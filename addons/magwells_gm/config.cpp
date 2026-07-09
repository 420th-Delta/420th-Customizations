class CfgPatches {
    class fdelta_magwells_gm {
        name = "420th Customizations - Global Mobilization Weapons Compatibility";
        author = "ol1034, thegamecracks";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.20;
        requiredAddons[] = {
            "fdelta_main",
            "gm_weapons_rifles_g11",
            "gm_weapons_rifles_hk33",
            "gm_weapons_rifles_sg550",
            "gm_weapons_machineguns_g8",
            "gm_weapons_sniperrifles_psg1",
        };
        skipWhenMissingDependencies = 1;
        skipWhenAnyAddonPresent[] = {"vmagcompatibility"};

        units[] = {};
    };
};

#define MAGAZINES_556x45 \
    "30Rnd_556x45_Stanag", \
    "30Rnd_556x45_Stanag_green", \
    "30Rnd_556x45_Stanag_red", \
    "30Rnd_556x45_Stanag_Tracer_Red", \
    "30Rnd_556x45_Stanag_Tracer_Green", \
    "30Rnd_556x45_Stanag_Tracer_Yellow", \
    "30Rnd_556x45_Stanag_Sand", \
    "30Rnd_556x45_Stanag_Sand_green", \
    "30Rnd_556x45_Stanag_Sand_red", \
    "30Rnd_556x45_Stanag_Sand_Tracer_Red", \
    "30Rnd_556x45_Stanag_Sand_Tracer_Green", \
    "30Rnd_556x45_Stanag_Sand_Tracer_Yellow", \
    "150Rnd_556x45_Drum_Green_Mag_F", \
    "150Rnd_556x45_Drum_Green_Mag_Tracer_F", \
    "150Rnd_556x45_Drum_Sand_Mag_F", \
    "150Rnd_556x45_Drum_Sand_Mag_Tracer_F", \
    "150Rnd_556x45_Drum_Mag_F", \
    "150Rnd_556x45_Drum_Mag_Tracer_F",

class CfgMagazineWells {
    class gm_magazineWell_473x33mm_g11 {
        fdelta_magwells_gm_magazines[] = {
            "30Rnd_65x39_caseless_green_mag_Tracer",
            "30Rnd_65x39_caseless_green",
        };
    };
    class gm_magazineWell_556x45mm_hk33 {
        fdelta_magwells_gm_magazines[] = {
            MAGAZINES_556x45
        };
    };
    class gm_magazineWell_556x45mm_sg550 {
        fdelta_magwells_gm_magazines[] = {
            MAGAZINES_556x45
        };
    };
    class gm_magazineWell_762x51mm_mg8 {
        fdelta_magwells_gm_magazines[] = {
            "150Rnd_762x51_Box",
            "150Rnd_762x51_Box_Tracer",
            "150Rnd_762x54_Box",
            "150Rnd_762x54_Box_Tracer",
        };
    };
    class gm_magazineWell_762x51mm_sg542 {
        fdelta_magwells_gm_magazines[] = {
            "10Rnd_Mk14_762x51_Mag",
            "20Rnd_762x51_Mag",
        };
    };
    class gm_magazineWell_762x51mm_g3 {
        fdelta_magwells_gm_magazines[] = {
            "10Rnd_Mk14_762x51_Mag",
            "20Rnd_762x51_Mag",
        };
    };
};
