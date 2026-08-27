/*
    Author: zobri

    Requests that the server move the active UAV LOITER waypoint to camera aim.
*/
private _aircraft = call fdelta_fnc_terGetCameraAircraft;
if (isNull _aircraft || {!unitIsUAV _aircraft}) exitWith {
    systemChat "TER: Loiter retasking requires an actively controlled UAV.";
    false
};

private _loiter = [_aircraft] call fdelta_fnc_terFindActiveLoiter;
if (_loiter isEqualTo []) exitWith {
    systemChat "TER: The UAV has no active LOITER waypoint to move.";
    false
};

private _point = call fdelta_fnc_terAimPoint;
if (_point isEqualTo []) exitWith {
    systemChat "TER: The camera center does not intersect terrain or water within view distance.";
    false
};

private _centerASL = AGLToASL _point;
if (isServer) then {
    [player, _aircraft, _centerASL] call fdelta_fnc_terServerMoveLoiterCenter;
} else {
    [player, _aircraft, _centerASL] remoteExecCall [
        "fdelta_fnc_terServerMoveLoiterCenter",
        2
    ];
};

true
