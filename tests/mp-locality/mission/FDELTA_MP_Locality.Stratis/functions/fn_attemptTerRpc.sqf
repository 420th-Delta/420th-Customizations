/*
    Exercises the production Turret Enhanced RPC endpoints from a real
    graphical UAV gunner. Test orchestration only; no production state is
    bypassed or replaced.
*/
if (!hasInterface || {isNull player}) exitWith {false};
if !(
    _this isEqualType []
    && {count _this >= 3}
    && {(_this # 0) isEqualType ""}
    && {(_this # 1) isEqualType ""}
    && {(_this # 2) isEqualType ""}
) exitWith {false};

_this spawn {
    params [
        ["_case", "", [""]],
        ["_stage", "", [""]],
        ["_aircraftId", "", [""]],
        ["_altitudeASL", 0, [0]],
        ["_terrainClearance", 0, [0]],
        ["_radius", 0, [0]],
        ["_centerASL", [], [[]]]
    ];

    private _report = {
        params ["_phase", "_data"];
        [_case, _phase, _data] remoteExecCall [
            "fdelta_test_fnc_receivePhase",
            2
        ];
    };

    private _aircraft = objNull;
    private _resolveDeadline = diag_tickTime + 10;
    waitUntil {
        uiSleep 0.05;
        _aircraft = objectFromNetId _aircraftId;
        !isNull _aircraft || {diag_tickTime >= _resolveDeadline}
    };

    switch (toUpper _stage) do {
        case "SETUP": {
            private _addonPresent = isClass (
                configFile
                    >> "CfgPatches"
                    >> "fdelta_turret_enhanced"
            );
            if (!_addonPresent || {isNull _aircraft}) exitWith {
                ["TER_CONTROL_READY", [false, _addonPresent, false, false]]
                    call _report;
            };

            if !("B_UavTerminal" in assignedItems player) then {
                player linkItem "B_UavTerminal";
            };
            private _connected = player connectTerminalToUAV _aircraft;
            if (getConnectedUAV player isEqualTo _aircraft) then {
                _connected = true;
            };

            player action ["SwitchToUAVGunner", _aircraft];
            private _deadline = diag_tickTime + 10;
            waitUntil {
                uiSleep 0.05;
                player in (UAVControl [_aircraft, "gunner"])
                || {diag_tickTime >= _deadline}
            };
            private _gunnerControl = player in (
                UAVControl [_aircraft, "gunner"]
            );
            [
                "TER_CONTROL_READY",
                [
                    _connected && {_gunnerControl},
                    _addonPresent,
                    _connected,
                    _gunnerControl,
                    owner _aircraft,
                    local _aircraft,
                    UAVControl _aircraft
                ]
            ] call _report;
        };

        case "SUBMIT": {
            private _gunnerControl = !isNull _aircraft
                && {player in (UAVControl [_aircraft, "gunner"])};
            private _endpointsPresent = !(isNil {
                fdelta_fnc_terServerApplyLoiterSettings
            }) && {!(isNil {
                fdelta_fnc_terServerMoveLoiterCenter
            })};
            if (!_gunnerControl || {!_endpointsPresent}) exitWith {
                [
                    "TER_RPC_SENT",
                    [false, _gunnerControl, _endpointsPresent, owner _aircraft]
                ] call _report;
            };

            [
                player,
                _aircraft,
                _altitudeASL,
                _terrainClearance,
                _radius,
                false
            ] remoteExecCall [
                "fdelta_fnc_terServerApplyLoiterSettings",
                2
            ];
            [player, _aircraft, _centerASL] remoteExecCall [
                "fdelta_fnc_terServerMoveLoiterCenter",
                2
            ];

            [
                "TER_RPC_SENT",
                [
                    true,
                    _gunnerControl,
                    _endpointsPresent,
                    owner _aircraft,
                    local _aircraft,
                    UAVControl _aircraft
                ]
            ] call _report;
        };

        case "CLEANUP": {
            private _controlledUnit = getConnectedUAVUnit player;
            if (!isNull _controlledUnit) then {
                _controlledUnit action ["BackFromUAV"];
            };
            player connectTerminalToUAV objNull;
            ["TER_CLEANUP_DONE", [true]] call _report;
        };
    };
};
true
