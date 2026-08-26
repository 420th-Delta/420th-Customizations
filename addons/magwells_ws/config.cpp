#include "\z\fdelta\addons\magwells\magazines.hpp"

class CfgPatches {
    class fdelta_magwells_ws {
        name = "420th Customizations - Western Sahara Compatibility";
        author = "ol1034, thegamecracks";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.22;
        requiredAddons[] = {
            "cba_jam",
            "fdelta_magwells",
            "fdelta_main",
            "Weapons_F_lxWS_Rifles",
        };
        skipWhenMissingDependencies = 1;

        units[] = {};
    };
};

// class ItemCore;
// class Mode_SemiAuto;
// class Mode_Burst;
// class Mode_FullAuto;
// class SlotInfo;
// class CowsSlot;
// class MuzzleSlot;
// class PointerSlot;
class CfgMagazineWells {
    //add this since JCA guns cannot use these magazines
    class STANAG_556x45
    {
         fdelta_magwells_ws_magazines[] = {
            "75Rnd_556x45_Stanag_lxWS",
            "75Rnd_556x45_Stanag_green_lxWS",
            "75Rnd_556x45_Stanag_red_lxWS",
            "75Rnd_556x45_Stanag_camo_lxWS",
            "75Rnd_556x45_Stanag_green_camo_lxWS",
            "75Rnd_556x45_Stanag_red_camo_lxWS",
         };
    };
    class 556x45_Velko {
        fdelta_magwells_ws_magazines[] = {
            MAGAZINES_556x45
            "75Rnd_556x45_Stanag_lxWS",
            "75Rnd_556x45_Stanag_green_lxWS",
            "75Rnd_556x45_Stanag_red_lxWS",
            "75Rnd_556x45_Stanag_camo_lxWS",
            "75Rnd_556x45_Stanag_green_camo_lxWS",
            "75Rnd_556x45_Stanag_red_camo_lxWS",
        };
    };
    class SLR_762x51 {
        fdelta_magwells_ws_magazines[] = {
            MAGAZINES_762x51
        };
    };
};
