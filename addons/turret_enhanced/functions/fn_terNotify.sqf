/*
    Author: zobri

    Displays a server-authorized Turret Enhanced status message on a client.
*/
if (
    isRemoteExecuted
    && {remoteExecutedOwner isNotEqualTo 2}
) exitWith {false};
if !(_this isEqualType [] && {count _this isEqualTo 2}) exitWith {false};
if !(
    (_this # 0) isEqualType ""
    && {(_this # 1) isEqualType []}
) exitWith {false};
private _messageKey = _this # 0;
private _arguments = _this # 1;

if (!hasInterface || {_messageKey isEqualTo ""}) exitWith {false};

private _message = localize _messageKey;
if (_arguments isNotEqualTo []) then {
    _message = format ([_message] + _arguments);
};
systemChat _message;
true
