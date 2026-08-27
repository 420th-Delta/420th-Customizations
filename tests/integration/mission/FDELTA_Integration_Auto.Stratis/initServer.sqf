if (!isServer) exitWith {};

missionNamespace setVariable ["FDELTA_TEST_scriptErrors", []];
addMissionEventHandler ["ScriptError", {
    params ["_errorText", "_sourceFile", "_lineNumber", "_errorPosition", "_content", "_stackTrace"];
    private _errors = missionNamespace getVariable ["FDELTA_TEST_scriptErrors", []];
    _errors pushBack [_errorText, _sourceFile, _lineNumber, _errorPosition, _stackTrace];
    missionNamespace setVariable ["FDELTA_TEST_scriptErrors", _errors];
    diag_log format [
        "FDELTA_INTEGRATION|SCRIPT_ERROR|%1|%2:%3|%4",
        _errorText,
        _sourceFile,
        _lineNumber,
        _stackTrace
    ];
}];

[] spawn {
    waitUntil {time > 0};
    uiSleep 1;

    diag_log "FDELTA_INTEGRATION_BEGIN";
    private _passes = 0;
    private _failures = 0;
    private _assert = {
        params ["_label", "_condition", ["_data", []]];
        if (_condition) then {
            _passes = _passes + 1;
            diag_log format ["FDELTA_INTEGRATION|PASS|%1|%2", _label, _data];
        } else {
            _failures = _failures + 1;
            diag_log format ["FDELTA_INTEGRATION|FAIL|%1|%2", _label, _data];
        };
    };
    private _numberIs = {
        params ["_label", "_config", "_expected"];
        private _actual = getNumber _config;
        [_label, abs (_actual - _expected) < 0.001, [_actual, _expected]] call _assert;
    };
    private _textIs = {
        params ["_label", "_config", "_expected"];
        private _actual = getText _config;
        [_label, _actual isEqualTo _expected, [_actual, _expected]] call _assert;
    };

    {
        [format ["patch %1 loaded", _x], isClass (configFile >> "CfgPatches" >> _x)]
            call _assert;
    } forEach [
        "fdelta_main",
        "fdelta_ammo",
        "fdelta_blast",
        "fdelta_scalpel_l",
        "fdelta_turret_enhanced"
    ];

    private _functionNames = [
        "fdelta_fnc_blastPreInit",
        "fdelta_fnc_blastConfigureServer",
        "fdelta_fnc_blastProfile",
        "fdelta_fnc_blastSampleCurve",
        "fdelta_fnc_blastRegisterProjectile",
        "fdelta_fnc_blastRegisterProjectileEvidence",
        "fdelta_fnc_blastMonitorRegistry",
        "fdelta_fnc_blastReceiveBlast",
        "fdelta_fnc_blastProcessValidationQueue",
        "fdelta_fnc_blastValidateReport",
        "fdelta_fnc_blastProcessQueue",
        "fdelta_fnc_blastProcessBlast",
        "fdelta_fnc_blastMeasureCover",
        "fdelta_fnc_blastApplyTrauma",
        "fdelta_fnc_blastClientEffect",
        "fdelta_fnc_scalpelLOnFired",
        "fdelta_fnc_scalpelLCaptureCue",
        "fdelta_fnc_scalpelLTraceAimpoint",
        "fdelta_fnc_scalpelLTargetPointATL",
        "fdelta_fnc_scalpelLReceiveCue",
        "fdelta_fnc_scalpelLMonitorRegistryEntry",
        "fdelta_fnc_scalpelLGuideMissile",
        "fdelta_fnc_scalpelLFindTerminalTarget",
        "fdelta_fnc_terPostInit",
        "fdelta_fnc_terGetCameraAircraft",
        "fdelta_fnc_terCanUseCamera",
        "fdelta_fnc_terAddActions",
        "fdelta_fnc_terFindActiveLoiter",
        "fdelta_fnc_terOpenLoiterDialog",
        "fdelta_fnc_terLoiterDialogOnLoad",
        "fdelta_fnc_terApplyLoiterDialog",
        "fdelta_fnc_terApplyLoiterSettings",
        "fdelta_fnc_terApplyFlightProfileLocal",
        "fdelta_fnc_terServerApplyLoiterSettings",
        "fdelta_fnc_terServerMoveLoiterCenter",
        "fdelta_fnc_terNotify",
        "fdelta_fnc_terAimPoint",
        "fdelta_fnc_terMarkAim",
        "fdelta_fnc_terMoveLoiterCenter",
        "fdelta_fnc_terMeasureAim"
    ];
    {
        [format ["function %1 compiled", _x], !(isNil _x)] call _assert;
    } forEach _functionNames;

    private _functionRegistrations = [
        ["BlastPropagation", [
            "blastPreInit",
            "blastConfigureServer",
            "blastProfile",
            "blastSampleCurve",
            "blastRegisterProjectile",
            "blastRegisterProjectileEvidence",
            "blastMonitorRegistry",
            "blastReceiveBlast",
            "blastProcessValidationQueue",
            "blastValidateReport",
            "blastProcessQueue",
            "blastProcessBlast",
            "blastMeasureCover",
            "blastApplyTrauma",
            "blastClientEffect"
        ]],
        ["ScalpelL", [
            "scalpelLOnFired",
            "scalpelLCaptureCue",
            "scalpelLTraceAimpoint",
            "scalpelLTargetPointATL",
            "scalpelLReceiveCue",
            "scalpelLMonitorRegistryEntry",
            "scalpelLGuideMissile",
            "scalpelLFindTerminalTarget"
        ]],
        ["TurretEnhanced", [
            "terPostInit",
            "terGetCameraAircraft",
            "terCanUseCamera",
            "terAddActions",
            "terFindActiveLoiter",
            "terOpenLoiterDialog",
            "terLoiterDialogOnLoad",
            "terApplyLoiterDialog",
            "terApplyLoiterSettings",
            "terApplyFlightProfileLocal",
            "terServerApplyLoiterSettings",
            "terServerMoveLoiterCenter",
            "terNotify",
            "terAimPoint",
            "terMarkAim",
            "terMoveLoiterCenter",
            "terMeasureAim"
        ]]
    ];
    {
        _x params ["_category", "_names"];
        {
            [
                format ["CfgFunctions fdelta/%1/%2 registered", _category, _x],
                isClass (
                    configFile >> "CfgFunctions" >> "fdelta" >> _category >> _x
                )
            ] call _assert;
        } forEach _names;
    } forEach _functionRegistrations;

    private _ammoExpectations = [
        ["Bo_Mk82", 3200, 16.25],
        ["Bomb_04_F", 3200, 16.25],
        ["Bomb_03_F", 3600, 18.75],
        ["ammo_Bomb_SDB", 1600, 10],
        ["Sh_155mm_AMOS", 3600, 8.75],
        ["fdelta_M_Mo_155mm_HE_Guided", 3600, 8.75],
        ["fdelta_M_Mo_155mm_HE_LG", 3600, 8.75],
        ["R_230mm_fly", 3200, 16.25],
        ["ammo_Missile_Cruise_01", 7000, 30],
        ["Rocket_04_HE_F", 300, 10],
        ["Rocket_03_HE_F", 300, 10],
        ["M_AT", 250, 7.5],
        ["R_80mm_HE", 350, 10],
        ["ammo_Missile_HARM", 2000, 15],
        ["ammo_Missile_KH58", 2800, 18.75]
    ];
    {
        _x params ["_class", "_indirectHit", "_range"];
        private _cfg = configFile >> "CfgAmmo" >> _class;
        [format ["ammo %1 exists", _class], isClass _cfg] call _assert;
        [format ["ammo %1 indirectHit", _class], _cfg >> "indirectHit", _indirectHit]
            call _numberIs;
        [format ["ammo %1 indirectHitRange", _class], _cfg >> "indirectHitRange", _range]
            call _numberIs;
    } forEach _ammoExpectations;

    [
        "guided 155 terminal redirected",
        configFile >> "CfgAmmo" >> "Sh_155mm_AMOS_guided" >> "submunitionAmmo",
        "fdelta_M_Mo_155mm_HE_Guided"
    ] call _textIs;
    [
        "laser 155 terminal redirected",
        configFile >> "CfgAmmo" >> "Sh_155mm_AMOS_LG" >> "submunitionAmmo",
        "fdelta_M_Mo_155mm_HE_LG"
    ] call _textIs;
    [
        "ship guided terminal remains vanilla",
        configFile >> "CfgAmmo" >> "ammo_ShipCannon_120mm_HE_guided" >> "submunitionAmmo",
        "M_Mo_155mm_AT"
    ] call _textIs;

    private _dagr = configFile >> "CfgAmmo" >> "M_PG_AT";
    private _dagrm = configFile >> "CfgAmmo" >> "M_PGM_AT";
    private _dar = configFile >> "CfgAmmo" >> "M_AT";
    ["DAGR air lock", _dagr >> "airLock", 1] call _numberIs;
    ["DAGR speed gate", _dagr >> "missileLockMaxSpeed", 700] call _numberIs;
    ["DAGR usage flags", _dagr >> "aiAmmoUsageFlags", 448] call _numberIs;
    ["DAGRM air lock", _dagrm >> "airLock", 1] call _numberIs;
    ["DAGRM speed gate", _dagrm >> "missileLockMaxSpeed", 700] call _numberIs;
    ["DAR air lock remains disabled", _dar >> "airLock", 0] call _numberIs;
    ["DAR speed gate remains vanilla", _dar >> "missileLockMaxSpeed", 35] call _numberIs;
    ["DAR usage flags remain vanilla", _dar >> "aiAmmoUsageFlags", 192] call _numberIs;
    [
        "DAGR magazine lead speed",
        configFile >> "CfgMagazines" >> "24Rnd_PG_missiles" >> "maxLeadSpeed",
        700
    ] call _numberIs;

    private _dagrSensors = _dagr >> "Components" >> "SensorsManagerComponent" >> "Components";
    private _darSensors = _dar >> "Components" >> "SensorsManagerComponent" >> "Components";
    ["DAGR IR tracking speed", _dagrSensors >> "IRSensorComponent" >> "maxTrackableSpeed", 700]
        call _numberIs;
    ["DAGR laser tracking speed", _dagrSensors >> "LaserSensorComponent" >> "maxTrackableSpeed", 700]
        call _numberIs;
    ["DAR IR tracking speed remains vanilla", _darSensors >> "IRSensorComponent" >> "maxTrackableSpeed", 35]
        call _numberIs;
    ["DAR laser tracking speed remains vanilla", _darSensors >> "LaserSensorComponent" >> "maxTrackableSpeed", 35]
        call _numberIs;

    private _pinExpectations = [
        ["BombCluster_01_Ammo_F", 5000, 1100, 12],
        ["ammo_Missile_Cruise_01_Cluster", 6000, 2000, 30],
        ["Rocket_04_AP_F", 95, 25, 2.5],
        ["Rocket_03_AP_F", 95, 25, 3],
        ["ammo_ShipCannon_120mm_HE", -1, 125, 30]
    ];
    {
        _x params ["_class", "_hit", "_indirectHit", "_range"];
        private _cfg = configFile >> "CfgAmmo" >> _class;
        if (_hit >= 0) then {
            [format ["pin %1 hit", _class], _cfg >> "hit", _hit] call _numberIs;
        };
        [format ["pin %1 indirectHit", _class], _cfg >> "indirectHit", _indirectHit]
            call _numberIs;
        [format ["pin %1 range", _class], _cfg >> "indirectHitRange", _range]
            call _numberIs;
    } forEach _pinExpectations;

    private _inheritanceExpectations = [
        ["fdelta_M_Mo_155mm_HE_Guided", "M_Mo_155mm_AT"],
        ["fdelta_M_Mo_155mm_HE_LG", "M_Mo_155mm_AT_LG"],
        ["BombCluster_01_Ammo_F", "Bomb_04_F"],
        ["ammo_Missile_Cruise_01_Cluster", "ammo_Missile_Cruise_01"],
        ["ammo_ShipCannon_120mm_HE", "Sh_155mm_AMOS"],
        ["Rocket_04_AP_F", "Rocket_04_HE_F"],
        ["Rocket_03_AP_F", "Rocket_04_AP_F"],
        ["M_AT", "M_PG_AT"]
    ];
    {
        _x params ["_class", "_expectedParent"];
        private _actualParent = configName (
            inheritsFrom (configFile >> "CfgAmmo" >> _class)
        );
        [
            format ["ammo %1 direct parent", _class],
            _actualParent isEqualTo _expectedParent,
            [_actualParent, _expectedParent]
        ] call _assert;
    } forEach _inheritanceExpectations;

    private _cupAmmoLoaded = isClass (
        configFile >> "CfgPatches" >> "CUP_Weapons_Ammunition"
    );
    private _cupCompatLoaded = isClass (
        configFile >> "CfgPatches" >> "fdelta_ammo_cup"
    );
    [
        "CUP ammo compatibility activates exactly with dependency",
        _cupAmmoLoaded isEqualTo _cupCompatLoaded,
        [_cupAmmoLoaded, _cupCompatLoaded]
    ] call _assert;
    private _cup122Terminal = getText (
        configFile >> "CfgAmmo" >> "CUP_Sh_122_LASER" >> "submunitionAmmo"
    );
    private _cup105Terminal = getText (
        configFile >> "CfgAmmo" >> "CUP_Sh_105_LASER" >> "submunitionAmmo"
    );
    [
        "CUP 105/122 mm laser terminals remain outside 155 mm redirect",
        !_cupCompatLoaded || {
            _cup122Terminal isEqualTo "M_Mo_155mm_AT_LG"
            && {_cup105Terminal isEqualTo "M_Mo_155mm_AT_LG"}
        },
        [_cup122Terminal, _cup105Terminal]
    ] call _assert;

    private _rhsAmmoLoaded = isClass (
        configFile >> "CfgPatches" >> "rhsusf_c_airweapons"
    );
    private _rhsCompatLoaded = isClass (
        configFile >> "CfgPatches" >> "fdelta_ammo_rhsusaf"
    );
    [
        "RHSUSAF ammo compatibility activates exactly with dependency",
        _rhsAmmoLoaded isEqualTo _rhsCompatLoaded,
        [_rhsAmmoLoaded, _rhsCompatLoaded]
    ] call _assert;
    private _rhsMk82 = configFile >> "CfgAmmo" >> "rhs_ammo_mk82";
    [
        "RHS Mk 82 receives complete unitary-warhead policy",
        !_rhsCompatLoaded || {
            abs (getNumber (_rhsMk82 >> "indirectHit") - 3200) < 0.001
            && {abs (getNumber (
                _rhsMk82 >> "indirectHitRange"
            ) - 16.25) < 0.001}
        },
        [
            getNumber (_rhsMk82 >> "indirectHit"),
            getNumber (_rhsMk82 >> "indirectHitRange")
        ]
    ] call _assert;
    private _rhsMk82BlastProfile = configFile
        >> "CfgFdeltaBlastProfiles" >> "rhs_ammo_mk82";
    private _rhsCbuBlastProfile = configFile
        >> "CfgFdeltaBlastProfiles" >> "rhs_ammo_cbu_base";
    [
        "RHS Mk 82 alone receives exact supplemental blast profile",
        !_rhsCompatLoaded || {
            isClass _rhsMk82BlastProfile
            && {!isClass _rhsCbuBlastProfile}
        },
        [isClass _rhsMk82BlastProfile, isClass _rhsCbuBlastProfile]
    ] call _assert;
    private _rhsCbu = configFile >> "CfgAmmo" >> "rhs_ammo_cbu_base";
    [
        "RHS cluster carrier remains outside unitary-warhead policy",
        !_rhsCompatLoaded || {
            abs (getNumber (_rhsCbu >> "indirectHit") - 1150) < 0.001
            && {abs (getNumber (
                _rhsCbu >> "indirectHitRange"
            ) - 12) < 0.001}
        },
        [
            getNumber (_rhsCbu >> "indirectHit"),
            getNumber (_rhsCbu >> "indirectHitRange")
        ]
    ] call _assert;
    private _rhsDagrMagazine = configFile
        >> "CfgMagazines" >> "rhs_mag_DAGR_4";
    [
        "RHS DAGR retains coherent native lead-speed policy",
        !_rhsCompatLoaded || {
            abs (getNumber (
                _rhsDagrMagazine >> "maxLeadSpeed"
            ) - 41.6667) < 0.001
        },
        [getNumber (_rhsDagrMagazine >> "maxLeadSpeed")]
    ] call _assert;

    private _profileClasses = [
        "Bo_Mk82",
        "Bomb_04_F",
        "Bomb_03_F",
        "ammo_Bomb_SDB",
        "Sh_155mm_AMOS",
        "fdelta_M_Mo_155mm_HE_Guided",
        "fdelta_M_Mo_155mm_HE_LG",
        "R_230mm_fly",
        "ammo_Missile_Cruise_01",
        "Rocket_04_HE_F",
        "Rocket_03_HE_F",
        "M_AT",
        "R_80mm_HE",
        "ammo_Missile_HARM",
        "ammo_Missile_KH58"
    ];
    {
        [
            format ["blast profile %1 exists", _x],
            isClass (configFile >> "CfgFdeltaBlastProfiles" >> _x)
        ] call _assert;
    } forEach _profileClasses;
    {
        [
            format ["blast profile %1 excluded", _x],
            !isClass (configFile >> "CfgFdeltaBlastProfiles" >> _x)
        ] call _assert;
    } forEach [
        "BombCluster_01_Ammo_F",
        "ammo_Missile_Cruise_01_Cluster",
        "Sh_155mm_AMOS_guided",
        "Sh_155mm_AMOS_LG",
        "ammo_ShipCannon_120mm_HE"
    ];
    private _mk82Profile = ["Bo_Mk82"] call fdelta_fnc_blastProfile;
    ["Mk 82 profile resolves", count _mk82Profile isEqualTo 5, _mk82Profile] call _assert;
    [
        "blast curve samples exact point",
        abs (([70, [65, 70, 100], [0.36, 0.30, 0.18]] call fdelta_fnc_blastSampleCurve) - 0.30)
            < 0.001
    ] call _assert;
    ["invalid blast report rejected", !( ["bogus", [1, 1, 1], [0, 0, 0]] call fdelta_fnc_blastReceiveBlast)]
        call _assert;
    [
        "Blast ingress token helper is not remote-addressable",
        isNil "fdelta_fnc_blastConsumeIngressToken"
    ] call _assert;
    [
        "Blast ingress token helper exists only in localNamespace",
        (localNamespace getVariable [
            "fdelta_blast_consumeIngressToken",
            0
        ]) isEqualType {}
    ] call _assert;
    [
        "Blast HC owner resolver is not remote-addressable",
        isNil "fdelta_fnc_blastIsHeadlessOwner"
    ] call _assert;
    [
        "Blast HC owner resolver exists only in localNamespace",
        (localNamespace getVariable [
            "fdelta_blast_isHeadlessOwner",
            0
        ]) isEqualType {}
    ] call _assert;
    [
        "Blast profile resolver is not remote-addressable",
        isNil "fdelta_fnc_blastResolveProfile"
    ] call _assert;
    [
        "Blast profile resolver exists only in localNamespace",
        (localNamespace getVariable [
            "fdelta_blast_resolveProfile",
            0
        ]) isEqualType {}
    ] call _assert;
    [
        "Blast monitor watchdog is active",
        !scriptDone (localNamespace getVariable [
            "fdelta_blast_monitorWatchdogHandle",
            scriptNull
        ])
    ] call _assert;
    [
        "TER active-loiter resolver is not remote-addressable",
        isNil "fdelta_fnc_terResolveActiveLoiter"
    ] call _assert;
    [
        "TER active-loiter resolver exists only in localNamespace",
        (localNamespace getVariable [
            "fdelta_ter_resolveActiveLoiter",
            0
        ]) isEqualType {}
    ] call _assert;

    private _initialBlastSettings = [createHashMap]
        call fdelta_fnc_blastConfigureServer;
    [
        "Blast server configuration returns detached settings",
        _initialBlastSettings isEqualType createHashMap
            && {(_initialBlastSettings getOrDefault [
                "fdelta_blast_damageMultiplier",
                -1
            ]) isEqualTo 1}
    ] call _assert;
    _initialBlastSettings set ["fdelta_blast_damageMultiplier", 9];
    private _settingsAfterDetachedMutation = [createHashMap]
        call fdelta_fnc_blastConfigureServer;
    [
        "Blast configuration return cannot mutate live settings",
        (_settingsAfterDetachedMutation getOrDefault [
            "fdelta_blast_damageMultiplier",
            -1
        ]) isEqualTo 1
    ] call _assert;

    // A client can replace missionNamespace globals through publicVariable,
    // but runtime damage must consume only the server-local settings snapshot.
    missionNamespace setVariable ["fdelta_blast_damageMultiplier", 100];
    private _blastTestGroup = createGroup [east, true];
    private _blastTestTarget = _blastTestGroup createUnit [
        "O_V_Soldier_hex_F",
        [2500, 5500, 0],
        [],
        0,
        "CAN_COLLIDE"
    ];
    _blastTestTarget disableAI "ALL";
    [
        _blastTestTarget,
        0.1,
        "Bo_Mk82",
        getPosASL _blastTestTarget,
        100,
        [1, false],
        objNull,
        objNull,
        "integration-default-settings"
    ] call fdelta_fnc_blastApplyTrauma;
    [
        "published legacy Blast multiplier is non-authoritative after preInit",
        abs ((_blastTestTarget getVariable [
            "fdelta_blast_lastDose",
            -1
        ]) - 0.1) < 0.001
    ] call _assert;

    private _updatedBlastSettings = [createHashMapFromArray [
        ["fdelta_blast_damageMultiplier", 2],
        ["fdelta_blast_maxTargets", 4096],
        ["fdelta_blast_maxDamageQueue", 4096],
        ["fdelta_blast_maxRegistry", 16384],
        ["unrecognized_setting", 123]
    ]] call fdelta_fnc_blastConfigureServer;
    [
        "Blast configuration applies valid server-local update",
        (_updatedBlastSettings getOrDefault [
            "fdelta_blast_damageMultiplier",
            -1
        ]) isEqualTo 2
    ] call _assert;
    [
        "Blast configuration clamps registry workload bound",
        (_updatedBlastSettings getOrDefault [
            "fdelta_blast_maxRegistry",
            -1
        ]) isEqualTo 4096
    ] call _assert;
    [
        "Blast configuration clamps damage queue bound",
        (_updatedBlastSettings getOrDefault [
            "fdelta_blast_maxDamageQueue",
            -1
        ]) isEqualTo 512
    ] call _assert;
    [
        "Blast configuration clamps bounded integer update",
        (_updatedBlastSettings getOrDefault [
            "fdelta_blast_maxTargets",
            -1
        ]) isEqualTo 2048
    ] call _assert;
    [
        "Blast configuration ignores unknown setting",
        !("unrecognized_setting" in _updatedBlastSettings)
    ] call _assert;

    _blastTestTarget setDamage 0;
    [
        _blastTestTarget,
        0.1,
        "Bo_Mk82",
        getPosASL _blastTestTarget,
        100,
        [1, false],
        objNull,
        objNull,
        "integration-updated-settings"
    ] call fdelta_fnc_blastApplyTrauma;
    [
        "Blast trauma consumes configured server-local multiplier",
        abs ((_blastTestTarget getVariable [
            "fdelta_blast_lastDose",
            -1
        ]) - 0.2) < 0.001
    ] call _assert;

    private _invalidBlastSettings = [createHashMapFromArray [[
        "fdelta_blast_damageMultiplier",
        "invalid"
    ]]] call fdelta_fnc_blastConfigureServer;
    [
        "Blast configuration retains prior value after invalid update",
        (_invalidBlastSettings getOrDefault [
            "fdelta_blast_damageMultiplier",
            -1
        ]) isEqualTo 2
    ] call _assert;

    private _resetBlastSettings = [createHashMapFromArray [
        ["fdelta_blast_damageMultiplier", 1],
        ["fdelta_blast_maxTargets", 256],
        ["fdelta_blast_maxDamageQueue", 128],
        ["fdelta_blast_maxRegistry", 512]
    ]] call fdelta_fnc_blastConfigureServer;
    [
        "Blast configuration restored after test",
        (_resetBlastSettings getOrDefault [
            "fdelta_blast_damageMultiplier",
            -1
        ]) isEqualTo 1
            && {(_resetBlastSettings getOrDefault [
                "fdelta_blast_maxTargets",
                -1
            ]) isEqualTo 256}
            && {(_resetBlastSettings getOrDefault [
                "fdelta_blast_maxDamageQueue",
                -1
            ]) isEqualTo 128}
            && {(_resetBlastSettings getOrDefault [
                "fdelta_blast_maxRegistry",
                -1
            ]) isEqualTo 512}
    ] call _assert;

    // A stale task can outlive a locality reservation, so prove the validation
    // queue has its own strict cap instead of relying only on registry size.
    private _queueProjectile = createVehicle [
        "Bo_Mk82",
        [2400, 5400, 800],
        [],
        0,
        "CAN_COLLIDE"
    ];
    private _queueKey = netId _queueProjectile;
    private _queueEvidenceDeadline = diag_tickTime + 3;
    waitUntil {
        uiSleep 0.02;
        _queueKey = netId _queueProjectile;
        private _registry = localNamespace getVariable [
            "fdelta_blast_projectileRegistry",
            createHashMap
        ];
        count (_registry getOrDefault [_queueKey, createHashMap]) > 0
            || {diag_tickTime >= _queueEvidenceDeadline}
    };
    [createHashMapFromArray [["fdelta_blast_maxRegistry", 32]]]
        call fdelta_fnc_blastConfigureServer;
    private _savedValidationQueue = +(localNamespace getVariable [
        "fdelta_blast_validationQueue",
        []
    ]);
    private _fullValidationQueue = [];
    for "_index" from 1 to 32 do {
        _fullValidationQueue pushBack [];
    };
    localNamespace setVariable [
        "fdelta_blast_validationQueue",
        _fullValidationQueue
    ];
    private _queueReportAccepted = [
        _queueKey,
        getPosASL _queueProjectile,
        velocity _queueProjectile
    ] call fdelta_fnc_blastReceiveBlast;
    private _queueEntry = (localNamespace getVariable [
        "fdelta_blast_projectileRegistry",
        createHashMap
    ]) getOrDefault [_queueKey, createHashMap];
    [
        "Blast validation queue rejects before reserving at its hard cap",
        !_queueReportAccepted
            && {!(_queueEntry getOrDefault ["pending", false])},
        [_queueReportAccepted, _queueEntry]
    ] call _assert;
    localNamespace setVariable [
        "fdelta_blast_validationQueue",
        _savedValidationQueue
    ];
    [createHashMapFromArray [
        ["fdelta_blast_maxRegistry", 512],
        ["fdelta_blast_maxRegistryPerOwner", 128]
    ]]
        call fdelta_fnc_blastConfigureServer;
    deleteVehicle _queueProjectile;

    private _oldMonitorHandle = localNamespace getVariable [
        "fdelta_blast_registryMonitorHandle",
        scriptNull
    ];
    terminate _oldMonitorHandle;
    private _watchdogDeadline = diag_tickTime + 3;
    private _newMonitorHandle = scriptNull;
    waitUntil {
        uiSleep 0.05;
        _newMonitorHandle = localNamespace getVariable [
            "fdelta_blast_registryMonitorHandle",
            scriptNull
        ];
        (
            _newMonitorHandle isNotEqualTo _oldMonitorHandle
            && {!scriptDone _newMonitorHandle}
        ) || {diag_tickTime >= _watchdogDeadline}
    };
    [
        "Blast monitor watchdog restarts a terminated monitor",
        _newMonitorHandle isNotEqualTo _oldMonitorHandle
            && {!scriptDone _newMonitorHandle}
    ] call _assert;
    deleteVehicle _blastTestTarget;
    deleteGroup _blastTestGroup;

    private _scalpelAmmo = configFile >> "CfgAmmo" >> "fdelta_M_Scalpel_L";
    ["Scalpel-L ammo exists", isClass _scalpelAmmo] call _assert;
    ["Scalpel-L manual control", _scalpelAmmo >> "manualControl", 1] call _numberIs;
    ["Scalpel-L terminal range", _scalpelAmmo >> "fdelta_scalpelL_terminalRange", 1600]
        call _numberIs;
    ["Scalpel-L terminal cone", _scalpelAmmo >> "fdelta_scalpelL_terminalCone", 45]
        call _numberIs;
    ["Scalpel-L minimum loft", _scalpelAmmo >> "fdelta_scalpelL_minimumLoftDistance", 1500]
        call _numberIs;
    {
        private _cfg = configFile >> "CfgMagazines" >> _x;
        [format ["Scalpel-L magazine %1 exists", _x], isClass _cfg] call _assert;
        [format ["Scalpel-L magazine %1 ammo", _x], _cfg >> "ammo", "fdelta_M_Scalpel_L"]
            call _textIs;
        [
            format ["Scalpel-L magazine %1 weapon", _x],
            _cfg >> "pylonWeapon",
            "fdelta_missiles_Scalpel_L"
        ] call _textIs;
    } forEach [
        "fdelta_PylonRack_1Rnd_Scalpel_L",
        "fdelta_PylonMissile_1Rnd_Scalpel_L",
        "fdelta_PylonRack_3Rnd_Scalpel_L",
        "fdelta_PylonRack_4Rnd_Scalpel_L"
    ];
    private _scalpelWeapon = configFile >> "CfgWeapons" >> "fdelta_missiles_Scalpel_L";
    ["Scalpel-L weapon exists", isClass _scalpelWeapon] call _assert;
    [
        "Scalpel-L weapon exposes all magazines",
        getArray (_scalpelWeapon >> "magazines") isEqualTo [
            "fdelta_PylonRack_1Rnd_Scalpel_L",
            "fdelta_PylonMissile_1Rnd_Scalpel_L",
            "fdelta_PylonRack_3Rnd_Scalpel_L",
            "fdelta_PylonRack_4Rnd_Scalpel_L"
        ],
        getArray (_scalpelWeapon >> "magazines")
    ] call _assert;

    [
        "TER dialog exists",
        isClass (configFile >> "Fdelta_TER_LoiterDialog")
    ] call _assert;
    [
        "TER addon action group exists",
        getNumber (configFile >> "UserActionGroups" >> "Fdelta_TER_Actions" >> "isAddon")
            isEqualTo 1
    ] call _assert;
    private _remoteExpectations = [
        ["fdelta_fnc_blastRegisterProjectileEvidence", 2],
        ["fdelta_fnc_blastReceiveBlast", 2],
        ["fdelta_fnc_blastClientEffect", 1],
        ["fdelta_fnc_scalpelLReceiveCue", 0],
        ["fdelta_fnc_terServerApplyLoiterSettings", 2],
        ["fdelta_fnc_terServerMoveLoiterCenter", 2],
        ["fdelta_fnc_terApplyFlightProfileLocal", 0],
        ["fdelta_fnc_terNotify", 1]
    ];
    {
        _x params ["_function", "_target"];
        private _cfg = configFile >> "CfgRemoteExec" >> "Functions" >> _function;
        [format ["remote %1 exists", _function], isClass _cfg] call _assert;
        [format ["remote %1 target", _function], _cfg >> "allowedTargets", _target]
            call _numberIs;
        [format ["remote %1 no JIP", _function], _cfg >> "jip", 0] call _numberIs;
    } forEach _remoteExpectations;

    private _uav = createVehicle ["B_UAV_02_dynamicLoadout_F", [2100, 5600, 300], [], 0, "FLY"];
    createVehicleCrew _uav;
    private _group = group (driver _uav);
    private _waypoint = _group addWaypoint [[2200, 5600, 300], -1];
    _waypoint setWaypointType "LOITER";
    _waypoint setWaypointLoiterRadius 500;
    _waypoint setWaypointLoiterAltitude 100;
    _group setCurrentWaypoint _waypoint;
    uiSleep 0.2;

    private _found = [_uav] call fdelta_fnc_terFindActiveLoiter;
    [
        "active LOITER waypoint found",
        _found isEqualTo _waypoint,
        [_found, _waypoint, currentWaypoint _group]
    ] call _assert;
    private _profileApplied = [_uav, 600, 40] call fdelta_fnc_terApplyFlightProfileLocal;
    ["owner-local flight profile accepted", _profileApplied] call _assert;
    [
        "flight profile state recorded",
        _uav getVariable ["fdelta_terLastAppliedFlightProfile", []] isEqualTo [600, 40]
    ] call _assert;
    _waypoint setWaypointLoiterAltitude 40;
    _waypoint setWaypointLoiterRadius 800;
    ["loiter radius changed", abs (waypointLoiterRadius _waypoint - 800) < 0.1]
        call _assert;
    ["loiter terrain altitude changed", abs (waypointLoiterAltitude _waypoint - 40) < 0.1]
        call _assert;

    private _newCenterASL = AGLToASL [2400, 5700, 0];
    _waypoint setWaypointPosition [_newCenterASL, -1];
    uiSleep 0.1;
    [
        "loiter center moved",
        (waypointPosition _waypoint) distance2D (ASLToAGL _newCenterASL) < 5,
        [waypointPosition _waypoint, ASLToAGL _newCenterASL]
    ] call _assert;

    private _deadAircraft = createVehicle [
        "B_UAV_01_F",
        [2050, 5550, 0],
        [],
        0,
        "NONE"
    ];
    _deadAircraft setDamage 1;
    private _nonAircraft = createVehicle [
        "B_Quadbike_01_F",
        [2070, 5550, 0],
        [],
        0,
        "NONE"
    ];
    private _validRegistryProfile = [_uav, 600, 40];
    _uav setVariable ["fdelta_terLastAppliedFlightProfile", []];
    localNamespace setVariable ["fdelta_terFlightProfiles", [
        _validRegistryProfile,
        [objNull, 600, 40],
        [_deadAircraft, 650, 45],
        [_nonAircraft, 700, 50],
        [_uav, 10, 40],
        [_uav, 600, 5],
        [_uav],
        "malformed"
    ]];
    private _registryDeadline = diag_tickTime + 7;
    waitUntil {
        uiSleep 0.1;
        private _profiles = localNamespace getVariable [
            "fdelta_terFlightProfiles",
            []
        ];
        (
            _profiles isEqualType []
            && {count _profiles isEqualTo 1}
            && {(_profiles # 0) isEqualTo _validRegistryProfile}
        ) || {diag_tickTime >= _registryDeadline}
    };
    private _prunedProfiles = localNamespace getVariable [
        "fdelta_terFlightProfiles",
        []
    ];
    [
        "TER registry prunes null, dead, non-air, out-of-range and malformed entries",
        _prunedProfiles isEqualTo [_validRegistryProfile],
        _prunedProfiles
    ] call _assert;
    [
        "TER registry reapplies its surviving owner-local profile",
        _uav getVariable ["fdelta_terLastAppliedFlightProfile", []]
            isEqualTo [600, 40]
    ] call _assert;
    localNamespace setVariable ["fdelta_terFlightProfiles", []];

    private _errors = missionNamespace getVariable ["FDELTA_TEST_scriptErrors", []];
    ["no SQF ScriptError events", _errors isEqualTo [], _errors] call _assert;

    deleteVehicleCrew _uav;
    deleteVehicle _uav;
    deleteGroup _group;
    deleteVehicle _deadAircraft;
    deleteVehicle _nonAircraft;

    diag_log format [
        "FDELTA_INTEGRATION_SUMMARY|pass=%1|passes=%2|failures=%3|scriptErrors=%4",
        _failures isEqualTo 0,
        _passes,
        _failures,
        count _errors
    ];
    diag_log "FDELTA_INTEGRATION_DONE";
    endMission "END1";
};
