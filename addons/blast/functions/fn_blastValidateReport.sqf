/*
    Author: zobri

    Description:
        Waits for the server to observe projectile termination, rechecks the
        final position, consumes the evidence once, and queues blast damage.

    Parameters:
        0: Projectile network ID <STRING>
        1: Reported explosion position ASL <ARRAY>
        2: Reported velocity <ARRAY>
        3: Recorded network owner <NUMBER>
        4: Server receipt time <NUMBER>
        5: Server reservation ID <STRING>

    Returns:
        Whether the evidence was consumed and queued <BOOL>
*/
if (!isServer || {isRemoteExecuted}) exitWith {false};

params [
    ["_key", "", [""]],
    ["_positionASL", [], [[]]],
    ["_velocity", [], [[]]],
    ["_sourceOwner", -1, [0]],
    ["_receivedAt", -1, [0]],
    ["_reservationId", "", [""]]
];

// Release only the reservation that launched this validator. Run the compare
// and write unscheduled so a locality-change registration cannot be clobbered
// between them.
private _releaseReservation = {
    params ["_releaseKey", "_releaseId"];
    private _released = false;
    isNil {
        private _releaseRegistry = localNamespace getVariable [
            "fdelta_blast_projectileRegistry",
            createHashMap
        ];
        private _releaseEntry = _releaseRegistry getOrDefault [
            _releaseKey,
            createHashMap
        ];
        if (
            count _releaseEntry > 0
            && {(_releaseEntry getOrDefault [
                "reservationId",
                ""
            ]) isEqualTo _releaseId}
        ) then {
            _releaseEntry set ["pending", false];
            _releaseEntry set ["pendingAt", -1];
            _releaseEntry set ["reservationId", ""];
            _releaseRegistry set [_releaseKey, _releaseEntry];
            localNamespace setVariable [
                "fdelta_blast_projectileRegistry",
                _releaseRegistry
            ];
            _released = true;
        };
    };
    _released
};

private _startedAt = diag_tickTime;
private _validPosition = count _positionASL isEqualTo 3 && {
    (_positionASL findIf {!(_x isEqualType 0) || {!finite _x}}) < 0
};
private _validVelocity = count _velocity isEqualTo 3 && {
    (
        _velocity findIf {
            !(_x isEqualType 0)
            || {!finite _x}
            || {abs _x > 10000}
        }
    ) < 0
};
if (
    _key isEqualTo ""
    || {_reservationId isEqualTo ""}
    || {!_validPosition}
    || {!_validVelocity}
    || {!finite _receivedAt}
    || {_receivedAt < 0}
    || {_receivedAt > _startedAt}
    || {_startedAt - _receivedAt > 10}
) exitWith {
    [_key, _reservationId] call _releaseReservation;
    false
};
if (
    (_positionASL select 0) < 0
    || {(_positionASL select 1) < 0}
    || {(_positionASL select 0) > worldSize}
    || {(_positionASL select 1) > worldSize}
    || {(_positionASL select 2) < -1000}
    || {(_positionASL select 2) > 50000}
) exitWith {
    [_key, _reservationId] call _releaseReservation;
    false
};

private _deadline = _receivedAt + 2;
private _missing = false;
private _ended = false;
private _superseded = false;

waitUntil {
    uiSleep 0.02;
    private _registry = localNamespace getVariable [
        "fdelta_blast_projectileRegistry",
        createHashMap
    ];
    private _entry = _registry getOrDefault [_key, createHashMap];
    if (count _entry isEqualTo 0) then {
        _missing = true;
    } else {
        if (
            (_entry getOrDefault [
                "reservationId",
                ""
            ]) isNotEqualTo _reservationId
        ) then {
            _superseded = true;
        } else {
            private _projectile = _entry getOrDefault ["projectile", objNull];
            _ended = isNull _projectile || {!alive _projectile};
        };
    };

    _missing || {_superseded} || {_ended} || {diag_tickTime >= _deadline}
};

if (_missing || {_superseded}) exitWith {false};

