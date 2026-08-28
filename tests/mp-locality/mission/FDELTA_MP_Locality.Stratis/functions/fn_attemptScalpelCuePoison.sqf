/*
    Sends an owner-only engine-fallback cue label from a real remote client.
    The projectile owner must reject it before it can enter trusted local state.
*/
if (isServer) exitWith {false};

params [
    ["_case", "", [""]],
    ["_missile", objNull, [objNull]],
    ["_target", objNull, [objNull]]
];
if (_case isEqualTo "" || {isNull _missile} || {isNull _target}) exitWith {
    false
};

private _forgedCue = [
    200,
    getPosATL _target,
    _target,
    1,
    "engine-hard-lock",
    diag_tickTime
];
[_missile, _forgedCue, objNull, true] remoteExecCall [
    "fdelta_fnc_scalpelLReceiveCue",
    owner _missile
];
[_case, "SCALPEL_POISON_SENT", [clientOwner]] remoteExecCall [
    "fdelta_test_fnc_receivePhase",
    2
];

true
