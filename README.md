# 420th Customizations

An Arma 3 mod for the 420th Delta community.

This mod can work fully client-side. It's signed for multiplayer with a single bikey,
and the mod version does not need to match between server and clients
unless loaded as a required mod with [verifySignatures = 2](https://community.bistudio.com/wiki/ArmA:_Armed_Assault:_Addon_Signatures).

<p align="center">
    <a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3647324436">
        <img src="logo.jpg">
    </a>
</p>

## Features

- Increase capacity of various clothing (see [Capacity Changes](#capacity-changes))
- Allow loading vanilla magazines into modded weapons (CUP, JCA, NIArms, RHS, SOG, GM)
- Allow loading modded pylons onto vanilla aircraft (CUP, RHS)
- Allow attaching RHS grips on NIArms weaponry
- Allow aimed usage of NVGs with vanilla optics and modded optics (RHSUSAF)
- Allow DAGR missiles to lock and fire on slow-moving aircraft
- Add 4x zoom levels and 1km zeroing for ARCO, ERCO, MRCO, and RCO optics
- Improve effectiveness of some vanilla HE munitions against infantry
- Fix [A3TI] incompatibility with thermal-capable MH-80 Camera Pods
- Fix A3TI causing units/vehicles to appear pink when changing cameras
- Fix MH-80 DAP ECM Pods (DIRCM variants) not detecting some IR missiles

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
hemtt build
```

You can also build the mod for release with `hemtt release`, but you will need
to remove the `[signing]` configuration in project.toml to generate an ephemeral
signing key.

[HEMTT]: https://github.com/brettmayson/HEMTT

## License

This project is written under the [MIT] license.

[MIT]: /LICENSE

## Sponsor Us!

[![420th ko-fi](https://img.shields.io/badge/Ko--fi-420th-grey?style=for-the-badge&logo=kofi&logoColor=%23FF6433&labelColor=white)](https://ko-fi.com/420th)
[![thegamecracks ko-fi](https://img.shields.io/badge/Ko--fi-thegamecracks-grey?style=for-the-badge&logo=kofi&logoColor=%23FF6433&labelColor=white)](https://ko-fi.com/thegamecracks)
