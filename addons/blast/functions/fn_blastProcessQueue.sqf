/*
    Author: zobri

    Description:
        Serially processes validated blast payloads on the server.

    Returns:
        Nothing
*/
if (!isServer || {isRemoteExecuted}) exitWith {};

while {true} do {
    private _queue = localNamespace getVariable ["fdelta_blast_queue", []];
    if (_queue isEqualTo []) exitWith {};

    private _payload = _queue deleteAt 0;
    localNamespace setVariable ["fdelta_blast_queue", _queue];

    // Let native indirect damage finish before supplementing survivor trauma.
    uiSleep 0.05;
    _payload call fdelta_fnc_blastProcessBlast;
    uiSleep 0.001;
};

localNamespace setVariable ["fdelta_blast_workerRunning", false];

// Close the small race in which another validated report arrives as the loop empties.
if ((localNamespace getVariable ["fdelta_blast_queue", []]) isNotEqualTo []) then {
    localNamespace setVariable ["fdelta_blast_workerRunning", true];
    localNamespace setVariable [
        "fdelta_blast_damageWorkerHandle",
        [] spawn fdelta_fnc_blastProcessQueue
    ];
};
