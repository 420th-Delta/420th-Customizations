/*
    Author: zobri

    Creates a globally styled channel marker at the center-camera aim point.
*/
if (isRemoteExecuted) exitWith {""};

params [["_requestedColor", "", [""]]];

private _point = call fdelta_fnc_terAimPoint;
if (_point isEqualTo []) exitWith {
    systemChat localize "STR_FDELTA_TER_MSG_NO_CAMERA_INTERSECTION";
    ""
};

private _color = _requestedColor;
if (_color isEqualTo "") then {
    _color = switch (side group player) do {
        case west: {"ColorWEST"};
        case east: {"ColorEAST"};
        case independent: {"ColorGUER"};
        case civilian: {"ColorCIV"};
        default {"ColorYellow"};
    };
};

private _counter = (missionNamespace getVariable ["fdelta_terMarkerCounter", 0]) + 1;
missionNamespace setVariable ["fdelta_terMarkerCounter", _counter];

private _channel = currentChannel;
if (_channel in [-1, 5, 16]) then {
    _channel = 1;
};

private _markerName = format ["_USER_DEFINED #%1/%2/%3", clientOwner, _counter, _channel];
private _label = format [localize "STR_FDELTA_TER_MARKER_LABEL", _counter];
private _marker = createMarker [_markerName, _point, _channel, player];
if (_marker isEqualTo "") exitWith {
    systemChat localize "STR_FDELTA_TER_MSG_MARKER_FAILED";
    ""
};

// The final global update broadcasts the complete marker state once.
_marker setMarkerShapeLocal "ICON";
_marker setMarkerColorLocal _color;
_marker setMarkerSizeLocal [0.7, 0.7];
_marker setMarkerTextLocal _label;
_marker setMarkerType "mil_dot";

systemChat format [
    localize "STR_FDELTA_TER_MSG_MARKED_FORMAT",
    _label,
    mapGridPosition _point
];
_marker
