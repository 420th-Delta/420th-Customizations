#include "\z\fdelta\addons\magwells\magazines.hpp"

class CfgPatches {
    class fdelta_magwells_jca {
        name = "420th Customizations - Expeditionary Forces Compatibility";
        author = "ol1034, thegamecracks";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.20;
        requiredAddons[] = {
            "cba_jam",
            "fdelta_magwells",
            "fdelta_main",
            "Sounds_F_JCA_IA",
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
    class JCA_SR_762x51 {
        fdelta_magwells_jca_magazines[] = {
            MAGAZINES_762x51
        };
    };
    class JCA_HK437_300BLK {
        fdelta_magwells_jca_magazines[] = {
            MAGAZINES_556x45
        };
    };
    class JCA_SCAR_762x51 {
        fdelta_magwells_jca_magazines[] = {
            MAGAZINES_762x51
        };
    };
    class JCA_MP5_9x19 {
        fdelta_magwells_jca_magazines[] = {
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
    class JCA_UMP_45ACP {
        fdelta_magwells_jca_magazines[] = {
            "30Rnd_45ACP_Mag_SMG_01",
            "30Rnd_45ACP_Mag_SMG_01_tracer_green",
            "30Rnd_45ACP_Mag_SMG_01_Tracer_Red",
            "30Rnd_45ACP_Mag_SMG_01_Tracer_Yellow",
        };
    };
    class JCA_AWM_338LM {
        fdelta_magwells_jca_magazines[] = {
            "10Rnd_338_Mag",
        };
    };
    class JCA_M107_127x99 {
        fdelta_magwells_jca_magazines[] = {
            "5Rnd_127x108_Mag",
            "5Rnd_127x108_APDS_Mag",
        };
    };
    class JCA_G17_9x19 {
        fdelta_magwells_jca_magazines[] = {
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
    class JCA_M9A1_9x19 {
        fdelta_magwells_jca_magazines[] = {
            "16Rnd_9x21_Mag",
            "16Rnd_9x21_red_Mag",
            "16Rnd_9x21_green_Mag",
            "16Rnd_9x21_yellow_Mag",
        };
    };
    class JCA_P226_9x19 {
        fdelta_magwells_jca_magazines[] = {
            "16Rnd_9x21_Mag",
            "16Rnd_9x21_red_Mag",
            "16Rnd_9x21_green_Mag",
            "16Rnd_9x21_yellow_Mag",
        };
    };
    class JCA_P320_9x19 {
        fdelta_magwells_jca_magazines[] = {
            "16Rnd_9x21_Mag",
            "16Rnd_9x21_red_Mag",
            "16Rnd_9x21_green_Mag",
            "16Rnd_9x21_yellow_Mag",
        };
    };
    class JCA_Mk23_45ACP {
        fdelta_magwells_jca_magazines[] = {
            "11Rnd_45ACP_Mag",
        };
    };
    class JCA_MK153 {
        fdelta_magwells_jca_magazines[] = {
            "RPG32_F",
            "RPG32_HE_F",
        };
    };
};
