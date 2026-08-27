/*
    Author: zobri

    Description:
        Maintains server-observed projectile positions and expires evidence.

    Returns:
        Nothing
*/
if (!isServer || {isRemoteExecuted}) exitWith {};

private _nextAuxCleanup = 0;
private _nextTraumaCleanup = 0;
private _registryCursor = 0;
private _registryCycleKeys = [];

while {true} do {
    private _now = diag_tickTime;
    private _settings = localNamespace getVariable [
        "fdelta_blast_settings",
        createHashMap
    ];
    private _maxAge = _settings getOrDefault [
        "fdelta_blast_maxEvidenceAge",
        300
    ];

    // Process a bounded batch and make only each key's compare/write atomic.
    // This prevents stale cleanup races without holding one long unscheduled
    // section across a large registry.
    // Keep a stable key order for a whole bounded sweep. Rebuilding unordered
    // HashMap keys while retaining only a numeric cursor can skip an entry
    // after deletion/reordering and violate the 2.5-second freshness gate.
    if (
        _registryCycleKeys isEqualTo []
        || {_registryCursor >= count _registryCycleKeys}
    ) then {
        _registryCycleKeys = keys (localNamespace getVariable [
            "fdelta_blast_projectileRegistry",
            createHashMap
        ]);
        _registryCursor = 0;
    };
    private _registryCount = count _registryCycleKeys;
    if (_registryCount > 0) then {
        // 128 probes per 50 ms bounds worst-case work while still revisiting
        // all 4,096 permitted entries within 1.6 seconds.
        private _batchCount = 128 min (_registryCount - _registryCursor);
        for "_offset" from 0 to (_batchCount - 1) do {
            private _key = _registryCycleKeys # (_registryCursor + _offset);
            isNil {
                private _registry = localNamespace getVariable [
                    "fdelta_blast_projectileRegistry",
                    createHashMap
                ];
            private _entry = _registry getOrDefault [_key, createHashMap];
            if (count _entry > 0) then {
                private _projectile = _entry getOrDefault [
                    "projectile",
                    objNull
                ];
                private _registeredAt = _entry getOrDefault [
                    "registeredAt",
                    -1
                ];
                private _lastSeenAt = _entry getOrDefault [
                    "lastSeenAt",
                    -1
                ];
                private _validTimestamps =
                    _registeredAt isEqualType 0
                    && {finite _registeredAt}
                    && {_registeredAt >= 0}
                    && {_registeredAt <= _now}
                    && {_lastSeenAt isEqualType 0}
                    && {finite _lastSeenAt}
                    && {_lastSeenAt >= _registeredAt}
                    && {_lastSeenAt <= _now};

                // Ownership is authoritative on the server. Rebase evidence
                // when locality moves, superseding any validator reserved by
                // the prior owner. Reporter EHs were installed on every modded
                // proxy at ProjectileCreated and will fire only on the new
                // owner at detonation.
                if (!isNull _projectile) then {
                    private _observedOwner = owner _projectile;
                    private _recordedOwner = _entry getOrDefault ["owner", -1];
                    if (
                        alive _projectile
                        && {_observedOwner > 1}
                        && {_observedOwner isNotEqualTo _recordedOwner}
                    ) then {
                        private _positionASL = getPosASL _projectile;
                        private _velocity = velocity _projectile;
                        private _trackValid =
                            count _positionASL isEqualTo 3
                            && {count _velocity isEqualTo 3}
                            && {
                                (_positionASL findIf {
                                    !(_x isEqualType 0)
                                    || {!finite _x}
                                }) < 0
                            }
                            && {
                                (_velocity findIf {
                                    !(_x isEqualType 0)
                                    || {!finite _x}
                                    || {abs _x > 10000}
                                }) < 0
                            };
                        if (_trackValid) then {
                            private _parents = getShotParents _projectile;
                            private _observedVehicle = _parents param [
                                0,
                                objNull,
                                [objNull]
                            ];
                            private _observedInstigator = _parents param [
                                1,
                                objNull,
                                [objNull]
                            ];
                            _entry set ["owner", _observedOwner];
                            _entry set ["registeredAt", _now];
                            _entry set ["lastSeenAt", _now];
                            _entry set ["lastPositionASL", _positionASL];
                            _entry set ["lastVelocity", _velocity];
                            if (!isNull _observedVehicle) then {
                                _entry set ["vehicle", _observedVehicle];
                            };
                            if (!isNull _observedInstigator) then {
                                _entry set [
                                    "instigator",
                                    _observedInstigator
                                ];
                            };
                            _entry set ["pending", false];
                            _entry set ["pendingAt", -1];
                            _entry set ["reservationId", ""];
                            _entry set [
                                "blastId",
                                format [
                                    "%1@%2:%3",
                                    _key,
                                    _observedOwner,
                                    round (_now * 1000)
                                ]
                            ];
                            _registeredAt = _now;
                            _lastSeenAt = _now;
                            _validTimestamps = true;
                        };
                    };
                };

                if (
                    !_validTimestamps
                    || {_now - _registeredAt > _maxAge}
                ) then {
                    _registry deleteAt _key;
                }
                else {
                    private _pending = _entry getOrDefault [
                        "pending",
                        false
                    ];
                    if !(_pending isEqualType true) then {_pending = false;};
                    private _pendingAt = _entry getOrDefault [
                        "pendingAt",
                        -1
                    ];
                    if (
                        _pending
                        && {
                            !(_pendingAt isEqualType 0)
                            || {!finite _pendingAt}
                            || {_pendingAt < 0}
                            || {_pendingAt > _now}
                            || {_now - _pendingAt > 15}
                        }
                    ) then {
                        _pending = false;
                        _entry set ["pending", false];
                        _entry set ["pendingAt", -1];
                        _entry set ["reservationId", ""];
                    };

                    if (!isNull _projectile) then {
                        private _ammo = _entry getOrDefault ["ammo", ""];
                        if (typeOf _projectile isNotEqualTo _ammo) then {
                            _registry deleteAt _key;
                        }
                        else {
                            if (
                                !alive _projectile
                                && {!_pending}
                                && {_now - _lastSeenAt > 3}
                            ) then {
                                _registry deleteAt _key;
                            }
                            else {
                                private _positionASL = getPosASL _projectile;
                                private _velocity = velocity _projectile;
                                private _trackValid =
                                    count _positionASL isEqualTo 3
                                    && {count _velocity isEqualTo 3}
                                    && {
                                        (_positionASL findIf {
                                            !(_x isEqualType 0)
                                            || {!finite _x}
                                        }) < 0
                                    }
                                    && {
                                        (_velocity findIf {
                                            !(_x isEqualType 0)
                                            || {!finite _x}
                                            || {abs _x > 10000}
                                        }) < 0
                                    };
                                if (_trackValid) then {
                                    _entry set ["lastSeenAt", _now];
                                    _entry set [
                                        "lastPositionASL",
                                        _positionASL
                                    ];
                                    _entry set ["lastVelocity", _velocity];
                                    _entry set [
                                        "observations",
                                        (_entry getOrDefault [
                                            "observations",
                                            0
                                        ]) + 1
                                    ];
                                };
                                _registry set [_key, _entry];
                            };
                        };
                    }
                    else {
                        if (!_pending && {_now - _lastSeenAt > 3}) then {
                            _registry deleteAt _key;
                        }
                        else {
                            _registry set [_key, _entry];
                        };
                    };
                };
            };
                localNamespace setVariable [
                    "fdelta_blast_projectileRegistry",
                    _registry
                ];
            };
        };
        _registryCursor = _registryCursor + _batchCount;
        if (_registryCursor >= _registryCount) then {
            _registryCycleKeys = [];
            _registryCursor = 0;
        };
    }
    else {
        _registryCycleKeys = [];
        _registryCursor = 0;
    };

    // Token, rate and tombstone cleanup does not need the 20 Hz tracking
    // cadence. Compute from detached snapshots and atomically commit per key
    // only when an ingress call has not changed that key in the meantime.
    if (_now >= _nextAuxCleanup) then {
        _nextAuxCleanup = _now + 1;
        private _seenSnapshot = localNamespace getVariable [
            "fdelta_blast_seen",
            createHashMap
        ];
        {
            private _key = _x;
            private _seenAtSnapshot = _seenSnapshot getOrDefault [_key, -1];
            private _stale =
                !(_seenAtSnapshot isEqualType 0)
                || {!finite _seenAtSnapshot}
                || {_seenAtSnapshot < 0}
                || {_seenAtSnapshot > _now}
                || {_now - _seenAtSnapshot > 60};
            if (_stale) then {
                isNil {
                    private _seen = localNamespace getVariable [
                        "fdelta_blast_seen",
                        createHashMap
                    ];
                    if ((_seen getOrDefault [_key, -2]) isEqualTo _seenAtSnapshot) then {
                        _seen deleteAt _key;
                    };
                };
            };
        } forEach (keys _seenSnapshot);

        private _ratesSnapshot = localNamespace getVariable [
            "fdelta_blast_ownerRates",
            createHashMap
        ];
        {
            private _key = _x;
            private _historySnapshot = _ratesSnapshot getOrDefault [_key, []];
            if !(_historySnapshot isEqualType []) then {
                _historySnapshot = [];
            };
            _historySnapshot = +_historySnapshot;
            private _filteredHistory = _historySnapshot select {
                _x isEqualType 0
                && {finite _x}
                && {_x >= 0}
                && {_x <= _now}
                && {_now - _x <= 60}
            };
            isNil {
                private _rates = localNamespace getVariable [
                    "fdelta_blast_ownerRates",
                    createHashMap
                ];
                if ((_rates getOrDefault [_key, 0]) isEqualTo _historySnapshot) then {
                    if (_filteredHistory isEqualTo []) then {
                        _rates deleteAt _key;
                    }
                    else {
                        _rates set [_key, _filteredHistory];
                    };
                };
            };
        } forEach (keys _ratesSnapshot);

        private _ingressSnapshot = localNamespace getVariable [
            "fdelta_blast_ingressBuckets",
            createHashMap
        ];
        {
            private _key = _x;
            private _stateSnapshot = _ingressSnapshot getOrDefault [_key, []];
            if !(_stateSnapshot isEqualType []) then {_stateSnapshot = [];};
            _stateSnapshot = +_stateSnapshot;
            private _tokens = _stateSnapshot param [0, -1, [0]];
            private _updatedAt = _stateSnapshot param [1, -1, [0]];
            private _stale =
                _stateSnapshot isEqualTo []
                || {!finite _tokens}
                || {_tokens < 0}
                || {!finite _updatedAt}
                || {_updatedAt < 0}
                || {_updatedAt > _now}
                || {_now - _updatedAt > 60};
            if (_stale) then {
                isNil {
                    private _ingressBuckets = localNamespace getVariable [
                        "fdelta_blast_ingressBuckets",
                        createHashMap
                    ];
                    if ((_ingressBuckets getOrDefault [
                        _key,
                        0
                    ]) isEqualTo _stateSnapshot) then {
                        _ingressBuckets deleteAt _key;
                    };
                };
            };
        } forEach (keys _ingressSnapshot);
    };

    if (_now >= _nextTraumaCleanup) then {
        _nextTraumaCleanup = _now + 30;
        private _halfLife = _settings getOrDefault [
            "fdelta_blast_halfLife",
            1800
        ];
        private _traumaMaxAge = _halfLife * 10;
        private _traumaSnapshot = localNamespace getVariable [
            "fdelta_blast_traumaRegistry",
            createHashMap
        ];
        {
            private _key = _x;
            private _stateSnapshot = _traumaSnapshot getOrDefault [_key, []];
            if !(_stateSnapshot isEqualType []) then {_stateSnapshot = [];};
            _stateSnapshot = +_stateSnapshot;
            private _target = _stateSnapshot param [0, objNull, [objNull]];
            private _lastTime = _stateSnapshot param [2, -1, [0]];
            private _stale =
                isNull _target
                || {!alive _target}
                || {!finite _lastTime}
                || {_lastTime < 0}
                || {_lastTime > _now}
                || {_now - _lastTime > _traumaMaxAge};
            if (_stale) then {
                isNil {
                    private _traumaRegistry = localNamespace getVariable [
                        "fdelta_blast_traumaRegistry",
                        createHashMap
                    ];
                    if ((_traumaRegistry getOrDefault [
                        _key,
                        0
                    ]) isEqualTo _stateSnapshot) then {
                        _traumaRegistry deleteAt _key;
                    };
                };
            };
        } forEach (keys _traumaSnapshot);
    };

    // Restart only server-local workers after an unexpected script error.
    private _validationHandle = localNamespace getVariable [
        "fdelta_blast_validationWorkerHandle",
        scriptNull
    ];
    if (scriptDone _validationHandle) then {
        localNamespace setVariable [
            "fdelta_blast_validationWorkerHandle",
            [] spawn fdelta_fnc_blastProcessValidationQueue
        ];
    };

    private _damageHandle = localNamespace getVariable [
        "fdelta_blast_damageWorkerHandle",
        scriptNull
    ];
    if (
        (localNamespace getVariable [
            "fdelta_blast_queue",
            []
        ]) isNotEqualTo []
        && {scriptDone _damageHandle}
    ) then {
        localNamespace setVariable ["fdelta_blast_workerRunning", true];
        localNamespace setVariable [
            "fdelta_blast_damageWorkerHandle",
            [] spawn fdelta_fnc_blastProcessQueue
        ];
    };

    uiSleep 0.05;
};
