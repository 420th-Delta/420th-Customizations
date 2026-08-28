# Dedicated-server integration smoke test

This combined-package mission validates the imported patches and function
registrations, ammo changes and inheritance pins, vanilla-identity guided 155 mm
terminals, conditional CUP/RHS policies without a CUP compatibility shim,
the four-function Blast surface, its local profile cache and additive damage,
Scalpel-L classes and cue RPC, and Turret Enhanced loiter behavior and scoped
RPCs. It also verifies that Blast exposes no RPCs or permanent queue/worker
state. The current suite emits 222 assertions and fails on any assertion or SQF
`ScriptError` event.

Build the mod and run the test from the repository root:

```powershell
hemtt build
.\tests\integration\run.ps1
```

The runner starts a hidden dedicated server with the HEMTT build, waits for the
mission summary, then stops only that process and removes only its temporary
mission copy. Profiles and the filtered assertion log are retained under the
ignored `tests/integration/artifacts/` directory.

Override paths or timeout when needed:

```powershell
.\tests\integration\run.ps1 -ArmaRoot "D:\SteamLibrary\steamapps\common\Arma 3" -BuildPath ".\.hemttout\build" -TimeoutSeconds 90
```

Load supported optional dependencies to exercise their conditional effective-
config assertions as well:

```powershell
.\tests\integration\run.ps1 -ExtraMods @(
    "D:\SteamLibrary\steamapps\workshop\content\107410\450814997",
    "D:\SteamLibrary\steamapps\workshop\content\107410\497660133",
    "D:\SteamLibrary\steamapps\workshop\content\107410\843577117"
)
```
