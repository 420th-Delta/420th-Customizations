# Gameplay and Compatibility Details

This page documents the gameplay and compatibility features integrated from
the A3TI MH-80 Camera Pod Fix, DAGR-AirLock, Unitary Warhead Rebalance, Blast
Propagation, Scalpel-L, and Turret Enhanced Rebuilt projects. Their public
classes, functions, and variables use the 420th Customizations `fdelta`
namespace.

## Packaging and Multiplayer

These features ship as parts of one mod rather than independently selectable
Workshop items:

| Addon | Purpose | Multiplayer placement |
|---|---|---|
| `fdelta_a3ti` | A3TI camera compatibility | Opted-in clients; activates only where A3TI is loaded |
| `fdelta_ammo` | DAGR and unitary HE config changes | Server and each projectile owner that should use the changes |
| `fdelta_ammo_cup` | CUP terminal-ammo compatibility | Conditional; activates only with CUP Weapons |
| `fdelta_ammo_rhsusaf` | RHSUSAF ammo compatibility | Conditional; activates only with RHSUSAF and Blast Propagation |
| `fdelta_blast` | Supplemental blast trauma | Server and each supported projectile owner |
| `fdelta_scalpel_l` | New pylon weapon and guidance | Server and every machine that may own a Scalpel-L projectile |
| `fdelta_turret_enhanced` | Camera UI and UAV control | Server, control users, and every machine that may own the UAV |

`fdelta_a3ti` skips itself when A3TI is absent, so it does not make A3TI a
requirement for users who do not use it. A3TI itself requires CBA_A3. The CUP
and RHSUSAF compatibility PBOs likewise skip themselves when their dependency
is absent. The core gameplay features in this page have no CBA dependency.

The mod can be server-installed and player-optional when the server accepts mod
disparity and the mission does not declare 420th-only assets as required. For
supported explosives, enhanced behavior is guaranteed only when the server and
the machine that owns and simulates the projectile load the same release.
Ammunition config is read on the projectile-owning machine. Blast Propagation
listens there and validates its reports on the server. Scalpel-L guidance also
runs where its projectile is local. Turret Enhanced combines client UI, server
validation, and execution on the UAV-owning machine.

A dedicated-server matrix on Arma 3 `2.22.154045` measured the following with
an actual `Mk82BombLauncher` shot from a graphical player's aircraft:

| Server | Firing client | Client Mk 82 config | Clear target at 100 m |
|---|---|---|---|
| Vanilla | Modded | `3200 / 16.25` | No native damage and no supplemental BP dose |
| Modded | Unmodded | `1100 / 12` | No native damage and no supplemental BP dose |
| Modded | Modded | `3200 / 16.25` | BP validated the shot and applied approximately `0.18` damage |

The modded graphical client also killed the 55 m target through native UWR
damage. An unmodded graphical client on the modded server caused no damage at
that distance. Thus, an opted-in player gets UWR for supported projectiles that
remain local to that player's machine, and gets BP when the server is also
modded. An unmodded projectile owner is not promised either enhancement.

This is a locality-qualified guarantee, not a promise that every weapon used by
a modded person is always enhanced. Vehicle locality commonly follows the
driver, so a modded passenger gunner may fire a projectile simulated by an
unmodded vehicle owner. Server-local AI and other server-owned projectiles use
the server's config; this is particularly relevant in PvE. An unmodded player
can still receive globally authoritative damage caused by a modded projectile
owner even though that victim does not load 420th Customizations.

If AI or vehicles are offloaded to a headless client, load 420th Customizations
on that HC to obtain native UWR and supplemental BP. Arma exposes HC RPCs with
`remoteExecutedOwner = 0` and can report `isRemoteExecuted = false`, so BP binds
the anonymous request to the server-observed projectile or registry owner and
verifies that owner through `allUsers`/`getUserInfo` as a connected HC. The
complete HC 2x2 matrix validates this path.

Configured HCs are trusted server infrastructure. Because the engine erases
the individual HC caller identity, all connected HCs share one trusted ingress
domain and cannot be isolated from one another as hostile clients. Do not give
the HC password to untrusted machines. Scalpel-L guidance and Turret Enhanced
flight changes likewise require their projectile or UAV owner to have the mod.

