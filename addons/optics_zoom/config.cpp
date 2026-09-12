class CfgPatches {
    class fdelta_optics_zoom {
        name = "420th Customizations - Enhanced Optics Magnification - Vanilla";
        author = "thegamecracks";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.22;
        requiredAddons[] = {
            "A3_Data_F_Decade_Loadorder",
        };
        skipWhenMissingDependencies = 0;
        skipWhenAnyAddonPresent[] = {
            "A3RO_A3", // Conflicts with A3RO - Arma 3 Realism Overhaul
        };

        units[] = {};
    };
};

class CfgWeapons {
    class ItemCore;
    class InventoryOpticsItem_Base_F;
    class optic_Arco : ItemCore {
        class ItemInfo : InventoryOpticsItem_Base_F {
            class OpticsModes {
                class ARCO2collimator;
                class ARCO2scope : ARCO2collimator {
                    discreteDistance[] = {300,400,500,600,700,800,900,1000};
                    discreteDistanceInitIndex = 0;
                    distanceZoomMax = 1000; // 300
                    distanceZoomMin = 300; // 300
                };
                class fdelta_ARCO2scope_4x : ARCO2scope {
                    opticsID = 3;
                    opticsZoomInit = 0.25 / 4;
                    opticsZoomMax = 0.25 / 4;
                    opticsZoomMin = 0.25 / 4;
                };
            };
        };
    };
    class optic_Hamr : ItemCore {
        class ItemInfo : InventoryOpticsItem_Base_F {
            class OpticsModes {
                class Hamr2Scope {
                    discreteDistance[] = {300,400,500,600,700,800,900,1000};
                    discreteDistanceInitIndex = 0;
                    distanceZoomMax = 1000; // 300
                    distanceZoomMin = 300; // 300
                };
                class fdelta_Hamr2Scope_4x : Hamr2Scope {
                    opticsID = 3;
                    opticsZoomInit = 0.25 / 4;
                    opticsZoomMax = 0.25 / 4;
                    opticsZoomMin = 0.25 / 4;
                };
            };
        };
    };
    class optic_MRCO : ItemCore {
        class ItemInfo : InventoryOpticsItem_Base_F {
            class OpticsModes {
                class MRCOscope {
                    discreteDistance[] = {300,400,500,600,700,800,900,1000};
                    discreteDistanceInitIndex = 0;
                    distanceZoomMax = 1000; // 300
                    distanceZoomMin = 300; // 300
                };
                class fdelta_MRCOscope_4x : MRCOscope {
                    opticsID = 3;
                    opticsZoomInit = 0.25 / 4;
                    opticsZoomMax = 0.25 / 4;
                    opticsZoomMin = 0.25 / 4;
                };
            };
        };
    };
};
