/*
    Author: Lala14

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
private ["_turretConfig","_unit","_uav","_playerControl","_uavPos","_veh","_turretConfigName","_turretPlayer"];
_turretConfig = configNull;

_unit = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
//this was moved outside as if the player is in a vehicle and is controlling
//the uav, the uav needs priority over the current player vehicle
//UAV
if (!(isNull (getConnectedUAV _unit)) && !(cameraOn isEqualTo _unit)) then {
    _uav = getConnectedUAV _unit;
    _playerControl = (UAVControl _uav) find _unit;
    _uavPos = (UAVControl _uav) select (_playerControl + 1);
    if ((toLower _uavPos) isEqualTo "gunner") then {
        _turretConfig = [_uav] call FNC(getGunTurret);
    };
    if ((toLower _uavPos) isEqualTo "driver") then {
        _turretConfig = (configFile >> "CfgVehicles" >> typeOf _uav);
    };
};

if (isNull _turretConfig) then {
    if (vehicle _unit == _unit) then {
        //assuming zeus
        //still to implement
    } else {
        //normal vehicle
        _veh = vehicle _unit;
        if (isNull _veh) exitWith { /*not in veh*/ configNull };
        if (_unit isEqualTo (driver _veh)) then {
            _turretConfig = (configFile >> "CfgVehicles" >> typeOf _veh);
        } else {
            private _turretPlayer = [];
            _assignedRole = (assignedVehicleRole _unit);
            if (count _assignedRole < 1) then {
                {
                    if ((_veh turretUnit _x) isEqualTo _unit) exitWith { _turretPlayer = _x };
                }forEach (allTurrets [_veh, true]);
            } else {
                if (count _assignedRole > 1) then {
                    _turretPlayer = (_assignedRole select 1);
                };
            };

            if (count _turretPlayer <= 0) exitWith { /*_unit not in a turret*/ configNull };

            _turretConfigName = [_veh, _turretPlayer] call BIS_fnc_turretConfig;
            if ((getNumber(_turretConfigName >> "isPersonTurret") > 0) && (isTurnedOut _unit)) then {
                systemChat "FFV";
            } else {
                _turretConfig = _turretConfigName;
            };
        };
    };
};

//return config
_turretConfig