Scalpel-L adds custom weapon, magazine, and ammunition classes. A mission that
places or declares those classes can make `fdelta_scalpel_l` a mission
dependency even when the server otherwise permits missing assets. For a truly
optional deployment, keep the saved mission vanilla-compatible and assign the
custom pylon magazine at runtime only for opted-in users.

A mission-level `CfgRemoteExec` policy can override an addon's declarations.
Server administrators must allow the documented functions if their mission
uses a restrictive allowlist. Signature or exact-mod-parity policies must also
allow the same signed release on connecting clients.

Blast Propagation needs `fdelta_fnc_blastRegisterProjectileEvidence` and
`fdelta_fnc_blastReceiveBlast` on the server, plus
`fdelta_fnc_blastClientEffect` on clients. Scalpel-L needs
`fdelta_fnc_scalpelLReceiveCue` on the projectile owner. Turret Enhanced's four
remote functions are listed in its section below.

Do not load the standalone **ZBR Gameplay Enhancements** bundle, the original
Turret Enhanced addons, or the standalone source-project releases alongside a
420th release containing these integrations. The duplicated BP listeners can
apply supplemental trauma twice, duplicated Turret Enhanced actions can issue
competing UAV commands, and the separate Scalpel-L namespaces create duplicate
weapons. Remove the standalone bundle when migrating to this 420th release.

## A3TI MH-80 Camera Pod Compatibility

The compatibility resolver preserves A3TI's normal UAV and turret behavior,
then checks the active camera pylon while the player is in `GUNNER` view. It
uses Arma's camera-pylon lookup, verifies the live pylon magazine and the
occupied turret, and returns that magazine's `CameraComponent/PilotCamera`
configuration to A3TI.

The known target is the removable Camera Pod on all six vanilla MH-80 DAP and
Assault base, sand, and tropic variants, from either pilot or copilot ownership
and with any of the four camera-pod liveries. Radar and searchlight pods do not
expose the matching thermal-capable camera configuration and therefore remain
on their normal vision path.

This fix does not edit `CfgVehicles` or `CfgMagazines`, nor does it redistribute
or modify A3TI shaders, textures, settings, initialization, or keybinds. A3TI
and CBA_A3 remain external dependencies. The existing 420th camera-exit cleanup
that prevents pink units and vehicles is retained and should be regression
tested alongside this resolver.

Arma's `switchCamera` command cannot enter the driver's Multifunction Camera,
so pilot-owned pod combinations require a manual in-game test. Non-matching
vehicles, non-camera pods, on-foot play, and ordinary turret optics should
continue through A3TI's original resolver behavior.

## DAGR and DAGRM Air Locking

The vanilla DAGR and DAGRM remain eligible against ground targets while gaining
aircraft eligibility. Their missile-lock, IR-tracking, laser-tracking, magazine
lead, and AI lead-speed gates allow targets travelling at up to 700 m/s.

The change does not tune thrust, manoeuvrability, damage, guidance profiles,
seeker range or cones, or countermeasure resistance. DAR inherits from the
same vanilla family, so its targeting and speed gates are explicitly pinned to
their original behavior while retaining the separate DAR blast rebalance.

A successful lock is not a promise of interception. The rockets retain their
original flight performance, so warmed helicopters, UAVs, and fixed-wing
aircraft should be tested at different speeds, aspects, altitudes, and
backgrounds. Player and AI acquisition should be tested separately, along with
continued guidance against ground vehicles.

The patch edits vanilla base classes. CUP, RHS, or another addon can therefore
inherit a changed value when its ammunition descends from one of those classes
and does not override the field itself. Server maintainers should inspect the
effective config with their complete modset after either 420th or a dependency
updates; a source-level class-name review cannot prove the final merged result.

## Unitary Warhead Rebalance

This config-only pass changes native indirect damage for selected unitary HE
ordnance. Values are `indirectHit / indirectHitRange`; native damage reaches
zero at approximately four times the configured range.

