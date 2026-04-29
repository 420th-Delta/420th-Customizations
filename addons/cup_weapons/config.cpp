class CfgPatches {
    class fdelta_cup_weapons {
        name = "420th Customizations - CUP Weapons";
        author = "thegamecracks";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.20;
        requiredAddons[] = {
            "CUP_Weapons_Backpacks",
        };
        skipWhenMissingDependencies = 1;

        units[] = {};
    };
};

class CfgVehicles {
    class B_Kitbag_Base;
    class CUP_C_PHOENIX_FIRSTAID : B_Kitbag_Base {
        maximumLoad = 320; // 280
    };
};
