class CfgPatches {
    class fdelta_blast {
        name = "420th Customizations - Blast Propagation";
        author = "zobri";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.22;
        requiredAddons[] = {
            "fdelta_ammo",
        };
        skipWhenMissingDependencies = 0;

        units[] = {};
        weapons[] = {};
    };
};

class CfgFunctions {
    class fdelta {
        tag = "fdelta";

        class BlastPropagation {
            file = "\z\fdelta\addons\blast\functions";

            class blastPreInit { preInit = 1; };
            class blastProfile {};
            class blastSampleCurve {};
            class blastRegisterProjectile {};
            class blastRegisterProjectileEvidence {};
            class blastMonitorRegistry {};
            class blastReceiveBlast {};
            class blastValidateReport {};
            class blastProcessQueue {};
            class blastProcessBlast {};
            class blastMeasureCover {};
            class blastApplyTrauma {};
            class blastClientEffect {};
        };
    };
};

class CfgRemoteExec {
    class Functions {
        class fdelta_fnc_blastRegisterProjectileEvidence {
            allowedTargets = 2;
            jip = 0;
        };
        class fdelta_fnc_blastReceiveBlast {
            allowedTargets = 2;
            jip = 0;
        };
        class fdelta_fnc_blastClientEffect {
            allowedTargets = 1;
            jip = 0;
        };
    };
};

// This is an exact registry rather than an inheritance tree. Cluster carriers
// and other descendants therefore cannot inherit supplemental blast damage.
class CfgFdeltaBlastProfiles {
    class Bo_Mk82 {
        outerRanges[] = {65, 70, 100, 150, 200, 250};
        outerDoses[] = {0.36, 0.30, 0.18, 0.11, 0.07, 0.045};
        innerRanges[] = {0, 30, 55, 60, 65};
        innerDoses[] = {1.20, 1.20, 1.15, 1.10, 0.45};
        virtualLift = 4;
    };
    class Bomb_04_F : Bo_Mk82 {};

    class Bomb_03_F {
        outerRanges[] = {75, 82, 110, 165, 220, 275};
        outerDoses[] = {0.36, 0.30, 0.18, 0.11, 0.07, 0.045};
        innerRanges[] = {0, 35, 60, 70, 75};
        innerDoses[] = {1.20, 1.20, 1.15, 1.10, 0.45};
        virtualLift = 4.5;
    };

    class ammo_Bomb_SDB {
        outerRanges[] = {40, 45, 57, 86, 114, 145};
        outerDoses[] = {0.32, 0.27, 0.17, 0.10, 0.06, 0.035};
        innerRanges[] = {0, 15, 30, 35, 40};
        innerDoses[] = {1.15, 1.15, 1.05, 0.90, 0.35};
        virtualLift = 3;
    };

    // Guided 155 mm carriers separate above the target. Only the terminal
    // leaves below receive a profile.
    class Sh_155mm_AMOS {
        outerRanges[] = {35, 40, 55, 75, 100, 125};
        outerDoses[] = {0.30, 0.25, 0.16, 0.10, 0.06, 0.035};
        innerRanges[] = {0, 15, 27.5, 32, 35};
        innerDoses[] = {1.10, 1.10, 1.00, 0.85, 0.35};
        virtualLift = 2.5;
    };
    class fdelta_M_Mo_155mm_HE_Guided : Sh_155mm_AMOS {};
    class fdelta_M_Mo_155mm_HE_LG : Sh_155mm_AMOS {};

    class R_230mm_fly : Bo_Mk82 {};

    class ammo_Missile_Cruise_01 {
        outerRanges[] = {120, 135, 180, 250, 325, 400};
        outerDoses[] = {0.45, 0.38, 0.25, 0.15, 0.09, 0.055};
        innerRanges[] = {0, 50, 90, 110, 120};
        innerDoses[] = {1.40, 1.40, 1.30, 1.15, 0.50};
        virtualLift = 6;
    };

    class Rocket_04_HE_F {
        outerRanges[] = {40, 45, 55, 68, 80, 90};
        outerDoses[] = {0.24, 0.20, 0.13, 0.08, 0.045, 0.025};
        innerRanges[] = {0, 10, 20, 30, 40};
        innerDoses[] = {1.00, 0.95, 0.80, 0.55, 0.25};
        virtualLift = 2;
    };
    class Rocket_03_HE_F : Rocket_04_HE_F {};

    class M_AT {
        outerRanges[] = {30, 36, 46, 58, 70, 80};
        outerDoses[] = {0.22, 0.18, 0.12, 0.07, 0.04, 0.02};
        innerRanges[] = {0, 8, 15, 22, 30};
        innerDoses[] = {0.95, 0.90, 0.75, 0.50, 0.22};
        virtualLift = 1.75;
    };

    class R_80mm_HE {
        outerRanges[] = {40, 48, 60, 75, 90, 100};
        outerDoses[] = {0.26, 0.21, 0.14, 0.085, 0.05, 0.025};
        innerRanges[] = {0, 10, 20, 30, 40};
        innerDoses[] = {1.05, 1.00, 0.85, 0.60, 0.27};
        virtualLift = 2;
    };

    class ammo_Missile_HARM {
        outerRanges[] = {60, 68, 85, 115, 150, 190};
        outerDoses[] = {0.32, 0.27, 0.17, 0.10, 0.06, 0.035};
        innerRanges[] = {0, 25, 45, 52, 60};
        innerDoses[] = {1.15, 1.15, 1.05, 0.90, 0.35};
        virtualLift = 3.5;
    };

    class ammo_Missile_KH58 {
        outerRanges[] = {75, 82, 105, 155, 205, 250};
        outerDoses[] = {0.34, 0.29, 0.18, 0.11, 0.07, 0.04};
        innerRanges[] = {0, 30, 55, 65, 75};
        innerDoses[] = {1.20, 1.20, 1.15, 1.05, 0.40};
        virtualLift = 4;
    };
};
