/*
    Author: zobri

    Adds the local player's Turret Enhanced interaction actions once.
*/
if (isRemoteExecuted) exitWith {[]};

params [["_unit", player, [objNull]]];

if (
    !hasInterface
    || {isNull _unit}
    || {!local _unit}
    || {!isPlayer _unit}
) exitWith {[]};

private _existing = _unit getVariable ["fdelta_terActionIds", []];
if (_existing isNotEqualTo []) exitWith {_existing};

private _cameraCondition = "call fdelta_fnc_terCanUseCamera";
private _uavCondition = "(call fdelta_fnc_terCanUseCamera) && "
    + "{private _aircraft = call fdelta_fnc_terGetCameraAircraft; "
    + "!isNull _aircraft && {unitIsUAV _aircraft}}";
private _ids = [];

_ids pushBack (_unit addAction [
    format [
        "<t color='#7FDBFF'>%1</t>",
        localize "STR_FDELTA_TER_ADD_ACTION_OPEN_LOITER"
    ],
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

_ids pushBack (_unit addAction [
    format [
        "<t color='#FFD65A'>%1</t>",
        localize "STR_FDELTA_TER_ADD_ACTION_MARK_AIM"
    ],
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

_ids pushBack (_unit addAction [
    format [
        "<t color='#FF6868'>%1</t>",
        localize "STR_FDELTA_TER_ADD_ACTION_MARK_AIM_RED"
    ],
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

_ids pushBack (_unit addAction [
    format [
        "<t color='#7FDBFF'>%1</t>",
        localize "STR_FDELTA_TER_ADD_ACTION_MOVE_LOITER"
    ],
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

_ids pushBack (_unit addAction [
    localize "STR_FDELTA_TER_ADD_ACTION_MEASURE_AIM",
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

_unit setVariable ["fdelta_terActionIds", _ids];
_ids
