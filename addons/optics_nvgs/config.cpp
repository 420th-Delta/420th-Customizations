class CfgPatches {
    class fdelta_optics_nvgs {
        name = "420th Customizations - Optics NVGs Compatibility";
        author = "thegamecracks";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.22;
        requiredAddons[] = {
            "fdelta_main",
        };
        skipWhenMissingDependencies = 1;
        skipWhenAnyAddonPresent[] = {
            // This addon is derived from JCA - QOL Essentials V2 with permission:
            // https://steamcommunity.com/sharedfiles/filedetails/?id=3032405142
            "Weapons_F_Essentials_Items",
        };

        units[] = {};
    };
};

class CfgWeapons {
    class ItemCore;
    class InventoryOpticsItem_Base_F;
    class optic_AMS_base : ItemCore {
        class ItemInfo : InventoryOpticsItem_Base_F {
            class OpticsModes {
                class AMS {
                    visionMode[] = {};
                };
            };
        };
    };
    class optic_DMS : ItemCore {
        class ItemInfo : InventoryOpticsItem_Base_F {
            class OpticsModes {
                class Snip {
                    visionMode[] = {};
                };
            };
        };
    };
    class optic_KHS_base : ItemCore {
        class ItemInfo : InventoryOpticsItem_Base_F {
            class OpticsModes {
                class KHS {
                    visionMode[] = {};
                };
            };
        };
    };
    class optic_KHS_old : ItemCore {
        class ItemInfo : InventoryOpticsItem_Base_F {
            class OpticsModes {
                class KHS {
                    visionMode[] = {};
                };
            };
        };
    };
    class optic_LRPS : ItemCore {
        class ItemInfo : InventoryOpticsItem_Base_F {
            class OpticsModes {
                class Snip {
                    visionMode[] = {};
                };
            };
        };
    };
    class optic_SOS : ItemCore {
        class ItemInfo : InventoryOpticsItem_Base_F {
            class OpticsModes {
                class Snip {
                    visionMode[] = {};
                };
            };
        };
    };
};
