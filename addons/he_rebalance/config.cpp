class CfgPatches {
    class fdelta_he_rebalance {
        name = "420th Customizations - Vanilla HE Rebalance";
        author = "Seathre0420, thegamecracks";
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

class CfgAmmo {
    class ammo_Bomb_SmallDiameterBase;
    class B_127x99_SLAP;
    class B_19mm_HE;
    class BulletBase;

    class ammo_Bomb_SDB : ammo_Bomb_SmallDiameterBase {
        indirectHit = 200; // 85
        indirectHitRange = 5; // 3
    };

    // HE Shell Rebalance
    // About a 50% increase-ish. Should make most autocannons more effective on infantry.

    class B_127x99_HEIAP : B_127x99_SLAP {
        indirectHit = 6; // 3
        indirectHitRange = 4; // 2
    };

    class Gatling_30mm_HE_Plane_CAS_01_F : BulletBase {
        indirectHit = 6; // 4
        indirectHitRange = 6; // 3
    };

    class Cannon_30mm_HE_Plane_CAS_02_F : Gatling_30mm_HE_Plane_CAS_01_F {
        indirectHit = 6; // 4
        indirectHitRange = 6; // 4
    };

    class B_30mm_HE : B_19mm_HE {
        indirectHit = 12; // 8
        indirectHitRange = 6; // 3
    };

    class B_30mm_MP : B_30mm_HE {
        indirectHit = 8; // 4
        indirectHitRange = 4; // 2
    };

    class B_40mm_GPR : B_30mm_HE {
        indirectHit = 12; // 8
        indirectHitRange = 6; // 4
    };

    class B_20mm : BulletBase {
        indirectHit = 6; // 6
        indirectHitRange = 4.8; // 1.6
    };
};
