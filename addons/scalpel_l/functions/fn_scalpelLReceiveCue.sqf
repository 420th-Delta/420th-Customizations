/*
    Author: zobri

    Validates and stores an immutable launch cue on the projectile owner,
    including strict remote-caller ownership and launcher-association checks.
*/
params ["_missile", "_cue", ["_sourceUnit", objNull], ["_rerouted", false]];

if !(_missile isEqualType objNull) exitWith {false};
if !(_cue isEqualType []) exitWith {false};
if !(_sourceUnit isEqualType objNull) exitWith {false};
if !(_rerouted isEqualType true) exitWith {false};
if (isNull _missile || {typeOf _missile isNotEqualTo "fdelta_M_Scalpel_L"}) exitWith {false};
if ((count _cue) isNotEqualTo 6) exitWith {false};

_cue params ["_priority", "_aimpointATL", "_selectedTarget", "_lockValue", "_source", "_capturedAt"];
if !(_priority isEqualType 0) exitWith {false};
if !(_aimpointATL isEqualType []) exitWith {false};
if !(_selectedTarget isEqualType objNull) exitWith {false};
if !(_lockValue isEqualType 0) exitWith {false};
if !(_source isEqualType "") exitWith {false};
if !(_capturedAt isEqualType 0) exitWith {false};
if !((finite _priority) && {finite _lockValue} && {finite _capturedAt}) exitWith {false};
if (_lockValue < 0 || {_lockValue > 1}) exitWith {false};
if (
    (count _aimpointATL) isNotEqualTo 3 ||
    {
        (_aimpointATL findIf {
            !(_x isEqualType 0) ||
            {!(finite _x)} ||
            {abs _x > 1000000}
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

// Store only canonical priorities, never caller-supplied ranking values.
_cue set [0, _expectedPriority];

if (!local _missile) exitWith {
    if (!_rerouted) then {
        [_missile, _cue, _sourceUnit, true] remoteExecCall
            ["fdelta_fnc_scalpelLReceiveCue", owner _missile];
    };
    false
};

// A remotely supplied UI snapshot is accepted only from the player who owns
// the supplied source unit and is actually associated with the launcher.
private _remoteCueValid = true;
if (isRemoteExecuted) then {
    _remoteCueValid = _source in ["camera-los", "selected-snapshot", "player-hard-lock"] &&
        {!isNull _sourceUnit} &&
        {(owner _sourceUnit) isEqualTo remoteExecutedOwner};

    if (_remoteCueValid) then {
        private _parents = getShotParents _missile;
        private _launcher = _parents param [0, objNull];
        private _instigator = _parents param [1, objNull];
        private _uavOperators = if (!isNull _launcher && {unitIsUAV _launcher}) then {
            UAVControl [_launcher, "crew"]
        }
        else {
            []
        };
        _remoteCueValid =
            (_sourceUnit isEqualTo _instigator) ||
            {_sourceUnit in _uavOperators};
    };
};
if (!_remoteCueValid) exitWith {false};

private _existing = _missile getVariable ["fdelta_scalpelL_launchCue", []];
if (_existing isEqualTo [] || {(_cue # 0) > (_existing # 0)}) then {
    // The immutable snapshot is needed only by the projectile owner. Keeping
    // it local avoids broadcasting exact targeting data to every client.
    _missile setVariable ["fdelta_scalpelL_launchCue", _cue];
};

true
