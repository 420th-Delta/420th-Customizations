class CfgPatches {
    class fdelta_a3ti {
        name = "420th Customizations - A3TI Fixes";
        author = "thegamecracks";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.22;
        requiredAddons[] = {
            "A3TI",
        };
        skipWhenMissingDependencies = 1;

        units[] = {};
    };
};

class CfgFunctions {
    class A3TI {
        class core {
            class cameraViewEH { file = "z\fdelta\addons\a3ti\fn_cameraViewEH.sqf"; };
            class getPlayerTurret { file = "z\fdelta\addons\a3ti\fn_getPlayerTurret.sqf"; };
        };
    };
};
