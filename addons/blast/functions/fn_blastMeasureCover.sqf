/*
    Author: zobri

    Description:
        Estimates blast transmission through terrain and object cover.

    Parameters:
        0: Explosion position ASL <ARRAY>
        1: Target unit <OBJECT>
        2: Virtual origin lift in metres <NUMBER>

    Returns:
        Cover factor and diagnostic data <ARRAY>
*/
if (isRemoteExecuted) exitWith {[0, true, false, false, [], []]};

params [
    ["_originASL", [], [[]]],
    ["_target", objNull, [objNull]],
    ["_virtualLift", 4, [0]]
];

if (count _originASL != 3 || {isNull _target}) exitWith {
    [0, true, false, false, [], []]
};

private _targetBaseASL = getPosASL _target;
private _lowOrigin = _originASL vectorAdd [0, 0, 0.15];
private _torso = _targetBaseASL vectorAdd [0, 0, 1.0];
private _allObjects = [];
private _allSurfaces = [];

private _trace = {
    params ["_fromASL", "_toASL"];

    private _terrain = terrainIntersectASL [_fromASL, _toASL];
    private _hits = lineIntersectsSurfaces [
        _fromASL,
        _toASL,
        objNull,
        _target,
        true,
        16,
        "IFIRE",
        "NONE",
        false
    ];
    private _objectBlocked = false;

    {
        private _object = _x param [2, objNull, [objNull]];
        private _parent = _x param [3, objNull, [objNull]];
        private _blocker = [_object, _parent] select (!isNull _parent);
        private _surface = _x param [5, "", [""]];

        if (!isNull _blocker) then {
            _objectBlocked = true;
            _allObjects pushBackUnique _blocker;
        };
        if (_surface isNotEqualTo "") then {
            _allSurfaces pushBackUnique _surface;
        };
    } forEach _hits;

    [_terrain, _objectBlocked]
};

private _direct = [_lowOrigin, _torso] call _trace;
_direct params ["_directTerrain", "_directObject"];
private _directBlocked = _directTerrain || _directObject;

if (!_directBlocked) exitWith {[1, false, false, false, [], []]};

private _terrainAtOrigin = getTerrainHeightASL [_originASL select 0, _originASL select 1];
private _airburst = (_originASL select 2) - _terrainAtOrigin > 2;
private _lift = if (_airburst) then {0} else {_virtualLift max 0};
private _targetHeights = [0.45, 1.0, 1.65];
private _raisedClear = 0;
private _raisedTerrainClear = 0;
private _raisedObjectClear = 0;

for "_index" from 0 to 2 do {
    private _fraction = (_index + 1) / 3;
    private _raisedOrigin = _originASL vectorAdd [0, 0, 0.15 + (_lift * _fraction)];
    private _targetPoint = _targetBaseASL vectorAdd [0, 0, _targetHeights select _index];
    private _result = [_raisedOrigin, _targetPoint] call _trace;
    _result params ["_terrainBlocked", "_objectBlocked"];

    if (!_terrainBlocked) then {_raisedTerrainClear = _raisedTerrainClear + 1};
    if (!_objectBlocked) then {_raisedObjectClear = _raisedObjectClear + 1};
    if (!_terrainBlocked && {!_objectBlocked}) then {_raisedClear = _raisedClear + 1};
};

private _hasRock = false;
private _hasHardCover = false;
private _hasLightCover = false;

{
    private _name = toLower typeOf _x;
    if (
        _name find "rock" >= 0
        || {_name find "stone" >= 0}
        || {_name find "boulder" >= 0}
    ) then {
        _hasRock = true;
    } else {
        if (
            _name find "concrete" >= 0
            || {_name find "wall" >= 0}
            || {_name find "bunker" >= 0}
            || {_name find "house" >= 0}
            || {_name find "building" >= 0}
            || {_name find "hangar" >= 0}
            || {_x isKindOf "House"}
        ) then {
            _hasHardCover = true;
        };
    };

    if (_name find "fence" >= 0 || {_name find "wire" >= 0}) then {
        _hasLightCover = true;
    };
} forEach _allObjects;

{
    private _surface = toLower _x;
    if (_surface find "rock" >= 0 || {_surface find "stone" >= 0}) then {
        _hasRock = true;
    };
    if (_surface find "concrete" >= 0 || {_surface find "metal" >= 0}) then {
        _hasHardCover = true;
    };
    if (_surface find "wood" >= 0 || {_surface find "fence" >= 0}) then {
        _hasLightCover = true;
    };
} forEach _allSurfaces;

private _terrainFactor = 1;
if (_directTerrain) then {
    _terrainFactor = [0.35, 0.95] select (_raisedTerrainClear > 0);
};

private _objectFactor = 1;
if (_directObject) then {
    if (_hasHardCover) then {
        _objectFactor = [0.20, 0.35] select (_raisedObjectClear > 0);
    } else {
        if (_hasRock) then {
            _objectFactor = [0.40, 0.85] select (_raisedObjectClear > 0);
        } else {
            if (_hasLightCover) then {
                _objectFactor = 0.75;
            } else {
                _objectFactor = [0.40, 0.65] select (_raisedObjectClear > 0);
            };
        };
    };
};

private _factor = _terrainFactor * _objectFactor;
if (count _allObjects > 1) then {_factor = _factor * 0.75};
_factor = 0.08 max (_factor min 1);

[
    _factor,
    _directBlocked,
    _directTerrain,
    _directObject,
    _allObjects apply {typeOf _x},
    _allSurfaces,
    _raisedClear,
    _airburst
]
