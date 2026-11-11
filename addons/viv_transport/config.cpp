// https://community.bistudio.com/wiki/Arma_3:_Vehicle_in_Vehicle_Transport
#define VIV_ENABLED \
    class VehicleTransport { \
        class Cargo { \
            parachuteClass       = "B_Parachute_02_F";             \
            parachuteHeightLimit = 10;                             \
            canBeTransported     = 1;                              \
            dimensions[]         = {"BBox_1_1_pos","Mirror_R_BR"}; \
        }; \
    };

class CfgPatches {
    class fdelta_viv_transport {
        name = "420th Customizations - Vehicle-in-Vehicle Transport - Vanilla";
        author = "ol1034, thegamecracks";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.22;
        requiredAddons[] = {
            "A3_Data_F_Decade_Loadorder",
        };
        skipWhenMissingDependencies = 0;

        units[] = {};
    };
};

class CfgVehicles {
    class Car_F;
    class Tank_F;
    class VTOL_01_unarmed_base_F;
    class Wheeled_APC_F;

    class VTOL_01_vehicle_base_F : VTOL_01_unarmed_base_F {
        class VehicleTransport {
            class Carrier {
                maxLoadMass = 80000;
            };
        };
    };

    class MRAP_01_base_F : Car_F {
        VIV_ENABLED
    };
    class MRAP_02_base_F : Car_F {
        VIV_ENABLED
    };
    class APC_Wheeled_02_base_F : Wheeled_APC_F {
        class VehicleTransport {
            class Cargo {
                parachuteClass       = "B_Parachute_02_F";
                parachuteHeightLimit = 10;
                canBeTransported     = 1;
                dimensions[]         = {"BBox_1_1_pos","Mirror_R_BR"};
                rotation             = -90; // Slightly better than sticking out to the side
            };
        };
    };
    class APC_Wheeled_03_base_F : Wheeled_APC_F {
        VIV_ENABLED
    };
    class APC_Tracked_01_base_F : Tank_F {
        VIV_ENABLED
    };
    class APC_Tracked_02_base_F : Tank_F {
        VIV_ENABLED
    };
    class APC_Tracked_03_base_F : Tank_F {
        VIV_ENABLED
    };
    class MBT_01_base_F : Tank_F {
        VIV_ENABLED
    };
    class MBT_02_base_F : Tank_F {
        VIV_ENABLED
    };
    class MBT_03_base_F : Tank_F {
        VIV_ENABLED
    };
    class MBT_04_base_F : Tank_F {
        VIV_ENABLED
    };
};
