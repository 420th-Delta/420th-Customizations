/*
    Author: zobri

    Opens the loiter controls for the actively controlled UAV.
*/
if !(call fdelta_fnc_terCanUseCamera) exitWith {
    systemChat "TER: Enter an aircraft gunner optic first.";
    false
};

private _aircraft = call fdelta_fnc_terGetCameraAircraft;
if (isNull _aircraft || {!unitIsUAV _aircraft}) exitWith {
    systemChat "TER: Loiter controls require an actively controlled UAV.";
    false
};

uiNamespace setVariable ["fdelta_terDialogAircraft", _aircraft];
createDialog "Fdelta_TER_LoiterDialog"
