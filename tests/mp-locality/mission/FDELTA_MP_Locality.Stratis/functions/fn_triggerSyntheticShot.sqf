params [
    ["_case", "", [""]],
    ["_originASL", [], [[]]],
    ["_stageOnly", false, [false]]
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

// Replicate the controlled impact position before detonation. In transfer
// cases the server takes ownership after this step and detonates locally.
private _stagingASL = _originASL vectorAdd [0, 0, 20];
_projectile setPosASL _stagingASL;
_projectile setVelocity [0, 0, 0];
uiSleep 0.25;

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

private _phase = ["TRIGGERED", "STAGED"] select _stageOnly;
["SHOT_" + _phase, [_case, _data, _detonationASL]]
    call fdelta_test_fnc_log;
[_case, _phase, _data] remoteExecCall ["fdelta_test_fnc_receivePhase", 2];

if (_stageOnly) exitWith {};

triggerAmmo _projectile;

fdelta_test_localProjectiles deleteAt _case;

private _platform = if (isNil "fdelta_test_weaponPlatforms") then {
    objNull
} else {
    fdelta_test_weaponPlatforms getOrDefault [_case, objNull]
};
if (!isNull _platform) then {
    moveOut player;
    uiSleep 0.5;
    deleteVehicle _platform;
    fdelta_test_weaponPlatforms deleteAt _case;
};
