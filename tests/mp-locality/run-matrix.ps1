param(
    [string]$ArmaRoot = "D:\SteamLibrary\steamapps\common\Arma 3",
    [string]$BuildPath = $(
        Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) ".hemttout\build"
    ),
    [int]$TimeoutSeconds = 150,
    [ValidateSet("Headless", "Player")]
    [string]$ClientMode = "Headless",
    [string]$OnlyCell = "",
    [string[]]$ExtraMods = @()
)

$ErrorActionPreference = "Stop"

$serverExe = Join-Path $ArmaRoot "arma3server_x64.exe"
$playerExe = Join-Path $ArmaRoot "arma3_x64.exe"
$sourceMission = Join-Path $PSScriptRoot "mission\FDELTA_MP_Locality.Stratis"
$serverConfig = if ($ClientMode -eq "Player") {
    Join-Path $PSScriptRoot "server-player.cfg"
} else {
    Join-Path $PSScriptRoot "server.cfg"
}
$stamp = Get-Date -Format "yyyyMMdd-HHmmss-fff"
$mpFolderName = "FDELTA_Locality_Missions_$stamp"
$mpRoot = Join-Path $ArmaRoot $mpFolderName
$missionTarget = Join-Path $mpRoot "FDELTA_MP_Locality.Stratis"
$expectedMpRoot = [IO.Path]::GetFullPath(
    (Join-Path ([IO.Path]::GetFullPath($ArmaRoot)) $mpFolderName)
)
$resolvedMpRoot = [IO.Path]::GetFullPath($mpRoot)

if ($resolvedMpRoot -ne $expectedMpRoot) {
    throw "Refusing unexpected MPMissions target: $resolvedMpRoot"
}
if (!(Test-Path -LiteralPath $serverExe)) {
    throw "Arma dedicated executable not found: $serverExe"
}
if ($ClientMode -eq "Player" -and !(Test-Path -LiteralPath $playerExe)) {
    throw "Arma player executable not found: $playerExe"
}
if (!(Test-Path -LiteralPath $sourceMission)) {
    throw "Test mission not found: $sourceMission"
}
if (!(Test-Path -LiteralPath (Join-Path $BuildPath "addons\fdelta_blast.pbo"))) {
    throw "Built bundle not found: $BuildPath"
}

$resolvedExtraMods = @(
    $ExtraMods |
        Where-Object { ![string]::IsNullOrWhiteSpace($_) } |
        ForEach-Object {
            if (!(Test-Path -LiteralPath $_ -PathType Container)) {
                throw "Extra mod directory not found: $_"
            }
            [IO.Path]::GetFullPath($_)
        }
)
$modPath = (@([IO.Path]::GetFullPath($BuildPath)) + $resolvedExtraMods) -join ";"

