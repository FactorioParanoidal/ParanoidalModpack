local swarmUtils = {}
-- imports

local bombUtils = require("utils/BombUtils")
local attackFlame = require("utils/AttackFlame")
local energyThiefFaction = require("EnergyThief")
local poisonFaction = require("Poison")
local beamUtils = require("utils/BeamUtils")
local acidBall = require("utils/AttackBall")
local droneUtils = require("utils/DroneUtils")
local biterUtils = require("utils/BiterUtils")
local particleUtils = require("utils/ParticleUtils")
local stickerUtils = require("utils/StickerUtils")
local unitUtils = require("utils/UnitUtils")
local fireUtils = require("utils/FireUtils")
local spawnUtils = require("utils/SpawnUtils")

local constants = require("__RampantFixed__/libs/Constants")
local mathUtils = require("__RampantFixed__/libs/MathUtils")

-- imported functions

local roundToNearest = mathUtils.roundToNearest

local mMax = math.max
local mMin = math.min

local deepcopy = util.table.deepcopy

local TIER_UPGRADE_SET_10 = constants.TIER_UPGRADE_SET_10
-- + !КДА 2021.11
local TIER_UPGRADE_SET_10_AS_IS = constants.TIER_UPGRADE_SET_10_AS_IS
local OVERDAMAGEPROTECTION_THRESHOLD = constants.OVERDAMAGEPROTECTION_THRESHOLD
local calculateValuesForLevels = mathUtils.calculateValuesForLevels
local addTrigger_effect = biterUtils.addTrigger_effect

local blockableStreams = false
blockableStreams = settings.startup["rampantFixed--useBlockableSteamAttacks"].value
-- if mods["combat-mechanics-overhaul"] and mods["Krastorio2"] and mods["space-exploration"] then
	-- log(serpent.dump(settings))
	-- if settings.startup["combat-mechanics-overhaul-spitter-spit-blockable"].value or settings.startup["combat-mechanics-overhaul--worm-spit-blockable"].value then
		-- blockableStreams = true
	-- end	
-- end

local function recalculateTableForEffectiveLevel(attributeTable, tierSet, precision, specPrecisionTable, ignoredAttributes)
	if not precision then precision = 4 end
	for i,tierValues in pairs(attributeTable) do
		if ignoredAttributes and ignoredAttributes[i] then
		else			
			local specPrecision
			if specPrecisionTable then 
				specPrecision = specPrecisionTable[i]
			end	
			attributeTable[i] = calculateValuesForLevels(tierValues, tierSet, (specPrecision or precision))
		end	
	end	
end
-- - !КДА 2021.11

local biterattackanimation = unitUtils.biterattackanimation

local createProjectileAttack = biterUtils.createProjectileAttack
local createCapsuleProjectile = droneUtils.createCapsuleProjectile
local makeSticker = stickerUtils.makeSticker
local makeAtomicBlast = bombUtils.makeAtomicBlast
local makeLaser = beamUtils.makeLaser
local createAttackBall = acidBall.createAttackBall
local createSpitFire = acidBall.createSpitFire
local createRangedAttack = biterUtils.createRangedAttack
local createMeleeAttack = biterUtils.createMeleeAttack
local makeMeleePoisonCloud = biterUtils.makeMeleePoisonCloud
local makeflamerAtack = biterUtils.makeflamerAtack
local createSpawnAttack = biterUtils.createSpawnAttack
local createSpawnBall = spawnUtils.createSpawnBall


local makeAcidSplashFire = fireUtils.makeAcidSplashFire

local makeWormAlienLootTable = biterUtils.makeWormAlienLootTable
local makeUnitAlienLootTable = biterUtils.makeUnitAlienLootTable
local makeSpawnerAlienLootTable = biterUtils.makeSpawnerAlienLootTable
local makeSchallAlienLootTables = biterUtils.makeSchallAlienLootTables
local makeAlienLootEconomyTables = biterUtils.makeAlienLootEconomyTables

local createSuicideAttack = biterUtils.createSuicideAttack

local createAttackFlame = attackFlame.createAttackFlame
local createStreamAttack = biterUtils.createStreamAttack

local gaussianRandomRangeRG = mathUtils.gaussianRandomRangeRG

local makeBloodFountains = particleUtils.makeBloodFountains

local makeBubble = beamUtils.makeBubble
local makeBeam = beamUtils.makeBeam
local createElectricAttack = biterUtils.createElectricAttack

local makeBiter = biterUtils.makeBiter
local makeDrone = droneUtils.makeDrone
local makeSpitter = biterUtils.makeSpitter
local makeWorm = biterUtils.makeWorm
local makeUnitSpawner = biterUtils.makeUnitSpawner

-- module code

local scorchmarkTiers = {
    "small-scorchmark",
    "small-scorchmark",
    "medium-scorchmark",
    "medium-scorchmark",
    "medium-scorchmark",
    "big-scorchmark",
    "big-scorchmark",
    "big-scorchmark",
    "huge-scorchmark",
    "huge-scorchmark"
}

local explosionTiers = {
    "explosion",
    "explosion",
    "big-explosion",
    "big-explosion",
    "big-explosion",
    "big-explosion",
    "massive-explosion",
    "massive-explosion",
    "massive-explosion",
    "massive-explosion"
}

local bloodFountains = {
    "blood-explosion-small-rampant",
    "blood-explosion-small-rampant",
    "blood-explosion-small-rampant",
    "blood-explosion-small-rampant",
    "blood-explosion-big-rampant",
    "blood-explosion-big-rampant",
    "blood-explosion-big-rampant",
    "blood-explosion-huge-rampant",
    "blood-explosion-huge-rampant",
    "blood-explosion-huge-rampant",
}


local nuclearAttackNumeric = {
    ["damage"] = { 75, 100, 150, 187, 270, 360, 500, 550, 600, 650 },			-- instant dmg to target
    ["repeatCount"] = { 150, 175, 250, 300, 350, 400, 450, 500, 550, 600 },
    ["radius"] = { 10, 13, 14, 15, 17, 18, 19, 20, 21, 22 },
    ["explosionDistance"] = { 3, 3, 4, 4, 5, 5, 6, 6, 7, 7 },
    ["explosionCount"] = { 3, 3, 3, 4, 4, 4, 5, 5, 6, 6 }
}
--recalculateTableForEffectiveLevel(nuclearAttackNumeric,TIER_UPGRADE_SET_10_AS_IS, 0)	-- + !КДА 2021.11
nuclearAttackNumeric["damage"] = calculateValuesForLevels(nuclearAttackNumeric["damage"], TIER_UPGRADE_SET_10_AS_IS, 0)	
nuclearAttackNumeric["radius"] = calculateValuesForLevels(nuclearAttackNumeric["radius"], TIER_UPGRADE_SET_10_AS_IS, 0)	
nuclearAttackNumeric["repeatCount"] = calculateValuesForLevels(nuclearAttackNumeric["repeatCount"], TIER_UPGRADE_SET_10_AS_IS, 0)	


local bombAttackNumeric = {
    ["damage"] = { 75, 112, 150, 187, 270, 360, 600, 720, 975, 1050 },
    ["radius"] = { 1.75, 1.75, 2, 2.5, 3, 3, 3.5, 3.5, 3.75, 4 },
    ["explosionDistance"] = { 2, 2, 2, 2, 2, 2.5, 2.5, 2.5, 3, 3 },
    ["explosionCount"] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 }	
}
bombAttackNumeric["damage"] = calculateValuesForLevels(bombAttackNumeric["damage"], TIER_UPGRADE_SET_10_AS_IS, 1)	

local streamAttackNumeric = {
    ["stickerDamagePerTick"] = { 0.6, 0.8, 1, 1.5, 2, 2.5, 3, 4, 5, 6 },
    ["particleTimeout"] = { 3, 3, 4, 4, 5, 5, 6, 6, 7, 7 },
    ["fireSpreadRadius"] = { 0.75, 0.75, 0.77, 0.77, 0.79, 0.79, 0.83, 0.83, 0.85, 0.85 },
    ["damageMaxMultipler"] = { 6, 6, 7, 7, 7, 7, 8, 8, 8, 9 },
    ["stickerMovementModifier"] = { 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1 },
    ["fireSpreadCooldown"] = { 30, 30, 29, 29, 28, 28, 27, 27, 25, 25 },
    ["stickerDuration"] = { 800, 800, 900, 900, 1000, 1000, 1100, 1100, 1200, 1200 },
    ["damage"] = { 3, 3, 4, 4, 5, 5, 5, 5, 5, 6 }					-- used as steam dmg per tick if default steam attack builded. As direct hit damage if alternative atack builded
   ,["fireDamagePerTick"] = {1, 1.2, 1.5, 2, 3, 4, 5, 6, 7, 8 }		-- used as fire dmg per tick when alternative atack builded (fire/inferno spitters)
}
recalculateTableForEffectiveLevel(streamAttackNumeric,TIER_UPGRADE_SET_10_AS_IS, 1, {particleTimeout = 0, fireSpreadCooldown = 0, stickerDuration = 0, fireDamagePerTick = 2})	-- + !КДА 2021.11
--log("streamAttackNumeric="..serpent.dump(streamAttackNumeric.fireDamagePerTick))

local lowDamageStreamAttackNumeric = {
    ["stickerDamagePerTick"] = { 0.6, 0.6, 0.8, 0.8, 0.8, 0.9, 1, 1, 1.3, 1.5 },
    ["particleTimeout"] = { 3, 3, 4, 4, 5, 5, 6, 6, 7, 7 },
    ["fireSpreadRadius"] = { 0.75, 0.75, 0.77, 0.77, 0.79, 0.79, 0.83, 0.83, 0.85, 0.85 },
    ["damageMaxMultipler"] = { 6, 6, 7, 7, 7, 7, 8, 8, 8, 9 },
    ["stickerMovementModifier"] = { 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1 },
    ["fireSpreadCooldown"] = { 30, 30, 29, 29, 28, 28, 27, 27, 25, 25 },
    ["stickerDuration"] = { 800, 800, 900, 900, 1000, 1000, 1100, 1100, 1200, 1200 },
    ["damage"] = { 0.5, 0.7, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5 }					-- used as steam dmg per tick if default steam attack builded. As direct hit damage if alternative atack builded
   ,["fireDamagePerTick"] = {0.8, 0.9, 1, 1.5, 2, 3, 4, 5, 6, 7 }		-- used as fire dmg per tick when alternative atack builded (fire/inferno spitters)
}
recalculateTableForEffectiveLevel(lowDamageStreamAttackNumeric,TIER_UPGRADE_SET_10_AS_IS, 1, {particleTimeout = 0, fireSpreadCooldown = 0, stickerDuration = 0, fireDamagePerTick = 2})



local beamAttackNumeric = {
    ["range"] = { 11, 11, 12, 12, 13, 13, 14, 14, 15, 15 },
    ["damage"] = { 3.6, 6, 9, 12, 18, 27, 36, 45, 54, 90 },
    ["duration"] = { 20, 20, 21, 21, 22, 22, 23, 23, 24, 24 },
    ["damageInterval"] =  { 20, 20, 21, 21, 22, 22, 23, 23, 24, 24 },
    ["width"] = { 1.5, 1.5, 1.6, 1.6, 1.7, 1.7, 1.8, 1.8, 1.9, 1.9 }
}
-- + !КДА 2021.11
beamAttackNumeric["damage"] = calculateValuesForLevels(beamAttackNumeric["damage"], TIER_UPGRADE_SET_10_AS_IS, 1)	
beamAttackNumeric["duration"] = calculateValuesForLevels(beamAttackNumeric["duration"], TIER_UPGRADE_SET_10_AS_IS, 1)
--beamAttackNumeric["damageInterval"] = calculateValuesForLevels(beamAttackNumeric["damageInterval"], TIER_UPGRADE_SET_10_AS_IS, 0)
-- - !КДА 2021.11


