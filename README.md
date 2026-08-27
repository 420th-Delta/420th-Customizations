# 420th Customizations

An Arma 3 mod for the 420th Delta community.

<p align="center">
    <a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3647324436">
        <img src="logo.jpg">
    </a>
</p>

## Features

- Increase capacity of various clothing (see [Capacity Changes](#capacity-changes))
- Rebalance native indirect damage for selected vanilla unitary HE bombs,
  rockets, SPG, MLRS/MRL, and VLS ammunition—including the SDB—and add
  cover-aware cumulative blast trauma for exposed infantry
- Allow DAGR/DAGRM rockets to acquire aircraft travelling at up to 700 m/s
  without removing ground targeting
- Add Scalpel-L, a separate pylon ATGM with immutable launch cues, a scripted
  vertical top-attack profile, terminal LOAL acquisition, and lock-loss recovery
- Add UAV camera tools for ASL loiter altitude, minimum terrain clearance,
  orbit radius, loiter-center retasking, map marking, and range/bearing measurement
- Allow loading vanilla magazines into modded weapons (CUP, JCA, NIArms, RHS, SOG, GM)
- Allow loading modded pylons onto vanilla aircraft (CUP, RHS)
- Allow attaching RHS grips on NIArms weaponry
- Allow aimed usage of NVGs with modded optics (RHSUSAF)
- Fix [A3TI] incompatibility with thermal-capable MH-80 Camera Pods
- Fix A3TI causing units/vehicles to appear pink when changing cameras
- Fix MH-80 DAP ECM Pods (DIRCM variants) not detecting some IR missiles

See [Gameplay and compatibility details](docs/gameplay-and-compatibility.md)
for exact scope, multiplayer requirements, known limits, and validation status.

Do not load the standalone **ZBR Gameplay Enhancements**, Turret Enhanced, or
Turret Enhanced Plus mods alongside a 420th release containing these features.
They duplicate runtime handlers and can apply blast trauma twice or issue
competing UAV commands. Remove the standalone bundle when migrating.

[A3TI]: https://steamcommunity.com/workshop/filedetails/?id=2041057379

## Capacity Changes

| Item                    | Original | New | Ratio  |
| ----------------------- | --------:| ---:| ------:|
| Aid Worker Clothes      |       30 | 120 |     4x |
| Assault Pack            |      160 | 320 |     2x |
| Casual Clothes (AoW)    |       20 |  80 |     4x |
| Combat Fatigues (LDF)   |       40 | 120 |     3x |
| CBRN Suit               |       30 | 120 |     4x |
| CTRG Stealth Uniform    |       40 | 120 |     3x |
| Everyday Backpack       |      240 | 320 |  1.33x |
| Farmer Outfit           |       20 |  80 |     4x |
| Field Pack              |      200 | 320 |   1.6x |
| Formal Suit             |       20 |  80 |     4x |
| Kitbag                  |      280 | 320 |  1.14x |
| Leg Strap Bag (Back)    |       80 | 320 |     4x |
| Leg Strap Bag (Vest)    |       80 | 300 |  3.75x |
| Messenger Bag           |      140 | 320 |  2.29x |
| Modular Carrier         |      130 | 300 |   2.3x |
| Paramedic Outfit        |       30 | 500 | 16.67x |
| Sports Backpack         |      240 | 320 |  1.33x |
| Tracksuit               |       40 | 160 |     4x |

### CUP Weapons

| Item                    | Original | New | Ratio  |
| ----------------------- | --------:| ---:| ------:|
| First Aid Backpack      |      280 | 320 |  1.14x |

### Reaction Forces

| Item                    | Original | New | Ratio  |
| ----------------------- | --------:| ---:| ------:|
| Duffel Bag              |      320 | 480 |   1.5x |

## Installation

To build the mod from source, install [HEMTT] and run the following command:

```sh
hemtt check
hemtt build
```

The reproducible validation missions are documented in
[`tests/integration`](tests/integration) and
[`tests/mp-locality`](tests/mp-locality). They cover combined-package config and
runtime checks plus vanilla/modded server and client locality combinations.

Official releases must be signed by the maintainer or CI holding the private
key that matches `.hemtt/project.toml`. Contributors can remove the `[signing]`
configuration to generate an ephemeral key for private test builds, but those
signatures are not compatible with the official Workshop signing authority and
must not be published as an official update.

[HEMTT]: https://github.com/brettmayson/HEMTT

## License

This project is written under the [MIT] license.

[MIT]: /LICENSE