private _registry = localNamespace getVariable [
    "fdelta_blast_projectileRegistry",
    createHashMap
];
private _entry = _registry getOrDefault [_key, createHashMap];
if (count _entry isEqualTo 0) exitWith {false};
if ((_entry getOrDefault [
    "reservationId",
    ""
]) isNotEqualTo _reservationId) exitWith {
    false
};

if (!_ended) exitWith {
    // An early or forged report cannot consume a still-live projectile. Clear
    // the reservation so a later genuine Explode event may be considered.
    [_key, _reservationId] call _releaseReservation;
    false
};

private _ammo = _entry getOrDefault ["ammo", ""];
private _registeredAt = _entry getOrDefault ["registeredAt", -1];
private _lastSeenAt = _entry getOrDefault ["lastSeenAt", -1];
private _lastPosition = _entry getOrDefault ["lastPositionASL", []];
private _lastVelocity = _entry getOrDefault ["lastVelocity", []];
private _now = diag_tickTime;
private _validEvidence =
    (_entry getOrDefault ["owner", -1]) isEqualTo _sourceOwner
    && {([_ammo] call (localNamespace getVariable [
        "fdelta_blast_resolveProfile",
        {[]}
    ])) isNotEqualTo []}
    && {_registeredAt isEqualType 0}
    && {finite _registeredAt}
    && {_registeredAt >= 0}
    && {_registeredAt <= _receivedAt}
    && {_receivedAt >= 0}
    && {finite _receivedAt}
    && {_receivedAt <= _now}
    && {_now - _receivedAt <= 10}
    && {_lastSeenAt isEqualType 0}
    && {finite _lastSeenAt}
    && {_lastSeenAt >= 0}
    && {_lastSeenAt >= _registeredAt}
    && {_lastSeenAt <= _now}
    && {_now - _lastSeenAt <= 2.5}
    && {((_receivedAt - _lastSeenAt) max 0) <= 2.5}
    && {count _lastPosition isEqualTo 3}
    && {count _lastVelocity isEqualTo 3}
    && {(_lastPosition findIf {!(_x isEqualType 0) || {!finite _x}}) < 0}
    && {
        (
            _lastVelocity findIf {
                !(_x isEqualType 0)
                || {!finite _x}
                || {abs _x > 10000}
            }
        ) < 0
    };

if (_validEvidence) then {
    _validEvidence =
        (_lastPosition select 0) >= 0
        && {(_lastPosition select 1) >= 0}
        && {(_lastPosition select 0) <= worldSize}
        && {(_lastPosition select 1) <= worldSize}
        && {(_lastPosition select 2) >= -1000}
        && {(_lastPosition select 2) <= 50000};
};

if (_validEvidence) then {
    private _elapsed = ((_receivedAt - _lastSeenAt) max 0) min 2.5;
    private _predicted = _lastPosition vectorAdd (_lastVelocity vectorMultiply _elapsed);
    private _speed = vectorMagnitude _lastVelocity;
    private _tolerance = (35 + (_speed * (_elapsed + 0.15))) min 750;
    private _evidenceDistance = (_positionASL distance _lastPosition) min
        (_positionASL distance _predicted);
    _validEvidence = _evidenceDistance <= _tolerance;
};

// The caller's position has now served its only purpose: rejecting an
// implausible report. Damage origin is derived exclusively from the server's
// last observed track, with both extrapolation time and distance tightly capped.
private _trustedOrigin = [];
if (_validEvidence) then {
    private _serverElapsed = ((_receivedAt - _lastSeenAt) max 0) min 0.25;
    private _speed = vectorMagnitude _lastVelocity;
    private _travel = (_speed * _serverElapsed) min 75;
    private _scale = 0;
    if (_speed > 0.001) then {_scale = _travel / _speed};
    _trustedOrigin = _lastPosition vectorAdd (_lastVelocity vectorMultiply _scale);
    _validEvidence =
        count _trustedOrigin isEqualTo 3
        && {(_trustedOrigin findIf {!(_x isEqualType 0) || {!finite _x}}) < 0}
        && {(_trustedOrigin select 0) >= 0}
        && {(_trustedOrigin select 1) >= 0}
        && {(_trustedOrigin select 0) <= worldSize}
        && {(_trustedOrigin select 1) <= worldSize}
        && {(_trustedOrigin select 2) >= -1000}
        && {(_trustedOrigin select 2) <= 50000};
};

