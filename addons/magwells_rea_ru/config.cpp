#include "\z\fdelta\addons\magwells\magazines.hpp"

class CfgPatches {
    class magwells_rea_ru {
        name = "420th Customizations - Magazine Compatibility - ReArma RU weapons";
        author = "ol1034, thegamecracks";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.22;
        requiredAddons[] = {
            "cba_jam",
            "fdelta_magwells",
            "rus_weapon_rifles"
        };
        skipWhenMissingDependencies = 1;

        units[] = {};
    };
};

class CfgWeapons
{
    class Rifle_Base_F;
    class Rifle_Long_Base_F;
    class DMR_03_base_F: Rifle_Long_Base_F
    {
    };
    class arifle_AK12_base_F: Rifle_Base_F
    {
    };
    class RPL35_F: arifle_AK12_base_F
    {
        magazineWell[]+=
        {
            "CBA_762x54R_LINKS"
        };
    };
    class MMG_01_base_F: Rifle_Long_Base_F
    {
    };
    class PKP_F: MMG_01_base_F
    {
        magazineWell[]+=
        {
            "CBA_762x54R_LINKS"
        };
    };
    class sgun_HunterShotgun_01_base_F: Rifle_Long_Base_F
    {
    };
    class ks23_F: sgun_HunterShotgun_01_base_F
    {
        magazineWell[]+=
        {
            "UBS_12GA"
        };
    };
    class DMR_01_base_F: Rifle_Long_Base_F
    {
    };
    class SV98M_F: DMR_01_base_F
    {
        magazineWell[]+=
        {
            "CBA_762x54R_SVD"
        };
    };
    class DMR_02_base_F: Rifle_Long_Base_F
    {
    };
    class SVCh_F: DMR_02_base_F
    {
        magazineWell[]+=
        {
            "CBA_762x54R_SVD"
        };
    };
};
