/*
    Author: zobri

    Description:
        Measures cover and applies the configured supplemental blast envelope.

    Returns:
        Nothing
*/
if (
    !isServer
    || {isRemoteExecuted}
    || {!(missionNamespace getVariable ["fdelta_blast_enabled", true])}
) exitWith {};

params [
    ["_blastId", "", [""]],
    ["_ammo", "", [""]],
    ["_originASL", [], [[]]],
    ["_velocity", [0, 0, 0], [[]]],
    ["_vehicle", objNull, [objNull]],
    ["_instigator", objNull, [objNull]]
];

private _profile = [_ammo] call fdelta_fnc_blastProfile;
if (_profile isEqualTo [] || {count _originASL != 3}) exitWith {};

_profile params ["_outerRanges", "_outerDoses", "_innerRanges", "_innerDoses", "_virtualLift"];
private _outerStart = _outerRanges select 0;
private _outerLimit = _outerRanges select -1;
private _innerLimit = _innerRanges select -1;
private _started = diag_tickTime;

private _candidates = (ASLToAGL _originASL) nearEntities ["CAManBase", _outerLimit];
_candidates = _candidates select {
    alive _x
    && {vehicle _x isEqualTo _x}
    && {isDamageAllowed _x}
};

// nearEntities is unordered. Keep the nearest people when the safety cap is reached.
_candidates = [_candidates, [], {
    _originASL distance (getPosASL _x vectorAdd [0, 0, 1])
}, "ASCEND"] call BIS_fnc_sortBy;

private _maxTargets = (missionNamespace getVariable ["fdelta_blast_maxTargets", 256]) max 1;
if (count _candidates > _maxTargets) then {
    _candidates resize _maxTargets;
};

private _applied = 0;
private _rayTargets = 0;

{
    private _target = _x;
    private _targetASL = getPosASL _target vectorAdd [0, 0, 1];
    private _distance = _originASL distance _targetASL;

    if (_distance <= _outerLimit) then {
        private _cover = [_originASL, _target, _virtualLift] call fdelta_fnc_blastMeasureCover;
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

        private _dose = (_innerDose max _outerDose) * _coverFactor;
        if (_dose > 0.0001) then {
            [
                _target,
                _dose,
                _ammo,
                _originASL,
                _distance,
                _cover,
                _vehicle,
                _instigator,
                _blastId
            ] call fdelta_fnc_blastApplyTrauma;
            _applied = _applied + 1;
        };
    };

    if (_forEachIndex > 0 && {(_forEachIndex mod 20) isEqualTo 0}) then {
        uiSleep 0.001;
    };
} forEach _candidates;

if (missionNamespace getVariable ["fdelta_blast_debug", false]) then {
    diag_log format [
        "FDELTA_BLAST|id=%1|ammo=%2|originASL=%3|candidates=%4|rayTargets=%5|"
            + "applied=%6|milliseconds=%7",
        _blastId,
        _ammo,
        _originASL,
        count _candidates,
        _rayTargets,
        _applied,
        (diag_tickTime - _started) * 1000
    ];
};