| Weapon/system | `CfgAmmo` | Vanilla | Rebalanced | Approx. cutoff |
|---|---|---:|---:|---:|
| Mk 82 | `Bo_Mk82` | 1100 / 12 | 3200 / 16.25 | 65 m |
| GBU-12 | `Bomb_04_F` | 1100 / 12 | 3200 / 16.25 | 65 m |
| LOM-250G / KAB-250 | `Bomb_03_F` | 1400 / 16 | 3600 / 18.75 | 75 m |
| Small Diameter Bomb | `ammo_Bomb_SDB` | 85 / 3 | 1600 / 10 | 40 m |
| Shrieker HE | `Rocket_04_HE_F` | 55 / 15 | 300 / 10 | 40 m |
| Tratnyr HE | `Rocket_03_HE_F` | 55 / 15 | 300 / 10 | 40 m |
| DAR | `M_AT` | 50 / 8 | 250 / 7.5 | 30 m |
| Skyfire | `R_80mm_HE` | 60 / 15 | 350 / 10 | 40 m |
| AGM-88C HARM | `ammo_Missile_HARM` | 85 / 8 | 2000 / 15 | 60 m |
| KH-58 | `ammo_Missile_KH58` | 85 / 8 | 2800 / 18.75 | 75 m |
| 155 mm SPG HE | `Sh_155mm_AMOS` | 125 / 30 | 3600 / 8.75 | 35 m |
| 155 mm guided terminal | `fdelta_M_Mo_155mm_HE_Guided` | 200 / 4 base | 3600 / 8.75 | 35 m |
| 155 mm laser terminal | `fdelta_M_Mo_155mm_HE_LG` | 200 / 4 base | 3600 / 8.75 | 35 m |
| 230 mm M5/Zamak terminal | `R_230mm_fly` | 800 / 30 | 3200 / 16.25 | 65 m |
| Mk41 VLS unitary cruise | `ammo_Missile_Cruise_01` | 2000 / 30 | 7000 / 30 | 120 m |

Direct-hit damage, guidance, flight performance, fusing, sensors, and weapon
magazines are not changed. Guided 155 mm shells are deployment carriers, so
they are redirected to isolated terminal subclasses. This tunes only the
ground impact and avoids a false carrier blast.

Aircraft and VLS cluster carriers, AP Shrieker and Tratnyr leaves, and Mk45
destroyer ammunition are explicitly pinned to their vanilla damage or terminal
classes. Air-to-air missiles, Scalpel, DAGR/DAGRM, tandem or penetrator
anti-armor weapons, cluster submunitions, non-HE artillery, latent 230 mm
guided/anti-armor ammunition, and Mk45 are deliberately outside this pass.

As with DAGR, third-party descendants can inherit these vanilla-class edits.
Conditional compatibility PBOs make the known CUP/RHS behavior explicit:

- CUP 105 mm and 122 mm laser-guided shells retain their original
  `M_Mo_155mm_AT_LG` terminal instead of inheriting the vanilla 155 mm redirect.
- RHS Mk 82 receives the complete `3200 / 16.25` native policy and an exact Mk
  82 BP profile. RHS cluster carriers retain `1150 / 12` and receive no BP
  profile.
- RHS DAGR retains its native `41.6667` m/s magazine lead-speed policy rather
  than inheriting only part of the vanilla 700 m/s DAGR change.

The explicit pins protect the known exclusions, and the installed CBA, CUP
Weapons, and RHSUSAF set passes the effective-config suite. Other descendants
can still change after a dependency update and should be regression tested with
the production modset.

The Mk 82/GBU-12 is the empirical gameplay anchor. The remaining values are
proportional first-pass approximations and must not be presented as measured or
classified real-world lethality data.

### Calibration References

- [U.S. Army JPEO Armaments & Ammunition Portfolio Book][JPEOAA]
- [U.S. Army Weapon Systems Handbook][Army handbook]
- [U.S. Navy Tomahawk Cruise Missile fact file][Navy Tomahawk]

[JPEOAA]: https://jpeoaa.army.mil/Portals/94/Documents/JPEOAAPortfolioBook_2025.pdf
[Army handbook]: https://www.army.mil/e2/downloads/rv7/2020-2021_Weapon_Systems_Handbook.pdf
[Navy Tomahawk]: https://www.navy.mil/Resources/Fact-Files/Display-FactFiles/Article/2169229/tomohawk-cruise-missile/

## Blast Propagation

