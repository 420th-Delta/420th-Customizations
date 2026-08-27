/*
    Author: zobri

    Description:
        Returns the exact supplemental blast profile for an ammunition class.

    Parameters:
        0: Ammunition class name <STRING>

    Returns:
        Profile arrays and virtual lift, or an empty array <ARRAY>
*/
if (isRemoteExecuted) exitWith {[]};
if !(
    _this isEqualType []
    && {count _this isEqualTo 1}
    && {(_this # 0) isEqualType ""}
) exitWith {[]};
private _ammo = _this # 0;

private _resolver = localNamespace getVariable [
    "fdelta_blast_resolveProfile",
    {[]}
];
[_ammo] call _resolver
