params [
    ["_event", "UNKNOWN", [""]],
    ["_data", [], [[]]]
];
private _role = if (isServer) then {
    if (isDedicated) then {"DEDICATED_SERVER"} else {"LISTEN_SERVER"};
} else {
    if (hasInterface) then {"INTERFACE_CLIENT"} else {"HEADLESS_CLIENT"};
};

diag_log format [
    "FDELTA_MPLOC|owner=%1|role=%2|profile=%3|event=%4|data=%5",
    clientOwner,
    _role,
    profileName,
    _event,
    _data
];
