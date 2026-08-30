#define FDELTA_DAGR_AIR_TARGET_SPEED 200

class CfgPatches {
    class fdelta_guidance {
        name = "420th Customizations - Ammunition Guidance Tweaks";
        author = "zobri, thegamecracks";
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
    class MissileCore;
    class MissileBase : MissileCore {
        class Components;
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

    // DAR inherits from M_PG_AT in vanilla. Its lower 250 / 7.5 profile is the
    // 30 m member of the same small HE-fragmentation rocket bracket above.
    // Pin targeting so DAGR air-lock changes do not reach unguided rockets.
    class M_AT : M_PG_AT {
        airLock = 0;
        missileLockMaxSpeed = 35;
        aiAmmoUsageFlags = 128 + 64;

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
