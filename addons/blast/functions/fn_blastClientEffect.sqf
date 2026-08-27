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
params [
    ["_unit", objNull, [objNull]],
    ["_dose", 0, [0]]
];

// Clients may never make another client's camera shake.
if (isRemoteExecuted && {remoteExecutedOwner != 2}) exitWith {};
if (!hasInterface || {isNull _unit} || {_unit isNotEqualTo player} || {_dose <= 0}) exitWith {};

addCamShake [2 + (18 * (_dose min 1)), 0.8 + (3.2 * (_dose min 1)), 18];
