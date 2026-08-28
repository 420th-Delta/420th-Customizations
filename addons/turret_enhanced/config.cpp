class CfgPatches {
    class fdelta_turret_enhanced {
        name = "$STR_FDELTA_TER_ADDON_NAME";
        author = "zobri";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.22;
        requiredAddons[] = {
            "A3_Functions_F",
            "A3_UI_F",
            "fdelta_main",
        };
        skipWhenMissingDependencies = 0;

        units[] = {};
        weapons[] = {};
    };
};

class CfgFunctions {
    class fdelta {
        tag = "fdelta";

        class TurretEnhanced {
            file = "\z\fdelta\addons\turret_enhanced\functions";

            class terPostInit {
                postInit = 1;
            };
            class terGetCameraAircraft {};
            class terCanUseCamera {};
            class terAddActions {};
            class terFindActiveLoiter {};
            class terOpenLoiterDialog {};
            class terLoiterDialogOnLoad {};
            class terApplyLoiterDialog {};
            class terApplyLoiterSettings {};
            class terApplyFlightProfileLocal {};
            class terServerApplyLoiterSettings {};
            class terServerMoveLoiterCenter {};
            class terAimPoint {};
            class terMarkAim {};
            class terMoveLoiterCenter {};
            class terMeasureAim {};
        };
    };
};

class CfgUserActions {
    class Fdelta_TER_OpenLoiter {
        displayName = "$STR_FDELTA_TER_ACTION_OPEN_LOITER";
        tooltip = "$STR_FDELTA_TER_ACTION_OPEN_LOITER_TOOLTIP";
        onActivate = "[] call fdelta_fnc_terOpenLoiterDialog";
        onDeactivate = "";
        onAnalog = "";
        analogChangeThreshold = 0.01;
        modifierBlocking = 1;
    };

    class Fdelta_TER_MarkAim {
        displayName = "$STR_FDELTA_TER_ACTION_MARK_AIM";
        tooltip = "$STR_FDELTA_TER_ACTION_MARK_AIM_TOOLTIP";
        onActivate = "[] call fdelta_fnc_terMarkAim";
        onDeactivate = "";
        onAnalog = "";
        analogChangeThreshold = 0.01;
        modifierBlocking = 1;
    };

    class Fdelta_TER_MarkAimRed {
        displayName = "$STR_FDELTA_TER_ACTION_MARK_AIM_RED";
        tooltip = "$STR_FDELTA_TER_ACTION_MARK_AIM_RED_TOOLTIP";
        onActivate = "['ColorRed'] call fdelta_fnc_terMarkAim";
        onDeactivate = "";
        onAnalog = "";
        analogChangeThreshold = 0.01;
        modifierBlocking = 1;
    };

    class Fdelta_TER_MoveLoiterCenter {
        displayName = "$STR_FDELTA_TER_ACTION_MOVE_LOITER";
        tooltip = "$STR_FDELTA_TER_ACTION_MOVE_LOITER_TOOLTIP";
        onActivate = "[] call fdelta_fnc_terMoveLoiterCenter";
        onDeactivate = "";
        onAnalog = "";
        analogChangeThreshold = 0.01;
        modifierBlocking = 1;
    };

    class Fdelta_TER_MeasureAim {
        displayName = "$STR_FDELTA_TER_ACTION_MEASURE_AIM";
        tooltip = "$STR_FDELTA_TER_ACTION_MEASURE_AIM_TOOLTIP";
        onActivate = "[] call fdelta_fnc_terMeasureAim";
        onDeactivate = "";
        onAnalog = "";
        analogChangeThreshold = 0.01;
        modifierBlocking = 1;
    };
};

class UserActionGroups {
    class Fdelta_TER_Actions {
        name = "$STR_FDELTA_TER_GROUP_NAME";
        isAddon = 1;
        group[] = {
            "Fdelta_TER_OpenLoiter",
            "Fdelta_TER_MarkAim",
            "Fdelta_TER_MarkAimRed",
            "Fdelta_TER_MoveLoiterCenter",
            "Fdelta_TER_MeasureAim",
        };
    };
};

class RscText;
class RscEdit;
class RscButton;
class RscStructuredText;

class Fdelta_TER_LoiterDialog {
    idd = 420870;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "_this call fdelta_fnc_terLoiterDialogOnLoad";
    onUnload = "uiNamespace setVariable ['fdelta_terDialogAircraft', objNull]";

    class controlsBackground {
        class Background : RscText {
            idc = -1;
            x = "safeZoneX + safeZoneW * 0.365";
            y = "safeZoneY + safeZoneH * 0.32";
            w = "safeZoneW * 0.27";
            h = "safeZoneH * 0.36";
            colorBackground[] = {0.02, 0.025, 0.03, 0.94};
        };

