/*
    Author: zobri

    Returns the aircraft whose gunner camera the local player is actively using.
*/
if (!hasInterface || {isNull player}) exitWith {objNull};

private _connectedUAV = getConnectedUAV player;
if (
    !isNull _connectedUAV
    && {_connectedUAV isKindOf "Air"}
    && {player in (UAVControl [_connectedUAV, "gunner"])}
    && {cameraOn isEqualTo _connectedUAV}
    && {cameraView isEqualTo "GUNNER"}
) exitWith {
    _connectedUAV
};

private _cameraAircraft = cameraOn;
if (
    !isNull _cameraAircraft
    && {_cameraAircraft isKindOf "Air"}
    && {player in crew _cameraAircraft}
) exitWith {
    _cameraAircraft
};

private _occupiedAircraft = vehicle player;
if (
    _occupiedAircraft isNotEqualTo player
    && {_occupiedAircraft isKindOf "Air"}
    && {cameraOn isEqualTo _occupiedAircraft}
) exitWith {
    _occupiedAircraft
};

objNull
