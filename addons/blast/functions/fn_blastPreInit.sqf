/*
    Author: zobri

    Description:
        Initializes projectile observation and server-authoritative blast state.

    Returns:
        Nothing
*/
if (isRemoteExecuted) exitWith {};

// These established missionNamespace variables remain compatibility hints for
// preInit-time defaults only. The server snapshots them once through the
// validated configuration API; trusted runtime code never reads them again.
if (isNil "fdelta_blast_enabled") then {fdelta_blast_enabled = true};
if (isNil "fdelta_blast_damageMultiplier") then {
    fdelta_blast_damageMultiplier = 1;
};
if (isNil "fdelta_blast_halfLife") then {fdelta_blast_halfLife = 1800};
if (isNil "fdelta_blast_cumulativeGain") then {
    fdelta_blast_cumulativeGain = 0.5;
};
if (isNil "fdelta_blast_debug") then {fdelta_blast_debug = false};
if (isNil "fdelta_blast_maxTargets") then {fdelta_blast_maxTargets = 256};
if (isNil "fdelta_blast_maxDamageQueue") then {
    fdelta_blast_maxDamageQueue = 128;
};
if (isNil "fdelta_blast_maxEvidenceAge") then {
    fdelta_blast_maxEvidenceAge = 300;
};
if (isNil "fdelta_blast_maxRegistry") then {fdelta_blast_maxRegistry = 512};
if (isNil "fdelta_blast_maxRegistryPerOwner") then {
    fdelta_blast_maxRegistryPerOwner = 128;
};
if (isNil "fdelta_blast_rateShortCount") then {
    fdelta_blast_rateShortCount = 64;
};
if (isNil "fdelta_blast_rateLongCount") then {
    fdelta_blast_rateLongCount = 192;
};
if (isNil "fdelta_blast_ingressCapacity") then {
    fdelta_blast_ingressCapacity = 256;
};
if (isNil "fdelta_blast_ingressRefill") then {
    fdelta_blast_ingressRefill = 64;
};
if (isNil "fdelta_blast_globalIngressCapacity") then {
    fdelta_blast_globalIngressCapacity = 1024;
};
if (isNil "fdelta_blast_globalIngressRefill") then {
    fdelta_blast_globalIngressRefill = 256;
};
if (isNil "fdelta_blast_maxConcurrentValidations") then {
    fdelta_blast_maxConcurrentValidations = 32;
};

// Profile resolution is internal on every machine. The public wrapper rejects
// remote execution, while these private localNamespace calls remain usable
// from authenticated ingress functions whose remote context is propagated.
if (isNil {localNamespace getVariable "fdelta_blast_resolveProfile"}) then {
    localNamespace setVariable [
        "fdelta_blast_resolveProfile",
        compile preprocessFileLineNumbers
            "\z\fdelta\addons\blast\functions\fn_blastResolveProfile.sqf"
    ];
};

