/*
    Author: zobri

    Description:
        Applies server-side token buckets to player and authenticated HC blast
        ingress. Genuine owner-2 server calls are trusted and do not consume
        tokens; HC calls consume tokens even though Arma masks their remote
        execution context.

    Parameters:
        0: Remote network owner <NUMBER>
        1: Ingress channel <STRING>
        2: Endpoint authenticated an owner-0 HC call <BOOL>

    Returns:
        Whether the call may continue <BOOL>
*/
if (!isServer) exitWith {false};

params [
    ["_sourceOwner", -1, [0]],
    ["_channel", "", [""]],
    ["_allowOwnerZero", false, [true]]
];

if (
    isRemoteExecuted
    && {remoteExecutedOwner isNotEqualTo _sourceOwner}
    && {!(_allowOwnerZero && {remoteExecutedOwner isEqualTo 0})}
) exitWith {false};
if (_sourceOwner isEqualTo 2) exitWith {true};
if (_sourceOwner < 0 || {_sourceOwner isEqualTo 1}) exitWith {false};
if !(_channel in ["evidence", "report"]) exitWith {false};

private _now = diag_tickTime;
private _settings = localNamespace getVariable ["fdelta_blast_settings", createHashMap];
private _capacity = _settings getOrDefault ["fdelta_blast_ingressCapacity", 256];
private _refill = _settings getOrDefault ["fdelta_blast_ingressRefill", 64];
private _globalCapacity = _settings getOrDefault [
    "fdelta_blast_globalIngressCapacity",
    1024
];
private _globalRefill = _settings getOrDefault [
    "fdelta_blast_globalIngressRefill",
    256
];
private _buckets = localNamespace getVariable [
    "fdelta_blast_ingressBuckets",
    createHashMap
];

private _consume = {
    params ["_key", "_limit", "_rate", "_now", "_buckets"];
    private _state = _buckets getOrDefault [_key, [_limit, _now]];
    private _tokens = _state param [0, _limit, [0]];
    private _updatedAt = _state param [1, _now, [0]];
    if (
        !finite _tokens
        || {!finite _updatedAt}
        || {_updatedAt < 0}
        || {_updatedAt > _now}
    ) then {
        _tokens = _limit;
        _updatedAt = _now;
    };
    _tokens = (_tokens max 0) min _limit;
    _tokens = (_tokens + ((_now - _updatedAt) * _rate)) min _limit;
    private _allowed = _tokens >= 1;
    if (_allowed) then {_tokens = _tokens - 1};
    _buckets set [_key, [_tokens, _now]];
    _allowed
};

private _ownerAllowed = [
    format ["%1|%2", _sourceOwner, _channel],
    _capacity,
    _refill,
    _now,
    _buckets
] call _consume;
if (!_ownerAllowed) exitWith {
    localNamespace setVariable ["fdelta_blast_ingressBuckets", _buckets];
    false
};

private _globalAllowed = [
    format ["global|%1", _channel],
    _globalCapacity,
    _globalRefill,
    _now,
    _buckets
] call _consume;
localNamespace setVariable ["fdelta_blast_ingressBuckets", _buckets];
_globalAllowed
