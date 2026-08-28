/*
    Author: zobri

    Validates and stores an immutable launch cue in the projectile owner's
    local registry, including caller ownership and launcher association checks.
*/
if !(
    _this isEqualType []
    && {count _this >= 2}
    && {count _this <= 4}
) exitWith {false};
private _missile = _this # 0;
private _cue = _this # 1;
private _sourceUnit = _this param [2, objNull];
private _rerouted = _this param [3, false];

if !(_missile isEqualType objNull) exitWith {false};
if !(_cue isEqualType []) exitWith {false};
if !(_sourceUnit isEqualType objNull) exitWith {false};
if !(_rerouted isEqualType true) exitWith {false};
if (isNull _missile || {typeOf _missile isNotEqualTo "fdelta_M_Scalpel_L"}) exitWith {false};

private _remoteCall = isRemoteExecuted;

// A remote call that lands anywhere except the authoritative owner is never
// forwarded. Only an ordinary local call may make the single owner hop.
if (_remoteCall && {!local _missile}) exitWith {false};
if (!_remoteCall && {_rerouted}) exitWith {false};
if (!local _missile) exitWith {
    if (!_rerouted) then {
        [_missile, _cue, _sourceUnit, true] remoteExecCall
            ["fdelta_fnc_scalpelLReceiveCue", owner _missile];
    };
    false
};
if (_remoteCall && {!_rerouted}) exitWith {false};

