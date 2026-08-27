class CfgPatches {
    class fdelta_ammo_rhsusaf {
        name = "420th Customizations - RHSUSAF Ammo Compatibility";
        author = "zobri";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.22;
        requiredAddons[] = {
            "fdelta_ammo",
            "fdelta_blast",
            "rhsusf_c_airweapons",
        };
        skipWhenMissingDependencies = 1;

        units[] = {};
        weapons[] = {};
    };
};

class CfgFdeltaBlastProfiles {
    class Bo_Mk82;

    // The exact-match BP registry does not follow CfgAmmo inheritance.
    class rhs_ammo_mk82 : Bo_Mk82 {};
};

class CfgAmmo {
    class Bo_Mk82;

    // RHS's Mk 82 is intentionally in the unitary-warhead pass. State the
    // complete policy here so it cannot become a hybrid of RHS damage and an
    // inherited fdelta radius when either project changes its base classes.
    class rhs_ammo_mk82 : Bo_Mk82 {
        hit = 5000;
        indirectHit = 3200;
        indirectHitRange = 16.25;
    };

    // RHS cluster carriers derive from its Mk 82. They are outside the UWR
    // pass and retain their pre-fdelta native blast values.
    class rhs_ammo_cbu_base : rhs_ammo_mk82 {
        hit = 5000;
        indirectHit = 1150;
        indirectHitRange = 12;
    };
};

class CfgMagazines {
    class 24Rnd_PG_missiles;

    // RHS DAGR ammunition has independent seeker tuning, so inheriting only
    // the vanilla magazine's 700 m/s lead gate creates a non-functional
    // hybrid. Preserve RHS's complete pre-fdelta policy in this scoped pass.
    class rhs_mag_DAGR_4 : 24Rnd_PG_missiles {
        maxLeadSpeed = 41.6667;
    };
};
