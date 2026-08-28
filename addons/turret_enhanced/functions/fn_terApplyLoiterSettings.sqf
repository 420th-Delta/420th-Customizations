/*
    Author: zobri

    Submits validated loiter settings for the UAV currently controlled by the player.
*/
if (isRemoteExecuted) exitWith {false};

params [
    ["_aircraft", objNull, [objNull]],
    ["_altitudeASL", 0, [0]],
    ["_terrainClearance", 0, [0]],
    ["_radius", 0, [0]]
];

if (isNull _aircraft || {!unitIsUAV _aircraft} || {!(_aircraft isKindOf "Air")}) exitWith {
    systemChat localize "STR_FDELTA_TER_MSG_UAV_UNAVAILABLE";
    false
};
if (
    !finite _altitudeASL
    || {!finite _terrainClearance}
    || {!finite _radius}
    || {_altitudeASL < 20}
    || {_altitudeASL > 20000}
    || {_terrainClearance < 20}
    || {_terrainClearance > 1000}
    || {_radius < 100}
    || {_radius > 20000}
) exitWith {false};

private _controlled = call fdelta_fnc_terGetCameraAircraft;
if (_controlled isNotEqualTo _aircraft) exitWith {
    systemChat localize "STR_FDELTA_TER_MSG_UAV_CONTROL_CHANGED";
    false
};

_aircraft setVariable [
    "fdelta_terUiFlightProfile",
    [_altitudeASL, _terrainClearance, _radius]
];

// In the common case the requesting client also owns the UAV. Apply the local
// flight command immediately and let the server handle only waypoint state.
// The server forwards once only when a different machine owns the aircraft.
private _flightAppliedLocally = false;
if (!isServer && {local _aircraft}) then {
    [_aircraft, _altitudeASL, _terrainClearance]
        call fdelta_fnc_terApplyFlightProfileLocal;
    _flightAppliedLocally = true;
};

if (isServer) then {
    [
        player,
        _aircraft,
        _altitudeASL,
        _terrainClearance,
        _radius,
        _flightAppliedLocally
    ]
        call fdelta_fnc_terServerApplyLoiterSettings;
} else {
    [
        player,
        _aircraft,
        _altitudeASL,
        _terrainClearance,
        _radius,
        _flightAppliedLocally
    ] remoteExecCall [
        "fdelta_fnc_terServerApplyLoiterSettings",
        2
    ];
};

private _pilot = driver _aircraft;
private _name = if (isNull _pilot) then {""} else {groupId (group _pilot)};
if (_name isEqualTo "") then {
    _name = getText (configOf _aircraft >> "displayName");
};

private _loiter = [_aircraft] call fdelta_fnc_terFindActiveLoiter;
if (_loiter isEqualTo []) then {
    systemChat format [
        localize "STR_FDELTA_TER_MSG_SETTINGS_NO_WAYPOINT_FORMAT",
        _name,
        round _altitudeASL,
        round _terrainClearance
    ];
} else {
    systemChat format [
        localize "STR_FDELTA_TER_MSG_SETTINGS_SUCCESS_FORMAT",
        _name,
        round _altitudeASL,
        round _terrainClearance,
        round _radius
    ];
};

true
