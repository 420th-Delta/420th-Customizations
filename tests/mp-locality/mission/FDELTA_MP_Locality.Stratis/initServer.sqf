if (!isServer) exitWith {};

[] call fdelta_test_fnc_installScriptErrorHandler;
fdelta_test_nodes = createHashMap;
fdelta_test_phases = createHashMap;

if !(isNil "fdelta_fnc_blastConfigureServer") then {
    [createHashMapFromArray [["fdelta_blast_debug", true]]]
        call fdelta_fnc_blastConfigureServer;
};

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
                && {!(_record select 1)}
                && {
                    (_shooterRole isEqualTo 0)
                    || {_shooterRole isEqualTo 1 && {_record select 3}}
                    || {_shooterRole isEqualTo 2 && {!(_record select 3)}}
                }
            ) exitWith {
                _shooter = _record;
            };
        } forEach keys fdelta_test_nodes;
        count _shooter > 0 || {diag_tickTime >= _nodeDeadline}
    };

    if (count _shooter isEqualTo 0) exitWith {
        ["SUITE_ERROR", ["No requested projectile owner registered", _shooterRole]]
            call fdelta_test_fnc_log;
        ["SUITE_DONE", [false, "NO_SHOOTER", []]] call fdelta_test_fnc_log;
    };

    private _shooterOwner = _shooter select 0;
    private _serverAmmoPatch = isClass (
        configFile >> "CfgPatches" >> "fdelta_ammo"
    );
    private _serverBlastPatch = isClass (
        configFile >> "CfgPatches" >> "fdelta_blast"
    );
    private _serverScalpelPatch = isClass (
        configFile >> "CfgPatches" >> "fdelta_scalpel_l"
    );
    private _shooterBlastPatch = _shooter select 6;
    [
        "SHOOTER_SELECTED",
        [_shooterOwner, _shooter, _serverAmmoPatch, _serverBlastPatch]
    ] call fdelta_test_fnc_log;

    private _originXY = [1651.18, 5467.72];
    private _direction = vectorNormalized [0.2588, 0.9659, 0];
    private _originASL = [
        _originXY select 0,
        _originXY select 1,
        (getTerrainHeightASL _originXY) + 0.15
    ];
    private _distances = [55, 100, 255];
    private _results = [];
    private _allCompleted = true;

    // A network caller must not be able to masquerade as the projectile
    // owner's AI/engine fallback producer. Exercise the public endpoint from
    // a real graphical client before accepting the same cue owner-locally.
    if (
        _serverScalpelPatch
        && {_shooterBlastPatch}
        && {_shooter select 3}
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
        private _scalpelBucket = _scalpelRegistry getOrDefault [_scalpelHash, []];
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
        if (!_scalpelPassed) then {_allCompleted = false};
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

    // A graphical client can publish arbitrary missionNamespace values to the
    // server even when it does not load 420th. Prove that Blast's trusted state
    // and damage multiplier remain machine-local by attempting the old forged-
    // registry exploit before the normal weapon cases.
    if (_serverBlastPatch && {_shooter select 3}) then {
        private _poisonCase = "BLAST_STATE_POISON";
        private _poisonOriginXY = [1300, 5200];
        private _poisonOriginASL = [
            _poisonOriginXY # 0,
            _poisonOriginXY # 1,
            (getTerrainHeightASL _poisonOriginXY) + 0.15
        ];
        private _poisonTargetXY = [1400, 5200];
        private _poisonTargetASL = [
            _poisonTargetXY # 0,
            _poisonTargetXY # 1,
            getTerrainHeightASL _poisonTargetXY
        ];
        private _poisonGroup = createGroup [east, true];
        private _poisonTarget = _poisonGroup createUnit [
            "O_V_Soldier_hex_F",
            ASLToAGL _poisonTargetASL,
            [],
            0,
            "CAN_COLLIDE"
        ];
        _poisonTarget setPosASL _poisonTargetASL;
        _poisonTarget setUnitPos "UP";
        _poisonTarget disableAI "ALL";
        removeAllWeapons _poisonTarget;

        private _poisonKey = format [
            "forged-%1-%2",
            _shooterOwner,
            round (diag_tickTime * 1000)
        ];
        [_poisonCase, _poisonKey, _poisonOriginASL]
            remoteExecCall ["fdelta_test_fnc_attemptStatePoison", _shooterOwner];

        private _poisonDeadline = diag_tickTime + 8;
        waitUntil {
            uiSleep 0.05;
            !isNil {
                fdelta_test_phases get (
                    format ["%1|POISON_SENT", _poisonCase]
                )
            } || {diag_tickTime >= _poisonDeadline}
        };
        private _poisonArrived = false;
        private _poisonArrivalDeadline = diag_tickTime + 3;
        waitUntil {
            uiSleep 0.05;
            private _publishedRegistry = missionNamespace getVariable [
                "fdelta_blast_projectileRegistry",
                createHashMap
            ];
            _poisonArrived = _publishedRegistry isEqualType createHashMap
                && {_poisonKey in _publishedRegistry}
                && {
                    (missionNamespace getVariable [
                        "fdelta_blast_damageMultiplier",
                        -1
                    ]) isEqualTo 100
                };
            _poisonArrived || {diag_tickTime >= _poisonArrivalDeadline}
        };
        uiSleep 3;

        private _poisonPhase = fdelta_test_phases getOrDefault [
            format ["%1|POISON_SENT", _poisonCase],
            []
        ];
        private _publishedRegistry = missionNamespace getVariable [
            "fdelta_blast_projectileRegistry",
            createHashMap
        ];
        private _publishedMultiplier = missionNamespace getVariable [
            "fdelta_blast_damageMultiplier",
            -1
        ];
        private _poisonDamage = damage _poisonTarget;
        private _poisonPassed = _poisonPhase isNotEqualTo []
            && {_poisonArrived}
            && {_poisonDamage < 0.001};
        if (!_poisonPassed) then {_allCompleted = false};
        [
            "STATE_POISON_RESULT",
            [
                _poisonPassed,
                _poisonDamage,
                _poisonPhase,
                _poisonKey,
                _poisonArrived,
                _publishedMultiplier,
                _publishedRegistry isEqualType createHashMap
                    && {_poisonKey in _publishedRegistry}
            ]
        ] call fdelta_test_fnc_log;

        deleteVehicle _poisonTarget;
        deleteGroup _poisonGroup;
    };

    // Exercise a real mid-flight ownership transfer while an earlier report
    // is pending. The old reservation must be superseded, the server must
    // register itself as the new owner, and the final blast must apply once.
    if (_serverBlastPatch && {_shooterBlastPatch}) then {
        private _transferCase = "BLAST_LOCALITY_PREEMPT";
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
        private _transferGroup = createGroup [east, true];
        private _transferTarget = _transferGroup createUnit [
            "O_V_Soldier_hex_F",
            ASLToAGL _transferTargetASL,
            [],
            0,
            "CAN_COLLIDE"
        ];
        _transferTarget setPosASL _transferTargetASL;
        _transferTarget setUnitPos "UP";
        _transferTarget disableAI "ALL";
        removeAllWeapons _transferTarget;

        [_transferCase, _transferOriginASL] remoteExec [
            "fdelta_test_fnc_createSyntheticShot",
            _shooterOwner
        ];
        private _transferReadyKey = format [
            "%1|READY",
            _transferCase
        ];
        private _transferReadyDeadline = diag_tickTime + 10;
        waitUntil {
            uiSleep 0.05;
            (fdelta_test_phases getOrDefault [
                _transferReadyKey,
                []
            ]) isNotEqualTo []
            || {diag_tickTime >= _transferReadyDeadline}
        };

        private _transferReady = fdelta_test_phases getOrDefault [
            _transferReadyKey,
            []
        ];
        private _transferKey = "";
        private _transferProjectile = objNull;
        private _initialEvidence = false;
        private _earlyReserved = false;
        private _oldReservation = "";
        private _transferAccepted = false;
        private _migrationObserved = false;
        private _migrationOwner = -1;
        private _migrationReservation = "";
        private _localityImmediate = false;
        private _preDetonationOwner = -1;
        private _preDetonationReservation = "";

        if (_transferReady isNotEqualTo []) then {
            _transferKey = (_transferReady # 2) param [0, "", [""]];
            private _evidenceDeadline = diag_tickTime + 3;
            waitUntil {
                uiSleep 0.05;
                private _registry = localNamespace getVariable [
                    "fdelta_blast_projectileRegistry",
                    createHashMap
                ];
                private _entry = _registry getOrDefault [
                    _transferKey,
                    createHashMap
                ];
                _transferProjectile = _entry getOrDefault [
                    "projectile",
                    objNull
                ];
                _initialEvidence = count _entry > 0
                    && {!isNull _transferProjectile}
                    && {(_entry getOrDefault [
                        "owner",
                        -1
                    ]) isEqualTo _shooterOwner};
                _initialEvidence || {diag_tickTime >= _evidenceDeadline}
            };
        };

        if (_initialEvidence) then {
            [_transferCase, _transferOriginASL] remoteExec [
                "fdelta_test_fnc_submitEarlyBlastReport",
                _shooterOwner
            ];
            private _earlyDeadline = diag_tickTime + 4;
            waitUntil {
                uiSleep 0.05;
                private _registry = localNamespace getVariable [
                    "fdelta_blast_projectileRegistry",
                    createHashMap
                ];
                private _entry = _registry getOrDefault [
                    _transferKey,
                    createHashMap
                ];
                _oldReservation = _entry getOrDefault [
                    "reservationId",
                    ""
                ];
                _earlyReserved = _entry getOrDefault ["pending", false]
                    && {_oldReservation isNotEqualTo ""};
                _earlyReserved || {diag_tickTime >= _earlyDeadline}
            };
        };

        if (_earlyReserved && {!isNull _transferProjectile}) then {
            // Freeze the batched monitor until engine locality confirms, then
            // trigger before the registry can rebase. This forces Explode-time
            // evidence—not the monitor—to authenticate the new owner and
            // supersede the pending reservation.
            private _monitorHandle = localNamespace getVariable [
                "fdelta_blast_registryMonitorHandle",
                scriptNull
            ];
            if (!scriptDone _monitorHandle) then {
                terminate _monitorHandle;
            };
            private _monitorPauseHandle = [] spawn {uiSleep 10};
            localNamespace setVariable [
                "fdelta_blast_registryMonitorHandle",
                _monitorPauseHandle
            ];

            _transferAccepted = _transferProjectile setOwner 2;
            private _localityDeadline = diag_tickTime + 2;
            waitUntil {
                uiSleep 0.01;
                local _transferProjectile
                || {diag_tickTime >= _localityDeadline}
            };
            _localityImmediate = local _transferProjectile;
            private _preDetonationRegistry = localNamespace getVariable [
                "fdelta_blast_projectileRegistry",
                createHashMap
            ];
            private _preDetonationEntry = _preDetonationRegistry getOrDefault [
                _transferKey,
                createHashMap
            ];
            _preDetonationOwner = _preDetonationEntry getOrDefault [
                "owner",
                -1
            ];
            _preDetonationReservation = _preDetonationEntry getOrDefault [
                "reservationId",
                ""
            ];

            if (
                _transferAccepted
                && {_localityImmediate}
                && {_preDetonationOwner isEqualTo _shooterOwner}
                && {_preDetonationReservation isEqualTo _oldReservation}
            ) then {
                private _detonationASL = _transferOriginASL vectorAdd [0, 0, 2];
                _transferProjectile setPosASL _detonationASL;
                _transferProjectile setVelocity [0, 0, 0];
                triggerAmmo _transferProjectile;

                private _migrationDeadline = diag_tickTime + 1;
                waitUntil {
                    uiSleep 0.01;
                    private _postDetonationRegistry = localNamespace
                        getVariable [
                            "fdelta_blast_projectileRegistry",
                            createHashMap
                        ];
                    private _postDetonationEntry = _postDetonationRegistry
                        getOrDefault [_transferKey, createHashMap];
                    _migrationOwner = _postDetonationEntry getOrDefault [
                        "owner",
                        -1
                    ];
                    _migrationReservation = _postDetonationEntry getOrDefault [
                        "reservationId",
                        ""
                    ];
                    _migrationObserved = _migrationOwner isEqualTo 2
                        && {_postDetonationEntry getOrDefault [
                            "pending",
                            false
                        ]}
                        && {_migrationReservation isNotEqualTo ""}
                        && {_migrationReservation isNotEqualTo _oldReservation};
                    _migrationObserved || {diag_tickTime >= _migrationDeadline}
                };
            };

            terminate _monitorPauseHandle;
            localNamespace setVariable [
                "fdelta_blast_registryMonitorHandle",
                [] spawn fdelta_fnc_blastMonitorRegistry
            ];
        };
        uiSleep 4;

        private _transferRegistry = localNamespace getVariable [
            "fdelta_blast_projectileRegistry",
            createHashMap
        ];
        private _transferFinalEntry = _transferRegistry getOrDefault [
            _transferKey,
            createHashMap
        ];
        private _transferSeen = localNamespace getVariable [
            "fdelta_blast_seen",
            createHashMap
        ];
        private _transferDamage = damage _transferTarget;
        private _transferLastBlast = _transferTarget getVariable [
            "fdelta_blast_lastBlast",
            []
        ];
        private _transferBlastId = _transferLastBlast param [0, "", [""]];
        private _transferPassed = _transferReady isNotEqualTo []
            && {_initialEvidence}
            && {_earlyReserved}
            && {_transferAccepted}
            && {_localityImmediate}
            && {_preDetonationOwner isEqualTo _shooterOwner}
            && {_preDetonationReservation isEqualTo _oldReservation}
            && {_migrationObserved}
            && {_migrationOwner isEqualTo 2}
            && {_migrationReservation isNotEqualTo _oldReservation}
            && {_transferDamage > 0.1}
            && {_transferDamage < 0.3}
            && {count _transferFinalEntry isEqualTo 0}
            && {(_transferSeen getOrDefault [_transferKey, -1]) >= 0}
            && {_transferBlastId find "@2:" >= 0};
        if (!_transferPassed) then {_allCompleted = false};
        [
            "LOCALITY_PREEMPT_RESULT",
            [
                _transferPassed,
                _transferKey,
                _initialEvidence,
                _earlyReserved,
                _oldReservation,
                _transferAccepted,
                _localityImmediate,
                _preDetonationOwner,
                _preDetonationReservation,
                _migrationObserved,
                _migrationOwner,
                _migrationReservation,
                _transferDamage,
                _transferBlastId,
                count _transferFinalEntry,
                _transferSeen getOrDefault [_transferKey, -1]
            ]
        ] call fdelta_test_fnc_log;

        if (!isNull _transferProjectile) then {
            deleteVehicle _transferProjectile;
        };
        deleteVehicle _transferTarget;
        deleteGroup _transferGroup;
    };

    {
        private _distance = _x;
        private _case = format ["MK82_%1M", _distance];
        private _targetXY = [
            (_originXY select 0) + ((_direction select 0) * _distance),
            (_originXY select 1) + ((_direction select 1) * _distance)
        ];
        private _targetASL = [
            _targetXY select 0,
            _targetXY select 1,
            getTerrainHeightASL _targetXY
        ];
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
        _target addEventHandler ["HandleDamage", {
            params [
                "_unit",
                "_selection",
                "_damage",
                "_source",
                "_projectile",
                "_hitIndex",
                "_instigator",
                "_hitPoint",
                "_directHit",
                "_context"
            ];
            [
                "TARGET_HANDLE_DAMAGE",
                [
                    _unit getVariable ["fdelta_test_case", ""],
                    _selection,
                    _damage,
                    typeOf _source,
                    _projectile,
                    _hitIndex,
                    typeOf _instigator,
                    _hitPoint,
                    _directHit,
                    _context
                ]
            ] call fdelta_test_fnc_log;
            _damage
        }];

        uiSleep 0.5;
        ["CASE_BEGIN", [_case, _distance, getPosASL _target]]
            call fdelta_test_fnc_log;
        [_case, _originASL] remoteExec [
            "fdelta_test_fnc_createSyntheticShot",
            _shooterOwner
        ];

        private _readyKey = format ["%1|READY", _case];
        private _readyDeadline = diag_tickTime + 10;
        waitUntil {
            uiSleep 0.05;
            !((fdelta_test_phases getOrDefault [_readyKey, []]) isEqualTo [])
            || {diag_tickTime >= _readyDeadline}
        };
        private _ready = fdelta_test_phases getOrDefault [_readyKey, []];
        private _networkId = "";
        private _reportedOriginASL = [];

        if (_ready isEqualTo []) then {
            _allCompleted = false;
            ["CASE_ERROR", [_case, "READY_TIMEOUT"]] call fdelta_test_fnc_log;
        } else {
            private _readyData = _ready select 2;
            _networkId = _readyData param [0, "", [""]];
            private _evidenceSeen = false;

            if (_serverBlastPatch && {_shooterBlastPatch}) then {
                private _evidenceDeadline = diag_tickTime + 3;
                waitUntil {
                    uiSleep 0.05;
                    private _registry = localNamespace getVariable [
                        "fdelta_blast_projectileRegistry",
                        createHashMap
                    ];
                    private _entry = _registry getOrDefault [
                        _networkId,
                        createHashMap
                    ];
                    _evidenceSeen = count _entry > 0;
                    _evidenceSeen || {diag_tickTime >= _evidenceDeadline}
                };
            };
            ["SERVER_EVIDENCE", [_case, _networkId, _evidenceSeen]]
                call fdelta_test_fnc_log;

            if (
                _distance isEqualTo 100
                && {_serverBlastPatch}
                && {_shooterBlastPatch}
            ) then {
                _reportedOriginASL = _originASL vectorAdd [
                    (_direction # 0) * 20,
                    (_direction # 1) * 20,
                    2
                ];
                [_case, _originASL, _reportedOriginASL] remoteExec [
                    "fdelta_test_fnc_triggerDisplacedShot",
                    _shooterOwner
                ];
            } else {
                [_case, _originASL] remoteExec [
                    "fdelta_test_fnc_triggerSyntheticShot",
                    _shooterOwner
                ];
            };
            private _triggerKey = format ["%1|TRIGGERED", _case];
            private _triggerDeadline = diag_tickTime + 5;
            waitUntil {
                uiSleep 0.05;
                !((fdelta_test_phases getOrDefault [_triggerKey, []]) isEqualTo [])
                || {diag_tickTime >= _triggerDeadline}
            };
            if (
                (fdelta_test_phases getOrDefault [_triggerKey, []]) isEqualTo []
            ) then {
                _allCompleted = false;
                ["CASE_ERROR", [_case, "TRIGGER_TIMEOUT"]]
                    call fdelta_test_fnc_log;
            };
        };

        uiSleep 4;
        private _actualDistance = _originASL distance (
            getPosASL _target vectorAdd [0, 0, 1]
        );
        private _finalRegistry = localNamespace getVariable [
            "fdelta_blast_projectileRegistry",
            createHashMap
        ];
        private _finalEntry = _finalRegistry getOrDefault [
            _networkId,
            createHashMap
        ];
        private _result = [
            _case,
            _distance,
            _actualDistance,
            alive _target,
            damage _target,
            _target getVariable ["fdelta_blast_lastDose", -1],
            _target getVariable ["fdelta_blast_lastIncrement", -1],
            _target getVariable ["fdelta_blast_traumaState", []],
            _target getVariable ["fdelta_blast_lastBlast", []],
            _networkId,
            _finalEntry,
            keys _finalRegistry,
            keys (localNamespace getVariable ["fdelta_blast_seen", createHashMap]),
            _reportedOriginASL
        ];
        _results pushBack _result;
        ["CASE_RESULT", _result] call fdelta_test_fnc_log;

        private _observedDamage = _result # 4;
        private _behaviorPassed = switch (_distance) do {
            case 55: {
                if (_shooter select 5) then {
                    _observedDamage >= 0.99
                } else {
                    _observedDamage < 0.001
                }
            };
            case 100: {
                if (
                    _serverBlastPatch
                    && {_shooterBlastPatch}
                ) then {
                    _observedDamage > 0.1 && {_observedDamage < 0.3}
                } else {
                    _observedDamage < 0.001
                }
            };
            default {_observedDamage < 0.001};
        };
        private _originSecurityPassed = true;
        if (_reportedOriginASL isNotEqualTo []) then {
            private _lastBlast = _result # 8;
            private _trustedOrigin = _lastBlast param [4, [], [[]]];
            private _expectedOrigin = _originASL vectorAdd [0, 0, 2];
            private _seenKeys = _result # 12;
            _originSecurityPassed = count _lastBlast >= 5
                && {count _trustedOrigin isEqualTo 3}
                && {_trustedOrigin distance _expectedOrigin < 8}
                && {_trustedOrigin distance _reportedOriginASL > 12}
                && {count _finalEntry isEqualTo 0}
                && {_networkId in _seenKeys};
            [
                "SERVER_ORIGIN_RESULT",
                [
                    _case,
                    _originSecurityPassed,
                    _trustedOrigin,
                    _expectedOrigin,
                    _reportedOriginASL,
                    _networkId in _seenKeys
                ]
            ] call fdelta_test_fnc_log;
        };
        _behaviorPassed = _behaviorPassed && {_originSecurityPassed};
        if (!_behaviorPassed) then {_allCompleted = false};
        [
            "CASE_EXPECTATION",
            [_case, _behaviorPassed, _observedDamage]
        ] call fdelta_test_fnc_log;

        deleteVehicle _target;
        deleteGroup _group;
        uiSleep 0.5;
    } forEach _distances;

    // Repeat the decisive 100 m case with a projectile emitted by an actual
    // aircraft weapon. This confirms the normal Fired/getShotParents path in
    // addition to the deterministic createVehicle locality matrix above.
    if (_shooter select 3) then {
        private _case = "MK82_WEAPON_100M";
        private _distance = 100;
        private _targetXY = [
            (_originXY select 0) + ((_direction select 0) * _distance),
            (_originXY select 1) + ((_direction select 1) * _distance)
        ];
        private _targetASL = [
            _targetXY select 0,
            _targetXY select 1,
            getTerrainHeightASL _targetXY
        ];
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
        _target addEventHandler ["HandleDamage", {
            params [
                "_unit",
                "_selection",
                "_damage",
                "_source",
                "_projectile",
                "_hitIndex",
                "_instigator",
                "_hitPoint",
                "_directHit",
                "_context"
            ];
            [
                "TARGET_HANDLE_DAMAGE",
                [
                    _unit getVariable ["fdelta_test_case", ""],
                    _selection,
                    _damage,
                    typeOf _source,
                    _projectile,
                    _hitIndex,
                    typeOf _instigator,
                    _hitPoint,
                    _directHit,
                    _context
                ]
            ] call fdelta_test_fnc_log;
            _damage
        }];

        uiSleep 0.5;
        ["WEAPON_CASE_BEGIN", [_case, _distance, getPosASL _target]]
            call fdelta_test_fnc_log;
        [_case, _originASL] remoteExec [
            "fdelta_test_fnc_createWeaponShot",
            _shooterOwner
        ];

        private _readyKey = format ["%1|WEAPON_READY", _case];
        private _failedKey = format ["%1|WEAPON_FAILED", _case];
        private _readyDeadline = diag_tickTime + 15;
        waitUntil {
            uiSleep 0.05;
            !((fdelta_test_phases getOrDefault [_readyKey, []]) isEqualTo [])
            || {!((fdelta_test_phases getOrDefault [_failedKey, []]) isEqualTo [])}
            || {diag_tickTime >= _readyDeadline}
        };

        private _ready = fdelta_test_phases getOrDefault [_readyKey, []];
        private _networkId = "";
        private _firedData = [];
        private _evidenceSeen = false;

        if (_ready isEqualTo []) then {
            _allCompleted = false;
            [
                "WEAPON_CASE_ERROR",
                [
                    _case,
                    "READY_FAILED_OR_TIMEOUT",
                    fdelta_test_phases getOrDefault [_failedKey, []]
                ]
            ] call fdelta_test_fnc_log;
        } else {
            private _readyData = _ready select 2;
            _networkId = _readyData param [0, "", [""]];
            _firedData = _readyData param [4, [], [[]]];

            if (_serverBlastPatch && {_shooterBlastPatch}) then {
                private _evidenceDeadline = diag_tickTime + 3;
                waitUntil {
                    uiSleep 0.05;
                    private _registry = localNamespace getVariable [
                        "fdelta_blast_projectileRegistry",
                        createHashMap
                    ];
                    private _entry = _registry getOrDefault [
                        _networkId,
                        createHashMap
                    ];
                    _evidenceSeen = count _entry > 0;
                    _evidenceSeen || {diag_tickTime >= _evidenceDeadline}
                };
            };
            [
                "WEAPON_SERVER_EVIDENCE",
                [_case, _networkId, _evidenceSeen]
            ] call fdelta_test_fnc_log;

            [_case, _originASL] remoteExec [
                "fdelta_test_fnc_triggerSyntheticShot",
                _shooterOwner
            ];
            private _triggerKey = format ["%1|TRIGGERED", _case];
            private _triggerDeadline = diag_tickTime + 5;
            waitUntil {
                uiSleep 0.05;
                !((fdelta_test_phases getOrDefault [_triggerKey, []]) isEqualTo [])
                || {diag_tickTime >= _triggerDeadline}
            };
            if (
                (fdelta_test_phases getOrDefault [_triggerKey, []]) isEqualTo []
            ) then {
                _allCompleted = false;
                ["WEAPON_CASE_ERROR", [_case, "TRIGGER_TIMEOUT"]]
                    call fdelta_test_fnc_log;
            };
        };

        uiSleep 4;
        private _actualDistance = _originASL distance (
            getPosASL _target vectorAdd [0, 0, 1]
        );
        private _finalRegistry = localNamespace getVariable [
            "fdelta_blast_projectileRegistry",
            createHashMap
        ];
        private _finalEntry = _finalRegistry getOrDefault [
            _networkId,
            createHashMap
        ];
        private _result = [
            _case,
            _distance,
            _actualDistance,
            alive _target,
            damage _target,
            _target getVariable ["fdelta_blast_lastDose", -1],
            _target getVariable ["fdelta_blast_lastIncrement", -1],
            _target getVariable ["fdelta_blast_traumaState", []],
            _target getVariable ["fdelta_blast_lastBlast", []],
            _networkId,
            _firedData,
            _evidenceSeen,
            _finalEntry
        ];
        _results pushBack _result;
        ["WEAPON_CASE_RESULT", _result] call fdelta_test_fnc_log;

        private _weaponDamage = _result # 4;
        private _weaponBehaviorPassed = if (
            _serverBlastPatch && {_shooterBlastPatch}
        ) then {
            _weaponDamage > 0.1 && {_weaponDamage < 0.3}
        } else {
            _weaponDamage < 0.001
        };
        if (!_weaponBehaviorPassed) then {_allCompleted = false};
        [
            "WEAPON_CASE_EXPECTATION",
            [_case, _weaponBehaviorPassed, _weaponDamage]
        ] call fdelta_test_fnc_log;

        deleteVehicle _target;
        deleteGroup _group;
    };

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
