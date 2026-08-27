/*
    Author: zobri

    Traces the firing camera or launcher axis once and returns a fixed ATL
    aimpoint for coordinate guidance.
*/
if (isRemoteExecuted) exitWith {[]};

params ["_launcher", "_weapon", "_missile", ["_operator", objNull], ["_useCamera", false]];

private _ammoConfig = configOf _missile;
private _maximumRange = getNumber (_ammoConfig >> "fdelta_scalpelL_aimRange");
if (_maximumRange <= 0) then {_maximumRange = 6000;};

private _originASL = getPosASL _missile;
private _direction = vectorNormalized velocity _missile;

if (_useCamera && {hasInterface}) then {
    _originASL = AGLToASL (positionCameraToWorld [0, 0, 0]);
    _direction = vectorNormalized (screenToWorldDirection [0.5, 0.5]);
}
else {
    private _weaponDirection = _launcher weaponDirection _weapon;
    if ((vectorMagnitude _weaponDirection) > 0.1) then {
        _direction = vectorNormalized _weaponDirection;
    };
};

if ((vectorMagnitude _direction) < 0.1) then {
    _direction = vectorDir _launcher;
};

private _endASL = _originASL vectorAdd (_direction vectorMultiply _maximumRange);
private _intersections = lineIntersectsSurfaces
[
    _originASL,
    _endASL,
    _launcher,
    _operator,
    true,
    1,
    "VIEW",
    "FIRE"
];

if (_intersections isEqualTo []) exitWith {ASLToATL _endASL};
ASLToATL ((_intersections # 0) # 0)
