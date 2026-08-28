/*
    Author: zobri

    Requests that the server move the active UAV LOITER waypoint to camera aim.
*/
if (isRemoteExecuted) exitWith {false};

private _aircraft = call fdelta_fnc_terGetCameraAircraft;
if (isNull _aircraft || {!unitIsUAV _aircraft}) exitWith {
    systemChat localize "STR_FDELTA_TER_MSG_RETASK_REQUIRES_UAV";
    false
};

private _loiter = [_aircraft] call fdelta_fnc_terFindActiveLoiter;
if (_loiter isEqualTo []) exitWith {
    systemChat localize "STR_FDELTA_TER_MSG_NO_ACTIVE_LOITER";
    false
};
if (
    !isNull (waypointAttachedVehicle _loiter)
    || {!isNull (waypointAttachedObject _loiter)}
) exitWith {
    systemChat localize "STR_FDELTA_TER_MSG_LOITER_ATTACHED";
    false
};

private _point = call fdelta_fnc_terAimPoint;
if (_point isEqualTo []) exitWith {
    systemChat localize "STR_FDELTA_TER_MSG_NO_CAMERA_INTERSECTION";
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

systemChat format [
    localize "STR_FDELTA_TER_MSG_LOITER_CENTER_MOVED_FORMAT",
    mapGridPosition _point
];

true
