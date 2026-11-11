class CfgPatches {
    class fdelta_capacity_ef {
        name = "420th Customizations - Capacity Tweaks - Expeditionary Forces";
        author = "ol1034, thegamecracks";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.22;
        requiredAddons[] = {
            "A3_Data_F_Decade_Loadorder",
            "EF_Marines",
        };
        skipWhenMissingDependencies = 1;

        units[] = {};
    };
};

class CfgWeapons {
    class ItemCore;
    class Vest_Camo_Base : ItemCore {
        class ItemInfo;
    };
    class Vest_NoCamo_Base : ItemCore {
        class ItemInfo;
    };
    class EF_V_AAV_Coy : Vest_NoCamo_Base {
        class ItemInfo : ItemInfo {
            containerClass = "Supply300"; // 40
        };
    };
    class EF_V_AAV_Diver_Coy : EF_V_AAV_Coy {
        class ItemInfo : ItemInfo {
            containerClass = "Supply300"; // 80
        };
    };
    class EF_V_AAV_Diver_NoReb_Coy : EF_V_AAV_Coy {
        class ItemInfo : ItemInfo {
            containerClass = "Supply300"; // 80
        };
    };
    class EF_V_AAV_Rifleman_Coy : EF_V_AAV_Coy {
        class ItemInfo : ItemInfo {
            containerClass = "Supply300"; // 140
        };
    };
    class EF_V_AAV_Sailor_Coy : EF_V_AAV_Coy {
        class ItemInfo : ItemInfo {
            containerClass = "Supply300"; // 140
        };
    };
    class EF_V_AAV_Scout_Coy : EF_V_AAV_Coy {
        class ItemInfo : ItemInfo {
            containerClass = "Supply300"; // 140
        };
    };
    class EF_V_AAV_Support_Coy : EF_V_AAV_Coy {
        class ItemInfo : ItemInfo {
            containerClass = "Supply300"; // 140
        };
    };
    class EF_V_AAV_TL_Coy : EF_V_AAV_Coy {
        class ItemInfo : ItemInfo {
            containerClass = "Supply300"; // 140
        };
    };
    class EF_V_CCR_Rifleman_Coy : Vest_Camo_Base {
        class ItemInfo : ItemInfo {
            containerClass = "Supply300"; // 140
        };
    };
};
