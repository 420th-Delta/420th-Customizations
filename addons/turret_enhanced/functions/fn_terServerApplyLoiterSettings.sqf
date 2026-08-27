/*
    Author: zobri

    Validates a gunner-owned request and applies UAV altitude and loiter settings.
*/
if (!isServer) exitWith {false};
private _remoteCall = isRemoteExecuted;
if (_remoteCall && {remoteExecutedOwner <= 2}) exitWith {false};

// A short, server-local, per-owner throttle limits RPC spam without trusting
// variables on the requester object. Keep the two TER commands independent so
// a normal dialog apply followed by a center move remains possible.
private _now = diag_tickTime;
private _requestOwner = if (_remoteCall) then {
    remoteExecutedOwner
} else {
    2
};
private _throttleNamespace = localNamespace;
private _requestTimes = _throttleNamespace getVariable [
    "fdelta_terSettingsRequestTimes",
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

// Server owner IDs can change after reconnects. Expire old IDs and enforce a
// hard cap so a long-running server cannot accumulate throttle state forever.
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
    "fdelta_terSettingsRequestTimes",
    _requestTimes
];

// Do not let malformed public RPC payloads reach typed params, which can emit
// diagnostics before authentication and become an RPT-spam primitive.
if !(_this isEqualType [] && {count _this isEqualTo 5}) exitWith {false};
if !(
    (_this # 0) isEqualType objNull
    && {(_this # 1) isEqualType objNull}
    && {(_this # 2) isEqualType 0}
    && {(_this # 3) isEqualType 0}
    && {(_this # 4) isEqualType 0}
) exitWith {false};
private _requester = _this # 0;
private _aircraft = _this # 1;
private _altitudeASL = _this # 2;
private _terrainClearance = _this # 3;
private _radius = _this # 4;

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
    ["STR_FDELTA_TER_MSG_REQUEST_CONTROL_CHANGED"] call _notifyRequester;
    false
};
if (!finite _altitudeASL || {!finite _terrainClearance} || {!finite _radius}) exitWith {
    false
};
if (
    _altitudeASL < 20
    || {_altitudeASL > 20000}
    || {_terrainClearance < 20}
    || {_terrainClearance > 1000}
    || {_radius < 100}
    || {_radius > 20000}
) exitWith {false};

private _loiter = [_aircraft] call (localNamespace getVariable [
    "fdelta_ter_resolveActiveLoiter",
    {[]}
]);
private _hasLoiter = _loiter isNotEqualTo [];
private _radiusApplied = false;
if (_hasLoiter) then {
    _loiter setWaypointLoiterAltitude _terrainClearance;
    _loiter setWaypointLoiterRadius _radius;
    _radiusApplied = abs (waypointLoiterAltitude _loiter - _terrainClearance) < 0.1
        && {abs (waypointLoiterRadius _loiter - _radius) < 0.1};
};

private _registryNamespace = localNamespace;
private _profiles = _registryNamespace getVariable ["fdelta_terFlightProfiles", []];
private _profileIndex = _profiles findIf {(_x # 0) isEqualTo _aircraft};
private _entry = [_aircraft, _altitudeASL, _terrainClearance];
if (_profileIndex < 0) then {
    _profiles pushBack _entry;
} else {
    _profiles set [_profileIndex, _entry];
};
_registryNamespace setVariable ["fdelta_terFlightProfiles", _profiles];

if (local _aircraft) then {
    _aircraft flyInHeight _terrainClearance;
    _aircraft flyInHeightASL [_altitudeASL, _altitudeASL, _altitudeASL];
    _aircraft setVariable [
        "fdelta_terLastAppliedFlightProfile",
        [_altitudeASL, _terrainClearance]
    ];
} else {
    [_aircraft, _altitudeASL, _terrainClearance] remoteExecCall [
        "fdelta_fnc_terApplyFlightProfileLocal",
        _aircraft
    ];
};

private _pilot = driver _aircraft;
private _name = if (isNull _pilot) then {""} else {groupId (group _pilot)};
if (_name isEqualTo "") then {
    _name = getText (configOf _aircraft >> "displayName");
};

private _notification = if (_radiusApplied) then {
    [
        "STR_FDELTA_TER_MSG_SETTINGS_SUCCESS_FORMAT",
        [_name, round _altitudeASL, round _terrainClearance, round _radius]
    ]
} else {
    if (_hasLoiter) then {
        [
            "STR_FDELTA_TER_MSG_SETTINGS_WAYPOINT_FAILED_FORMAT",
            [_name, round _altitudeASL, round _terrainClearance]
        ]
    } else {
        [
            "STR_FDELTA_TER_MSG_SETTINGS_NO_WAYPOINT_FORMAT",
            [_name, round _altitudeASL, round _terrainClearance]
        ]
    }
};

_notification call _notifyRequester;
true