local clusterAttackNumeric = {
    ["clusterDistance"] = { 3, 3, 4, 4, 5, 5, 6, 6, 7, 7 },
    ["clusters"] = { 5, 5, 6, 6, 7, 7, 8, 8, 9, 9 },										
    ["startingSpeed"] = { 0.25, 0.25, 0.27, 0.27, 0.29, 0.29, 0.31, 0.31, 0.33, 0.33 }	
}
--recalculateTableForEffectiveLevel(clusterAttackNumeric,TIER_UPGRADE_SET_10_AS_IS, 0, {startingSpeed = 2})	-- + !КДА 2021.11

local biterAttributeNumeric = {
    ["range"] = { 0.5, 0.5, 0.75, 0.75, 1.0, 1.0, 1.25, 1.50, 1.75, 2.0 },
    ["radius"] = { 0.5, 0.65, 0.75, 0.85, 0.95, 1.1, 1.2, 1.3, 1.4, 1.5 },
    ["cooldown"] = { 40, 41, 42, 44, 46, 48, 50, 52, 55, 57 },
    ["damage"] = {7, 20, 35, 60, 115, 145, 175, 205.0, 235.0, 265.0 },	-- + !КДА 2021.11 defs{7, 15, 30, 90}		 { 16, 35, 65, 85, 115, 145, 175, 205.0, 235.0, 265.0 }
    ["scale"] = { 0.25, 0.40, 0.60, 0.8, 0.9, 1, 1.2, 1.4, 1.6, 1.8 },
    ["healing"] = { 0.01, 0.01, 0.015, 0.02, 0.05, 0.075, 0.1, 0.12, 0.14, 0.16 },
    ["physicalDecrease"] = { 0, 2, 4, 5, 6, 8, 11, 13, 16, 17 },			-- + !КДА 2021.11 { 0, 0, 4, 5, 6, 8, 11, 13, 16, 17 }
    ["physicalPercent"] = { 0, 0, 0, 10, 12, 12, 14, 16, 18, 20 },
    ["explosionDecrease"] = { 0, 0, 0, 0, 0, 10, 12, 14, 16, 20 },
    ["explosionPercent"] = { 0, 0, 0, 10, 12, 13, 15, 16, 17, 20 },
    -- ["distancePerFrame"] = { 0.1, 0.125, 0.15, 0.19, 0.195, 0.2, 0.2, 0.2, 0.2, 0.2 },
    ["distancePerFrame"] = { 0.08, 0.10, 0.125, 0.15, 0.18, 0.195, 0.2, 0.2, 0.2, 0.2 },
    ["movement"] = { 0.2, 0.2, 0.21, 0.21, 0.22, 0.22, 0.22, 0.22, 0.22, 0.20 },	-- + !КДА КДА 2021.11 { 0.2, 0.19, 0.185, 0.18, 0.175, 0.17, 0.17, 0.17, 0.17, 0.17 }
    ["health"] = { 15, 75, 150, 250, 1000, 2000, 3500, 7500, 15000, 30000 },
    ["pollutionToAttack"] = {8, 20, 30, 50, 140, 200, 260, 320, 400, 500 },		-- + !КДА defs {4, 20, 80, 400} 		{ 10, 40, 80, 120, 200, 300, 450, 550, 650, 750 }
    ["spawningTimeModifer"] = { 1, 1, 1, 2, 3, 7, 10, 10, 12, 12 }
}
-- + !КДА 2021.11
recalculateTableForEffectiveLevel(biterAttributeNumeric,TIER_UPGRADE_SET_10_AS_IS, 
	2, 
	{cooldown = 0, spawningTimeModifer = 0, health = 0},
	{physicalPercent = "", explosionPercent = "", movement = "", distancePerFrame = ""}
	)	

-- + !КДА 2021.12
local poisonAttacksNumeric = {
	["dps"] = {7, 20, 35, 60, 115, 145, 175, 205.0, 235.0, 265.0 },
	["hps"] = {7, 20, 35, 60, 115, 145, 175, 205.0, 235.0, 265.0 },
    ["radius"] = {2, 2.3, 2.6, 3, 3.2, 3.6, 4, 4.2, 4.4, 4.6 }
}
poisonAttacksNumeric["dps"] = calculateValuesForLevels(poisonAttacksNumeric["dps"], TIER_UPGRADE_SET_10_AS_IS, 2)	
poisonAttacksNumeric["hps"] = calculateValuesForLevels(poisonAttacksNumeric["hps"], TIER_UPGRADE_SET_10_AS_IS, 2)
-- - !КДА 2021.12

local acidPuddleAttributeNumeric = {
    ["damagePerTick"] = { 0.05, 0.1, 0.3, 0.6, 1, 1.4, 2, 3, 4.5, 6 },
    ["stickerDamagePerTick"] = { 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5 },
    ["stickerDuration"] = { 600, 610, 620, 630, 640, 650, 660, 670, 680, 690 }
}
recalculateTableForEffectiveLevel(acidPuddleAttributeNumeric,TIER_UPGRADE_SET_10_AS_IS, 2, nil, {stickerDuration = ""})	-- + !КДА 2021.11

local spitterAttributeNumeric = {
    ["range"] = { 11, 11, 11, 12, 12, 12, 13, 13, 14, 14 },
    ["radius"] = { 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0, 2.5 },
    ["cooldown"] = { 100, 100, 97, 97, 95, 95, 93, 93, 90, 90 },
    ["warmup"] = { 30, 29, 28, 27, 26, 25, 24, 23, 22, 21 },
    ["stickerDuration"] = { 600, 610, 620, 630, 640, 650, 660, 670, 680, 690 },
    ["damagePerTick"] = { 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1 },
    ["stickerDamagePerTick"] = { 0.025, 0.05, 0.075, 0.1, 0.125, 0.15, 0.175, 0.2, 0.225, 0.25 },
    ["stickerMovementModifier"] = { 0.97, 0.96, 0.95, 0.94, 0.93, 0.92, 0.91, 0.90, 0.89, 0.88 },
    ["damage"] = { 4, 7.5, 11.25, 15, 22.5, 27.5, 32.5, 37.5, 42.5, 47.5 },
    ["particleVerticalAcceleration"] = { 0.01, 0.01, 0.02, 0.02, 0.03, 0.03, 0.04, 0.04, 0.05, 0.05 },
    ["particleHoizontalSpeed"] = { 0.6, 0.6, 0.7, 0.7, 0.8, 0.8, 0.9, 0.9, 1, 1 },
    ["particleHoizontalSpeedDeviation"] = { 0.0025, 0.0025, 0.0024, 0.0024, 0.0023, 0.0023, 0.0022, 0.0022, 0.0021, 0.0021 },
    ["scale"] = { 0.25, 0.40, 0.60, 0.8, 0.9, 1, 1.2, 1.4, 1.6, 1.8 },
    ["healing"] = { 0.01, 0.01, 0.015, 0.02, 0.05, 0.075, 0.1, 0.12, 0.14, 0.16 },
    ["physicalDecrease"] = { 0, 0, 0, 0, 2, 4, 6, 8, 10, 12 },
    ["physicalPercent"] = { 0, 0, 0, 10, 12, 12, 14, 14, 15, 15 },
    ["explosionPercent"] = { 0, 0, 10, 10, 20, 20, 30, 30, 40, 40 },
    ["distancePerFrame"] = { 0.04, 0.045, 0.050, 0.055, 0.060, 0.065, 0.067, 0.069, 0.071, 0.073 },
    ["movement"] = { 0.185, 0.185, 0.19, 0.19, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20 },		-- + !КДА КДА 2021.11	{ 0.185, 0.18, 0.18, 0.17, 0.17, 0.16, 0.16, 0.15, 0.15, 0.14 } 
    ["health"] = { 10, 50, 150, 320, 1000, 2250, 3250, 6500, 12500, 25000 },				-- + !КДА КДА 2022.01	{ 10, 50, 200, 350, 1250, 2250, 3250, 6500, 12500, 25000 }
    ["pollutionToAttack"] = {6, 20, 45, 60, 160, 200, 260, 320, 400, 500 },	-- + !КДА defs (4, 12, 30, 200), 	{ 10, 40, 80, 120, 200, 300, 450, 550, 650, 750 }
    ["spawningTimeModifer"] = { 1, 1, 1, 2, 2, 5, 8, 8, 10, 10 },
}
-- + !КДА 2021.11
-- recalculateTableForEffectiveLevel(spitterAttributeNumeric,TIER_UPGRADE_SET_10_AS_IS, 
	-- 2, 
	-- {cooldown = 0, particleHoizontalSpeedDeviation = 4, spawningTimeModifer = 0, health = 0, stickerDamagePerTick = 4},
	-- {range = "", radius="", movement = "",  distancePerFrame = "",})
spitterAttributeNumeric["damagePerTick"] = calculateValuesForLevels(spitterAttributeNumeric["damagePerTick"], TIER_UPGRADE_SET_10_AS_IS, 2)
spitterAttributeNumeric["stickerDamagePerTick"] = calculateValuesForLevels(spitterAttributeNumeric["stickerDamagePerTick"], TIER_UPGRADE_SET_10_AS_IS, 4)
spitterAttributeNumeric["damage"] = calculateValuesForLevels(spitterAttributeNumeric["damage"], TIER_UPGRADE_SET_10_AS_IS, 2)
spitterAttributeNumeric["scale"] = calculateValuesForLevels(spitterAttributeNumeric["scale"], TIER_UPGRADE_SET_10_AS_IS, 2)
spitterAttributeNumeric["healing"] = calculateValuesForLevels(spitterAttributeNumeric["healing"], TIER_UPGRADE_SET_10_AS_IS, 4)
spitterAttributeNumeric["physicalDecrease"] = calculateValuesForLevels(spitterAttributeNumeric["physicalDecrease"], TIER_UPGRADE_SET_10_AS_IS, 2)
spitterAttributeNumeric["health"] = calculateValuesForLevels(spitterAttributeNumeric["health"], TIER_UPGRADE_SET_10_AS_IS, 0)
spitterAttributeNumeric["pollutionToAttack"] = calculateValuesForLevels(spitterAttributeNumeric["pollutionToAttack"], TIER_UPGRADE_SET_10_AS_IS, 0)
spitterAttributeNumeric["spawningTimeModifer"] = calculateValuesForLevels(spitterAttributeNumeric["spawningTimeModifer"], TIER_UPGRADE_SET_10_AS_IS, 1)
-- - !КДА 2021.11

local droneAttributeNumeric = {
    ["scale"] = { 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4 },			-- { 0.3, 0.32, 0.34, 0.36, 0.4, 0.42, 0.44, 0.5, 0.52, 0.54 }
    ["particleVerticalAcceleration"] = { 0.01, 0.01, 0.02, 0.02, 0.03, 0.03, 0.04, 0.04, 0.05, 0.05 },
    ["particleHoizontalSpeed"] = { 0.6, 0.6, 0.7, 0.7, 0.8, 0.8, 0.9, 0.9, 1, 1 },
    ["particleHoizontalSpeedDeviation"] = { 0.0025, 0.0025, 0.0024, 0.0024, 0.0023, 0.0023, 0.0022, 0.0022, 0.0021, 0.0021 },
    ["stickerDuration"] = { 600, 610, 620, 630, 640, 650, 660, 670, 680, 690 },
    ["stickerMovementModifier"] = { 0.8, 0.8, 0.75, 0.75, 0.7, 0.7, 0.65, 0.65, 0.5, 0.5 },
    ["damagePerTick"] = { 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1 },
    ["cooldown"] = { 60, 60, 55, 55, 50, 50, 45, 45, 40, 40 },
    ["warmup"] = { 20, 19, 18, 17, 16, 15, 14, 13, 12, 11 },
    ["ttl"] = { 300, 300, 350, 350, 400, 400, 450, 450, 500, 500 },
    ["damage"] = { 2, 4, 7, 13, 15, 18, 22, 28, 35, 40 },
    -- ["movement"] = { 0.06, 0.06, 0.07, 0.07, 0.08, 0.08, 0.09, 0.09, 0.1, 0.1 },
    ["movement"] = { 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2 },
    ["distancePerFrame"] = { 0.1, 0.1, 0.105, 0.105, 0.110, 0.110, 0.112, 0.112, 0.114, 0.114 },
    -- ["rangeFromPlayer"] = { 9, 9, 10, 10, 11, 11, 12, 12, 13, 13 },
    ["rangeFromPlayer"] = { 14, 15, 16, 17, 18, 19, 20, 21, 22, 23 },
    ["range"] = { 10, 10, 11, 11, 12, 12, 13, 13, 14, 14 },
    ["radius"] = { 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0, 2.5 },
    ["health"] = { 15, 75, 100, 150, 200, 250, 275, 300, 325, 350 },
    ["healing"] = { 0.01, 0.01, 0.015, 0.02, 0.05, 0.075, 0.1, 0.12, 0.14, 0.16 },
}