if (isServer) then {

    // allUsers/getUserInfo is the reliable server-side HC identity source.
    // Keep the resolver private because an HC's hidden remote-execution
    // context must always be paired with server-owned projectile evidence.
    if (isNil {
        localNamespace getVariable "fdelta_blast_isHeadlessOwner"
    }) then {
        localNamespace setVariable [
            "fdelta_blast_isHeadlessOwner",
            compile preprocessFileLineNumbers
                "\z\fdelta\addons\blast\functions\fn_blastIsHeadlessOwner.sqf"
        ];
    };

    // Keep the ingress bucket helper outside missionNamespace so default-open
    // CfgRemoteExec policies cannot address it as a public function. Calls
    // made from ordinary clients retain their remote execution context. The
    // endpoints explicitly authenticate masked HC calls before permitting the
    // helper's owner-zero exception.
    if (isNil {
        localNamespace getVariable "fdelta_blast_consumeIngressToken"
    }) then {
        localNamespace setVariable [
            "fdelta_blast_consumeIngressToken",
            compile preprocessFileLineNumbers
                "\z\fdelta\addons\blast\functions\fn_blastConsumeIngressToken.sqf"
        ];
    };

    if (isNil {localNamespace getVariable "fdelta_blast_settings"}) then {
        private _legacyDefaults = createHashMapFromArray [
            ["fdelta_blast_enabled", fdelta_blast_enabled],
            ["fdelta_blast_damageMultiplier", fdelta_blast_damageMultiplier],
            ["fdelta_blast_halfLife", fdelta_blast_halfLife],
            ["fdelta_blast_cumulativeGain", fdelta_blast_cumulativeGain],
            ["fdelta_blast_debug", fdelta_blast_debug],
            ["fdelta_blast_maxTargets", fdelta_blast_maxTargets],
            ["fdelta_blast_maxDamageQueue", fdelta_blast_maxDamageQueue],
            ["fdelta_blast_maxEvidenceAge", fdelta_blast_maxEvidenceAge],
            ["fdelta_blast_maxRegistry", fdelta_blast_maxRegistry],
            [
                "fdelta_blast_maxRegistryPerOwner",
                fdelta_blast_maxRegistryPerOwner
            ],
            ["fdelta_blast_rateShortCount", fdelta_blast_rateShortCount],
            ["fdelta_blast_rateLongCount", fdelta_blast_rateLongCount],
            ["fdelta_blast_ingressCapacity", fdelta_blast_ingressCapacity],
            ["fdelta_blast_ingressRefill", fdelta_blast_ingressRefill],
            [
                "fdelta_blast_globalIngressCapacity",
                fdelta_blast_globalIngressCapacity
            ],
            [
                "fdelta_blast_globalIngressRefill",
                fdelta_blast_globalIngressRefill
            ],
            [
                "fdelta_blast_maxConcurrentValidations",
                fdelta_blast_maxConcurrentValidations
            ]
        ];
        [_legacyDefaults] call fdelta_fnc_blastConfigureServer;
    };

    {
        if (isNil {localNamespace getVariable _x}) then {
            localNamespace setVariable [_x, createHashMap];
        };
    } forEach [
        "fdelta_blast_projectileRegistry",
        "fdelta_blast_seen",
        "fdelta_blast_ownerRates",
        "fdelta_blast_ingressBuckets",
        "fdelta_blast_traumaRegistry"
    ];
    if (isNil {localNamespace getVariable "fdelta_blast_validationQueue"}) then {
        localNamespace setVariable ["fdelta_blast_validationQueue", []];
    };
    if (isNil {localNamespace getVariable "fdelta_blast_queue"}) then {
        localNamespace setVariable ["fdelta_blast_queue", []];
    };
    if (isNil {localNamespace getVariable "fdelta_blast_workerRunning"}) then {
        localNamespace setVariable ["fdelta_blast_workerRunning", false];
    };

    private _validationHandle = localNamespace getVariable [
        "fdelta_blast_validationWorkerHandle",
        scriptNull
    ];
    if (scriptDone _validationHandle) then {
        localNamespace setVariable [
            "fdelta_blast_validationWorkerHandle",
            [] spawn fdelta_fnc_blastProcessValidationQueue
        ];
    };

    private _monitorHandle = localNamespace getVariable [
        "fdelta_blast_registryMonitorHandle",
        scriptNull
    ];
    if (scriptDone _monitorHandle) then {
        localNamespace setVariable [
            "fdelta_blast_registryMonitorHandle",
            [] spawn fdelta_fnc_blastMonitorRegistry
        ];
    };

    private _watchdogHandle = localNamespace getVariable [
        "fdelta_blast_monitorWatchdogHandle",
        scriptNull
    ];
    if (scriptDone _watchdogHandle) then {
        localNamespace setVariable [
            "fdelta_blast_monitorWatchdogHandle",
            [] spawn (compile preprocessFileLineNumbers
                "\z\fdelta\addons\blast\functions\fn_blastMonitorWatchdog.sqf")
        ];
    };
};

if (isNil {localNamespace getVariable "fdelta_blast_localReporters"}) then {
    localNamespace setVariable ["fdelta_blast_localReporters", createHashMap];
};

private _projectileEH = localNamespace getVariable ["fdelta_blast_projectileEH", -1];
if (_projectileEH < 0) then {
    _projectileEH = addMissionEventHandler ["ProjectileCreated", {
        params ["_projectile"];
        if (isNull _projectile) exitWith {};

        private _ammo = typeOf _projectile;
        private _resolver = localNamespace getVariable [
            "fdelta_blast_resolveProfile",
            {[]}
        ];
        if (([_ammo] call _resolver) isEqualTo []) exitWith {};

        // Projectile EHs do not support the entity-only "Local" event. Install
        // the local Explode reporter on every modded proxy now; it fires only
        // on whichever machine owns the projectile when detonation occurs.
        [_projectile] call fdelta_fnc_blastRegisterProjectile;
    }];
    localNamespace setVariable ["fdelta_blast_projectileEH", _projectileEH];
};

diag_log "FDELTA_BLAST_INIT|Blast Propagation initialized";
