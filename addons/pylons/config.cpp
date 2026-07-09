class CfgPatches {
    class fdelta_pylons {
        name = "420th Customizations - Pylons Compatibility";
        author = "ol1034, thegamecracks";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.20;
        requiredAddons[] = {
            "A3_Air_F",
            "A3_Air_F_Beta",
            "A3_Air_F_Beta_Heli_Attack_01",
            "A3_Air_F_Beta_Heli_Attack_02",
            "A3_Air_F_Beta_Heli_Transport_01",
            "A3_Air_F_EPB_Heli_Light_03",
            "A3_Air_F_EPC_Plane_CAS_01",
            "A3_Air_F_EPC_Plane_CAS_02",
            "A3_Air_F_Exp",
            "A3_Air_F_Exp_Plane_Civil_01",
            "A3_Air_F_Exp_UAV_03",
            "A3_Air_F_Exp_VTOL_01",
            "A3_Air_F_Exp_VTOL_02",
            "A3_Air_F_Gamma_Plane_Fighter_03",
            "A3_Air_F_Heli",
            "A3_Air_F_Heli_Light_01",
            "A3_Air_F_Heli_Light_02",
            "A3_Air_F_Jets_Plane_Fighter_01",
            "A3_Air_F_Jets_Plane_Fighter_02",
            "A3_Air_F_Jets_Plane_Fighter_04",
            "A3_Air_F_Jets_UAV_05",
            "A3_Air_F_Orange",
            "fdelta_main",
        };
        skipWhenMissingDependencies = 0;

        units[] = {};
    };
};

