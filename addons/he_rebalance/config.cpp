#define FDELTA_MK82_INDIRECT_HIT 3200
#define FDELTA_MK82_INDIRECT_RANGE 16.25
#define FDELTA_SMALL_HEFRAG_INDIRECT_HIT 35
#define FDELTA_SMALL_HEFRAG_INDIRECT_RANGE 20

class CfgPatches {
    class fdelta_he_rebalance {
        name = "420th Customizations - Vanilla Warhead Rebalance";
        author = "Seathre0420, zobri";
        url = "https://github.com/thegamecracks/420th-Customizations";

        requiredVersion = 2.22;
        requiredAddons[] = {
            "A3_Data_F_Decade_Loadorder",
            "fdelta_main",
        };
        skipWhenMissingDependencies = 0;

        units[] = {};
    };
};

class CfgAmmo {
    class ammo_Bomb_LaserGuidedBase;
    class ammo_Bomb_SmallDiameterBase;
    class ammo_Missile_AntiRadiationBase;
    class ammo_Missile_CruiseBase;
    class BombCore;
    class M_PG_AT;
    class MissileBase;
    class RocketBase;
    class ShellBase;

    // Vanilla warhead rebalance
    //
    // indirectHit is an Arma damage coefficient, not a weight of explosive.
    // These values provide the concentrated native core used with the
    // cover-aware Blast Propagation addon in 420th-Enhancements. Native splash
    // ends at roughly 4x indirectHitRange; the scripted infantry-only profile
    // takes over at that handoff. Keeping the native core short also avoids
    // extending Arma's armor-bypassing radial damage through the outer zone.
    //
    // Public warhead statistics below are sanity checks for relative scale,
    // not a claim that kilograms or pounds convert directly to indirectHit.

    // 500 lb Mk 82 / GBU-12 family. USAF Maritime WSEP data lists 192 lb
    // net explosive weight. This is the empirical gameplay anchor: controlled
    // Arma tests put a protected CSAT Viper down near the 65 m native handoff.
    class Bo_Mk82 : BombCore {
        indirectHit = FDELTA_MK82_INDIRECT_HIT; // 1100
        indirectHitRange = FDELTA_MK82_INDIRECT_RANGE; // 12
    };

    class Bomb_04_F : ammo_Bomb_LaserGuidedBase {
        indirectHit = FDELTA_MK82_INDIRECT_HIT; // 1100
        indirectHitRange = FDELTA_MK82_INDIRECT_RANGE; // 12
    };

    // The fictional 565 lb LOM-250G is bracketed against the KAB-250LG-E.
    // Rosoboronexport lists that 256 kg bomb with a 165 kg HE-fragmentation
    // warhead. Its profile is only modestly above the Mk 82 gameplay anchor.
    class Bomb_03_F : ammo_Bomb_LaserGuidedBase {
        indirectHit = FDELTA_MK82_INDIRECT_HIT + 400; // 1400
        indirectHitRange = FDELTA_MK82_INDIRECT_RANGE + 2.5; // 16
    };

    // GBU-39/B SDB I is a multipurpose penetrating blast-fragmentation weapon.
    // USAF/Boeing data gives 36 lb explosive fill out of a 205 lb warhead.
    class ammo_Bomb_SDB : ammo_Bomb_SmallDiameterBase {
        indirectHit = 100; // 85
        indirectHitRange = 25; // 3
    };

    // M795 is the public 155 mm HE analogue: the U.S. Army lists a 23.8 lb
    // TNT/IMX-101 fill in a high-fragmentation steel body and describes its
    // point-detonating effect as most lethal within 25 m. Charge scaling from
    // the Mk 82 anchor gives about 32 m, rounded to a 35 m handoff. Although
    // 3600 looks large alone, pairing it with 8.75 m makes this curve stronger
    // than vanilla only inside about 20 m, weaker beyond, and zero after 35 m
    // instead of 120 m. Blast Propagation owns the cover-aware 35-125 m zone.
    class Sh_155mm_AMOS : ShellBase {
        indirectHit = 3600; // 125
        indirectHitRange = 8.75; // 30
    };

