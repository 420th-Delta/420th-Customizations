#define FNC(var1) A3TI_fnc_##var1

//#define DEFAULT_VIEWMODE [1,"1stPerson"]
//#define DEFAULT_VISIONMODE [0,"DTV",[0]]
//#define DEFAULT_VISIONMODE [0,"D-TV B/W"]
#define DEFAULT_VISIONMODE -1
/*#define DEFAULT_APERTURE [-1,-1,-1,-1]
#define DEFAULT_TIINCR [0,0,0]
 // BRT, CNT, APR // zero increment offset values*/

 //gain,brightness,contrast
#define GAIN_MAX 5
#define GAIN_MIN 0
#define BRT_MAX 5
#define BRT_MIN -5
#define CNT_MAX 2
#define CNT_MIN -5

#define DEFAULT_DAYINCR 0
 //GAIN
#define DEFAULT_TIINCR [0,0]

#define DEFAULT_LLTVTIINCR [0,-3]

#define DEFAULT_DAYPP_SETTINGS [0,1.2,0,0]
 //BRT, CNT, ALPHA, GRAIN // DTV settings
#define DEFAULT_TIPP_SETTINGS [1.16,0.62,0,0]
 //BRT, CNT, ALPHA, GRAIN // THERMAL settings
#define DEFAULT_LLTVTIPP_SETTINGS [0.75,0.6,0,0]
 //BRT, CNT, ALPHA, GRAIN // THERMAL LLTV settings

#define DEFAULT_FLIR_ENABLED 0

//for second sun default settings
#define DEFAULT_ADJUSTCOLOUR [0.5,0.5,0.5]
#define DEFAULT_ADJUSTBRIGHTNESS 0

//vanilla definitions for vision modes
#define VANILLA_DTV 0
#define VANILLA_NV 1
#define VANILLA_TI 2

//NV FUSION ADD VISIONS
#define FUSION_VISIONMODES [-2,-3]

//DEFAULT RVMAT IF NONE AVAILABLE
#define DEFAULT_RVMAT_NIL "\a3\data_f\default.rvmat"
#define DEFAULT_RVMAT_FUSION "a3ti\data\EmissiveWhite.rvmat"

//second sun definitions
#define DEFAULT_SECONDSUN_BRIGHTNESS 13
#define DEFAULT_DIETSUN_BRIGHTNESS 0.8

//LTM
#define LTM_MODE_BLINK 0
#define LTM_MODE_STEADY 1
#define LTM_BLINK_INTERVAL 0.3

//aperture
#define APERTURE_SETTINGS [-1,15,25]
#define APERTURE_DEFAULT 15

//global namespace used throughout project, all variables are technically local according to setVariable
#define UNAMESPACE missionNamespace
