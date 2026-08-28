if (!isNil "fdelta_test_projectileEH") exitWith {};

private _supported = [
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
missionNamespace setVariable ["fdelta_test_supportedAmmo", _supported];

fdelta_test_projectileEH = addMissionEventHandler ["ProjectileCreated", {
    params ["_projectile"];
    if (isNull _projectile) exitWith {};

    private _ammo = typeOf _projectile;
    if !(_ammo in (missionNamespace getVariable ["fdelta_test_supportedAmmo", []])) exitWith {};

    private _parents = getShotParents _projectile;
    [
        "PROJECTILE_CREATED",
        [
            _ammo,
            _projectile getVariable ["fdelta_test_case", ""],
            local _projectile,
            owner _projectile,
            netId _projectile,
            typeOf (_parents param [0, objNull]),
            typeOf (_parents param [1, objNull])
        ]
    ] call fdelta_test_fnc_log;

    _projectile addEventHandler ["Explode", {
        params ["_projectile", "_positionASL", "_velocity"];
        [
            "PROJECTILE_EXPLODE",
            [
                typeOf _projectile,
                _projectile getVariable ["fdelta_test_case", ""],
                local _projectile,
                owner _projectile,
                netId _projectile,
                _positionASL,
                _velocity,
                alive _projectile
            ]
        ] call fdelta_test_fnc_log;
    }];

    _projectile addEventHandler ["Deleted", {
        params ["_projectile"];
        [
            "PROJECTILE_DELETED",
            [
                typeOf _projectile,
                _projectile getVariable ["fdelta_test_case", ""],
                local _projectile,
                owner _projectile,
                netId _projectile
            ]
        ] call fdelta_test_fnc_log;
    }];

    [_projectile] spawn {
        params ["_projectile"];
        uiSleep 0.25;
        if (isNull _projectile) exitWith {};

        private _ammoCfg = configFile >> "CfgAmmo" >> typeOf _projectile;
        [
            "PROJECTILE_SETTLED",
            [
                typeOf _projectile,
                _projectile getVariable ["fdelta_test_case", ""],
                local _projectile,
                owner _projectile,
                netId _projectile,
                getNumber (_ammoCfg >> "hit"),
                getNumber (_ammoCfg >> "indirectHit"),
                getNumber (_ammoCfg >> "indirectHitRange"),
                isClass (
                    configFile
                        >> "CfgFdeltaBlastProfiles"
                        >> (typeOf _projectile)
                )
            ]
        ] call fdelta_test_fnc_log;
    };
}];

["DIAGNOSTICS_INSTALLED", [fdelta_test_projectileEH]] call fdelta_test_fnc_log;
