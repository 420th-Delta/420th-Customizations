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

    Returns:
        Whether the evidence was consumed and queued <BOOL>
*/
if (!isServer || {isRemoteExecuted}) exitWith {false};

params [
    ["_key", "", [""]],
    ["_positionASL", [], [[]]],
    ["_velocity", [], [[]]],
    ["_sourceOwner", -1, [0]]
];

private _deadline = diag_tickTime + 2;
private _missing = false;
private _ended = false;

waitUntil {
    uiSleep 0.02;
    private _registry = missionNamespace getVariable [
        "fdelta_blast_projectileRegistry",
        createHashMap
    ];
    private _entry = _registry getOrDefault [_key, createHashMap];
    if (count _entry isEqualTo 0) then {
        _missing = true;
    } else {
        private _projectile = _entry getOrDefault ["projectile", objNull];
        _ended = isNull _projectile || {!alive _projectile};
    };

    _missing || {_ended} || {diag_tickTime >= _deadline}
};

if (_missing) exitWith {false};

private _registry = missionNamespace getVariable [
    "fdelta_blast_projectileRegistry",
    createHashMap
];
private _entry = _registry getOrDefault [_key, createHashMap];
if (count _entry isEqualTo 0) exitWith {false};

if (!_ended) exitWith {
    // An early or forged report cannot consume a still-live projectile. Clear
    // the reservation so a later genuine Explode event may be considered.
    _entry set ["pending", false];
    _registry set [_key, _entry];
    missionNamespace setVariable ["fdelta_blast_projectileRegistry", _registry];
    false
};

private _ammo = _entry getOrDefault ["ammo", ""];
private _lastSeenAt = _entry getOrDefault ["lastSeenAt", -1];
private _lastPosition = _entry getOrDefault ["lastPositionASL", []];
private _lastVelocity = _entry getOrDefault ["lastVelocity", []];
private _now = diag_tickTime;
private _validEvidence =
    (_entry getOrDefault ["owner", -1]) isEqualTo _sourceOwner
    && {([_ammo] call fdelta_fnc_blastProfile) isNotEqualTo []}
    && {_lastSeenAt >= 0}
    && {_now - _lastSeenAt <= 2.5}
    && {count _lastPosition isEqualTo 3}
    && {count _lastVelocity isEqualTo 3}
    && {(_lastPosition findIf {!(_x isEqualType 0) || {!finite _x}}) < 0}
    && {(_lastVelocity findIf {!(_x isEqualType 0) || {!finite _x}}) < 0};

if (_validEvidence) then {
    private _elapsed = ((_now - _lastSeenAt) max 0) min 2.5;
    private _predicted = _lastPosition vectorAdd (_lastVelocity vectorMultiply _elapsed);
    private _speed = vectorMagnitude _lastVelocity;
    private _tolerance = (35 + (_speed * (_elapsed + 0.15))) min 750;
    private _evidenceDistance = (_positionASL distance _lastPosition) min
        (_positionASL distance _predicted);
    _validEvidence = _evidenceDistance <= _tolerance;
};

// A terminated projectile consumes its registry slot whether the final report
// passed or failed, preventing retries against stale evidence.
_registry deleteAt _key;
missionNamespace setVariable ["fdelta_blast_projectileRegistry", _registry];
if (!_validEvidence) exitWith {false};

private _seen = missionNamespace getVariable ["fdelta_blast_seen", createHashMap];
if ((_seen getOrDefault [_key, -1]) >= 0) exitWith {false};
_seen set [_key, _now];
missionNamespace setVariable ["fdelta_blast_seen", _seen];

private _blastId = _entry getOrDefault ["blastId", _key];
private _vehicle = _entry getOrDefault ["vehicle", objNull];
private _instigator = _entry getOrDefault ["instigator", objNull];
private _queue = missionNamespace getVariable ["fdelta_blast_queue", []];
_queue pushBack [
    _blastId,
    _ammo,
    _positionASL,
    _velocity,
    _vehicle,
    _instigator
];
missionNamespace setVariable ["fdelta_blast_queue", _queue];

if !(missionNamespace getVariable ["fdelta_blast_workerRunning", false]) then {
    missionNamespace setVariable ["fdelta_blast_workerRunning", true];
    [] spawn fdelta_fnc_blastProcessQueue;
};

if (missionNamespace getVariable ["fdelta_blast_debug", false]) then {
    diag_log format [
        "FDELTA_BLAST_VALIDATED|id=%1|owner=%2|ammo=%3|position=%4",
        _blastId,
        _sourceOwner,
        _ammo,
        _positionASL
    ];
};

true
