/*
    Author: zobri

    Description:
        Linearly samples a distance/dose curve.

    Parameters:
        0: Distance <NUMBER>
        1: Ordered distance samples <ARRAY>
        2: Dose samples <ARRAY>

    Returns:
        Interpolated dose <NUMBER>
*/
if (isRemoteExecuted) exitWith {0};

params [
    ["_distance", 0, [0]],
    ["_ranges", [], [[]]],
    ["_values", [], [[]]]
];

if (count _ranges < 2 || {count _ranges != count _values}) exitWith {0};
if (_distance < (_ranges select 0)) exitWith {_values select 0};
if (_distance > (_ranges select -1)) exitWith {0};

private _result = _values select -1;
for "_index" from 1 to (count _ranges - 1) do {
    private _upperRange = _ranges select _index;
    if (_distance <= _upperRange) exitWith {
        private _lowerRange = _ranges select (_index - 1);
        private _lowerValue = _values select (_index - 1);
        private _upperValue = _values select _index;
        private _fraction = (_distance - _lowerRange) / ((_upperRange - _lowerRange) max 0.001);
        _result = _lowerValue + ((_upperValue - _lowerValue) * _fraction);
    };
};

_result
