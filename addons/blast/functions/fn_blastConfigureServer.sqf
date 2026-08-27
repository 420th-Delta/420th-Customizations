/*
    Author: zobri

    Description:
        Validates and applies server-local Blast Propagation settings. The
        resulting HashMap is held in localNamespace, so a client cannot replace
        trusted tuning with publicVariable or a public setVariable call.

        Mission authors may call this function from server-local code after
        preInit. Pass a HashMap or an array of [name, value] pairs using these
        established names:

        fdelta_blast_enabled, fdelta_blast_damageMultiplier,
        fdelta_blast_halfLife, fdelta_blast_cumulativeGain,
        fdelta_blast_debug, fdelta_blast_maxTargets,
        fdelta_blast_maxDamageQueue,
        fdelta_blast_maxEvidenceAge, fdelta_blast_maxRegistry,
        fdelta_blast_maxRegistryPerOwner, fdelta_blast_rateShortCount,
        fdelta_blast_rateLongCount, fdelta_blast_ingressCapacity,
        fdelta_blast_ingressRefill, fdelta_blast_globalIngressCapacity,
        fdelta_blast_globalIngressRefill,
        fdelta_blast_maxConcurrentValidations.

        Direct assignments to missionNamespace variables after preInit are
        deliberately non-authoritative; call this function to apply changes.

    Parameters:
        0: Settings HashMap or [name, value] pairs <HASHMAP or ARRAY>

    Returns:
        A detached copy of the complete validated settings <HASHMAP>
*/
if (!isServer || {isRemoteExecuted}) exitWith {createHashMap};

private _updates = _this param [0, createHashMap];
private _input = createHashMap;
private _hashMapType = createHashMap;

if (_updates isEqualType _hashMapType) then {
    _input = +_updates;
} else {
    if (_updates isEqualType []) then {
        {
            if (
                _x isEqualType []
                && {count _x isEqualTo 2}
                && {(_x select 0) isEqualType ""}
            ) then {
                _input set [_x select 0, _x select 1];
            };
        } forEach _updates;
    };
};

private _settings = localNamespace getVariable [
    "fdelta_blast_settings",
    createHashMap
];

private _applyBoolean = {
    params ["_name", "_default", "_input", "_settings"];

    private _current = _settings getOrDefault [_name, _default];
    if !(_current isEqualType true) then {_current = _default};

    private _candidate = _input getOrDefault [_name, _current];
    private _value = [_current, _candidate] select (_candidate isEqualType true);
    _settings set [_name, _value];
};

private _applyNumber = {
    params [
        "_name",
        "_default",
        "_minimum",
        "_maximum",
        "_integer",
        "_input",
        "_settings"
    ];

    private _current = _settings getOrDefault [_name, _default];
    if !(_current isEqualType 0 && {finite _current}) then {
        _current = _default;
    };

    private _candidate = _input getOrDefault [_name, _current];
    private _value = _current;
    if (_candidate isEqualType 0 && {finite _candidate}) then {
        _value = (_candidate max _minimum) min _maximum;
        if (_integer) then {_value = floor _value};
    };
    _settings set [_name, _value];
};

[
    "fdelta_blast_enabled",
    true,
    _input,
    _settings
] call _applyBoolean;
[
    "fdelta_blast_debug",
    false,
    _input,
    _settings
] call _applyBoolean;

[
    "fdelta_blast_damageMultiplier",
    1,
    0,
    10,
    false,
    _input,
    _settings
] call _applyNumber;
[
    "fdelta_blast_halfLife",
    1800,
    1,
    86400,
    false,
    _input,
    _settings
] call _applyNumber;
[
    "fdelta_blast_cumulativeGain",
    0.5,
    0,
    10,
    false,
    _input,
    _settings
] call _applyNumber;
[
    "fdelta_blast_maxTargets",
    256,
    1,
    2048,
    true,
    _input,
    _settings
] call _applyNumber;
[
    "fdelta_blast_maxDamageQueue",
    128,
    1,
    512,
    true,
    _input,
    _settings
] call _applyNumber;
[
    "fdelta_blast_maxEvidenceAge",
    300,
    3,
    3600,
    false,
    _input,
    _settings
] call _applyNumber;
[
    "fdelta_blast_maxRegistry",
    512,
    32,
    4096,
    true,
    _input,
    _settings
] call _applyNumber;
[
    "fdelta_blast_maxRegistryPerOwner",
    128,
    1,
    4096,
    true,
    _input,
    _settings
] call _applyNumber;
[
    "fdelta_blast_rateShortCount",
    64,
    1,
    4096,
    true,
    _input,
    _settings
] call _applyNumber;
[
    "fdelta_blast_rateLongCount",
    192,
    1,
    16384,
    true,
    _input,
    _settings
] call _applyNumber;
[
    "fdelta_blast_ingressCapacity",
    256,
    1,
    4096,
    true,
    _input,
    _settings
] call _applyNumber;
[
    "fdelta_blast_ingressRefill",
    64,
    0,
    4096,
    false,
    _input,
    _settings
] call _applyNumber;
[
    "fdelta_blast_globalIngressCapacity",
    1024,
    1,
    16384,
    true,
    _input,
    _settings
] call _applyNumber;
[
    "fdelta_blast_globalIngressRefill",
    256,
    0,
    16384,
    false,
    _input,
    _settings
] call _applyNumber;
[
    "fdelta_blast_maxConcurrentValidations",
    32,
    1,
    128,
    true,
    _input,
    _settings
] call _applyNumber;

private _maxRegistry = _settings get "fdelta_blast_maxRegistry";
private _maxPerOwner = _settings get "fdelta_blast_maxRegistryPerOwner";
_settings set [
    "fdelta_blast_maxRegistryPerOwner",
    _maxPerOwner min _maxRegistry
];

private _shortCount = _settings get "fdelta_blast_rateShortCount";
private _longCount = _settings get "fdelta_blast_rateLongCount";
_settings set ["fdelta_blast_rateLongCount", _longCount max _shortCount];

private _ownerCapacity = _settings get "fdelta_blast_ingressCapacity";
private _globalCapacity = _settings get "fdelta_blast_globalIngressCapacity";
_settings set [
    "fdelta_blast_globalIngressCapacity",
    _globalCapacity max _ownerCapacity
];

localNamespace setVariable ["fdelta_blast_settings", _settings];
+_settings
