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
    class JCA_P320_9x19 {
        fdelta_magwells_jca_magazines[] = {
            "16Rnd_9x21_Mag",
            "16Rnd_9x21_red_Mag",
            "16Rnd_9x21_green_Mag",
            "16Rnd_9x21_yellow_Mag",
        };
    };
};
class CfgWeapons {
    class Pistol_Base_F;
    class Launcher_Base_F;
    class Rifle_Base_F;
    class Rifle_Short_Base_F: Rifle_Base_F {};
    class Rifle_Long_Base_F: Rifle_Base_F {};
    class JCA_smg_MP5_base_F: Rifle_Short_Base_F {
        magazineWell[] += {"CBA_9x19_MP5"};
    };
    class JCA_smg_UMP_base_F: Rifle_Short_Base_F {
        magazineWell[] += {"CBA_45ACP_UMP"};
    };    
    class JCA_arifle_HK433_base_F: Rifle_Base_F {
        magazineWell[] += {"CBA_556x45_STANAG","CBA_556x45_STANAG_L","CBA_556x45_STANAG_XL","CBA_556x45_STANAG_2D","CBA_556x45_STANAG_2D_XL"};
    };
    class JCA_arifle_HK437_base_F: Rifle_Base_F {
        magazineWell[] += {"CBA_300BLK_STANAG"};
    };    
    class JCA_arifle_M16A4_base_F: Rifle_Base_F {
        magazineWell[] += {"CBA_556x45_STANAG","CBA_556x45_STANAG_L","CBA_556x45_STANAG_XL","CBA_556x45_STANAG_2D","CBA_556x45_STANAG_2D_XL"};
    };    
    class JCA_arifle_M4A1_base_F: Rifle_Base_F {
        magazineWell[] += {"CBA_556x45_STANAG","CBA_556x45_STANAG_L","CBA_556x45_STANAG_XL","CBA_556x45_STANAG_2D","CBA_556x45_STANAG_2D_XL"};
    };
    class JCA_arifle_M4A4_base_F: Rifle_Base_F {
        magazineWell[] += {"CBA_556x45_STANAG","CBA_556x45_STANAG_L","CBA_556x45_STANAG_XL","CBA_556x45_STANAG_2D","CBA_556x45_STANAG_2D_XL"};
    };
    class JCA_arifle_SCAR_L_base_F: Rifle_Base_F {
        magazineWell[] += {"CBA_556x45_STANAG","CBA_556x45_STANAG_L","CBA_556x45_STANAG_XL","CBA_556x45_STANAG_2D","CBA_556x45_STANAG_2D_XL"};
    };
    class JCA_arifle_SCAR_H_base_F: Rifle_Base_F {
        magazineWell[] += {"CBA_762x51_SCAR"}; 
    };
    class JCA_arifle_SR10_base_F: Rifle_Base_F {
        magazineWell[] += {"CBA_762x51_AR10"}; 
    };    
    class JCA_arifle_SR25_base_F: Rifle_Base_F {
        magazineWell[] += {"CBA_762x51_AR10"}; 
    };        
    class JCA_srifle_AWM_base_F: Rifle_Long_Base_F {
        magazineWell[] += {"CBA_338LM_AI"}; 
    };    
    class JCA_srifle_M107_base_F: Rifle_Long_Base_F {
        magazineWell[] += {"CBA_50BMG_M107"}; 
    };
    class JCA_hgun_G17_base_F: Pistol_Base_F {
        magazineWell[] += {"CBA_9x19_Glock_Full"}; 
    };
    class JCA_hgun_M9A1_base_F: Pistol_Base_F {
        magazineWell[] += {"CBA_9x19_M9"}; 
    };
    class JCA_hgun_Mk23_base_F: Pistol_Base_F {
        magazineWell[] += {"CBA_45ACP_USP"}; 
    };
    class JCA_hgun_P226_base_F: Pistol_Base_F {
        magazineWell[] += {"CBA_9x19_P226"}; 
    };
    class JCA_launch_Mk153_base_F: Launcher_Base_F {
        magazineWell[] += {"CBA_SMAW"}; 
    };
};
