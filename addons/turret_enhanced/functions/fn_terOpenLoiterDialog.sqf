/*
    Author: zobri

    Opens the loiter controls for the actively controlled UAV.
*/
if (isRemoteExecuted) exitWith {false};

if !(call fdelta_fnc_terCanUseCamera) exitWith {
    systemChat localize "STR_FDELTA_TER_MSG_ENTER_GUNNER_OPTIC";
    false
};

private _aircraft = call fdelta_fnc_terGetCameraAircraft;
if (isNull _aircraft || {!unitIsUAV _aircraft}) exitWith {
    systemChat localize "STR_FDELTA_TER_MSG_LOITER_REQUIRES_UAV";
    false
};

uiNamespace setVariable ["fdelta_terDialogAircraft", _aircraft];
createDialog "Fdelta_TER_LoiterDialog"
