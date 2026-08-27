params [
    ["_case", "", [""]],
    ["_originASL", [], [[]]]
];

if (_case isEqualTo "" || {count _originASL < 3}) exitWith {};
if (isRemoteExecuted && {remoteExecutedOwner != 2}) exitWith {
    ["WEAPON_SHOT_REJECTED", [_case, remoteExecutedOwner]]
        call fdelta_test_fnc_log;
};
if (!hasInterface || {isNull player}) exitWith {
    ["WEAPON_SHOT_FAILED", [_case, "NO_INTERFACE_PLAYER"]]
        call fdelta_test_fnc_log;
    [_case, "WEAPON_FAILED", ["NO_INTERFACE_PLAYER"]]
        remoteExecCall ["fdelta_test_fnc_receivePhase", 2];
};

if (isNil "fdelta_test_localProjectiles") then {
    fdelta_test_localProjectiles = createHashMap;
};
if (isNil "fdelta_test_weaponPlatforms") then {
    fdelta_test_weaponPlatforms = createHashMap;
};

// The aircraft remains far above the test area. The Fired event immediately
// captures its real weapon projectile and parks that projectile at a safe
// altitude for the same controlled detonation used by the locality matrix.
private _aircraftASL = _originASL vectorAdd [0, 0, 1400];
private _holdASL = _originASL vectorAdd [0, 0, 900];
private _aircraft = createVehicle [
    "I_Plane_Fighter_03_CAS_F",
    ASLToAGL _aircraftASL,
    [],
    0,
    "FLY"
];
_aircraft setPosASL _aircraftASL;
_aircraft setDir 0;
_aircraft setVelocity [0, 150, 0];
_aircraft allowDamage false;
_aircraft setVariable ["fdelta_test_weaponCase", _case];
_aircraft setVariable ["fdelta_test_holdASL", _holdASL];
_aircraft setVariable ["fdelta_test_weaponProjectile", objNull];
_aircraft setVariable ["fdelta_test_weaponFiredData", []];

player allowDamage false;
player moveInDriver _aircraft;

private _localityDeadline = diag_tickTime + 5;
waitUntil {
    uiSleep 0.05;
    (local _aircraft && {driver _aircraft isEqualTo player})
    || {diag_tickTime >= _localityDeadline}
};

if (!local _aircraft || {driver _aircraft isNotEqualTo player}) exitWith {
    private _failure = [
        "AIRCRAFT_NOT_LOCAL",
        local _aircraft,
        owner _aircraft,
        typeOf driver _aircraft
    ];
    ["WEAPON_SHOT_FAILED", [_case, _failure]] call fdelta_test_fnc_log;
    [_case, "WEAPON_FAILED", _failure]
        remoteExecCall ["fdelta_test_fnc_receivePhase", 2];
};

private _weapon = "Mk82BombLauncher";
private _magazine = "2Rnd_Mk82";
if !(_weapon in (_aircraft weaponsTurret [-1])) then {
    _aircraft addWeaponTurret [_weapon, [-1]];
};
if !(_magazine in (magazines _aircraft)) then {
    _aircraft addMagazineTurret [_magazine, [-1], 2];
};
_aircraft setVehicleAmmo 1;

private _firedEH = _aircraft addEventHandler ["Fired", {
    params [
        "_vehicle",
        "_weapon",
        "_muzzle",
        "_mode",
        "_ammo",
        "_magazine",
        "_projectile",
        "_gunner"
    ];

    private _case = _vehicle getVariable ["fdelta_test_weaponCase", ""];
    private _firedData = [
        _weapon,
        _muzzle,
        _mode,
        _ammo,
        _magazine,
        typeOf _gunner,
        local _projectile,
        owner _projectile,
        netId _projectile,
        getShotParents _projectile
    ];
    ["WEAPON_FIRED", [_case, _firedData]] call fdelta_test_fnc_log;

    if (_ammo isEqualTo "Bo_Mk82" && {!isNull _projectile}) then {
        _projectile setVariable ["fdelta_test_case", _case, true];
        _projectile setPosASL (
            _vehicle getVariable ["fdelta_test_holdASL", getPosASL _projectile]
        );
        _projectile setVelocity [0, 0, 0];
        _vehicle setVariable ["fdelta_test_weaponProjectile", _projectile];
        _vehicle setVariable ["fdelta_test_weaponFiredData", _firedData];
    };
}];

private _preFire = [
    typeOf _aircraft,
    local _aircraft,
    owner _aircraft,
    typeOf driver _aircraft,
    _aircraft weaponsTurret [-1],
    magazinesAllTurrets _aircraft,
    getAllPylonsInfo _aircraft
];
["WEAPON_FIRE_BEGIN", [_case, _preFire]] call fdelta_test_fnc_log;

_aircraft selectWeaponTurret [_weapon, [-1]];
uiSleep 0.25;
player forceWeaponFire [_weapon, _weapon];

private _projectile = objNull;
private _fireDeadline = diag_tickTime + 5;
waitUntil {
    uiSleep 0.02;
    _projectile = _aircraft getVariable [
        "fdelta_test_weaponProjectile",
        objNull
    ];
    !isNull _projectile || {diag_tickTime >= _fireDeadline}
};

if (isNull _projectile) exitWith {
    _aircraft removeEventHandler ["Fired", _firedEH];
    private _failure = [
        "NO_MK82_FIRED",
        _preFire,
        _aircraft currentWeaponTurret [-1],
        _aircraft currentMagazineTurret [-1]
    ];
    ["WEAPON_SHOT_FAILED", [_case, _failure]] call fdelta_test_fnc_log;
    [_case, "WEAPON_FAILED", _failure]
        remoteExecCall ["fdelta_test_fnc_receivePhase", 2];
};

private _networkDeadline = diag_tickTime + 5;
private _networkId = netId _projectile;
waitUntil {
    uiSleep 0.01;
    if (!isNull _projectile) then {_networkId = netId _projectile};
    isNull _projectile
    || {!(_networkId isEqualTo "" || {_networkId isEqualTo "0:0"})}
    || {diag_tickTime >= _networkDeadline}
};

if (
    isNull _projectile
    || {_networkId isEqualTo ""}
    || {_networkId isEqualTo "0:0"}
) exitWith {
    _aircraft removeEventHandler ["Fired", _firedEH];
    ["WEAPON_SHOT_FAILED", [_case, "NO_PROJECTILE_NETID", _networkId]]
        call fdelta_test_fnc_log;
    [_case, "WEAPON_FAILED", ["NO_PROJECTILE_NETID", _networkId]]
        remoteExecCall ["fdelta_test_fnc_receivePhase", 2];
};

fdelta_test_localProjectiles set [_case, _projectile];
fdelta_test_weaponPlatforms set [_case, _aircraft];

private _parents = getShotParents _projectile;
private _data = [
    _networkId,
    local _projectile,
    owner _projectile,
    getPosASL _projectile,
    _aircraft getVariable ["fdelta_test_weaponFiredData", []],
    typeOf (_parents param [0, objNull]),
    typeOf (_parents param [1, objNull]),
    local _aircraft,
    owner _aircraft
];

["WEAPON_SHOT_READY", [_case, _data]] call fdelta_test_fnc_log;
[_case, "WEAPON_READY", _data]
    remoteExecCall ["fdelta_test_fnc_receivePhase", 2];


