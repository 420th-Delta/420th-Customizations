/*
    Author: zobri

    Performs the server-only LOITER waypoint position change.
*/
if (!isServer) exitWith {false};
private _remoteCall = isRemoteExecuted;
if (_remoteCall && {remoteExecutedOwner <= 2}) exitWith {false};
// Reject malformed public calls before typed params can emit diagnostics.
if !(_this isEqualType [] && {count _this isEqualTo 3}) exitWith {false};
if !(
    (_this # 0) isEqualType objNull
    && {(_this # 1) isEqualType objNull}
    && {(_this # 2) isEqualType []}
) exitWith {false};
params [
    ["_requester", objNull, [objNull]],
    ["_aircraft", objNull, [objNull]],
    ["_centerASL", [], [[]]]
];

if (isNull _requester || {isNull _aircraft} || {!isPlayer _requester}) exitWith {
    false
};
if (_remoteCall && {owner _requester isNotEqualTo remoteExecutedOwner}) exitWith {
    false
};

if (!unitIsUAV _aircraft || {!(_aircraft isKindOf "Air")}) exitWith {false};
if !(_requester in (UAVControl [_aircraft, "gunner"])) exitWith {false};
if (count _centerASL isNotEqualTo 3) exitWith {false};
if ((_centerASL findIf {!(_x isEqualType 0) || {!finite _x}}) >= 0) exitWith {false};
if (
    (_centerASL # 0) < 0
    || {(_centerASL # 1) < 0}
    || {(_centerASL # 0) > worldSize}
    || {(_centerASL # 1) > worldSize}
) exitWith {false};

private _loiter = [_aircraft] call fdelta_fnc_terFindActiveLoiter;
if (_loiter isEqualTo []) exitWith {
    false
};

if (
    !isNull (waypointAttachedVehicle _loiter)
    || {!isNull (waypointAttachedObject _loiter)}
) exitWith {
    false
};

_loiter setWaypointPosition [_centerASL, -1];

private _desiredAGL = ASLToAGL _centerASL;
if ((waypointPosition _loiter) distance2D _desiredAGL > 5) exitWith {
    false
};
true
