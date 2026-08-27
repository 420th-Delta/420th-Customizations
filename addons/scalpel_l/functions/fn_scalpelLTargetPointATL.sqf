/*
    Author: zobri

    Resolves a target object's current aiming point in ATL coordinates.
*/
if (isRemoteExecuted) exitWith {[]};

params ["_target"];

if (isNull _target) exitWith {[]};

private _positionATL = getPosATL _target;
if (_target isKindOf "LaserTarget") exitWith {_positionATL};

// Aim at the model centre for a vehicle snapshot. If terminal acquisition
// never succeeds, the stationary cue remains close enough to carry the
// missile into the intended target area and ultimately into the terrain.
private _bounds = boundingBoxReal _target;
if ((count _bounds) >= 2) then {
    private _minimum = _bounds # 0;
    private _maximum = _bounds # 1;
    private _centreModel =
    [
        ((_minimum # 0) + (_maximum # 0)) * 0.5,
        ((_minimum # 1) + (_maximum # 1)) * 0.5,
        ((_minimum # 2) + (_maximum # 2)) * 0.5
    ];
    _positionATL = ASLToATL (AGLToASL (_target modelToWorldVisual _centreModel));
};

_positionATL
