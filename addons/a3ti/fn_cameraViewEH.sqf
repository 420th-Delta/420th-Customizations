/*
    Author: Lala14, Pingopete, thegamecracks

    Description:
    For when the player cycles been vision modes, attempts to check if player
    has access to said vision mode when aiming and removes when no longer in sight

    Parameter(s):
    NONE

    Returns:
    NIL
*/
#include "constants.h"
isNil {
/*_curPlayerTurret = call FNC(getPlayerTurret);
_visions = [];
if (!isNull _curPlayerTurret) then {
    _visions = _curPlayerTurret call FNC(getAvailVisions);
};*/

//Force disable TI stuff if player switches to another unit
/*switch (_this) do
{
    //this case only occurs when zeus is taking control of a unit
    case "unit_switched":
    {
        ace_common_oldIsCamera = false;
        call FNC(disablePPeffects);
        call FNC(destroySecondSun);
        ["OFF"] call FNC(setObjects);
    };
};*/


if (
    cameraView isNotEqualTo "GUNNER"
    || {isNull objectParent player && {!unitIsUAV cameraOn}}
    || {_this isEqualTo "unit_switched"}
) then {
    //disable PP
    ace_common_oldIsCamera = false;
    call FNC(disablePPeffects);
    call FNC(destroySecondSun);
    ["OFF"] call FNC(setObjects);
} else {
    //enable PP
    //this allows for when switching views from 3rd/1st to gunner to retain vision
    //however, once the vehicle detected is not the same as what you were in
    //we need to reset, still need to fix UAV switching
    _unitVehToCheckVision = vehicle(call FNC(getCurrentControlledUnit));
    _storedUnitVeh = (UNAMESPACE getVariable ["A3TI_FLIR_currentUnitVeh", _unitVehToCheckVision]);
    if (_unitVehToCheckVision isEqualTo _storedUnitVeh) then {
        call FNC(ppEffects);
    } else {
        call FNC(cycleVision);
    };
};

null = [] spawn FNC(pfhLTM);
};
