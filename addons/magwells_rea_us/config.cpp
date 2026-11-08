#include "\z\fdelta\addons\magwells\magazines.hpp"

class CfgPatches {
    class magwells_rea_us {
        name = "420th Customizations - Magazine Compatibility - ReArma US weapons";
        author = "ol1034, thegamecracks";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.22;
        requiredAddons[] = {
            "cba_jam",
            "fdelta_magwells",
			"us_weapon"
        };
        skipWhenMissingDependencies = 1;

        units[] = {};
    };
};

class CfgWeapons
{
	class Rifle_Base_F;
	class Rifle_Short_Base_F;
	class Rifle_Long_Base_F;
	class DMR_03_base_F: Rifle_Long_Base_F
	{
	};
	class M7_base_F: DMR_03_base_F
	{
		magazineWell[]+=
		{
			"MX_65x39",
			"MX_65x39_Large",
			"CBA_65x39_MX",
			"CBA_65x39_MX_XL"
		};
	};
	class RM277_base_F: DMR_03_base_F
	{
		magazineWell[]+=
		{
			"MX_65x39",
			"MX_65x39_Large",
			"CBA_65x39_MX",
			"CBA_65x39_MX_XL"
		};
	};
	class RM277UW_F: RM277_base_F
	{
		magazineWell[]=
		{
			"MX_65x39",
			"MX_65x39_Large",
			"CBA_65x39_MX",
			"CBA_65x39_MX_XL"
		};
	};
	class arifle_SPAR_01_base_F: Rifle_Base_F
	{
	};
	class NX_base_F: arifle_SPAR_01_base_F
	{
		magazineWell[]+=
		{
			"STANAG_556x45",
			"STANAG_556x45_Large",
			"CBA_556x45_STANAG",
			"CBA_556x45_STANAG_L",
			"CBA_556x45_STANAG_XL",
			"CBA_556x45_STANAG_2D",
			"CBA_556x45_STANAG_2D_XL"
		};
	};
	class SMG_02_base_F: Rifle_Short_Base_F
	{
	};
	class MP7A2_base_f: SMG_02_base_F
	{
		magazineWell[]+=
		{
			"CBA_46x30_MP7"
		};
	};
	class MMG_02_base_F: Rifle_Long_Base_F
	{
	};
	class M250_F: MMG_02_base_F
	{
		magazineWell[]+=
		{
			"Mk200_65x39",
			"CBA_65x39_Mk200"
		};
	};    
};
