class CfgPatches {
    class fdelta_optics_ef {
        name = "420th Customizations - Optics Tweaks - Expeditionary Forces";
        author = "ol1034, thegamecracks";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.22;
        requiredAddons[] = {
            "A3_Data_F_Decade_Loadorder",
            "EF_Weapons",
        };
        skipWhenMissingDependencies = 1;

        units[] = {};
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
