# Multiplayer Locality Validation

This harness compares client-owned explosive behavior in four deployments:

1. vanilla server and vanilla headless client;
2. modded server and vanilla headless client;
3. vanilla server and modded headless client; and
4. modded server and modded headless client.

The mission has only vanilla dependencies. For each cell, an independently
running headless client owns and detonates a `Bo_Mk82` while the dedicated
server measures fresh AI targets at 55, 100, and 255 metres. RPT telemetry
records each machine's live `CfgAmmo`, projectile locality, native
`HandleDamage`, Blast Propagation state, and final damage.

Graphical-client runs add a fourth case at 100 metres. That case seats the
player in a vanilla A-143, arms its stock `Mk82BombLauncher`, records the
engine's `Fired` event and shot parents, then uses the same controlled impact
point. This distinguishes a merely client-created test object from a projectile
made through Arma's real vehicle-weapon path. It does not test natural bomb
flight or fusing.

Before those shots, each modded-server graphical cell also has the client try
the former forged-registry exploit: it publishes a fake Blast registry and a
`damageMultiplier` of 100 to the server, calls the public report endpoint, and
places a target inside the forged envelope. A passing build leaves that target
undamaged because every trusted value is kept in `localNamespace`.

The same cell sends a forged high-priority Scalpel-L `engine-hard-lock` cue
through the public cue endpoint. The remote cue must leave no trusted registry
entry, while an otherwise identical owner-local fallback cue must be accepted;
this guards the distinction between authenticated player-camera traffic and
owner-only AI/engine fallbacks.

Positive cells also send a plausible but displaced explosion position and
verify that damage uses the server-observed projectile origin. A separate case
reserves an early report, transfers the live projectile to the server, pauses
the registry monitor, and detonates immediately. It passes only if Explode-time
evidence supersedes the stale reservation and commits exactly once.

The following graphical-client results were observed on the current integrated
build:

| Server | Client | Live Mk 82 config | Actual weapon shot at 100 m |
|---|---|---|---|
| Vanilla | Vanilla | `1100 / 12` | No BP evidence; zero damage |
| Vanilla | Modded | `3200 / 16.25` | No BP evidence; zero damage |
| Modded | Unmodded | `1100 / 12` | No BP evidence; zero damage |
| Modded | Modded | `3200 / 16.25` | Evidence validated; approximately `0.18` BP damage |

The headless-client 2x2 matrix has the same BP boundary. Only the modded
server/modded HC cell validates supplemental damage (approximately `0.18` at
100 m); native 55 m damage follows whether the HC projectile owner is modded.

Build the package with `hemtt build`, then run `run-matrix.ps1` from PowerShell
for the four headless-client cells. Run `run-matrix.ps1 -ClientMode Player` for
a complete graphical-client 2x2 matrix. Together they verify ordinary player
RPCs and the HC recovery path Arma masks as owner 0/server-local. The launcher
uses random per-run server and admin passwords, temporarily copies the mission
into a uniquely named test-only directory beside the Arma executable, launches
isolated server/client processes, stores RPTs below ignored `artifacts/`, and
removes the temporary mission directory in a `finally` block. The command
returns failure unless every requested cell reaches a successful `SUITE_DONE`
and satisfies its expected damage behavior.

```powershell
hemtt build
& .\tests\mp-locality\run-matrix.ps1
& .\tests\mp-locality\run-matrix.ps1 -ClientMode Player
```

Use `-OnlyCell S1C1` for the headless positive control, or combine
`-ClientMode Player -OnlyCell P1C1` for the graphical positive control.

Pass additional local mod directories as a PowerShell array to include them on
each side marked modded while leaving the vanilla sides untouched:

```powershell
& .\tests\mp-locality\run-matrix.ps1 -ClientMode Player -ExtraMods `
    "D:\SteamLibrary\steamapps\workshop\content\107410\450814997", `
    "D:\SteamLibrary\steamapps\workshop\content\107410\497660133", `
    "D:\SteamLibrary\steamapps\workshop\content\107410\843577117"
```

The example includes CBA_A3 because CUP Weapons declares it as a dependency.
Load every dependency required by the extra mods or Arma will stop before the
test mission initializes.

HC-originated remote execution reports owner `0` and can appear server-local.
The addon therefore binds a request to server-observed projectile/registry
ownership and verifies that owner as a connected HC. Arma does not expose which
HC made the call, so all configured HCs share one trusted server-infrastructure
domain; this harness verifies support for trusted HCs, not isolation from a
hostile HC that already has the server's HC password.

The launcher defaults to the repository's `.hemttout\build` directory. Pass
`-BuildPath <path>` to test a different unpacked mod build.
