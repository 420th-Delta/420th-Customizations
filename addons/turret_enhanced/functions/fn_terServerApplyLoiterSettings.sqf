/*
    Author: zobri

    Validates a gunner-owned request and applies UAV altitude and loiter settings.
*/
params [
    ["_requester", objNull, [objNull]],
    ["_aircraft", objNull, [objNull]],
    ["_altitudeASL", 0, [0]],
    ["_terrainClearance", 0, [0]],
    ["_radius", 0, [0]]
];

if (!isServer) exitWith {false};
if (isNull _requester || {isNull _aircraft} || {!isPlayer _requester}) exitWith {false};
if (
    isMultiplayer
    && {isRemoteExecuted}
    && {
        remoteExecutedOwner <= 2
        || {owner _requester isNotEqualTo remoteExecutedOwner}
    }
) exitWith {false};

// A short, server-local, per-player throttle limits RPC spam without affecting
// the normal dialog workflow or the separate waypoint-center command.
private _now = diag_tickTime;
private _lastRequest = _requester getVariable ["fdelta_terLastSettingsRequest", -1];
if (_lastRequest >= 0 && {_now - _lastRequest < 0.25}) exitWith {false};
_requester setVariable ["fdelta_terLastSettingsRequest", _now];

private _notifyRequester = {
    params ["_message"];
    if (hasInterface && {_requester isEqualTo player}) exitWith {
        [_message] call fdelta_fnc_terNotify;
    };

    private _requesterOwner = owner _requester;
    if (_requesterOwner > 2) then {
        [_message] remoteExecCall ["fdelta_fnc_terNotify", _requesterOwner];
    };
};

if (!unitIsUAV _aircraft || {!(_aircraft isKindOf "Air")}) exitWith {false};
if !(_requester in (UAVControl [_aircraft, "gunner"])) exitWith {
    ["TER: Request rejected because you no longer control that UAV gunner."]
        call _notifyRequester;
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

private _loiter = [_aircraft] call fdelta_fnc_terFindActiveLoiter;
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

private _message = if (_radiusApplied) then {
    format [
        "TER: %1 set to %2 m ASL, %3 m terrain clearance, %4 m loiter radius.",
        _name,
        round _altitudeASL,
        round _terrainClearance,
        round _radius
    ]
} else {
    if (_hasLoiter) then {
        format [
            "TER: %1 set to %2 m ASL and %3 m terrain clearance, but the active "
                + "LOITER waypoint could not be updated.",
            _name,
            round _altitudeASL,
            round _terrainClearance
        ]
    } else {
        format [
            "TER: %1 set to %2 m ASL and %3 m terrain clearance. Radius unchanged: "
                + "no active LOITER waypoint.",
            _name,
            round _altitudeASL,
            round _terrainClearance
        ]
    }
};

[_message] call _notifyRequester;
true
