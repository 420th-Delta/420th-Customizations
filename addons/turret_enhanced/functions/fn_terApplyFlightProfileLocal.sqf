/*
    Author: zobri

    Applies the validated ASL target and AGL safety floor where the UAV is local.
*/
if (
    isRemoteExecuted
    && {remoteExecutedOwner isNotEqualTo 2}
) exitWith {false};
if !(_this isEqualType [] && {count _this isEqualTo 3}) exitWith {false};
if !(
    (_this # 0) isEqualType objNull
    && {(_this # 1) isEqualType 0}
    && {(_this # 2) isEqualType 0}
) exitWith {false};
private _aircraft = _this # 0;
private _altitudeASL = _this # 1;
private _terrainClearance = _this # 2;

if (isNull _aircraft || {!local _aircraft} || {!(_aircraft isKindOf "Air")}) exitWith {
    false
};
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
