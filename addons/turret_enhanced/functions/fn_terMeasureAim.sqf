/*
    Author: zobri

    Captures two camera points and reports their distance and bearing.
*/
if (isRemoteExecuted) exitWith {false};

private _point = call fdelta_fnc_terAimPoint;
if (_point isEqualTo []) exitWith {
    systemChat localize "STR_FDELTA_TER_MSG_NO_CAMERA_INTERSECTION";
    false
};

private _stored = missionNamespace getVariable ["fdelta_terMeasureStart", []];
private _expired = _stored isEqualTo []
    || {count _stored < 2}
    || {diag_tickTime - (_stored # 1) > 120};

if (_expired) exitWith {
    missionNamespace setVariable ["fdelta_terMeasureStart", [_point, diag_tickTime]];
    systemChat format [
        localize "STR_FDELTA_TER_MSG_MEASURE_START_FORMAT",
        mapGridPosition _point
    ];
    true
};

private _start = _stored # 0;
missionNamespace setVariable ["fdelta_terMeasureStart", []];

private _distance = round (_start distance2D _point);
private _bearing = round (_start getDir _point);
if (_bearing >= 360) then {
    _bearing = 0;
};

systemChat format [
    localize "STR_FDELTA_TER_MSG_MEASURE_RESULT_FORMAT",
    _distance,
    _bearing,
    mapGridPosition _start,
    mapGridPosition _point
];
true
