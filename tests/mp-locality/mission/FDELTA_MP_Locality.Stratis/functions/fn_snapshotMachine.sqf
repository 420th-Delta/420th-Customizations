private _ammoCfg = configFile >> "CfgAmmo" >> "Bo_Mk82";
private _patchNames = [
    "fdelta_main",
    "fdelta_ammo",
    "fdelta_blast"
];
private _patchState = _patchNames apply {
    [_x, isClass (configFile >> "CfgPatches" >> _x)]
};

[
    "MACHINE_CONFIG",
    [
        productVersion,
        worldName,
        _patchState,
        [
            "Bo_Mk82",
            getNumber (_ammoCfg >> "hit"),
            getNumber (_ammoCfg >> "indirectHit"),
            getNumber (_ammoCfg >> "indirectHitRange"),
            configSourceAddonList _ammoCfg
        ],
        [
            "fdeltaProfile",
            isClass (configFile >> "CfgFdeltaBlastProfiles" >> "Bo_Mk82")
        ],
        [
            "fdeltaReporter",
            !(isNil "fdelta_fnc_blastRegisterProjectile")
        ]
    ]
] call fdelta_test_fnc_log;

