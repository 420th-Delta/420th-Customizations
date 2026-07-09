class CfgPatches {
    class fdelta_magwells_hlc {
        name = "420th Customizations - NIArms Weapons Compatibility";
        author = "ol1034, thegamecracks";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.20;
        requiredAddons[] = {
            "hlcweapons_core",
            "hlcweapons_SCAR",
            "hlcweapons_XM8",
        };
        skipWhenMissingDependencies = 1;

        units[] = {};
    };
};

class nia_rifle_gripod_slot;
class nia_rifle_grips_slot : nia_rifle_gripod_slot {
    class compatibleItems {
        rhs_acc_grip_ffg2 = 1;
        rhs_acc_grip_rk2 = 1;
        rhs_acc_grip_rk6 = 1;
        rhsusf_acc_grip1 = 1;
        rhsusf_acc_grip2 = 1;
        rhsusf_acc_grip2_tan = 1;
        rhsusf_acc_grip2_wd = 1;
        rhsusf_acc_grip3 = 1;
        rhsusf_acc_grip3_tan = 1;
        rhsusf_acc_kac_grip = 1;
        rhsusf_acc_rvg_blk = 1;
        rhsusf_acc_rvg_de = 1;
        rhsusf_acc_tacsac_blue = 1;
        rhsusf_acc_tacsac_blk = 1;
        rhsusf_acc_tacsac_tan = 1;
        rhsusf_acc_tdstubby_blk = 1;
        rhsusf_acc_tdstubby_tan = 1;
    };
};
class asdg_UnderSlot;
class nia_rifle_bipodsgrips_slot : asdg_UnderSlot {
    class compatibleItems {
        rhs_acc_grip_ffg2 = 1;
        rhs_acc_grip_rk2 = 1;
        rhs_acc_grip_rk6 = 1;
        rhsusf_acc_grip1 = 1;
        rhsusf_acc_grip2 = 1;
        rhsusf_acc_grip2_tan = 1;
        rhsusf_acc_grip2_wd = 1;
        rhsusf_acc_grip3 = 1;
        rhsusf_acc_grip3_tan = 1;
        rhsusf_acc_kac_grip = 1;
        rhsusf_acc_rvg_blk = 1;
        rhsusf_acc_rvg_de = 1;
        rhsusf_acc_tacsac_blue = 1;
        rhsusf_acc_tacsac_blk = 1;
        rhsusf_acc_tacsac_tan = 1;
        rhsusf_acc_tdstubby_blk = 1;
        rhsusf_acc_tdstubby_tan = 1;
    };
};
