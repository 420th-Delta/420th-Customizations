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

if (isNull _projectile) exitWith {-1};

private _ammo = typeOf _projectile;
if (([_ammo] call (localNamespace getVariable [
    "fdelta_blast_resolveProfile",
    {[]}
])) isEqualTo []) exitWith {-1};

// Event-handler state is owner-local. Never trust a networked object variable
// to decide whether a reporter exists or which registry key should be sent.
private _reporters = localNamespace getVariable [
    "fdelta_blast_localReporters",
    createHashMap
];
private _objectHash = hashValue _projectile;
private _bucket = _reporters getOrDefault [_objectHash, []];
private _reporterIndex = _bucket findIf {
    (_x param [0, objNull, [objNull]]) isEqualTo _projectile
};
private _eventHandler = -1;

if (_reporterIndex >= 0) then {
    _eventHandler = (_bucket select _reporterIndex) param [1, -1, [0]];
} else {
    _eventHandler = _projectile addEventHandler ["Explode", {
        params ["_projectile", "_positionASL", "_velocity"];

        // netId is derived from the projectile at report time. A public
        // setVariable on the object therefore cannot redirect the registry key.
        private _key = netId _projectile;
        if (_key isEqualTo "" || {_key isEqualTo "0:0"}) exitWith {};

        private _payload = [_key, _positionASL, _velocity];
        if (isServer) then {
            [_projectile] call fdelta_fnc_blastRegisterProjectileEvidence;
            _payload call fdelta_fnc_blastReceiveBlast;
        } else {
            [_projectile] remoteExecCall [
                "fdelta_fnc_blastRegisterProjectileEvidence",
                2
            ];
            _payload remoteExecCall ["fdelta_fnc_blastReceiveBlast", 2];
        };
    }];

    _projectile addEventHandler ["Deleted", {
        params ["_projectile"];
        private _reporters = localNamespace getVariable [
            "fdelta_blast_localReporters",
            createHashMap
        ];
        private _objectHash = hashValue _projectile;
        private _bucket = _reporters getOrDefault [_objectHash, []];
        private _index = _bucket findIf {
            (_x param [0, objNull, [objNull]]) isEqualTo _projectile
        };
        if (_index >= 0) then {
            _bucket deleteAt _index;
            if (_bucket isEqualTo []) then {
                _reporters deleteAt _objectHash;
            } else {
                _reporters set [_objectHash, _bucket];
            };
        };
        localNamespace setVariable ["fdelta_blast_localReporters", _reporters];
    }];

    _bucket pushBack [_projectile, _eventHandler];
    _reporters set [_objectHash, _bucket];
    localNamespace setVariable ["fdelta_blast_localReporters", _reporters];
};

// Remote proxies need only the local-only reporter above. The current owner
// submits evidence; the server also observes owner changes in its registry
// monitor so a stale reservation cannot survive a transfer.
if (!local _projectile) exitWith {_eventHandler};

private _key = netId _projectile;
private _registered = false;
if !(_key isEqualTo "" || {_key isEqualTo "0:0"}) then {
    if (isServer) then {
        _registered = [_projectile]
            call fdelta_fnc_blastRegisterProjectileEvidence;
    } else {
        [_projectile] remoteExecCall ["fdelta_fnc_blastRegisterProjectileEvidence", 2];
    };
};

if (!_registered) then {
    // ProjectileCreated can precede assignment of a network ID, and after a
    // Local EH the server can briefly retain the old owner. Retry on a short,
    // bounded schedule while this machine remains authoritative. Same-owner
    // registration is idempotent on the server.
    [_projectile] spawn {
        params ["_projectile"];
        scopeName "fdelta_blast_evidenceRetry";
        {
            uiSleep _x;
            if (
                isNull _projectile
                || {!alive _projectile}
                || {!local _projectile}
            ) then {
                breakOut "fdelta_blast_evidenceRetry";
            };

            private _retryKey = netId _projectile;
            if !(_retryKey isEqualTo "" || {_retryKey isEqualTo "0:0"}) then {
                if (isServer) then {
                    if (
                        [_projectile]
                            call fdelta_fnc_blastRegisterProjectileEvidence
                    ) then {
                        breakOut "fdelta_blast_evidenceRetry";
                    };
                } else {
                    [_projectile] remoteExecCall [
                        "fdelta_fnc_blastRegisterProjectileEvidence",
                        2
                    ];
                };
            };
        } forEach [0.05, 0.15, 0.35, 0.75];
    };
};

_eventHandler
