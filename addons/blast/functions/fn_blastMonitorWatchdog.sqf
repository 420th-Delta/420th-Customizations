/*
    Author: zobri

    Description:
        Minimal server-local watchdog for the projectile-registry monitor. This
        code is compiled privately during preInit and is not a CfgRemoteExec
        addressable function.

    Returns:
        Nothing
*/
if (!isServer || {isRemoteExecuted}) exitWith {};

while {true} do {
    uiSleep 1;

    private _monitorHandle = localNamespace getVariable [
        "fdelta_blast_registryMonitorHandle",
        scriptNull
    ];
    if (scriptDone _monitorHandle) then {
        localNamespace setVariable [
            "fdelta_blast_registryMonitorHandle",
            [] spawn fdelta_fnc_blastMonitorRegistry
        ];
    };
};
