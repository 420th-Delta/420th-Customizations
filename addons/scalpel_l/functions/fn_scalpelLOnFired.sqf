/*
    Author: zobri

    Handles a Scalpel-L Fired event, captures the firing operator's immutable
    launch cue, and starts guidance only where the projectile is local.
*/
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
    if (!_isLocalOperator && {vehicle player isEqualTo _launcher} && {isManualFire _launcher}) then {
        _isLocalOperator = true;
    };
};
if (_isLocalOperator) then {
    private _uiCue = [_launcher, _weapon, _missile, _instigator, true] call fdelta_fnc_scalpelLCaptureCue;
    [_missile, _uiCue, player] call fdelta_fnc_scalpelLReceiveCue;
};

if (missionNamespace getVariable ["fdelta_scalpelL_debug", false]) then {
    diag_log format
    [
        "fdelta_scalpelL_FIRED|launcher=%1|eventGunner=%2|shotParents=%3|instigator=%4|localOperator=%5|engineTarget=%6|manualFire=%7",
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
    private _fallbackCue = [_launcher, _weapon, _missile, _instigator, false] call fdelta_fnc_scalpelLCaptureCue;
    [_missile, _fallbackCue] call fdelta_fnc_scalpelLReceiveCue;
    if !(_missile getVariable ["fdelta_scalpelL_controllerStarted", false]) then {
        _missile setVariable ["fdelta_scalpelL_controllerStarted", true];
        [_missile] spawn fdelta_fnc_scalpelLGuideMissile;
    };
};
