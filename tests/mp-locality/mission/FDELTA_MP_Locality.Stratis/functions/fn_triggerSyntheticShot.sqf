params [
    ["_case", "", [""]],
    ["_originASL", [], [[]]]
];

if (_case isEqualTo "" || {count _originASL < 3}) exitWith {};
if (isRemoteExecuted && {remoteExecutedOwner != 2}) exitWith {
    ["SHOT_TRIGGER_REJECTED", [_case, remoteExecutedOwner]] call fdelta_test_fnc_log;
};

private _projectile = if (isNil "fdelta_test_localProjectiles") then {
    objNull
} else {
    fdelta_test_localProjectiles getOrDefault [_case, objNull]
};

if (isNull _projectile || {!local _projectile}) exitWith {
    ["SHOT_TRIGGER_FAILED", [_case, isNull _projectile]] call fdelta_test_fnc_log;
    [_case, "TRIGGER_FAILED", []] remoteExecCall ["fdelta_test_fnc_receivePhase", 2];
};

// First move near the impact point, but safely above terrain, and allow that
// position to replicate to the server proxy. The final 18 m hop then remains
// inside BP's minimum evidence tolerance even under network latency.
private _stagingASL = _originASL vectorAdd [0, 0, 20];
_projectile setPosASL _stagingASL;
_projectile setVelocity [0, 0, 0];
uiSleep 1;

private _detonationASL = _originASL vectorAdd [0, 0, 2];
_projectile setPosASL _detonationASL;
_projectile setVelocity [0, 0, 0];
uiSleep 0.1;

private _data = [
    netId _projectile,
    local _projectile,
    owner _projectile,
    getPosASL _projectile
];

["SHOT_TRIGGER", [_case, _data, _detonationASL]] call fdelta_test_fnc_log;
[_case, "TRIGGERED", _data] remoteExecCall ["fdelta_test_fnc_receivePhase", 2];
triggerAmmo _projectile;

fdelta_test_localProjectiles deleteAt _case;


