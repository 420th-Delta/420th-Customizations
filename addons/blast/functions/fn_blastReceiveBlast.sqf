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
if (!isServer || {!(missionNamespace getVariable ["fdelta_blast_enabled", true])}) exitWith {
    false
};

params [
    ["_key", "", [""]],
    ["_positionASL", [], [[]]],
    ["_velocity", [], [[]]]
];

private _validPosition = count _positionASL isEqualTo 3 && {
    (_positionASL findIf {!(_x isEqualType 0) || {!finite _x}}) < 0
};
private _validVelocity = count _velocity isEqualTo 3 && {
    (_velocity findIf {!(_x isEqualType 0) || {!finite _x}}) < 0
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

private _sourceOwner = if (isRemoteExecuted) then {remoteExecutedOwner} else {2};
if (isRemoteExecuted && {_sourceOwner <= 2}) exitWith {false};

private _registry = missionNamespace getVariable [
    "fdelta_blast_projectileRegistry",
    createHashMap
];
private _entry = _registry getOrDefault [_key, createHashMap];
if (count _entry isEqualTo 0) exitWith {false};
if (_entry getOrDefault ["pending", false]) exitWith {false};
if ((_entry getOrDefault ["owner", -1]) isNotEqualTo _sourceOwner) exitWith {false};

private _ammo = _entry getOrDefault ["ammo", ""];
if (([_ammo] call fdelta_fnc_blastProfile) isEqualTo []) exitWith {false};

private _now = diag_tickTime;
private _registeredAt = _entry getOrDefault ["registeredAt", -1];
private _lastSeenAt = _entry getOrDefault ["lastSeenAt", -1];
private _lastPosition = _entry getOrDefault ["lastPositionASL", []];
private _lastVelocity = _entry getOrDefault ["lastVelocity", []];
private _maxAge = missionNamespace getVariable ["fdelta_blast_maxEvidenceAge", 300];
if (
    _registeredAt < 0
    || {_now - _registeredAt > _maxAge}
    || {_lastSeenAt < 0}
    || {_now - _lastSeenAt > 2.5}
    || {count _lastPosition isNotEqualTo 3}
    || {count _lastVelocity isNotEqualTo 3}
    || {(_lastPosition findIf {!(_x isEqualType 0) || {!finite _x}}) >= 0}
    || {(_lastVelocity findIf {!(_x isEqualType 0) || {!finite _x}}) >= 0}
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
    private _rates = missionNamespace getVariable [
        "fdelta_blast_ownerRates",
        createHashMap
    ];
    private _ownerKey = str _sourceOwner;
    private _history = _rates getOrDefault [_ownerKey, []];
    _history = _history select {_now - _x <= 60};
    private _shortCount = {_now - _x <= 10} count _history;
    private _shortLimit = missionNamespace getVariable [
        "fdelta_blast_rateShortCount",
        64
    ];
    private _longLimit = missionNamespace getVariable [
        "fdelta_blast_rateLongCount",
        192
    ];

    if (_shortCount >= _shortLimit || {count _history >= _longLimit}) then {
        _rateAllowed = false;
    } else {
        _history pushBack _now;
        _rates set [_ownerKey, _history];
        missionNamespace setVariable ["fdelta_blast_ownerRates", _rates];
    };
};
if (!_rateAllowed) exitWith {
    _registry deleteAt _key;
    missionNamespace setVariable ["fdelta_blast_projectileRegistry", _registry];
    false
};

_entry set ["pending", true];
_registry set [_key, _entry];
missionNamespace setVariable ["fdelta_blast_projectileRegistry", _registry];

[_key, _positionASL, _velocity, _sourceOwner] spawn fdelta_fnc_blastValidateReport;
true
