/*
    Author: zobri

    Displays a server-authorized Turret Enhanced status message on a client.
*/
params [["_message", "", [""]]];

if (
    isMultiplayer
    && {isRemoteExecuted}
    && {remoteExecutedOwner isNotEqualTo 2}
) exitWith {false};
if (!hasInterface || {_message isEqualTo ""}) exitWith {false};

systemChat _message;
true
