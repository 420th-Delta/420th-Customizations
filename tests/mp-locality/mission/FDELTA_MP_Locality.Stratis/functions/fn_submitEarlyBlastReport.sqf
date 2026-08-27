/*
    Moves a locally owned test projectile to its impact track and submits a
    plausible report while it is still alive. The server should reserve that
    report without consuming it until termination or locality replacement.
*/
params [
    ["_case", "", [""]],
    ["_originASL", [], [[]]]
];

if (_case isEqualTo "" || {count _originASL != 3}) exitWith {};
if (isRemoteExecuted && {remoteExecutedOwner != 2}) exitWith {
    ["EARLY_REPORT_REJECTED", [_case, remoteExecutedOwner]]
        call fdelta_test_fnc_log;
};

private _projectile = if (isNil "fdelta_test_localProjectiles") then {
    objNull
} else {
    fdelta_test_localProjectiles getOrDefault [_case, objNull]
};
if (isNull _projectile || {!local _projectile}) exitWith {
    [_case, "EARLY_REPORT_FAILED", [isNull _projectile]] remoteExecCall [
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
[_key, _detonationASL, [0, 0, 0]] remoteExecCall [
    "fdelta_fnc_blastReceiveBlast",
    2
];
[_case, "EARLY_REPORTED", [
    _key,
    local _projectile,
    owner _projectile,
    getPosASL _projectile
]] remoteExecCall ["fdelta_test_fnc_receivePhase", 2];

["EARLY_REPORT_SENT", [_case, _key, _detonationASL]]
    call fdelta_test_fnc_log;
