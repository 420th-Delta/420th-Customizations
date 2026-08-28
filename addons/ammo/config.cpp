#define FDELTA_MK82_INDIRECT_HIT 3200
#define FDELTA_MK82_INDIRECT_RANGE 16.25
#define FDELTA_155MM_INDIRECT_HIT 3600
#define FDELTA_155MM_INDIRECT_RANGE 8.75
#define FDELTA_230MM_INDIRECT_HIT 3200
#define FDELTA_230MM_INDIRECT_RANGE 16.25
#define FDELTA_CRUISE_INDIRECT_HIT 7000
#define FDELTA_CRUISE_INDIRECT_RANGE 30

class CfgPatches {
    class fdelta_ammo {
        name = "420th Customizations - Vanilla Ammunition Tweaks";
        author = "Seathre0420, zobri";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.22;
        requiredAddons[] = {
            "A3_Weapons_F",
            "A3_Weapons_F_Jets",
            "A3_Weapons_F_Orange",
            "A3_Weapons_F_Sams",
            "A3_Weapons_F_Destroyer",
            "A3_Data_F_Decade_Loadorder",
            "fdelta_main",
        };
        skipWhenMissingDependencies = 0;

        units[] = {};
        weapons[] = {};
    };
};

class CfgAmmo {
    class Default;
    class ShellCore : Default {};
    class ShellBase : ShellCore {};

    class BombCore : Default {};
    class LaserBombCore : BombCore {};
    class ammo_Bomb_LaserGuidedBase : LaserBombCore {};
    class ammo_Bomb_SmallDiameterBase : ammo_Bomb_LaserGuidedBase {};

    class MissileCore : Default {};
    class MissileBase : MissileCore {};
    class ammo_Missile_AntiRadiationBase : MissileBase {};

    class RocketCore : Default {};
    class RocketBase : RocketCore {};

    // Unitary warhead rebalance

    // 500 lb Mk 82 family. In Arma, native indirect damage reaches zero at
    // roughly four times indirectHitRange, so 16.25 gives a 65 m cutoff.
    class Bo_Mk82 : BombCore {
        indirectHit = FDELTA_MK82_INDIRECT_HIT;
        indirectHitRange = FDELTA_MK82_INDIRECT_RANGE;
    };

    class Bomb_04_F : ammo_Bomb_LaserGuidedBase {
        indirectHit = FDELTA_MK82_INDIRECT_HIT;
        indirectHitRange = FDELTA_MK82_INDIRECT_RANGE;
    };

    // Larger 250 kg-class guided bomb used by the CSAT aircraft.
    class Bomb_03_F : ammo_Bomb_LaserGuidedBase {
        indirectHit = 3600;
        indirectHitRange = 18.75;
    };

    // Keep the existing 420th SDB adjustment unchanged in this UWR pass.
    class ammo_Bomb_SDB : ammo_Bomb_SmallDiameterBase {
        indirectHit = 200; // 85
        indirectHitRange = 5; // 3
    };

    // Remaining unitary warhead rebalance

    class Sh_155mm_AMOS : ShellBase {
        indirectHit = FDELTA_155MM_INDIRECT_HIT;
        indirectHitRange = FDELTA_155MM_INDIRECT_RANGE;
    };

    // The 230 mm HE launcher projectile separates at 500 m. Patch only its
    // ground-impact terminal leaf; cluster and latent anti-armor leaves use
    // different terminal classes and remain untouched.
    class R_230mm_fly : ShellBase {
        indirectHit = FDELTA_230MM_INDIRECT_HIT;
        indirectHitRange = FDELTA_230MM_INDIRECT_RANGE;
    };

    // VLS unitary cruise missile. Its cluster child inherits this class, so
    // the child is explicitly pinned to the complete vanilla damage triplet.
    class ammo_Missile_CruiseBase : MissileBase {};
    class ammo_Missile_Cruise_01 : ammo_Missile_CruiseBase {
        indirectHit = FDELTA_CRUISE_INDIRECT_HIT;
        indirectHitRange = FDELTA_CRUISE_INDIRECT_RANGE;
    };
    class ammo_Missile_Cruise_01_Cluster : ammo_Missile_Cruise_01 {
        hit = 6000;
        indirectHit = 2000;
        indirectHitRange = 30;
    };

    // The destroyer cannon shares the conventional artillery parent but is not
    // part of this pass. Pin its unguided splash to vanilla.
    class ammo_ShipCannon_120mm_HE : Sh_155mm_AMOS {
        indirectHit = 125;
        indirectHitRange = 30;
    };

    class Rocket_04_HE_F : MissileBase {
        indirectHit = 300;
        indirectHitRange = 10;
    };

    class Rocket_03_HE_F : Rocket_04_HE_F {
        indirectHit = 300;
        indirectHitRange = 10;
    };

    class R_80mm_HE : RocketBase {
        indirectHit = 350;
        indirectHitRange = 10;
    };

    class ammo_Missile_HARM : ammo_Missile_AntiRadiationBase {
        indirectHit = 2000;
        indirectHitRange = 15;
    };

    class ammo_Missile_KH58 : ammo_Missile_AntiRadiationBase {
        indirectHit = 2800;
        indirectHitRange = 18.75;
    };

    // BombCluster_01 and its descendants inherit from Bomb_04_F. Pin the
    // carrier blast to vanilla so changing GBU-12 cannot buff cluster bombs.
    class BombCluster_01_Ammo_F : Bomb_04_F {
        hit = 5000;
        indirectHit = 1100;
        indirectHitRange = 12;
    };

    // The AP rocket leaves inherit from the patched HE family. Re-state their
    // vanilla values so their penetrator/HEAT balance remains untouched.
    class Rocket_04_AP_F : Rocket_04_HE_F {
        hit = 95;
        indirectHit = 25;
        indirectHitRange = 2.5;
    };

    class Rocket_03_AP_F : Rocket_04_AP_F {
        hit = 95;
        indirectHit = 25;
        indirectHitRange = 3;
    };

    class M_PG_AT : MissileBase {};
    class M_AT : M_PG_AT {
        indirectHit = 250;
        indirectHitRange = 7.5;
    };
};