private _blastId = _entry getOrDefault ["blastId", _key];
private _vehicle = _entry getOrDefault ["vehicle", objNull];
private _instigator = _entry getOrDefault ["instigator", objNull];
private _settings = localNamespace getVariable [
    "fdelta_blast_settings",
    createHashMap
];
private _maxDamageQueue = _settings getOrDefault [
    "fdelta_blast_maxDamageQueue",
    128
];
private _maxSeen = ((
    _settings getOrDefault ["fdelta_blast_maxRegistry", 512]
) * 4) max 256 min 16384;

// Atomically recheck and consume the exact reservation. A new owner may have
// installed a fresh reservation while this scheduled validator was calculating;
// that state must survive untouched. Invalid evidence still consumes only its
// own terminated-projectile reservation, while a full damage queue drops the
// blast without allowing stale retries.
private _reservationConsumed = false;
private _queued = false;
isNil {
    private _commitRegistry = localNamespace getVariable [
        "fdelta_blast_projectileRegistry",
        createHashMap
    ];
    private _commitEntry = _commitRegistry getOrDefault [
        _key,
        createHashMap
    ];
    if (
        count _commitEntry > 0
        && {(_commitEntry getOrDefault [
            "reservationId",
            ""
        ]) isEqualTo _reservationId}
    ) then {
        _commitRegistry deleteAt _key;
        localNamespace setVariable [
            "fdelta_blast_projectileRegistry",
            _commitRegistry
        ];
        _reservationConsumed = true;

        private _seen = localNamespace getVariable [
            "fdelta_blast_seen",
            createHashMap
        ];
        private _alreadySeen = (_seen getOrDefault [_key, -1]) >= 0;
        if (!_alreadySeen && {count _seen >= _maxSeen}) then {
            private _oldestKey = "";
            private _oldestAt = 1e39;
            {
                private _seenAt = _y;
                private _candidateAt = if (
                    _seenAt isEqualType 0
                    && {finite _seenAt}
                ) then {
                    _seenAt
                }
                else {
                    -1
                };
                if (_candidateAt < _oldestAt) then {
                    _oldestAt = _candidateAt;
                    _oldestKey = _x;
                };
            } forEach _seen;
            if (_oldestKey isNotEqualTo "") then {
                _seen deleteAt _oldestKey;
            };
        };
        _seen set [_key, _now];
        localNamespace setVariable ["fdelta_blast_seen", _seen];

        if (_validEvidence && {!_alreadySeen}) then {
            private _queue = localNamespace getVariable [
                "fdelta_blast_queue",
                []
            ];
            if (count _queue < _maxDamageQueue) then {
                _queue pushBack [
                    _blastId,
                    _ammo,
                    _trustedOrigin,
                    _lastVelocity,
                    _vehicle,
                    _instigator
                ];
                localNamespace setVariable ["fdelta_blast_queue", _queue];
                _queued = true;
            };
        };
    };
};

if (!_reservationConsumed || {!_validEvidence} || {!_queued}) exitWith {false};

private _damageWorker = localNamespace getVariable [
    "fdelta_blast_damageWorkerHandle",
    scriptNull
];
if (
    !(localNamespace getVariable ["fdelta_blast_workerRunning", false])
    || {scriptDone _damageWorker}
) then {
    localNamespace setVariable ["fdelta_blast_workerRunning", true];
    localNamespace setVariable [
        "fdelta_blast_damageWorkerHandle",
        [] spawn fdelta_fnc_blastProcessQueue
    ];
};

if (_settings getOrDefault ["fdelta_blast_debug", false]) then {
    diag_log format [
        "FDELTA_BLAST_VALIDATED|id=%1|owner=%2|ammo=%3|origin=%4|reported=%5",
        _blastId,
        _sourceOwner,
        _ammo,
        _trustedOrigin,
        _positionASL
    ];
};

true
