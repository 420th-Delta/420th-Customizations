/*
    Author: zobri

    Description:
        Serially processes validated blast payloads on the server.

    Returns:
        Nothing
*/
if (!isServer || {isRemoteExecuted}) exitWith {};

while {true} do {
    private _queue = missionNamespace getVariable ["fdelta_blast_queue", []];
    if (_queue isEqualTo []) exitWith {};

    private _payload = _queue deleteAt 0;
    missionNamespace setVariable ["fdelta_blast_queue", _queue];

    // Let native indirect damage finish before supplementing survivor trauma.
    uiSleep 0.05;
    _payload call fdelta_fnc_blastProcessBlast;
    uiSleep 0.001;
};

missionNamespace setVariable ["fdelta_blast_workerRunning", false];

// Close the small race in which another validated report arrives as the loop empties.
if ((missionNamespace getVariable ["fdelta_blast_queue", []]) isNotEqualTo []) then {
    missionNamespace setVariable ["fdelta_blast_workerRunning", true];
    [] spawn fdelta_fnc_blastProcessQueue;
};
