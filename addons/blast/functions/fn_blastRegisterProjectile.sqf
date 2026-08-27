/*
    Author: zobri

    Description:
        Installs the local explosion reporter and submits the networked
        projectile object to the server for independent observation.

    Parameters:
        0: Local projectile <OBJECT>

    Returns:
        Event-handler index, or -1 when the projectile is not eligible <NUMBER>
*/
if (isRemoteExecuted) exitWith {-1};

params [["_projectile", objNull, [objNull]]];

if (isNull _projectile || {!local _projectile}) exitWith {-1};

private _ammo = typeOf _projectile;
if (([_ammo] call fdelta_fnc_blastProfile) isEqualTo []) exitWith {-1};

_projectile setVariable ["fdelta_blast_ammo", _ammo];
private _eventHandler = _projectile addEventHandler ["Explode", {
    params ["_projectile", "_positionASL", "_velocity"];

    private _key = _projectile getVariable ["fdelta_blast_registryKey", netId _projectile];
    if (_key isEqualTo "" || {_key isEqualTo "0:0"}) exitWith {};

    private _payload = [_key, _positionASL, _velocity];
    if (isServer) then {
        _payload call fdelta_fnc_blastReceiveBlast;
    } else {
        _payload remoteExecCall ["fdelta_fnc_blastReceiveBlast", 2];
    };
}];

private _key = netId _projectile;
if !(_key isEqualTo "" || {_key isEqualTo "0:0"}) then {
    _projectile setVariable ["fdelta_blast_registryKey", _key];
    if (isServer) then {
        [_projectile] call fdelta_fnc_blastRegisterProjectileEvidence;
    } else {
        [_projectile] remoteExecCall ["fdelta_fnc_blastRegisterProjectileEvidence", 2];
    };
} else {
    // ProjectileCreated can precede assignment of a network ID by one frame.
    [_projectile] spawn {
        params ["_projectile"];
        private _deadline = diag_tickTime + 0.5;
        private _key = "";

        waitUntil {
            uiSleep 0.01;
            if (!isNull _projectile) then {_key = netId _projectile};
            isNull _projectile
            || {!(_key isEqualTo "" || {_key isEqualTo "0:0"})}
            || {diag_tickTime >= _deadline}
        };

        if (isNull _projectile || {_key isEqualTo ""} || {_key isEqualTo "0:0"}) exitWith {};
        _projectile setVariable ["fdelta_blast_registryKey", _key];
        if (isServer) then {
            [_projectile] call fdelta_fnc_blastRegisterProjectileEvidence;
        } else {
            [_projectile] remoteExecCall ["fdelta_fnc_blastRegisterProjectileEvidence", 2];
        };
    };
};

_eventHandler
