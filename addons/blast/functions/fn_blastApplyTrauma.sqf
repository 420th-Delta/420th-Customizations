/*
    Author: zobri

    Description:
        Applies one server-authoritative supplemental trauma dose.

    Returns:
        Nothing
*/
if (!isServer || {isRemoteExecuted}) exitWith {};

params [
    ["_target", objNull, [objNull]],
    ["_dose", 0, [0]],
    ["_ammo", "", [""]],
    ["_originASL", [], [[]]],
    ["_distance", 0, [0]],
    ["_cover", [], [[]]],
    ["_vehicle", objNull, [objNull]],
    ["_instigator", objNull, [objNull]],
    ["_blastId", "", [""]]
];

if (isNull _target || {!alive _target} || {_dose <= 0}) exitWith {};

private _now = diag_tickTime;
private _targetKey = [hashValue _target, netId _target];
private _traumaRegistry = localNamespace getVariable [
    "fdelta_blast_traumaRegistry",
    createHashMap
];
private _state = _traumaRegistry getOrDefault [
    _targetKey,
    [objNull, 0, _now]
];
private _stateTarget = _state param [0, objNull, [objNull]];
private _oldLoad = _state param [1, 0, [0]];
private _lastTime = _state param [2, _now, [0]];
if (
    _stateTarget isNotEqualTo _target
    || {!finite _oldLoad}
    || {_oldLoad < 0}
    || {!finite _lastTime}
    || {_lastTime < 0}
    || {_lastTime > _now}
) then {
    _oldLoad = 0;
    _lastTime = _now;
};

private _settings = localNamespace getVariable ["fdelta_blast_settings", createHashMap];
private _halfLife = _settings getOrDefault ["fdelta_blast_halfLife", 1800];
private _decay = 0.5 ^ (((_now - _lastTime) max 0) / _halfLife);
private _decayedLoad = _oldLoad * _decay;

private _multiplier = _settings getOrDefault ["fdelta_blast_damageMultiplier", 1];
private _scaledDose = _dose * _multiplier;
private _gain = _settings getOrDefault ["fdelta_blast_cumulativeGain", 0.5];
private _increment = _scaledDose * (1 + (_gain * (_decayedLoad min 1)));
private _newLoad = _decayedLoad + _scaledDose;
private _before = damage _target;
private _after = 1 min (_before + _increment);
private _killer = [_instigator, _vehicle] select (!isNull _vehicle);

_traumaRegistry set [_targetKey, [_target, _newLoad, _now]];
localNamespace setVariable ["fdelta_blast_traumaRegistry", _traumaRegistry];

// Object variables are diagnostics only and are never read for damage. Even if
// a client publicizes replacements, cumulative state remains server-local.
_target setVariable ["fdelta_blast_traumaState", [_newLoad, _now]];
_target setVariable ["fdelta_blast_lastDose", _scaledDose];
_target setVariable ["fdelta_blast_lastIncrement", _increment];
_target setVariable [
    "fdelta_blast_lastBlast",
    [_blastId, _ammo, _distance, _cover, _originASL]
];
_target setDamage [_after, true, _killer, _instigator];

if (isPlayer _target) then {
    if (local _target && {hasInterface}) then {
        [_target, _scaledDose] call fdelta_fnc_blastClientEffect;
    } else {
        [_target, _scaledDose] remoteExecCall ["fdelta_fnc_blastClientEffect", owner _target];
    };
};

if (_settings getOrDefault ["fdelta_blast_debug", false]) then {
    diag_log format [
        "FDELTA_BLAST_RESULT|id=%1|ammo=%2|target=%3|distance=%4|dose=%5|load=%6|"
            + "increment=%7|damage=%8>%9|cover=%10",
        _blastId,
        _ammo,
        typeOf _target,
        _distance,
        _scaledDose,
        _newLoad,
        _increment,
        _before,
        _after,
        _cover
    ];
};
