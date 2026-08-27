/*
    Author: zobri

    Bounds owner-local cue state when guidance never starts, aborts on an
    unexpected script error, or loses projectile locality before cleanup.
*/
if (isRemoteExecuted) exitWith {};

params ["_missile", "_missileHash", "_registryToken"];

if !(_missile isEqualType objNull) exitWith {};
if !(_missileHash isEqualType 0) exitWith {};
if !(_registryToken isEqualType 0) exitWith {};

private _timeToLive = if (isNull _missile) then {
    180
}
else {
    getNumber (configOf _missile >> "timeToLive")
};
if (!(finite _timeToLive) || {_timeToLive <= 0}) then {_timeToLive = 180;};
private _createdAt = diag_tickTime;
private _hardDeadline = _createdAt + (((_timeToLive max 30) min 900) + 30);

private _finished = false;
while {!_finished} do {
    uiSleep 1;

    private _registry = localNamespace getVariable [
        "fdelta_scalpelL_ownerRegistry",
        0
    ];
    if !(_registry isEqualType createHashMap) exitWith {};

    private _bucket = _registry getOrDefault [_missileHash, []];
    if !(_bucket isEqualType []) exitWith {};
    private _entryIndex = _bucket findIf {
        _x isEqualType []
        && {(count _x) >= 5}
        && {(_x # 4) isEqualType 0}
        && {(_x # 4) isEqualTo _registryToken}
    };
    if (_entryIndex < 0) exitWith {};

    private _entry = _bucket # _entryIndex;
    private _started = _entry param [2, false];
    if !(_started isEqualType true) then {_started = false;};
    private _stale = isNull _missile
        || {!local _missile}
        || {diag_tickTime >= _hardDeadline}
        || {!_started && {diag_tickTime - _createdAt >= 2}};

    if (_stale) then {
        _bucket deleteAt _entryIndex;
        if (_bucket isEqualTo []) then {
            _registry deleteAt _missileHash;
        }
        else {
            _registry set [_missileHash, _bucket];
        };
        _finished = true;
    };
};