    // The closest public analogue is the 227 mm M31 GMLRS round.
    // GD-OTS lists a 195 lb scored-steel warhead with 51 lb PBXN-109; its
    // fragmentation construction, not just explosive fill, drives effects.
    // The Mk 82 profile is therefore a gameplay baseline, not an equal-yield
    // claim. The new curve crosses vanilla near 23 m, is weaker after that,
    // and ends at 65 m rather than 120 m before BP continues to 250 m.
    // Patch only the ground-impact terminal leaf; cluster and latent
    // anti-armor leaves use different terminal classes and remain untouched.
    class R_230mm_fly : ShellBase {
        indirectHit = 3200; // 800
        indirectHitRange = 16.25; // 30
    };

    // Mk41 VLS cruise missile, bracketed against Tomahawk Block IV.
    // The U.S. Navy lists a 1,000 lb-class warhead. The 7000 coefficient
    // is about 2.2x the Mk 82 anchor while retaining vanilla's 120 m cutoff;
    // it models the inner core rather than equating warhead mass to damage.
    // Raising indirectHitRange to 50 would push armor-bypassing native splash
    // to 200 m and overlap the BP profile that owns the 120-400 m outer zone.
    // The cluster child is explicitly pinned to its vanilla damage triplet.
    class ammo_Missile_Cruise_01 : ammo_Missile_CruiseBase {
        indirectHit = 7000; // 2000
        indirectHitRange = 30; // 30
    };
    class ammo_Missile_Cruise_01_Cluster : ammo_Missile_Cruise_01 {
        hit = 6000;
        indirectHit = 2000;
        indirectHitRange = 30;
    };

    // The destroyer cannon shares the conventional artillery parent but is not
    // part of this pass. Pin its unguided splash to vanilla.
    class ammo_ShipCannon_120mm_HE : Sh_155mm_AMOS {
        indirectHit = 125;
        indirectHitRange = 30;
    };

    // Fictional 70-80 mm HE rockets are bracketed against the M151 Hydra-70.
    // U.S. Army data describes its 10 lb warhead as producing thousands
    // of high-velocity fragments.
    class Rocket_04_HE_F : MissileBase {
        indirectHit = FDELTA_SMALL_HEFRAG_INDIRECT_HIT; // 55
        indirectHitRange = FDELTA_SMALL_HEFRAG_INDIRECT_RANGE; // 15
    };

    class Rocket_03_HE_F : Rocket_04_HE_F {
        indirectHit = FDELTA_SMALL_HEFRAG_INDIRECT_HIT; // 55
        indirectHitRange = FDELTA_SMALL_HEFRAG_INDIRECT_RANGE; // 15
    };

    class R_80mm_HE : RocketBase {
        indirectHit = FDELTA_SMALL_HEFRAG_INDIRECT_HIT; // 60
        indirectHitRange = FDELTA_SMALL_HEFRAG_INDIRECT_RANGE; // 15
    };

    // DAR inherits from DAGR but should receive similar effectiveness
    // as the other HE-fragmentation rockets.
    class M_AT : M_PG_AT {
        indirectHit = FDELTA_SMALL_HEFRAG_INDIRECT_HIT; // 50
        indirectHitRange = FDELTA_SMALL_HEFRAG_INDIRECT_RANGE; // 8
    };

    // Equivalant to the AGM-88C with a 68 kg (150 lb) warhead.
    class ammo_Missile_HARM : ammo_Missile_AntiRadiationBase {
        indirectHit = 1200; // 85
        indirectHitRange = 7.5; // 8
    };

    // Equivalant to the Kh-58UShKE with a 149 kg (328 lb) warhead.
    class ammo_Missile_KH58 : ammo_Missile_AntiRadiationBase {
        indirectHit = 2600; // 85
        indirectHitRange = 16; // 8
    };

    // BombCluster_01 and its descendants inherit from Bomb_04_F. Pin the
    // carrier blast to vanilla so changing GBU-12 cannot buff cluster bombs.
    class BombCluster_01_Ammo_F : Bomb_04_F {
        hit = 5000;
        indirectHit = 1100;
        indirectHitRange = 12;
    };

    // The AP rocket leaves inherit from the patched HE family. Re-state their
    // vanilla values so their penetrator/HEAT balance remains untouched.
    class Rocket_04_AP_F : Rocket_04_HE_F {
        hit = 95;
        indirectHit = 25;
        indirectHitRange = 2.5;
    };

    class Rocket_03_AP_F : Rocket_04_AP_F {
        hit = 95;
        indirectHit = 25;
        indirectHitRange = 3;
    };
};
