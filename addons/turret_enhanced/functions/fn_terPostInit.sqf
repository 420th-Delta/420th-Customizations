/*
    Author: zobri

    Maintains server-authoritative flight profiles and installs client actions.
*/
if (isRemoteExecuted) exitWith {};

if (isNil {localNamespace getVariable "fdelta_ter_resolveActiveLoiter"}) then {
    localNamespace setVariable [
        "fdelta_ter_resolveActiveLoiter",
        compile preprocessFileLineNumbers
            "\z\fdelta\addons\turret_enhanced\functions\fn_terResolveActiveLoiter.sqf"
    ];
};

if (isServer) then {
    private _registryNamespace = localNamespace;
    _registryNamespace setVariable ["fdelta_terFlightProfiles", []];

    [_registryNamespace] spawn {
        params ["_registryNamespace"];

        while {true} do {
            // Keep prune + reapply atomic with the unscheduled settings RPCs.
            // Otherwise a newer accepted profile could be overwritten briefly
            // by the scheduled loop's stale snapshot until its next pass.
            isNil {
            private _profiles = _registryNamespace getVariable ["fdelta_terFlightProfiles", []];
            if !(_profiles isEqualType []) then {
                _profiles = [];
                _registryNamespace setVariable [
                    "fdelta_terFlightProfiles",
                    _profiles
                ];
            };

            // Prune the live array in place. An unscheduled settings RPC that
            // appends while this scheduled loop is pre-empted mutates the same
            // array and therefore cannot be lost to a later snapshot replace.
            for "_index" from ((count _profiles) - 1) to 0 step -1 do {
                private _entry = _profiles # _index;
                private _valid = _entry isEqualType []
                    && {count _entry isEqualTo 3}
                    && {(_entry # 0) isEqualType objNull}
                    && {(_entry # 1) isEqualType 0}
                    && {(_entry # 2) isEqualType 0};
                if (_valid) then {
                    private _aircraft = _entry # 0;
                    private _altitudeASL = _entry # 1;
                    private _terrainClearance = _entry # 2;
                    _valid = !isNull _aircraft
                        && {alive _aircraft}
                        && {_aircraft isKindOf "Air"}
                        && {finite _altitudeASL}
                        && {finite _terrainClearance}
                        && {_altitudeASL >= 20 && {_altitudeASL <= 20000}}
                        && {_terrainClearance >= 20 && {_terrainClearance <= 1000}};
                };
                if (!_valid) then {
                    _profiles deleteAt _index;
                };
            };
            private _validProfiles = +_profiles;

            {
                _x params ["_aircraft", "_altitudeASL", "_terrainClearance"];
                if (local _aircraft) then {
                    [_aircraft, _altitudeASL, _terrainClearance]
                        call fdelta_fnc_terApplyFlightProfileLocal;
                } else {
                    [_aircraft, _altitudeASL, _terrainClearance] remoteExecCall [
                        "fdelta_fnc_terApplyFlightProfileLocal",
                        _aircraft
                    ];
                };
            } forEach _validProfiles;
            };

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
