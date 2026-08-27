/*
    Author: zobri

    Description:
        Resolves whether a server-observed network owner belongs to a connected
        Headless Client. Arma hides HC remote-execution identity, so callers
        must still bind this result to trusted projectile-registry evidence.

    Parameters:
        0: Network owner ID <NUMBER>

    Returns:
        Whether the owner is a connected Headless Client <BOOL>
*/
if (!isServer) exitWith {false};

params [["_ownerId", -1, [0]]];
if (_ownerId <= 2) exitWith {false};

private _matched = false;
{
    private _info = getUserInfo _x;
    if (
        _info isEqualType []
        && {count _info > 7}
        && {(_info # 1) isEqualType 0}
        && {(_info # 7) isEqualType true}
        && {(_info # 1) isEqualTo _ownerId}
        && {_info # 7}
    ) exitWith {
        _matched = true;
    };
} forEach allUsers;

_matched