$artifactRoot = Join-Path $PSScriptRoot "artifacts\$stamp"
New-Item -ItemType Directory -Force -Path $artifactRoot | Out-Null
$summaryPath = Join-Path $artifactRoot "summary.log"
$cellFailures = [System.Collections.Generic.List[string]]::new()
$testPassword = [Guid]::NewGuid().ToString("N")
$testAdminPassword = [Guid]::NewGuid().ToString("N")
$runtimeServerConfig = Join-Path $artifactRoot "server-runtime.cfg"
$serverConfigText = Get-Content -LiteralPath $serverConfig -Raw
$serverConfigText = [regex]::Replace(
    $serverConfigText,
    '(?m)^\s*password\s*=\s*"[^"]*"\s*;',
    ('password = "{0}";' -f $testPassword)
)
$serverConfigText = [regex]::Replace(
    $serverConfigText,
    '(?m)^\s*passwordAdmin\s*=\s*"[^"]*"\s*;',
    ('passwordAdmin = "{0}";' -f $testAdminPassword)
)
Set-Content -LiteralPath $runtimeServerConfig -Value $serverConfigText `
    -Encoding ASCII

$cells = if ($ClientMode -eq "Player") {
    @(
        [pscustomobject]@{Name="P0C0"; ServerMod=$false; ClientMod=$false; Port=24322},
        [pscustomobject]@{Name="P1C0"; ServerMod=$true;  ClientMod=$false; Port=24332},
        [pscustomobject]@{Name="P0C1"; ServerMod=$false; ClientMod=$true; Port=24342},
        [pscustomobject]@{Name="P1C1"; ServerMod=$true;  ClientMod=$true; Port=24352}
    )
} else {
    @(
        [pscustomobject]@{Name="S0C0"; ServerMod=$false; ClientMod=$false; Port=24222},
        [pscustomobject]@{Name="S1C0"; ServerMod=$true;  ClientMod=$false; Port=24232},
        [pscustomobject]@{Name="S0C1"; ServerMod=$false; ClientMod=$true;  Port=24242},
        [pscustomobject]@{Name="S1C1"; ServerMod=$true;  ClientMod=$true;  Port=24252}
    )
}
if ($OnlyCell -ne "") {
    $cells = @($cells | Where-Object { $_.Name -eq $OnlyCell })
    if ($cells.Count -ne 1) {
        throw "Unknown cell '$OnlyCell' for client mode '$ClientMode'"
    }
}

function Stop-TestProcess {
    param([System.Diagnostics.Process]$Process)
    if ($null -eq $Process) { return }
    try {
        $Process.Refresh()
        if (!$Process.HasExited) {
            Stop-Process -Id $Process.Id -Force -ErrorAction Stop
            $Process.WaitForExit(10000) | Out-Null
        }
    } catch {
        Add-Content -LiteralPath $summaryPath -Value (
            "PROCESS_STOP_WARNING|pid={0}|message={1}" -f $Process.Id, $_.Exception.Message
        )
    }
}

function Get-LatestRpt {
    param([string]$ProfilePath)
    Get-ChildItem -LiteralPath $ProfilePath -Filter "*.rpt" -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
}

try {
    if (Test-Path -LiteralPath $mpRoot) {
        throw "Refusing pre-existing temporary MPMissions path: $mpRoot"
    }
    New-Item -ItemType Directory -Force -Path $mpRoot | Out-Null
    Copy-Item -LiteralPath $sourceMission -Destination $missionTarget -Recurse -Force

    foreach ($cell in $cells) {
        $cellRoot = Join-Path $artifactRoot $cell.Name
        $serverProfile = Join-Path $cellRoot "server"
        $clientProfile = Join-Path $cellRoot "client"
        New-Item -ItemType Directory -Force -Path $serverProfile, $clientProfile | Out-Null

        $serverProcess = $null
        $clientProcess = $null
        Add-Content -LiteralPath $summaryPath -Value (
            "CELL_BEGIN|name={0}|serverMod={1}|clientMod={2}|port={3}" -f `
                $cell.Name, $cell.ServerMod, $cell.ClientMod, $cell.Port
        )
        if ($cell.ServerMod -or $cell.ClientMod) {
            Add-Content -LiteralPath $summaryPath -Value (
                "CELL_MOD_PATH|name={0}|path={1}" -f $cell.Name, $modPath
            )
        }

        try {
            # Arma clients did not join this harness when the server used an
            # explicit -ip=127.0.0.1 bind. Listen normally, connect through
            # loopback, and protect the short-lived instance with the random
            # per-run credentials written to $runtimeServerConfig above.
            $serverArgs = @(
                "-profiles=`"$serverProfile`"",
                "-name=FdeltaServer_$($cell.Name)",
                "-config=`"$runtimeServerConfig`"",
                "-port=$($cell.Port)",
                "-mpmissions=$mpFolderName",
                "-world=empty",
                "-autoInit",
                "-noSound",
                "-noSplash",
                "-skipIntro",
                "-noPause",
                "-noBE",
                "-limitFPS=60"
            )
            if ($cell.ServerMod) {
                $serverArgs += "-serverMod=`"$modPath`""
            }
            $serverProcess = Start-Process -FilePath $serverExe `
                -ArgumentList $serverArgs -WorkingDirectory $ArmaRoot `
                -WindowStyle Hidden -PassThru

            Start-Sleep -Seconds 7
            $clientArgs = @(
                "-connect=127.0.0.1",
                "-port=$($cell.Port)",
                "-password=$testPassword",
                "-profiles=`"$clientProfile`"",
                "-name=FdeltaClient_$($cell.Name)",
                "-world=empty",
                "-noSound",
                "-noSplash",
                "-skipIntro",
                "-noPause",
                "-noBE",
                "-limitFPS=60"
            )
            $clientExe = $serverExe
            if ($ClientMode -eq "Headless") {
                $clientArgs = @("-client") + $clientArgs
            } else {
                $clientExe = $playerExe
                $clientArgs += @("-window", "-x=640", "-y=480")
            }
            if ($cell.ClientMod) {
                $clientArgs += "-mod=`"$modPath`""
            }
            $clientProcess = Start-Process -FilePath $clientExe `
                -ArgumentList $clientArgs -WorkingDirectory $ArmaRoot `
                -WindowStyle Hidden -PassThru

            $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
            $done = $false
            $serverRpt = $null
            while ((Get-Date) -lt $deadline -and !$done) {
                Start-Sleep -Seconds 1
                $serverProcess.Refresh()
                $clientProcess.Refresh()
                if ($serverProcess.HasExited -or $clientProcess.HasExited) { break }
                $serverRpt = Get-LatestRpt -ProfilePath $serverProfile
                if ($null -ne $serverRpt) {
                    $done = Select-String -LiteralPath $serverRpt.FullName `
                        -SimpleMatch "event=SUITE_DONE" -Quiet
                }
            }

            $serverRpt = Get-LatestRpt -ProfilePath $serverProfile
            $clientRpt = Get-LatestRpt -ProfilePath $clientProfile
            Add-Content -LiteralPath $summaryPath -Value (
                "CELL_STATUS|name={0}|done={1}|serverExited={2}|clientExited={3}|serverRpt={4}|clientRpt={5}" -f `
                    $cell.Name, $done, $serverProcess.HasExited, $clientProcess.HasExited, `
                    $(if ($serverRpt) {$serverRpt.FullName} else {""}), `
                    $(if ($clientRpt) {$clientRpt.FullName} else {""})
            )
            if ($serverRpt) {
                Select-String -LiteralPath $serverRpt.FullName `
                    -Pattern "FDELTA_MPLOC|FDELTA_BLAST" |
                    ForEach-Object { $_.Line } |
                    Add-Content -LiteralPath $summaryPath
            }
            if ($clientRpt) {
                Select-String -LiteralPath $clientRpt.FullName `
                    -Pattern "FDELTA_MPLOC|FDELTA_BLAST" |
                    ForEach-Object { "CLIENT_RPT|" + $_.Line } |
                    Add-Content -LiteralPath $summaryPath
            }
            if (!$done) {
                throw "Cell did not reach SUITE_DONE before exit or timeout"
            }

            # A negative behavior test is meaningful only when the intended
            # addon boundary actually loaded. The mission reports, in order,
            # server UWR, server BP, owner UWR, owner BP, and expected owner BP.
            $serverState = $cell.ServerMod.ToString().ToLowerInvariant()
            $ownerState = $cell.ClientMod.ToString().ToLowerInvariant()
            $expectedMatrixState = (
                "event=MATRIX_STATE|data=[{0},{0},{1},{1},{1}]" -f `
                    $serverState, $ownerState
            )
            if (
                !(Select-String -LiteralPath $serverRpt.FullName `
                    -SimpleMatch $expectedMatrixState -Quiet)
            ) {
                throw (
                    "Cell did not report expected addon/owner state: {0}" -f `
                        $expectedMatrixState
                )
            }
            $scriptErrorReports = @(
                @($serverRpt, $clientRpt) |
                    Where-Object { $null -ne $_ } |
                    ForEach-Object {
                        Select-String -LiteralPath $_.FullName `
                            -SimpleMatch "FDELTA_MPLOC_SCRIPT_ERROR|"
                    }
            )
            if ($scriptErrorReports.Count -gt 0) {
                $scriptErrorReports |
                    ForEach-Object { "SCRIPT_ERROR_RPT|" + $_.Line } |
                    Add-Content -LiteralPath $summaryPath
                throw "Cell emitted one or more ScriptError events"
            }
            if (
                !(Select-String -LiteralPath $serverRpt.FullName `
                    -SimpleMatch 'event=SUITE_DONE|data=[true' -Quiet)
            ) {
                throw "Cell reached SUITE_DONE with an unsuccessful result"
            }
        } catch {
            $cellFailures.Add(("{0}: {1}" -f $cell.Name, $_.Exception.Message))
            Add-Content -LiteralPath $summaryPath -Value (
                "CELL_ERROR|name={0}|message={1}" -f $cell.Name, $_.Exception.Message
            )
        } finally {
            Stop-TestProcess -Process $clientProcess
            Stop-TestProcess -Process $serverProcess
        }
    }
} finally {
    if ([IO.Path]::GetFullPath($mpRoot) -eq $expectedMpRoot -and (Test-Path -LiteralPath $mpRoot)) {
        Remove-Item -LiteralPath $mpRoot -Recurse -Force
    }
}

if ($cellFailures.Count -gt 0) {
    throw (
        "420th MP locality {0} matrix failed: {1}. Summary: {2}" -f `
            $ClientMode, ($cellFailures -join "; "), $summaryPath
    )
}

Write-Output "420th MP locality $ClientMode matrix complete: $summaryPath"
