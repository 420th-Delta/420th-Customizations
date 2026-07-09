class CfgPatches {
    class fdelta_magwells_vn {
        name = "420th Customizations - SOG Weapons Compatibility";
        author = "ol1034, thegamecracks";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.20;
        requiredAddons[] = {
            "cba_jam",
            "weapons_f_vietnam_c",
            "weapons_f_vietnam_03_c",
            "weapons_f_vietnam_04_c",
        };
        skipWhenMissingDependencies = 1;

        units[] = {};
    };
};

#define MAGAZINES_40mm \
    "vn_40mm_m381_he_mag", \
    "vn_40mm_m406_he_mag", \
    "vn_40mm_m397_ab_mag", \
    "vn_40mm_m433_hedp_mag", \
    "vn_40mm_m583_flare_w_mag", \
    "vn_40mm_m661_flare_g_mag", \
    "vn_40mm_m662_flare_r_mag", \
    "vn_40mm_m695_flare_y_mag", \
    "vn_40mm_m680_smoke_w_mag", \
    "vn_40mm_m682_smoke_r_mag", \
    "vn_40mm_m715_smoke_g_mag", \
    "vn_40mm_m716_smoke_y_mag", \
    "vn_40mm_m717_smoke_p_mag", \
    "vn_40mm_m651_cs_mag", \
    "vn_40mm_m576_buck_mag",

// class ItemCore;
// class Mode_SemiAuto;
// class Mode_Burst;
// class Mode_FullAuto;
// class SlotInfo;
// class CowsSlot;
// class MuzzleSlot;
// class PointerSlot;
class CfgMagazineWells {
    class CBA_762x25_PPSh_Stick {
        fdelta_magwells_vn_magazines[] = {
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
    class CBA_9x19_MP40 {
        fdelta_magwells_vn_magazines[] = {
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
    class CBA_762x54R_Mosin {
        fdelta_magwells_vn_magazines[] = {
            "10Rnd_762x54_Mag",
        };
    };
    class CBA_3006_Garand {
        fdelta_magwells_vn_magazines[] = {
            "10Rnd_762x54_Mag",
        };
    };
    class CBA_792x57_K98 {
        fdelta_magwells_vn_magazines[] = {
            "10Rnd_762x54_Mag",
        };
    };
    class CBA_762x39_SKS {
        fdelta_magwells_vn_magazines[] = {
            "10Rnd_762x54_Mag",
        };
    };
    class CBA_30Carbine_M1Carbine {
        fdelta_magwells_vn_magazines[] = {
            "20Rnd_650x39_Cased_Mag_F",
        };
    };
    class UGL_40x36 {
        fdelta_magwells_vn_magazines[] = {
            MAGAZINES_40mm
        };
    };
    class CBA_40mm_M203 {
        fdelta_magwells_vn_magazines[] = {
            MAGAZINES_40mm
        };
    };
};
class CfgWeapons {
    class Rifle;
    // class UGL_F;
    class Rifle_Base_F : Rifle {
        // class WeaponSlotsInfo;
        // class GunParticles;
        // class Eventhandlers;
    };
    class vn_rifle : Rifle_Base_F {
        class vn_ugl;
        class vn_m203_muzzle : vn_ugl {
            magazineWell[] = {
                "CBA_40mm_M203",
            };
        };
        class vn_m79_muzzle : vn_ugl {
            magazineWell[] = {
                "CBA_40mm_M203",
            };
        };
    };
    class vn_smg : vn_rifle {
            magazineWell[] = {
                "CBA_9x19_ScorpionEvo3",
            };
    };
    class vn_pps52 : vn_smg {
    };
    class vn_mc10 : vn_pps52 {
            magazineWell[] = {
                "CBA_9x19_ScorpionEvo3",
            };
    };
    class vn_m63a : vn_rifle {
        magazines[] = {
            "vn_m63a_30_mag",
            "vn_m63a_30_t_mag",
            "30Rnd_556x45_Stanag",
            "30Rnd_556x45_Stanag_green",
            "30Rnd_556x45_Stanag_red",
            "30Rnd_556x45_Stanag_Tracer_Red",
            "30Rnd_556x45_Stanag_Tracer_Green",
            "30Rnd_556x45_Stanag_Tracer_Yellow",
            "30Rnd_556x45_Stanag_Sand",
            "30Rnd_556x45_Stanag_Sand_green",
            "30Rnd_556x45_Stanag_Sand_red",
            "30Rnd_556x45_Stanag_Sand_Tracer_Red",
            "30Rnd_556x45_Stanag_Sand_Tracer_Green",
            "30Rnd_556x45_Stanag_Sand_Tracer_Yellow",
            "150Rnd_556x45_Drum_Green_Mag_F",
            "150Rnd_556x45_Drum_Green_Mag_Tracer_F",
            "150Rnd_556x45_Drum_Sand_Mag_F",
            "150Rnd_556x45_Drum_Sand_Mag_Tracer_F",
            "150Rnd_556x45_Drum_Mag_F",
            "150Rnd_556x45_Drum_Mag_Tracer_F",
        };
    };
    class vn_m63a_lmg : vn_rifle {
        magazines[] = {
            "vn_m63a_100_mag",
            "vn_m63a_100_t_mag",
            "200Rnd_556x45_Box_F",
            "200Rnd_556x45_Box_Red_F",
            "200Rnd_556x45_Box_Tracer_F",
            "200Rnd_556x45_Box_Tracer_Red_F",
        };
    };
    class vn_m63a_cdo : vn_m63a_lmg {
        magazines[] = {
            "vn_m63a_150_mag",
            "vn_m63a_150_t_mag",
            "200Rnd_556x45_Box_F",
            "200Rnd_556x45_Box_Red_F",
            "200Rnd_556x45_Box_Tracer_F",
            "200Rnd_556x45_Box_Tracer_Red_F",
        };
    };
    class vn_rifle762 : vn_rifle {
        magazineWell[] = {
            "CBA_762x54R_SVD",
        };
    };
    class vn_l1a1_01 : vn_rifle762 {
        magazineWell[] = {
            "CBA_762x51_FAL",
        };
    };
    class vn_svd : vn_rifle762 {
        magazineWell[] = {
            "CBA_762x54R_SVD",
        };
    };
    class vn_lmg : vn_rifle {
    };
    class vn_l4 : vn_lmg {
        magazineWell[] = {
            "CBA_762x51_FAL",
        };
    };
    class vn_m1918 : vn_lmg {
        magazineWell[] = {
            "CBA_762x51_MkI_EMR",
        };
    };
    class vn_rpd : vn_lmg {
        magazineWell[] = {
            "CBA_762x54R_LINKS",
            "CBA_762x51_LINKS",

        };
    };
    class vn_mg42 : vn_lmg {
        magazineWell[] = {
            "CBA_762x54R_LINKS",
            "CBA_762x51_LINKS",
        };
    };
};
