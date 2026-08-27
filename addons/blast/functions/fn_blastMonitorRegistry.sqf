/*
    Author: zobri

    Description:
        Maintains server-observed projectile positions and expires evidence.

    Returns:
        Nothing
*/
if (!isServer || {isRemoteExecuted}) exitWith {};

while {true} do {
    private _now = diag_tickTime;
    private _registry = missionNamespace getVariable [
        "fdelta_blast_projectileRegistry",
        createHashMap
    ];
    private _maxAge = missionNamespace getVariable ["fdelta_blast_maxEvidenceAge", 300];

    {
        private _key = _x;
        private _entry = _registry getOrDefault [_key, createHashMap];
        if (count _entry > 0) then {
            private _projectile = _entry getOrDefault ["projectile", objNull];
            private _registeredAt = _entry getOrDefault ["registeredAt", _now];
            private _lastSeenAt = _entry getOrDefault ["lastSeenAt", _registeredAt];

            if (_now - _registeredAt > _maxAge) then {
                _registry deleteAt _key;
            } else {
                if (!isNull _projectile) then {
                    private _ammo = _entry getOrDefault ["ammo", ""];
                    if (typeOf _projectile isNotEqualTo _ammo) then {
                        _registry deleteAt _key;
                    } else {
                        _entry set ["lastSeenAt", _now];
                        _entry set ["lastPositionASL", getPosASL _projectile];
                        _entry set ["lastVelocity", velocity _projectile];
                        _entry set [
                            "observations",
                            (_entry getOrDefault ["observations", 0]) + 1
                        ];
                        _registry set [_key, _entry];
                    };
                } else {
                    private _pending = _entry getOrDefault ["pending", false];
                    if (!_pending && {_now - _lastSeenAt > 3}) then {
                        _registry deleteAt _key;
                    };
                };
            };
        };
    } forEach (keys _registry);

    missionNamespace setVariable ["fdelta_blast_projectileRegistry", _registry];

    private _seen = missionNamespace getVariable ["fdelta_blast_seen", createHashMap];
    {
        if (_now - (_seen getOrDefault [_x, _now]) > 60) then {
            _seen deleteAt _x;
        };
    } forEach (keys _seen);
    missionNamespace setVariable ["fdelta_blast_seen", _seen];

    private _rates = missionNamespace getVariable ["fdelta_blast_ownerRates", createHashMap];
    {
        private _history = _rates getOrDefault [_x, []];
        _history = _history select {_now - _x <= 60};
        if (_history isEqualTo []) then {
            _rates deleteAt _x;
        } else {
            _rates set [_x, _history];
        };
    } forEach (keys _rates);
    missionNamespace setVariable ["fdelta_blast_ownerRates", _rates];

    uiSleep 0.05;
};
