/*
    Author: zobri

    Runs the owner-local Scalpel-L loft, pitch-over, terminal acquisition,
    native handoff, lock-loss, and reacquisition controller.
*/
params ["_missile"];

if (isNull _missile || {!local _missile} || {typeOf _missile isNotEqualTo "fdelta_M_Scalpel_L"}) exitWith {};
if (_missile getVariable ["fdelta_scalpelL_controllerActive", false]) exitWith {};
_missile setVariable ["fdelta_scalpelL_controllerActive", true];
_missile setVariable ["fdelta_scalpelL_guidanceMode", "pending"];

private _ammoConfig = configOf _missile;
private _terminalRange = getNumber (_ammoConfig >> "fdelta_scalpelL_terminalRange");
private _terminalCone = getNumber (_ammoConfig >> "fdelta_scalpelL_terminalCone");
private _cueWait = getNumber (_ammoConfig >> "fdelta_scalpelL_cueWait");
private _loftAngle = getNumber (_ammoConfig >> "fdelta_scalpelL_loftAngle");
private _pitchRadius = getNumber (_ammoConfig >> "fdelta_scalpelL_pitchRadius");
private _verticalDiveHeight = getNumber (_ammoConfig >> "fdelta_scalpelL_verticalDiveHeight");
private _waypointTolerance = getNumber (_ammoConfig >> "fdelta_scalpelL_waypointTolerance");
private _minimumLoftDistance = getNumber (_ammoConfig >> "fdelta_scalpelL_minimumLoftDistance");
if (_terminalRange <= 0) then {_terminalRange = 1600;};
if (_terminalCone <= 0) then {_terminalCone = 45;};
if (_cueWait <= 0) then {_cueWait = 0.50;};
if (_loftAngle <= 0 || {_loftAngle >= 89}) then {_loftAngle = 40;};
if (_pitchRadius <= 0) then {_pitchRadius = 500;};
if (_verticalDiveHeight <= 0) then {_verticalDiveHeight = 400;};
if (_waypointTolerance <= 0) then {_waypointTolerance = 80;};
if (_minimumLoftDistance <= 0) then {_minimumLoftDistance = 1500;};

