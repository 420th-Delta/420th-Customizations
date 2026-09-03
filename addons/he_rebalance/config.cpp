// Retain this patch as a load-order anchor for existing downstream addons.
// It deliberately contains no ammunition or damage overrides.
class CfgPatches {
    class fdelta_he_rebalance {
        name = "420th Customizations - Legacy HE Rebalance Compatibility";
        author = "Seathre0420, zobri, thegamecracks";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.22;
        requiredAddons[] = {
            "A3_Data_F_Decade_Loadorder",
            "fdelta_main",
        };
        skipWhenMissingDependencies = 0;

        units[] = {};
    };
};
