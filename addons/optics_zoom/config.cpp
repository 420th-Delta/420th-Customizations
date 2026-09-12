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
                    // Allow zeroing scope in steps
                    discreteDistance[] = {300,400,500,600,700,800,900,1000};
                    discreteDistanceInitIndex = 0;
                    distanceZoomMax = 1000; // 300
                    distanceZoomMin = 300; // 300

                    // Allow zooming scope in steps
                    discreteFov[] = {0.25/2, 0.25/3, 0.25/4};
                    discreteInitIndex = 0;
                    opticsZoomInit = 0.25 / 2; // 0.125
                    opticsZoomMax = 0.25 / 2; // 0.125
                    opticsZoomMin = 0.25 / 4; // 0.125
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

                    discreteFov[] = {0.25/2, 0.25/3, 0.25/4};
                    discreteInitIndex = 0;
                    opticsZoomInit = 0.25 / 2; // 0.125
                    opticsZoomMax = 0.25 / 2; // 0.125
                    opticsZoomMin = 0.25 / 4; // 0.125
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

                    discreteFov[] = {0.25/2, 0.25/3, 0.25/4};
                    discreteInitIndex = 0;
                    opticsZoomInit = 0.25 / 2; // 0.125
                    opticsZoomMax = 0.25 / 2; // 0.125
                    opticsZoomMin = 0.25 / 4; // 0.125
                };
            };
        };
    };
};