Blast Propagation adds a supplemental, server-authoritative trauma channel for
the rebalance's selected unitary HE ammunition. It does not create a second
explosion and does not edit `hit`, `indirectHit`, or `indirectHitRange`.

The native rebalance owns clear targets inside each handoff. Such targets
receive no duplicate scripted injury. If the engine's low indirect-fire ray is
blocked inside that zone, a raised-origin correction models partial propagation
past shallow terrain or objects. Outside the handoff, a distance-graded dose
can accumulate across repeated exposures.

| Munition | Native/BP handoff | Outer boundary | Virtual lift |
|---|---:|---:|---:|
| Mk 82 / GBU-12 / RHS Mk 82 | 65 m | 250 m | 4 m |
| LOM/KAB | 75 m | 275 m | 4.5 m |
| SDB | 40 m | 145 m | 3 m |
| 155 mm HE | 35 m | 125 m | 2.5 m |
| 230 mm unitary HE | 65 m | 250 m | 4 m |
| VLS unitary cruise | 120 m | 400 m | 6 m |
| Shrieker/Tratnyr HE | 40 m | 90 m | 2 m |
| DAR | 30 m | 80 m | 1.75 m |
| Skyfire | 40 m | 100 m | 2 m |
| HARM | 60 m | 190 m | 3.5 m |
| KH-58 | 75 m | 250 m | 4 m |

The outer boundary is a potential-incapacitation boundary, not a guaranteed
kill radius. Existing trauma decays with a 30-minute half-life and can increase
later increments by up to 50 percent at default settings.

Cover uses one low `IFIRE` ray plus three raised rays toward pelvis, torso, and
head. A shallow terrain obstruction cleared by a raised ray retains 95 percent
transmission; deep terrain retains 35 percent. Raised-clear and fully blocking
rocks retain 85 and 40 percent. Hard cover retains 35 or 20 percent, light
cover 75 percent, and unclassified objects 65 or 40 percent. Multiple object
layers multiply attenuation, with an 8 percent floor. Actual airbursts are not
lifted again.

Only dismounted `CAManBase` targets are affected in this version. Vehicle
damage and occupants of enclosed vehicles remain native. The nearest targets
are processed first if a blast exceeds the default 256-target cap.

The projectile-owning machine reports one local explosion. The server validates
the exact ammo registry, report ownership, timing, and position, de-duplicates
reports, queues bursts, and alone applies trauma with killer/instigator
attribution. JIP machines install the projectile listener at pre-init; there is
no persistent remote-execution payload.

Ordinary client ingress is accepted only through unscheduled `remoteExecCall`.
HC ingress is recovered from the trusted server-side ownership evidence because
Arma masks its remote context. Both paths use per-owner and global token buckets
before entering a server-local validation worker. Registry, validation, target,
and damage queues are independently bounded; validators are capped at 32 by
default. Caller positions are advisory—the committed origin comes from the
server's projectile track.

Legacy `fdelta_blast_*` mission variables are read once during pre-init as
defaults. Direct assignments after that snapshot are deliberately
non-authoritative. Apply runtime changes from server-local code through the
validated configuration API instead:

```sqf
[createHashMapFromArray [
    ["fdelta_blast_enabled", true],
    ["fdelta_blast_damageMultiplier", 1],
    ["fdelta_blast_halfLife", 1800],
    ["fdelta_blast_cumulativeGain", 0.5],
    ["fdelta_blast_maxTargets", 256],
    ["fdelta_blast_maxDamageQueue", 128],
    ["fdelta_blast_maxRegistry", 512],
    ["fdelta_blast_debug", false]
]] call fdelta_fnc_blastConfigureServer;
```

The function also accepts an array of `[name, value]` pairs as its first
argument. It validates types, clamps workload limits, ignores unknown names,
stores the authoritative settings in `localNamespace`, and returns a detached
copy. Ingress refill values are tokens per second; change security limits only
after measuring a legitimate high-volume workload.

Profiles are stored in `CfgFdeltaBlastProfiles`. The vanilla adapter uses
server-side `setDamage`, which bypasses wearable armor and accumulates naturally
but does not create `HandleDamage` wounds. ACE or another replacement medical
system requires a dedicated adapter; this version does not claim ACE medical
compatibility and does not force an unconscious state.

## Scalpel-L

