/*
    Author: zobri

    Description:
        Reserves server-recorded projectile evidence for validation. The caller
        supplies only its registry key and observed explosion vectors.

    Parameters:
        0: Projectile network ID <STRING>
        1: Explosion position ASL <ARRAY>
        2: Projectile velocity at explosion <ARRAY>

    Returns:
        Whether the report entered validation <BOOL>
*/
if (!isServer) exitWith {false};

private _settings = localNamespace getVariable ["fdelta_blast_settings", createHashMap];
if !(_settings getOrDefault ["fdelta_blast_enabled", true]) exitWith {false};
private _remoteCall = isRemoteExecuted;
if (_remoteCall && {canSuspend}) exitWith {false};

private _sourceOwner = if (_remoteCall) then {remoteExecutedOwner} else {2};
if (
    _remoteCall
    && {_sourceOwner isNotEqualTo 0}
    && {_sourceOwner <= 2}
) exitWith {false};
private _ingressTokenConsumed = false;
if (_remoteCall && {_sourceOwner > 2}) then {
    if !([_sourceOwner, "report"] call (localNamespace getVariable [
        "fdelta_blast_consumeIngressToken",
        {false}
    ])) exitWith {false};
    _ingressTokenConsumed = true;
};

if !(
    _this isEqualType []
    && {count _this isEqualTo 3}
    && {(_this # 0) isEqualType ""}
    && {(_this # 1) isEqualType []}
    && {(_this # 2) isEqualType []}
) exitWith {false};
private _key = _this # 0;
private _positionASL = _this # 1;
private _velocity = _this # 2;

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
    || {count _key > 80}
    || {!_validPosition}
    || {!_validVelocity}
) exitWith {false};

if (
    (_positionASL select 0) < 0
    || {(_positionASL select 1) < 0}
    || {(_positionASL select 0) > worldSize}
    || {(_positionASL select 1) > worldSize}
    || {(_positionASL select 2) < -1000}
    || {(_positionASL select 2) > 50000}
) exitWith {false};

private _registry = localNamespace getVariable [
    "fdelta_blast_projectileRegistry",
    createHashMap
];
private _entry = _registry getOrDefault [_key, createHashMap];
if (count _entry isEqualTo 0) exitWith {false};
if (_entry getOrDefault ["pending", false]) exitWith {false};

private _entryOwner = _entry getOrDefault ["owner", -1];
private _headlessIngress = false;
if (
    _entryOwner > 2
    && {
        [_entryOwner] call (localNamespace getVariable [
            "fdelta_blast_isHeadlessOwner",
            {false}
        ])
    }
    && {
        (_remoteCall && {_sourceOwner isEqualTo 0})
        || {!_remoteCall && {_sourceOwner isEqualTo 2}}
    }
) then {
    _sourceOwner = _entryOwner;
    _headlessIngress = true;
};

private _networkIngress = _remoteCall || {_headlessIngress};
if (_networkIngress && {canSuspend}) exitWith {false};
if (_sourceOwner isEqualTo 0) exitWith {false};
if (_entryOwner isNotEqualTo _sourceOwner) exitWith {false};
if (
    _networkIngress
    && {!_ingressTokenConsumed}
    && {
        !([_sourceOwner, "report", _headlessIngress] call (localNamespace getVariable [
            "fdelta_blast_consumeIngressToken",
            {false}
        ]))
    }
) exitWith {false};

private _ammo = _entry getOrDefault ["ammo", ""];
if (([_ammo] call (localNamespace getVariable [
    "fdelta_blast_resolveProfile",
    {[]}
])) isEqualTo []) exitWith {false};

private _now = diag_tickTime;
private _registeredAt = _entry getOrDefault ["registeredAt", -1];
private _lastSeenAt = _entry getOrDefault ["lastSeenAt", -1];
private _lastPosition = _entry getOrDefault ["lastPositionASL", []];
private _lastVelocity = _entry getOrDefault ["lastVelocity", []];
private _maxAge = _settings getOrDefault ["fdelta_blast_maxEvidenceAge", 300];
if (
    !(_registeredAt isEqualType 0)
    || {!finite _registeredAt}
    || {_registeredAt < 0}
    || {_registeredAt > _now}
    || {!(_lastSeenAt isEqualType 0)}
    || {!finite _lastSeenAt}
    || {_now - _registeredAt > _maxAge}
    || {_lastSeenAt < 0}
    || {_lastSeenAt > _now}
    || {_lastSeenAt < _registeredAt}
    || {_now - _lastSeenAt > 2.5}
    || {count _lastPosition isNotEqualTo 3}
    || {count _lastVelocity isNotEqualTo 3}
    || {(_lastPosition findIf {!(_x isEqualType 0) || {!finite _x}}) >= 0}
    || {
        (
            _lastVelocity findIf {
                !(_x isEqualType 0)
                || {!finite _x}
                || {abs _x > 10000}
            }
        ) >= 0
    }
) exitWith {false};
if (
    (_lastPosition select 0) < 0
    || {(_lastPosition select 1) < 0}
    || {(_lastPosition select 0) > worldSize}
    || {(_lastPosition select 1) > worldSize}
    || {(_lastPosition select 2) < -1000}
    || {(_lastPosition select 2) > 50000}
) exitWith {false};

private _projectile = _entry getOrDefault ["projectile", objNull];
if (!isNull _projectile && {typeOf _projectile isNotEqualTo _ammo}) exitWith {false};
if (
    !isNull _projectile
    && {alive _projectile}
    && {owner _projectile isNotEqualTo _sourceOwner}
) exitWith {false};

private _elapsed = ((_now - _lastSeenAt) max 0) min 2.5;
private _predicted = _lastPosition vectorAdd (_lastVelocity vectorMultiply _elapsed);
private _speed = vectorMagnitude _lastVelocity;
private _tolerance = (35 + (_speed * (_elapsed + 0.15))) min 750;
private _evidenceDistance = (_positionASL distance _lastPosition) min
    (_positionASL distance _predicted);
if (_evidenceDistance > _tolerance) exitWith {false};

// Trusted server-owned ordnance is not throttled. Player and HC owners retain
// enough burst capacity for rocket pods and artillery salvos.
private _rateAllowed = true;
if (_sourceOwner > 2) then {
    private _rates = localNamespace getVariable [
        "fdelta_blast_ownerRates",
        createHashMap
    ];
    private _ownerKey = str _sourceOwner;
    private _history = _rates getOrDefault [_ownerKey, []];
    _history = _history select {
        _x isEqualType 0
        && {finite _x}
        && {_x >= 0}
        && {_x <= _now}
        && {_now - _x <= 60}
    };
    private _shortCount = {_now - _x <= 10} count _history;
    private _shortLimit = _settings getOrDefault [
        "fdelta_blast_rateShortCount",
        64
    ];
    private _longLimit = _settings getOrDefault [
        "fdelta_blast_rateLongCount",
        192
    ];

    if (_shortCount >= _shortLimit || {count _history >= _longLimit}) then {
        _rateAllowed = false;
    } else {
        _history pushBack _now;
        _rates set [_ownerKey, _history];
        localNamespace setVariable ["fdelta_blast_ownerRates", _rates];
    };
};
if (!_rateAllowed) exitWith {
    _registry deleteAt _key;
    localNamespace setVariable ["fdelta_blast_projectileRegistry", _registry];
    false
};

private _blastId = _entry getOrDefault ["blastId", ""];
if !(_blastId isEqualType "" && {_blastId isNotEqualTo ""}) exitWith {
    false
};

// Bound queued validators independently of the registry. Locality changes may
// invalidate old queue items without removing them immediately, so the one-
// pending-report-per-entry rule alone is not a strict memory bound.
private _validationQueue = localNamespace getVariable [
    "fdelta_blast_validationQueue",
    []
];
private _maxValidationQueue = _settings getOrDefault [
    "fdelta_blast_maxRegistry",
    512
];
if (count _validationQueue >= _maxValidationQueue) exitWith {false};

private _reservationSerial = localNamespace getVariable [
    "fdelta_blast_reservationSerial",
    0
];
if !(_reservationSerial isEqualType 0 && {finite _reservationSerial}) then {
    _reservationSerial = 0;
};
_reservationSerial = _reservationSerial + 1;
if (_reservationSerial > 1000000000) then {_reservationSerial = 1;};
localNamespace setVariable [
    "fdelta_blast_reservationSerial",
    _reservationSerial
];
private _reservationId = format [
    "%1#%2:%3",
    _blastId,
    round (_now * 1000),
    _reservationSerial
];

_entry set ["pending", true];
_entry set ["pendingAt", _now];
_entry set ["reservationId", _reservationId];
_registry set [_key, _entry];
localNamespace setVariable ["fdelta_blast_projectileRegistry", _registry];

// remoteExecCall runs this function in the caller's remote-execution context.
// A child spawned directly here inherits that context, so the validator's
// server-local security guard would reject it. A worker created locally during
// preInit drains this queue and starts validation outside the remote context.
_validationQueue pushBack [
    _key,
    _positionASL,
    _velocity,
    _sourceOwner,
    _now,
    _reservationId
];
localNamespace setVariable [
    "fdelta_blast_validationQueue",
    _validationQueue
];
true
