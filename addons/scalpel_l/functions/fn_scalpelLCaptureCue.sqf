/*
    Author: zobri

    Captures the best immutable launch cue available from player UI, engine
    target state, AI target state, or the launcher's forward axis.
*/
if (isRemoteExecuted) exitWith {[]};

params [
    "_launcher",
    "_weapon",
    "_missile",
    ["_gunner", objNull],
    ["_capturePlayerUI", false]
];

private _selectedTarget = objNull;
private _lockValue = 0;
private _aimpointATL = [];
private _priority = 20;
private _source = "launcher-axis";

if (_capturePlayerUI && {hasInterface}) then {
    private _lockInfo = playerTargetLock;
    _lockInfo params
    [
        ["_uiTarget", objNull],
        ["_uiLockValue", 0],
        ["_uiWeaponConfig", configNull]
    ];

    // playerTargetLock can expose a selected target at zero lock progress.
    // Reject stale lock state belonging to some other selected weapon.
    private _lockBelongsToWeapon =
        !isNull _uiTarget &&
        {!isNull _uiWeaponConfig} &&
        {configName _uiWeaponConfig isEqualTo _weapon};

    if (_lockBelongsToWeapon) then {
        _selectedTarget = _uiTarget;
        _lockValue = _uiLockValue;
        _aimpointATL = [_selectedTarget] call fdelta_fnc_scalpelLTargetPointATL;
        // Player UI state is authoritative. In particular, an engine target
        // may already exist for a merely selected object, so even a zero-
        // progress UI lock must outrank the owner's generic engine fallback.
        _priority = 250 + ([0, 40] select (_lockValue >= 0.999));
        _source = ["selected-snapshot", "player-hard-lock"] select (_lockValue >= 0.999);
    }
    else {
        _aimpointATL = [
            _launcher,
            _weapon,
            _missile,
            player,
            true
        ] call fdelta_fnc_scalpelLTraceAimpoint;
        _priority = 220;
        _source = "camera-los";
    };
};

if (_aimpointATL isEqualTo []) then {
    private _engineTarget = missileTarget _missile;
    if (!isNull _engineTarget) then {
        _selectedTarget = _engineTarget;
        _lockValue = 1;
        _aimpointATL = [_engineTarget] call fdelta_fnc_scalpelLTargetPointATL;
        _priority = 200;
        _source = "engine-hard-lock";
    }
    else {
        private _aiTarget = if (isNull _gunner) then {objNull} else {getAttackTarget _gunner};
        if (!isNull _aiTarget) then {
            _selectedTarget = _aiTarget;
            _aimpointATL = [_aiTarget] call fdelta_fnc_scalpelLTargetPointATL;
            _priority = 60;
            _source = "ai-target-snapshot";
        }
        else {
            _aimpointATL = [
                _launcher,
                _weapon,
                _missile,
                _gunner,
                false
            ] call fdelta_fnc_scalpelLTraceAimpoint;
        };
    };
};

[
    _priority,
    _aimpointATL,
    _selectedTarget,
    _lockValue,
    _source,
    diag_tickTime
]