Scalpel-L is a separate pylon weapon derived from the vanilla Scalpel ATGM. It
inherits stock models, racks, propulsion, tandem-HEAT warhead, sounds, effects,
and hardpoints; no vanilla Scalpel class is patched.

Included pylon magazines are:

- `fdelta_PylonRack_1Rnd_Scalpel_L`
- `fdelta_PylonMissile_1Rnd_Scalpel_L`
- `fdelta_PylonRack_3Rnd_Scalpel_L`
- `fdelta_PylonRack_4Rnd_Scalpel_L`

At launch, one immutable cue is captured:

1. A full object or laser lock tracks that exact object during the scripted
   trajectory and hands it to native homing only at the vertical dive gate.
2. A selected target without a full lock freezes its launch-time position.
3. With no selection, the center camera ray is sampled once and then frozen.

Within 1,600 m of the launch aimpoint, a 45-degree terminal seeker considers
enemy ground vehicles visible to the configured radar/IR sensors and physical
line of sight. Candidates are ranked by distance from the immutable aimpoint,
then angular offset, then missile distance. A nearer intended candidate outside
the current cone causes the missile to wait rather than select a farther decoy.
After a confirmed native lock loss, the missile clears the object, returns
toward the original aimpoint, and uses the same ranking for reacquisition.
Laser reacquisition remains bound to the selected launch-time laser identity.

Normal-range shots climb at 40 degrees to an apex roughly 900 m over the target,
use a 500 m-radius quarter-circle, and enter a 400 m vertical run. Shots inside
1,500 m use direct guidance because the complete loft does not fit. No proxy
target is created, and moving the camera after launch cannot steer the missile.

The inherited racks fit the stock To-199 Neophron, A-164 Wipeout, and A-143
Buzzard. The Black Wasp, Shikra, Gryphon, and Sentinel use different hardpoints
and need a separate compatibility patch.

The server, firing operator, and every machine that can own the projectile
should load the same 420th release. The operator sends one cue to the projectile
owner; all subsequent steering and sensor work is owner-local, with no
per-frame network traffic. A modded gunner cannot guarantee scripted guidance
when an unmodded pilot or another unmodded machine owns the vehicle or missile.
Guidance stops safely if unusual mid-flight locality migration occurs, but it
does not resume on the new owner. The selected-but-incomplete branch also
depends on the carrier UI exposing its selection through `playerTargetLock`.

Set `fdelta_scalpelL_debug = true` in mission namespace to log launch,
midcourse, terminal, and recovery transitions.

## Turret Enhanced

Turret Enhanced is a separately namespaced replacement for the unsupported
Turret Enhanced addon. It does not reuse or patch the old addon and has no CBA
dependency. Disable Turret Enhanced and Turret Enhanced Plus when using this
implementation to avoid duplicated actions and conflicting flight commands.

From an aircraft gunner optic or remotely controlled UAV gunner camera, it can:

- open UAV loiter controls for ASL altitude, minimum AGL clearance, and radius;
- place a side-colored or red, shared, user-deletable marker at camera aim;
- move the active `LOITER` waypoint center to camera aim; and
- capture two camera points and report 2D distance and bearing.

The features are available through scroll-wheel actions and assignable addon
controls. No keys are bound by default.

Absolute altitude combines `flyInHeightASL` with a low `flyInHeight` value used
only as a terrain-clearance safety floor. The aircraft therefore avoids routine
terrain-following but may climb when terrain violates the floor. Arma AI,
collision avoidance, objects, or combat behavior can still command a higher
altitude. Radius and center changes require the group's active waypoint to be
type `LOITER`; altitude can be applied without one.

Markers use the player's current non-direct channel when possible and are
created as `_USER_DEFINED` markers, so they are shared in that channel and can
be deleted normally. Looking above the horizon or beyond the terrain/water
intersection produces no camera point and therefore no marker.

Client requests are validated on the server, then flight changes execute on
the UAV-owning machine. Restrictive mission allowlists must permit:

- `fdelta_fnc_terServerApplyLoiterSettings`
- `fdelta_fnc_terServerMoveLoiterCenter`
- `fdelta_fnc_terApplyFlightProfileLocal`
- `fdelta_fnc_terNotify`

