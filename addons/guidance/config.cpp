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
                        maxTrackableSpeed = FDELTA_DAGR_AIR_TARGET_SPEED; // 35
                    };

                    class LaserSensorComponent : SensorTemplateLaser {
                        maxTrackableSpeed = FDELTA_DAGR_AIR_TARGET_SPEED; // 35
                    };
                };
            };
        };
    };

    // DAR inherits from M_PG_AT in vanilla.
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