class CfgVehicles {
    class Helicopter;
    class Plane;
    class Plane_base_F : Plane {
        class Components;
    };
    class Helicopter_Base_F : Helicopter {
        class Components;
    };
    class Helicopter_Base_H;
    class Heli_Transport_01_base_F : Helicopter_Base_H {
        class Components;
    };
    // UH-80 Stub Wings
    class Heli_Transport_01_pylons_base_F : Heli_Transport_01_base_F {
        class Components : Components {
            class TransportPylonsComponent {
                class pylons {
                    class pylon1 {
                        hardpoints[] = {
                            "B_BOMB_PYLON",
                            "B_FUELTANK_HELI",
                            "SCALPEL_1RND_EJECTOR",
                            "B_ASRRAM_EJECTOR",
                            "DAR",
                            "DAGRM",
                            "B_SHIEKER",
                            "20MM_TWIN_CANNON",
                            "CANNON_PODS_RF",
                            "CUP_NATO_HELO_UH60",
                            "CUP_NATO_HELO_LARGE",
                            "TITAN_NLOS_2RND",
                            "B_SIDEARM",
                            "RHS_HP_LONGBOW_RACK",
                            "RHS_HP_FFAR_ARMY",
                            "RHS_HP_AIM9_HELI_ARMY",
                            "RHS_HP_ATAS_AH64",
                            "vn_b_rocket_pylon_uh1c_01",
                        };
                    };
                    class pylon2 : pylon1 {
                        hardpoints[] = {
                            "B_BOMB_PYLON",
                            "B_FUELTANK_HELI",
                            "SCALPEL_1RND_EJECTOR",
                            "B_ASRRAM_EJECTOR",
                            "DAR",
                            "DAGRM",
                            "B_SHIEKER",
                            "20MM_TWIN_CANNON",
                            "CANNON_PODS_RF",
                            "CUP_NATO_HELO_UH60",
                            "CUP_NATO_HELO_LARGE",
                            "TITAN_NLOS_2RND",
                            "B_SIDEARM",
                            "RHS_HP_MELB_L",
                            "RHS_HP_LONGBOW_RACK",
                            "RHS_HP_FFAR_ARMY",
                            "RHS_HP_AIM9_HELI_ARMY",
                            "RHS_HP_ATAS_AH64",
                            "vn_b_rocket_pylon_uh1c_01",
                        };
                    };
                    class pylon3 : pylon2 {
                        hardpoints[] = {
                            "B_BOMB_PYLON",
                            "B_FUELTANK_HELI",
                            "SCALPEL_1RND_EJECTOR",
                            "B_ASRRAM_EJECTOR",
                            "DAR",
                            "DAGRM",
                            "B_SHIEKER",
                            "20MM_TWIN_CANNON",
                            "CANNON_PODS_RF",
                            "CUP_NATO_HELO_UH60",
                            "CUP_NATO_HELO_LARGE",
                            "TITAN_NLOS_2RND",
                            "B_SIDEARM",
                            "RHS_HP_MELB_R",
                            "RHS_HP_LONGBOW_RACK",
                            "RHS_HP_FFAR_ARMY",
                            "RHS_HP_AIM9_HELI_ARMY",
                            "RHS_HP_ATAS_AH64",
                            "vn_b_rocket_pylon_uh1c_01",
                        };
                    };
                    class pylon4 : pylon1 {

                    };
                };
            };
        };
    };
    class Heli_Light_01_base_F;
    class Heli_Light_01_armed_base_F : Heli_Light_01_base_F {
        class Components;
    };
    class Heli_Light_01_dynamicLoadout_base_F : Heli_Light_01_armed_base_F {
        class Components : Components {
            class TransportPylonsComponent {
                class pylons {
                    class PylonLeft1 {
                        priority=5;
                        hardpoints[] = {
                            "DAR",
                            "DAGR",
                            "B_SHIEKER",
                            "SCALPEL_1RND_EJECTOR",
                            "B_ASRRAM_EJECTOR",
                            "CANNON_PODS_RF",
                            "CUP_NATO_HELO_SMALL",
                            "CUP_NATO_HELO_AH6_RIGHT",
                            "B_SIDEARM",
                            "RHS_HP_MELB",
                            "RHS_HP_FFAR_ARMY",
                            "RHS_HP_AIM9_HELI_ARMY",
                            "RHS_HP_ATAS_AH64",
                            "vn_b_rocket_pylon_uh1c_01",
                        };
                    };
                    class PylonRight1 : PylonLeft1 {
                        priority=5;
                        hardpoints[] = {
                            "DAR",
                            "DAGR",
                            "B_SHIEKER",
                            "SCALPEL_1RND_EJECTOR",
                            "B_ASRRAM_EJECTOR",
                            "CANNON_PODS_RF",
                            "CUP_NATO_HELO_SMALL",
                            "CUP_NATO_HELO_AH6_Left",
                            "B_SIDEARM",
                            "RHS_HP_MELB",
                            "RHS_HP_FFAR_ARMY",
                            "RHS_HP_AIM9_HELI_ARMY",
                            "RHS_HP_ATAS_AH64",
                            "vn_b_rocket_pylon_uh1c_01",
                        };
                    };
                };
            };
        };
    };
    class Heli_light_03_base_F : Helicopter_Base_F {
        class Components;
    };
    class Heli_light_03_dynamicLoadout_base_F : Heli_light_03_base_F {
        class Components : Components {
            class TransportPylonsComponent {
                class pylons {
                    class PylonLeft1 {
                        priority=5;
                        hardpoints[] = {
                            "DAR",
                            "DAGR",
                            "B_SHIEKER",
                            "UNI_SCALPEL",
                            "20MM_TWIN_CANNON",
                            "B_ASRRAM_EJECTOR",
                            "CANNON_PODS_RF",
                            "B_SIDEARM",
                            "RHS_HP_MELB",
                            "RHS_HP_FFAR_ARMY",
                            "RHS_HP_AIM9_HELI_ARMY",
                            "RHS_HP_ATAS_AH64",
                            "CUP_NATO_HELO_SMALL",
                            "vn_b_rocket_pylon_uh1c_01",
                        };
                    };
                    class PylonRight1 : PylonLeft1 {
                        priority=5;
                        hardpoints[] = {
                            "DAR",
                            "DAGR",
                            "B_SHIEKER",
                            "UNI_SCALPEL",
                            "20MM_TWIN_CANNON",
                            "B_ASRRAM_EJECTOR",
                            "CANNON_PODS_RF",
                            "B_SIDEARM",
                            "RHS_HP_MELB",
                            "RHS_HP_FFAR_ARMY",
                            "RHS_HP_AIM9_HELI_ARMY",
                            "RHS_HP_ATAS_AH64",
                            "CUP_NATO_HELO_SMALL",
                            "vn_b_rocket_pylon_uh1c_01",
                        };
                    };
                };
            };
        };
    };
    class Heli_Light_02_base_F : Helicopter_Base_H {
        class Components;
    };
    class Heli_Light_02_dynamicLoadout_base_F : Heli_Light_02_base_F {
        class Components : Components {
            class TransportPylonsComponent {
                class pylons {
                    class PylonLeft1 {
                        priority=5;
                        hardpoints[] = {
                            "O_SKYFIRE",
                            "DAGR",
                            "DAR",
                            "I_ORCA_RIGHT_PYLON",
                            "20MM_TWIN_CANNON",
                            "SCALPEL_1RND_EJECTOR",
                            "B_ASRRAM_EJECTOR",
                            "O_MISSILE_PYLON",
                            "O_BOMB_PYLON_HELI",
                            "CUP_EAST_HELO_LARGE",
                            "RHS_HP_KAB250",
                            "RHS_HP_FAB500",
                            "RHS_HP_UB16",
                            "RHS_HP_UB32",
                            "RHS_HP_B8M1",
                            "RHS_HP_B13L",
                            "RHS_HP_APU68M3_S24",
                            "RHS_HP_O25L",
                            "RHS_HP_R60",
                            "RHS_HP_R73",
                            "RHS_HP_UPK23_KA52",
                            "vn_o_missile_pylon_mi2_01",
                        };
                    };
                    class PylonRight1 : PylonLeft1 {
                        priority=5;
                        hardpoints[] = {
                            "O_SKYFIRE","DAGR","DAR",
                            "20MM_TWIN_CANNON",
                            "SCALPEL_1RND_EJECTOR",
                            "B_ASRRAM_EJECTOR",
                            "O_MISSILE_PYLON",
                            "O_BOMB_PYLON_HELI",
                            "CUP_EAST_HELO_LARGE",
                            "RHS_HP_KAB250",
                            "RHS_HP_FAB500",
                            "RHS_HP_UB16",
                            "RHS_HP_UB32",
                            "RHS_HP_B8M1",
                            "RHS_HP_B13L",
                            "RHS_HP_APU68M3_S24",
                            "RHS_HP_O25L",
                            "RHS_HP_R60",
                            "RHS_HP_R73",
                            "RHS_HP_UPK23_KA52",
                            "vn_o_missile_pylon_mi2_01",
                        };
                    };
                };
            };
        };
    };
    class Heli_Attack_01_base_F : Helicopter_Base_F {
        class Components;
    };
    class Heli_Attack_01_dynamicLoadout_base_F : Heli_Attack_01_base_F {
        class Components : Components {
            class TransportPylonsComponent {
                class pylons {
                    class PylonLeft1 {
                        hardpoints[] = {
                            "SCALPEL_1RND",
                            "B_ASRAAM",
                            "DAR",
                            "DAGR",
                            "B_SHIEKER",
                            "TITAN_NLOS_1RND",
                            "B_AIM9",
                            "vn_b_rocket_pylon_uh1c_01",
                        };
                    };
                    class PylonLeft2 : PylonLeft1 {
                        hardpoints[] = {
                            "SCALPEL_1RND",
                            "B_ASRAAM",
                            "TITAN_NLOS_1RND",
                            "B_AIM9",
                        };
                    };
                    class PylonLeft3 : PylonLeft1 {
                        hardpoints[] = {
                            "SCALPEL_1RND",
                            "B_ASRAAM",
                            "DAR",
                            "DAGR",
                            "B_SHIEKER",
                            "B_AIM9",
                            "TITAN_NLOS_1RND",
                            "WEAPON_PODS_RF",
                            "vn_b_rocket_pylon_uh1c_01",
                        };
                    };
                    class PylonRight1 : PylonLeft1 {
                        hardpoints[] = {
                            "SCALPEL_1RND",
                            "B_ASRAAM",
                            "DAR",
                            "DAGR",
                            "TITAN_NLOS_1RND",
                            "B_AIM9",
                            "vn_b_rocket_pylon_uh1c_01",
                        };
                    };
                    class PylonRight2 : PylonLeft2 {
                        hardpoints[] = {
                            "SCALPEL_1RND",
                            "B_ASRAAM",
                            "TITAN_NLOS_1RND",
                            "B_AIM9",
                        };
                    };
                    class PylonRight3 : PylonLeft3 {
                        hardpoints[] = {
                            "SCALPEL_1RND",
                            "B_ASRAAM",
                            "DAR",
                            "DAGR",
                            "B_SHIEKER",
                            "TITAN_NLOS_1RND",
                            "B_AIM9",
                            "WEAPON_PODS_RF",
                            "vn_b_rocket_pylon_uh1c_01",
                        };
                    };
                };
            };
        };
    };
    class Heli_Attack_01_pylons_dynamicLoadout_base_F : Heli_Attack_01_dynamicLoadout_base_F {
        class Components : Components {
            class TransportPylonsComponent : TransportPylonsComponent {
                class pylons : pylons {
                    class PylonExternalLeft {
                        hardpoints[] = {
                            "UNI_SCALPEL",
                            "B_ASRRAM_EJECTOR",
                            "DAR",
                            "DAGR",
                            "B_SHIEKER",
                            "CUP_NATO_HELO_LARGE",
                            "WEAPON_PODS_RF",
                            "TITAN_NLOS_2RND",
                            "B_SIDEARM",
                            "RHS_HP_LONGBOW_RACK",
                            "RHS_HP_FFAR_ARMY",
                            "RHS_HP_AIM9_HELI_ARMY",
                            "RHS_HP_ATAS_AH64",
                            "vn_b_rocket_pylon_uh1c_01",
                        };
                    };
                    class PylonExternalRight : PylonExternalLeft {
                        hardpoints[] = {
                            "UNI_SCALPEL",
                            "B_ASRRAM_EJECTOR",
                            "DAR",
                            "DAGR",
                            "B_SHIEKER",
                            "CUP_NATO_HELO_LARGE",
                            "WEAPON_PODS_RF",
                            "TITAN_NLOS_2RND",
                            "B_SIDEARM",
                            "RHS_HP_LONGBOW_RACK",
                            "RHS_HP_FFAR_ARMY",
                            "RHS_HP_AIM9_HELI_ARMY",
                            "RHS_HP_ATAS_AH64",
                            "vn_b_rocket_pylon_uh1c_01",
                        };
                    };
                };
            };
        };
    };
    class Heli_Attack_02_base_F : Helicopter_Base_H {
        class Components;
    };
    class Heli_Attack_02_dynamicLoadout_base_F : Heli_Attack_02_base_F {
        class Components : Components {
            class TransportPylonsComponent {
                class pylons {
                    class PylonLeft1 {
                        hardpoints[] = {
                            "O_MISSILE_PYLON",
                            "O_BOMB_PYLON_HELI",
                            "UNI_SCALPEL",
                            "20MM_TWIN_CANNON",
                            "CUP_EAST_HELO_LARGE",
                            "RHS_HP_KH25_APU68_MIG29",
                            "RHS_HP_KH29_AKU58_MIG29",
                            "RHS_HP_FAB100_BD3_UMK2A",
                            "RHS_HP_FAB100_MBD3_U4T",
                            "RHS_HP_FAB250_BD3_UMK2A",
                            "RHS_HP_FAB500_BD3_UMK2A",
                            "RHS_HP_KAB500_BD3_UMK2A",
                            "RHS_HP_KMGU2_BD3_UMK2A",
                            "RHS_HP_BD3_USK_A_O25L",
                            "RHS_HP_APU68_BD3_UMK2A",
                            "RHS_HP_B13L_BD3_UMK2A",
                            "RHS_HP_B8M1_BD3_UMK2A",
                            "RHS_HP_UB16_BD3_UMK2A",
                            "RHS_HP_UB32_BD3_UMK2A",
                            "RHS_HP_R77M_AKU170_MIG29",
                            "RHS_HP_R77_AKU170_MIG29",
                            "RHS_HP_R27_APU470",
                            "RHS_HP_R60_APU60",
                            "RHS_HP_R73_APU73",
                            "RHS_HP_UPK23_KA52",
                            "RHS_HP_APU6_9m127_KA52",
                            "vn_o_missile_pylon_mi2_01",
                        };
                    };
                    class PylonLeft2 : PylonLeft1 {
                        hardpoints[] = {
                            "O_MISSILE_PYLON",
                            "O_BOMB_PYLON_HELI",
                            "UNI_SCALPEL",
                            "20MM_TWIN_CANNON",
                            "CUP_EAST_HELO_LARGE",
                            "RHS_HP_KH25_APU68_MIG29",
                            "RHS_HP_KH29_AKU58_MIG29",
                            "RHS_HP_FAB100_BD3_UMK2A",
                            "RHS_HP_FAB100_MBD3_U4T",
                            "RHS_HP_FAB250_BD3_UMK2A",
                            "RHS_HP_FAB500_BD3_UMK2A",
                            "RHS_HP_KAB500_BD3_UMK2A",
                            "RHS_HP_KMGU2_BD3_UMK2A",
                            "RHS_HP_BD3_USK_A_O25L",
                            "RHS_HP_APU68_BD3_UMK2A",
                            "RHS_HP_B13L_BD3_UMK2A",
                            "RHS_HP_B8M1_BD3_UMK2A",
                            "RHS_HP_UB16_BD3_UMK2A",
                            "RHS_HP_UB32_BD3_UMK2A",
                            "RHS_HP_R77M_AKU170_MIG29",
                            "RHS_HP_R77_AKU170_MIG29",
                            "RHS_HP_R27_APU470",
                            "RHS_HP_R60_APU60",
                            "RHS_HP_R73_APU73",
                            "RHS_HP_UPK23_KA52",
                            "RHS_HP_APU6_9m127_KA52",
                            "vn_o_missile_pylon_mi2_01",
                        };
                    };
                    class PylonRight1 : PylonLeft1 {
                        hardpoints[] = {
                            "O_MISSILE_PYLON",
                            "O_BOMB_PYLON_HELI",
                            "UNI_SCALPEL",
                            "20MM_TWIN_CANNON",
                            "CUP_EAST_HELO_LARGE",
                            "RHS_HP_KH25_APU68_MIG29",
                            "RHS_HP_KH29_AKU58_MIG29",
                            "RHS_HP_FAB100_BD3_UMK2A",
                            "RHS_HP_FAB100_MBD3_U4T",
                            "RHS_HP_FAB250_BD3_UMK2A",
                            "RHS_HP_FAB500_BD3_UMK2A",
                            "RHS_HP_KAB500_BD3_UMK2A",
                            "RHS_HP_KMGU2_BD3_UMK2A",
                            "RHS_HP_BD3_USK_A_O25L",
                            "RHS_HP_APU68_BD3_UMK2A",
                            "RHS_HP_B13L_BD3_UMK2A",
                            "RHS_HP_B8M1_BD3_UMK2A",
                            "RHS_HP_UB16_BD3_UMK2A",
                            "RHS_HP_UB32_BD3_UMK2A",
                            "RHS_HP_R77M_AKU170_MIG29",
                            "RHS_HP_R77_AKU170_MIG29",
                            "RHS_HP_R27_APU470",
                            "RHS_HP_R60_APU60",
                            "RHS_HP_R73_APU73",
                            "RHS_HP_UPK23_KA52",
                            "RHS_HP_APU6_9m127_KA52",
                            "vn_o_missile_pylon_mi2_01",
                        };
                    };
                    class PylonRight2 : PylonLeft2 {
                        hardpoints[] = {
                            "O_MISSILE_PYLON",
                            "O_BOMB_PYLON_HELI",
                            "UNI_SCALPEL",
                            "20MM_TWIN_CANNON",
                            "CUP_EAST_HELO_LARGE",
                            "RHS_HP_KH25_APU68_MIG29",
                            "RHS_HP_KH29_AKU58_MIG29",
                            "RHS_HP_FAB100_BD3_UMK2A",
                            "RHS_HP_FAB100_MBD3_U4T",
                            "RHS_HP_FAB250_BD3_UMK2A",
                            "RHS_HP_FAB500_BD3_UMK2A",
                            "RHS_HP_KAB500_BD3_UMK2A",
                            "RHS_HP_KMGU2_BD3_UMK2A",
                            "RHS_HP_BD3_USK_A_O25L",
                            "RHS_HP_APU68_BD3_UMK2A",
                            "RHS_HP_B13L_BD3_UMK2A",
                            "RHS_HP_B8M1_BD3_UMK2A",
                            "RHS_HP_UB16_BD3_UMK2A",
                            "RHS_HP_UB32_BD3_UMK2A",
                            "RHS_HP_R77M_AKU170_MIG29",
                            "RHS_HP_R77_AKU170_MIG29",
                            "RHS_HP_R27_APU470",
                            "RHS_HP_R60_APU60",
                            "RHS_HP_R73_APU73",
                            "RHS_HP_UPK23_KA52",
                            "RHS_HP_APU6_9m127_KA52",
                            "vn_o_missile_pylon_mi2_01",
                        };
                    };
                };
            };
        };
    };
    class UAV_03_base_F : Helicopter_Base_F {
        class Components : Components {};
    };
    class UAV_03_dynamicLoadout_base_F : UAV_03_base_F {
        class Components : Components {
            class TransportPylonsComponent {
                class Pylons {
                    class Pylons1 {
                        hardpoints[] = {
                            "DAR",
                            "DAGR",
                            "B_SHIEKER",
                            "UNI_SCALPEL",
                            "20MM_TWIN_CANNON",
                            "B_AIM9",
                            "CUP_M789",
                            "CUP_NATO_HELO_SMALL",
                            "RHS_HP_LONGBOW_RACK",
                            "RHS_HP_FFAR_ARMY",
                            "RHS_HP_AIM9_HELI_ARMY",
                            "RHS_HP_ATAS_AH64",
                        };
                    };
                    class Pylons2 : Pylons1 {

                    };
                    class Pylons3 : Pylons2 {

                    };
                    class Pylons4 : Pylons1 {

                    };
                };
            };
        };
    };
    class Plane_CAS_01_base_F : Plane_base_F {
        class Components;
    };
    class Plane_CAS_01_dynamicLoadout_base_F : Plane_CAS_01_base_F {
        class Components : Components {
            class TransportPylonsComponent {
                class Pylons {
                    class Pylons1 {
                        hardpoints[] = {
                            "B_MISSILE_PYLON",
                            "B_BOMB_PYLON",
                            "B_BIM9X_RAIL",
                            "B_BIM9X_DUAL_RAIL",
                            "RHS_HP_AIM9_2x",
                        };
                    };
                    class Pylons10 : Pylons1 {};
                    class Pylons2 : Pylons1 {
                        hardpoints[] = {
                            "B_MISSILE_PYLON",
                            "B_BOMB_PYLON",
                            "RHS_HP_FFAR_USAF",
                            "RHS_HP_FFAR_USAF_3x",
                            "RHS_HP_FFAR_HEAVY_USAF",
                            "RHS_HP_Hydra_USAF",
                            "RHS_HP_Hydra_USAF_3x",
                            "RHS_HP_AGM65",
                            "RHS_HP_BOMB_500",
                            "RHS_HP_LGB_500",
                            "RHS_HP_JDAM_500",
                            "vn_b_rocket_pylon_f4_in",
                        };
                    };
                    class Pylons3 : Pylons1 {
                        hardpoints[] = {
                            "B_MISSILE_PYLON",
                            "B_BOMB_PYLON",
                            "RHS_HP_FFAR_USAF",
                            "RHS_HP_FFAR_USAF_3x",
                            "RHS_HP_FFAR_HEAVY_USAF",
                            "RHS_HP_Hydra_USAF",
                            "RHS_HP_Hydra_USAF_3x",
                            "RHS_HP_AGM65_3x",
                            "RHS_HP_BOMB_500",
                            "RHS_HP_LGB_500",
                            "RHS_HP_JDAM_500",
                            "RHS_HP_BOMB_500_3x",
                            "RHS_HP_LGB_500_3x",
                            "RHS_HP_JDAM_500_3x",
                            "vn_b_rocket_pylon_f4_in",
                        };
                    };
                    class Pylons4 : Pylons1 {
                        hardpoints[] = {
                            "B_MISSILE_PYLON",
                            "B_BOMB_PYLON",
                            "B_SDB_QUAD_RAIL",
                            "B_GBU12_DUAL_RAIL",
                            "RHS_HP_FFAR_USAF",
                            "RHS_HP_FFAR_USAF_3x",
                            "RHS_HP_FFAR_HEAVY_USAF",
                            "RHS_HP_FFAR_HEAVY_USAF_3x",
                            "RHS_HP_Hydra_USAF",
                            "RHS_HP_Hydra_USAF_3x",
                            "RHS_HP_AGM65",
                            "RHS_HP_BOMB_500",
                            "RHS_HP_LGB_500",
                            "RHS_HP_JDAM_500",
                            "RHS_HP_BOMB_500_3x",
                            "RHS_HP_LGB_500_3x",
                            "RHS_HP_JDAM_500_3x",
                            "vn_b_rocket_pylon_f4_in",
                        };
                    };
                    class Pylons5 : Pylons1 {
                        hardpoints[] = {
                            "B_MISSILE_PYLON",
                            "B_BOMB_PYLON",
                            "B_SDB_QUAD_RAIL",
                            "B_GBU12_DUAL_RAIL",
                            "RHS_HP_BOMB_500",
                            "RHS_HP_LGB_500",
                            "RHS_HP_JDAM_500",
                        };
                    };
                    class Pylons6 : Pylons5 {};
                    class Pylons7 : Pylons4 {};
                    class Pylons8 : Pylons3 {};
                    class Pylons9 : Pylons2 {};
                };
            };
        };
    };
    class B_Plane_CAS_01_dynamicLoadout_F : Plane_CAS_01_dynamicLoadout_base_F {};
    class B_Plane_CAS_01_Cluster_F : B_Plane_CAS_01_dynamicLoadout_F {
        class Components : Components {
            class TransportPylonsComponent : TransportPylonsComponent {
                class Pylons : Pylons {
                    class Pylons1 : Pylons1 {
                        hardpoints[] = {
                            "B_MISSILE_PYLON",
                            "B_BOMB_PYLON",
                            "B_BIM9X_RAIL",
                            "B_BIM9X_DUAL_RAIL",
                            "RHS_HP_AIM9_2x",
                        };
                    };
                    class Pylons10 : Pylons10 {};
                    class Pylons2 : Pylons2 {
                        hardpoints[] = {
                            "B_MISSILE_PYLON",
                            "B_BOMB_PYLON",
                            "RHS_HP_FFAR_USAF",
                            "RHS_HP_FFAR_USAF_3x",
                            "RHS_HP_FFAR_HEAVY_USAF",
                            "RHS_HP_Hydra_USAF",
                            "RHS_HP_Hydra_USAF_3x",
                            "RHS_HP_AGM65",
                            "RHS_HP_BOMB_500",
                            "RHS_HP_LGB_500",
                            "RHS_HP_JDAM_500",
                            "vn_b_rocket_pylon_f4_in",
                        };
                    };
                    class Pylons3 : Pylons3 {
                        hardpoints[] = {
                            "B_MISSILE_PYLON",
                            "B_BOMB_PYLON",
                            "RHS_HP_FFAR_USAF",
                            "RHS_HP_FFAR_USAF_3x",
                            "RHS_HP_FFAR_HEAVY_USAF",
                            "RHS_HP_Hydra_USAF",
                            "RHS_HP_Hydra_USAF_3x",
                            "RHS_HP_AGM65_3x",
                            "RHS_HP_BOMB_500",
                            "RHS_HP_LGB_500",
                            "RHS_HP_JDAM_500",
                            "RHS_HP_BOMB_500_3x",
                            "RHS_HP_LGB_500_3x",
                            "RHS_HP_JDAM_500_3x",
                            "vn_b_rocket_pylon_f4_in",
                        };
                    };
                    class Pylons4 : Pylons4 {
                        hardpoints[] = {
                            "B_MISSILE_PYLON",
                            "B_BOMB_PYLON",
                            "B_SDB_QUAD_RAIL",
                            "B_GBU12_DUAL_RAIL",
                            "RHS_HP_FFAR_USAF",
                            "RHS_HP_FFAR_USAF_3x",
                            "RHS_HP_FFAR_HEAVY_USAF",
                            "RHS_HP_FFAR_HEAVY_USAF_3x",
                            "RHS_HP_Hydra_USAF",
                            "RHS_HP_Hydra_USAF_3x",
                            "RHS_HP_AGM65",
                            "RHS_HP_BOMB_500",
                            "RHS_HP_LGB_500",
                            "RHS_HP_JDAM_500",
                            "RHS_HP_BOMB_500_3x",
                            "RHS_HP_LGB_500_3x",
                            "RHS_HP_JDAM_500_3x",
                            "vn_b_rocket_pylon_f4_in",
                        };
                    };
                    class Pylons5 : Pylons5 {
                        hardpoints[] = {
                            "B_MISSILE_PYLON",
                            "B_BOMB_PYLON",
                            "B_SDB_QUAD_RAIL",
                            "B_GBU12_DUAL_RAIL",
                            "RHS_HP_BOMB_500",
                            "RHS_HP_LGB_500",
                            "RHS_HP_JDAM_500",
                        };
                    };
                    class Pylons6 : Pylons6 {};
                    class Pylons7 : Pylons7 {};
                    class Pylons8 : Pylons8 {};
                    class Pylons9 : Pylons9 {};
                };
            };
        };
    };
    class Plane_CAS_02_base_F : Plane_base_F {
        class Components : Components {};
    };
    class Plane_CAS_02_dynamicLoadout_base_F : Plane_CAS_02_base_F {
        class Components : Components {
            class TransportPylonsComponent {
                class Pylons {
                    class Pylons1 {
                        hardpoints[] = {
                            "O_MISSILE_PYLON",
                            "O_R73",
                            "UNI_SCALPEL",
                            "RHS_HP_R60",
                            "RHS_HP_R73",
                        };
                    };
                    class Pylons10 : Pylons1 {};
                    class Pylons2 : Pylons1 {
                        hardpoints[] = {
                            "O_MISSILE_PYLON",
                            "O_R73",
                            "UNI_SCALPEL",
                            "RHS_HP_R60",
                            "RHS_HP_R73",
                            "RHS_HP_UB16",
                            "RHS_HP_UB32",
                            "RHS_HP_B8M1",
                            "RHS_HP_KH25",
                        };
                    };
                    class Pylons3 : Pylons1 {
                        hardpoints[] = {
                            "O_BOMB_PYLON",
                            "O_MISSILE_PYLON",
                            "O_KAB250_BOMB",
                            "O_KH25",
                            "UNI_SCALPEL",
                            "RHS_HP_UB16",
                            "RHS_HP_UB32",
                            "RHS_HP_B8M1",
                            "RHS_HP_B13L1",
                            "RHS_HP_APU68M3_S24",
                            "RHS_HP_O25L",
                            "RHS_HP_KH25",
                            "RHS_HP_KH29",
                            "RHS_HP_Kh38",
                            "RHS_HP_FAB250",
                            "RHS_HP_KAB250",
                            "RHS_HP_FAB500",
                        };
                    };
                    class Pylons4 : Pylons1 {
                        hardpoints[] = {
                            "O_BOMB_PYLON",
                            "O_MISSILE_PYLON",
                            "O_KAB250_BOMB",
                            "O_KH25",
                            "O_KH58",
                            "UNI_SCALPEL",
                            "RHS_HP_UB16",
                            "RHS_HP_UB32",
                            "RHS_HP_B8M1",
                            "RHS_HP_B13L1",
                            "RHS_HP_APU68M3_S24",
                            "RHS_HP_O25L",
                            "RHS_HP_KH25",
                            "RHS_HP_KH29",
                            "RHS_HP_Kh38",
                            "RHS_HP_FAB250",
                            "RHS_HP_KAB250",
                            "RHS_HP_FAB500",
                        };
                    };
                    class Pylons5 : Pylons1 {
                        hardpoints[] = {
                            "O_BOMB_PYLON",
                            "O_MISSILE_PYLON",
                            "O_KAB250_BOMB",
                            "O_KH25",
                            "O_KH58",
                            "UNI_SCALPEL",
                            "RHS_HP_UB16",
                            "RHS_HP_UB32",
                            "RHS_HP_B8M1",
                            "RHS_HP_B13L1",
                            "RHS_HP_APU68M3_S24",
                            "RHS_HP_O25L",
                            "RHS_HP_KH25",
                            "RHS_HP_KH29",
                            "RHS_HP_Kh38",
                            "RHS_HP_FAB250",
                            "RHS_HP_KAB250",
                            "RHS_HP_FAB500",
                        };
                    };
                    class Pylons6 : Pylons5 {};
                    class Pylons7 : Pylons4 {};
                    class Pylons8 : Pylons3 {};
                    class Pylons9 : Pylons2 {};
                };
            };
        };
    };
    class O_Plane_CAS_02_dynamicLoadout_F : Plane_CAS_02_dynamicLoadout_base_F {};
    class O_Plane_CAS_02_Cluster_F : O_Plane_CAS_02_dynamicLoadout_F {
        class Components : Components {
            class TransportPylonsComponent : TransportPylonsComponent {
                class pylons : Pylons {
                    class Pylons1 : Pylons1 {
                        hardpoints[] = {
                            "O_MISSILE_PYLON",
                            "O_R73",
                            "UNI_SCALPEL",
                            "RHS_HP_R60",
                            "RHS_HP_R73",
                        };
                    };
                    class Pylons10 : Pylons10 {};
                    class Pylons2 : Pylons2 {
                        hardpoints[] = {
                            "O_MISSILE_PYLON",
                            "O_R73",
                            "UNI_SCALPEL",
                            "RHS_HP_R60",
                            "RHS_HP_R73",
                            "RHS_HP_UB16",
                            "RHS_HP_UB32",
                            "RHS_HP_B8M1",
                            "RHS_HP_KH25",
                        };
                    };
                    class Pylons3 : Pylons3 {
                        hardpoints[] = {
                            "O_BOMB_PYLON",
                            "O_MISSILE_PYLON",
                            "O_KAB250_BOMB",
                            "O_KH25",
                            "UNI_SCALPEL",
                            "RHS_HP_UB16",
                            "RHS_HP_UB32",
                            "RHS_HP_B8M1",
                            "RHS_HP_B13L1",
                            "RHS_HP_APU68M3_S24",
                            "RHS_HP_O25L",
                            "RHS_HP_KH25",
                            "RHS_HP_KH29",
                            "RHS_HP_Kh38",
                            "RHS_HP_FAB250",
                            "RHS_HP_KAB250",
                            "RHS_HP_FAB500",
                        };
                    };
                    class Pylons4 : Pylons4 {
                        hardpoints[] = {
                            "O_BOMB_PYLON",
                            "O_MISSILE_PYLON",
                            "O_KAB250_BOMB",
                            "O_KH25",
                            "O_KH58",
                            "UNI_SCALPEL",
                            "RHS_HP_UB16",
                            "RHS_HP_UB32",
                            "RHS_HP_B8M1",
                            "RHS_HP_B13L1",
                            "RHS_HP_APU68M3_S24",
                            "RHS_HP_O25L",
                            "RHS_HP_KH25",
                            "RHS_HP_KH29",
                            "RHS_HP_Kh38",
                            "RHS_HP_FAB250",
                            "RHS_HP_KAB250",
                            "RHS_HP_FAB500",
                        };
                    };
                    class Pylons5 : Pylons5 {
                        hardpoints[] = {
                            "O_BOMB_PYLON",
                            "O_MISSILE_PYLON",
                            "O_KAB250_BOMB",
                            "O_KH25",
                            "O_KH58",
                            "UNI_SCALPEL",
                            "RHS_HP_UB16",
                            "RHS_HP_UB32",
                            "RHS_HP_B8M1",
                            "RHS_HP_B13L1",
                            "RHS_HP_APU68M3_S24",
                            "RHS_HP_O25L",
                            "RHS_HP_KH25",
                            "RHS_HP_KH29",
                            "RHS_HP_Kh38",
                            "RHS_HP_FAB250",
                            "RHS_HP_KAB250",
                            "RHS_HP_FAB500",
                        };
                    };
                    class Pylons6 : Pylons6 {};
                    class Pylons7 : Pylons7 {};
                    class Pylons8 : Pylons8 {};
                    class Pylons9 : Pylons9 {};
                };
            };
        };
    };
    class Plane_Fighter_01_Base_F : Plane_base_F {
        class Components : Components {
            class TransportPylonsComponent {
                class pylons {
                    class pylon1 {
                        hardpoints[] = {
                            "B_BIM9X_RAIL",
                            "B_BIM9X_DUAL_RAIL",
                            "B_AMRAAM_C_RAIL",
                            "B_AMRAAM_C_DUAL_RAIL",
                            "B_AMRAAM_D_RAIL",
                            "B_AMRAAM_D_DUAL_RAIL",
                            "B_AGM65_RAIL",
                            "B_MISSILE_PYLON",
                            "B_BOMB_PYLON",
                            "B_GBU12",
                            "B_GBU12_DUAL_RAIL",
                            "RHS_HP_AIM9_2x",
                            "RHS_HP_AIM120",
                            "RHS_HP_AGM65_3x",
                            "RHS_HP_BOMB_500",
                            "RHS_HP_LGB_500",
                            "RHS_HP_JDAM_500",
                            "RHS_HP_BOMB_500_3x",
                            "RHS_HP_LGB_500_3x",
                            "RHS_HP_JDAM_500_3x",
                            "vn_b_rocket_pylon_f4_in",
                        };
                    };
                    class pylon2 : pylon1 {

                    };
                    class pylon3 {
                        hardpoints[] = {
                            "B_BIM9X_RAIL",
                            "B_BIM9X_DUAL_RAIL",
                            "B_AMRAAM_C_RAIL",
                            "B_AMRAAM_C_DUAL_RAIL",
                            "B_AMRAAM_D_RAIL",
                            "B_AMRAAM_D_DUAL_RAIL",
                            "B_AGM65_RAIL",
                            "B_AGM65_DUAL_RAIL",
                            "B_MISSILE_PYLON",
                            "B_BOMB_PYLON",
                            "B_GBU12",
                            "B_GBU12_DUAL_RAIL",
                            "B_HARM_RAIL",
                            "B_SDB_QUAD_RAIL",
                            "RHS_HP_AIM9_2x",
                            "RHS_HP_AIM120",
                            "RHS_HP_AGM65_3x",
                            "RHS_HP_BOMB_500",
                            "RHS_HP_LGB_500",
                            "RHS_HP_JDAM_500",
                            "RHS_HP_BOMB_500_3x",
                            "RHS_HP_LGB_500_3x",
                            "RHS_HP_JDAM_500_3x",
                            "vn_b_rocket_pylon_f4_in",
                        };
                    };
                    class pylon4 :pylon3 {

                    };
                    class pylonBayCenter1 {
                        hardpoints[] = {
                            "B_AMRAAM_D_INT",
                            "B_HARM_INT",
                            "RHS_HP_aim120_int",

                        };
                    };
                    class pylonBayCenter2 : pylonBayCenter1 {

                    };
                    class pylonBayCenter3 {
                        hardpoints[] = {
                            "B_AMRAAM_D_INT",
                            "B_SDB_QUAD_RAIL",
                            "RHS_HP_aim120_int",
                        };
                    };
                    class pylonBayCenter4 : pylonBayCenter3 {

                    };
                    class pylonBayCenter5 {
                        hardpoints[] = {
                            "B_AMRAAM_D_INT",
                            "B_GBU12",
                            "RHS_HP_aim120_int",
                            "RHS_HP_BOMB_500",
                            "RHS_HP_LGB_500",
                            "RHS_HP_JDAM_500",
                        };
                    };
                    class pylonBayCenter6 : pylonBayCenter5 {

                    };
                    class pylonBayRight1 {
                        hardpoints[] = {
                            "B_BIM9X",
                            "RHS_HP_AIM9_int",

                        };
                    };
                    class pylonBayLeft1 : pylonBayRight1 {

                    };
                };
            };
        };
    };
    class B_Plane_Fighter_01_Stealth_F : Plane_Fighter_01_Base_F {
        class Components : Components {
            class TransportPylonsComponent {
                class pylons {
                    class pylonBayCenter1 {
                        hardpoints[] = {
                            "B_AMRAAM_D_INT",
                            "B_HARM_INT",
                            "RHS_HP_aim120_int",

                        };
                    };
                    class pylonBayCenter2 : pylonBayCenter1 {

                    };
                    class pylonBayCenter3 {
                        hardpoints[] = {
                            "B_AMRAAM_D_INT",
                            "B_SDB_QUAD_RAIL",
                            "RHS_HP_aim120_int",
                        };
                    };
                    class pylonBayCenter4 : pylonBayCenter3 {

                    };
                    class pylonBayCenter5 {
                        hardpoints[] = {
                            "B_AMRAAM_D_INT",
                            "B_GBU12",
                            "RHS_HP_aim120_int",
                            "RHS_HP_BOMB_500",
                            "RHS_HP_LGB_500",
                            "RHS_HP_JDAM_500",
                        };
                    };
                    class pylonBayCenter6 : pylonBayCenter5 {

                    };
                    class pylonBayRight1 {
                        hardpoints[] = {
                            "B_BIM9X",
                            "RHS_HP_AIM9_int",

                        };
                    };
                    class pylonBayLeft1 : pylonBayRight1 {

                    };
                };
            };
        };
    };
    class Plane_Fighter_02_Base_F : Plane_base_F {
        class Components : Components {
            class TransportPylonsComponent {
              class pylons
              {
                    class pylonBayCenter1 {
                        hardpoints[] = {
                            "O_R77_INT",
                            "RHS_HP_R77",
                            "RHS_HP_R77M",
                        };
                    };
                    class pylonBayCenter2 : pylonBayCenter1 {

                    };
                    class pylonBayCenter3 {
                        hardpoints[] = {
                            "O_R77_INT",
                            "O_KH25_INT",
                            "O_KAB250_BOMB",
                            "O_KH58_INT",
                            "RHS_HP_KAB250_INT",
                            "RHS_HP_Kh38_INT",
                        };
                    };
                    class pylonBayRight1 {
                        hardpoints[] = {
                           "O_R73",
                           "RHS_HP_R74M2_int",

                        };
                    };
                    class pylonBayRight2 {
                        hardpoints[] = {
                            "O_R77",
                            "RHS_HP_R77",
                            "RHS_HP_R77M",

                        };
                    };
                    class pylonBayLeft1 : pylonBayRight1 {

                    };
                    class pylonBayLeft2 : pylonBayRight2 {

                    };
                    class pylons1 {
                        hardpoints[] = {
                         "O_R73",
                         "O_R77",
                         "O_MISSILE_PYLON",
                         "RHS_HP_R77M",
                         "RHS_HP_R77",
                         "RHS_HP_R60",
                         "RHS_HP_R73",
                         "RHS_HP_R74",
                        };
                    };
                    class pylons2 : pylons1 {

                    };
                    class pylons3 {
                        hardpoints[] = {
                            "O_R73",
                            "O_R77",
                            "O_KH25",
                            "O_KAB250_BOMB",
                            "O_BOMB_PYLON",
                            "O_MISSILE_PYLON",
                            "RHS_HP_R27",
                            "RHS_HP_R77M",
                            "RHS_HP_R77",
                            "RHS_HP_R60",
                            "RHS_HP_R73",
                            "RHS_HP_R74",
                            "RHS_HP_R74M2",
                            "RHS_HP_KAB250",
                            "RHS_HP_FAB500",
                            "RHS_HP_UB16",
                            "RHS_HP_UB32",
                            "RHS_HP_B8M1",
                            "RHS_HP_B13L",
                            "RHS_HP_APU68M3_S24",
                            "RHS_HP_O25L",
                            "RHS_HP_KH25",
                            "RHS_HP_KH29",
                            "RHS_HP_Kh38",
                        };
                    };
                    class pylons4 : pylons3 {

                    };
                    class pylons5 {
                        hardpoints[] = {
                            "O_R73",
                            "O_R77",
                            "O_KH25",
                            "O_KAB250_BOMB",
                            "O_BOMB_PYLON",
                            "O_KH58",
                            "O_MISSILE_PYLON",
                            "RHS_HP_R27",
                            "RHS_HP_R77M",
                            "RHS_HP_R77",
                            "RHS_HP_R60",
                            "RHS_HP_R73",
                            "RHS_HP_R74",
                            "RHS_HP_R74M2",
                            "RHS_HP_KAB250",
                            "RHS_HP_FAB500",
                            "RHS_HP_UB16",
                            "RHS_HP_UB32",
                            "RHS_HP_B8M1",
                            "RHS_HP_B13L",
                            "RHS_HP_APU68M3_S24",
                            "RHS_HP_O25L",
                            "RHS_HP_KH25",
                            "RHS_HP_KH29",
                            "RHS_HP_Kh38",
                        };
                    };
                    class pylons6 : pylons5 {

                    };
              };
            };
        };
    };
    class O_Plane_Fighter_02_Stealth_F : Plane_Fighter_02_Base_F {
        class Components : Components {
            class TransportPylonsComponent {
                class pylons {
                    class pylonBayCenter1 {
                        hardpoints[] = {
                            "O_R77_INT",
                            "RHS_HP_R77",
                            "RHS_HP_R77M",
                        };
                    };
                    class pylonBayCenter2 : pylonBayCenter1 {

                    };
                    class pylonBayCenter3 {
                        hardpoints[] = {
                            "O_R77_INT",
                            "O_KH25_INT",
                            "O_KAB250_BOMB",
                            "O_KH58_INT",
                            "RHS_HP_KAB250_INT",
                            "RHS_HP_Kh38_INT",
                        };
                    };
                    class pylonBayRight1 {
                        hardpoints[] = {
                           "O_R73",
                           "RHS_HP_R74M2_int",

                        };
                    };
                    class pylonBayRight2 {
                        hardpoints[] = {
                            "O_R77",
                            "RHS_HP_R77",
                            "RHS_HP_R77M",

                        };
                    };
                    class pylonBayLeft1 : pylonBayRight1 {

                    };
                    class pylonBayLeft2 : pylonBayRight2 {

                    };
                };
            };
        };
    };
    class Plane_Fighter_03_base_F : Plane_base_F {
        class Components;
    };
    class Plane_Fighter_03_dynamicLoadout_base_F : Plane_Fighter_03_base_F {
        class Components : Components {
            class TransportPylonsComponent {
                class pylons {
                    class pylons1 {
                        hardpoints[] =
                            {
                                "B_ZEPHYR",
                                "B_MISSILE_PYLON",
                                "I_BIM9X_RAIL",
                                "RHS_HP_AIM9",
                                "RHS_HP_AIM120",
                            };
                    };
                    class pylons2 : pylons1 {
                        hardpoints[] =
                            {
                                "B_MISSILE_PYLON",
                                "B_ZEPHYR",
                                "vn_b_rocket_pylon_f4_out",
                                "B_BOMB_PYLON",
                                "B_SDB_QUAD_RAIL",
                                "I_GBU12_DUAL_RAIL",
                                "I_BIM9X_RAIL",
                                "I_BIM9X_DUAL_RAIL",
                                "I_AMRAAM_C_DUAL_RAIL",
                                "I_AMRAAM_D_DUAL_RAIL",
                                "I_AGM65_RAIL",
                                "I_AGM65_DUAL_RAIL",
                                "I_HARM_RAIL",
                                "RHS_HP_Hydra_USAF",
                                "RHS_HP_Hydra_USAF_3x",
                                "RHS_HP_FFAR_USAF",
                                "RHS_HP_FFAR_HEAVY_USAF",
                                "RHS_HP_FFAR_USAF_3x",
                                "RHS_HP_FFAR_HEAVY_USAF_3x",
                                "RHS_HP_AGM65",
                                "RHS_HP_AIM9",
                                "RHS_HP_AIM120",
                            };
                    };
                    class pylons3 : pylons1 {
                        hardpoints[] =
                            {
                                "B_MISSILE_PYLON",
                                "B_ZEPHYR",
                                "vn_b_rocket_pylon_f4_out",
                                "B_BOMB_PYLON",
                                "B_SDB_QUAD_RAIL",
                                "I_GBU12_DUAL_RAIL",
                                "I_AMRAAM_C_DUAL_RAIL",
                                "I_AMRAAM_D_DUAL_RAIL",
                                "I_AGM65_RAIL",
                                "I_AGM65_DUAL_RAIL",
                                "I_HARM_RAIL",
                                "RHS_HP_Hydra_USAF",
                                "RHS_HP_Hydra_USAF_3x",
                                "RHS_HP_FFAR_USAF",
                                "RHS_HP_FFAR_HEAVY_USAF",
                                "RHS_HP_FFAR_USAF_3x",
                                "RHS_HP_FFAR_HEAVY_USAF_3x",
                                "RHS_HP_AGM65",
                                "RHS_HP_AIM9",
                                "RHS_HP_AIM120",
                            };
                    };
                    class pylons4 : pylons1 {
                        hardpoints[] = {
                            "B_A143_BUZZARD_CENTER_PYLON",
                            "CUP_GSh23",
                            "RHS_HP_UPK23",
                            "vn_b_rocket_pylon_f4_cl",
                        };
                    };
                    class pylons5 : pylons3 {

                    };
                    class pylons6 : pylons2 {

                    };
                    class pylons7 : pylons1 {

                    };
                };
            };
        };
    };
    class I_Plane_Fighter_03_dynamicLoadout_F : Plane_Fighter_03_dynamicLoadout_base_F {};
    class I_Plane_Fighter_03_Cluster_F : I_Plane_Fighter_03_dynamicLoadout_F {
        class Components : Components {
            class TransportPylonsComponent : TransportPylonsComponent {
                class pylons : pylons {
                    class pylons1 : pylons1 {
                        hardpoints[] =
                            {
                                "B_ZEPHYR",
                                "B_MISSILE_PYLON",
                                "I_BIM9X_RAIL",
                                "RHS_HP_AIM9",
                                "RHS_HP_AIM120",
                            };
                    };
                    class pylons2 : pylons2 {
                        hardpoints[] =
                            {
                                "B_MISSILE_PYLON",
                                "B_ZEPHYR",
                                "vn_b_rocket_pylon_f4_out",
                                "B_BOMB_PYLON",
                                "B_SDB_QUAD_RAIL",
                                "I_GBU12_DUAL_RAIL",
                                "I_BIM9X_RAIL",
                                "I_BIM9X_DUAL_RAIL",
                                "I_AMRAAM_C_DUAL_RAIL",
                                "I_AMRAAM_D_DUAL_RAIL",
                                "I_AGM65_RAIL",
                                "I_AGM65_DUAL_RAIL",
                                "I_HARM_RAIL",
                                "RHS_HP_Hydra_USAF",
                                "RHS_HP_Hydra_USAF_3x",
                                "RHS_HP_FFAR_USAF",
                                "RHS_HP_FFAR_HEAVY_USAF",
                                "RHS_HP_FFAR_USAF_3x",
                                "RHS_HP_FFAR_HEAVY_USAF_3x",
                                "RHS_HP_AGM65",
                                "RHS_HP_AIM9",
                                "RHS_HP_AIM120",
                            };
                    };
                    class pylons3 : pylons3 {
                        hardpoints[] =
                            {
                                "B_MISSILE_PYLON",
                                "B_ZEPHYR",
                                "vn_b_rocket_pylon_f4_out",
                                "B_BOMB_PYLON",
                                "B_SDB_QUAD_RAIL",
                                "I_GBU12_DUAL_RAIL",
                                "I_AMRAAM_C_DUAL_RAIL",
                                "I_AMRAAM_D_DUAL_RAIL",
                                "I_AGM65_RAIL",
                                "I_AGM65_DUAL_RAIL",
                                "I_HARM_RAIL",
                                "RHS_HP_Hydra_USAF",
                                "RHS_HP_Hydra_USAF_3x",
                                "RHS_HP_FFAR_USAF",
                                "RHS_HP_FFAR_HEAVY_USAF",
                                "RHS_HP_FFAR_USAF_3x",
                                "RHS_HP_FFAR_HEAVY_USAF_3x",
                                "RHS_HP_AGM65",
                                "RHS_HP_AIM9",
                                "RHS_HP_AIM120",
                            };
                    };
                    class pylons4 : pylons4 {
                        hardpoints[] = {
                            "B_A143_BUZZARD_CENTER_PYLON",
                            "CUP_GSh23",
                            "RHS_HP_UPK23",
                            "vn_b_rocket_pylon_f4_cl",
                        };
                    };
                    class pylons5 : pylons5 {

                    };
                    class pylons6 : pylons6 {

                    };
                    class pylons7 : pylons7 {

                    };
                };
            };
        };
    };
    class Plane_Fighter_04_Base_F : Plane_base_F {
        class Components : Components {
            class TransportPylonsComponent {
               class pylons {
                    class pylon1 {
                        hardpoints[] = {
                            "B_AIM9",
                            "I_BIM9X",
                            "I_AMRAAM_C_RAIL",
                            "I_AMRAAM_D_RAIL",
                            "RHS_HP_AIM9",
                        };
                    };
                    class pylon2 : pylon1 {

                    };
                    class pylon3 {
                        hardpoints[] = {
                            "I_BIM9X_RAIL",
                            "I_BIM9X_DUAL_RAIL",
                            "I_AMRAAM_C_RAIL",
                            "I_AMRAAM_C_DUAL_RAIL",
                            "I_AMRAAM_D_RAIL",
                            "I_AMRAAM_D_DUAL_RAIL",
                            "I_AGM65_RAIL",
                            "I_AGM65_DUAL_RAIL",
                            "I_HARM_RAIL",
                            "B_SDB_QUAD_RAIL",
                            "I_GBU12",
                            "I_GBU12_DUAL_RAIL",
                            "B_BOMB_PYLON",
                            "B_MISSILE_PYLON",
                            "B_ZEPHYR",
                            "RHS_HP_AIM9_2x",
                            "RHS_HP_AIM120",
                            "RHS_HP_LGB_500",
                            "RHS_HP_LGB_1000",
                            "RHS_HP_FFAR_USAF",
                            "RHS_HP_FFAR_USAF_3x",
                            "RHS_HP_HYDRA_USAF",
                            "RHS_HP_HYDRA_USAF_3x",
                            "RHS_HP_AGM65_3x",
                            "RHS_HP_BOMB_500_3x",
                            "vn_b_rocket_pylon_f4_in",

                        };
                    };
                    class pylon4 : pylon3 {

                    };
                    class pylon5 {
                        hardpoints[] = {
                            "I_BIM9X_RAIL",
                            "I_BIM9X_DUAL_RAIL",
                            "I_AMRAAM_C_RAIL",
                            "I_AMRAAM_C_DUAL_RAIL",
                            "I_AMRAAM_D_RAIL",
                            "I_AMRAAM_D_DUAL_RAIL",
                            "I_AGM65_RAIL",
                            "I_AGM65_DUAL_RAIL",
                            "I_HARM_RAIL",
                            "B_SDB_QUAD_RAIL",
                            "I_GBU12",
                            "I_GBU12_DUAL_RAIL",
                            "B_BOMB_PYLON",
                            "B_MISSILE_PYLON",
                            "B_ZEPHYR",
                            "RHS_HP_AIM9_2x",
                            "RHS_HP_AIM120",
                            "RHS_HP_LGB_500",
                            "RHS_HP_LGB_1000",
                            "RHS_HP_FFAR_USAF",
                            "RHS_HP_FFAR_USAF_3x",
                            "RHS_HP_HYDRA_USAF",
                            "RHS_HP_HYDRA_USAF_3x",
                            "RHS_HP_AGM65_3x",
                            "RHS_HP_BOMB_500_3x",
                            "vn_b_rocket_pylon_f4_in",
                        };
                    };
                    class pylon6 : pylon5 {

                    };
                };
            };
        };
    };
    class VTOL_02_base_F;
    class VTOL_02_infantry_base_F : VTOL_02_base_F {
           class Components;
    };
    class VTOL_02_vehicle_base_F : VTOL_02_base_F {
           class Components;
    };
    class VTOL_02_infantry_dynamicLoadout_base_F : VTOL_02_infantry_base_F {
        class Components : Components {
            class TransportPylonsComponent {
                class Pylons {
                    class PylonRight1 {
                        hardpoints[] = {
                            "O_MISSILE_PYLON",
                            "O_BOMB_PYLON",
                            "UNI_SCALPEL",
                            "O_R73",
                            "O_R77",
                            "O_KAB250_BOMB",
                            "O_KH25",
                            "O_KH58",
                            "DAR",
                            "DAGRM",
                            "UNI_SCALPEL",
                            "RHS_HP_R60",
                            "RHS_HP_R73",
                            "RHS_HP_R77",
                            "RHS_HP_R77M",
                            "RHS_HP_UB16",
                            "RHS_HP_UB32",
                            "RHS_HP_B8M1",
                            "RHS_HP_B13L1",
                            "RHS_HP_APU68M3_S24",
                            "RHS_HP_O25L",
                            "RHS_HP_KH25",
                            "RHS_HP_KH29",
                            "RHS_HP_Kh38",
                            "RHS_HP_FAB250",
                            "RHS_HP_KAB250",
                            "RHS_HP_FAB500",
                        };
                    };
                    class PylonRight2 : PylonRight1 {
                        hardpoints[] = {
                            "O_MISSILE_PYLON",
                            "O_BOMB_PYLON",
                            "UNI_SCALPEL",
                            "O_R73",
                            "O_R77",
                            "O_KAB250_BOMB",
                            "O_KH25",
                            "O_KH58",
                            "DAR",
                            "DAGRM",
                            "UNI_SCALPEL",
                            "RHS_HP_R60",
                            "RHS_HP_R73",
                            "RHS_HP_R77",
                            "RHS_HP_R77M",
                            "RHS_HP_UB16",
                            "RHS_HP_UB32",
                            "RHS_HP_B8M1",
                            "RHS_HP_B13L1",
                            "RHS_HP_APU68M3_S24",
                            "RHS_HP_O25L",
                            "RHS_HP_KH25",
                            "RHS_HP_KH29",
                            "RHS_HP_Kh38",
                            "RHS_HP_FAB250",
                            "RHS_HP_KAB250",
                            "RHS_HP_FAB500",
                        };
                    };
                    class PylonLeft1 : PylonRight1 {

                    };
                    class PylonLeft2 : PylonRight2 {

                    };
                };
            };
        };
    };
    class VTOL_02_vehicle_dynamicLoadout_base_F : VTOL_02_vehicle_base_F {
        class Components : Components {
            class TransportPylonsComponent {
                class Pylons {
                    class PylonLeft1 {
                        hardpoints[] = {
                            "O_MISSILE_PYLON",
                            "O_BOMB_PYLON",
                            "UNI_SCALPEL",
                            "O_R73",
                            "O_R77",
                            "O_KAB250_BOMB",
                            "O_KH25",
                            "O_KH58",
                            "DAR",
                            "DAGRM",
                            "UNI_SCALPEL",
                            "RHS_HP_R60",
                            "RHS_HP_R73",
                            "RHS_HP_R77",
                            "RHS_HP_R77M",
                            "RHS_HP_UB16",
                            "RHS_HP_UB32",
                            "RHS_HP_B8M1",
                            "RHS_HP_B13L1",
                            "RHS_HP_APU68M3_S24",
                            "RHS_HP_O25L",
                            "RHS_HP_KH25",
                            "RHS_HP_KH29",
                            "RHS_HP_Kh38",
                            "RHS_HP_FAB250",
                            "RHS_HP_KAB250",
                            "RHS_HP_FAB500",
                        };
                    };
                    class PylonLeft2 : PylonLeft1 {
                        hardpoints[] = {
                            "O_MISSILE_PYLON",
                            "O_BOMB_PYLON",
                            "UNI_SCALPEL",
                            "O_R73",
                            "O_R77",
                            "O_KAB250_BOMB",
                            "O_KH25",
                            "O_KH58",
                            "DAR",
                            "DAGRM",
                            "UNI_SCALPEL",
                            "RHS_HP_R60",
                            "RHS_HP_R73",
                            "RHS_HP_R77",
                            "RHS_HP_R77M",
                            "RHS_HP_UB16",
                            "RHS_HP_UB32",
                            "RHS_HP_B8M1",
                            "RHS_HP_B13L1",
                            "RHS_HP_APU68M3_S24",
                            "RHS_HP_O25L",
                            "RHS_HP_KH25",
                            "RHS_HP_KH29",
                            "RHS_HP_Kh38",
                            "RHS_HP_FAB250",
                            "RHS_HP_KAB250",
                            "RHS_HP_FAB500",
                        };
                    };
                    class PylonRight1 : PylonLeft1 {

                    };
                    class PylonRight2 : PylonLeft2 {

                    };
                };
            };
        };
    };
};
