/*
    Author: zobri

    Maintains server-authoritative flight profiles and installs client actions.
*/
if (isServer) then {
    private _registryNamespace = localNamespace;
    _registryNamespace setVariable ["fdelta_terFlightProfiles", []];

    [_registryNamespace] spawn {
        params ["_registryNamespace"];

        while {true} do {
            private _profiles = _registryNamespace getVariable ["fdelta_terFlightProfiles", []];

            {
                _x params [
                    ["_aircraft", objNull, [objNull]],
                    ["_altitudeASL", 0, [0]],
                    ["_terrainClearance", 0, [0]]
                ];

                if (
                    !isNull _aircraft
                    && {alive _aircraft}
                    && {_aircraft isKindOf "Air"}
                    && {finite _altitudeASL}
                    && {finite _terrainClearance}
                    && {_altitudeASL >= 20 && {_altitudeASL <= 20000}}
                    && {_terrainClearance >= 20 && {_terrainClearance <= 1000}}
                ) then {
                    if (local _aircraft) then {
                        [_aircraft, _altitudeASL, _terrainClearance]
                            call fdelta_fnc_terApplyFlightProfileLocal;
                    } else {
                        [_aircraft, _altitudeASL, _terrainClearance] remoteExecCall [
                            "fdelta_fnc_terApplyFlightProfileLocal",
                            _aircraft
                        ];
                    };
                };
            } forEach _profiles;

            uiSleep 5;
        };
    };
};

if (!hasInterface) exitWith {};

missionNamespace setVariable ["fdelta_terMarkerCounter", 0];
missionNamespace setVariable ["fdelta_terMeasureStart", []];

[] spawn {
    waitUntil {
        uiSleep 0.1;
        !isNull player
    };

    while {hasInterface} do {
        [] call fdelta_fnc_terAddActions;
        uiSleep 1;
    };
};
