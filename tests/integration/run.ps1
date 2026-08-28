param(
    [string]$ArmaRoot = "D:\SteamLibrary\steamapps\common\Arma 3",
    [string]$BuildPath = $(
        Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) ".hemttout\build"
    ),
    [int]$TimeoutSeconds = 60,
    [int]$Port = 24150,
    [int]$ExpectedAssertions = 222,
    [string[]]$ExtraMods = @()
)

$ErrorActionPreference = "Stop"

$serverExe = Join-Path $ArmaRoot "arma3server_x64.exe"
$sourceMission = Join-Path $PSScriptRoot "mission\FDELTA_Integration_Auto.Stratis"
$serverConfig = Join-Path $PSScriptRoot "server.cfg"
$buildPbo = Join-Path $BuildPath "addons\fdelta_blast.pbo"
$missionName = "FDELTA_Integration_Auto.Stratis"
$mpMissionsRoot = Join-Path $ArmaRoot "MPMissions"
$missionTarget = Join-Path $mpMissionsRoot $missionName
$expectedMissionTarget = [IO.Path]::GetFullPath(
    (Join-Path ([IO.Path]::GetFullPath($mpMissionsRoot)) $missionName)
)
$resolvedMissionTarget = [IO.Path]::GetFullPath($missionTarget)

if ($resolvedMissionTarget -ne $expectedMissionTarget) {
    throw "Refusing unexpected mission target: $resolvedMissionTarget"
}
if (!(Test-Path -LiteralPath $serverExe -PathType Leaf)) {
    throw "Arma dedicated executable not found: $serverExe"
}
if (!(Test-Path -LiteralPath $sourceMission -PathType Container)) {
    throw "Integration mission not found: $sourceMission"
}
if (!(Test-Path -LiteralPath $serverConfig -PathType Leaf)) {
    throw "Server config not found: $serverConfig"
}
if (!(Test-Path -LiteralPath $buildPbo -PathType Leaf)) {
    throw "Built bundle not found at $BuildPath; run 'hemtt build' first."
}
$resolvedModPaths = @([IO.Path]::GetFullPath($BuildPath))
foreach ($extraMod in $ExtraMods) {
    $resolvedExtraMod = [IO.Path]::GetFullPath($extraMod)
    if (!(Test-Path -LiteralPath $resolvedExtraMod -PathType Container)) {
        throw "Extra mod directory not found: $resolvedExtraMod"
    }
    $resolvedModPaths += $resolvedExtraMod
}
$modArgument = $resolvedModPaths -join ";"
if (!(Test-Path -LiteralPath $mpMissionsRoot -PathType Container)) {
    throw "Arma MPMissions directory not found: $mpMissionsRoot"
}
if (Test-Path -LiteralPath $missionTarget) {
    throw "Refusing to overwrite pre-existing mission: $missionTarget"
}

$stamp = Get-Date -Format "yyyyMMdd-HHmmss-fff"
$artifactRoot = Join-Path $PSScriptRoot "artifacts\$stamp"
$profilePath = Join-Path $artifactRoot "profile"
$filteredLog = Join-Path $artifactRoot "assertions.log"
New-Item -ItemType Directory -Force -Path $profilePath | Out-Null

function Get-LatestRpt {
    Get-ChildItem -LiteralPath $profilePath -Filter "*.rpt" -File `
        -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
}

function Stop-IntegrationProcess {
    param([System.Diagnostics.Process]$Process)
    if ($null -eq $Process) { return }
    try {
        $Process.Refresh()
        if (!$Process.HasExited) {
            Stop-Process -Id $Process.Id -Force -ErrorAction Stop
            $Process.WaitForExit(10000) | Out-Null
        }
    } catch {
        Write-Warning (
            "Could not stop integration server PID {0}: {1}" -f `
                $Process.Id, $_.Exception.Message
        )
    }
}

$serverProcess = $null
$missionInstalled = $false
try {
    Copy-Item -LiteralPath $sourceMission -Destination $missionTarget `
        -Recurse -Force
    $missionInstalled = $true

    $serverArgs = @(
        "-profiles=`"$profilePath`"",
        "-name=FdeltaIntegrationTest",
        "-config=`"$serverConfig`"",
        "-mod=`"$modArgument`"",
        "-world=empty",
        "-autoInit",
        "-missionsToShutdown=1",
        "-ip=127.0.0.1",
        "-port=$Port",
        "-noSound",
        "-noSplash",
        "-skipIntro",
        "-noPause",
        "-noBE"
    )
    $serverProcess = Start-Process -FilePath $serverExe `
        -ArgumentList $serverArgs -WorkingDirectory $ArmaRoot `
        -WindowStyle Hidden -PassThru

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    $rpt = $null
    $done = $false
    while ((Get-Date) -lt $deadline -and !$done) {
        Start-Sleep -Milliseconds 500
        $rpt = Get-LatestRpt
        if ($null -ne $rpt) {
            $done = Select-String -LiteralPath $rpt.FullName `
                -SimpleMatch "FDELTA_INTEGRATION_DONE" -Quiet
        }
        $serverProcess.Refresh()
        if ($serverProcess.HasExited -and !$done) {
            break
        }
    }

    $rpt = Get-LatestRpt
    if ($null -eq $rpt) {
        throw "Dedicated server produced no RPT under $profilePath"
    }
    Select-String -LiteralPath $rpt.FullName -Pattern "FDELTA_INTEGRATION" |
        ForEach-Object { $_.Line } |
        Set-Content -LiteralPath $filteredLog

    $summaryMatch = Select-String -LiteralPath $rpt.FullName `
        -Pattern "FDELTA_INTEGRATION_SUMMARY\|pass=(true|false)\|passes=(\d+)\|failures=(\d+)\|scriptErrors=(\d+)" |
        Select-Object -Last 1
    if ($null -eq $summaryMatch) {
        throw "Integration summary not found before timeout. RPT: $($rpt.FullName)"
    }

    $match = [regex]::Match(
        $summaryMatch.Line,
        "FDELTA_INTEGRATION_SUMMARY\|pass=(true|false)\|passes=(\d+)\|failures=(\d+)\|scriptErrors=(\d+)"
    )
    $passed = $match.Groups[1].Value -eq "true"
    $passes = [int]$match.Groups[2].Value
    $failures = [int]$match.Groups[3].Value
    $scriptErrors = [int]$match.Groups[4].Value

    if (!$done) {
        throw "Integration mission did not reach its DONE marker. RPT: $($rpt.FullName)"
    }
    if (!$passed -or $failures -ne 0 -or $scriptErrors -ne 0) {
        throw "Integration failed: $($summaryMatch.Line). Log: $filteredLog"
    }
    if ($passes -ne $ExpectedAssertions) {
        throw "Expected $ExpectedAssertions assertions, observed $passes. Log: $filteredLog"
    }

    Write-Output (
        "420th integration passed: {0}/{0} assertions. Log: {1}" -f `
            $passes, $filteredLog
    )
} finally {
    Stop-IntegrationProcess -Process $serverProcess
    if (
        $missionInstalled -and
        [IO.Path]::GetFullPath($missionTarget) -eq $expectedMissionTarget -and
        (Test-Path -LiteralPath $missionTarget)
    ) {
        Remove-Item -LiteralPath $missionTarget -Recurse -Force
    }
}
