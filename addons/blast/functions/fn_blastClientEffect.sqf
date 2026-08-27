/*
    Author: zobri

    Description:
        Applies the local camera response for a server-authorized blast dose.

    Parameters:
        0: Affected player unit <OBJECT>
        1: Supplemental dose <NUMBER>

    Returns:
        Nothing
*/
// Clients may never make another client's camera shake.
if (isRemoteExecuted && {remoteExecutedOwner != 2}) exitWith {};
if !(
    _this isEqualType []
    && {count _this isEqualTo 2}
    && {(_this # 0) isEqualType objNull}
    && {(_this # 1) isEqualType 0}
) exitWith {};
private _unit = _this # 0;
private _dose = _this # 1;
if (!hasInterface || {isNull _unit} || {_unit isNotEqualTo player} || {_dose <= 0}) exitWith {};

addCamShake [2 + (18 * (_dose min 1)), 0.8 + (3.2 * (_dose min 1)), 18];
