/*
    Author: zobri

    Private active-LOITER resolver compiled into localNamespace during
    postInit. Authenticated server RPCs call it without exposing waypoint
    traversal as an unthrottled default-open CfgRemoteExec target.
*/
if !(
    _this isEqualType []
    && {count _this isEqualTo 1}
    && {(_this # 0) isEqualType objNull}
) exitWith {[]};
private _aircraft = _this # 0;

if (isNull _aircraft) exitWith {[]};

private _pilot = driver _aircraft;
if (isNull _pilot) exitWith {[]};

private _group = group _pilot;
if (isNull _group) exitWith {[]};

private _index = currentWaypoint _group;
private _allWaypoints = waypoints _group;
if (_index < 0 || {_index >= count _allWaypoints}) exitWith {[]};

private _waypoint = [_group, _index];
if (toUpper (waypointType _waypoint) isNotEqualTo "LOITER") exitWith {[]};

_waypoint
