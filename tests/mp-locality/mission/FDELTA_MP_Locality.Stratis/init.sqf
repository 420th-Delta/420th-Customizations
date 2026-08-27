[] call fdelta_test_fnc_installScriptErrorHandler;
[] call fdelta_test_fnc_installDiagnostics;
[] call fdelta_test_fnc_snapshotMachine;

[] spawn {
    waitUntil {time > 0};
    uiSleep 0.5;

    private _ammoCfg = configFile >> "CfgAmmo" >> "Bo_Mk82";
    private _info = [
        clientOwner,
        isServer,
        isDedicated,
        hasInterface,
        profileName,
        isClass (configFile >> "CfgPatches" >> "fdelta_ammo"),
        isClass (configFile >> "CfgPatches" >> "fdelta_blast"),
        getNumber (_ammoCfg >> "hit"),
        getNumber (_ammoCfg >> "indirectHit"),
        getNumber (_ammoCfg >> "indirectHitRange")
    ];

    if (isServer) then {
        [_info] call fdelta_test_fnc_registerNode;
    } else {
        [_info] remoteExecCall ["fdelta_test_fnc_registerNode", 2];
    };
};
