/*
    BIS_fnc_pylon_ECMPodIncoming
    Called by the vehicle's IncomingMissile EH when a missile is detected.

    Parameters (forwarded from IncomingMissile EH):
        _vehicle    - vehicle that detected the missile (target)  [Object]
        _ammo       - ammo classname of the incoming missile  [String]
        _firer      - vehicle that fired (unused)  [Object]
        _instigator - person who pulled the trigger (unused)  [Object]
        _missile    - the missile object  [Object]
*/
params ["_vehicle","_ammo","","","_missile"];

if (isNull _missile) exitWith {};

// Tracking and jamming must only run where the vehicle is local
if (!local _vehicle) exitWith {};

private _ammoCfg = configFile >> "CfgAmmo" >> _ammo;
private _isIR = (
    getNumber (_ammoCfg >> "irLock") > 0
    || {isClass (_ammoCfg >> "Components" >> "SensorsManagerComponent" >> "Components" >> "IRSensorComponent")}
);

// --- Append to tracked-missile array (guard against duplicates) ---
private _tracked = _vehicle getVariable ["bis_pylon_ecmTracked", []];
if (_missile in (_tracked apply { _x # 0 })) exitWith {};

_tracked pushBack [_missile, _isIR];
_vehicle setVariable ["bis_pylon_ecmTracked", _tracked];

// --- Start the single per-vehicle tracking handler if not running ---
if (_vehicle getVariable ["bis_pylon_ecmTrackRunning", false]) exitWith {};

// Build pod data cache once — stored in handler args so Track never reads CfgMagazines.
// Each element: [_pod, _proxy, _pylonName, _ecmCfg, _type, _sensorPos, _sensorDir, _sensorAngle, _sensorRange]
private _allPylons = getAllPylonsInfo _vehicle;
private _ecmPylons = _allPylons select { (_x # 3) isKindOf ["PylonECMPod_Base", configFile >> "CfgMagazines"] };

private _podData = _ecmPylons apply
{
    private _pod        = _x;
    private _proxy      = _pod # 7;
    private _pylonName  = _pod # 0;
    private _magClass   = _pod # 3;
    private _ecmCfg     = configFile >> "CfgMagazines" >> _magClass >> "ECMSystem";
    [
        _pod,
        _proxy,
        _pylonName,
        _ecmCfg,
        [_ecmCfg, "type",        ""]     call BIS_fnc_returnConfigEntry,
        [_ecmCfg, "sensorPos",   []]     call BIS_fnc_returnConfigEntry,
        [_ecmCfg, "sensorDir",   []]     call BIS_fnc_returnConfigEntry,
        [_ecmCfg, "sensorAngle", [0]]    call BIS_fnc_returnConfigEntry,
        [_ecmCfg, "sensorRange",   [2000]] call BIS_fnc_returnConfigEntry,
        [_ecmCfg, "flareCooldown", 2]      call BIS_fnc_returnConfigEntry
    ]
};

private _handlerId = format ["bis_pylon_ecmTrack_%1", netId _vehicle];
private _interval  = 0.05;

_vehicle setVariable ["bis_pylon_ecmTrackRunning", true];
[
    _handlerId,
    "onEachFrame",
    { _this call BIS_fnc_pylon_ECMPodTrack },
    [_vehicle, _handlerId, _interval, time, _podData]
] call BIS_fnc_addStackedEventHandler;