        class TitleBar : RscText {
            idc = -1;
            x = "safeZoneX + safeZoneW * 0.365";
            y = "safeZoneY + safeZoneH * 0.32";
            w = "safeZoneW * 0.27";
            h = "safeZoneH * 0.045";
            colorBackground[] = {0.12, 0.32, 0.18, 1};
        };
    };

    class controls {
        class Title : RscText {
            idc = 420871;
            x = "safeZoneX + safeZoneW * 0.375";
            y = "safeZoneY + safeZoneH * 0.325";
            w = "safeZoneW * 0.25";
            h = "safeZoneH * 0.035";
            text = "$STR_FDELTA_TER_DIALOG_TITLE";
            sizeEx = "safeZoneH * 0.026";
        };

        class AltitudeLabel : RscText {
            idc = -1;
            x = "safeZoneX + safeZoneW * 0.385";
            y = "safeZoneY + safeZoneH * 0.385";
            w = "safeZoneW * 0.14";
            h = "safeZoneH * 0.035";
            text = "$STR_FDELTA_TER_DIALOG_ALTITUDE_LABEL";
            sizeEx = "safeZoneH * 0.021";
        };

        class AltitudeEdit : RscEdit {
            idc = 420872;
            x = "safeZoneX + safeZoneW * 0.535";
            y = "safeZoneY + safeZoneH * 0.385";
            w = "safeZoneW * 0.075";
            h = "safeZoneH * 0.035";
            text = "500";
            tooltip = "$STR_FDELTA_TER_DIALOG_ALTITUDE_TOOLTIP";
        };

        class ClearanceLabel : RscText {
            idc = -1;
            x = "safeZoneX + safeZoneW * 0.385";
            y = "safeZoneY + safeZoneH * 0.435";
            w = "safeZoneW * 0.14";
            h = "safeZoneH * 0.035";
            text = "$STR_FDELTA_TER_DIALOG_CLEARANCE_LABEL";
            sizeEx = "safeZoneH * 0.021";
        };

        class ClearanceEdit : RscEdit {
            idc = 420873;
            x = "safeZoneX + safeZoneW * 0.535";
            y = "safeZoneY + safeZoneH * 0.435";
            w = "safeZoneW * 0.075";
            h = "safeZoneH * 0.035";
            text = "50";
            tooltip = "$STR_FDELTA_TER_DIALOG_CLEARANCE_TOOLTIP";
        };

        class RadiusLabel : RscText {
            idc = -1;
            x = "safeZoneX + safeZoneW * 0.385";
            y = "safeZoneY + safeZoneH * 0.485";
            w = "safeZoneW * 0.14";
            h = "safeZoneH * 0.035";
            text = "$STR_FDELTA_TER_DIALOG_RADIUS_LABEL";
            sizeEx = "safeZoneH * 0.021";
        };

        class RadiusEdit : RscEdit {
            idc = 420874;
            x = "safeZoneX + safeZoneW * 0.535";
            y = "safeZoneY + safeZoneH * 0.485";
            w = "safeZoneW * 0.075";
            h = "safeZoneH * 0.035";
            text = "1000";
            tooltip = "$STR_FDELTA_TER_DIALOG_RADIUS_TOOLTIP";
        };

        class Status : RscStructuredText {
            idc = 420875;
            x = "safeZoneX + safeZoneW * 0.385";
            y = "safeZoneY + safeZoneH * 0.535";
            w = "safeZoneW * 0.225";
            h = "safeZoneH * 0.075";
            text = "";
            colorBackground[] = {0, 0, 0, 0};
        };

        class Apply : RscButton {
            idc = 420876;
            x = "safeZoneX + safeZoneW * 0.44";
            y = "safeZoneY + safeZoneH * 0.625";
            w = "safeZoneW * 0.07";
            h = "safeZoneH * 0.035";
            text = "$STR_FDELTA_TER_DIALOG_APPLY";
            action = "[] call fdelta_fnc_terApplyLoiterDialog";
        };

        class Cancel : RscButton {
            idc = 420877;
            x = "safeZoneX + safeZoneW * 0.52";
            y = "safeZoneY + safeZoneH * 0.625";
            w = "safeZoneW * 0.07";
            h = "safeZoneH * 0.035";
            text = "$STR_FDELTA_TER_DIALOG_CANCEL";
            action = "closeDialog 2";
        };
    };
};

class CfgRemoteExec {
    class Functions {
        class fdelta_fnc_terServerApplyLoiterSettings {
            allowedTargets = 2;
            jip = 0;
        };
        class fdelta_fnc_terServerMoveLoiterCenter {
            allowedTargets = 2;
            jip = 0;
        };
        class fdelta_fnc_terApplyFlightProfileLocal {
            allowedTargets = 0;
            jip = 0;
        };
    };
};
