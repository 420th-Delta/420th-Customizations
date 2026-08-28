/*
    Author: zobri

    Installs the local interaction actions without permanent polling.
*/
if (isRemoteExecuted) exitWith {};

if (!hasInterface) exitWith {};

missionNamespace setVariable ["fdelta_terMarkerCounter", 0];
missionNamespace setVariable ["fdelta_terMeasureStart", []];

addMissionEventHandler ["EntityRespawned", {
    params ["_newEntity"];
    if (_newEntity isEqualTo player) then {
        // EntityRespawned copies the old entity's variable namespace first.
        // Those action IDs belong to the deleted unit, so force a fresh set.
        _newEntity setVariable ["fdelta_terActionIds", nil];
        [_newEntity] call fdelta_fnc_terAddActions;
    };
}];

addMissionEventHandler ["TeamSwitch", {
    params ["_oldUnit", "_newUnit"];
    if (_newUnit isEqualTo player) then {
        [_newUnit] call fdelta_fnc_terAddActions;
    };
}];

[] spawn {
    waitUntil {
        uiSleep 0.1;
        !isNull player
    };
    [player] call fdelta_fnc_terAddActions;
};
