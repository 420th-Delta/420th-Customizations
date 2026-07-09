class CfgPatches {
    class fdelta_magwells_ws {
        name = "420th Customizations - Western Sahara Compatibility";
        author = "ol1034, thegamecracks";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.20;
        requiredAddons[] = {
            "cba_jam",
            "Weapons_F_lxWS_Rifles",
        };
        skipWhenMissingDependencies = 1;

        units[] = {};
    };
};
#define MAGAZINES_556x45 \
    "30Rnd_556x45_Stanag", \
    "30Rnd_556x45_Stanag_green", \
    "30Rnd_556x45_Stanag_red", \
    "30Rnd_556x45_Stanag_Tracer_Red", \
    "30Rnd_556x45_Stanag_Tracer_Green", \
    "30Rnd_556x45_Stanag_Tracer_Yellow", \
    "30Rnd_556x45_Stanag_Sand", \
    "30Rnd_556x45_Stanag_Sand_green", \
    "30Rnd_556x45_Stanag_Sand_red", \
    "30Rnd_556x45_Stanag_Sand_Tracer_Red", \
    "30Rnd_556x45_Stanag_Sand_Tracer_Green", \
    "30Rnd_556x45_Stanag_Sand_Tracer_Yellow", \
    "150Rnd_556x45_Drum_Green_Mag_F", \
    "150Rnd_556x45_Drum_Green_Mag_Tracer_F", \
    "150Rnd_556x45_Drum_Sand_Mag_F", \
    "150Rnd_556x45_Drum_Sand_Mag_Tracer_F", \
    "150Rnd_556x45_Drum_Mag_F", \
    "150Rnd_556x45_Drum_Mag_Tracer_F", \
    "75Rnd_556x45_Stanag_lxWS", \
    "75Rnd_556x45_Stanag_green_lxWS", \
    "75Rnd_556x45_Stanag_red_lxWS", \
    "75Rnd_556x45_Stanag_camo_lxWS", \
    "75Rnd_556x45_Stanag_green_camo_lxWS", \
    "75Rnd_556x45_Stanag_red_camo_lxWS",

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
         fdelta_magwells_magazine_1[] = {
            "75Rnd_556x45_Stanag_lxWS",
            "75Rnd_556x45_Stanag_green_lxWS",
            "75Rnd_556x45_Stanag_red_lxWS",
            "75Rnd_556x45_Stanag_camo_lxWS",
            "75Rnd_556x45_Stanag_green_camo_lxWS",
            "75Rnd_556x45_Stanag_red_camo_lxWS",
         };
    };
    class 556x45_Velko {
        fdelta_magwells_magazines[] = {
            MAGAZINES_556x45
        };
    };
    class SLR_762x51 {
        fdelta_magwells_magazines[] = {
            "10Rnd_Mk14_762x51_Mag",
            "20Rnd_762x51_Mag",
        };
    };
};
