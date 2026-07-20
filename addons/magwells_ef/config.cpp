#include "\z\fdelta\addons\magwells\magazines.hpp"

class CfgPatches {
    class fdelta_magwells_ef {
        name = "420th Customizations - Expeditionary Forces Compatibility";
        author = "ol1034, thegamecracks";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.20;
        requiredAddons[] = {
            "cba_jam",
            "EF_Weapons",
            "fdelta_magwells",
            "fdelta_main",
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
    class EF_Diplomat_9x19 {
        fdelta_magwells_ef_magazines[] = {
            "16Rnd_9x21_Mag",
            "16Rnd_9x21_red_Mag",
            "16Rnd_9x21_green_Mag",
            "16Rnd_9x21_yellow_Mag",
            "30Rnd_9x21_Mag",
            "30Rnd_9x21_Red_Mag",
            "30Rnd_9x21_Yellow_Mag",
            "30Rnd_9x21_Green_Mag",
            "30Rnd_9x21_Mag_SMG_02",
            "30Rnd_9x21_Mag_SMG_02_Tracer_Red",
            "30Rnd_9x21_Mag_SMG_02_Tracer_Yellow",
            "30Rnd_9x21_Mag_SMG_02_Tracer_Green",
        };
    };
};
class CfgWeapons {
    class InventoryOpticsItem_Base_F;
    class ItemCore;
    class ef_optic_mbs : ItemCore {
        class ItemInfo : InventoryOpticsItem_Base_F {
            class OpticsModes {
                class MBSScope {
                    visionMode[] = {};
                };
            };
        };
    };
};
