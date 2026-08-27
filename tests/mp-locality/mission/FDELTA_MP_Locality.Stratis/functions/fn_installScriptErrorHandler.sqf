private _existingHandler = missionNamespace getVariable [
    "fdelta_test_scriptErrorHandler",
    -1
];
if (_existingHandler isEqualType 0 && {_existingHandler >= 0}) exitWith {
    _existingHandler
};

missionNamespace setVariable ["fdelta_test_scriptErrors", []];
private _scriptErrorHandler = addMissionEventHandler ["ScriptError", {
    private _record = [
        _this param [0, "", [""]],
        _this param [1, "", [""]],
        _this param [2, -1, [0]],
        _this param [3, -1, [0]],
        _this param [5, [], [[]]]
    ];
    private _errors = missionNamespace getVariable [
        "fdelta_test_scriptErrors",
        []
    ];
    _errors pushBack _record;
    missionNamespace setVariable ["fdelta_test_scriptErrors", _errors];
    diag_log format [
        "FDELTA_MPLOC_SCRIPT_ERROR|owner=%1|server=%2|interface=%3|data=%4",
        clientOwner,
        isServer,
        hasInterface,
        _record
    ];
}];
missionNamespace setVariable [
    "fdelta_test_scriptErrorHandler",
    _scriptErrorHandler
];

_scriptErrorHandler
