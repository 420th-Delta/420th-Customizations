# Multiplayer Locality Validation

This harness validates the optional-mod boundary for Unified Weapons Rebalance
(UWR) and Blast Propagation (BP). BP has no custom production RPC: the machine
that owns a projectile at detonation computes the supplemental blast locally,
then uses Arma's global `setDamage` arguments. The mission's small test-control
RPCs only create, position, and trigger repeatable test shots.

## Expected 2x2 matrix

The ordinary shots stay local to the connected player or headless client. Both
native UWR splash and scripted BP must therefore follow the projectile owner's
mod set, not the dedicated server's mod set.

| Cell | Server | Projectile owner | Native UWR | BP at 100 m |
|---|---|---|---|---|
| `S0C0` / `P0C0` | Vanilla | Vanilla | No | No |
| `S1C0` / `P1C0` | Modded | Vanilla | No | No |
| `S0C1` / `P0C1` | Vanilla | Modded | Yes | Yes |
| `S1C1` / `P1C1` | Modded | Modded | Yes | Yes |

The runner checks the live addon state reported by each cell, so a missing or
unexpected mod does not silently turn a positive case into a passing negative
case.

Each cell performs these controlled `Bo_Mk82` detonations:

- 55 m verifies that native UWR splash follows the projectile owner;
- 100 m verifies the BP increment, with an upper bound that also catches
  duplicate processing when both machines have the addon;
- 255 m verifies the configured BP cutoff;
- a target pre-damaged to 0.4 at 100 m verifies additive damage and prevents a
  stale proxy value from healing the unit; and
- a live projectile transferred to the server before detonation verifies that
  processing follows the new owner. This final case intentionally follows the
  server's mod state rather than the creating client's state.

Graphical-player runs add a real 100 m Mk 82 case. The player is seated in a
vanilla A-143, fires its stock `Mk82BombLauncher`, and the harness records the
engine `Fired` event and shot parents before placing the projectile at the same
controlled impact point. This covers the ordinary weapon-created path without
turning natural flight and fusing into timing variables. Headless-client runs
use the deterministic synthetic path because an HC has no player entity.

When both the server and graphical shooter have Scalpel-L, the harness also
verifies that a remote caller cannot inject the owner-only engine fallback cue
while the same endpoint still accepts legitimate owner-local state.

When both sides have Turret Enhanced, the graphical run also takes control of
a real UAV turret and submits Apply and Move requests through the production
RPCs. It verifies the server's LOITER radius, terrain-clearance altitude, moved
center, and server-local ASL flight profile.

The harness no longer contains the Blast forged-report, registry-poisoning,
validation queue, watchdog, reservation, or displaced-origin fixtures. Those
belonged to the removed server-ingress architecture and would not exercise the
optimized owner-local implementation.

## Running the matrices

Build the package, then run both four-cell matrices from PowerShell:

```powershell
hemtt build
& .\tests\mp-locality\run-matrix.ps1
& .\tests\mp-locality\run-matrix.ps1 -ClientMode Player
```

Use `-OnlyCell S1C1` for one headless cell, or combine
`-ClientMode Player -OnlyCell P1C1` for one graphical cell. The launcher uses
random per-run server and admin passwords, copies the mission into a unique
test-only directory beside the Arma executable, launches isolated processes,
stores RPTs below ignored `artifacts/`, and removes the temporary mission in a
`finally` block. It fails unless the expected addon state is present, every
case passes, no ScriptError event appears, and the mission emits a successful
`SUITE_DONE`.

Pass additional local mod directories as a PowerShell array to include them on
each side marked modded while leaving the vanilla sides untouched:

```powershell
& .\tests\mp-locality\run-matrix.ps1 -ClientMode Player -ExtraMods `
    "D:\SteamLibrary\steamapps\workshop\content\107410\450814997", `
    "D:\SteamLibrary\steamapps\workshop\content\107410\497660133", `
    "D:\SteamLibrary\steamapps\workshop\content\107410\843577117"
```

Load every dependency required by the extra mods. The launcher defaults to the
repository's `.hemttout\build` directory; pass `-BuildPath <path>` to test a
different unpacked build.
