/*
    Author: zobri

    Description:
        Computes and applies one supplemental blast on the projectile-owning
        machine. setDamage has global arguments and effects in Arma 3, so no
        custom network or server dispatch is required.
*/
if (isRemoteExecuted) exitWith {};

params [
    ["_ammo", "", [""]],
    ["_originASL", [], [[]]],
    ["_velocity", [0, 0, 0], [[]]],
    ["_profile", [], [[]]],
    ["_vehicle", objNull, [objNull]],
    ["_instigator", objNull, [objNull]]
];
if (
    !(missionNamespace getVariable ["fdelta_blast_enabled", true])
    || {count _originASL isNotEqualTo 3}
    || {count _profile isNotEqualTo 5}
) exitWith {};

// Avoid replacing a still-arriving native damage update with an older remote
// proxy value. Outer-envelope targets normally have no native damage at all.
if (canSuspend) then {uiSleep 0.10;};

_profile params [
    "_outerRanges",
    "_outerDoses",
    "_innerRanges",
    "_innerDoses",
    "_virtualLift"
];
private _outerStart = _outerRanges # 0;
private _outerLimit = _outerRanges # ((count _outerRanges) - 1);
private _innerLimit = _innerRanges # ((count _innerRanges) - 1);
private _started = diag_tickTime;

private _candidates = (ASLToAGL _originASL) nearEntities [
    "CAManBase",
    _outerLimit
];
_candidates = _candidates select {
    alive _x
    && {vehicle _x isEqualTo _x}
    && {isDamageAllowed _x}
};

private _maxTargets = missionNamespace getVariable [
    "fdelta_blast_maxTargets",
    128
];
if !(_maxTargets isEqualType 0 && {finite _maxTargets}) then {
    _maxTargets = 128;
};
_maxTargets = 1 max (256 min floor _maxTargets);
if (count _candidates > _maxTargets) then {
    _candidates = [_candidates, [], {
        _originASL distance (getPosASL _x vectorAdd [0, 0, 1])
    }, "ASCEND"] call BIS_fnc_sortBy;
    _candidates resize _maxTargets;
};

private _multiplier = missionNamespace getVariable [
    "fdelta_blast_damageMultiplier",
    1
];
if !(_multiplier isEqualType 0 && {finite _multiplier}) then {
    _multiplier = 1;
};
_multiplier = 0 max (10 min _multiplier);
private _killer = [_instigator, _vehicle] select (!isNull _vehicle);
private _applied = 0;
private _rayTargets = 0;

{
    private _target = _x;
    private _distance = _originASL distance (
        getPosASL _target vectorAdd [0, 0, 1]
    );
    if (_distance <= _outerLimit) then {
        private _cover = [
            _originASL,
            _target,
            _virtualLift
        ] call fdelta_fnc_blastMeasureCover;
        _cover params ["_coverFactor", "_directBlocked"];
        _rayTargets = _rayTargets + 1;

        private _innerDose = 0;
        if (_directBlocked && {_distance <= _innerLimit}) then {
            _innerDose = [
                _distance,
                _innerRanges,
                _innerDoses
            ] call fdelta_fnc_blastSampleCurve;
        };
        private _outerDose = 0;
        if (_distance >= _outerStart) then {
            _outerDose = [
                _distance,
                _outerRanges,
                _outerDoses
            ] call fdelta_fnc_blastSampleCurve;
        };

        private _increment = (_innerDose max _outerDose)
            * _coverFactor
            * _multiplier;
        if (_increment > 0.0001) then {
            private _before = damage _target;
            private _after = 1 min (_before + _increment);
            if (_after > _before) then {
                _target setDamage [
                    _after,
                    true,
                    _killer,
                    _instigator
                ];
                _applied = _applied + 1;
            };
        };
    };

    // Let the scheduled environment spread unusually dense blasts across
    // frames instead of producing one long script slice.
    if (canSuspend && {_forEachIndex > 0 && {_forEachIndex mod 16 isEqualTo 0}}) then {
        uiSleep 0.001;
    };
} forEach _candidates;

if (missionNamespace getVariable ["fdelta_blast_debug", false]) then {
    diag_log format [
        "FDELTA_BLAST|ammo=%1|originASL=%2|velocity=%3|owner=%4|"
            + "candidates=%5|rayTargets=%6|applied=%7|milliseconds=%8",
        _ammo,
        _originASL,
        _velocity,
        clientOwner,
        count _candidates,
        _rayTargets,
        _applied,
        (diag_tickTime - _started) * 1000
    ];
};
