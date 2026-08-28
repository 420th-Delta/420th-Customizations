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
        "fdelta_fnc_blastSampleCurve",
        "fdelta_fnc_blastProcessBlast",
        "fdelta_fnc_blastMeasureCover",
        "fdelta_fnc_scalpelLOnFired",
        "fdelta_fnc_scalpelLCaptureCue",
        "fdelta_fnc_scalpelLTraceAimpoint",
        "fdelta_fnc_scalpelLTargetPointATL",
        "fdelta_fnc_scalpelLReceiveCue",
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
            "blastSampleCurve",
            "blastProcessBlast",
            "blastMeasureCover"
        ]],
        ["ScalpelL", [
            "scalpelLOnFired",
            "scalpelLCaptureCue",
            "scalpelLTraceAimpoint",
            "scalpelLTargetPointATL",
            "scalpelLReceiveCue",
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
        ["M_Mo_155mm_AT", 200, 4],
        ["M_Mo_155mm_AT_LG", 200, 4],
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
        "guided 155 terminal direct damage remains vanilla",
        configFile >> "CfgAmmo" >> "M_Mo_155mm_AT" >> "hit",
        1200
    ] call _numberIs;
    [
        "laser 155 terminal direct damage remains vanilla",
        configFile >> "CfgAmmo" >> "M_Mo_155mm_AT_LG" >> "hit",
        1200
    ] call _numberIs;
    [
        "custom guided 155 terminal class is absent",
        !isClass (configFile >> "CfgAmmo" >> "fdelta_M_Mo_155mm_HE_Guided")
    ] call _assert;
    [
        "custom laser 155 terminal class is absent",
        !isClass (configFile >> "CfgAmmo" >> "fdelta_M_Mo_155mm_HE_LG")
    ] call _assert;

    [
        "guided 155 carrier retains vanilla terminal",
        configFile >> "CfgAmmo" >> "Sh_155mm_AMOS_guided" >> "submunitionAmmo",
        "M_Mo_155mm_AT"
    ] call _textIs;
    [
        "laser 155 carrier retains vanilla terminal",
        configFile >> "CfgAmmo" >> "Sh_155mm_AMOS_LG" >> "submunitionAmmo",
        "M_Mo_155mm_AT_LG"
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
        ["M_Mo_155mm_AT", "M_Mo_120mm_AT"],
        ["M_Mo_155mm_AT_LG", "M_Mo_120mm_AT_LG"],
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
    private _cupCompatPresent = isClass (
        configFile >> "CfgPatches" >> "fdelta_ammo_cup"
    );
    [
        "obsolete CUP ammo compatibility shim is absent",
        !_cupCompatPresent,
        [_cupAmmoLoaded, _cupCompatPresent]
    ] call _assert;
    private _cup122Terminal = getText (
        configFile >> "CfgAmmo" >> "CUP_Sh_122_LASER" >> "submunitionAmmo"
    );
    private _cup105Terminal = getText (
        configFile >> "CfgAmmo" >> "CUP_Sh_105_LASER" >> "submunitionAmmo"
    );
    [
        "CUP 105/122 mm laser terminals remain vanilla without a shim",
        !_cupAmmoLoaded || {
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
        "M_Mo_155mm_AT",
        "M_Mo_155mm_AT_LG",
        "fdelta_M_Mo_155mm_HE_Guided",
        "fdelta_M_Mo_155mm_HE_LG",
        "ammo_ShipCannon_120mm_HE"
    ];
    private _blastFunctionConfigs = configProperties [
        configFile >> "CfgFunctions" >> "fdelta" >> "BlastPropagation",
        "isClass _x",
        false
    ];
    [
        "Blast exposes only four functions",
        count _blastFunctionConfigs isEqualTo 4,
        _blastFunctionConfigs apply {configName _x}
    ] call _assert;

    private _profileCache = localNamespace getVariable [
        "fdelta_blast_profiles",
        0
    ];
    private _mk82Profile = if (_profileCache isEqualType createHashMap) then {
        _profileCache getOrDefault ["Bo_Mk82", []]
    } else {
        []
    };
    private _profileCount = if (_profileCache isEqualType createHashMap) then {
        count _profileCache
    } else {
        -1
    };
    private _projectileEH = localNamespace getVariable [
        "fdelta_blast_projectileEH",
        -1
    ];
    [
        "Blast profile cache and projectile listener are active",
        _profileCache isEqualType createHashMap
            && {count _mk82Profile isEqualTo 5}
            && {_projectileEH isEqualType 0 && {_projectileEH >= 0}},
        [_profileCount, _projectileEH, _mk82Profile]
    ] call _assert;
    [
        "blast curve samples exact and interpolated points",
        abs (([70, [65, 70, 100], [0.36, 0.30, 0.18]]
            call fdelta_fnc_blastSampleCurve) - 0.30) < 0.001
            && {abs (([85, [65, 70, 100], [0.36, 0.30, 0.18]]
                call fdelta_fnc_blastSampleCurve) - 0.24) < 0.001}
    ] call _assert;

    private _blastRemoteEntries = configProperties [
        configFile >> "CfgRemoteExec" >> "Functions",
        "isClass _x",
        true
    ] select {
        ((toLower (configName _x)) find "fdelta_fnc_blast") isEqualTo 0
    };
    [
        "Blast exposes no CfgRemoteExec functions",
        _blastRemoteEntries isEqualTo [],
        _blastRemoteEntries apply {configName _x}
    ] call _assert;

    private _blastWorkerState = allVariables localNamespace select {
        private _name = toLower _x;
        (_name find "fdelta_blast_") isEqualTo 0
            && {
                (localNamespace getVariable _x) isEqualType scriptNull
                || {_name find "queue" >= 0}
                || {_name find "registry" >= 0}
                || {_name find "worker" >= 0}
                || {_name find "monitor" >= 0}
                || {_name find "watchdog" >= 0}
            }
    };
    [
        "Blast has no permanent queue or worker state",
        _blastWorkerState isEqualTo [],
        _blastWorkerState
    ] call _assert;

    private _savedBlastEnabled = missionNamespace getVariable [
        "fdelta_blast_enabled",
        true
    ];
    private _savedBlastMultiplier = missionNamespace getVariable [
        "fdelta_blast_damageMultiplier",
        1
    ];
    private _savedBlastMaxTargets = missionNamespace getVariable [
        "fdelta_blast_maxTargets",
        128
    ];
    missionNamespace setVariable ["fdelta_blast_enabled", true];
    missionNamespace setVariable ["fdelta_blast_damageMultiplier", 1];
    missionNamespace setVariable ["fdelta_blast_maxTargets", 128];

    private _blastTestGroup = createGroup [east, true];
    private _blastTestTarget = _blastTestGroup createUnit [
        "O_V_Soldier_hex_F",
        [2500, 5500, 0],
        [],
        0,
        "CAN_COLLIDE"
    ];
    _blastTestTarget disableAI "ALL";
    private _blastOriginASL = getPosASL _blastTestTarget vectorAdd [-70, 0, 1];

    _blastTestTarget setDamage 0;
    [
        "Bo_Mk82",
        _blastOriginASL,
        [0, 0, -100],
        _mk82Profile,
        objNull,
        objNull
    ] call fdelta_fnc_blastProcessBlast;
    private _freshDamage = damage _blastTestTarget;
    [
        "owner-local Blast processing damages a fresh target",
        local _blastTestTarget && {_freshDamage > 0 && {_freshDamage <= 1}},
        _freshDamage
    ] call _assert;

    _blastTestTarget setDamage 0.4;
    private _beforeSupplement = damage _blastTestTarget;
    [
        "Bo_Mk82",
        _blastOriginASL,
        [0, 0, -100],
        _mk82Profile,
        objNull,
        objNull
    ] call fdelta_fnc_blastProcessBlast;
    private _afterSupplement = damage _blastTestTarget;
    [
        "owner-local Blast adds to pre-damage without healing",
        _afterSupplement > _beforeSupplement,
        [_beforeSupplement, _afterSupplement]
    ] call _assert;

    missionNamespace setVariable ["fdelta_blast_enabled", _savedBlastEnabled];
    missionNamespace setVariable [
        "fdelta_blast_damageMultiplier",
        _savedBlastMultiplier
    ];
    missionNamespace setVariable ["fdelta_blast_maxTargets", _savedBlastMaxTargets];
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
        ["fdelta_fnc_scalpelLReceiveCue", 0],
        ["fdelta_fnc_terServerApplyLoiterSettings", 2],
        ["fdelta_fnc_terServerMoveLoiterCenter", 2],
        ["fdelta_fnc_terApplyFlightProfileLocal", 0]
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

    private _errors = missionNamespace getVariable ["FDELTA_TEST_scriptErrors", []];
    ["no SQF ScriptError events", _errors isEqualTo [], _errors] call _assert;

    deleteVehicleCrew _uav;
    deleteVehicle _uav;
    deleteGroup _group;

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
