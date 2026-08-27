/*
    Author: zobri

    Populates the loiter dialog from the active UAV and waypoint state.
*/
disableSerialization;
params ["_display"];

private _aircraft = uiNamespace getVariable ["fdelta_terDialogAircraft", objNull];
if (isNull _aircraft) exitWith {
    closeDialog 2;
};

private _profile = _aircraft getVariable ["fdelta_terUiFlightProfile", []];
private _altitudeASL = if (count _profile >= 2) then {
    _profile # 0
} else {
    round ((getPosASL _aircraft) # 2)
};
private _terrainClearance = if (count _profile >= 2) then {_profile # 1} else {50};

private _loiter = [_aircraft] call fdelta_fnc_terFindActiveLoiter;
private _radius = if (_loiter isEqualTo []) then {1000} else {waypointLoiterRadius _loiter};
if (_radius <= 0) then {
    _radius = 1000;
};

private _vehicleName = getText (configOf _aircraft >> "displayName");
(_display displayCtrl 420871) ctrlSetText format ["UAV Loiter Controls - %1", _vehicleName];
(_display displayCtrl 420872) ctrlSetText str (round _altitudeASL);
(_display displayCtrl 420873) ctrlSetText str (round _terrainClearance);
(_display displayCtrl 420874) ctrlSetText str (round _radius);

private _status = if (_loiter isEqualTo []) then {
    "<t size='0.85' color='#FFD65A'>No active LOITER waypoint. Altitude will apply, "
        + "but radius and center commands need an active LOITER waypoint.</t>"
} else {
    "<t size='0.85' color='#9BE7A1'>Active LOITER waypoint found. ASL is the main "
        + "altitude; terrain clearance is only the safety floor.</t>"
};
(_display displayCtrl 420875) ctrlSetStructuredText parseText _status;

ctrlSetFocus (_display displayCtrl 420872);
