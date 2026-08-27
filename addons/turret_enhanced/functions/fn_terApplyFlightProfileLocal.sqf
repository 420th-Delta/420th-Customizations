/*
    Author: zobri

    Applies the validated ASL target and AGL safety floor where the UAV is local.
*/
params [
    ["_aircraft", objNull, [objNull]],
    ["_altitudeASL", 0, [0]],
    ["_terrainClearance", 0, [0]]
];

if (isNull _aircraft || {!local _aircraft} || {!(_aircraft isKindOf "Air")}) exitWith {false};
if (
    isMultiplayer
    && {isRemoteExecuted}
    && {remoteExecutedOwner isNotEqualTo 2}
) exitWith {false};
if (!finite _altitudeASL || {!finite _terrainClearance}) exitWith {false};
if (
    _altitudeASL < 20
    || {_altitudeASL > 20000}
    || {_terrainClearance < 20}
    || {_terrainClearance > 1000}
) exitWith {false};

_aircraft flyInHeight _terrainClearance;
_aircraft flyInHeightASL [_altitudeASL, _altitudeASL, _altitudeASL];

_aircraft setVariable [
    "fdelta_terLastAppliedFlightProfile",
    [_altitudeASL, _terrainClearance]
];
true
