/*
    Author: zobri

    Description:
        Dispatches authenticated explosion reports from a server-local worker.
        This prevents remote-execution context from propagating into the
        asynchronous validator while retaining its direct-remote-call guard.
        Concurrency is bounded so a large burst cannot create hundreds of
        polling scripts at once.

    Returns:
        Nothing
*/
if (!isServer || {isRemoteExecuted}) exitWith {};

localNamespace setVariable ["fdelta_blast_validationWorkerRunning", true];
private _active = [];

while {true} do {
    _active = _active select {!(scriptDone _x)};

    private _queue = localNamespace getVariable [
        "fdelta_blast_validationQueue",
        []
    ];
    private _settings = localNamespace getVariable [
        "fdelta_blast_settings",
        createHashMap
    ];
    private _limit = floor ((
        _settings getOrDefault [
            "fdelta_blast_maxConcurrentValidations",
            32
        ]
    ) max 1 min 128);
    private _slots = (_limit - count _active) max 0;
    private _toStart = _slots min count _queue;

    if (_toStart > 0) then {
        for "_index" from 1 to _toStart do {
            private _task = _queue deleteAt 0;
            if (_task isEqualType [] && {count _task >= 6}) then {
                _active pushBack (
                    _task spawn fdelta_fnc_blastValidateReport
                );
            };
        };
        localNamespace setVariable [
            "fdelta_blast_validationQueue",
            _queue
        ];
    };

    localNamespace setVariable [
        "fdelta_blast_activeValidationCount",
        count _active
    ];
    uiSleep 0.01;
};
