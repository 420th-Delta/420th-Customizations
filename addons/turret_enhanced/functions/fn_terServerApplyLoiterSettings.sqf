/*
    Author: zobri

    Applies the two server-only waypoint changes, then forwards the local
    flight command only when the UAV is owned by another machine.
*/
if (!isServer) exitWith {false};
private _remoteCall = isRemoteExecuted;
if (_remoteCall && {remoteExecutedOwner <= 2}) exitWith {false};
// Reject malformed public calls before typed params can emit diagnostics.
if !(_this isEqualType [] && {count _this isEqualTo 6}) exitWith {false};
if !(
    (_this # 0) isEqualType objNull
    && {(_this # 1) isEqualType objNull}
    && {(_this # 2) isEqualType 0}
    && {(_this # 3) isEqualType 0}
    && {(_this # 4) isEqualType 0}
    && {(_this # 5) isEqualType false}
) exitWith {false};
params [
    ["_requester", objNull, [objNull]],
    ["_aircraft", objNull, [objNull]],
    ["_altitudeASL", 0, [0]],
    ["_terrainClearance", 0, [0]],
    ["_radius", 0, [0]],
    ["_flightAppliedLocally", false, [false]]
];

if (isNull _requester || {isNull _aircraft} || {!isPlayer _requester}) exitWith {
    false
};
private _requestOwner = if (_remoteCall) then {remoteExecutedOwner} else {2};
if (owner _requester isNotEqualTo _requestOwner) exitWith {
    false
};

if (!unitIsUAV _aircraft || {!(_aircraft isKindOf "Air")}) exitWith {false};
if !(_requester in (UAVControl [_aircraft, "gunner"])) exitWith {false};
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

private _loiter = [_aircraft] call fdelta_fnc_terFindActiveLoiter;
if (_loiter isNotEqualTo []) then {
    _loiter setWaypointLoiterAltitude _terrainClearance;
    _loiter setWaypointLoiterRadius _radius;
};

if (local _aircraft) then {
    // This authenticated RPC still carries its caller's remote-execution
    // context into nested calls, so apply the server-local command directly.
    _aircraft flyInHeight _terrainClearance;
    _aircraft flyInHeightASL [_altitudeASL, _altitudeASL, _altitudeASL];
    _aircraft setVariable [
        "fdelta_terLastAppliedFlightProfile",
        [_altitudeASL, _terrainClearance]
    ];
} else {
    // Skip the return hop only when the requester actually applied the
    // command and still owns the UAV. If locality moved to the requester
    // after submission, the false flag closes that otherwise missed apply.
    if (
        !_flightAppliedLocally
        || {owner _aircraft isNotEqualTo _requestOwner}
    ) then {
        [_aircraft, _altitudeASL, _terrainClearance] remoteExecCall [
            "fdelta_fnc_terApplyFlightProfileLocal",
            _aircraft
        ];
    };
};
true
