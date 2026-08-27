if (!isServer) exitWith {};

params [
    ["_case", "", [""]],
    ["_phase", "", [""]],
    ["_data", [], [[]]]
];

if (isNil "fdelta_test_phases") then {fdelta_test_phases = createHashMap};
private _sender = if (isRemoteExecuted) then {remoteExecutedOwner} else {clientOwner};
private _key = format ["%1|%2", _case, _phase];
fdelta_test_phases set [_key, [_sender, serverTime, _data]];

["CLIENT_PHASE", [_case, _phase, _sender, _data]] call fdelta_test_fnc_log;


