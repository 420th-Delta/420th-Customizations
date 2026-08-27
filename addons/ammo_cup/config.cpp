class CfgPatches {
    class fdelta_ammo_cup {
        name = "420th Customizations - CUP Ammo Compatibility";
        author = "zobri";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.22;
        requiredAddons[] = {
            "fdelta_ammo",
            "CUP_Weapons_Ammunition",
        };
        skipWhenMissingDependencies = 1;

        units[] = {};
        weapons[] = {};
    };
};

class CfgAmmo {
    class Sh_155mm_AMOS_LG;

    // CUP derives these smaller laser-guided shells from the vanilla 155 mm
    // carrier. Keep CUP's own terminal selection instead of inheriting the
    // fdelta 155 mm HE terminal redirect through that base class.
    class CUP_Sh_122_LASER : Sh_155mm_AMOS_LG {
        submunitionAmmo = "M_Mo_155mm_AT_LG";
    };
    class CUP_Sh_105_LASER : Sh_155mm_AMOS_LG {
        submunitionAmmo = "M_Mo_155mm_AT_LG";
    };
};
