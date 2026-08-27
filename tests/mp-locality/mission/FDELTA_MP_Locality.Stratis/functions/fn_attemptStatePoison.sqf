/*
    Attempts the pre-hardening Blast registry and settings overwrite from a
    real graphical client. A secure server ignores both published values.
*/
if (isServer) exitWith {false};

params [
    ["_case", "", [""]],
    ["_key", "", [""]],
    ["_originASL", [], [[]]]
];
if (_case isEqualTo "" || {_key isEqualTo ""} || {count _originASL != 3}) exitWith {
    false
};

[_case, _key, _originASL] spawn {
    params ["_case", "_key", "_originASL"];

    private _future = 1e12;
    private _entry = createHashMapFromArray [
        ["projectile", objNull],
        ["owner", clientOwner],
        ["ammo", "Bo_Mk82"],
        ["registeredAt", _future],
        ["lastSeenAt", _future],
        ["lastPositionASL", _originASL],
        ["lastVelocity", [0, 0, 0]],
        ["observations", 1],
        ["vehicle", objNull],
        ["instigator", objNull],
        ["pending", false],
        ["blastId", _key]
    ];
    missionNamespace setVariable [
        "fdelta_blast_projectileRegistry",
        createHashMapFromArray [[_key, _entry]]
    ];
    publicVariableServer "fdelta_blast_projectileRegistry";

    missionNamespace setVariable ["fdelta_blast_damageMultiplier", 100];
    publicVariableServer "fdelta_blast_damageMultiplier";

    uiSleep 0.1;
    [_key, _originASL, [0, 0, 0]] remoteExecCall [
        "fdelta_fnc_blastReceiveBlast",
        2
    ];
    [_case, "POISON_SENT", [clientOwner]] remoteExecCall [
        "fdelta_test_fnc_receivePhase",
        2
    ];
};

true
