/*
    Author: zobri

    Finds and ranks valid terminal ground targets using sensor eligibility,
    hostility, line of sight, launch aimpoint proximity, and seeker geometry.
*/
params [
    "_missile",
    "_launcher",
    "_instigator",
    ["_originalLaser", objNull],
    ["_seekerRange", 1600],
    ["_seekerCone", 25],
    ["_referenceAimpointATL", []],
    ["_excludedTarget", objNull]
];

if (isNull _missile || {!local _missile}) exitWith {objNull};

private _candidateObjects = [];
private _sensorTracks = getSensorTargets _missile;

{
    _x params
    [
        ["_target", objNull],
        ["_type", "unknown"],
        ["_relationship", "unknown"],
        ["_sensors", []]
    ];

    if (!isNull _target && {_relationship isNotEqualTo "destroyed"}) then {
        private _isBoundLaser =
            !isNull _originalLaser &&
            {_target isEqualTo _originalLaser} &&
            {_target isKindOf "LaserTarget"};
        private _sensorNames = _sensors apply {toLowerANSI _x};
        private _physicalSeekerTrack =
            (_sensorNames findIf {
                (_x find "activeradar") >= 0 ||
                {(_x find "irsensor") >= 0} ||
                {_x isEqualTo "ir"}
            }) >= 0;
        private _isGroundVehicle =
            (_target isKindOf "LandVehicle") ||
            {_target isKindOf "Ship"} ||
            {_target isKindOf "StaticWeapon"};

        if (_isBoundLaser || {_physicalSeekerTrack && {_isGroundVehicle}}) then {
            _candidateObjects pushBackUnique _target;
        };
    };
} forEach _sensorTracks;

// Deterministic active-radar/IR fallback for ground vehicles whose sensor
// track has not populated on the same simulation tick. A physical radar or IR
// signature is still required; infantry, aircraft, arbitrary objects and
// arbitrary laser spots are excluded below.
private _nearbyVehicles = _missile nearEntities
[
    ["LandVehicle", "Ship", "StaticWeapon"],
    _seekerRange
];
{
    private _vehicleConfig = configOf _x;
    if (
        (getNumber (_vehicleConfig >> "radarTarget") > 0) ||
        {getNumber (_vehicleConfig >> "radarTargetSize") > 0} ||
        {getNumber (_vehicleConfig >> "irTarget") > 0} ||
        {getNumber (_vehicleConfig >> "irTargetSize") > 0}
    ) then {
        _candidateObjects pushBackUnique _x;
    };
} forEach _nearbyVehicles;

// A selected-but-unlocked laser is identity-bound at launch. It may be
// reacquired terminally, but an unrelated laser spot is never considered.
if (!isNull _originalLaser && {alive _originalLaser}) then {
    _candidateObjects pushBackUnique _originalLaser;
};

private _originASL = getPosASL _missile;
private _hasReferenceAimpoint =
    (count _referenceAimpointATL) isEqualTo 3 &&
    {
        (_referenceAimpointATL findIf {
            !(_x isEqualType 0) ||
            {!(finite _x)}
        }) < 0
    };
private _flightDirection = vectorNormalized velocity _missile;
if ((vectorMagnitude _flightDirection) < 0.1) then {
    _flightDirection = vectorDir _missile;
};

private _launchSide = if (!isNull _instigator) then {
    side group _instigator
}
else {
    if (isNull _launcher) then {sideUnknown} else {side _launcher}
};
private _ranked = [];
private _candidateOrdinal = 0;

