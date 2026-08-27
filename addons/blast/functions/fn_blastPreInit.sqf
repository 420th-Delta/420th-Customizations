/*
    Author: zobri

    Description:
        Initializes projectile observation and server-authoritative blast state.

    Returns:
        Nothing
*/
if (isRemoteExecuted) exitWith {};

if (isNil "fdelta_blast_enabled") then {fdelta_blast_enabled = true};
if (isNil "fdelta_blast_damageMultiplier") then {fdelta_blast_damageMultiplier = 1};
if (isNil "fdelta_blast_halfLife") then {fdelta_blast_halfLife = 1800};
if (isNil "fdelta_blast_cumulativeGain") then {fdelta_blast_cumulativeGain = 0.5};
if (isNil "fdelta_blast_debug") then {fdelta_blast_debug = false};
if (isNil "fdelta_blast_maxTargets") then {fdelta_blast_maxTargets = 256};
if (isNil "fdelta_blast_maxEvidenceAge") then {fdelta_blast_maxEvidenceAge = 300};
if (isNil "fdelta_blast_maxRegistry") then {fdelta_blast_maxRegistry = 512};
if (isNil "fdelta_blast_maxRegistryPerOwner") then {
    fdelta_blast_maxRegistryPerOwner = 128;
};
if (isNil "fdelta_blast_rateShortCount") then {fdelta_blast_rateShortCount = 64};
if (isNil "fdelta_blast_rateLongCount") then {fdelta_blast_rateLongCount = 192};

if (isServer) then {
    fdelta_blast_projectileRegistry = createHashMap;
    fdelta_blast_seen = createHashMap;
    fdelta_blast_ownerRates = createHashMap;
    fdelta_blast_queue = [];
    fdelta_blast_workerRunning = false;
    [] spawn fdelta_fnc_blastMonitorRegistry;
};

if (isNil "fdelta_blast_projectileEH") then {
    fdelta_blast_projectileEH = addMissionEventHandler ["ProjectileCreated", {
        params ["_projectile"];
        if (!isNull _projectile && {local _projectile}) then {
            [_projectile] call fdelta_fnc_blastRegisterProjectile;
        };
    }];
};

diag_log "FDELTA_BLAST_INIT|Blast Propagation initialized";
