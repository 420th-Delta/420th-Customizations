class CfgPatches {
    class fdelta_ammo {
        name = "420th Customizations - Vanilla Ammunition Tweaks";
        author = "Seathre0420";
        url = "https://github.com/Seathre0420/420th-Customizations";

        requiredVersion = 2.22;
        requiredAddons[] = {
            "A3_Weapons_F_Jets",
            "fdelta_main",
        };
        skipWhenMissingDependencies = 0;

        units[] = {};
    };
};

class CfgAmmo {
    class ammo_Bomb_SmallDiameterBase;
    class ammo_Bomb_SDB : ammo_Bomb_SmallDiameterBase {
        indirectHit = 200; // 85
        indirectHitRange = 5; // 3
    };
};
