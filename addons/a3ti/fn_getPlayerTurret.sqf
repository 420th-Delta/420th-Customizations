/*
    Author: Lala14, thegamecracks

    Description:
    Attempts to determine whether the player is controlling a uav or is in a
    turret seat, will return the config entry for their respective seat or UAV
    This is later to be used to get visionModes of their respective seat or UAV

    Parameter(s):
    NONE

    Returns:
    full config value containing selected turret
    e.g. if player is in uav gunner
    (configfile >> "CfgVehicles" >> "B_UAV_05_F" >> "Turrets" >> "MainTurret")
    or if player is in uav driver
    (configfile >> "CfgVehicles" >> "B_UAV_05_F")
*/
#include "constants.h"

private _unit = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];

// If the player is in a vehicle and is controlling a UAV, the UAV needs priority
// over the current player vehicle.
private _uavTurret = call {
    private _uav = getConnectedUAV _unit;
    if (isNull _uav || {cameraOn isEqualTo _unit}) exitWith {configNull};

    // Clunky way to get the unit's current vehicle role...
    private _role = "";
    private _uavControl = UAVControl _uav;
    for "_i" from 0 to floor (count _uavControl / 2) - 1 do {
        if (_uavControl # _i isEqualTo _unit) exitWith {
            _role = _uavControl # (_i + 1);
        };
    };

    switch (toLowerANSI _role) do {
        case "gunner": {[_uav] call FNC(getGunTurret)};
        case "driver": {configOf _uav};
        default {
            diag_log text format ["%1: unknown UAV role: %2", _fnc_scriptName, _uavControl];
            configNull
        };
    }
};
if (!isNull _uavTurret) exitWith {_uavTurret};

// assuming zeus, still to implement
if (isNull objectParent _unit) exitWith {configNull};

// normal vehicle
private _vehicle = objectParent _unit;
if (isNull _vehicle) exitWith {configNull};

private _turretPath = _vehicle unitTurret _unit;
if (_turretPath isEqualTo []) exitWith {configNull};

// https://community.bistudio.com/wiki/Arma_3:_Vehicle_Loadouts#%22Generic%22_Pylons
// With the introduction of "Generic Pylons" in v2.22, it is now possible for pylons
// to provide camera functionality. Look for any pylons providing a camera component
// that matches the turret path of the current unit.
private _cameraPylonConfigs =
    getAllPylonsInfo _vehicle
    select {_x # 2 isEqualTo _turretPath}
    apply {configFile >> "CfgMagazines" >> _x # 3 >> "Components" >> "CameraComponent"}
    select {isClass _x};

// As of v2.22, it is possible for a vehicle to have multiple camera pylons via setPylonLoadout,
// but the player can only view the first camera pylon available to them.
// As such, we'll always return the first pylon.
// It'd be nice if we had a getter command for the player's selected pylon...
if (_cameraPylonConfigs isNotEqualTo []) exitWith {_cameraPylonConfigs # 0};

// Finally, traditional turret config retrieval
private _turretConfig = [_vehicle, _turretPath] call BIS_fnc_turretConfig;
if (getNumber (_turretConfig >> "isPersonTurret") > 0 && {isTurnedOut _unit}) exitWith {
    diag_log text format ["%1: in FFV seat", _fnc_scriptName];
    configNull
};

_turretConfig