-- + !КДА 2021.11
--recalculateTableForEffectiveLevel(droneAttributeNumeric,TIER_UPGRADE_SET_10_AS_IS,nil,nil,{cooldown="", warmup="", range="", rangeFromPlayer=""})	-- + !КДА 2021.11
droneAttributeNumeric["damagePerTick"] = calculateValuesForLevels(droneAttributeNumeric["damagePerTick"], TIER_UPGRADE_SET_10_AS_IS, 2)
droneAttributeNumeric["damage"] = calculateValuesForLevels(droneAttributeNumeric["damage"], TIER_UPGRADE_SET_10_AS_IS, 0)
droneAttributeNumeric["health"] = calculateValuesForLevels(droneAttributeNumeric["health"], TIER_UPGRADE_SET_10_AS_IS, 0)
droneAttributeNumeric["healing"] = calculateValuesForLevels(droneAttributeNumeric["healing"], TIER_UPGRADE_SET_10_AS_IS, 0)
-- - !КДА 2021.11


local eggsAttributeNumeric = {
    ["scale"] = { 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6 },
    ["stickerDuration"] = { 600, 600, 600, 600, 600, 600, 600, 600, 600, 600 },
    ["stickerMovementModifier"] = { 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6 },
    ["damagePerTick"] = { 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1 },
    ["cooldown"] = { 60, 60, 60, 60, 60, 60, 60, 60, 60, 60 },
    ["warmup"] = { 20, 19, 18, 17, 16, 15, 14, 13, 12, 11 },
    ["ttl"] = { 300, 300, 300, 300, 300, 300, 300, 280, 260, 240 },
    ["damage"] = { 2, 4, 7, 13, 15, 18, 22, 28, 30, 30 },
    ["movement"] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    ["health"] = { 15, 75, 150, 300, 450, 600, 750, 1000, 1500, 3000 },
}
eggsAttributeNumeric["damagePerTick"] = calculateValuesForLevels(eggsAttributeNumeric["damagePerTick"], TIER_UPGRADE_SET_10_AS_IS, 2)
eggsAttributeNumeric["ttl"] = calculateValuesForLevels(eggsAttributeNumeric["ttl"], TIER_UPGRADE_SET_10_AS_IS, 0)
eggsAttributeNumeric["damage"] = calculateValuesForLevels(eggsAttributeNumeric["damage"], TIER_UPGRADE_SET_10_AS_IS, 0)
eggsAttributeNumeric["health"] = calculateValuesForLevels(eggsAttributeNumeric["health"], TIER_UPGRADE_SET_10_AS_IS, 0)

local unitSpawnerAttributeNumeric = {
    ["health"] = { 350, 500, 750, 1000, 1500, 3500, 11000, 20000, 30000, 45000 },
    ["healing"] = { 0.02, 0.02, 0.022, 0.024, 0.026, 0.028, 0.03, 0.032, 0.034, 0.036 },
    ["spawningCooldownStart"] = { 1080, 1075, 1020, 1015, 950, 940, 920, 910, 900, 880 },
    ["spawningCooldownEnd"] = { 350, 335, 320, 310, 300, 290, 280, 270, 260, 250 },
    ["unitsToSpawn"] = { 11, 11, 10, 10, 9, 9, 8, 8, 8, 7 },
    ["scale"] = { 0.5, 0.6, 0.7, 0.8, 0.9, 1, 1.2, 1.4, 1.6, 1.8 },
    ["unitsOwned"] = { 9, 9, 9, 9, 9, 8, 8, 8, 8, 7 },
    ["physicalDecrease"] = { 1, 2, 3, 4, 6, 6, 8, 10, 12, 14 },
    ["physicalPercent"] = { 15, 15, 17, 17, 18, 18, 19, 19, 20, 20 },
    ["explosionDecrease"] = { 5, 5, 6, 6, 7, 7, 8, 8, 9, 9 },
    ["explosionPercent"] = { 15, 15, 17, 17, 18, 18, 19, 19, 20, 20 },
    ["fireDecrease"] = { 3, 3, 4, 4, 4, 4, 4, 4, 5, 5 },
    ["firePercent"] = { 40, 40, 42, 42, 43, 43, 44, 44, 45, 45 },
    ["evolutionRequirement"] = { 0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9 },
    ["cooldown"] = { 50, 50, 45, 45, 40, 40, 35, 35, 30, 30 }
}
-- + !КДА 2021.11
unitSpawnerAttributeNumeric["health"] = calculateValuesForLevels(unitSpawnerAttributeNumeric["health"], TIER_UPGRADE_SET_10_AS_IS, 0)
unitSpawnerAttributeNumeric["healing"] = calculateValuesForLevels(unitSpawnerAttributeNumeric["healing"], TIER_UPGRADE_SET_10_AS_IS, 4)
unitSpawnerAttributeNumeric["scale"] = calculateValuesForLevels(unitSpawnerAttributeNumeric["scale"], TIER_UPGRADE_SET_10_AS_IS, 2)
unitSpawnerAttributeNumeric["physicalDecrease"] = calculateValuesForLevels(unitSpawnerAttributeNumeric["physicalDecrease"], TIER_UPGRADE_SET_10_AS_IS, 2)
unitSpawnerAttributeNumeric["explosionDecrease"] = calculateValuesForLevels(unitSpawnerAttributeNumeric["explosionDecrease"], TIER_UPGRADE_SET_10_AS_IS, 2)
unitSpawnerAttributeNumeric["fireDecrease"] = calculateValuesForLevels(unitSpawnerAttributeNumeric["fireDecrease"], TIER_UPGRADE_SET_10_AS_IS, 2)
-- - !КДА 2021.11

local hiveAttributeNumeric = {
    ["health"] = { 1000, 1500, 2000, 3000, 4500, 15000, 22000, 40000, 60000, 90000 },
    ["healing"] = { 0.02, 0.02, 0.022, 0.024, 0.026, 0.028, 0.03, 0.032, 0.034, 0.036 },
    ["spawningCooldownStart"] = {180, 180, 180, 180, 180, 180, 180, 180, 180, 180 },
    ["spawningCooldownEnd"] = { 60, 60, 60, 60, 60, 60, 60, 60, 60, 60 },
    ["unitsToSpawn"] = { 12, 12, 12, 12, 12, 12, 12, 12, 12, 12 },
    ["scale"] = { 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0, 2.1 },
    ["unitsOwned"] = { 9, 9, 9, 9, 9, 9, 9, 9, 9, 9 },
    ["physicalDecrease"] = { 1, 2, 3, 4, 6, 6, 8, 10, 12, 14 },
    ["physicalPercent"] = { 15, 15, 17, 17, 18, 18, 19, 19, 20, 20 },
    ["explosionDecrease"] = { 5, 5, 6, 6, 7, 7, 8, 8, 9, 9 },
    ["explosionPercent"] = { 15, 15, 17, 17, 18, 18, 19, 19, 20, 20 },
    ["fireDecrease"] = { 3, 3, 4, 4, 4, 4, 4, 4, 5, 5 },
    ["firePercent"] = { 40, 40, 42, 42, 43, 43, 44, 44, 45, 45 },
    ["evolutionRequirement"] = { 0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9 },
    ["cooldown"] = { 50, 50, 45, 45, 40, 40, 35, 35, 30, 30 }
}
-- + !КДА 2021.11
hiveAttributeNumeric["health"] = calculateValuesForLevels(hiveAttributeNumeric["health"], TIER_UPGRADE_SET_10_AS_IS, 0)
hiveAttributeNumeric["healing"] = calculateValuesForLevels(hiveAttributeNumeric["healing"], TIER_UPGRADE_SET_10_AS_IS, 4)
hiveAttributeNumeric["scale"] = calculateValuesForLevels(hiveAttributeNumeric["scale"], TIER_UPGRADE_SET_10_AS_IS, 2)
hiveAttributeNumeric["physicalDecrease"] = calculateValuesForLevels(hiveAttributeNumeric["physicalDecrease"], TIER_UPGRADE_SET_10_AS_IS, 2)
hiveAttributeNumeric["explosionDecrease"] = calculateValuesForLevels(hiveAttributeNumeric["explosionDecrease"], TIER_UPGRADE_SET_10_AS_IS, 2)
hiveAttributeNumeric["fireDecrease"] = calculateValuesForLevels(hiveAttributeNumeric["fireDecrease"], TIER_UPGRADE_SET_10_AS_IS, 2)
-- - !КДА 2021.11


local wormAttributeNumeric = {
    ["stickerDuration"] = { 800, 810, 820, 830, 840, 850, 860, 870, 880, 890 },
    ["stickerMovementModifier"] = { 0.8, 0.8, 0.75, 0.75, 0.7, 0.7, 0.65, 0.65, 0.5, 0.5 },
    ["damagePerTick"] = { 0.15, 0.3, 0.4, 0.6, 0.7, 0.8, 1, 1.2, 1.5, 2 },		-- { 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1 }
    ["range"] = { 25, 27, 31, 33, 35, 36, 37, 38, 39, 40 },
--    ["cooldown"] = { 70, 70, 68, 66, 64, 62, 60, 58, 56, 54 },
    ["cooldown"] = { 60, 55, 50, 48, 44, 40, 36, 34, 32, 30 },
    ["damage"] = { 12, 22.5, 33.75, 45, 67.5, 82.5, 97.5, 112.5, 127.5, 142.5 },
    ["scale"] = { 0.60, 0.80, 0.90, 1, 1.1, 1.2, 1.3, 1.4, 1.6, 1.8 },	--{ 0.40, 0.50, 0.60, 0.8, 0.9, 1, 1.2, 1.4, 1.6, 1.8 }
    ["radius"] = { 1.5, 1.6, 1.7, 1.8, 1.9, 2.0, 2.2, 2.3, 2.5, 3.0 },
    ["stickerDamagePerTick"] = { 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5 },
    ["particleVerticalAcceleration"] = { 0.01, 0.01, 0.02, 0.02, 0.03, 0.03, 0.04, 0.04, 0.05, 0.05 },
    ["particleHoizontalSpeed"] = { 0.6, 0.6, 0.7, 0.7, 0.8, 0.8, 0.9, 0.9, 1, 1 },
    ["particleHoizontalSpeedDeviation"] = { 0.0025, 0.0025, 0.0024, 0.0024, 0.0023, 0.0023, 0.0022, 0.0022, 0.0021, 0.0021 },
--    ["foldingSpeed"] = { 0.15, 0.15, 0.16, 0.16, 0.16, 0.17, 0.17, 0.18, 0.18, 0.19 },
    ["preparingSpeed"] = { 0.025, 0.025, 0.026, 0.026, 0.027, 0.027, 0.028, 0.028, 0.029, 0.029 },
    ["prepareRange"] = { 30, 30, 35, 35, 40, 40, 40, 40, 45, 45 },
    ["physicalDecrease"] = { 0, 0, 5, 5, 8, 8, 10, 10, 12, 12 },
    ["explosionDecrease"] = { 0, 0, 5, 5, 8, 8, 10, 10, 12, 12 },
    ["explosionPercent"] = { 0, 0, 10, 10, 20, 20, 30, 30, 40, 40 },
    ["fireDecrease"] = { 3, 3, 4, 4, 5, 5, 5, 5, 5, 6 },
    ["health"] = { 200, 500, 800, 1400, 2500, 3500, 7500, 12000, 20000, 25000 },
    ["firePercent"] = { 40, 40, 42, 42, 43, 43, 44, 44, 45, 45 },
    ["healing"] = { 0.01, 0.01, 0.015, 0.02, 0.05, 0.075, 0.1, 0.12, 0.14, 0.16 },
    ["evolutionRequirement"] = { 0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9 }
}

