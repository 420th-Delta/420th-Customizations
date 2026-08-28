if (!isServer) exitWith {};

[] call fdelta_test_fnc_installScriptErrorHandler;
fdelta_test_nodes = createHashMap;
fdelta_test_phases = createHashMap;

[] spawn {
    waitUntil {time > 0};
    uiSleep 0.5;

    ["SUITE_BEGIN", [serverTime]] call fdelta_test_fnc_log;

    private _shooterRole = ["ShooterRole", 2] call BIS_fnc_getParamValue;
    private _nodeDeadline = diag_tickTime + 90;
    private _shooter = [];
    waitUntil {
        uiSleep 0.1;
        {
            private _record = fdelta_test_nodes get _x;
            if (
                count _record >= 10
                && {!(_record # 1)}
                && {
                    _shooterRole isEqualTo 0
                    || {_shooterRole isEqualTo 1 && {_record # 3}}
                    || {_shooterRole isEqualTo 2 && {!(_record # 3)}}
                }
            ) exitWith {
                _shooter = _record;
            };
        } forEach keys fdelta_test_nodes;
        _shooter isNotEqualTo [] || {diag_tickTime >= _nodeDeadline}
    };

    if (_shooter isEqualTo []) exitWith {
        ["SUITE_ERROR", ["No requested projectile owner registered", _shooterRole]]
            call fdelta_test_fnc_log;
        ["SUITE_DONE", [false, "NO_SHOOTER", []]] call fdelta_test_fnc_log;
    };

    private _shooterOwner = _shooter # 0;
    private _serverAmmoPatch = isClass (
        configFile >> "CfgPatches" >> "fdelta_ammo"
    );
    private _serverBlastPatch = isClass (
        configFile >> "CfgPatches" >> "fdelta_blast"
    );
    private _serverScalpelPatch = isClass (
        configFile >> "CfgPatches" >> "fdelta_scalpel_l"
    );
    private _serverTerPatch = isClass (
        configFile >> "CfgPatches" >> "fdelta_turret_enhanced"
    );
    private _shooterAmmoPatch = _shooter # 5;
    private _shooterBlastPatch = _shooter # 6;
    private _shooterTerPatch = _shooter param [10, false, [false]];

    // The normal cases remain owned by the client/HC. Therefore their BP and
    // native UWR behavior must follow that machine, not the server's mod set.
    [
        "MATRIX_STATE",
        [
            _serverAmmoPatch,
            _serverBlastPatch,
            _shooterAmmoPatch,
            _shooterBlastPatch,
            _shooterBlastPatch
        ]
    ] call fdelta_test_fnc_log;
    ["SHOOTER_SELECTED", [_shooterOwner, _shooter]]
        call fdelta_test_fnc_log;

    private _originXY = [1651.18, 5467.72];
    private _direction = vectorNormalized [0.2588, 0.9659, 0];
    private _originASL = [
        _originXY # 0,
        _originXY # 1,
        (getTerrainHeightASL _originXY) + 0.15
    ];
    private _results = [];
    private _allCompleted = true;

    // Keep the still-relevant Scalpel RPC trust regression independent from
    // the removed Blast ingress tests. A graphical client must not be able to
    // inject the owner-only engine fallback label into server-local guidance.
    if (
        _serverScalpelPatch
        && {_shooterBlastPatch}
        && {_shooter # 3}
    ) then {
        private _scalpelCase = "SCALPEL_CUE_POISON";
        private _scalpelMissile = createVehicle [
            "fdelta_M_Scalpel_L",
            [1200, 5000, 1200],
            [],
            0,
            "CAN_COLLIDE"
        ];
        _scalpelMissile enableSimulationGlobal false;
        private _scalpelTarget = createVehicle [
            "Land_HelipadEmpty_F",
            [1300, 5000, 1200],
            [],
            0,
            "CAN_COLLIDE"
        ];

        [_scalpelCase, _scalpelMissile, _scalpelTarget] remoteExecCall [
            "fdelta_test_fnc_attemptScalpelCuePoison",
            _shooterOwner
        ];
        private _scalpelDeadline = diag_tickTime + 8;
        waitUntil {
            uiSleep 0.05;
            !isNil {
                fdelta_test_phases get (
                    format ["%1|SCALPEL_POISON_SENT", _scalpelCase]
                )
            } || {diag_tickTime >= _scalpelDeadline}
        };
        uiSleep 0.5;

        private _scalpelPhase = fdelta_test_phases getOrDefault [
            format ["%1|SCALPEL_POISON_SENT", _scalpelCase],
            []
        ];
        private _scalpelRegistry = localNamespace getVariable [
            "fdelta_scalpelL_ownerRegistry",
            createHashMap
        ];
        private _scalpelHash = hashValue _scalpelMissile;
        private _scalpelBucket = _scalpelRegistry getOrDefault [
            _scalpelHash,
            []
        ];
        private _remoteEntryIndex = _scalpelBucket findIf {
            _x isEqualType []
            && {count _x >= 5}
            && {(_x # 0) isEqualTo _scalpelMissile}
        };
        private _remoteRejected = _remoteEntryIndex < 0;

        private _ownerCue = [
            20,
            getPosATL _scalpelTarget,
            objNull,
            0,
            "launcher-axis",
            diag_tickTime
        ];
        private _ownerAccepted = [
            _scalpelMissile,
            _ownerCue,
            objNull,
            false
        ] call fdelta_fnc_scalpelLReceiveCue;
        _scalpelRegistry = localNamespace getVariable [
            "fdelta_scalpelL_ownerRegistry",
            createHashMap
        ];
        _scalpelBucket = _scalpelRegistry getOrDefault [_scalpelHash, []];
        private _ownerEntryIndex = _scalpelBucket findIf {
            _x isEqualType []
            && {count _x >= 5}
            && {(_x # 0) isEqualTo _scalpelMissile}
        };
        private _scalpelPassed = _scalpelPhase isNotEqualTo []
            && {_remoteRejected}
            && {_ownerAccepted}
            && {_ownerEntryIndex >= 0};
        if (!_scalpelPassed) then {_allCompleted = false;};
        [
            "SCALPEL_POISON_RESULT",
            [
                _scalpelPassed,
                _remoteRejected,
                _ownerAccepted,
                _remoteEntryIndex,
                _ownerEntryIndex,
                _scalpelPhase
            ]
        ] call fdelta_test_fnc_log;

        _scalpelRegistry deleteAt _scalpelHash;
        deleteVehicle _scalpelMissile;
        deleteVehicle _scalpelTarget;
    };

    private _waitPhase = {
        params ["_case", "_phase", ["_seconds", 10]];
        private _key = format ["%1|%2", _case, _phase];
        private _deadline = diag_tickTime + _seconds;
        waitUntil {
            uiSleep 0.05;
            (fdelta_test_phases getOrDefault [_key, []]) isNotEqualTo []
            || {diag_tickTime >= _deadline}
        };
        fdelta_test_phases getOrDefault [_key, []]
    };

    // A server-and-client modded graphical run exercises the authenticated
    // production TER endpoints. The UAV is forced server-local after the
    // client takes turret control so the flight-profile result is directly
    // observable alongside the server-owned LOITER waypoint.
    if (
        _serverTerPatch
        && {_shooterTerPatch}
        && {_shooter # 3}
    ) then {
        private _terCase = "TER_AUTH_RPC";
        private _terPlayer = objNull;
        {
            if (owner _x isEqualTo _shooterOwner) exitWith {
                _terPlayer = _x;
            };
        } forEach allPlayers;

        private _terAircraft = createVehicle [
            "B_UAV_02_dynamicLoadout_F",
            [2050, 5650, 400],
            [],
            0,
            "FLY"
        ];
        createVehicleCrew _terAircraft;
        private _crewDeadline = diag_tickTime + 5;
        waitUntil {
            uiSleep 0.05;
            !isNull (driver _terAircraft)
            || {diag_tickTime >= _crewDeadline}
        };

        private _terGroup = group (driver _terAircraft);
        private _terLoiter = _terGroup addWaypoint [
            [2050, 5650, 0],
            0
        ];
        _terLoiter setWaypointType "LOITER";
        _terLoiter setWaypointLoiterAltitude 100;
        _terLoiter setWaypointLoiterRadius 600;
        _terGroup setCurrentWaypoint _terLoiter;
        private _terAircraftId = netId _terAircraft;
        uiSleep 1;

        [_terCase, "SETUP", _terAircraftId] remoteExecCall [
            "fdelta_test_fnc_attemptTerRpc",
            _shooterOwner
        ];
        private _terSetupPhase = [
            _terCase,
            "TER_CONTROL_READY",
            15
        ] call _waitPhase;
        private _terSetupData = _terSetupPhase param [2, [], [[]]];
        private _terSetupOk = _terSetupData param [0, false, [false]];

        private _terControlVisible = false;
        private _controlDeadline = diag_tickTime + 8;
        waitUntil {
            uiSleep 0.05;
            _terControlVisible = !isNull _terPlayer
                && {_terPlayer in (UAVControl [_terAircraft, "gunner"])};
            _terControlVisible || {diag_tickTime >= _controlDeadline}
        };

        if (!local _terAircraft) then {
            _terAircraft setOwner 2;
        };
        private _ownerDeadline = diag_tickTime + 5;
        waitUntil {
            uiSleep 0.05;
            local _terAircraft
            || {diag_tickTime >= _ownerDeadline}
        };
        private _terServerLocal = local _terAircraft
            && {owner _terAircraft isEqualTo 2};

        private _terAltitudeASL = 725;
        private _terClearance = 140;
        private _terRadius = 925;
        private _terCenterXY = [2250, 5450];
        private _terCenterASL = [
            _terCenterXY # 0,
            _terCenterXY # 1,
            getTerrainHeightASL _terCenterXY
        ];
        [
            _terCase,
            "SUBMIT",
            _terAircraftId,
            _terAltitudeASL,
            _terClearance,
            _terRadius,
            _terCenterASL
        ] remoteExecCall [
            "fdelta_test_fnc_attemptTerRpc",
            _shooterOwner
        ];
        private _terSubmitPhase = [
            _terCase,
            "TER_RPC_SENT",
            10
        ] call _waitPhase;
        private _terSubmitData = _terSubmitPhase param [2, [], [[]]];
        private _terSubmitOk = _terSubmitData param [0, false, [false]];

        private _terProfile = [];
        private _terWaypointAltitude = -1;
        private _terWaypointRadius = -1;
        private _terWaypointPosition = [];
        private _terStateObserved = false;
        private _stateDeadline = diag_tickTime + 8;
        waitUntil {
            uiSleep 0.05;
            _terProfile = _terAircraft getVariable [
                "fdelta_terLastAppliedFlightProfile",
                []
            ];
            _terWaypointAltitude = waypointLoiterAltitude _terLoiter;
            _terWaypointRadius = waypointLoiterRadius _terLoiter;
            _terWaypointPosition = waypointPosition _terLoiter;
            _terStateObserved = _terProfile isEqualTo [
                _terAltitudeASL,
                _terClearance
            ]
                && {abs (_terWaypointAltitude - _terClearance) < 0.1}
                && {abs (_terWaypointRadius - _terRadius) < 0.1}
                && {
                    _terWaypointPosition distance2D (
                        ASLToAGL _terCenterASL
                    ) <= 5
                };
            _terStateObserved || {diag_tickTime >= _stateDeadline}
        };

        private _terPassed = _terSetupPhase isNotEqualTo []
            && {_terSetupOk}
            && {_terControlVisible}
            && {_terServerLocal}
            && {_terSubmitPhase isNotEqualTo []}
            && {_terSubmitOk}
            && {_terStateObserved}
            && {toUpper (waypointType _terLoiter) isEqualTo "LOITER"};
        private _terResult = [
            _terCase,
            _terPassed,
            _terSetupOk,
            _terControlVisible,
            _terServerLocal,
            _terSubmitOk,
            _terStateObserved,
            owner _terAircraft,
            waypointType _terLoiter,
            _terWaypointAltitude,
            _terWaypointRadius,
            _terWaypointPosition,
            ASLToAGL _terCenterASL,
            _terProfile,
            _terSetupData,
            _terSubmitData
        ];
        ["TER_RPC_RESULT", _terResult] call fdelta_test_fnc_log;
        _results pushBack _terResult;
        if (!_terPassed) then {_allCompleted = false;};

        [_terCase, "CLEANUP", _terAircraftId] remoteExecCall [
            "fdelta_test_fnc_attemptTerRpc",
            _shooterOwner
        ];
        [_terCase, "TER_CLEANUP_DONE", 3] call _waitPhase;
        private _terCrew = crew _terAircraft;
        {deleteVehicle _x;} forEach _terCrew;
        deleteVehicle _terAircraft;
        if (!isNull _terGroup) then {deleteGroup _terGroup;};
    } else {
        [
            "TER_RPC_SKIPPED",
            [_serverTerPatch, _shooterTerPatch, _shooter # 3]
        ] call fdelta_test_fnc_log;
    };

    private _createTarget = {
        params ["_case", "_targetASL", ["_initialDamage", 0]];
        private _group = createGroup [east, true];
        private _target = _group createUnit [
            "O_V_Soldier_hex_F",
            ASLToAGL _targetASL,
            [],
            0,
            "CAN_COLLIDE"
        ];
        _target setPosASL _targetASL;
        _target setUnitPos "UP";
        _target disableAI "ALL";
        removeAllWeapons _target;
        _target setVariable ["fdelta_test_case", _case];
        if (_initialDamage > 0) then {
            _target setDamage _initialDamage;
        };
        [_target, _group]
    };

    private _runOwnerCase = {
        params [
            "_case",
            "_distance",
            "_initialDamage",
            "_expectation",
            ["_realWeapon", false]
        ];

        private _targetXY = [
            (_originXY # 0) + ((_direction # 0) * _distance),
            (_originXY # 1) + ((_direction # 1) * _distance)
        ];
        private _targetASL = [
            _targetXY # 0,
            _targetXY # 1,
            getTerrainHeightASL _targetXY
        ];
        private _targetState = [
            _case,
            _targetASL,
            _initialDamage
        ] call _createTarget;
        _targetState params ["_target", "_group"];

        uiSleep 0.35;
        ["OWNER_CASE_BEGIN", [
            _case,
            _distance,
            _initialDamage,
            _expectation,
            _realWeapon,
            damage _target
        ]] call fdelta_test_fnc_log;

        private _createFunction = [
            "fdelta_test_fnc_createSyntheticShot",
            "fdelta_test_fnc_createWeaponShot"
        ] select _realWeapon;
        private _readyPhase = ["READY", "WEAPON_READY"] select _realWeapon;
        [_case, _originASL] remoteExec [_createFunction, _shooterOwner];
        private _ready = [_case, _readyPhase, 15] call _waitPhase;
        private _networkId = "";
        private _readyData = [];
        private _triggered = false;

        if (_ready isNotEqualTo []) then {
            _readyData = _ready # 2;
            _networkId = _readyData param [0, "", [""]];
            [_case, _originASL, false] remoteExec [
                "fdelta_test_fnc_triggerSyntheticShot",
                _shooterOwner
            ];
            _triggered = ([_case, "TRIGGERED", 6] call _waitPhase)
                isNotEqualTo [];
        };

        uiSleep 2;
        private _observedDamage = damage _target;
        private _actualDistance = _originASL distance (
            getPosASL _target vectorAdd [0, 0, 1]
        );
        private _noHealing = _observedDamage >= (_initialDamage - 0.01);
        private _behaviorPassed = switch (_expectation) do {
            case "UWR": {
                if (_shooterAmmoPatch) then {
                    _observedDamage >= 0.99
                } else {
                    _observedDamage < 0.01
                }
            };
            case "BP": {
                if (_shooterBlastPatch) then {
                    // The upper bound also detects duplicate processing when
                    // both server and owner have the addon.
                    _observedDamage > 0.10 && {_observedDamage < 0.30}
                } else {
                    _observedDamage < 0.01
                }
            };
            case "PRE_DAMAGED": {
                _noHealing && {
                    if (_shooterBlastPatch) then {
                        _observedDamage > (_initialDamage + 0.10)
                            && {_observedDamage < (_initialDamage + 0.30)}
                    } else {
                        abs (_observedDamage - _initialDamage) < 0.02
                    }
                }
            };
            default {
                _observedDamage < 0.01
            };
        };
        private _passed = _ready isNotEqualTo []
            && {_networkId isNotEqualTo ""}
            && {_triggered}
            && {_noHealing}
            && {_behaviorPassed};
        private _result = [
            _case,
            _passed,
            _expectation,
            _realWeapon,
            _distance,
            _actualDistance,
            _initialDamage,
            _observedDamage,
            _shooterAmmoPatch,
            _shooterBlastPatch,
            _networkId,
            _readyData
        ];
        ["OWNER_CASE_RESULT", _result] call fdelta_test_fnc_log;

        deleteVehicle _target;
        deleteGroup _group;
        uiSleep 0.35;
        [_passed, _result]
    };

    {
        private _caseResult = _x call _runOwnerCase;
        _caseResult params ["_passed", "_result"];
        _results pushBack _result;
        if (!_passed) then {_allCompleted = false;};
    } forEach [
        ["MK82_NATIVE_55M", 55, 0, "UWR", false],
        ["MK82_BP_100M", 100, 0, "BP", false],
        ["MK82_CUTOFF_255M", 255, 0, "CUTOFF", false],
        ["MK82_PRE_DAMAGED_100M", 100, 0.4, "PRE_DAMAGED", false]
    ];

    // A graphical client additionally emits a real Mk 82 from the A-143. The
    // HC matrix uses the deterministic synthetic path because it has no player.
    if (_shooter # 3) then {
        private _weaponResult = [
            "MK82_WEAPON_100M",
            100,
            0,
            "BP",
            true
        ] call _runOwnerCase;
        _weaponResult params ["_passed", "_result"];
        _results pushBack _result;
        if (!_passed) then {_allCompleted = false;};
    } else {
        ["WEAPON_CASE_SKIPPED", ["HEADLESS_CLIENT"]]
            call fdelta_test_fnc_log;
    };

    // Transfer a live, staged projectile to the dedicated server immediately
    // before detonation. This case deliberately follows the *new* owner: a
    // modded server processes it and a vanilla server does not, regardless of
    // the creating client's mod set.
    private _transferCase = "MK82_TRANSFER_100M";
    private _transferOriginXY = [2750, 5200];
    private _transferOriginASL = [
        _transferOriginXY # 0,
        _transferOriginXY # 1,
        (getTerrainHeightASL _transferOriginXY) + 0.15
    ];
    private _transferTargetXY = [2850, 5200];
    private _transferTargetASL = [
        _transferTargetXY # 0,
        _transferTargetXY # 1,
        getTerrainHeightASL _transferTargetXY
    ];
    private _transferTargetState = [
        _transferCase,
        _transferTargetASL,
        0
    ] call _createTarget;
    _transferTargetState params ["_transferTarget", "_transferGroup"];

    [_transferCase, _transferOriginASL] remoteExec [
        "fdelta_test_fnc_createSyntheticShot",
        _shooterOwner
    ];
    private _transferReady = [
        _transferCase,
        "READY",
        12
    ] call _waitPhase;
    private _transferNetworkId = "";
    private _transferInitialOwner = -1;
    private _transferFinalOwner = -1;
    private _transferLocal = false;
    private _transferTriggered = false;

    if (_transferReady isNotEqualTo []) then {
        _transferNetworkId = (_transferReady # 2) param [0, "", [""]];
        [_transferCase, _transferOriginASL, true] remoteExec [
            "fdelta_test_fnc_triggerSyntheticShot",
            _shooterOwner
        ];
        private _staged = ([_transferCase, "STAGED", 6] call _waitPhase)
            isNotEqualTo [];
        private _projectile = objNull;
        private _resolveDeadline = diag_tickTime + 5;
        waitUntil {
            uiSleep 0.05;
            _projectile = objectFromNetId _transferNetworkId;
            !isNull _projectile || {diag_tickTime >= _resolveDeadline}
        };

        if (_staged && {!isNull _projectile}) then {
            _transferInitialOwner = owner _projectile;
            _projectile setOwner 2;
            private _localityDeadline = diag_tickTime + 5;
            waitUntil {
                uiSleep 0.02;
                _transferLocal = local _projectile;
                _transferFinalOwner = owner _projectile;
                _transferLocal && {_transferFinalOwner isEqualTo 2}
                || {diag_tickTime >= _localityDeadline}
            };
            if (_transferLocal && {_transferFinalOwner isEqualTo 2}) then {
                triggerAmmo _projectile;
                _transferTriggered = true;
            };
        };
    };

    uiSleep 2;
    private _transferDamage = damage _transferTarget;
    private _transferBehavior = if (_serverBlastPatch) then {
        _transferDamage > 0.10 && {_transferDamage < 0.30}
    } else {
        _transferDamage < 0.01
    };
    private _transferPassed = _transferReady isNotEqualTo []
        && {_transferNetworkId isNotEqualTo ""}
        && {_transferInitialOwner isEqualTo _shooterOwner}
        && {_transferLocal}
        && {_transferFinalOwner isEqualTo 2}
        && {_transferTriggered}
        && {_transferBehavior};
    private _transferResult = [
        _transferCase,
        _transferPassed,
        _transferDamage,
        _serverBlastPatch,
        _shooterBlastPatch,
        _transferNetworkId,
        _transferInitialOwner,
        _transferFinalOwner,
        _transferLocal,
        _transferTriggered
    ];
    ["LOCALITY_TRANSFER_RESULT", _transferResult]
        call fdelta_test_fnc_log;
    _results pushBack _transferResult;
    if (!_transferPassed) then {_allCompleted = false;};

    deleteVehicle _transferTarget;
    deleteGroup _transferGroup;

    private _scriptErrors = missionNamespace getVariable [
        "fdelta_test_scriptErrors",
        []
    ];
    if (_scriptErrors isNotEqualTo []) then {
        _allCompleted = false;
        ["SCRIPT_ERRORS", [count _scriptErrors, _scriptErrors]]
            call fdelta_test_fnc_log;
    };

    ["SUITE_DONE", [_allCompleted, "COMPLETE", _results]]
        call fdelta_test_fnc_log;
};
