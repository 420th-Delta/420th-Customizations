params [
    ["_case", "", [""]],
    ["_originASL", [], [[]]]
];

if (_case isEqualTo "" || {count _originASL < 3}) exitWith {};
if (isRemoteExecuted && {remoteExecutedOwner != 2}) exitWith {
    ["SHOT_CREATE_REJECTED", [_case, remoteExecutedOwner]] call fdelta_test_fnc_log;
};

if (isNil "fdelta_test_localProjectiles") then {
    fdelta_test_localProjectiles = createHashMap;
};

private _safeASL = _originASL vectorAdd [0, 0, 800];
private _projectile = createVehicle [
    "Bo_Mk82",
    ASLToAGL _safeASL,
    [],
    0,
    "CAN_COLLIDE"
];
_projectile setPosASL _safeASL;
_projectile setVelocity [0, 0, 0];
_projectile setVariable ["fdelta_test_case", _case, true];

private _deadline = diag_tickTime + 5;
private _networkId = netId _projectile;
waitUntil {
    uiSleep 0.01;
    if (!isNull _projectile) then {_networkId = netId _projectile};
    isNull _projectile
    || {!(_networkId isEqualTo "" || {_networkId isEqualTo "0:0"})}
    || {diag_tickTime >= _deadline}
};

if (isNull _projectile || {_networkId isEqualTo ""} || {_networkId isEqualTo "0:0"}) exitWith {
    ["SHOT_CREATE_FAILED", [_case, _networkId]] call fdelta_test_fnc_log;
    [_case, "CREATE_FAILED", [_networkId]] remoteExecCall ["fdelta_test_fnc_receivePhase", 2];
};

fdelta_test_localProjectiles set [_case, _projectile];
private _cfg = configFile >> "CfgAmmo" >> "Bo_Mk82";
private _data = [
    _networkId,
    local _projectile,
    owner _projectile,
    getPosASL _projectile,
    getNumber (_cfg >> "hit"),
    getNumber (_cfg >> "indirectHit"),
    getNumber (_cfg >> "indirectHitRange"),
    configSourceAddonList _cfg
];

["SHOT_READY", [_case, _data]] call fdelta_test_fnc_log;
[_case, "READY", _data] remoteExecCall ["fdelta_test_fnc_receivePhase", 2];