wormAttributeNumeric["damagePerTick"] = calculateValuesForLevels(wormAttributeNumeric["damagePerTick"], TIER_UPGRADE_SET_10_AS_IS, 4)
wormAttributeNumeric["damage"] = calculateValuesForLevels(wormAttributeNumeric["damage"], TIER_UPGRADE_SET_10_AS_IS, 1)
wormAttributeNumeric["scale"] = calculateValuesForLevels(wormAttributeNumeric["scale"], TIER_UPGRADE_SET_10_AS_IS, 2)
wormAttributeNumeric["stickerDamagePerTick"] = calculateValuesForLevels(wormAttributeNumeric["stickerDamagePerTick"], TIER_UPGRADE_SET_10_AS_IS, 4)
wormAttributeNumeric["physicalDecrease"] = calculateValuesForLevels(wormAttributeNumeric["physicalDecrease"], TIER_UPGRADE_SET_10_AS_IS, 2)
wormAttributeNumeric["explosionDecrease"] = calculateValuesForLevels(wormAttributeNumeric["explosionDecrease"], TIER_UPGRADE_SET_10_AS_IS, 2)
wormAttributeNumeric["fireDecrease"] = calculateValuesForLevels(wormAttributeNumeric["fireDecrease"], TIER_UPGRADE_SET_10_AS_IS, 2)
wormAttributeNumeric["health"] = calculateValuesForLevels(wormAttributeNumeric["health"], TIER_UPGRADE_SET_10_AS_IS, 0)
wormAttributeNumeric["healing"] = calculateValuesForLevels(wormAttributeNumeric["healing"], TIER_UPGRADE_SET_10_AS_IS, 4)

local propTables10 = {
     {{0, 1}, {0.27, 0.0}},
    {{0.15, 1}, {0.38, 0.0}},
    {{0.27, 1}, {0.47, 0.0}},
    {{0.38, 1}, {0.56, 0.0}},
    {{0.47, 1}, {0.65, 0.0}},
    {{0.56, 1}, {0.74, 0.0}},
    {{0.65, 1}, {0.82, 0.0}},
    {{0.74, 1}, {0.91, 0.0}},
    {{0.82, 1}, {1, 0.0}},
    {{0.91, 1}, {1, 1.0}}
	}	


