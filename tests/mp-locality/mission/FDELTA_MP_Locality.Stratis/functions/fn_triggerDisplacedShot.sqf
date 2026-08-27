/*
    Reserves a plausible but displaced caller position before terminating the
    projectile at the server-observed track. Blast damage must use the latter.
*/
params [
    ["_case", "", [""]],
    ["_originASL", [], [[]]],
    ["_reportedASL", [], [[]]]
];

if (
    _case isEqualTo ""
    || {count _originASL != 3}
    || {count _reportedASL != 3}
) exitWith {};
if (isRemoteExecuted && {remoteExecutedOwner != 2}) exitWith {
    ["DISPLACED_TRIGGER_REJECTED", [_case, remoteExecutedOwner]]
        call fdelta_test_fnc_log;
};

private _projectile = if (isNil "fdelta_test_localProjectiles") then {
    objNull
} else {
    fdelta_test_localProjectiles getOrDefault [_case, objNull]
};
if (isNull _projectile || {!local _projectile}) exitWith {
    [_case, "TRIGGER_FAILED", [isNull _projectile]] remoteExecCall [
        "fdelta_test_fnc_receivePhase",
        2
    ];
};

private _stagingASL = _originASL vectorAdd [0, 0, 20];
_projectile setPosASL _stagingASL;
_projectile setVelocity [0, 0, 0];
uiSleep 1;

private _detonationASL = _originASL vectorAdd [0, 0, 2];
_projectile setPosASL _detonationASL;
_projectile setVelocity [0, 0, 0];
uiSleep 0.15;

private _key = netId _projectile;
[_key, _reportedASL, [0, 0, 0]] remoteExecCall [
    "fdelta_fnc_blastReceiveBlast",
    2
];
uiSleep 0.25;

private _data = [
    _key,
    local _projectile,
    owner _projectile,
    getPosASL _projectile,
    _reportedASL
];
["DISPLACED_TRIGGER", [_case, _data, _detonationASL]]
    call fdelta_test_fnc_log;
[_case, "TRIGGERED", _data] remoteExecCall [
    "fdelta_test_fnc_receivePhase",
    2
];
triggerAmmo _projectile;

fdelta_test_localProjectiles deleteAt _case;
