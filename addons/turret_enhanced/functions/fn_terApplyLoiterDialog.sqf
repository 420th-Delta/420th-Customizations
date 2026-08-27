/*
    Author: zobri

    Validates and submits the values entered in the loiter dialog.
*/
if (isRemoteExecuted) exitWith {false};

disableSerialization;

private _display = findDisplay 420870;
if (isNull _display) exitWith {false};

private _altitudeASL = parseNumber (ctrlText (_display displayCtrl 420872));
private _terrainClearance = parseNumber (ctrlText (_display displayCtrl 420873));
private _radius = parseNumber (ctrlText (_display displayCtrl 420874));

if (!finite _altitudeASL || {_altitudeASL < 20} || {_altitudeASL > 20000}) exitWith {
    systemChat localize "STR_FDELTA_TER_MSG_ALTITUDE_RANGE";
    false
};
if (
    !finite _terrainClearance
    || {_terrainClearance < 20}
    || {_terrainClearance > 1000}
) exitWith {
    systemChat localize "STR_FDELTA_TER_MSG_CLEARANCE_RANGE";
    false
};
if (!finite _radius || {_radius < 100} || {_radius > 20000}) exitWith {
    systemChat localize "STR_FDELTA_TER_MSG_RADIUS_RANGE";
    false
};

private _aircraft = uiNamespace getVariable ["fdelta_terDialogAircraft", objNull];
closeDialog 1;

[_aircraft, _altitudeASL, _terrainClearance, _radius] call fdelta_fnc_terApplyLoiterSettings
