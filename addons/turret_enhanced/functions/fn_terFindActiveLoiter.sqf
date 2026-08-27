/*
    Author: zobri

    Returns the aircraft pilot group's active LOITER waypoint or an empty array.
*/
params [["_aircraft", objNull, [objNull]]];

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
