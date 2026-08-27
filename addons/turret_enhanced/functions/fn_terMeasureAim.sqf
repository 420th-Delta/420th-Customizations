/*
    Author: zobri

    Captures two camera points and reports their distance and bearing.
*/
private _point = call fdelta_fnc_terAimPoint;
if (_point isEqualTo []) exitWith {
    systemChat "TER: The camera center does not intersect terrain or water within view distance.";
    false
};

private _stored = missionNamespace getVariable ["fdelta_terMeasureStart", []];
private _expired = _stored isEqualTo []
    || {count _stored < 2}
    || {diag_tickTime - (_stored # 1) > 120};

if (_expired) exitWith {
    missionNamespace setVariable ["fdelta_terMeasureStart", [_point, diag_tickTime]];
    systemChat format [
        "TER: Measurement start captured at grid %1. Aim elsewhere and measure again.",
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
    "TER: %1 m, bearing %2 deg (grid %3 to %4).",
    _distance,
    _bearing,
    mapGridPosition _start,
    mapGridPosition _point
];
true
