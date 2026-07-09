class CfgPatches {
    class fdelta_optics_rhsusf {
        name = "420th Customizations - RHSUSAF Optics Compatibility";
        author = "ol1034, thegamecracks";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.20;
        requiredAddons[] = {
            "rhsusf_c_weapons",
        };
        skipWhenMissingDependencies = 1;

        units[] = {};
    };
};

class CfgWeapons {
    class InventoryOpticsItem_Base_F;
    class ItemCore;
    class rhsusf_acc_g33_xps3 : ItemCore {
        class ItemInfo : InventoryOpticsItem_Base_F {
            class OpticsModes {
                class MAG {
                    opticsDisablePeripherialVision = 0;
                    visionMode[] = {};
                };
            };
        };
    };
};
