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

private _now = serverTime;
private _state = _target getVariable ["fdelta_blast_traumaState", [0, _now]];
private _oldLoad = _state param [0, 0, [0]];
private _lastTime = _state param [1, _now, [0]];
private _halfLife = (missionNamespace getVariable ["fdelta_blast_halfLife", 1800]) max 1;
private _decay = 0.5 ^ (((_now - _lastTime) max 0) / _halfLife);
private _decayedLoad = _oldLoad * _decay;

private _multiplier = (missionNamespace getVariable ["fdelta_blast_damageMultiplier", 1]) max 0;
private _scaledDose = _dose * _multiplier;
private _gain = (missionNamespace getVariable ["fdelta_blast_cumulativeGain", 0.5]) max 0;
private _increment = _scaledDose * (1 + (_gain * (_decayedLoad min 1)));
private _newLoad = _decayedLoad + _scaledDose;
private _before = damage _target;
private _after = 1 min (_before + _increment);
private _killer = [_instigator, _vehicle] select (!isNull _vehicle);

// These diagnostics stay server-local. setDamage remains globally authoritative.
_target setVariable ["fdelta_blast_traumaState", [_newLoad, _now]];
_target setVariable ["fdelta_blast_lastDose", _scaledDose];
_target setVariable ["fdelta_blast_lastIncrement", _increment];
_target setVariable ["fdelta_blast_lastBlast", [_blastId, _ammo, _distance, _cover]];
_target setDamage [_after, true, _killer, _instigator];

if (isPlayer _target) then {
    if (local _target && {hasInterface}) then {
        [_target, _scaledDose] call fdelta_fnc_blastClientEffect;
    } else {
        [_target, _scaledDose] remoteExecCall ["fdelta_fnc_blastClientEffect", owner _target];
    };
};

if (missionNamespace getVariable ["fdelta_blast_debug", false]) then {
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
