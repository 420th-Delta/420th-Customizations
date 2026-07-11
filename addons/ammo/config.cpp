class CfgPatches {
    class fdelta_ammo {
        name = "420th Customizations - Ammunition";
        author = "Seathre0420";
        url = "https://github.com/Seathre0420/420th-Customizations";

        requiredVersion = 2.20;
        requiredAddons[] = {
            "A3_Weapons_F_Jets",
        };
        skipWhenMissingDependencies = 1;

        units[] = {};
        weapons[] = {};
    };
};

class CfgAmmo {
    class ammo_Bomb_SDB {
        indirectHit = 200;
        indirectHitRange = 5;
    };
};
