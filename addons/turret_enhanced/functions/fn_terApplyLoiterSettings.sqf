/*
    Author: zobri

    Submits validated loiter settings for the UAV currently controlled by the player.
*/
params [
    ["_aircraft", objNull, [objNull]],
    ["_altitudeASL", 0, [0]],
    ["_terrainClearance", 0, [0]],
    ["_radius", 0, [0]]
];

if (isNull _aircraft || {!unitIsUAV _aircraft} || {!(_aircraft isKindOf "Air")}) exitWith {
    systemChat "TER: The controlled UAV is no longer available.";
    false
};

private _controlled = call fdelta_fnc_terGetCameraAircraft;
if (_controlled isNotEqualTo _aircraft) exitWith {
    systemChat "TER: UAV control changed before the settings were applied.";
    false
};

_aircraft setVariable [
    "fdelta_terUiFlightProfile",
    [_altitudeASL, _terrainClearance, _radius]
];

if (isServer) then {
    [player, _aircraft, _altitudeASL, _terrainClearance, _radius]
        call fdelta_fnc_terServerApplyLoiterSettings;
} else {
    [player, _aircraft, _altitudeASL, _terrainClearance, _radius] remoteExecCall [
        "fdelta_fnc_terServerApplyLoiterSettings",
        2
    ];
};

true
