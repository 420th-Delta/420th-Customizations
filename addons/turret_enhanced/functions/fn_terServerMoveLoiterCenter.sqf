/*
    Author: zobri

    Validates a gunner-owned request and moves the active UAV LOITER waypoint.
*/
params [
    ["_requester", objNull, [objNull]],
    ["_aircraft", objNull, [objNull]],
    ["_centerASL", [], [[]]]
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

// Keep this throttle independent from settings changes so a normal apply-then-
// retask sequence is never blocked.
private _now = diag_tickTime;
private _lastRequest = _requester getVariable ["fdelta_terLastCenterRequest", -1];
if (_lastRequest >= 0 && {_now - _lastRequest < 0.25}) exitWith {false};
_requester setVariable ["fdelta_terLastCenterRequest", _now];

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
    ["TER: Retask rejected because you no longer control that UAV gunner."]
        call _notifyRequester;
    false
};
if (count _centerASL < 3) exitWith {false};
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

private _loiter = [_aircraft] call fdelta_fnc_terFindActiveLoiter;
if (_loiter isEqualTo []) exitWith {
    ["TER: The UAV has no active LOITER waypoint to move."] call _notifyRequester;
    false
};

if (
    !isNull (waypointAttachedVehicle _loiter)
    || {!isNull (waypointAttachedObject _loiter)}
) exitWith {
    ["TER: The active LOITER waypoint is attached to an object and was not moved."]
        call _notifyRequester;
    false
};

_loiter setWaypointPosition [_centerASL, -1];

private _desiredAGL = ASLToAGL _centerASL;
if ((waypointPosition _loiter) distance2D _desiredAGL > 5) exitWith {
    ["TER: The active LOITER waypoint could not be moved on this machine."]
        call _notifyRequester;
    false
};

private _message = format [
    "TER: Active loiter center moved to grid %1.",
    mapGridPosition _desiredAGL
];
[_message] call _notifyRequester;
true
