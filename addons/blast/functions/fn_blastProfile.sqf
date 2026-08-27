/*
    Author: zobri

    Description:
        Returns the exact supplemental blast profile for an ammunition class.

    Parameters:
        0: Ammunition class name <STRING>

    Returns:
        Profile arrays and virtual lift, or an empty array <ARRAY>
*/
params [["_ammo", "", [""]]];

private _cfg = configFile >> "CfgFdeltaBlastProfiles" >> _ammo;
if (!isClass _cfg) exitWith {[]};

private _outerRanges = getArray (_cfg >> "outerRanges");
private _outerDoses = getArray (_cfg >> "outerDoses");
private _innerRanges = getArray (_cfg >> "innerRanges");
private _innerDoses = getArray (_cfg >> "innerDoses");
private _virtualLift = getNumber (_cfg >> "virtualLift");

if (
    count _outerRanges < 2
    || {count _outerRanges != count _outerDoses}
    || {count _innerRanges < 2}
    || {count _innerRanges != count _innerDoses}
) exitWith {[]};

[_outerRanges, _outerDoses, _innerRanges, _innerDoses, _virtualLift]