local function fillUnitTable(result, unitSet, tier, probability)
    for x=1,#unitSet[tier] do
        result[#result+1] = {unitSet[tier][x], probability}
    end
end

local function unitSetToProbabilityTable(unitSet)	-- biters per evo
    local result = {}
	local tierEnd = settings.startup["rampantFixed--tierEnd"].value	
	local evoOffset = mMax(tierEnd-5, 0)*0.02
	
    fillUnitTable(result, unitSet, 1, {{0, 1}, {0.40, 0.0}})
    fillUnitTable(result, unitSet, 2, {{0.10+evoOffset*0.5, 0}, {0.25+evoOffset, 0.5}, {0.50, 0.0}})		
    fillUnitTable(result, unitSet, 3, {{0.22+evoOffset*0.5, 0}, {0.45+evoOffset*0.5, 0.5}, {0.60, 0.0}})
    fillUnitTable(result, unitSet, 4, {{0.38, 0}, {0.55+evoOffset, 0.5}, {0.70+evoOffset, 0.0}})
    fillUnitTable(result, unitSet, 5, {{0.47, 0}, {0.65+evoOffset, 0.5}, {0.80+evoOffset, 0.0}})
    fillUnitTable(result, unitSet, 6, {{0.65, 0}, {0.75+(evoOffset*0.5), 0.5}, {0.975, 0.0}})
    fillUnitTable(result, unitSet, 7, {{0.74, 0}, {0.825+(evoOffset*0.5), 0.5}, {0.975, 0.0}})
    fillUnitTable(result, unitSet, 8, {{0.80, 0}, {0.875, 0.5}, {0.98, 0.0}})
    fillUnitTable(result, unitSet, 9, {{0.85, 0}, {0.925, 0.5}, {0.99, 0.0}})
    fillUnitTable(result, unitSet, 10, {{0.91, 0}, {1, 1.0}})


    return result
end

local function unitSetToHiveProbabilityTable(unitSet)		-- +1 lvl
    local result = {}
	local tierEnd = settings.startup["rampantFixed--tierEnd"].value
	local evoOffset = mMax(tierEnd-5, 0)*0.02
	
    fillUnitTable(result, unitSet, 1, {{0, 1}, {0.15, 0.0}})
    fillUnitTable(result, unitSet, 2, {{0.00, 0}, {0.15, 0.5}, {0.27, 0.0}})		
    fillUnitTable(result, unitSet, 3, {{0.15, 0}, {0.27, 0.5}, {0.38, 0.0}})		
    fillUnitTable(result, unitSet, 4, {{0.27, 0}, {0.38, 0.5}, {0.47, 0.0}})
    fillUnitTable(result, unitSet, 5, {{0.38, 0}, {0.47, 0.5}, {0.65, 0.0}})
    fillUnitTable(result, unitSet, 6, {{0.47, 0}, {0.65, 0.5}, {0.74, 0.0}})
    fillUnitTable(result, unitSet, 7, {{0.65, 0}, {0.74, 0.5}, {0.85, 0.0}})
    fillUnitTable(result, unitSet, 8, {{0.74, 0}, {0.80, 0.5}, {0.95, 0.0}})
    fillUnitTable(result, unitSet, 9, {{0.80, 0}, {0.85, 0.5}, {0.98, 0.0}})
    fillUnitTable(result, unitSet, 10, {{0.85, 0}, {1, 1.0}})
    return result
	
end


local function addImmunity(entity, name)
	entity.resistances[name] = {decrease = 0, percent = 100}
end

local function addExtremeResistance(entity, name)
	entity.resistances[name] = {decrease = 3, percent = 99.99}
end

local function addMajorResistance(entity, name, tier)
    local decreases = { 5, 6, 7, 10, 13, 14, 16, 17, 19, 23 }	-- { 7, 7, 10, 10, 13, 13, 16, 16, 19, 23 }
	decreases = calculateValuesForLevels(decreases, TIER_UPGRADE_SET_10_AS_IS, 0)
	
    local percents = { 80, 80, 84, 86, 88, 90, 92, 92, 92, 93 }
	entity.resistances[name] = {decrease = decreases[tier], percent = percents[tier]}
end

local function addMinorResistance(entity, name, tier)
     local decreases = { 3, 4, 7, 10, 12, 12, 13, 13, 16, 18 }	
	decreases = calculateValuesForLevels(decreases, TIER_UPGRADE_SET_10_AS_IS, 0)
    local percents = { 35, 35, 40, 40, 45, 45, 50, 55, 60, 65 }
	entity.resistances[name] = {decrease = decreases[tier], percent = percents[tier]}
end

local function addLesserResistance(entity, name, tier)
     local decreases = { 3, 4, 7, 10, 12, 12, 13, 13, 16, 18 }	
	decreases = calculateValuesForLevels(decreases, TIER_UPGRADE_SET_10_AS_IS, 0)
    local percents = { 0, 5, 10, 15, 20, 25, 30, 30, 30, 35 }
	entity.resistances[name] = {decrease = decreases[tier], percent = percents[tier]}
end

local function addMajorWeakness(entity, name, tier)
    local decreases ={ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	decreases = calculateValuesForLevels(decreases, TIER_UPGRADE_SET_10_AS_IS, 0)
    local percents = { -100, -100, -100, -100, -100, -100, -100, -100, -100, -100 }	
	entity.resistances[name] = {decrease = decreases[tier], percent = percents[tier]}
end

local function addMinorWeakness(entity, name, tier)
    local decreases = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }				--	{ -3, -3, -7, -7, -10, -10, -13, -13, -16, -18 }
	decreases = calculateValuesForLevels(decreases, TIER_UPGRADE_SET_10_AS_IS, 0)
    local percents = { -50, -50, -50, -50, -50, -50, -50, -50, -50, -50 }	-- { -35, -35, -40, -40, -45, -45, -50, -55, -55, -60 }
	entity.resistances[name] = {decrease = decreases[tier], percent = percents[tier]}
end

local function scaleAttributes (entity)
    if (entity.type == "biter") then
		entity["health"] = entity["health"] * settings.startup["rampantFixed--unitBiterHealthScaler"].value
        entity["movement"] = entity["movement"] * settings.startup["rampantFixed--unitBiterSpeedScaler"].value
        entity["distancePerFrame"] = entity["distancePerFrame"] * settings.startup["rampantFixed--unitBiterSpeedScaler"].value
        entity["damage"] = entity["damage"] * settings.startup["rampantFixed--unitBiterDamageScaler"].value
        entity["range"] = entity["range"] * settings.startup["rampantFixed--unitBiterRangeScaler"].value
        entity["healing"] = entity["healing"] * settings.startup["rampantFixed--unitBiterHealingScaler"].value
    elseif (entity.type == "spitter") then
        entity["health"] = entity["health"] * settings.startup["rampantFixed--unitSpitterHealthScaler"].value
        entity["movement"] = entity["movement"] * settings.startup["rampantFixed--unitSpitterSpeedScaler"].value
        entity["distancePerFrame"] = entity["distancePerFrame"] * settings.startup["rampantFixed--unitSpitterSpeedScaler"].value
        entity["damage"] = entity["damage"] * settings.startup["rampantFixed--unitSpitterDamageScaler"].value
        if entity["stickerDamagePerTick"] then
            entity["stickerDamagePerTick"] = entity["stickerDamagePerTick"] * settings.startup["rampantFixed--unitSpitterDamageScaler"].value
        end
        entity["damagePerTick"] = entity["damagePerTick"] * settings.startup["rampantFixed--unitSpitterDamageScaler"].value
        entity["range"] = entity["range"] * settings.startup["rampantFixed--unitSpitterRangeScaler"].value
        entity["healing"] = entity["healing"] * settings.startup["rampantFixed--unitSpitterHealingScaler"].value
    elseif (entity.type == "drone") then
        entity["health"] = entity["health"] * settings.startup["rampantFixed--unitDroneHealthScaler"].value
        entity["movement"] = entity["movement"] * settings.startup["rampantFixed--unitDroneSpeedScaler"].value
        entity["distancePerFrame"] = entity["distancePerFrame"] * settings.startup["rampantFixed--unitDroneSpeedScaler"].value
        entity["damage"] = entity["damage"] * settings.startup["rampantFixed--unitDroneDamageScaler"].value
        entity["damagePerTick"] = entity["damagePerTick"] * settings.startup["rampantFixed--unitDroneDamageScaler"].value
        entity["range"] = entity["range"] * settings.startup["rampantFixed--unitDroneRangeScaler"].value
        entity["healing"] = entity["healing"] * settings.startup["rampantFixed--unitDroneHealingScaler"].value
    elseif (entity.type == "biter-spawner") or (entity.type == "spitter-spawner") then
        entity["health"] = entity["health"] * settings.startup["rampantFixed--unitSpawnerHealthScaler"].value
        entity["unitsOwned"] = entity["unitsOwned"] * settings.startup["rampantFixed--unitSpawnerOwnedScaler"].value
        entity["unitsToSpawn"] = entity["unitsToSpawn"] * settings.startup["rampantFixed--unitSpawnerSpawnScaler"].value
        entity["spawningCooldownStart"] = entity["spawningCooldownStart"] * settings.startup["rampantFixed--unitSpawnerRespawnScaler"].value
        entity["spawningCooldownEnd"] = entity["spawningCooldownEnd"] * settings.startup["rampantFixed--unitSpawnerRespawnScaler"].value
        entity["healing"] = entity["healing"] * settings.startup["rampantFixed--unitSpawnerHealingScaler"].value
    elseif (entity.type == "turret") then
        entity["health"] = entity["health"] * settings.startup["rampantFixed--unitWormHealthScaler"].value
        entity["damage"] = entity["damage"] * settings.startup["rampantFixed--unitWormDamageScaler"].value
        entity["damagePerTick"] = entity["damagePerTick"] * settings.startup["rampantFixed--unitWormDamageScaler"].value
        entity["range"] = entity["range"] * settings.startup["rampantFixed--unitWormRangeScaler"].value
        entity["prepareRange"] = entity["prepareRange"] * settings.startup["rampantFixed--unitWormRangeScaler"].value	-- + !КДА 2021.11	
        entity["healing"] = entity["healing"] * settings.startup["rampantFixed--unitWormHealingScaler"].value
    elseif (entity.type == "hive") then
        entity["health"] = entity["health"] * settings.startup["rampantFixed--unitHiveHealthScaler"].value
        entity["healing"] = entity["healing"] * settings.startup["rampantFixed--unitHiveHealingScaler"].value
        entity["spawningCooldownStart"] = entity["spawningCooldownStart"] * settings.startup["rampantFixed--unitHiveRespawnScaler"].value
        entity["spawningCooldownEnd"] = entity["spawningCooldownEnd"] * settings.startup["rampantFixed--unitHiveRespawnScaler"].value
    end
end

local lootTables = {}
lootTables[1] = makeSchallAlienLootTables()
lootTables[2] = makeAlienLootEconomyTables()

local function fillEntityTemplate(entity)
    local tier = entity.effectiveLevel
	local allowLongRangeImmunity = settings.startup["rampantFixed--allowLongRangeImmunity"].value
	local allowOneshotProtection = settings.startup["rampantFixed--allowOneshotProtection"].value
	local buildingsImmuneToElectic = settings.startup["rampantFixed--buildingsImmuneToElectic"].value

	entity.noLoot = false
	
    if (entity.type == "biter") then
        for key,value in pairs(biterAttributeNumeric) do
			if not entity[key] then
				entity[key] = value[tier]
			else
				entity[key] = entity[key][tier]
			end
        end
    elseif (entity.type == "spitter") then
        for key,value in pairs(spitterAttributeNumeric) do
			if not entity[key] then
				entity[key] = value[tier]
			else
				entity[key] = entity[key][tier]
			end
       end
    elseif (entity.type == "biter-spawner") or (entity.type == "spitter-spawner") then
        for key,value in pairs(unitSpawnerAttributeNumeric) do
			if not entity[key] then
				entity[key] = value[tier]
			else
				entity[key] = entity[key][tier]
			end
        end
    elseif (entity.type == "hive") then
        for key,value in pairs(hiveAttributeNumeric) do
			if not entity[key] then
				entity[key] = value[tier]
			else
				entity[key] = entity[key][tier]
			end
        end
    elseif (entity.type == "turret") then
        for key,value in pairs(wormAttributeNumeric) do
			if not entity[key] then
				entity[key] = value[tier]
			else
				entity[key] = entity[key][tier]
			end
        end
    elseif (entity.type == "drone") then
        for key,value in pairs(droneAttributeNumeric) do
			if not entity[key] then
				entity[key] = value[tier]
			else
				entity[key] = entity[key][tier]
			end
        end
    end
	
	if buildingsImmuneToElectic and ((entity.type == "turret") or (entity.type == "hive") or (entity.type == "biter-spawner") or (entity.type == "spitter-spawner")) then	
		entity.resistances["electric"] = {decrease = 0, percent = 100}
	end	


    for k,v in pairs(entity) do
        local startDecrease = string.find(k, "Decrease")
        local startPercent = string.find(k, "Percent")
        if startDecrease or startPercent then
            local damageType = string.sub(k, 1, (startDecrease or startPercent)-1)
            if not entity.resistances[damageType] then
                entity.resistances[damageType] = {}
            end

            if startDecrease then
                entity.resistances[damageType].decrease = v
            elseif startPercent then
                entity.resistances[damageType].percent = v
            end
        end
    end

    for i=1,#entity.addon do
        for k,v in pairs(entity.addon[i]) do
            entity[k] = v[tier]
        end
    end

    for key, value in pairs(entity) do
        if (key == "drops") then
            if not entity.loot then
                entity.loot = {}
            end
            for _,lootTable in pairs(entity.drops) do
                entity.loot[#entity.loot+1] = lootTable[tier]
            end
        elseif (key == "explosion") then
            local ti = tier
            if (entity.type == "drone") then
                ti = 1
            end
            entity["hitSprayName"] = entity[key] .. "-" .. "damaged-fountain-rampant"
            entity[key] = entity[key] .. "-" .. bloodFountains[ti]
        elseif (key == "evolutionFunction") then
            entity["evolutionRequirement"] = value(tier)
		elseif (key == "immunity") then	
            for i=1,#value do
				addImmunity(entity, value[i])
            end
 		elseif (key == "extremeResistances") then	
            for i=1,#value do
				addExtremeResistance(entity, value[i])
            end
       elseif (key == "majorResistances") then
            for i=1,#value do
                addMajorResistance(entity, value[i], tier)
            end
        elseif (key == "minorResistances") then
            for i=1,#value do
                addMinorResistance(entity, value[i], tier)
            end
         elseif (key == "lesserResistances") then
            for i=1,#value do
                addLesserResistance(entity, value[i], tier)
            end
       elseif (key == "majorWeaknesses") then
            for i=1,#value do
                addMajorWeakness(entity, value[i], tier)
            end
        elseif (key == "minorWeaknesses") then
            for i=1,#value do
                addMinorWeakness(entity, value[i], tier)
            end
        elseif (key == "explosionTiers") then
            entity.attackExplosion = entity.explosionTiers[tier]
            entity.attackScorchmark = entity.scorchmarkTiers[tier]
        elseif (key == "attributes") then
            for i=1,#entity[key] do
                local attribute = entity[key][i]
                if (attribute == "lowHealth") then
                    entity["health"] = entity["health"] * 0.75
                elseif (attribute == "lowestHealth") then
                    entity["health"] = entity["health"] * 0.50
                elseif (attribute == "slowCooldown") then
                    entity["cooldown"] = entity["cooldown"] * 1.50
                    entity["damage"] = entity["damage"] * 1.50
                    if entity["damagePerTick"] then
                        entity["damagePerTick"] = entity["damagePerTick"] * 1.5
                    end					
                elseif (attribute == "quickCooldown") then
                    entity["cooldown"] = entity["cooldown"] * 0.50
                    -- entity["damage"] = entity["damage"] * 0.65
                    if entity["damagePerTick"] then
                        entity["damagePerTick"] = entity["damagePerTick"] * 0.65
                    end
                elseif (attribute == "slowMovement") then
                    entity["movement"] = entity["movement"] * 0.35
                    entity["distancePerFrame"] = entity["distancePerFrame"] * 0.65
                elseif (attribute == "quickMovement") then
					local k = 1.1+(tier*0.03)
                    entity["movement"] = entity["movement"] * k	-- (1.25
                    entity["distancePerFrame"] = entity["distancePerFrame"] * (1.35*(k/1.25))	-- *1.35
                elseif (attribute == "quickSpawning") then
                    if entity["spawningCooldownStart"] then
                        entity["spawningCooldownStart"] = entity["spawningCooldownStart"] * 0.85
                        entity["spawningCooldownEnd"] = entity["spawningCooldownEnd"] * 0.85
                    end
                    if entity["spawningTimeModifer"] then
                        entity["spawningTimeModifer"] = entity["spawningTimeModifer"] * 0.85
                    end
                    if entity["pollutionToAttack"] then
                        entity["pollutionToAttack"] = entity["pollutionToAttack"] * 0.5
					end
                elseif (attribute == "altBiterArmored") then
                    entity["altBiter"] = "armored"
                elseif (attribute == "altBiterArachnid") then
                    entity["altBiter"] = "arachnid"				
                elseif (attribute == "highRegen") then
                    entity["healing"] = entity["healing"] * 1.5
                elseif (attribute == "highestRegen") then
                    entity["healing"] = entity["healing"] * 3.5
                elseif (attribute == "big") then
                    entity["scale"] = entity["scale"] * 1.2
                elseif (attribute == "bigger") then
                    entity["scale"] = entity["scale"] * 1.35
                elseif (attribute == "lowestCollision") then
                    entity["collisionModifier"] = 0.1
                elseif (attribute == "noCollision") then
                    entity["collisionModifier"] = 0
                elseif (attribute == "addReach") then
                    entity["range"] = entity["range"] * 1.5
                elseif (attribute == "longReach") then
                    entity["range"] = entity["range"] * 3
                elseif (attribute == "largePrepRange") then
					if entity["prepareRange"] then
						entity["prepareRange"] = entity["prepareRange"] + 5
					end	
                elseif (attribute == "smallest") then
                    entity["scale"] = entity["scale"] * 0.5
                elseif (attribute == "fragile") then
                    entity["health"] = entity["health"] * 0.1
                elseif (attribute == "selfDamaging") then
                    local divider
                    if entity.health < 100 then
                        divider = 2
                    else
                        divider = 2.5
                    end
                    entity.healthDamage = entity.health / divider
                    entity.sourceEffect = function (attributes)
                        return
                            {
                                {
                                    type = "damage",
                                    affects_target = true,
                                    damage = {amount = attributes.healthDamage or 5, type = attributes.damageType or "physical"}
                                }
                            }
                    end
                elseif (attribute == "killsSelf") then
                    entity.healthDamage = entity.health * 3
                elseif (attribute == "unstable") then
                    entity["healing"] = -0.0033 * entity["health"]
                elseif (attribute == "checkBuildability") then
                    entity.checkBuildability = true
                elseif (attribute == "followsPlayer") then
                    entity.followsPlayer = true
                elseif (attribute == "stationary") then
                    entity.movement = 0
                    entity.distancePerFrame = 0
				elseif (attribute == "egg") then
					for key,value in pairs(eggsAttributeNumeric) do
						entity[key] = value[tier]
					end
				
                elseif (attribute == "highHealth") then
                    entity["health"] = entity["health"] * 1.50
                elseif (attribute == "poisonDeathCloud") then
                    entity.dyingEffect = {
                        type = "create-entity",
                        entity_name = "poison-cloud-v" .. tier .. "-cloud-rampant"
                    }
                elseif (attribute == "fireDeathCloud") then
                    entity.dyingEffect = {
                        type = "create-entity",
                        entity_name = "fire-cloud-Dmg"..tier.."-cloud-rampant"
                    }
                elseif (attribute == "highestHealth") then
                    entity["health"] = entity["health"] * 2
                elseif type(attribute) == "table" then
                    if (attribute[1] == "clusterDeath") then
                        entity.deathGenerator = function (attack)
							if (attribute[3] or attack.clusters) == 1 then
								return {
									{
										type = "direct",
										action_delivery =
											{
												type = "instant",
												source_effects = {
													{
													type = "create-entity",
													entity_name = attack.faction .. "-" .. attribute[2]
																						 .. "-v" .. attack.variation .. "-t"
																						 .. attack.effectiveLevel .. "-rampant",
													repeat_count = attribute[4] or 1,
													}
												}
											}
									}
								}
							else
								return {
									{
										type = "cluster",
										cluster_count = attribute[3] or attack.clusters,
										distance = attack.clusterDistance,
										distance_deviation = 3,
										action_delivery =
											{
												type = "projectile",
												projectile = createCapsuleProjectile(attack,
																					 attack.faction .. "-" .. attribute[2]
																						 .. "-v" .. attack.variation .. "-t"
																						 .. attack.effectiveLevel .. "-rampant"),
												direction_deviation = 0.6,
												starting_speed = 0.25,
												max_range = attack.range,
												starting_speed_deviation = 0.3
											}
									}
								}
							end	
                        end
					elseif (attribute[1] == "spawnOnDestroyed") then	-- + !2022.10
 						local spawnLevel = entity.effectiveLevel + (attribute[3] or 0)	-- be careful: same unit and attribute[3]=0  ==> infinite respawn
						local entity_name
						if (spawnLevel<1) and (entity.effectiveLevel > 1) then
							spawnLevel = 1
						end
						if (spawnLevel>=1) or (spawnLevel<=10) then
							entity.deathGenerator = function (attack)
								return {
									{
									type = "create-entity",
									entity_name = entity.faction .. "-" .. attribute[2] .. "-v1-t" ..spawnLevel.. ((attribute[5] and ("-"..attribute[5])) or "") .. "-rampant",
									repeat_count = attribute[4] or 1,
									}
								}
							end
						end	
					elseif (attribute[1] == "spawnOnDeath") then	-- + !КДА 2021.11
						local spawnLevel = entity.effectiveLevel + (attribute[3] or 0)	-- be careful: same unit and attribute[3]=0  ==> infinite respawn
						if (spawnLevel<1) and (entity.effectiveLevel > 1) then
							spawnLevel = 1
						end
						if (spawnLevel<1) or (spawnLevel>10) then
							entity.dyingEffect = nil
						else	
							entity.dyingEffect = {
								type = "create-entity",
								entity_name = entity.faction .. "-" .. attribute[2] .. "-v1-t" ..spawnLevel.. ((attribute[5] and ("-"..attribute[5])) or "") .. "-rampant",
								repeat_count = attribute[4] or 1,
							}
						end	
					elseif (attribute[1] == "longRangeImmunity") then	-- + !КДА 2021.11
						if allowLongRangeImmunity then	
							entity.resistances["rampant-longRangeImmunity"] = {decrease = attribute[2], percent = settings.startup["rampantFixed--longRangeImmunity_efficiency"].value}
						end
					elseif (attribute[1] == "overdamageProtection") then	-- + !КДА 2021.11
						if allowOneshotProtection then
							local maxDamage = mMax(entity["health"]/attribute[2], OVERDAMAGEPROTECTION_THRESHOLD)
							entity.resistances["rampant-overdamageProtection"] = {decrease = maxDamage, percent = settings.startup["rampantFixed--oneshotProtection_efficiency"].value}
						end	
					elseif (attribute[1] == "movement") then	-- + !КДА 2021.12
						entity["movement"] = entity["movement"] * attribute[2]
						if attribute[2]<1 then
							local k = 1 - ((1 - attribute[2]) / 2)
							entity["distancePerFrame"] = entity["distancePerFrame"] * k
						elseif attribute[2]>1 then
							local k = 1 + ((attribute[2] - 1) / 2)
							entity["distancePerFrame"] = entity["distancePerFrame"] * k						
						end
					elseif (attribute[1] == "bonusRange") then	-- + !КДА 2021.11
						entity["range"] = entity["range"] + attribute[2]
					else
                        error("Unknown table attribute " .. attribute[1])
                    end
				elseif (attribute == "notInKillStatistics") then
					entity.additionalFlags[#entity.additionalFlags+1] = "not-in-kill-statistics"
				elseif (attribute == "not-flammable") then
					entity.additionalFlags[#entity.additionalFlags+1] = "not-flammable"
				elseif (attribute == "noLoot") then
					entity.noLoot = true
                else
                    error("Unknown attribute " .. attribute)
                end
            end
        end
    end

    -- print(serpent.dump(entity))
    scaleAttributes(entity)
end

local function generateApperance(unit)
    local tier = unit.effectiveLevel
    if unit.scale then
		unit.scale = unit.scale[tier]
    end
end

local function addEntityLoot(entity, lootType, effectiveLevel)
	for _, lootTable in pairs(lootTables) do
		local entityLoot = lootTable[lootType] and lootTable[lootType][effectiveLevel]
		if entityLoot then
			if not entity.loot then
				entity.loot = {}
			end	
			for lootIndex = 1, #entityLoot do
				entity.loot[#entity.loot+1] = entityLoot[lootIndex]
			end		
		end
	end		
end

function swarmUtils.buildUnits(template, dyingEffects)
    local unitSet = {}

    local variations = settings.startup["rampantFixed--newEnemyVariations"].value

    for tier=1, 10 do
		--local effectiveLevel = TIER_UPGRADE_SET_10[tier]
        local effectiveLevel = tier	-- + !КДА 2021.11
		local result = {}

        for i=1,variations do
            local unit = deepcopy(template)
            unit.name = unit.name .. "-v" .. i .. "-t" .. tier
            -- unit.nameSuffix = "-v" .. i .. "-t" .. tier
            unit.effectiveLevel = effectiveLevel
            unit.tier = tier
            unit.variation = i
            generateApperance(unit)
            fillEntityTemplate(unit)
            unit.attack = unit.attackGenerator(unit)
            unit.death = (unit.deathGenerator and unit.deathGenerator(unit)) or nil
			
            local entity
            if (unit.type == "spitter") then
                entity = makeSpitter(unit)
				if (not entity.noLoot) then
					addEntityLoot(entity, "biterLoot", effectiveLevel)
				end	
            elseif (unit.type == "biter") then
                entity = makeBiter(unit)
				if (not entity.noLoot) then
					addEntityLoot(entity, "biterLoot", effectiveLevel)
				end	
            elseif (unit.type == "drone") then
                -- if not unit.death then
                --     unit.death = {
                --         type = "direct",
                --         action_delivery =
                --             {
                --                 type = "instant",
                --                 target_effects =
                --                     {
                --                         type = "create-entity",
                --                         entity_name = "massive-explosion"
                --                     }
                --             }
                --     }
                -- end
                entity = makeDrone(unit)
            end
			if i == 1 then
				result[#result+1] = entity.name
			end	
			
			if unit.noLoot then
				entity.loot = nil
			end

			if entity.dying_trigger_effect then
				dyingEffects[#dyingEffects+1] = {dyingEffect = deepcopy(entity.dying_trigger_effect), type = entity.type, name = entity.name, effectType = "dying_trigger_effect"}
				entity.dying_trigger_effect = nil
			end
			if entity.destroy_action then
				dyingEffects[#dyingEffects+1] = {dyingEffect = deepcopy(entity.destroy_action), type = entity.type, name = entity.name, effectType = "destroy_action"}
				entity.destroy_action = nil
			end
			if data.raw[entity.type][entity.name] and data.raw[entity.type][entity.name].loot then
				log("rebuilding ".. entity.name.. ", saving existing loot")
				entity.loot = deepcopy(data.raw[entity.type][entity.name].loot)
			end
            data:extend({entity})			
        end

        unitSet[#unitSet+1] = result
    end
	
    return unitSet
end

function swarmUtils.buildEntitySpawner(template, factionBuildings)
    local variations = settings.startup["rampantFixed--newEnemyVariations"].value

    for tier=1, 10 do
        --local effectiveLevel = TIER_UPGRADE_SET_10[tier]
        local effectiveLevel = tier

        for i=1,variations do
            local unitSpawner = deepcopy(template)
            unitSpawner.name = unitSpawner.name .. "-v" .. i .. "-t" .. tier
            unitSpawner.effectiveLevel = effectiveLevel
			unitSpawner.tier = tier
            unitSpawner.variation = i
            unitSpawner.unitSet = unitSetToHiveProbabilityTable(template.unitSet)
            generateApperance(unitSpawner)
            fillEntityTemplate(unitSpawner)
			
			if (not unitSpawner.noLoot) then				
				addEntityLoot(unitSpawner, "spawnerLoot", effectiveLevel)
			end
			

            if unitSpawner.autoplace then
                unitSpawner.autoplace = unitSpawner.autoplace[effectiveLevel]
            end
						
            data:extend({
                    makeUnitSpawner(unitSpawner)
            })
        end
    end
end

function swarmUtils.buildUnitSpawner(template)
    local variations = settings.startup["rampantFixed--newEnemyVariations"].value

    for tier=1, 10 do
        --local effectiveLevel = TIER_UPGRADE_SET_10[tier]
        local effectiveLevel = tier

        for i=1,variations do
            local unitSpawner = deepcopy(template)
            unitSpawner.name = unitSpawner.name .. "-v" .. i .. "-t" .. tier
            unitSpawner.effectiveLevel = effectiveLevel
			unitSpawner.tier = tier
            unitSpawner.variation = i
            local unitTable = unitSetToProbabilityTable(template.unitSet)
            unitSpawner.unitSet = unitTable
            generateApperance(unitSpawner)
            fillEntityTemplate(unitSpawner)
			
			if (not unitSpawner.noLoot) then
				addEntityLoot(unitSpawner, "spawnerLoot", effectiveLevel)
			end

            if unitSpawner.autoplace then
                unitSpawner.autoplace = unitSpawner.autoplace[effectiveLevel]
            end

            data:extend({
                    makeUnitSpawner(unitSpawner)
            })
        end
    end
end

function swarmUtils.buildWorm(template)
    local variations = settings.startup["rampantFixed--newEnemyVariations"].value

    for tier=1, 10 do
        --local effectiveLevel = TIER_UPGRADE_SET_10[tier]
		local effectiveLevel = tier

        for i=1,variations do
            local worm = deepcopy(template)
            worm.name = worm.name .. "-v" .. i .. "-t" .. tier
            worm.effectiveLevel = effectiveLevel
			worm.tier = tier
            worm.variation = i
            generateApperance(worm)
            fillEntityTemplate(worm)
			
			if (not worm.noLoot) then
				addEntityLoot(worm, "wormLoot", effectiveLevel)
			end            
			
			worm.attack = worm.attackGenerator(worm)

            if worm.autoplace then
                worm.attributes["autoplace"] = worm.autoplace[effectiveLevel]
            end
            data:extend({
                    makeWorm(worm)
            })
        end
    end
end

local function makeLootTables(template)
    local makeLootTable
    if (template.type == "biter") or (template.type == "spitter") then
        makeLootTable = makeUnitAlienLootTable
    elseif (template.type == "worm") then
        makeLootTable = makeWormAlienLootTable
    elseif (template.type == "biter-spawner") or (template.type == "spitter-spawner") then
        makeLootTable = makeSpawnerAlienLootTable
    elseif (template.type == "hive") then
        makeLootTable = makeSpawnerAlienLootTable
    else
        return nil
    end

    local newDrops = {}
    for i=1,#template.drops do
        local attribute = template.drops[i]
        if (attribute == "greenArtifact") then
            newDrops[#newDrops+1] = makeLootTable("green")
        elseif (attribute == "yellowArtifact") then
            newDrops[#newDrops+1] = makeLootTable("yellow")
       elseif (attribute == "blueArtifact") then
            newDrops[#newDrops+1] = makeLootTable("blue")
        elseif (attribute == "orangeArtifact") then
            newDrops[#newDrops+1] = makeLootTable("orange")
        elseif (attribute == "redArtifact") then
            newDrops[#newDrops+1] = makeLootTable("red")
       elseif (attribute == "purpleArtifact") then
            newDrops[#newDrops+1] = makeLootTable("purple")
       elseif (attribute == "nilArtifact") then
            newDrops[#newDrops+1] = makeLootTable(nil)
       end
    end

    return newDrops
end

-- + !КДА 2021.11
local rangePerTier = { 0.1, 0.1, 0.1, 0.2, 0.2, 0.3, 0.3, 0.3, 0.3, 0.4 } 
rangePerTier = calculateValuesForLevels(rangePerTier, TIER_UPGRADE_SET_10_AS_IS, 1)	
-- - !КДА 2021.11

local function buildAttack(faction, template)
    for i=1,#template.attackAttributes do
        local attack = template.attackAttributes[i]
        if (attack == "melee") then
            template.attackGenerator = createMeleeAttack
        elseif (attack == "acidPool") then
            template.addon[#template.addon+1] = acidPuddleAttributeNumeric
            template.meleePuddleGenerator = function (attributes)
                attributes.stickerDamagePerTickType = "acid"
                return {
                    type="create-fire",
                    entity_name = makeAcidSplashFire(attributes, attributes.stickerName or makeSticker(attributes)),
                    check_buildability = true,
                    initial_ground_flame_count = 2,
                    show_in_tooltip = true
                }
            end
        elseif (attack == "spit") then
            template.attackType = "projectile"
            -- template.attackDirectionOnly = true

            template.attackGenerator = function (attack)
                return createRangedAttack(attack,
                                          createAttackBall(attack),
                                          (template.attackAnimation and template.attackAnimation(attack.scale,
                                                                                                 attack.tint,
                                                                                                 attack.tint2)) or nil)
            end
        elseif (attack == "touch") then
            template.attackType = "projectile"
            -- template.attackDirectionOnly = true
            template.range = rangePerTier	-- + !КДА 2021.11 { 0.1, 0.1, 0.1, 0.2, 0.2, 0.3, 0.3, 0.3, 0.3, 0.4 }

            template.attackGenerator = function (attack)
                return createRangedAttack(attack,
                                          createAttackBall(attack),
                                          (template.attackAnimation and template.attackAnimation(attack.scale,
                                                                                                 attack.tint,
                                                                                                 attack.tint2)) or nil)
            end
        elseif (attack == "drainCrystal") then
            template.actions = function(attributes, electricBeam)
                return
                    {
                        {
                            type = "instant",
                            target_effects =
                                {
                                    type = "create-entity",
                                    trigger_created_entity = true,
                                    entity_name = "drain-trigger-rampant"
                                }
                        },
                        {
                            type = "beam",
                            beam = electricBeam or "electric-beam",
                            duration = attributes.duration or 20
                        }
                    }
            end
        elseif (attack == "physical") then
            template.explosionTiers = explosionTiers
            template.scorchmarkTiers = scorchmarkTiers            
            template.damageType = "physical"
            template.fireDamagePerTickType = "physical"
            template.stickerDamagePerTickType = "physical"
            template.attackPointEffects = function (attributes)
                return {
                    {
                        type= "create-entity",
                        entity_name = attributes.attackScorchmark
                    },
                    {
                        type= "create-entity",
                        entity_name = attributes.attackExplosion
                    }
                }
            end
        elseif (attack == "acid") then
            template.damageType = "acid"
            template.fireDamagePerTickType = "acid"
            template.stickerDamagePerTickType = "acid"
        elseif (attack == "laser") then
            template.damageType = "laser"
            template.fireDamagePerTickType = "laser"
            template.stickerDamagePerTickType = "laser"
        elseif (attack == "electric") then
            template.damageType = "electric"
            template.fireDamagePerTickType = "electric"
            template.stickerDamagePerTickType = "electric"
        elseif (attack == "poison") then
            template.damageType = "poison"
            template.fireDamagePerTickType = "poison"
            template.stickerDamagePerTickType = "poison"
            template.attackPointEffects = function(attributes)
                return
                    {
                        {
                            type="create-entity",
                            entity_name = "poison-cloud-v" .. attributes.effectiveLevel .. "-cloud-rampant"
                        }
                    }
            end
        elseif (attack == "stream") then
			if blockableStreams then		-- alternative attack
				template.attackModifiers = {damage = 2, fireDamage = 1}
				template.attackType = "projectile"
				template.addon[#template.addon+1] = streamAttackNumeric
				template.attackGenerator = function (attack)
					return createRangedAttack(attack,
											  createSpitFire(attack),
											  (template.attackAnimation and template.attackAnimation(attack.scale,
																									 attack.tint,
																									 attack.tint2)) or nil)	
					end																				 
			else
				template.addon[#template.addon+1] = streamAttackNumeric
				template.attackGenerator = function (attack)
					return createStreamAttack(attack,
                                          createAttackFlame(attack),
                                          (template.attackAnimation and template.attackAnimation(attack.scale,
                                                                                                 attack.tint,
                                                                                                 attack.tint2)) or nil)
				end
			end
        elseif (attack == "lowDamageStream") then
			if blockableStreams then		-- alternative attack
				template.attackModifiers = {damage = 2, fireDamage = 1}
				template.attackType = "projectile"
				template.addon[#template.addon+1] = lowDamageStreamAttackNumeric
				template.attackGenerator = function (attack)
					return createRangedAttack(attack,
											  createSpitFire(attack),
											  (template.attackAnimation and template.attackAnimation(attack.scale,
																									 attack.tint,
																									 attack.tint2)) or nil)	
					end																				 
			else
				template.addon[#template.addon+1] = lowDamageStreamAttackNumeric
				template.attackGenerator = function (attack)
					return createStreamAttack(attack,
                                          createAttackFlame(attack),
                                          (template.attackAnimation and template.attackAnimation(attack.scale,
                                                                                                 attack.tint,
                                                                                                 attack.tint2)) or nil)
				end
			end
			
        elseif (attack == "beam") then
            template.addon[#template.addon+1] = beamAttackNumeric
            template.attackGenerator = function (attack)
                return createElectricAttack(attack,
                                            makeBeam(attack),
                                            (template.attackAnimation and template.attackAnimation(attack.scale,
                                                                                                   attack.tint,
                                                                                                   attack.tint2)) or nil)
            end
        elseif (attack == "cluster") then
            template.addon[#template.addon+1] = clusterAttackNumeric
            template.attackBubble = makeBubble(template)
			template.clusterAttack = true		-- so dungreous ==> slower speed, bigger.
            template.attackPointEffects = function(attributes)
                return
                    {
                        {
                            type="nested-result",
                            action = {
                                {
                                    type = "cluster",
                                    cluster_count = attributes.clusters,
                                    distance = attributes.clusterDistance,
                                    distance_deviation = 3,
                                    action_delivery =
                                        {
                                            type = "projectile",
                                            projectile = makeLaser(attributes),
                                            duration = 30,		-- 20,
                                            direction_deviation = 0.6,
                                            starting_speed = attributes.startingSpeed,
                                            starting_speed_deviation = 0.15	--0.3
                                        }
                                    , repeat_count = 3		-- 2022.05		(2)
                                }
                            }
                        }
                    }
            end
        elseif (attack == "slow") then
            template.force = "not-same"
            template.stickerAnimation = {
                filename = "__base__/graphics/entity/slowdown-sticker/slowdown-sticker.png",
                priority = "extra-high",
                line_length = 5,
                width = 22,
                height = 24,
                frame_count = 50,
                animation_speed = 0.5,
                tint = {r = 0.3500, g = 0.663, b = 0.000, a = 0.694}, -- #4a900b1
                shift = util.by_pixel (2,-1),
                hr_version =
                    {
                        filename = "__base__/graphics/entity/slowdown-sticker/hr-slowdown-sticker.png",
                        line_length = 5,
                        width = 42,
                        height = 48,
                        frame_count = 50,
                        animation_speed = 0.5,
                        tint = {r = 0.3500, g = 0.663, b = 0.000, a = 0.694}, -- #ffa900b1
                        shift = util.by_pixel(2, -0.5),
                        scale = 0.5
                    }
            }
            template.areaEffects = function (attributes)
                return {
                    {
                        type = "damage",
                        damage = { amount = attributes.damage, type = "acid" }
                    },
                    {
                        type = "create-sticker",
                        sticker = makeSticker(attributes)
                    }
                }
            end
        elseif (attack == "nuclear") then
            template.addon[#template.addon+1] = nuclearAttackNumeric
            template.explosionTiers = explosionTiers
            template.scorchmarkTiers = scorchmarkTiers            
            template.nuclear = true
            template.attackGenerator = function (attack)
                return createSuicideAttack(attack,
                                           makeAtomicBlast(attack),
                                           (template.attackAnimation and template.attackAnimation(attack.scale,
                                                                                                  attack.tint,
                                                                                                  attack.tint2)) or nil)
            end
        elseif (attack == "bomb") then
            template.addon[#template.addon+1] = bombAttackNumeric
            template.explosionTiers = explosionTiers
            template.scorchmarkTiers = scorchmarkTiers
            template.attackGenerator = function (attack)
                return createSuicideAttack(attack,
                                           nil,
                                           (template.attackAnimation and template.attackAnimation(attack.scale,
                                                                                                  attack.tint,
                                                                                                  attack.tint2)) or nil)
            end
        elseif (attack == "capsule") then
            template.attackType = "projectile"
            -- template.attackDirectionOnly = true
            template.attackGenerator = function (attack)
				attack.range = attack.range + 1
                return createProjectileAttack(attack,
                                              createCapsuleProjectile(attack,
                                                                      attack.entityGenerator(attack)),
                                              (template.attackAnimation and template.attackAnimation(attack.scale,
                                                                                                  attack.tint,
                                                                                                  attack.tint2)) or nil)
            end
        elseif (attack == "noFriendlyFire") then
            template["force"] = "not-same"
        elseif (attack == "noAcidPuddle") then
            template.noAcidPuddle = true
        elseif (attack == "meleePoisonCloud") then
				template.attackGenerator = function(attributes)
					return makeMeleePoisonCloud(attributes.range
							, attributes.effectiveLevel
							, (template.attackAnimation and template.attackAnimation(attributes.scale,
                                                                                                     attributes.tint,
                                                                                                     attributes.tint2,
																									 attributes.altBiter)) or nil)	--range, tier, animation
				end
        elseif (type(attack) == "table") then
            if (attack[1] == "drone") then
                template.entityGenerator = function (attributes)
                    return template.faction .. "-" .. attack[2] .. "-v" ..
                        attributes.variation .. "-t" .. attributes.effectiveLevel .. "-drone-rampant"
                end	
			elseif (attack[1] == "flame") then 		-- + !КДА 2021.11
				if blockableStreams then	-- alternative attack
					template.attackModifiers = {range = (attack[2] or 0), damage = (attack[3] or 1)*4, fireDamage = (attack[3] or 1) * 0.2}
					template.attackType = "projectile"
					template.addon[#template.addon+1] = streamAttackNumeric
					template.attackGenerator = function (attack)
						return createRangedAttack(attack,
												  createSpitFire(attack,  data.raw["stream"]["flamethrower-fire-stream"].particle, data.raw["stream"]["flamethrower-fire-stream"].shadow),
												  (template.attackAnimation and template.attackAnimation(attack.scale,
																										 attack.tint,
																										 attack.tint2)) or nil)	
						end																				 
				else
					template.attackGenerator = function(attributes)
						return makeflamerAtack(attributes.range+attack[2] 	--or 0)
								, attributes.damage * (attack[3] or 1)
								, (template.attackAnimation and template.attackAnimation(attributes.scale,
																										 attributes.tint,
																										 attributes.tint2)) or nil)	--range, damage, animation
					end
				end
			elseif (attack[1] == "spawnSpit") then
				template.spawningAttributes={spawnName = attack[2], spawnStep = attack[3] or 1, spawnCounts = attack[4] or 1, entitySuffix = ((attack[5] and ("-".. attack[5])) or "")}
				---------------------------
				template.attackGenerator = function (attributes)
					local spawningAttributes = attributes.spawningAttributes
					local spawnLvl = attributes.effectiveLevel+spawningAttributes.spawnStep
					if spawnLvl<1 then 
						spawnLvl = 1 
					elseif spawnLvl>10 then
						spawnLvl = 10
					end
					local entityName = attributes.faction .. "-" .. spawningAttributes.spawnName .. "-v1-t" ..spawnLvl.. spawningAttributes.entitySuffix .. "-rampant"
					
					return createSpawnAttack(attributes,
												createSpawnBall(attributes, entityName, spawningAttributes.spawnCounts), 
												(template.attackAnimation and template.attackAnimation(attributes.scale,
																									   attributes.tint,
																									   attributes.tint2)) or nil)
				end
			elseif (attack[1] == "bonusRange") then
				for i = 1, 10 do
					template.addon[#template.addon]["range"][i] = template.addon[#template.addon]["range"][i] + attack[2]
				end	
			elseif (attack[1] == "damageKoefficient") then
				for i = 1, 10 do
					template.addon[#template.addon]["damage"][i] = template.addon[#template.addon]["damage"][i] * attack[2]
				end			
			elseif (attack[1] == "durationKoefficient") then
				for i = 1, 10 do
					template.addon[#template.addon]["duration"][i] = template.addon[#template.addon]["duration"][i] * attack[2]
					template.addon[#template.addon]["damageInterval"][i] = template.addon[#template.addon]["damageInterval"][i] * attack[2]					
				end			
			end	
       else
            error ("unknown attack " .. type(attack).." = "..attack)
        end
    end
end

local function checkForAddons(template)
    for i=1,#template.attributes do
        local attribute = template.attributes[i]
        if (type(attribute) == "table") then
            if (attribute[1] == "clusterDeath") then
                template.addon[#template.addon+1] = clusterAttackNumeric
            end
        end
    end
end

local function buildUnitTemplate(faction, unit)
    local template = deepcopy(unit)

    template.name = faction.type .. "-" .. unit.name
    template.tint = faction.tint
    template.tint2 = faction.tint2

    template.faction = faction.type
    template.unitName = unit.name

    template.addon = {}
    template.explosion = faction.type

    template.resistances = {}
    template.additionalFlags = {}

    if (template.type == "biter") then
        template.attackAnimation = biterattackanimation
    elseif (template.type == "spitter") then
        template.attackAnimation = spitterattackanimation
    end

    checkForAddons(template)

    buildAttack(faction, template)

    if template.drops then
        template.drops = makeLootTables(template)
    end

    if not template.attackGenerator then
        error("missing attack generator " .. faction.type .. " " .. template.name)
    end

    return template
end

local function buildTurretTemplate(faction, turret)
    local template = deepcopy(turret)

    template.name = faction.type .. "-" .. turret.name
    template.tint = faction.tint
    template.tint2 = faction.tint2

    template.faction = faction.type
    template.unitName = turret.name

    template.evolutionFunction = function (tier)
        if (tier == 0) then
            return 0
        else
            return math.min(faction.evo + ((tier - 2) * 0.10), 0.92)
        end
    end

    template.explosion = faction.type

    template.addon = {}
    template.resistances = {}

    buildAttack(faction, template)

    checkForAddons(template)

    if template.drops then
        template.drops = makeLootTables(template)
    end

    if not template.attackGenerator then
        error("missing attack generator " .. faction.type .. " " .. template.name)
    end

    return template
end

local function buildUnitSpawnerTemplate(faction, incomingTemplate, unitSets)
    local template = deepcopy(incomingTemplate)

    template.name = faction.type .. "-" .. template.name
    template.tint = faction.tint
    template.tint2 = faction.tint2

    template.faction = faction.type
    template.unitName = incomingTemplate.name

    template.evolutionFunction = function (tier)
        if (tier == 0) then
            return 0
        else
            return math.min(faction.evo + ((tier - 2) * 0.10), 0.92)
        end
    end

    template.explosion = faction.type
    template.addon = {}

    checkForAddons(template)

    template.resistances = {}

    local unitSet = {}

    -- local unitVariations = settings.startup["rampantFixed--newEnemyVariations"].value

    for t=1,10 do
        for i=1,#template.buildSets do
            local buildSet = template.buildSets[i]
            if (buildSet[2] <= t) and (t <= buildSet[3]) then
                local activeUnitSet = unitSets[buildSet[1]][t]
                local unitSetTier = unitSet[t]
                if unitSetTier then
                    for b=1,#activeUnitSet do
                        unitSetTier[#unitSetTier+1] = activeUnitSet[b]
                    end
                else
                    unitSet[t] = deepcopy(activeUnitSet)
                end
            end
        end
        -- while (#unitSet[t] > unitVariations) do
        --     table.remove(unitSet, math.random(#unitSet[t]))
        -- end
    end

    template.unitSet = unitSet
    if template.drops then
        template.drops = makeLootTables(template)
    end

    return template
end

-- local function buildHiveTemplate(faction, incomingTemplate, unitSets)
    -- local template = deepcopy(incomingTemplate)

    -- template.name = faction.type .. "-" .. template.name
    -- template.tint = faction.tint
    -- template.tint2 = faction.tint2

    -- template.faction = faction.type
    -- template.unitName = incomingTemplate.name

    -- template.evolutionFunction = function (tier)
        -- if (tier == 0) then
            -- return 0
        -- else
            -- return math.min(faction.evo + ((tier - 2) * 0.10), 0.92)
        -- end
    -- end

    -- template.explosion = faction.type
    -- template.addon = {}

    -- checkForAddons(template)

    -- template.resistances = {}

   -- local unitSet = {}

    -- -- local unitVariations = settings.startup["rampantFixed--newEnemyVariations"].value

    -- for t=1,10 do
        -- for i=1,#template.buildSets do
            -- local buildSet = template.buildSets[i]
            -- if (buildSet[2] <= t) and (t <= buildSet[3]) then
                -- local activeUnitSet = unitSets[buildSet[1]][t]
                -- local unitSetTier = unitSet[t]
                -- if unitSetTier then
                    -- for b=1,#activeUnitSet do
                        -- unitSetTier[#unitSetTier+1] = activeUnitSet[b]
                    -- end
                -- else
                    -- unitSet[t] = deepcopy(activeUnitSet)
                -- end
            -- end
        -- end
        -- -- while (#unitSet[t] > unitVariations) do
        -- --     table.remove(unitSet, math.random(#unitSet[t]))
        -- -- end
    -- end

    -- template.unitSet = unitSet

    -- if template.drops then
        -- template.drops = makeLootTables(template)
    -- end

    -- return template
-- end

local function generateSpawnerProxyTemplate(name, health, result_units)
    return {
        type = "unit-spawner",
        name = name,
        icon = "__base__/graphics/icons/biter-spawner.png",
        icon_size = 64,
        icon_mipmaps = 4,
        flags = {"placeable-player", "placeable-enemy", "not-repairable"},
        max_health = health,
        order="b-b-g",
        subgroup="enemies",
        loot = nil,
        resistances = nil,
        working_sound = nil,
        dying_sound = nil,
        damaged_trigger_effect = nil,
        healing_per_tick = -1,
        -- collision_box = {{-3,-3},{3,3}},
        -- selection_box = {{-3,-3},{3,3}},
        collision_box = nil,
        selection_box = nil,
        -- in ticks per 1 pu
        pollution_absorption_absolute = 10,
        pollution_absorption_proportional = 0.005,
        map_generator_bounding_box = nil,
        corpse = nil,
        dying_explosion = nil,
        dying_trigger_effect = nil,
        max_count_of_owned_units = 0,
        max_friends_around_to_spawn = 0,
        enemy_map_color = {r=0,g=0,b=0,a=0},
        -- enemy_map_color = {r=0,g=1,b=1,a=1},
        animations = { filename = "__core__/graphics/empty.png", size = 1 },
        -- animations ={
        --     spawner_idle_animation(0, {r=1,b=1,g=1,a=1}, 1, {r=1,b=1,g=1,a=1}),
        --     spawner_idle_animation(1, {r=1,b=1,g=1,a=1}, 1, {r=1,b=1,g=1,a=1}),
        --     spawner_idle_animation(2, {r=1,b=1,g=1,a=1}, 1, {r=1,b=1,g=1,a=1}),
        --     spawner_idle_animation(3, {r=1,b=1,g=1,a=1}, 1, {r=1,b=1,g=1,a=1})
        -- },
        integration = nil,
        result_units = result_units,
        -- With zero evolution the spawn rate is 6 seconds, with max evolution it is 2.5 seconds
        spawning_cooldown = {360, 150},
        spawning_radius = 10,
        spawning_spacing = 3,
        max_spawn_shift = 0,
        max_richness_for_spawn_shift = 100,
        build_base_evolution_requirement = 0.0,
        call_for_help_radius = 50
    }
end

function swarmUtils.generateSpawnerProxy(result_units)

    data:extend({
            generateSpawnerProxyTemplate("spawner-proxy-1-rampant", 1 * 60 * 60, result_units),
            generateSpawnerProxyTemplate("spawner-proxy-2-rampant", 2 * 60 * 60, result_units),
            generateSpawnerProxyTemplate("spawner-proxy-3-rampant", 3 * 60 * 60, result_units)
    })
end

-- + !КДА 2021.12
local deathCloudNumeric = {
--	["dps"] = {12, 24, 36, 48, 60, 72, 84, 96, 108, 120 },
	["dps"] = {12, 15, 18, 21, 24, 30, 42, 76, 100, 120 },
	["hps"] = {24, 48, 72, 96, 120, 144, 168, 192, 216, 240},
    ["radius"] = {2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7 },
	["duration"] = {50, 100, 150, 200, 250, 300, 350, 400, 450, 500 }	--ticks
}
deathCloudNumeric["dps"] = calculateValuesForLevels(deathCloudNumeric["dps"], TIER_UPGRADE_SET_10_AS_IS, 2)	
deathCloudNumeric["hps"] = calculateValuesForLevels(deathCloudNumeric["hps"], TIER_UPGRADE_SET_10_AS_IS, 2)

local poisonAttacksNumeric = {
	["dps"] = {5, 15, 25, 30, 60, 115, 140, 155.0, 180.0, 200.0 },		-- duration: always 2 sec, atack speed - twice per sec, so it can stack 4 times (per biter)
	["hps"] = {7, 20, 35, 45, 60, 115, 140, 155.0, 180.0, 200.0 },
    ["radius"] = {2, 2.3, 2.6, 3, 3.2, 3.6, 4, 4.2, 4.4, 4.6 }
}
poisonAttacksNumeric["dps"] = calculateValuesForLevels(poisonAttacksNumeric["dps"], TIER_UPGRADE_SET_10_AS_IS, 2)	
poisonAttacksNumeric["hps"] = calculateValuesForLevels(poisonAttacksNumeric["hps"], TIER_UPGRADE_SET_10_AS_IS, 2)

local fireCloudNumeric = {
	["dps"] = {100, 140, 200, 300, 500, 750, 1250, 2000, 3000, 4000 },		-- duration: always 10 sec, attack speed - 5 per sec1
    ["radius"] = {1, 1.1, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2}
}
fireCloudNumeric["dps"] = calculateValuesForLevels(fireCloudNumeric["dps"], TIER_UPGRADE_SET_10_AS_IS, 2)	
-- - !КДА 2021.12

function swarmUtils.processFactions()
	local dyingEffects = {}

	local deathCloudAdded = false
    for i=1,#constants.FACTION_SET do
        local faction = constants.FACTION_SET[i]

        if (faction.type == "energy-thief") then
            energyThiefFaction.addFactionAddon()
        elseif ((faction.type == "poison") or (faction.type == "juggernaut") or (faction.type == "fire")) then
			if not data.raw["damage-type"]["healing"] then
			
				data:extend({
						{
							type = "damage-type",
							name = "healing"
						}
				})
			end	
			if not deathCloudAdded then
				poisonFaction.addFactionAddon(deathCloudNumeric)
				deathCloudAdded = true
			end	
			if (faction.type == "juggernaut") then
				poisonFaction.createAttackPoisonClouds(poisonAttacksNumeric)	
			end	
			if (faction.type == "fire") then
				poisonFaction.createFireClouds(fireCloudNumeric)	
			end
        end

        makeBloodFountains({
                name = faction.type,
                tint2 = faction.tint2
        })

        local unitSets = {}

        for iu=1,#faction.units do
            local unit = faction.units[iu]
            local template = buildUnitTemplate(faction, unit)

            unitSets[unit.name] = swarmUtils.buildUnits(template, dyingEffects)	-- + КДА 2022.07 now only first variant in unit list
        end

		local factionBuildings = {}
        for iu=1,#faction.buildings do
            local building = faction.buildings[iu]
			factionBuildings[building.type] = building.name	-- 1:1

            if (building.type == "spitter-spawner") then
                local template = buildUnitSpawnerTemplate(faction, building, unitSets)

                swarmUtils.buildUnitSpawner(template)
            elseif (building.type == "biter-spawner") then
                local template = buildUnitSpawnerTemplate(faction, building, unitSets)

                swarmUtils.buildUnitSpawner(template)
            elseif (building.type == "turret") then
                local template = buildTurretTemplate(faction, building)
                swarmUtils.buildWorm(template)
            elseif (building.type == "hive") then
                local template = buildUnitSpawnerTemplate(faction, building, unitSets)

                swarmUtils.buildEntitySpawner(template, factionBuildings)
           elseif (building.type == "trap") then

            elseif (building.type == "utility") then

            end


        end
    end
	
	for _, unitData in pairs(dyingEffects) do
		if unitData.name then
			local entity = data.raw[unitData.type][unitData.name]
			entity[unitData.effectType] = unitData.dyingEffect
			data:extend({entity})
		end	
	end
	
end

return swarmUtils
