/*
    Author: zobri

    Returns the aircraft pilot group's active LOITER waypoint or an empty array.
*/
if (isRemoteExecuted) exitWith {[]};
_this call (localNamespace getVariable [
    "fdelta_ter_resolveActiveLoiter",
    {[]}
])