Map marking and measurement are local UI features using base-game markers.
Waypoint radius and center changes are server operations. ASL altitude and the
terrain-clearance floor must execute where the UAV is local, so they require
the current UAV owner to load 420th Customizations. A modded remote gunner can
therefore have working controls but fail to change altitude when an unmodded
client owns the aircraft. Ownership migration, HC ownership, JIP, and a
restrictive mission `CfgRemoteExec` should be included in server acceptance
testing.

## Validation Status

The standalone source projects and the integrated branch were tested against
Arma 3 `2.22.154045`. The standalone results provide deeper feature coverage;
the integrated results verify the combined HEMTT package and its multiplayer
boundaries.

- **A3TI:** the standalone resolver passed 24/24 copilot airframe/livery
  combinations, six non-camera-pod exclusions, Blackfoot fallback, and on-foot
  fallback. Pilot combinations remain manual.
- **DAGR/DAGRM:** a live dedicated-server config merge reported `airLock = 1`
  and 700 m/s for the lock, IR, laser, and lead-speed gates.
- **Unitary warheads:** the standalone dedicated tests confirmed every table
  value, guided-terminal redirection, and the cluster, AP, VLS, and Mk45 pins.
- **Blast Propagation:** standalone tests matched configured distance doses,
  cumulative trauma, cover cases, profile boundaries, and terminal/carrier
  inclusion and exclusion assertions.
- **Scalpel-L:** its standalone suite passed 224 assertions, including frozen
  cues, aimpoint-first selection, terminal LOAL, laser identity, cover LOS,
  moving locks, recovery, a fast-jet release matrix, and a real pylon shot.
- **Turret Enhanced:** dedicated smoke tests can cover config, function
  loading, waypoint logic, and script errors, but not client UI, turret optics,
  map channels, keybinds, or remote UAV control.

Current integrated validation is reproducible from `tests/integration` and
`tests/mp-locality`:

- `hemtt check` and `hemtt build` pass 19 addon configs, 48 SQF files, two
  stringtables, and all 19 PBOs.
- The dedicated integration mission passes 274/274 assertions with no SQF
  `ScriptError` events. It covers all 40 registered custom runtime functions,
  private trusted-state helpers, bounded worker/registry behavior, direct ammo
  inheritance pins, BP profiles and RemoteExec entries, Scalpel-L exposure,
  and TER registry pruning and profile reapplication.
- The same 274/274 suite passes with the locally installed CBA_A3, CUP Weapons,
  and RHSUSAF set, including the conditional CUP/RHS compatibility policies.
- The complete graphical-player 2x2 server/client matrix passes. A real
  client-fired Mk 82 at 100 m produces no BP evidence when either endpoint is
  vanilla and approximately `0.18` BP damage when both are modded. The 55 m
  case also demonstrates that native UWR damage follows the projectile owner.
- The modded/modded graphical cell also passes with CBA_A3, CUP Weapons
  `1.19.1`, and RHSUSAF loaded. Its real weapon case applied approximately
  `0.18006` BP damage.
- The complete HC 2x2 matrix passes. A modded HC on a modded server applied
  approximately `0.18003` BP damage at 100 m; the other three combinations
  produced no supplemental dose. The positive cells also pass forged-state,
  displaced-origin, exactly-once reservation, and immediate locality-transfer
  regressions.

The remaining release gates are interactive or depend on the production
modset: verify A3TI camera entry/exit and the retained pink-model and MH-80 DAP
IRCM fixes; test actual DAGR acquisition and third-party ammo descendants;
exercise representative natural bomb, rocket, and artillery flight; retest
Scalpel-L with mixed vehicle/projectile ownership and locality migration; and
exercise TER optics, dialogs, keybinds, marker channels, remote UAV ownership,
JIP, and restrictive mission `CfgRemoteExec` policies.

## Attribution and License

These integrations originated in standalone local projects authored by zobri
and are contributed here under the repository's MIT license. Configuration and
function author credits are retained.

The A3TI compatibility functions also retain their original credits to Lala14,
Pingopete, and thegamecracks. A3TI remains an external dependency; its PBOs,
shaders, textures, and settings are not redistributed. Scalpel-L inherits and
references Arma 3 assets and classes rather than copying stock models or
textures.
