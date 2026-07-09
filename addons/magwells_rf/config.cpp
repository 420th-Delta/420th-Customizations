class CfgPatches {
    class fdelta_magwells_rf {
        name = "420th Customizations - Reaction Forces Compatibility";
        author = "ol1034, thegamecracks";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.20;
        requiredAddons[] = {
            "cba_jam",
            "RF_Weapons_Rifles_ASH12",
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
    "150Rnd_556x45_Drum_Mag_Tracer_F",

// class ItemCore;
// class Mode_SemiAuto;
// class Mode_Burst;
// class Mode_FullAuto;
// class SlotInfo;
// class CowsSlot;
// class MuzzleSlot;
// class PointerSlot;
class CfgMagazineWells {
    class ASH12_127x55_RF {
        fdelta_magwells_magazines[] = {
            "10Rnd_50BW_Mag_F",
            "10Rnd_127x54_Mag",
        };
    };
    class Pistol_9x19_RF {
        fdelta_magwells_magazines[] = {
            "16Rnd_9x21_Mag",
            "16Rnd_9x21_red_Mag",
            "16Rnd_9x21_green_Mag",
            "16Rnd_9x21_yellow_Mag",
            "30Rnd_9x21_Mag",
            "30Rnd_9x21_Red_Mag",
            "30Rnd_9x21_Yellow_Mag",
            "30Rnd_9x21_Green_Mag",
        };
    };
    class Pistol_DEagle_RF {
        fdelta_magwells_magazines[] = {
            "11Rnd_45ACP_Mag",
        };
    };
};
