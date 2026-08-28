/*
    Author: zobri

    Description:
        Estimates blast transmission with one direct and one raised ray.

    Returns:
        [cover factor, direct blocked, terrain blocked, object blocked,
        raised clear]
*/
if (isRemoteExecuted) exitWith {[0, true, false, false, false]};

params [
    ["_originASL", [], [[]]],
    ["_target", objNull, [objNull]],
    ["_virtualLift", 4, [0]]
];
if (count _originASL isNotEqualTo 3 || {isNull _target}) exitWith {
    [0, true, false, false, false]
};

private _targetBaseASL = getPosASL _target;
private _trace = {
    params ["_fromASL", "_toASL"];
    private _hits = lineIntersectsSurfaces [
        _fromASL,
        _toASL,
        objNull,
        _target,
        true,
        1,
        "IFIRE",
        "NONE",
        false
    ];
    private _hit = _hits param [0, []];
    private _object = _hit param [2, objNull, [objNull]];
    private _parent = _hit param [3, objNull, [objNull]];
    private _blocker = [_object, _parent] select (!isNull _parent);
    private _terrain = _hit isNotEqualTo [] && {isNull _blocker};
    [_terrain, !isNull _blocker, _blocker, _hit param [5, "", [""]]]
};

private _direct = [
    _originASL vectorAdd [0, 0, 0.15],
    _targetBaseASL vectorAdd [0, 0, 1.0]
] call _trace;
_direct params ["_directTerrain", "_directObject", "_blocker", "_surface"];
private _directBlocked = _directTerrain || _directObject;
if (!_directBlocked) exitWith {[1, false, false, false, true]};

private _terrainHeight = getTerrainHeightASL [_originASL # 0, _originASL # 1];
private _lift = if ((_originASL # 2) - _terrainHeight > 2) then {
    0
} else {
    _virtualLift max 0
};
private _raised = [
    _originASL vectorAdd [0, 0, 0.15 + _lift],
    _targetBaseASL vectorAdd [0, 0, 1.55]
] call _trace;
_raised params ["_raisedTerrain", "_raisedObject"];
private _raisedClear = !_raisedTerrain && {!_raisedObject};

private _terrainFactor = 1;
if (_directTerrain) then {
    _terrainFactor = [0.35, 0.95] select (!_raisedTerrain);
};

private _objectFactor = 1;
if (_directObject) then {
    private _identity = toLower format ["%1 %2", typeOf _blocker, _surface];
    private _hard = _blocker isKindOf "House"
        || {_identity find "concrete" >= 0}
        || {_identity find "metal" >= 0}
        || {_identity find "wall" >= 0}
        || {_identity find "bunker" >= 0}
        || {_identity find "building" >= 0}
        || {_identity find "hangar" >= 0};
    private _rock = _identity find "rock" >= 0
        || {_identity find "stone" >= 0}
        || {_identity find "boulder" >= 0};
    private _light = _identity find "fence" >= 0
        || {_identity find "wire" >= 0}
        || {_identity find "wood" >= 0};

    if (_hard) then {
        _objectFactor = [0.20, 0.35] select (!_raisedObject);
    } else {
        if (_rock) then {
            _objectFactor = [0.40, 0.85] select (!_raisedObject);
        } else {
            if (_light) then {
                _objectFactor = 0.75;
            } else {
                _objectFactor = [0.40, 0.65] select (!_raisedObject);
            };
        };
    };
};

private _factor = 0.08 max ((_terrainFactor * _objectFactor) min 1);
[_factor, true, _directTerrain, _directObject, _raisedClear]
