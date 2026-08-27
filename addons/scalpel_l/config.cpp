class CfgPatches {
    class fdelta_scalpel_l {
        name = "420th Customizations - Scalpel-L";
        author = "zobri";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.22;
        requiredAddons[] = {
            "A3_Functions_F",
            "A3_Weapons_F",
            "A3_Data_F_Decade_Loadorder",
            "fdelta_main",
        };
        skipWhenMissingDependencies = 0;

        units[] = {};
        weapons[] = {"fdelta_missiles_Scalpel_L"};
    };
};

class CfgFunctions {
    class fdelta {
        tag = "fdelta";

        class ScalpelL {
            file = "\z\fdelta\addons\scalpel_l\functions";

            class scalpelLOnFired {};
            class scalpelLCaptureCue {};
            class scalpelLTraceAimpoint {};
            class scalpelLTargetPointATL {};
            class scalpelLReceiveCue {};
            class scalpelLGuideMissile {};
            class scalpelLFindTerminalTarget {};
        };
    };
};

class CfgRemoteExec {
    class Functions {
        class fdelta_fnc_scalpelLReceiveCue {
            allowedTargets = 0;
            jip = 0;
        };
    };
};

class SensorTemplateActiveRadar;
class SensorTemplateIR;
class SensorTemplateLaser;
class SensorTemplateDataLink;

class CfgAmmo {
    class MissileCore;
    class MissileBase : MissileCore {};
    class M_Scalpel_AT : MissileBase {
        class Components;
    };

    class fdelta_M_Scalpel_L : M_Scalpel_AT {
        author = "zobri";

        // Retain the stock Scalpel body, tandem-HEAT warhead, propulsion and
        // TopDown tuning. Manual control lets the runtime fly immutable loft
        // waypoints for unlocked launches without following the operator's
        // camera after launch and without creating a visible proxy target.
        manualControl = 1;
        autoSeekTarget = 0;
        activeSensorAlwaysOn = 1;

        airLock = 0;
        irLock = 1;
        laserLock = 1;
        nvLock = 0;
        weaponLockSystem = 2 + 4 + 8 + 16;
        // The scripted overhead turn briefly places the target almost 90
        // degrees below the missile. The physical LOAL search remains gated
        // by fdelta_scalpelL_terminalCone; these wider engine cones only permit the final
        // pitch-over and retention of the already chosen target.
        missileLockCone = 120;
        missileKeepLockedCone = 180;
        // Scripted positions are an onboard-autopilot surrogate, not a player
        // command link. Accept recovery waypoints at every bearing and retain
        // enough engine control range while a fast carrier continues away.
        missileManualControlCone = 360;
        maxControlRange = 12000;
        missileLockMinDistance = 250;
        missileLockMaxDistance = 6000;
        missileLockMaxSpeed = 90;
        cmImmunity = 0.85;

        // Mod-specific values consumed by the owner-local guidance script.
        fdelta_scalpelL_terminalRange = 1600;
        fdelta_scalpelL_terminalCone = 45;
        fdelta_scalpelL_cueWait = 0.50;
        fdelta_scalpelL_aimRange = 6000;
        fdelta_scalpelL_loftAngle = 40;
        fdelta_scalpelL_pitchRadius = 500;
        fdelta_scalpelL_verticalDiveHeight = 400;
        fdelta_scalpelL_waypointTolerance = 80;
        fdelta_scalpelL_minimumLoftDistance = 1500;

        class Components : Components {
            class SensorsManagerComponent {
                class Components {
                    // Longbow-like millimetre-wave seeker. Its configured
                    // range supports a normal pre-launch hard lock; scripted
                    // unlocked shots do not accept a track until the shorter
                    // fdelta_scalpelL_terminalRange gate is crossed.
                    class ActiveRadarSensorComponent : SensorTemplateActiveRadar {
                        class AirTarget {
                            minRange = 0;
                            maxRange = 0;
                            objectDistanceLimitCoef = -1;
                            viewDistanceLimitCoef = -1;
                        };
                        class GroundTarget {
                            minRange = 6000;
                            maxRange = 6000;
                            objectDistanceLimitCoef = -1;
                            viewDistanceLimitCoef = -1;
                        };
                        typeRecognitionDistance = 4000;
                        angleRangeHorizontal = 45;
                        angleRangeVertical = 45;
                        maxTrackableSpeed = 90;
                        groundNoiseDistanceCoef = -1;
                        maxGroundNoiseDistance = -1;
                        minSpeedThreshold = 0;
                        maxSpeedThreshold = 0;
                    };

