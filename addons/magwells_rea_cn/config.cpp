#include "\z\fdelta\addons\magwells\magazines.hpp"

class CfgPatches {
    class magwells_rea_cn {
        name = "420th Customizations - Magazine Compatibility - ReArma CN weapons";
        author = "ol1034, thegamecracks";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.22;
        requiredAddons[] = {
            "cba_jam",
            "fdelta_magwells",
            "cn_weapon",
        };
        skipWhenMissingDependencies = 1;

        units[] = {};
    };
};

class CfgWeapons
{
    class Rifle_Base_F;
    class Rifle_Long_Base_F;
    class Rifle_Short_Base_F;
    class DMR_03_base_F: Rifle_Long_Base_F
    {
    };
    class arifle_ARX_base_F: Rifle_Base_F
    {
    };
    class QBW201_base: arifle_ARX_base_F
    {
        magazineWell[]+=
        {
            "CTAR_580x42",
            "CTAR_580x42_Large",
            "CBA_580x42_TYPE95",
            "CBA_580x42_TYPE95_XL",
        };
    };
    class sgun_HunterShotgun_01_base_F: Rifle_Long_Base_F
    {
    };
    class qbs09: sgun_HunterShotgun_01_base_F
    {
        magazineWell[]+=
        {
            "UBS_12GA",
        };
    };
    class SMG_02_base_F: Rifle_Short_Base_F
    {
    };
    class QCQ171_F: SMG_02_base_F
    {
        magazineWell[]+=
        {
            "CBA_9x19_ScorpionEvo3",
        };
    };
    class DMR_02_base_F: Rifle_Long_Base_F
    {
    };
    class QBU202: DMR_02_base_F
    {
        magazineWell[]+=
        {
            "MAR10_338",
        };
    };
};
