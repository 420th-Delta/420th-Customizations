class CfgPatches {
    class fdelta_magwells {
        name = "420th Customizations - Magazine Compatibility";
        author = "ol1034, thegamecracks";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.20;
        requiredAddons[] = {
            "cba_jam",
        };
        skipWhenMissingDependencies = 1;
        skipWhenAnyAddonPresent[] = {"vmagcompatibility"};

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

#define MAGAZINES_GL \
    "1Rnd_HE_Grenade_shell", \
    "1Rnd_Smoke_Grenade_shell", \
    "1Rnd_SmokeRed_Grenade_shell", \
    "1Rnd_SmokeGreen_Grenade_shell", \
    "1Rnd_SmokeYellow_Grenade_shell", \
    "1Rnd_SmokePurple_Grenade_shell", \
    "1Rnd_SmokeBlue_Grenade_shell", \
    "1Rnd_SmokeOrange_Grenade_shell", \
    "UGL_FlareWhite_F", \
    "UGL_FlareGreen_F", \
    "UGL_FlareRed_F", \
    "UGL_FlareYellow_F", \
    "UGL_FlareCIR_F", \
    "UGL_FlareGreen_Illumination_F", \
    "UGL_FlareRed_Illumination_F", \
    "UGL_FlareWhite_Illumination_F", \
    "UGL_FlareYellow_Illumination_F", \

#define MAGAZINES_3GL \
    "3Rnd_HE_Grenade_shell", \
    "3Rnd_Smoke_Grenade_shell", \
    "3Rnd_SmokeRed_Grenade_shell", \
    "3Rnd_SmokeGreen_Grenade_shell", \
    "3Rnd_SmokeYellow_Grenade_shell", \
    "3Rnd_SmokePurple_Grenade_shell", \
    "3Rnd_SmokeBlue_Grenade_shell", \
    "3Rnd_SmokeOrange_Grenade_shell", \
    "3Rnd_UGL_FlareWhite_F", \
    "3Rnd_UGL_FlareGreen_F", \
    "3Rnd_UGL_FlareRed_F", \
    "3Rnd_UGL_FlareYellow_F", \
    "3Rnd_UGL_FlareCIR_F",

class CfgMagazineWells {
    class STANAG_556x45 {
        fdelta_magwells_magazines_1[] = {
            "150Rnd_556x45_Drum_Green_Mag_F", 
            "150Rnd_556x45_Drum_Green_Mag_Tracer_F", 
            "150Rnd_556x45_Drum_Sand_Mag_F", 
            "150Rnd_556x45_Drum_Sand_Mag_Tracer_F", 
            "150Rnd_556x45_Drum_Mag_F", 
            "150Rnd_556x45_Drum_Mag_Tracer_F",
        };
    };
    class CBA_556x45_STANAG {
        fdelta_magwells_magazines[] = {
            MAGAZINES_556x45
        };
    };
    class CBA_556x45_G36 {
        fdelta_magwells_magazines[] = {
            MAGAZINES_556x45
        };
    };
    class CBA_556x45_SG550 {
        fdelta_magwells_magazines[] = {
            MAGAZINES_556x45
        };
    };
    class CBA_556x45_STEYR {
        fdelta_magwells_magazines[] = {
            MAGAZINES_556x45
        };
    };
    class CBA_556x45_HK33 {
        fdelta_magwells_magazines[] = {
            MAGAZINES_556x45
        };
    };
    class CBA_556x45_AK {
        fdelta_magwells_magazines[] = {
            MAGAZINES_556x45
        };
    };
    class CBA_556x45_FAMAS {
        fdelta_magwells_magazines[] = {
            MAGAZINES_556x45
        };
    };
    class CBA_556x45_GALIL {
        fdelta_magwells_magazines[] = {
            MAGAZINES_556x45
        };
    };
    class CBA_556x45_M21 {
        fdelta_magwells_magazines[] = {
            MAGAZINES_556x45
        };
    };
    class CBA_68SPC_STANAG {
        fdelta_magwells_magazines[] = {
            MAGAZINES_556x45
        };
    };
    class CBA_762x39_AK {
        BI_akmags[] = {
            "30Rnd_762x39_AK12_Mag_F",
            "30Rnd_762x39_AK12_Mag_Tracer_F",
            "30rnd_762x39_AK12_Arid_Mag_F",
            "30rnd_762x39_AK12_Arid_Mag_Tracer_F",
            "30rnd_762x39_AK12_Lush_Mag_F",
            "30rnd_762x39_AK12_Lush_Mag_Tracer_F",
            "75Rnd_762x39_Mag_F",
            "75Rnd_762x39_Mag_Tracer_F",
            "75rnd_762x39_AK12_Mag_F",
            "75rnd_762x39_AK12_Mag_Tracer_F",
            "75rnd_762x39_AK12_Lush_Mag_F",
            "75rnd_762x39_AK12_Lush_Mag_Tracer_F",
            "75rnd_762x39_AK12_Arid_Mag_F",
            "75rnd_762x39_AK12_Arid_Mag_Tracer_F",
        };
    };
    class CBA_762x39_VZ58 {
        fdelta_magwells_magazines[] = {
            "30Rnd_762x39_Mag_F",
            "30Rnd_762x39_Mag_Green_F",
            "30Rnd_762x39_Mag_Tracer_F",
            "30Rnd_762x39_Mag_Tracer_Green_F",
            "30Rnd_762x39_AK12_Mag_F",
            "30Rnd_762x39_AK12_Mag_Tracer_F",
            "30rnd_762x39_AK12_Arid_Mag_F",
            "30rnd_762x39_AK12_Arid_Mag_Tracer_F",
            "30rnd_762x39_AK12_Lush_Mag_F",
            "30rnd_762x39_AK12_Lush_Mag_Tracer_F",
            "75Rnd_762x39_Mag_F",
            "75Rnd_762x39_Mag_Tracer_F",
            "75rnd_762x39_AK12_Mag_F",
            "75rnd_762x39_AK12_Mag_Tracer_F",
            "75rnd_762x39_AK12_Lush_Mag_F",
            "75rnd_762x39_AK12_Lush_Mag_Tracer_F",
            "75rnd_762x39_AK12_Arid_Mag_F",
            "75rnd_762x39_AK12_Arid_Mag_Tracer_F",
        };
    };
    class CBA_762x51_5rnds {
        fdelta_magwells_magazines[] = {
            "7Rnd_408_Mag",
        };
    };
    class CBA_762x51_LINKS {
        BI_links[] = {
            "150Rnd_762x54_Box",
            "150Rnd_762x54_Box_Tracer",
        };
    };
    class CBA_762x54R_Vz59_LINKS {
        BI_links[] = {
            "150Rnd_762x54_Box",
            "150Rnd_762x54_Box_Tracer",
        };
    };
    class CBA_792x57_LINKS {
        BI_links[] = {
            "150Rnd_762x54_Box",
            "150Rnd_762x54_Box_Tracer",
        };
    };
    class CBA_762x51_MkI_EMR {
        fdelta_magwells_magazines[] = {
            "10Rnd_Mk14_762x51_Mag",
        };
    };
    class CBA_762x51_SIGAMT {
        fdelta_magwells_magazines[] = {
            "10Rnd_Mk14_762x51_Mag",
            "20Rnd_762x51_Mag",
        };
    };
    class CBA_762x51_SCAR {
        fdelta_magwells_magazines[] = {
            "10Rnd_Mk14_762x51_Mag",
            "20Rnd_762x51_Mag",
        };
    };
    class CBA_762x51_SCAR_EGLM {
        fdelta_magwells_magazines[] = {
            "10Rnd_Mk14_762x51_Mag",
            "20Rnd_762x51_Mag",
        };
    };
    class CBA_762x51_G3 {
        fdelta_magwells_magazines[] = {
            "10Rnd_Mk14_762x51_Mag",
            "20Rnd_762x51_Mag",
        };
    };
    class CBA_762x51_FAL {
        fdelta_magwells_magazines[] = {
            "10Rnd_Mk14_762x51_Mag",
            "20Rnd_762x51_Mag",
        };
    };
    class CBA_762x51_HK417 {
        fdelta_magwells_magazines[] = {
            "10Rnd_Mk14_762x51_Mag",
            "20Rnd_762x51_Mag",
        };
    };
    class CBA_762x51_AR10 {
        fdelta_magwells_magazines[] = {
            "10Rnd_Mk14_762x51_Mag",
            "20Rnd_762x51_Mag",
        };
    };
    class CBA_3006_Spring {
        fdelta_magwells_magazines[] = {
            "10Rnd_Mk14_762x51_Mag",
            "20Rnd_762x51_Mag",
        };
    };
    class CBA_75x55_STGW57 {
        fdelta_magwells_magazines[] = {
            "10Rnd_Mk14_762x51_Mag",
            "20Rnd_762x51_Mag",
        };
    };
    class CBA_300WM_AI {
        fdelta_magwells_magazines[] = {
            "10Rnd_338_Mag",
            "7Rnd_408_Mag",
        };
    };
    class CBA_300WM_AICS {
        fdelta_magwells_magazines[] = {
            "10Rnd_338_Mag",
            "7Rnd_408_Mag",
        };
    };
    class CBA_9x19_Vityaz {
        fdelta_magwells_magazines[] = {
            "30Rnd_9x21_Mag_SMG_02",
            "30Rnd_9x21_Mag_SMG_02_Tracer_Red",
            "30Rnd_9x21_Mag_SMG_02_Tracer_Yellow",
            "30Rnd_9x21_Mag_SMG_02_Tracer_Green",
            "30Rnd_9x21_Mag",
            "30Rnd_9x21_Red_Mag",
            "30Rnd_9x21_Yellow_Mag",
            "30Rnd_9x21_Green_Mag",
        };
    };
    class CBA_9x18_PM63 {
        fdelta_magwells_magazines[] = {
            "30Rnd_9x21_Mag_SMG_02",
            "30Rnd_9x21_Mag_SMG_02_Tracer_Red",
            "30Rnd_9x21_Mag_SMG_02_Tracer_Yellow",
            "30Rnd_9x21_Mag_SMG_02_Tracer_Green",
            "30Rnd_9x21_Mag",
            "30Rnd_9x21_Red_Mag",
            "30Rnd_9x21_Yellow_Mag",
            "30Rnd_9x21_Green_Mag",
        };
    };
    class CBA_9x19_UZI {
        fdelta_magwells_magazines[] = {
            "30Rnd_9x21_Mag_SMG_02",
            "30Rnd_9x21_Mag_SMG_02_Tracer_Red",
            "30Rnd_9x21_Mag_SMG_02_Tracer_Yellow",
            "30Rnd_9x21_Mag_SMG_02_Tracer_Green",
            "30Rnd_9x21_Mag",
            "30Rnd_9x21_Red_Mag",
            "30Rnd_9x21_Yellow_Mag",
            "30Rnd_9x21_Green_Mag",
        };
    };
    class CBA_45ACP_Grease {
        fdelta_magwells_magazines[] = {
            "30Rnd_45ACP_Mag_SMG_01",
            "30Rnd_45ACP_Mag_SMG_01_tracer_green",
            "30Rnd_45ACP_Mag_SMG_01_Tracer_Red",
            "30Rnd_45ACP_Mag_SMG_01_Tracer_Yellow",
        };
    };
    class CBA_45ACP_Thompson_Stick {
        fdelta_magwells_magazines[] = {
            "30Rnd_45ACP_Mag_SMG_01",
            "30Rnd_45ACP_Mag_SMG_01_tracer_green",
            "30Rnd_45ACP_Mag_SMG_01_Tracer_Red",
            "30Rnd_45ACP_Mag_SMG_01_Tracer_Yellow",
        };
    };
    class CBA_46x30_MP7 {
        fdelta_magwells_magazines[] = {
            "30Rnd_45ACP_Mag_SMG_01",
            "30Rnd_45ACP_Mag_SMG_01_tracer_green",
            "30Rnd_45ACP_Mag_SMG_01_Tracer_Red",
            "30Rnd_45ACP_Mag_SMG_01_Tracer_Yellow",
            "30Rnd_9x21_Mag_SMG_02",
            "30Rnd_9x21_Mag_SMG_02_Tracer_Red",
            "30Rnd_9x21_Mag_SMG_02_Tracer_Yellow",
            "30Rnd_9x21_Mag_SMG_02_Tracer_Green",
            "30Rnd_9x21_Mag",
            "30Rnd_9x21_Red_Mag",
            "30Rnd_9x21_Yellow_Mag",
            "30Rnd_9x21_Green_Mag",
        };
    };
    class CBA_9x39_VSS {
        fdelta_magwells_magazines[] = {
            "10Rnd_50BW_Mag_F",
            "10Rnd_127x54_Mag",
        };
    };
    class CBA_50BMG_M107 {
        fdelta_magwells_magazines[] = {
            "5Rnd_127x108_Mag",
            "5Rnd_127x108_APDS_Mag",
        };
    };
    class CBA_50BMG_AS50 {
        fdelta_magwells_magazines[] = {
            "5Rnd_127x108_Mag",
            "5Rnd_127x108_APDS_Mag",
        };
    };
    class CBA_127x108_KSVK {
        fdelta_magwells_magazines[] = {
            "5Rnd_127x108_Mag",
            "5Rnd_127x108_APDS_Mag",
        };
    };
    class UGL_40x36 {
        fdelta_magwells_magazines[] = {
            MAGAZINES_3GL
        };
    };
    class CBA_40mm_GP {
        fdelta_magwells_magazines[] = {
            MAGAZINES_GL
            MAGAZINES_3GL
        };
    };
    class CBA_40mm_M203_6rnds {
        fdelta_magwells_magazines[] = {
            MAGAZINES_GL
            MAGAZINES_3GL
        };
    };
};