{
    private _target = _x;
    if (
        !isNull _target &&
        {_target isNotEqualTo _launcher} &&
        {_target isNotEqualTo _excludedTarget} &&
        {alive _target} &&
        {
            (
                _target isKindOf "LaserTarget" &&
                {_target isEqualTo _originalLaser}
            ) ||
            {_target isKindOf "LandVehicle"} ||
            {_target isKindOf "Ship"} ||
            {_target isKindOf "StaticWeapon"}
        }
    ) then {
        private _isBoundLaser =
            !isNull _originalLaser &&
            {_target isEqualTo _originalLaser} &&
            {_target isKindOf "LaserTarget"};
        private _targetSide = side _target;
        if (
            !_isBoundLaser &&
            {_targetSide in [sideUnknown, civilian]} &&
            {!(_target isKindOf "LaserTarget")}
        ) then {
            // Empty vehicles report civilian/unknown at runtime. Retain their
            // configured faction so an abandoned or remote-controlled OPFOR
            // vehicle is not treated as friendly ambiguity.
            _targetSide = [east, west, resistance, civilian] param
                [round getNumber (configOf _target >> "side"), sideUnknown];
        };
        private _hostileOrUnknown =
            _isBoundLaser ||
            {
                !(_launchSide in [sideUnknown, civilian]) &&
                {!(_targetSide in [sideUnknown, civilian])} &&
                {(_launchSide getFriend _targetSide) < 0.6}
            };

        if (_hostileOrUnknown) then {
            private _targetASL = getPosASL _target;
            if !(_target isKindOf "LaserTarget") then {
                private _aimPosition = aimPos _target;
                if (_aimPosition isNotEqualTo [0, 0, 0]) then {
                    _targetASL = _aimPosition;
                };
            };

            private _offset = _targetASL vectorDiff _originASL;
            private _distance = vectorMagnitude _offset;
            if (_distance > 0 && {_distance <= _seekerRange}) then {
                private _targetDirection = _offset vectorMultiply (1 / _distance);
                private _cosine = (_flightDirection vectorCos _targetDirection) max -1 min 1;
                private _angle = acos _cosine;
                private _surfaceHits = lineIntersectsSurfaces
                [
                    _originASL,
                    _targetASL,
                    _missile,
                    _target,
                    true,
                    1,
                    "VIEW",
                    "FIRE"
                ];
                if (
                    _surfaceHits isEqualTo [] &&
                    {
                        // With an immutable launch reference, build the
                        // aimpoint ranking before applying the instantaneous
                        // tracking cone. A farther target that happens to
                        // enter the cone first must not steal the missile.
                        _hasReferenceAimpoint ||
                        {_angle <= _seekerCone}
                    }
                ) then {
                    private _targetATL = ASLToATL _targetASL;
                    private _aimpointDistance = if (_hasReferenceAimpoint) then {
                        _targetATL distance2D _referenceAimpointATL
                    }
                    else {
                        0
                    };
                    private _sortKeys = if (_hasReferenceAimpoint) then {
                        // The immutable launch aimpoint owns selection.
                        // Separate numeric keys make this a strict ordering;
                        // angle and missile range can never outweigh even a
                        // small advantage in aimpoint distance.
                        [_aimpointDistance, _angle, _distance]
                    }
                    else {
                        // Backward-compatible order for callers that do not
                        // supply a launch reference.
                        [_angle, _distance, 0]
                    };
                    _ranked pushBack
                    [
                        _sortKeys # 0,
                        _sortKeys # 1,
                        _sortKeys # 2,
                        _candidateOrdinal,
                        _target
                    ];
                    _candidateOrdinal = _candidateOrdinal + 1;
                };
            };
        };
    };
} forEach _candidateObjects;

if (_ranked isEqualTo []) exitWith {objNull};
_ranked sort true;
_missile setVariable ["fdelta_scalpelL_lastSeekerRanking", +_ranked];
private _winner = _ranked # 0;
if (_hasReferenceAimpoint && {(_winner # 1) > _seekerCone}) exitWith {
    // Hold coordinate guidance until the target nearest the launch aimpoint
    // enters the physical cone. Do not fall through to a farther candidate.
    _missile setVariable ["fdelta_scalpelL_seekerWaitingForCone", _winner # 4];
    objNull
};
_missile setVariable ["fdelta_scalpelL_seekerWaitingForCone", objNull];
_winner # 4
