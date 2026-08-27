/*
    Author: zobri

    Validates a gunner-owned request and moves the active UAV LOITER waypoint.
*/
if (!isServer) exitWith {false};
private _remoteCall = isRemoteExecuted;
if (_remoteCall && {remoteExecutedOwner <= 2}) exitWith {false};

// Keep this server-local throttle independent from settings changes so a
// normal apply-then-retask sequence is never blocked. The remote owner is the
// key; no client-writable requester-object state is trusted.
private _now = diag_tickTime;
private _requestOwner = if (_remoteCall) then {
    remoteExecutedOwner
} else {
    2
};
private _throttleNamespace = localNamespace;
private _requestTimes = _throttleNamespace getVariable [
    "fdelta_terCenterRequestTimes",
    createHashMap
];
if !(_requestTimes isEqualType createHashMap) then {
    _requestTimes = createHashMap;
};

private _lastRequest = _requestTimes getOrDefault [_requestOwner, -1];
if !(_lastRequest isEqualType 0 && {finite _lastRequest}) then {
    _lastRequest = -1;
};
if (_lastRequest >= 0 && {_now - _lastRequest < 0.25}) exitWith {false};
_requestTimes set [_requestOwner, _now];

private _staleOwners = [];
{
    if (!(_y isEqualType 0) || {!finite _y} || {_now - _y > 300}) then {
        _staleOwners pushBack _x;
    };
} forEach _requestTimes;
{
    _requestTimes deleteAt _x;
} forEach _staleOwners;

if (count _requestTimes > 128) then {
    private _requestsByAge = [];
    {
        _requestsByAge pushBack [_y, _x];
    } forEach _requestTimes;
    _requestsByAge sort true;

    for "_index" from 0 to (count _requestTimes - 129) do {
        _requestTimes deleteAt ((_requestsByAge # _index) # 1);
    };
};
_throttleNamespace setVariable [
    "fdelta_terCenterRequestTimes",
    _requestTimes
];

if !(_this isEqualType [] && {count _this isEqualTo 3}) exitWith {false};
if !(
    (_this # 0) isEqualType objNull
    && {(_this # 1) isEqualType objNull}
    && {(_this # 2) isEqualType []}
) exitWith {false};
private _requester = _this # 0;
private _aircraft = _this # 1;
private _centerASL = _this # 2;

if (isNull _requester || {isNull _aircraft} || {!isPlayer _requester}) exitWith {
    false
};
if (_remoteCall && {owner _requester isNotEqualTo _requestOwner}) exitWith {
    false
};

private _notifyRequester = {
    params [
        ["_messageKey", "", [""]],
        ["_arguments", [], [[]]]
    ];
    if (hasInterface && {_requester isEqualTo player}) exitWith {
        [_messageKey, _arguments] call fdelta_fnc_terNotify;
    };

    private _requesterOwner = owner _requester;
    if (_requesterOwner > 2) then {
        [_messageKey, _arguments] remoteExecCall [
            "fdelta_fnc_terNotify",
            _requesterOwner
        ];
    };
};

if (!unitIsUAV _aircraft || {!(_aircraft isKindOf "Air")}) exitWith {false};
if !(_requester in (UAVControl [_aircraft, "gunner"])) exitWith {
    ["STR_FDELTA_TER_MSG_RETASK_CONTROL_CHANGED"] call _notifyRequester;
    false
};
if (count _centerASL isNotEqualTo 3) exitWith {false};
if !(
    (_centerASL # 0) isEqualType 0
    && {(_centerASL # 1) isEqualType 0}
    && {(_centerASL # 2) isEqualType 0}
) exitWith {false};
if (
    !finite (_centerASL # 0)
    || {!finite (_centerASL # 1)}
    || {!finite (_centerASL # 2)}
) exitWith {false};
if (
    (_centerASL # 0) < 0
    || {(_centerASL # 1) < 0}
    || {(_centerASL # 0) > worldSize}
    || {(_centerASL # 1) > worldSize}
) exitWith {false};

private _loiter = [_aircraft] call (localNamespace getVariable [
    "fdelta_ter_resolveActiveLoiter",
    {[]}
]);
if (_loiter isEqualTo []) exitWith {
    ["STR_FDELTA_TER_MSG_NO_ACTIVE_LOITER"] call _notifyRequester;
    false
};

if (
    !isNull (waypointAttachedVehicle _loiter)
    || {!isNull (waypointAttachedObject _loiter)}
) exitWith {
    ["STR_FDELTA_TER_MSG_LOITER_ATTACHED"] call _notifyRequester;
    false
};

_loiter setWaypointPosition [_centerASL, -1];

private _desiredAGL = ASLToAGL _centerASL;
if ((waypointPosition _loiter) distance2D _desiredAGL > 5) exitWith {
    ["STR_FDELTA_TER_MSG_LOITER_MOVE_FAILED"] call _notifyRequester;
    false
};

[
    "STR_FDELTA_TER_MSG_LOITER_CENTER_MOVED_FORMAT",
    [mapGridPosition _desiredAGL]
] call _notifyRequester;
true
