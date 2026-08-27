if (!isServer) exitWith {};

params [["_info", [], [[]]]];
if (isNil "fdelta_test_nodes") then {fdelta_test_nodes = createHashMap};

private _claimedOwner = _info param [0, -1, [0]];
// CfgFunctions dispatch can clear isRemoteExecuted before this wrapper runs on
// some dedicated builds. Preserve the caller's clientOwner from the payload;
// prefer remoteExecutedOwner whenever the engine exposes a real client ID.
private _remoteOwner = remoteExecutedOwner;
private _actualOwner = if (_remoteOwner > 2) then {
    _remoteOwner
} else {
    _claimedOwner
};
private _record = +_info;
_record set [0, _actualOwner];
fdelta_test_nodes set [str _actualOwner, _record];

[
    "NODE_REGISTERED",
    [_actualOwner, _claimedOwner, _remoteOwner, isRemoteExecuted, _record]
] call fdelta_test_fnc_log;


