/*
    Author: zobri

    Handles a Scalpel-L Fired event, captures the firing operator's immutable
    launch cue, and starts guidance only where the projectile is local.
*/
if (isRemoteExecuted) exitWith {};

params [
    "_launcher",
    "_weapon",
    "_muzzle",
    "_mode",
    "_ammo",
    "_magazine",
    "_missile",
    ["_gunner", objNull]
];

if (isNull _missile || {_ammo isNotEqualTo "fdelta_M_Scalpel_L"}) exitWith {};

// Weapon-config Fired events can be observed away from the projectile owner.
// The actual local operator captures the UI state synchronously and sends one
// immutable cue to the machine that owns missile simulation.
private _shotParents = getShotParents _missile;
private _instigator = _shotParents param [1, objNull];
private _isLocalOperator = false;
if (hasInterface && {!isNull player}) then {
    // A pylon Fired event can report the vehicle's AI gunner even when the
    // rack is assigned to, selected by and fired from the pilot seat. Locate
    // the local seat that actually owns this weapon instead of trusting the
    // event's _gunner field. This also covers locally controlled UAV turrets.
    private _operatorCandidates = [player, focusOn, remoteControlled player];
    {
        private _candidate = _x;
        if (!isNull _candidate && {vehicle _candidate isEqualTo _launcher}) then {
            private _turretPath = _launcher unitTurret _candidate;
            private _seatWeapons = _launcher weaponsTurret _turretPath;
            if (
                _candidate isEqualTo _instigator ||
                {_weapon in _seatWeapons}
            ) exitWith {
                _isLocalOperator = true;
            };
        };
    } forEach _operatorCandidates;

    // Preserve manual-fire compatibility for carriers whose virtual weapon
    // is not exposed by weaponsTurret, but only when the player controls this
    // exact launcher. An unrelated AI crew target can no longer qualify.
    if (
        !_isLocalOperator
        && {vehicle player isEqualTo _launcher}
        && {isManualFire _launcher}
    ) then {
        _isLocalOperator = true;
    };

    // A UAV pilot can see the same pylon event, but only the player actively
    // controlling the UAV gunner owns the targeting-camera launch snapshot.
    if (
        _isLocalOperator
        && {unitIsUAV _launcher}
        && {!(player in (UAVControl [_launcher, "gunner"]))}
    ) then {
        _isLocalOperator = false;
    };
};
if (_isLocalOperator) then {
    private _uiCue = [
        _launcher,
        _weapon,
        _missile,
        _instigator,
        true
    ] call fdelta_fnc_scalpelLCaptureCue;
    [_missile, _uiCue, player] call fdelta_fnc_scalpelLReceiveCue;
};

if (localNamespace getVariable ["fdelta_scalpelL_debug", false]) then {
    diag_log format
    [
        "fdelta_scalpelL_FIRED|launcher=%1|eventGunner=%2|shotParents=%3|"
            + "instigator=%4|localOperator=%5|engineTarget=%6|manualFire=%7",
        _launcher,
        _gunner,
        _shotParents,
        _instigator,
        _isLocalOperator,
        missileTarget _missile,
        isManualFire _launcher
    ];
};

// Every authoritative owner has an AI/engine fallback even if a separate
// gunner client needs a fraction of a second to deliver the richer UI cue.
if (local _missile) then {
    private _fallbackCue = [
        _launcher,
        _weapon,
        _missile,
        _instigator,
        false
    ] call fdelta_fnc_scalpelLCaptureCue;
    [_missile, _fallbackCue] call fdelta_fnc_scalpelLReceiveCue;

    // Objects cannot be direct HashMap keys. Resolve the collision bucket by
    // object identity and keep the controller gates owner-local.
    private _registry = localNamespace getVariable
        ["fdelta_scalpelL_ownerRegistry", createHashMap];
    if !(_registry isEqualType createHashMap) then {
        _registry = createHashMap;
    };

    // Guidance removes its own entry on every normal exit. Sweep abandoned
    // entries opportunistically at launch instead of running a second
    // scheduled cleanup loop for every missile throughout its flight.
    private _now = diag_tickTime;
    private _nextSweep = localNamespace getVariable
        ["fdelta_scalpelL_nextRegistrySweep", 0];
    if !(_nextSweep isEqualType 0) then {_nextSweep = 0;};
    if (_now >= _nextSweep) then {
        localNamespace setVariable
            ["fdelta_scalpelL_nextRegistrySweep", _now + 15];
        private _registryUpdates = [];
        private _emptyHashes = [];
        {
            private _liveEntries = if (_y isEqualType []) then {
                _y select {
                    _x isEqualType []
                    && {(count _x) >= 5}
                    && {(_x # 0) isEqualType objNull}
                    && {!isNull (_x # 0)}
                    && {local (_x # 0)}
                }
            }
            else {
                []
            };
            if (_liveEntries isEqualTo []) then {
                _emptyHashes pushBack _x;
            }
            else {
                if (_liveEntries isNotEqualTo _y) then {
                    _registryUpdates pushBack [_x, _liveEntries];
                };
            };
        } forEach _registry;
        {_registry set _x;} forEach _registryUpdates;
        {_registry deleteAt _x;} forEach _emptyHashes;
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
        private _serial = localNamespace getVariable
            ["fdelta_scalpelL_registrySerial", 0];
        if !(_serial isEqualType 0) then {_serial = 0;};
        _serial = _serial + 1;
        if (!(finite _serial) || {_serial > 1000000000}) then {_serial = 1;};
        localNamespace setVariable ["fdelta_scalpelL_registrySerial", _serial];
        _bucket pushBack [_missile, [], false, false, _serial];
        _entryIndex = (count _bucket) - 1;
    };
    _registry set [_missileHash, _bucket];

    private _entry = _bucket # _entryIndex;
    private _controllerStarted = _entry param [2, false];
    if !(_controllerStarted isEqualType true) then {_controllerStarted = false;};
    if (!_controllerStarted) then {
        _entry set [2, true];
        [_missile] spawn fdelta_fnc_scalpelLGuideMissile;
    };
    _bucket set [_entryIndex, _entry];
    _registry set [_missileHash, _bucket];
    localNamespace setVariable ["fdelta_scalpelL_ownerRegistry", _registry];
};
