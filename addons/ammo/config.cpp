#define FDELTA_MK82_INDIRECT_HIT 3200
#define FDELTA_MK82_INDIRECT_RANGE 16.25
#define FDELTA_155MM_INDIRECT_HIT 3600
#define FDELTA_155MM_INDIRECT_RANGE 8.75
#define FDELTA_230MM_INDIRECT_HIT 3200
#define FDELTA_230MM_INDIRECT_RANGE 16.25
#define FDELTA_CRUISE_INDIRECT_HIT 7000
#define FDELTA_CRUISE_INDIRECT_RANGE 30
#define FDELTA_DAGR_AIR_TARGET_SPEED 700

class CfgPatches {
    class fdelta_ammo {
        name = "420th Customizations - Vanilla Ammunition Tweaks";
        author = "Seathre0420, zobri";
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

class SensorTemplateIR;
class SensorTemplateLaser;

class CfgAmmo {
    class ammo_Bomb_LaserGuidedBase;
    class ammo_Bomb_SmallDiameterBase;
    class ammo_Missile_AntiRadiationBase;
    class ammo_Missile_CruiseBase;
    class BombCore;
    class MissileCore;
    class MissileBase : MissileCore {
        class Components;
    };
    class RocketBase;
    class ShellBase;

    // Unitary warhead rebalance

    // 500 lb Mk 82 family. In Arma, native indirect damage reaches zero at
    // roughly four times indirectHitRange, so 16.25 gives a 65 m cutoff.
    class Bo_Mk82 : BombCore {
        indirectHit = FDELTA_MK82_INDIRECT_HIT; // 1100
        indirectHitRange = FDELTA_MK82_INDIRECT_RANGE; // 12
    };

    class Bomb_04_F : ammo_Bomb_LaserGuidedBase {
        indirectHit = FDELTA_MK82_INDIRECT_HIT; // 1100
        indirectHitRange = FDELTA_MK82_INDIRECT_RANGE; // 12
    };

    // Larger 250 kg-class guided bomb used by the CSAT aircraft.
    class Bomb_03_F : ammo_Bomb_LaserGuidedBase {
        indirectHit = 3600; // 1400
        indirectHitRange = 18.75; // 16
    };

    // The SDB remains much smaller than a Mk 82, but is no longer restricted
    // to the existing short-ranged 200 / 5 splash profile.
    class ammo_Bomb_SDB : ammo_Bomb_SmallDiameterBase {
        indirectHit = 1600; // 85
        indirectHitRange = 10; // 3
    };

    class Sh_155mm_AMOS : ShellBase {
        indirectHit = FDELTA_155MM_INDIRECT_HIT; // 125
        indirectHitRange = FDELTA_155MM_INDIRECT_RANGE; // 30
    };

    // The 230 mm HE launcher projectile separates at 500 m. Patch only its
    // ground-impact terminal leaf; cluster and latent anti-armor leaves use
    // different terminal classes and remain untouched.
    class R_230mm_fly : ShellBase {
        indirectHit = FDELTA_230MM_INDIRECT_HIT; // 800
        indirectHitRange = FDELTA_230MM_INDIRECT_RANGE; // 30
    };

    // VLS unitary cruise missile. Its cluster child inherits this class, so
    // the child is explicitly pinned to the complete vanilla damage triplet.
    class ammo_Missile_Cruise_01 : ammo_Missile_CruiseBase {
        indirectHit = FDELTA_CRUISE_INDIRECT_HIT; // 2000
        indirectHitRange = FDELTA_CRUISE_INDIRECT_RANGE; // 30
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
        indirectHit = 300; // 55
        indirectHitRange = 10; // 15
    };

    class Rocket_03_HE_F : Rocket_04_HE_F {
        indirectHit = 300; // 55
        indirectHitRange = 10; // 15
    };

    class R_80mm_HE : RocketBase {
        indirectHit = 350; // 60
        indirectHitRange = 10; // 15
    };

    class ammo_Missile_HARM : ammo_Missile_AntiRadiationBase {
        indirectHit = 2000; // 85
        indirectHitRange = 15; // 8
    };

    class ammo_Missile_KH58 : ammo_Missile_AntiRadiationBase {
        indirectHit = 2800; // 85
        indirectHitRange = 18.75; // 8
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

    // Keep ground targeting on DAGR/DAGRM and add the air target category.
    class M_PG_AT : MissileBase {
        airLock = 1; // 0
        missileLockMaxSpeed = FDELTA_DAGR_AIR_TARGET_SPEED; // 35
        aiAmmoUsageFlags = 64 + 128 + 256; // 128 + 64

        class Components : Components {
            class SensorsManagerComponent {
                class Components {
                    class IRSensorComponent : SensorTemplateIR {
                        class AirTarget {
                            minRange = 500;
                            maxRange = 4000;
                            objectDistanceLimitCoef = -1;
                            viewDistanceLimitCoef = 1;
                        };
                        class GroundTarget {
                            minRange = 500;
                            maxRange = 4000;
                            objectDistanceLimitCoef = 1;
                            viewDistanceLimitCoef = 1;
                        };
                        maxTrackableSpeed = FDELTA_DAGR_AIR_TARGET_SPEED; // 35
                        angleRangeHorizontal = 45;
                        angleRangeVertical = 35;
                    };

                    class LaserSensorComponent : SensorTemplateLaser {
                        class AirTarget {
                            minRange = 4000;
                            maxRange = 4000;
                            objectDistanceLimitCoef = -1;
                            viewDistanceLimitCoef = -1;
                        };
                        class GroundTarget {
                            minRange = 4000;
                            maxRange = 4000;
                            objectDistanceLimitCoef = -1;
                            viewDistanceLimitCoef = -1;
                        };
                        maxTrackableSpeed = FDELTA_DAGR_AIR_TARGET_SPEED; // 35
                        angleRangeHorizontal = 90;
                        angleRangeVertical = 70;
                    };
                };
            };
        };
    };

    // DAGRM inherits the patched sensor tree and retains vanilla
    // autoSeekTarget = 1, so aircraft remain eligible after launch. Re-state
    // its top-level gates so both affected projectile classes are explicit.
    class M_PGM_AT : M_PG_AT {
        airLock = 1; // 0
        missileLockMaxSpeed = FDELTA_DAGR_AIR_TARGET_SPEED; // 35
        aiAmmoUsageFlags = 64 + 128 + 256; // 128 + 64
    };

    // DAR inherits from M_PG_AT in vanilla. Apply its UWR blast values while
    // pinning targeting so DAGR air-lock changes do not reach unguided rockets.
    class M_AT : M_PG_AT {
        airLock = 0;
        missileLockMaxSpeed = 35;
        aiAmmoUsageFlags = 128 + 64;
        indirectHit = 250; // 50
        indirectHitRange = 7.5; // 8

        class Components : Components {
            class SensorsManagerComponent : SensorsManagerComponent {
                class Components : Components {
                    class IRSensorComponent : IRSensorComponent {
                        maxTrackableSpeed = 35;
                    };
                    class LaserSensorComponent : LaserSensorComponent {
                        maxTrackableSpeed = 35;
                    };
                };
            };
        };
    };
};

class CfgMagazines {
    class VehicleMagazine;

    class 24Rnd_PG_missiles : VehicleMagazine {
        // Propagates to the legacy and pylon DAGR/DAGRM magazine classes.
        maxLeadSpeed = FDELTA_DAGR_AIR_TARGET_SPEED; // 41.6667
    };
};