private _deadline = diag_tickTime + _cueWait;
waitUntil {
    uiSleep 0.01;
    isNull _missile ||
    {!local _missile} ||
    {
        private _cue = _missile getVariable ["fdelta_scalpelL_launchCue", []];
        _cue isNotEqualTo [] && {(_cue # 0) >= 220}
    } ||
    {diag_tickTime >= _deadline}
};

if (isNull _missile) exitWith {};
if (!local _missile) exitWith {
    _missile setVariable ["fdelta_scalpelL_guidanceMode", "locality-lost"];
    _missile setVariable ["fdelta_scalpelL_controllerActive", false];
};

private _cue = _missile getVariable ["fdelta_scalpelL_launchCue", []];
if (_cue isEqualTo []) exitWith {
    _missile setVariable ["fdelta_scalpelL_guidanceMode", "uncued"];
    _missile setVariable ["fdelta_scalpelL_controllerActive", false];
};

_cue params
[
    ["_priority", 0],
    ["_aimpointATL", []],
    ["_selectedTarget", objNull],
    ["_lockValue", 0],
    ["_source", "unknown"]
];

if ((count _aimpointATL) < 3) exitWith {
    _missile setVariable ["fdelta_scalpelL_guidanceMode", "invalid-cue"];
    _missile setVariable ["fdelta_scalpelL_controllerActive", false];
};

// Detach the guidance reference from the nested launch-cue array. Every
// non-hard acquisition and every later recovery uses this immutable copy.
_aimpointATL = +_aimpointATL;

private _engineTarget = missileTarget _missile;
private _explicitSoftCue =
    _priority >= 250 &&
    {!isNull _selectedTarget} &&
    {_lockValue < 0.999};
private _hardTarget = objNull;

if (!isNull _selectedTarget && {_lockValue >= 0.999}) then {
    _hardTarget = _selectedTarget;
}
else {
    // Only an owner-generated fallback may promote an engine target. A
    // player's camera or partial-selection snapshot always outranks a target
    // that another crew member may have attached to the projectile.
    if (
        !_explicitSoftCue &&
        {_priority isEqualTo 200} &&
        {_source isEqualTo "engine-hard-lock"} &&
        {!isNull _engineTarget}
    ) then {
        _hardTarget = _engineTarget;
    };
};

private _parents = getShotParents _missile;
private _launcher = _parents param [0, objNull];
private _instigator = _parents param [1, objNull];
private _originalLaser = objNull;
if (!isNull _selectedTarget && {_selectedTarget isKindOf "LaserTarget"}) then {
    _originalLaser = _selectedTarget;
};

private _launchATL = getPosATL _missile;
private _launchVelocity = velocity _missile;
private _launchBodyDirection = vectorDir _missile;
private _launchBodyUp = vectorUp _missile;
_missile setVariable
[
    "fdelta_scalpelL_launchKinematics",
    [+_launchVelocity, +_launchBodyDirection, +_launchBodyUp]
];

// Missile steering inherits the carrier's pitch and heading, but an aircraft
// bank must not rotate the guidance controller's pitch plane. Establish a
// roll-neutral body reference without changing either velocity or heading.
private _rollNeutralUp =
[
    -((_launchBodyDirection # 0) * (_launchBodyDirection # 2)),
    -((_launchBodyDirection # 1) * (_launchBodyDirection # 2)),
    1 - ((_launchBodyDirection # 2) * (_launchBodyDirection # 2))
];
if ((vectorMagnitude _rollNeutralUp) > 0.05) then {
    _rollNeutralUp = vectorNormalized _rollNeutralUp;
    _missile setVectorDirAndUp [_launchBodyDirection, _rollNeutralUp];
    _missile setVariable ["fdelta_scalpelL_rollReferenceEstablished", true];
};

private _initialGuidanceAimATL = +_aimpointATL;
if (!isNull _hardTarget) then {
    _initialGuidanceAimATL = [_hardTarget] call fdelta_fnc_scalpelLTargetPointATL;
};

private _horizontalOffset =
[
    (_initialGuidanceAimATL # 0) - (_launchATL # 0),
    (_initialGuidanceAimATL # 1) - (_launchATL # 1),
    0
];
private _totalDistance2D = vectorMagnitude _horizontalOffset;
private _approachDirection = vectorNormalized _horizontalOffset;
private _apexHeightAboveTarget = _pitchRadius + _verticalDiveHeight;
private _nominalApexATL = (_initialGuidanceAimATL # 2) + _apexHeightAboveTarget;
private _cruiseHeight = _nominalApexATL max (_launchATL # 2);
private _initialArcRadius =
    ((_cruiseHeight - (_initialGuidanceAimATL # 2)) - _verticalDiveHeight)
    max _pitchRadius;
private _heightDelta = (_cruiseHeight - (_launchATL # 2)) max 0;
private _climbDistance = if (_heightDelta > 1) then {
    _heightDelta / (tan _loftAngle)
}
else {
    100
};
// Reserve the actual pitch-over radius. High-altitude releases use a larger
// arc than the nominal 500 m and therefore need an earlier profile entry.
private _maximumClimbRun =
    (_totalDistance2D - _initialArcRadius - 150) max 100;
_climbDistance = (_climbDistance max 100) min _maximumClimbRun;
private _climbCommandProgress = _climbDistance;

private _useLoft =
    _totalDistance2D >= _minimumLoftDistance &&
    {(vectorMagnitude _approachDirection) > 0.1} &&
    {_maximumClimbRun >= 200};

private _climbWaypointATL = _launchATL vectorAdd (_approachDirection vectorMultiply _climbDistance);
_climbWaypointATL set [2, _cruiseHeight];
private _arcAngles = [90, 75, 60, 45, 30, 15, 0];
private _arcIndex = 0;
private _arcWaypointATL = +_initialGuidanceAimATL;

private _makeArcWaypoint = {
    params ["_targetATL", "_angle"];
    private _effectiveRadius =
        ((_cruiseHeight - (_targetATL # 2)) - _verticalDiveHeight) max _pitchRadius;
    private _alongOffset = -_effectiveRadius + (_effectiveRadius * cos _angle);
    private _waypoint = _targetATL vectorAdd (_approachDirection vectorMultiply _alongOffset);
    _waypoint set
    [
        2,
        (_targetATL # 2) + _verticalDiveHeight + (_effectiveRadius * sin _angle)
    ];
    _waypoint
};

_arcWaypointATL = [_initialGuidanceAimATL, _arcAngles # 0] call _makeArcWaypoint;
_missile setVariable ["fdelta_scalpelL_frozenAimpointATL", +_aimpointATL];
_missile setVariable
[
    "fdelta_scalpelL_loftWaypointsATL",
    [+_climbWaypointATL, +_arcWaypointATL, _pitchRadius, _verticalDiveHeight, +_arcAngles]
];
_missile setVariable ["fdelta_scalpelL_trackingTarget", _hardTarget];

private _climbComplete = !_useLoft;
private _verticalDive = !_useLoft;
private _terminalTarget = _hardTarget;
private _hardGuidance = !isNull _hardTarget;
private _handoffLogged = false;
private _crewOverrideCount = 0;
private _nativeHandoff = false;
private _handoffAttemptTarget = objNull;
private _handoffAttemptSince = -1;
private _preHandoffFailedTarget = objNull;
private _preHandoffFailedTargetUntil = 0;
private _preHandoffNextSeekerPoll = 0;

// No object target is retained during climb or pitch-over. This prevents
// native TopDown or an AI crew member's manual target from fighting the
// scripted arc. A full-lock object is still tracked continuously in script.
_missile setMissileTarget [objNull, true];
_missile setVariable
[
    "fdelta_scalpelL_guidanceMode",
    ["midcourse", "hard"] select _hardGuidance
];
_missile setVariable
[
    "fdelta_scalpelL_flightPhase",
    [
        ["direct", "climb"] select _useLoft,
        ["hard-direct", "hard-climb"] select _useLoft
    ] select _hardGuidance
];
if (_hardGuidance) then {
    _missile setVariable ["fdelta_scalpelL_terminalTarget", _hardTarget];
};

if (_useLoft) then {
    _missile setMissileTargetPos _climbWaypointATL;
}
else {
    if (_hardGuidance) then {
        _missile setMissileTarget [_hardTarget, true];
    }
    else {
        _missile setMissileTargetPos _initialGuidanceAimATL;
    };
};

if (missionNamespace getVariable ["fdelta_scalpelL_debug", false]) then {
    diag_log format
    [
        "fdelta_scalpelL_MIDCOURSE|missile=%1|source=%2|aimATL=%3|hard=%4|loft=%5|climbATL=%6|arcStartATL=%7|radius=%8|vertical=%9|selected=%10|lock=%11|state=%12",
        _missile,
        _source,
        _aimpointATL,
        _hardTarget,
        _useLoft,
        _climbWaypointATL,
        _arcWaypointATL,
        _pitchRadius,
        _verticalDiveHeight,
        _selectedTarget,
        _lockValue,
        missileState _missile
    ];
};

while {!isNull _missile && {local _missile} && {!_nativeHandoff}} do {
    private _positionATL = getPosATL _missile;

    // A destroyed identity cannot remain sticky in scripted midcourse. Return
    // immediately to the frozen area and let the same seeker choose again.
    if (!isNull _terminalTarget && {!alive _terminalTarget}) then {
        _preHandoffFailedTarget = _terminalTarget;
        _preHandoffFailedTargetUntil = diag_tickTime + 0.35;
        _terminalTarget = objNull;
        _hardGuidance = false;
        _handoffAttemptTarget = objNull;
        _handoffAttemptSince = -1;
        _missile setVariable ["fdelta_scalpelL_terminalTarget", objNull];
        _missile setVariable ["fdelta_scalpelL_trackingTarget", objNull];
        _missile setVariable ["fdelta_scalpelL_guidanceMode", "reacquiring"];
    };

    private _guidanceAimATL = +_aimpointATL;
    if (!isNull _terminalTarget) then {
        _guidanceAimATL = [_terminalTarget] call fdelta_fnc_scalpelLTargetPointATL;
    };
    private _distanceToAim2D = _positionATL distance2D _guidanceAimATL;

    if (
        isNull _terminalTarget &&
        {_distanceToAim2D <= _terminalRange} &&
        {diag_tickTime >= _preHandoffNextSeekerPoll}
    ) then {
        _preHandoffNextSeekerPoll = diag_tickTime + 0.05;
        private _preHandoffExcludedTarget = if
        (
            diag_tickTime < _preHandoffFailedTargetUntil
        ) then {
            _preHandoffFailedTarget
        }
        else {
            objNull
        };
        _terminalTarget =
        [
            _missile,
            _launcher,
            _instigator,
            _originalLaser,
            _terminalRange,
            _terminalCone,
            _aimpointATL,
            _preHandoffExcludedTarget
        ] call fdelta_fnc_scalpelLFindTerminalTarget;

        if (!isNull _terminalTarget) then {
            _handoffAttemptTarget = objNull;
            _handoffAttemptSince = -1;
            _missile setVariable ["fdelta_scalpelL_guidanceMode", "terminal"];
            _missile setVariable ["fdelta_scalpelL_terminalTarget", _terminalTarget];
            _missile setVariable ["fdelta_scalpelL_trackingTarget", _terminalTarget];
            _guidanceAimATL = [_terminalTarget] call fdelta_fnc_scalpelLTargetPointATL;
            _distanceToAim2D = _positionATL distance2D _guidanceAimATL;
        };
    };

    if (!_verticalDive) then {
        // Clear any target object that the engine or an AI crew member
        // reintroduced. Script-tracked hard and terminal targets live in
        // fdelta_scalpelL_trackingTarget until the missile is already pointed down.
        private _incidentalTarget = missileTarget _missile;
        if (!isNull _incidentalTarget) then {
            _crewOverrideCount = _crewOverrideCount + 1;
            _missile setVariable ["fdelta_scalpelL_crewOverrideCount", _crewOverrideCount];
            _missile setMissileTarget [objNull, true];
        };
    };

    if (!_climbComplete) then {
        private _travelFromLaunch = _positionATL vectorDiff _launchATL;
        private _horizontalProgress =
            ((_travelFromLaunch # 0) * (_approachDirection # 0)) +
            ((_travelFromLaunch # 1) * (_approachDirection # 1));
        private _crossTrack = abs
        (
            ((_travelFromLaunch # 0) * (-(_approachDirection # 1))) +
            ((_travelFromLaunch # 1) * (_approachDirection # 0))
        );
        private _flightVelocity = velocity _missile;
        private _horizontalSpeed = vectorMagnitude
        [
            _flightVelocity # 0,
            _flightVelocity # 1,
            0
        ];
        private _forwardAlignment = if (_horizontalSpeed > 1) then {
            (
                ((_flightVelocity # 0) * (_approachDirection # 0)) +
                ((_flightVelocity # 1) * (_approachDirection # 1))
            ) / _horizontalSpeed
        }
        else {
            1
        };
        private _altitudeReady =
            (_positionATL # 2) >= (_cruiseHeight - 30);
        private _profileCaptured =
            _crossTrack <= (_waypointTolerance * 1.5) &&
            {_forwardAlignment >= 0.5};
        private _climbWaypointClose =
            (_positionATL distance _climbWaypointATL) <=
            (_waypointTolerance * 2);

        // Inherited jet speed can carry the missile past the first climb
        // command before it reaches altitude. Advance that command along the
        // same profile line, but never into the reserved pitch-over arc.
        if (
            !_altitudeReady &&
            {_horizontalProgress >=
                (_climbCommandProgress - _waypointTolerance)} &&
            {_climbCommandProgress < _maximumClimbRun}
        ) then {
            private _climbLookAhead =
                ((_horizontalSpeed * 1.25) max 250) min 650;
            private _newClimbProgress =
                (_horizontalProgress + _climbLookAhead)
                min _maximumClimbRun;
            if (_newClimbProgress > (_climbCommandProgress + 10)) then {
                _climbCommandProgress = _newClimbProgress;
                _climbWaypointATL = _launchATL vectorAdd
                    (_approachDirection vectorMultiply _climbCommandProgress);
                _climbWaypointATL set [2, _cruiseHeight];
            };
        };

        _climbComplete =
            _altitudeReady &&
            {_profileCaptured} &&
            {
                _climbWaypointClose ||
                {_horizontalProgress >= (_climbCommandProgress * 0.85)}
            };
    };

    if (_verticalDive) then {
        if (!isNull _terminalTarget) then {
            if (missileTarget _missile isNotEqualTo _terminalTarget) then {
                if (_handoffAttemptTarget isNotEqualTo _terminalTarget) then {
                    _handoffAttemptTarget = _terminalTarget;
                    _handoffAttemptSince = diag_tickTime;
                };
                _nativeHandoff = _missile setMissileTarget [_terminalTarget, true];
                if (
                    !_nativeHandoff &&
                    {_handoffAttemptSince >= 0} &&
                    {(diag_tickTime - _handoffAttemptSince) >= 0.25}
                ) then {
                    private _rejectedTarget = _terminalTarget;
                    _preHandoffFailedTarget = _rejectedTarget;
                    _preHandoffFailedTargetUntil = diag_tickTime + 0.35;
                    _preHandoffNextSeekerPoll = diag_tickTime + 0.20;
                    _terminalTarget = objNull;
                    _hardGuidance = false;
                    _handoffAttemptTarget = objNull;
                    _handoffAttemptSince = -1;
                    _guidanceAimATL = +_aimpointATL;
                    _distanceToAim2D = _positionATL distance2D _guidanceAimATL;
                    _missile setVariable ["fdelta_scalpelL_terminalTarget", objNull];
                    _missile setVariable ["fdelta_scalpelL_trackingTarget", objNull];
                    _missile setVariable ["fdelta_scalpelL_guidanceMode", "reacquiring"];
                    _missile setMissileTarget [objNull, true];

                    if (missionNamespace getVariable ["fdelta_scalpelL_debug", false]) then {
                        diag_log format
                        [
                            "fdelta_scalpelL_PRE_HANDOFF_FAILED|missile=%1|target=%2|aimATL=%3|state=%4",
                            _missile,
                            _rejectedTarget,
                            _aimpointATL,
                            missileState _missile
                        ];
                    };
                };
            }
            else {
                _nativeHandoff = true;
            };
        }
        else {
            if (!isNull (missileTarget _missile)) then {
                _missile setMissileTarget [objNull, true];
            };
        };

        // Once an object handoff succeeds, stop issuing manual target
        // positions. Native homing can then use the target's velocity and the
        // inherited Scalpel lead logic instead of being forced to chase its
        // instantaneous position. Coordinate-only shots still require manual
        // guidance all the way to impact.
        if (!_nativeHandoff) then {
            _missile setMissileTargetPos _guidanceAimATL;
        }
        else {
            _missile setVariable ["fdelta_scalpelL_nativeHandoff", true];
        };

        private _divePhase = "coordinate-vertical-dive";
        if (_hardGuidance) then {
            _divePhase = "hard-vertical-dive";
        }
        else {
            if (!isNull _terminalTarget) then {_divePhase = "terminal-vertical-dive";};
        };
        _missile setVariable ["fdelta_scalpelL_flightPhase", _divePhase];

        if (!_handoffLogged) then {
            _handoffLogged = true;
            private _flightVelocity = velocity _missile;
            private _horizontalSpeed = vectorMagnitude
            [
                _flightVelocity # 0,
                _flightVelocity # 1,
                0
            ];
            private _downAngle =
                (-( _flightVelocity # 2)) atan2 (_horizontalSpeed max 0.001);
            private _handoffGeometry =
            [
                _distanceToAim2D,
                (_positionATL # 2) - (_guidanceAimATL # 2),
                _downAngle
            ];
            _missile setVariable ["fdelta_scalpelL_handoffGeometry", _handoffGeometry];
            if (missionNamespace getVariable ["fdelta_scalpelL_debug", false]) then {
                diag_log format
                [
                    "fdelta_scalpelL_TERMINAL|missile=%1|target=%2|geometry=%3|crewOverrides=%4|state=%5|aimATL=%6|ranking=%7",
                    _missile,
                    _terminalTarget,
                    _handoffGeometry,
                    _crewOverrideCount,
                    missileState _missile,
                    _aimpointATL,
                    _missile getVariable ["fdelta_scalpelL_lastSeekerRanking", []]
                ];
            };
        };
    }
    else {
        if (!_climbComplete) then {
            _missile setMissileTargetPos _climbWaypointATL;
            private _climbPhase = "climb";
            if (_hardGuidance) then {
                _climbPhase = "hard-climb";
            }
            else {
                if (!isNull _terminalTarget) then {_climbPhase = "terminal-climb";};
            };
            _missile setVariable ["fdelta_scalpelL_flightPhase", _climbPhase];
        }
        else {
            private _arcAngle = _arcAngles # _arcIndex;
            _arcWaypointATL = [_guidanceAimATL, _arcAngle] call _makeArcWaypoint;

            private _distanceToWaypoint = _positionATL distance _arcWaypointATL;
            private _waypointOffset = _arcWaypointATL vectorDiff _launchATL;
            private _positionOffset = _positionATL vectorDiff _launchATL;
            private _waypointProgress =
                ((_waypointOffset # 0) * (_approachDirection # 0)) +
                ((_waypointOffset # 1) * (_approachDirection # 1));
            private _positionProgress =
                ((_positionOffset # 0) * (_approachDirection # 0)) +
                ((_positionOffset # 1) * (_approachDirection # 1));
            private _waypointDelta =
                _positionATL vectorDiff _arcWaypointATL;
            private _waypointCrossTrack = abs
            (
                ((_waypointDelta # 0) * (-(_approachDirection # 1))) +
                ((_waypointDelta # 1) * (_approachDirection # 0))
            );
            private _arcVelocity = velocity _missile;
            private _arcHorizontalSpeed = vectorMagnitude
            [
                _arcVelocity # 0,
                _arcVelocity # 1,
                0
            ];
            private _arcForwardAlignment = if (_arcHorizontalSpeed > 1) then {
                (
                    ((_arcVelocity # 0) * (_approachDirection # 0)) +
                    ((_arcVelocity # 1) * (_approachDirection # 1))
                ) / _arcHorizontalSpeed
            }
            else {
                1
            };
            private _passedWaypoint =
                _positionProgress >= (_waypointProgress + _waypointTolerance) &&
                {_waypointCrossTrack <= (_waypointTolerance * 1.5)} &&
                {abs ((_positionATL # 2) - (_arcWaypointATL # 2)) <=
                    (_waypointTolerance * 1.5)} &&
                {_arcForwardAlignment >= 0.25};

            private _waypointSatisfied =
                _distanceToWaypoint <= (_waypointTolerance * 1.5) ||
                {_passedWaypoint};

            // The last circular gate is also the native-object handoff gate.
            // Do not advance on position alone while inherited jet momentum
            // still leaves the missile shy of the prescribed 75-degree dive.
            if (
                _waypointSatisfied &&
                {_arcIndex isEqualTo ((count _arcAngles) - 1)}
            ) then {
                private _arcDownAngle =
                    (-( _arcVelocity # 2)) atan2
                    (_arcHorizontalSpeed max 0.001);
                _waypointSatisfied =
                    (_arcVelocity # 2) < 0 &&
                    {_arcDownAngle >= 75} &&
                    {_distanceToAim2D <= 100};
            };

            if (_waypointSatisfied) then {
                _arcIndex = _arcIndex + 1;
                if (_arcIndex >= count _arcAngles) then {
                    _verticalDive = true;
                }
                else {
                    _arcAngle = _arcAngles # _arcIndex;
                    _arcWaypointATL = [_guidanceAimATL, _arcAngle] call _makeArcWaypoint;
                };
            };

            if (_verticalDive) then {
                // The next loop performs identity handoff at the vertical
                // gate. Issue the ground point now so the final arc tangent
                // continues downward without a one-frame guidance gap.
                _missile setMissileTargetPos _guidanceAimATL;
            }
            else {
                _missile setMissileTargetPos _arcWaypointATL;
                private _arcPhase = if (_arcIndex isEqualTo 0) then {
                    "apex-approach"
                }
                else {
                    format ["pitch-%1", _arcAngles # _arcIndex]
                };
                if (_hardGuidance) then {
                    _arcPhase = "hard-" + _arcPhase;
                }
                else {
                    if (!isNull _terminalTarget) then {
                        _arcPhase = "terminal-" + _arcPhase;
                    };
                };
                _missile setVariable ["fdelta_scalpelL_flightPhase", _arcPhase];
            };
        };
    };

    uiSleep 0.02;
};

// Native object homing owns velocity lead after the steep handoff, but the
// owner-local controller remains as a passive lock monitor. If Arma confirms
// that lock was lost, coordinate guidance carries the missile toward the
// immutable launch aimpoint while the same terminal seeker attempts recovery.
if (_nativeHandoff && {!isNull _missile} && {local _missile}) then {
    private _nativeTarget = _terminalTarget;
    private _nativeLockSeen = false;
    private _pendingSince = diag_tickTime;
    private _pendingWasReacquire = false;
    private _lossSince = -1;
    private _lockLossCount = 0;
    private _reacquireAttemptCount = 0;
    private _reacquireCount = 0;
    private _nextSeekerPoll = 0;
    private _failedTarget = objNull;
    private _failedTargetUntil = 0;
    _missile setVariable ["fdelta_scalpelL_lockLossCount", 0];
    _missile setVariable ["fdelta_scalpelL_reacquireAttemptCount", 0];
    _missile setVariable ["fdelta_scalpelL_reacquireCount", 0];
    _missile setVariable ["fdelta_scalpelL_nativeLockConfirmed", false];
    _missile setVariable ["fdelta_scalpelL_reacquireCandidate", objNull];
    _missile setVariable ["fdelta_scalpelL_reacquiredTarget", objNull];

    while {!isNull _missile && {local _missile}} do {
        if (_nativeHandoff) then {
            private _state = missileState _missile;
            private _guidanceState = toUpperANSI (_state param [1, ""]);
            private _identityRetained =
                !isNull _nativeTarget &&
                {alive _nativeTarget} &&
                {missileTarget _missile isEqualTo _nativeTarget};
            private _locked = _identityRetained && {_guidanceState isEqualTo "LOCKED"};

            if (_locked) then {
                _missile setVariable ["fdelta_scalpelL_nativeLockConfirmed", true];
                if (!_nativeLockSeen) then {
                    _nativeLockSeen = true;
                    if (_pendingWasReacquire) then {
                        _reacquireCount = _reacquireCount + 1;
                        _pendingWasReacquire = false;
                        _failedTarget = objNull;
                        _failedTargetUntil = 0;
                        _missile setVariable
                            ["fdelta_scalpelL_reacquireCount", _reacquireCount];
                        _missile setVariable
                            ["fdelta_scalpelL_reacquiredTarget", _nativeTarget];
                        _missile setVariable
                            ["fdelta_scalpelL_reacquireCandidate", objNull];
                        _missile setVariable
                            ["fdelta_scalpelL_guidanceMode", "terminal-reacquired"];
                        _missile setVariable
                            ["fdelta_scalpelL_flightPhase", "reacquired-native"];

                        if (missionNamespace getVariable ["fdelta_scalpelL_debug", false]) then {
                            diag_log format
                            [
                                "fdelta_scalpelL_REACQUIRED|missile=%1|target=%2|aimATL=%3|ranking=%4|state=%5|count=%6",
                                _missile,
                                _nativeTarget,
                                _aimpointATL,
                                _missile getVariable ["fdelta_scalpelL_lastSeekerRanking", []],
                                _state,
                                _reacquireCount
                            ];
                        };
                    };
                };
                _lossSince = -1;
            }
            else {
                _missile setVariable ["fdelta_scalpelL_nativeLockConfirmed", false];
                private _engineTarget = missileTarget _missile;
                private _invalidTarget =
                    isNull _nativeTarget ||
                    {!alive _nativeTarget} ||
                    {
                        !isNull _engineTarget &&
                        {_engineTarget isNotEqualTo _nativeTarget}
                    };
                private _fallbackNow = false;
                private _wasConfirmedLoss = _nativeLockSeen;

                if (!_nativeLockSeen) then {
                    // Assignment acceptance is not lock confirmation. Give a
                    // new handoff a short acquisition window, then fall back
                    // immediately rather than stacking the later loss grace.
                    _fallbackNow =
                        _invalidTarget ||
                        {(diag_tickTime - _pendingSince) >= 0.25};
                }
                else {
                    if (_invalidTarget) then {
                        // A dead target or a different attached identity is
                        // not a transient sensor mask.
                        _fallbackNow = true;
                    }
                    else {
                        if (_lossSince < 0) then {
                            _lossSince = diag_tickTime;
                        };
                        _fallbackNow =
                            (diag_tickTime - _lossSince) >= 0.12;
                    };
                };

                if (_fallbackNow) then {
                    private _lostTarget = _nativeTarget;
                    private _failedReacquire = _pendingWasReacquire;
                    private _failedAttemptCount = _reacquireAttemptCount;
                    if (_wasConfirmedLoss) then {
                        _lockLossCount = _lockLossCount + 1;
                        _missile setVariable ["fdelta_scalpelL_lockLossCount", _lockLossCount];
                    }
                    else {
                        // Do not immediately feed an accepted-but-unlockable
                        // identity back into native guidance. This leaves a
                        // real coordinate-guidance window and lets another
                        // aimpoint-ranked candidate be considered.
                        _failedTarget = _lostTarget;
                        _failedTargetUntil = diag_tickTime + 0.35;
                    };
                    _nativeHandoff = false;
                    _nativeTarget = objNull;
                    _terminalTarget = objNull;
                    _nativeLockSeen = false;
                    _pendingWasReacquire = false;
                    _lossSince = -1;
                    _missile setVariable ["fdelta_scalpelL_nativeHandoff", false];
                    _missile setVariable ["fdelta_scalpelL_lostTarget", _lostTarget];
                    _missile setVariable ["fdelta_scalpelL_trackingTarget", objNull];
                    _missile setVariable ["fdelta_scalpelL_terminalTarget", objNull];
                    _missile setVariable ["fdelta_scalpelL_nativeLockConfirmed", false];
                    _missile setVariable ["fdelta_scalpelL_reacquireCandidate", objNull];
                    _missile setVariable ["fdelta_scalpelL_reacquiredTarget", objNull];
                    _missile setVariable ["fdelta_scalpelL_guidanceMode", "reacquiring"];
                    _missile setVariable ["fdelta_scalpelL_flightPhase", "lock-lost-coordinate"];
                    _missile setMissileTarget [objNull, true];
                    _missile setMissileTargetPos _aimpointATL;
                    _nextSeekerPoll = if (_wasConfirmedLoss) then {
                        0
                    }
                    else {
                        // Even multiple alternating untrackable identities
                        // cannot starve coordinate fallback entirely.
                        diag_tickTime + 0.20
                    };

                    if (missionNamespace getVariable ["fdelta_scalpelL_debug", false]) then {
                        if (_wasConfirmedLoss) then {
                            diag_log format
                            [
                                "fdelta_scalpelL_LOCK_LOST|missile=%1|target=%2|aimATL=%3|state=%4|count=%5",
                                _missile,
                                _lostTarget,
                                _aimpointATL,
                                _state,
                                _lockLossCount
                            ];
                        }
                        else {
                            if (_failedReacquire) then {
                                diag_log format
                                [
                                    "fdelta_scalpelL_REACQUIRE_FAILED|missile=%1|target=%2|aimATL=%3|state=%4|attempt=%5",
                                    _missile,
                                    _lostTarget,
                                    _aimpointATL,
                                    _state,
                                    _failedAttemptCount
                                ];
                            }
                            else {
                                diag_log format
                                [
                                    "fdelta_scalpelL_HANDOFF_FAILED|missile=%1|target=%2|aimATL=%3|state=%4",
                                    _missile,
                                    _lostTarget,
                                    _aimpointATL,
                                    _state
                                ];
                            };
                        };
                    };
                };
            };
        }
        else {
            // Engine auto-seek or another crew member may attach an object
            // while recovery owns coordinate guidance. Keep it detached until
            // this controller explicitly accepts an aimpoint-ranked candidate.
            if (!isNull (missileTarget _missile)) then {
                _missile setMissileTarget [objNull, true];
            };

            // Polling at 20 Hz is sufficient for terminal recovery and avoids
            // rebuilding the candidate set on every simulation frame.
            if (diag_tickTime >= _nextSeekerPoll) then {
                _nextSeekerPoll = diag_tickTime + 0.05;
                private _cooldownTarget = if (diag_tickTime < _failedTargetUntil) then {
                    _failedTarget
                }
                else {
                    objNull
                };
                private _reacquiredTarget =
                [
                    _missile,
                    _launcher,
                    _instigator,
                    _originalLaser,
                    _terminalRange,
                    _terminalCone,
                    _aimpointATL,
                    _cooldownTarget
                ] call fdelta_fnc_scalpelLFindTerminalTarget;

                if (!isNull _reacquiredTarget) then {
                    private _accepted =
                        _missile setMissileTarget [_reacquiredTarget, true];
                    if (_accepted || {missileTarget _missile isEqualTo _reacquiredTarget}) then {
                        _reacquireAttemptCount = _reacquireAttemptCount + 1;
                        _nativeHandoff = true;
                        _nativeTarget = _reacquiredTarget;
                        _terminalTarget = _reacquiredTarget;
                        _nativeLockSeen = false;
                        _pendingWasReacquire = true;
                        _pendingSince = diag_tickTime;
                        _lossSince = -1;
                        _missile setVariable ["fdelta_scalpelL_nativeHandoff", true];
                        _missile setVariable ["fdelta_scalpelL_nativeLockConfirmed", false];
                        _missile setVariable ["fdelta_scalpelL_terminalTarget", _reacquiredTarget];
                        _missile setVariable ["fdelta_scalpelL_trackingTarget", _reacquiredTarget];
                        _missile setVariable
                            ["fdelta_scalpelL_reacquireCandidate", _reacquiredTarget];
                        _missile setVariable
                            ["fdelta_scalpelL_reacquireAttemptCount", _reacquireAttemptCount];
                        _missile setVariable ["fdelta_scalpelL_guidanceMode", "reacquire-pending"];
                        _missile setVariable
                            ["fdelta_scalpelL_flightPhase", "reacquire-pending-native"];

                        if (missionNamespace getVariable ["fdelta_scalpelL_debug", false]) then {
                            diag_log format
                            [
                                "fdelta_scalpelL_REACQUIRE_ATTEMPT|missile=%1|target=%2|aimATL=%3|ranking=%4|state=%5|attempt=%6",
                                _missile,
                                _reacquiredTarget,
                                _aimpointATL,
                                _missile getVariable ["fdelta_scalpelL_lastSeekerRanking", []],
                                missileState _missile,
                                _reacquireAttemptCount
                            ];
                        };
                    };
                };
            };

            if (!_nativeHandoff) then {
                _missile setMissileTargetPos _aimpointATL;
            };
        };

        uiSleep 0.02;
    };
};

if (!isNull _missile) then {
    if (!local _missile) then {
        _missile setVariable ["fdelta_scalpelL_guidanceMode", "locality-lost"];
    };
    _missile setVariable ["fdelta_scalpelL_controllerActive", false];
};