// Consume a cheap owner-local token before parsing attacker-controlled cue
// data or querying shot parents. One legitimate cue is expected per launch.
private _rateAllowed = true;
private _remoteOwner = -1;
if (_remoteCall) then {
    _remoteOwner = remoteExecutedOwner;
    private _rateBuckets = localNamespace getVariable
        ["fdelta_scalpelL_remoteCueRates", createHashMap];
    if !(_rateBuckets isEqualType createHashMap) then {
        _rateBuckets = createHashMap;
    };
    localNamespace setVariable ["fdelta_scalpelL_remoteCueRates", _rateBuckets];

    private _now = diag_tickTime;
    private _rateState = _rateBuckets getOrDefault [_remoteOwner, [8, _now]];
    if (
        !(_rateState isEqualType [])
        || {(count _rateState) isNotEqualTo 2}
        || {!((_rateState # 0) isEqualType 0)}
        || {!((_rateState # 1) isEqualType 0)}
        || {!(finite (_rateState # 0))}
        || {!(finite (_rateState # 1))}
    ) then {
        _rateState = [8, _now];
    };

    private _tokens = ((_rateState # 0) + (((_now - (_rateState # 1)) max 0) * 4)) min 8;
    if (_tokens < 1) then {
        _rateAllowed = false;
    }
    else {
        _tokens = _tokens - 1;
    };
    _rateBuckets set [_remoteOwner, [_tokens, _now]];

    private _staleOwners = [];
    {
        private _state = _y;
        if (
            !(_state isEqualType [])
            || {(count _state) isNotEqualTo 2}
            || {!((_state # 1) isEqualType 0)}
            || {!(finite (_state # 1))}
            || {_now - (_state # 1) > 300}
        ) then {
            _staleOwners pushBack _x;
        };
    } forEach _rateBuckets;
    {_rateBuckets deleteAt _x;} forEach _staleOwners;

    if (count _rateBuckets > 256) then {
        private _statesByAge = [];
        {
            _statesByAge pushBack [(_y param [1, -1]), _x];
        } forEach _rateBuckets;
        _statesByAge sort true;
        for "_index" from 0 to (count _rateBuckets - 257) do {
            _rateBuckets deleteAt ((_statesByAge # _index) # 1);
        };
    };
};
if (!_rateAllowed) exitWith {false};

if ((count _cue) isNotEqualTo 6) exitWith {false};
_cue params [
    "_priority",
    "_aimpointATL",
    "_selectedTarget",
    "_lockValue",
    "_source",
    "_capturedAt"
];
if !(_priority isEqualType 0) exitWith {false};
if !(_aimpointATL isEqualType []) exitWith {false};
if !(_selectedTarget isEqualType objNull) exitWith {false};
if !(_lockValue isEqualType 0) exitWith {false};
if !(_source isEqualType "") exitWith {false};
if !(_capturedAt isEqualType 0) exitWith {false};
if !((finite _priority) && {finite _lockValue} && {finite _capturedAt}) exitWith {false};
if (_lockValue < 0 || {_lockValue > 1}) exitWith {false};
if (
    (count _aimpointATL) isNotEqualTo 3
    || {
        (_aimpointATL findIf {
            !(_x isEqualType 0)
            || {!(finite _x)}
            || {abs _x > 1000000}
        }) >= 0
    }
) exitWith {false};

private _sources =
[
    "launcher-axis",
    "ai-target-snapshot",
    "engine-hard-lock",
    "camera-los",
    "selected-snapshot",
    "player-hard-lock"
];
private _sourceIndex = _sources find _source;
if (_sourceIndex < 0) exitWith {false};
private _expectedPriority = [20, 60, 200, 220, 250, 290] # _sourceIndex;
if (_priority isNotEqualTo _expectedPriority) exitWith {false};

private _hasTarget = !isNull _selectedTarget;
private _cueShapeValid = switch (_source) do {
    case "launcher-axis": {!_hasTarget && {_lockValue isEqualTo 0}};
    case "camera-los": {!_hasTarget && {_lockValue isEqualTo 0}};
    case "ai-target-snapshot": {_hasTarget && {_lockValue < 0.999}};
    case "selected-snapshot": {_hasTarget && {_lockValue < 0.999}};
    case "engine-hard-lock": {_hasTarget && {_lockValue >= 0.999}};
    case "player-hard-lock": {_hasTarget && {_lockValue >= 0.999}};
    default {false};
};
if (!_cueShapeValid) exitWith {false};

// AI/engine fallback cues are generated synchronously by the authoritative
// projectile owner. Accepting those labels over the network would let a
// client bypass the operator checks below with a forged high-priority target.
private _uiSources = ["camera-los", "selected-snapshot", "player-hard-lock"];
if (_remoteCall && {!(_source in _uiSources)}) exitWith {false};

// Keep launch snapshots near the configured acquisition envelope. The five
// percent (at least 250 m) margin covers a 6000 m edge capture while the
// projectile travels to its owner and differences between camera/weapon axes.
private _ammoConfig = configOf _missile;
private _aimRange = getNumber (_ammoConfig >> "fdelta_scalpelL_aimRange");
private _lockRange = getNumber (_ammoConfig >> "missileLockMaxDistance");
private _cueRange = _aimRange max _lockRange;
if (_cueRange <= 0) then {_cueRange = 6000;};
private _cueRangeLimit = _cueRange + ((_cueRange * 0.05) max 250);
private _missileATL = getPosATL _missile;
if ((_missileATL vectorDistance _aimpointATL) > _cueRangeLimit) exitWith {false};
if (
    _hasTarget
    && {(_missileATL vectorDistance (getPosATL _selectedTarget)) > _cueRangeLimit}
) exitWith {false};

// UI-derived cues require an authenticated operator even when the projectile
// happens to be local to that operator's client. For UAVs only the active
// gunner controller qualifies; a connected pilot or terminal user does not.
private _operatorValid = true;
if (_source in _uiSources) then {
    private _callerOwnsSource = !isNull _sourceUnit;
    if (_callerOwnsSource) then {
        _callerOwnsSource = if (_remoteCall) then {
            isPlayer _sourceUnit
            && {(owner _sourceUnit) isEqualTo _remoteOwner}
        }
        else {
            local _sourceUnit
        };
    };

    private _parents = getShotParents _missile;
    private _launcher = _parents param [0, objNull];
    private _instigator = _parents param [1, objNull];
    private _associated = false;
    if (_callerOwnsSource && {!isNull _launcher}) then {
        if (unitIsUAV _launcher) then {
            _associated = _sourceUnit in (UAVControl [_launcher, "gunner"]);
        }
        else {
            _associated = _sourceUnit isEqualTo _instigator;
            // Preserve owner-local pylon/manual-fire fallbacks, but do not
            // broaden remote authority beyond the engine's shot instigator.
            if (
                !_remoteCall
                && {!_associated}
                && {vehicle _sourceUnit isEqualTo _launcher}
            ) then {
                private _turretPath = _launcher unitTurret _sourceUnit;
                _associated = "fdelta_missiles_Scalpel_L" in
                    (_launcher weaponsTurret _turretPath);
                if (
                    !_associated
                    && {_sourceUnit isEqualTo currentPilot _launcher}
                    && {isManualFire _launcher}
                ) then {
                    _associated = true;
                };
            };
        };
    };
    _operatorValid = _callerOwnsSource && {_associated};
};
if (!_operatorValid) exitWith {false};

// Objects are not native HashMap keys. Bucket by hashValue, retain the object
// in each record, and resolve collisions by identity before reading/writing.
private _registry = localNamespace getVariable
    ["fdelta_scalpelL_ownerRegistry", createHashMap];
if !(_registry isEqualType createHashMap) then {
    _registry = createHashMap;
};
localNamespace setVariable ["fdelta_scalpelL_ownerRegistry", _registry];
private _missileHash = hashValue _missile;
private _bucket = _registry getOrDefault [_missileHash, []];
if !(_bucket isEqualType []) then {_bucket = [];};
_bucket = _bucket select {
    _x isEqualType []
    && {(count _x) >= 5}
    && {(_x # 0) isEqualType objNull}
    && {!isNull (_x # 0)}
};
private _entryIndex = _bucket findIf {(_x # 0) isEqualTo _missile};
if (_entryIndex < 0) then {
    private _serial = localNamespace getVariable ["fdelta_scalpelL_registrySerial", 0];
    if !(_serial isEqualType 0) then {_serial = 0;};
    _serial = _serial + 1;
    if (!(finite _serial) || {_serial > 1000000000}) then {_serial = 1;};
    localNamespace setVariable ["fdelta_scalpelL_registrySerial", _serial];
    _bucket pushBack [_missile, [], false, false, _serial];
    _entryIndex = (count _bucket) - 1;
};
_registry set [_missileHash, _bucket];

private _entry = _bucket # _entryIndex;
private _existing = _entry param [1, []];
if !(_existing isEqualType []) then {_existing = [];};
if (_existing isEqualTo [] || {(_cue # 0) > (_existing # 0)}) then {
    // Detach the nested coordinate array so later caller mutation cannot alter
    // the snapshot consumed by the guidance controller.
    private _trustedCue = +_cue;
    _trustedCue set [0, _expectedPriority];
    _trustedCue set [1, +_aimpointATL];
    _entry set [1, _trustedCue];
};

_bucket set [_entryIndex, _entry];
_registry set [_missileHash, _bucket];
localNamespace setVariable ["fdelta_scalpelL_ownerRegistry", _registry];

true
