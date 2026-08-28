/*
    Author: zobri

    Description:
        Caches exact blast profiles and installs one locality-aware projectile
        listener. The projectile owner performs all work; no scripted network
        messages or server workers are used.
*/
if (isRemoteExecuted) exitWith {};

if (isNil "fdelta_blast_enabled") then {fdelta_blast_enabled = true;};
if (isNil "fdelta_blast_damageMultiplier") then {
    fdelta_blast_damageMultiplier = 1;
};
if (isNil "fdelta_blast_maxTargets") then {fdelta_blast_maxTargets = 128;};
if (isNil "fdelta_blast_debug") then {fdelta_blast_debug = false;};

private _profiles = createHashMap;
{
    private _outerRanges = getArray (_x >> "outerRanges");
    private _outerDoses = getArray (_x >> "outerDoses");
    private _innerRanges = getArray (_x >> "innerRanges");
    private _innerDoses = getArray (_x >> "innerDoses");
    private _virtualLift = getNumber (_x >> "virtualLift");

    if (
        count _outerRanges >= 2
        && {count _outerRanges isEqualTo count _outerDoses}
        && {count _innerRanges >= 2}
        && {count _innerRanges isEqualTo count _innerDoses}
    ) then {
        _profiles set [
            configName _x,
            [
                _outerRanges,
                _outerDoses,
                _innerRanges,
                _innerDoses,
                _virtualLift
            ]
        ];
    };
} forEach configProperties [
    configFile >> "CfgFdeltaBlastProfiles",
    "isClass _x",
    true
];
localNamespace setVariable ["fdelta_blast_profiles", _profiles];

private _projectileEH = localNamespace getVariable [
    "fdelta_blast_projectileEH",
    -1
];
if (_projectileEH < 0) then {
    _projectileEH = addMissionEventHandler ["ProjectileCreated", {
        params ["_projectile"];
        if (isNull _projectile) exitWith {};

        // Pre-init populated this map before installing the listener. Avoid an
        // allocating default expression on the ordinary projectile hot path.
        private _profiles = localNamespace getVariable
            "fdelta_blast_profiles";
        private _profile = _profiles getOrDefault [typeOf _projectile, []];
        if (_profile isEqualTo []) exitWith {};

        // ProjectileCreated is seen for network proxies as well. Explode is
        // local, so every modded machine may install this small handler while
        // only the detonation owner performs the calculation.
        _projectile addEventHandler ["Explode", {
            params ["_projectile", "_positionASL", "_velocity"];
            if (isNull _projectile || {!local _projectile}) exitWith {};

            private _ammo = typeOf _projectile;
            private _profiles = localNamespace getVariable
                "fdelta_blast_profiles";
            private _profile = _profiles getOrDefault [_ammo, []];
            if (_profile isEqualTo []) exitWith {};

            // Capture everything before Explode returns and the projectile is
            // deleted. The spawned calculation deliberately runs later so the
            // engine's native indirect damage settles first.
            private _parents = getShotParents _projectile;
            [
                _ammo,
                +_positionASL,
                +_velocity,
                _profile,
                _parents param [0, objNull, [objNull]],
                _parents param [1, objNull, [objNull]]
            ] spawn fdelta_fnc_blastProcessBlast;
        }];
    }];
    localNamespace setVariable ["fdelta_blast_projectileEH", _projectileEH];
};

diag_log format [
    "FDELTA_BLAST_INIT|local owner processing enabled|profiles=%1",
    count _profiles
];