                    // IR remains as a compatibility fallback on aircraft that
                    // cannot present an active-radar lock through their FCS.
                    class IRSensorComponent : SensorTemplateIR {
                        class AirTarget {
                            minRange = 0;
                            maxRange = 0;
                            objectDistanceLimitCoef = -1;
                            viewDistanceLimitCoef = 1;
                        };
                        class GroundTarget {
                            minRange = 500;
                            maxRange = 6000;
                            objectDistanceLimitCoef = 1;
                            viewDistanceLimitCoef = 1;
                        };
                        maxTrackableSpeed = 90;
                        angleRangeHorizontal = 45;
                        angleRangeVertical = 45;
                    };

                    class LaserSensorComponent : SensorTemplateLaser {
                        class AirTarget {
                            minRange = 0;
                            maxRange = 0;
                            objectDistanceLimitCoef = -1;
                            viewDistanceLimitCoef = -1;
                        };
                        class GroundTarget {
                            minRange = 6000;
                            maxRange = 6000;
                            objectDistanceLimitCoef = -1;
                            viewDistanceLimitCoef = -1;
                        };
                        maxTrackableSpeed = 90;
                        angleRangeHorizontal = 90;
                        angleRangeVertical = 70;
                    };

                    class DataLinkSensorComponent : SensorTemplateDataLink {
                        class AirTarget {
                            minRange = 0;
                            maxRange = 0;
                            objectDistanceLimitCoef = -1;
                            viewDistanceLimitCoef = -1;
                        };
                        class GroundTarget {
                            minRange = 6000;
                            maxRange = 6000;
                            objectDistanceLimitCoef = -1;
                            viewDistanceLimitCoef = -1;
                        };
                        maxTrackableSpeed = 90;
                        angleRangeHorizontal = 120;
                        angleRangeVertical = 90;
                    };
                };
            };
        };
    };
};

class CfgMagazines {
    class PylonRack_1Rnd_LG_scalpel;
    class PylonMissile_1Rnd_LG_scalpel;
    class PylonRack_3Rnd_LG_scalpel;
    class PylonRack_4Rnd_LG_scalpel;

    class fdelta_PylonRack_1Rnd_Scalpel_L : PylonRack_1Rnd_LG_scalpel {
        author = "zobri";
        displayName = "Scalpel-L";
        displayNameShort = "Scalpel-L";
        descriptionShort = "Longbow-style radar/IR fire-and-forget ATGM with top-attack and terminal LOAL.";
        ammo = "fdelta_M_Scalpel_L";
        pylonWeapon = "fdelta_missiles_Scalpel_L";
    };

    class fdelta_PylonMissile_1Rnd_Scalpel_L : PylonMissile_1Rnd_LG_scalpel {
        author = "zobri";
        displayName = "Scalpel-L";
        displayNameShort = "Scalpel-L";
        descriptionShort = "Longbow-style radar/IR fire-and-forget ATGM with top-attack and terminal LOAL.";
        ammo = "fdelta_M_Scalpel_L";
        pylonWeapon = "fdelta_missiles_Scalpel_L";
    };

    class fdelta_PylonRack_3Rnd_Scalpel_L : PylonRack_3Rnd_LG_scalpel {
        author = "zobri";
        displayName = "Scalpel-L 3x";
        displayNameShort = "Scalpel-L";
        descriptionShort = "Three Longbow-style radar/IR fire-and-forget ATGMs with top-attack and terminal LOAL.";
        ammo = "fdelta_M_Scalpel_L";
        pylonWeapon = "fdelta_missiles_Scalpel_L";
    };

    class fdelta_PylonRack_4Rnd_Scalpel_L : PylonRack_4Rnd_LG_scalpel {
        author = "zobri";
        displayName = "Scalpel-L 4x";
        displayNameShort = "Scalpel-L";
        descriptionShort = "Four Longbow-style radar/IR fire-and-forget ATGMs with top-attack and terminal LOAL.";
        ammo = "fdelta_M_Scalpel_L";
        pylonWeapon = "fdelta_missiles_Scalpel_L";
    };
};

class CfgWeapons {
    class RocketPods;
    class missiles_SCALPEL : RocketPods {
        class TopDown;
    };

    class fdelta_missiles_Scalpel_L : missiles_SCALPEL {
        author = "zobri";
        displayName = "Scalpel-L";
        canLock = 2;
        weaponLockDelay = 3;
        weaponLockSystem = 2 + 4 + 8 + 16;
        cmImmunity = 0.85;
        magazines[] = {
            "fdelta_PylonRack_1Rnd_Scalpel_L",
            "fdelta_PylonMissile_1Rnd_Scalpel_L",
            "fdelta_PylonRack_3Rnd_Scalpel_L",
            "fdelta_PylonRack_4Rnd_Scalpel_L"
        };

        class TopDown : TopDown {
            displayName = "Scalpel-L";
        };

        class EventHandlers {
            fired = "_this call fdelta_fnc_scalpelLOnFired";
        };
    };
};
