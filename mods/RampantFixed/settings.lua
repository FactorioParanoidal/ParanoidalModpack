data:extend({
        {
            type = "bool-setting",
            name = "rampantFixed--allowExternalControl",
            description = "rampantFixed--allowExternalControl",
            setting_type = "startup",
            default_value = false,
            order = "a[modifier]-a0[remote]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--useDumbProjectiles",
            description = "rampantFixed--useDumbProjectiles",
            setting_type = "startup",
            default_value = true,
            order = "a[modifier]-a1[projectiles]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--disableCollidingProjectiles",
            setting_type = "startup",
            default_value = true,
            order = "b[modifier]-b1[trigger]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--useBlockableSteamAttacks",
            setting_type = "startup",
            default_value = false,
            order = "b[modifier]-b2[trigger]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--oldRedEnemyMapColor",
            setting_type = "startup",
            default_value = false,
            order = "b[modifier]-c[trigger]",
            per_user = false
        },

        {
            type = "int-setting",
            name = "rampantFixed--attackWaveMaxSize",
            setting_type = "runtime-global",
            minimum_value = 20,
            maximum_value = 600,
            default_value = 75,
            order = "b[modifier]-f[wave]",
            per_user = false
        },

        {
            type = "int-setting",
            name = "rampantFixed--attackWaveMaxSizeEvoPercent",
            setting_type = "runtime-global",
            minimum_value = 5,
            maximum_value = 100,
            default_value = 100,
            order = "b[modifier]-f[wave]",
            per_user = false
        },
		
        {
            type = "bool-setting",
            name = "rampantFixed--agressiveStart",
            setting_type = "runtime-global",
            default_value = false,
            order = "b[modifier]-f[wave]",
            per_user = false
        },

        {
            type = "int-setting",
            name = "rampantFixed--maxNumberOfSquads",
            setting_type = "runtime-global",
            minimum_value = 1,
            maximum_value = 30,
            default_value = 30,
            order = "b[modifier]-f[wave]",
            per_user = false
        },

        {
            type = "int-setting",
            name = "rampantFixed--maxNumberOfBuilders",
            setting_type = "runtime-global",
            minimum_value = 1,
            maximum_value = 120,
            default_value = 35,
            order = "b[modifier]-f[wave]",
            per_user = false
        },

        {
            type = "int-setting",
            name = "rampantFixed--unitAndSpawnerFadeTime",
            setting_type = "startup",
            minimum_value = 1,
            maximum_value = 30000000 * 60,
            default_value = 5 * 60,
            order = "b[modifier]-f[wave]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--enableFadeTime",
            setting_type = "startup",
            default_value = true,
            order = "b[modifier]-f[wave]",
            per_user = false
        },

        -- {
        --     type = "bool-setting",
        --     name = "rampantFixed--liteMode",
        --     setting_type = "startup",
        --     default_value = false,
        --     order = "b[modifier]-g[ai]",
        --     per_user = false
        -- },

        {
            type = "bool-setting",
            name = "rampantFixed--enableSwarm",
            description = "rampantFixed--enableSwarm",
            setting_type = "startup",
            default_value = true,
            order = "b[modifier]-j[unit]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--enableShrinkNestsAndWorms",
            description = "rampantFixed--enableShrinkNestsAndWorms",
            setting_type = "startup",
            default_value = true,
            order = "b[modifier]-j[unit]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--safeBuildings",
            setting_type = "runtime-global",
            default_value = false,
            order = "c[modifier]-a[safe]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--safeBuildings-curvedRail",
            setting_type = "runtime-global",
            default_value = false,
            order = "c[modifier]-b[safe]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--safeBuildings-straightRail",
            setting_type = "runtime-global",
            default_value = false,
            order = "c[modifier]-c[safe]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--safeBuildings-bigElectricPole",
            setting_type = "runtime-global",
            default_value = false,
            order = "c[modifier]-d[safe]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--safeBuildings-railSignals",
            setting_type = "runtime-global",
            default_value = false,
            order = "c[modifier]-e[safe]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--safeBuildings-railChainSignals",
            setting_type = "runtime-global",
            default_value = false,
            order = "c[modifier]-f[safe]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--safeBuildings-trainStops",
            setting_type = "runtime-global",
            default_value = false,
            order = "c[modifier]-g[safe]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--safeBuildings-lamps",
            setting_type = "runtime-global",
            default_value = false,
            order = "c[modifier]-h[safe]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--addWallResistanceAcid",
            description = "rampantFixed--addWallResistanceAcid",
            setting_type = "startup",
            default_value = false,
            order = "c[modifier]-j[damage]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--newEnemies",
            description = "rampantFixed--newEnemies",
            setting_type = "startup",
            default_value = true,
            order = "e[modifier]-a[unit]",
            per_user = false
        },
		
        {
            type = "bool-setting",
            name = "rampantFixed--allowOtherEnemies",
            description = "rampantFixed--allowOtherEnemies",
            setting_type = "startup",
            default_value = false,
            order = "e[modifier]-a[unit]_01",
            per_user = false
        },
		
        {
            type = "int-setting",
            name = "rampantFixed--max-evo-dist",
            setting_type = "startup",
            default_value = 9600,
            minimum_value = 1000,
            maximum_value = 1000000,
            order = "e[modifier]-b[unit]",
            per_user = false
        },

		
        {
            type = "string-setting",
            name = "rampantFixed--newEnemiesSide",
            description = "rampantFixed--newEnemiesSide",
            setting_type = "startup",
            default_value = "MIXED",
            order = "e[modifier]-a[unit]_02",
            allowed_values = {"MIXED", "NORTH", "EAST", "SOUTH", "WEST", "NORTH-EAST", "SOUTH-EAST", "SOUTH-WEST", "NORTH-WEST"},
            per_user = false
        },

        {
            type = "int-setting",
            name = "rampantFixed--newEnemyVariations",
            description = "rampantFixed--newEnemyVariations",
            setting_type = "startup",
            minimum_value = 1,
            maximum_value = 20,
            default_value = 1,
            order = "l[modifier]-h[unit]",
            per_user = false
        },

        {
            type = "int-setting",
            name = "rampantFixed--tierStart",
            setting_type = "startup",
            default_value = 1,
            minimum_value = 1,
            maximum_value = 10,
            order = "l[modifier]-l[unit]",
            per_user = false
        },

        {
            type = "int-setting",
            name = "rampantFixed--tierEnd",
            setting_type = "startup",
            minimum_value = 1,
            maximum_value = 10,
            default_value = 5,
            order = "l[modifier]-m[unit]",
            per_user = false
        },
		
        {
            type = "bool-setting",
            name = "rampantFixed--allowLongRangeImmunity",
            setting_type = "startup",
            default_value = true,
            order = "l[modifier]-n1[unit]",
            per_user = false
        },
		
        {
            type = "int-setting",
            name = "rampantFixed--longRangeImmunity_efficiency",
            setting_type = "startup",
            minimum_value = 10,
            maximum_value = 100,
            default_value = 95,
            order = "l[modifier]-n2[unit]",
            per_user = false
        },
		
        {
            type = "bool-setting",
            name = "rampantFixed--allowOneshotProtection",
            setting_type = "startup",
            default_value = true,
            order = "l[modifier]-o1[unit]",
            per_user = false
        },
		
        {
            type = "int-setting",
            name = "rampantFixed--oneshotProtection_efficiency",
            setting_type = "startup",
            minimum_value = 10,
            maximum_value = 100,
            default_value = 100,
            order = "l[modifier]-o2[unit]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--buildingsImmuneToElectic",
            description = "rampantFixed--buildingsImmuneToElectic",
            setting_type = "startup",
            default_value = true,
            order = "l[modifier]-p1[unit]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--acidEnemy",
            setting_type = "startup",
            default_value = true,
            order = "l[modifier]-t1[unit]",
            per_user = false
        },
		
        {
            type = "bool-setting",
            name = "rampantFixed--laserEnemy",
            setting_type = "startup",
            default_value = true,
            order = "l[modifier]-t2[unit]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--electricEnemy",
            setting_type = "startup",
            default_value = true,
            order = "l[modifier]-t2a[unit]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--suicideEnemy",
            setting_type = "startup",
            default_value = true,
            order = "l[modifier]-t2c[unit]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--fastEnemy",
            setting_type = "startup",
            default_value = true,
            order = "l[modifier]-t2d[unit]",
            per_user = false
        },
		
        {
            type = "bool-setting",
            name = "rampantFixed--waspEnemy",
            setting_type = "startup",
            default_value = true,
            order = "l[modifier]-t3[unit]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--spawnerEnemy",
            setting_type = "startup",
            default_value = true,
            order = "l[modifier]-t3a[unit]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--trollEnemy",
            setting_type = "startup",
            default_value = true,
            order = "l[modifier]-t3b[unit]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--energyThiefEnemy",
            setting_type = "startup",
            default_value = true,
            order = "l[modifier]-t3c[unit]",
            per_user = false
        },
		
        {
            type = "bool-setting",
            name = "rampantFixed--fireEnemy",
            setting_type = "startup",
            default_value = true,
            order = "l[modifier]-t4[unit]",
            per_user = false
        },

         {
            type = "bool-setting",
            name = "rampantFixed--ArachnidsEnemy",
            setting_type = "startup",
            default_value = true,
            order = "l[modifier]-t4a[unit]",
            per_user = false
        },
		
        {
            type = "bool-setting",
            name = "rampantFixed--physicalEnemy",
            setting_type = "startup",
            default_value = true,
            order = "l[modifier]-t5[unit]",
            per_user = false
        },
		
        {
            type = "bool-setting",
            name = "rampantFixed--infernoEnemy",
            setting_type = "startup",
            default_value = true,
            order = "l[modifier]-t6a[unit]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--poisonEnemy",
            setting_type = "startup",
            default_value = true,
            order = "l[modifier]-t6b[unit]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--nuclearEnemy",
            setting_type = "startup",
            default_value = true,
            order = "l[modifier]-t7[unit]",
            per_user = false
        },
		
        {
            type = "bool-setting",
            name = "rampantFixed--JuggernautEnemy",
            setting_type = "startup",
            default_value = true,
            order = "l[modifier]-t9[unit]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--unitSpawnerBreath",
            setting_type = "startup",
            default_value = true,
            order = "l[modifier]-zb[unit]",
            per_user = false
        },

        -- {
        --     type = "bool-setting",
        --     name = "rampantFixed--disableVanillaAI",
        --     description = "rampantFixed--disableVanillaAI",
        --     setting_type = 'runtime-global',
        --     default_value = true,
        --     order = "m[total]-a[ai]",
        --     per_user = false
        -- },

        {
            type = "bool-setting",
            name = "rampantFixed--enableMigration",
            description = "rampantFixed--enableMigration",
            setting_type = 'runtime-global',
            default_value = false,
            order = "m[total]-c1[ai]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--peacefulAIToggle",
            setting_type = "runtime-global",
            default_value = true,
            order = "m[total]-c2[ai]",
            per_user = false
        },

        {
            type = "int-setting",
            name = "rampantFixed--peacePeriod",
            setting_type = "runtime-global",
            minimum_value = 0,
            maximum_value = 1200,
            default_value = 20,
            order = "m[total]-c2a[ai]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--raidAIToggle",
            setting_type = "runtime-global",
            default_value = true,
            order = "m[total]-c3[ai]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--siegeAIToggle",
            setting_type = "runtime-global",
            default_value = true,
            order = "m[total]-c4[ai]",
            per_user = false
        },

        -- {
            -- type = "int-setting",
            -- name = "rampantFixed--siegeMinDistance",
            -- setting_type = "runtime-global",
            -- minimum_value = 0,
            -- maximum_value = 3,
            -- default_value = 1,
            -- order = "m[total]-c4a[ai]",
            -- per_user = false
        -- },

        {
            type = "bool-setting",
            name = "rampantFixed--undergroundAttack",
            setting_type = "runtime-global",
            default_value = true,
            order = "m[total]-c5[ai]",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--undergroundAttackProbability",
            setting_type = "runtime-global",
            minimum_value = 0.01,
            maximum_value = 0.50,
            default_value = 0.15,
            order = "m[total]-c6[ai]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--permanentNocturnal",
            description = "rampantFixed--permanentNocturnal",
            setting_type = "runtime-global",
            default_value = false,
            order = "m[total]-a[ai]",
            per_user = false
        },
		
        {
            type = "bool-setting",
            name = "rampantFixed--allowDaytimePlayerHunting",
            description = "rampantFixed--allowDaytimePlayerHunting",
            setting_type = "runtime-global",
            default_value = false,
            order = "m[total]-a[ai]2",
            per_user = false
        },
		
        {
            type = "bool-setting",
            name = "rampantFixed--allowDaytimeNonRampantActions",
            description = "rampantFixed--allowDaytimeNonRampantActions",
            setting_type = "runtime-global",
            default_value = false,
            order = "m[total]-a[ai]3",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--aiPointsScaler",
            description = "rampantFixed--aiPointsScaler",
            setting_type = "runtime-global",
            default_value = 1.0,
            minimum_value = 0.0,
            maximum_value = 100.0,
            order = "m[total]-b[ai]1",
            per_user = false
        },

        {
            type = "string-setting",
            name = "rampantFixed--aiDifficulty",
            description = "rampantFixed--aiDifficulty",
            setting_type = "runtime-global",
            default_value = "Hard",
            order = "m[total]-b[ai]m",
            allowed_values = {"Hard", "Lite"},
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--aiPointsPrintGainsToChat",
            description = "rampantFixed--aiPointsPrintGainsToChat",
            setting_type = "runtime-global",
            default_value = false,
            order = "m[total]-d1[ai]z",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--aiPointsPrintSpendingToChat",
            description = "rampantFixed--aiPointsPrintSpendingToChat",
            setting_type = "runtime-global",
            default_value = false,
            order = "m[total]-d2[ai]z",
            per_user = false
        },
		
        {
            type = "bool-setting",
            name = "rampantFixed--printAIStateChanges",
            setting_type = "runtime-global",
            default_value = false,
            order = "m[total]-d3[ai]z",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--debugTemperament",
            setting_type = "runtime-global",
            default_value = false,
            order = "m[total]-d4[ai]zz",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--showAdminMenu",
            description = "rampantFixed--showAdminMenu",
            setting_type = "runtime-per-user",
            default_value = false,
            order = "m[total]-c[ai]z1",
            per_user = false
        },
		
        {
            type = "double-setting",
            name = "rampantFixed--settlementsProbability",
            setting_type = "runtime-global",
            default_value = 0.400,
            minimum_value = 0.001,
            maximum_value = 1,
            order = "m[total]-b[ai]a",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--vengenceProbabilityPercent",
            setting_type = "runtime-global",
            default_value = 0.04,
            minimum_value = 0,
            maximum_value = 1,
            order = "m[total]-b[ai]a1",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--chainVengenceCoefficient",
            setting_type = "runtime-global",
            default_value = 0.6,
            minimum_value = 0,
            maximum_value = 1,
            order = "m[total]-b[ai]a2",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--removeBloodParticles",
            description = "rampantFixed--reduceBloodParticles",
            setting_type = "startup",
            default_value = false,
            order = "n[modifier]-a[optimize]",
            per_user = false
        },
        {
            type = "bool-setting",
            name = "rampantFixed--fireSafety-flamethrower",
            setting_type = "startup",
            default_value = true,
            order = "n[modifier]-b[optimize]",
            per_user = false
        },
        {
            type = "bool-setting",
            name = "rampantFixed--flamethrowerTurretsRebalance",
            setting_type = "startup",
            default_value = false,
            order = "n[modifier]-c[optimize]",
            per_user = false
        },
        {
            type = "bool-setting",
            name = "rampantFixed--rampantArsenalRebalance",
            setting_type = "startup",
            default_value = true,
            order = "n[modifier]-d[optimize]",
            per_user = false
        },

        -- {
        --     type = "bool-setting",
        --     name = "rampantFixed--enableFullMapScan",
        --     setting_type = "runtime-global",
        --     default_value = true,
        --     order = "n[modifier]-a[optimize]",
        --     per_user = false
        -- },

        {
            type = "bool-setting",
            name = "rampantFixed--unkillableLogisticRobots",
            setting_type = "startup",
            default_value = false,
            order = "n[modifier]-d[optimize]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--unkillableConstructionRobots",
            setting_type = "startup",
            default_value = false,
            order = "n[modifier]-c[optimize]",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--unitBiterHealthScaler",
            description = "rampantFixed--unitBiterHealthScaler",
            setting_type = "startup",
            default_value = 1.0,
            minimum_value = 0.0001,
            maximum_value = 100000.0,
            order = "p[modifier]-a[unit]",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--unitBiterHealingScaler",
            description = "rampantFixed--unitBiterHealingScaler",
            setting_type = "startup",
            default_value = 1.0,
            minimum_value = 0.0001,
            maximum_value = 100000.0,
            order = "p[modifier]-a[unit]",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--unitBiterSpeedScaler",
            description = "rampantFixed--unitBiterSpeedScaler",
            setting_type = "startup",
            default_value = 1.0,
            minimum_value = 0.0001,
            maximum_value = 100000.0,
            order = "p[modifier]-b[unit]",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--unitBiterDamageScaler",
            description = "rampantFixed--unitBiterDamageScaler",
            setting_type = "startup",
            default_value = 1.0,
            minimum_value = 0.0001,
            maximum_value = 100000.0,
            order = "p[modifier]-c[unit]",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--unitBiterRangeScaler",
            description = "rampantFixed--unitBiterRangeScaler",
            setting_type = "startup",
            default_value = 1.0,
            minimum_value = 0.0001,
            maximum_value = 100000.0,
            order = "p[modifier]-d[unit]",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--unitSpitterHealthScaler",
            description = "rampantFixed--unitSpitterHealthScaler",
            setting_type = "startup",
            default_value = 1.0,
            minimum_value = 0.0001,
            maximum_value = 100000.0,
            order = "p[modifier]-e[unit]",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--unitSpitterHealingScaler",
            description = "rampantFixed--unitSpitterHealingScaler",
            setting_type = "startup",
            default_value = 1.0,
            minimum_value = 0.0001,
            maximum_value = 100000.0,
            order = "p[modifier]-e[unit]",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--unitSpitterSpeedScaler",
            description = "rampantFixed--unitSpitterSpeedScaler",
            setting_type = "startup",
            default_value = 1.0,
            minimum_value = 0.0001,
            maximum_value = 100000.0,
            order = "p[modifier]-f[unit]",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--unitSpitterDamageScaler",
            description = "rampantFixed--unitSpitterDamageScaler",
            setting_type = "startup",
            default_value = 1.0,
            minimum_value = 0.0001,
            maximum_value = 100000.0,
            order = "p[modifier]-g[unit]",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--unitSpitterRangeScaler",
            description = "rampantFixed--unitSpitterRangeScaler",
            setting_type = "startup",
            default_value = 1.0,
            minimum_value = 0.0001,
            maximum_value = 100000.0,
            order = "p[modifier]-h[unit]",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--unitDroneHealthScaler",
            description = "rampantFixed--unitDroneHealthScaler",
            setting_type = "startup",
            default_value = 1.0,
            minimum_value = 0.0001,
            maximum_value = 100000.0,
            order = "p[modifier]-i[unit]",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--unitDroneHealingScaler",
            description = "rampantFixed--unitDroneHealingScaler",
            setting_type = "startup",
            default_value = 1.0,
            minimum_value = 0.0001,
            maximum_value = 100000.0,
            order = "p[modifier]-i[unit]",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--unitDroneSpeedScaler",
            description = "rampantFixed--unitDroneSpeedScaler",
            setting_type = "startup",
            default_value = 1.0,
            minimum_value = 0.0001,
            maximum_value = 100000.0,
            order = "p[modifier]-j[unit]",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--unitDroneDamageScaler",
            description = "rampantFixed--unitDroneDamageScaler",
            setting_type = "startup",
            default_value = 1.0,
            minimum_value = 0.0001,
            maximum_value = 100000.0,
            order = "p[modifier]-k[unit]",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--unitDroneRangeScaler",
            description = "rampantFixed--unitDroneRangeScaler",
            setting_type = "startup",
            default_value = 1.0,
            minimum_value = 0.0001,
            maximum_value = 100000.0,
            order = "p[modifier]-l[unit]",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--unitWormHealthScaler",
            description = "rampantFixed--unitWormHealthScaler",
            setting_type = "startup",
            default_value = 1.0,
            minimum_value = 0.0001,
            maximum_value = 100000.0,
            order = "p[modifier]-m[unit]",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--unitWormHealingScaler",
            description = "rampantFixed--unitWormHealingScaler",
            setting_type = "startup",
            default_value = 1.0,
            minimum_value = 0.0001,
            maximum_value = 100000.0,
            order = "p[modifier]-m[unit]",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--unitWormDamageScaler",
            description = "rampantFixed--unitWormDamageScaler",
            setting_type = "startup",
            default_value = 1.0,
            minimum_value = 0.0001,
            maximum_value = 100000.0,
            order = "p[modifier]-n[unit]",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--unitWormRangeScaler",
            description = "rampantFixed--unitWormRangeScaler",
            setting_type = "startup",
            default_value = 1.0,
            minimum_value = 0.0001,
            maximum_value = 100000.0,
            order = "p[modifier]-o[unit]",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--unitSpawnerHealthScaler",
            description = "rampantFixed--unitSpawnerHealthScaler",
            setting_type = "startup",
            default_value = 1.0,
            minimum_value = 0.0001,
            maximum_value = 100000.0,
            order = "p[modifier]-p[unit]",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--unitSpawnerHealingScaler",
            description = "rampantFixed--unitSpawnerHealingScaler",
            setting_type = "startup",
            default_value = 1.0,
            minimum_value = 0.0001,
            maximum_value = 100000.0,
            order = "p[modifier]-p[unit]",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--unitSpawnerOwnedScaler",
            description = "rampantFixed--unitSpawnerOwnedScaler",
            setting_type = "startup",
            default_value = 1.0,
            minimum_value = 0.0001,
            maximum_value = 100000.0,
            order = "p[modifier]-q[unit]",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--unitSpawnerSpawnScaler",
            description = "rampantFixed--unitSpawnerSpawnScaler",
            setting_type = "startup",
            default_value = 1.0,
            minimum_value = 0.0001,
            maximum_value = 100000.0,
            order = "p[modifier]-r[unit]",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--unitSpawnerRespawnScaler",
            description = "rampantFixed--unitSpawnerRespawnScaler",
            setting_type = "startup",
            default_value = 1.0,
            minimum_value = 0.0001,
            maximum_value = 100000.0,
            order = "p[modifier]-r[unit]",
            per_user = false
        },


        {
            type = "double-setting",
            name = "rampantFixed--unitHiveRespawnScaler",
            description = "rampantFixed--unitHiveRespawnScaler",
            setting_type = "startup",
            default_value = 1.0,
            minimum_value = 0.0001,
            maximum_value = 100000.0,
            order = "p[modifier]-r[zunit]",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--unitHiveHealthScaler",
            description = "rampantFixed--unitHiveHealthScaler",
            setting_type = "startup",
            default_value = 1.0,
            minimum_value = 0.0001,
            maximum_value = 100000.0,
            order = "p[modifier]-r[zunit]",
            per_user = false
        },

        {
            type = "double-setting",
            name = "rampantFixed--unitHiveHealingScaler",
            description = "rampantFixed--unitHiveHealingScaler",
            setting_type = "startup",
            default_value = 1.0,
            minimum_value = 0.0001,
            maximum_value = 100000.0,
            order = "p[modifier]-r[zunit]",
            per_user = false
        },

        {
            type = "bool-setting",
            name = "rampantFixed--attackWaveGenerationUsePlayerProximity",
            setting_type = "runtime-global",
            default_value = true,
            order = "b[modifier]-b[trigger]",
            per_user = false

        },

        {
            type = "double-setting",
            name = "rampantFixed--attackPlayerThreshold",
            setting_type = "runtime-global",
            minimum_value = 0,
            default_value = 20,
            order = "b[modifier]-c[threshold]",
            per_user = false
        }

})