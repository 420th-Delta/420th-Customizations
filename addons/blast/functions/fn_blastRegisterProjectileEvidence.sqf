/*
    Author: zobri

    Description:
        Records a server-observed projectile before accepting an explosion
        report. Remote callers cannot supply the ammunition, owner, parents,
        position, or registry key.

    Parameters:
        0: Networked projectile <OBJECT>

    Returns:
        Whether evidence was accepted <BOOL>
*/
if (!isServer) exitWith {false};

params [["_projectile", objNull, [objNull]]];
if (isNull _projectile) exitWith {false};

private _sourceOwner = if (isRemoteExecuted) then {remoteExecutedOwner} else {2};
if (isRemoteExecuted && {_sourceOwner <= 2}) exitWith {false};

private _observedOwner = owner _projectile;
if (_observedOwner isNotEqualTo _sourceOwner) exitWith {false};

private _ammo = typeOf _projectile;
if (([_ammo] call fdelta_fnc_blastProfile) isEqualTo []) exitWith {false};

private _key = netId _projectile;
if (_key isEqualTo "" || {_key isEqualTo "0:0"} || {count _key > 80}) exitWith {false};

private _positionASL = getPosASL _projectile;
private _validPosition = count _positionASL isEqualTo 3 && {
    (_positionASL findIf {!(_x isEqualType 0) || {!finite _x}}) < 0
};
if (!_validPosition) exitWith {false};

private _registry = missionNamespace getVariable [
    "fdelta_blast_projectileRegistry",
    createHashMap
];
private _seen = missionNamespace getVariable ["fdelta_blast_seen", createHashMap];
if ((_seen getOrDefault [_key, -1]) >= 0) exitWith {false};

private _existing = _registry getOrDefault [_key, createHashMap];
if (count _existing > 0) exitWith {
    (_existing getOrDefault ["projectile", objNull]) isEqualTo _projectile
    && {(_existing getOrDefault ["owner", -1]) isEqualTo _sourceOwner}
    && {(_existing getOrDefault ["ammo", ""]) isEqualTo _ammo}
};

private _maxRegistry = missionNamespace getVariable ["fdelta_blast_maxRegistry", 512];
if (count _registry >= _maxRegistry) exitWith {false};

private _ownerCount = count ((keys _registry) select {
    private _entry = _registry getOrDefault [_x, createHashMap];
    (_entry getOrDefault ["owner", -1]) isEqualTo _sourceOwner
});
private _maxPerOwner = missionNamespace getVariable [
    "fdelta_blast_maxRegistryPerOwner",
    128
];
if (_sourceOwner > 2 && {_ownerCount >= _maxPerOwner}) exitWith {false};

private _now = diag_tickTime;
private _parents = getShotParents _projectile;
private _entry = createHashMapFromArray [
    ["projectile", _projectile],
    ["owner", _sourceOwner],
    ["ammo", _ammo],
    ["registeredAt", _now],
    ["lastSeenAt", _now],
    ["lastPositionASL", _positionASL],
    ["lastVelocity", velocity _projectile],
    ["observations", 1],
    ["vehicle", _parents param [0, objNull, [objNull]]],
    ["instigator", _parents param [1, objNull, [objNull]]],
    ["pending", false],
    ["blastId", format ["%1@%2", _key, round (_now * 1000)]]
];

_registry set [_key, _entry];
missionNamespace setVariable ["fdelta_blast_projectileRegistry", _registry];
true
