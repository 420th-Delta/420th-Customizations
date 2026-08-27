/*
    Author: zobri

    Returns whether the local player is currently using a supported aircraft optic.
*/
if (isRemoteExecuted) exitWith {false};
private _aircraft = call fdelta_fnc_terGetCameraAircraft;

!isNull _aircraft
&& {alive _aircraft}
&& {cameraView isEqualTo "GUNNER"}
&& {!visibleMap}
