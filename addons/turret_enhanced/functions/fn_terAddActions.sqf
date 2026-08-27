/*
    Author: zobri

    Adds the local player's Turret Enhanced interaction actions once.
*/
if (!hasInterface || {isNull player}) exitWith {[]};

private _existing = player getVariable ["fdelta_terActionIds", []];
if (_existing isNotEqualTo []) exitWith {_existing};

private _cameraCondition = "call fdelta_fnc_terCanUseCamera";
private _uavCondition = "(call fdelta_fnc_terCanUseCamera) && "
    + "{private _aircraft = call fdelta_fnc_terGetCameraAircraft; "
    + "!isNull _aircraft && {unitIsUAV _aircraft}}";
private _ids = [];

_ids pushBack (player addAction [
    "<t color='#7FDBFF'>TER: UAV loiter controls</t>",
    {[] call fdelta_fnc_terOpenLoiterDialog},
    nil,
    -10,
    false,
    true,
    "",
    _uavCondition,
    -1,
    false,
    "",
    ""
]);

_ids pushBack (player addAction [
    "<t color='#FFD65A'>TER: Mark camera aim</t>",
    {[] call fdelta_fnc_terMarkAim},
    nil,
    -11,
    false,
    true,
    "",
    _cameraCondition,
    -1,
    false,
    "",
    ""
]);

_ids pushBack (player addAction [
    "<t color='#FF6868'>TER: Mark camera aim (red)</t>",
    {["ColorRed"] call fdelta_fnc_terMarkAim},
    nil,
    -12,
    false,
    true,
    "",
    _cameraCondition,
    -1,
    false,
    "",
    ""
]);

_ids pushBack (player addAction [
    "<t color='#7FDBFF'>TER: Move loiter center here</t>",
    {[] call fdelta_fnc_terMoveLoiterCenter},
    nil,
    -13,
    false,
    true,
    "",
    _uavCondition,
    -1,
    false,
    "",
    ""
]);

_ids pushBack (player addAction [
    "TER: Measure from/to camera aim",
    {[] call fdelta_fnc_terMeasureAim},
    nil,
    -14,
    false,
    true,
    "",
    _cameraCondition,
    -1,
    false,
    "",
    ""
]);

player setVariable ["fdelta_terActionIds", _ids];
_ids
