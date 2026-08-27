/*
    Author: zobri

    Returns the terrain or water position under the center of the active camera.
*/
if (isRemoteExecuted) exitWith {[]};
if !(call fdelta_fnc_terCanUseCamera) exitWith {[]};

private _direction = screenToWorldDirection [0.5, 0.5];
if (count _direction < 3 || {(_direction # 2) >= -0.001}) exitWith {[]};

private _point = screenToWorld [0.5, 0.5];
if (count _point < 2) exitWith {[]};
if (count _point isEqualTo 2) then {
    _point pushBack 0;
};

private _x = _point # 0;
private _y = _point # 1;
if (_x < 0 || {_y < 0} || {_x > worldSize} || {_y > worldSize}) exitWith {[]};

_point
