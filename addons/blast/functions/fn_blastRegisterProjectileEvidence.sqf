/*
    Author: zobri

    Description:
        Records a server-observed projectile before accepting an explosion
        report. Remote callers cannot supply the ammunition, owner, parents,
        position, or registry key.

    Parameters:
        0: Networked projectile <OBJECT>

    Returns:
        Whether evidence was accepted <BOOL>
*/
if (!isServer) exitWith {false};
private _remoteCall = isRemoteExecuted;
if (_remoteCall && {canSuspend}) exitWith {false};

private _settings = localNamespace getVariable [
    "fdelta_blast_settings",
    createHashMap
];
if !(_settings getOrDefault ["fdelta_blast_enabled", true]) exitWith {false};

if !(
    _this isEqualType []
    && {count _this isEqualTo 1}
    && {(_this # 0) isEqualType objNull}
) exitWith {false};
private _projectile = _this # 0;
if (isNull _projectile) exitWith {false};

private _reportedOwner = if (_remoteCall) then {remoteExecutedOwner} else {2};
if (
    _remoteCall
    && {_reportedOwner isNotEqualTo 0}
    && {_reportedOwner <= 2}
) exitWith {false};

// Normal player calls expose their owner and can be throttled before config or
// registry work. Arma reports HC remoteExecCall as server-local with owner 0,
// so that path is identified and throttled only after server evidence binds it
// to a connected HC below.
private _ingressTokenConsumed = false;
if (_remoteCall && {_reportedOwner > 2}) then {
    if !([_reportedOwner, "evidence"] call (localNamespace getVariable [
        "fdelta_blast_consumeIngressToken",
        {false}
    ])) exitWith {false};
    _ingressTokenConsumed = true;
};

private _observedOwner = owner _projectile;
private _sourceOwner = _reportedOwner;

private _ammo = typeOf _projectile;
if (([_ammo] call (localNamespace getVariable [
    "fdelta_blast_resolveProfile",
    {[]}
])) isEqualTo []) exitWith {false};

private _key = netId _projectile;
if (_key isEqualTo "" || {_key isEqualTo "0:0"} || {count _key > 80}) exitWith {false};

private _positionASL = getPosASL _projectile;
private _velocity = velocity _projectile;
private _validPosition = count _positionASL isEqualTo 3 && {
    (_positionASL findIf {!(_x isEqualType 0) || {!finite _x}}) < 0
};
private _validVelocity = count _velocity isEqualTo 3 && {
    (_velocity findIf {
        !(_x isEqualType 0)
        || {!finite _x}
        || {abs _x > 10000}
    }) < 0
};
if (!_validPosition || {!_validVelocity}) exitWith {false};
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
private _seen = localNamespace getVariable ["fdelta_blast_seen", createHashMap];
if ((_seen getOrDefault [_key, -1]) >= 0) exitWith {false};

private _existing = _registry getOrDefault [_key, createHashMap];
private _isHeadlessOwner = localNamespace getVariable [
    "fdelta_blast_isHeadlessOwner",
    {false}
];
private _headlessIngress = false;

// Arma deliberately exposes HC remote execution as if it were server-local.
// Recover the source only from the projectile's server-observed live owner.
if (
    _observedOwner > 2
    && {[_observedOwner] call _isHeadlessOwner}
    && {
        (_remoteCall && {_reportedOwner isEqualTo 0})
        || {!_remoteCall && {_reportedOwner isEqualTo 2}}
    }
) then {
    _sourceOwner = _observedOwner;
    _headlessIngress = true;
};

// During teardown, owner can already read as server while the HC's Explode
// report is in flight. Bind that otherwise anonymous call only to an existing,
// exact, dead projectile whose recorded owner is still a connected HC. All HCs
// consequently form one trusted ingress domain, never shared with players.
private _terminalHeadlessOwner = _existing getOrDefault ["owner", -1];
private _terminalHeadlessIngress = (
    !_remoteCall
    && {_reportedOwner isEqualTo 2}
    && {_observedOwner isEqualTo 2}
    && {!alive _projectile}
    && {count _existing > 0}
    && {(_existing getOrDefault ["projectile", objNull]) isEqualTo _projectile}
    && {(_existing getOrDefault ["ammo", ""]) isEqualTo _ammo}
    && {_terminalHeadlessOwner > 2}
    && {[_terminalHeadlessOwner] call _isHeadlessOwner}
);
if (_terminalHeadlessIngress) then {
    _sourceOwner = _terminalHeadlessOwner;
    _headlessIngress = true;
};

// A normal client's identity remains available, but the server can still see
// owner 2 once teardown starts. Permit only the recorded owner to refresh its
// exact dead object; the ordinary remote-owner token was already consumed.
private _terminalClientIngress = (
    _remoteCall
    && {_reportedOwner > 2}
    && {_observedOwner isEqualTo 2}
    && {!alive _projectile}
    && {count _existing > 0}
    && {(_existing getOrDefault ["projectile", objNull]) isEqualTo _projectile}
    && {(_existing getOrDefault ["ammo", ""]) isEqualTo _ammo}
    && {(_existing getOrDefault ["owner", -1]) isEqualTo _reportedOwner}
);

private _networkIngress = _remoteCall || {_headlessIngress};
if (_networkIngress && {canSuspend}) exitWith {false};
if (_sourceOwner isEqualTo 0) exitWith {false};
if (
    _observedOwner isNotEqualTo _sourceOwner
    && {!_terminalHeadlessIngress}
    && {!_terminalClientIngress}
) exitWith {false};
if (
    _networkIngress
    && {!_ingressTokenConsumed}
    && {
        !([_sourceOwner, "evidence", _headlessIngress] call (localNamespace getVariable [
            "fdelta_blast_consumeIngressToken",
            {false}
        ]))
    }
) exitWith {false};

private _now = diag_tickTime;
private _parents = getShotParents _projectile;
private _observedVehicle = _parents param [0, objNull, [objNull]];
private _observedInstigator = _parents param [1, objNull, [objNull]];
if (count _existing > 0) exitWith {
    if (
        (_existing getOrDefault ["projectile", objNull]) isNotEqualTo _projectile
        || {(_existing getOrDefault ["ammo", ""]) isNotEqualTo _ammo}
    ) exitWith {false};

    if ((_existing getOrDefault ["owner", -1]) isEqualTo _sourceOwner) exitWith {
        // Refresh the server-read terminal track even if Explode has already
        // marked the exact registered object dead. Do not disturb an existing
        // pending reservation; its validator should consume this fresher data.
        _existing set ["lastSeenAt", _now];
        _existing set ["lastPositionASL", _positionASL];
        _existing set ["lastVelocity", _velocity];
        _existing set [
            "observations",
            (_existing getOrDefault ["observations", 0]) + 1
        ];
        if (!isNull _observedVehicle) then {
            _existing set ["vehicle", _observedVehicle];
        };
        if (!isNull _observedInstigator) then {
            _existing set ["instigator", _observedInstigator];
        };
        _registry set [_key, _existing];
        localNamespace setVariable [
            "fdelta_blast_projectileRegistry",
            _registry
        ];
        true
    };

    // Locality changed to an authenticated new owner. A fresh reservation ID
    // prevents an old validator from deleting or consuming this registration.
    // This remains valid after detonation because the exact object, ammo, and
    // server-observed source were authenticated above; brand-new dead evidence
    // is still rejected below.
    _existing set ["owner", _sourceOwner];
    _existing set ["registeredAt", _now];
    _existing set ["lastSeenAt", _now];
    _existing set ["lastPositionASL", _positionASL];
    _existing set ["lastVelocity", _velocity];
    _existing set [
        "observations",
        (_existing getOrDefault ["observations", 0]) + 1
    ];
    if (!isNull _observedVehicle) then {
        _existing set ["vehicle", _observedVehicle];
    };
    if (!isNull _observedInstigator) then {
        _existing set ["instigator", _observedInstigator];
    };
    _existing set ["pending", false];
    _existing set ["pendingAt", -1];
    _existing set ["reservationId", ""];
    _existing set [
        "blastId",
        format ["%1@%2:%3", _key, _sourceOwner, round (_now * 1000)]
    ];
    _registry set [_key, _existing];
    localNamespace setVariable ["fdelta_blast_projectileRegistry", _registry];
    true
};

if (!alive _projectile) exitWith {false};

private _maxRegistry = _settings getOrDefault ["fdelta_blast_maxRegistry", 512];
if (count _registry >= _maxRegistry) exitWith {false};

private _ownerCount = count ((keys _registry) select {
    private _entry = _registry getOrDefault [_x, createHashMap];
    (_entry getOrDefault ["owner", -1]) isEqualTo _sourceOwner
});
private _maxPerOwner = _settings getOrDefault [
    "fdelta_blast_maxRegistryPerOwner",
    128
];
if (_sourceOwner > 2 && {_ownerCount >= _maxPerOwner}) exitWith {false};

private _entry = createHashMapFromArray [
    ["projectile", _projectile],
    ["owner", _sourceOwner],
    ["ammo", _ammo],
    ["registeredAt", _now],
    ["lastSeenAt", _now],
    ["lastPositionASL", _positionASL],
    ["lastVelocity", _velocity],
    ["observations", 1],
    ["vehicle", _observedVehicle],
    ["instigator", _observedInstigator],
    ["pending", false],
    ["pendingAt", -1],
    ["reservationId", ""],
    [
        "blastId",
        format ["%1@%2:%3", _key, _sourceOwner, round (_now * 1000)]
    ]
];

_registry set [_key, _entry];
localNamespace setVariable ["fdelta_blast_projectileRegistry", _registry];
true
