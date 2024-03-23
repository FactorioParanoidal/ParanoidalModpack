if constantsG then
    return constantsG
end
local constants = {}

-- versions

constants.VERSION_5 = 5
constants.VERSION_10 = 10
constants.VERSION_11 = 11
constants.VERSION_12 = 12
constants.VERSION_16 = 16
constants.VERSION_18 = 18
constants.VERSION_20 = 20
constants.VERSION_22 = 22
constants.VERSION_23 = 23
constants.VERSION_25 = 25
constants.VERSION_26 = 26
constants.VERSION_27 = 27
constants.VERSION_28 = 28
constants.VERSION_33 = 33
constants.VERSION_38 = 38
constants.VERSION_41 = 41
constants.VERSION_44 = 44
constants.VERSION_51 = 51
constants.VERSION_57 = 57
constants.VERSION_72 = 72
constants.VERSION_73 = 73
constants.VERSION_75 = 75
constants.VERSION_76 = 76
constants.VERSION_77 = 77
constants.VERSION_85 = 85
constants.VERSION_86 = 86
constants.VERSION_87 = 87
constants.VERSION_88 = 88

-- misc

-- constants.WATER_TILE_NAMES = { "water", "deepwater", "water-green", "deepwater-green" }

constants.MAGIC_MAXIMUM_NUMBER = 1e99 -- used in loops trying to find the lowest/highest score
constants.MAGIC_MAXIMUM_BASE_NUMBER = 100000000
constants.MAXIMUM_BASE_RADIUS = 128	-- + !КДА 2021.11 (chunkUtils.initialScan)	<32 - 1 chunk, 50 ~ 3x3, 128 - 4 chunk radius, ...
constants.BASE_CHANGING_CHANCE = 0.1	-- + !КДА 2021.11 (chunkUtils.initialScan)

constants.RETREAT_MOVEMENT_PHEROMONE_LEVEL_MIN = 1000
constants.RETREAT_MOVEMENT_PHEROMONE_LEVEL_MAX = 130000

constants.PROCESS_QUEUE_SIZE = 140
constants.SCAN_QUEUE_SIZE = 2
constants.RESOURCE_QUEUE_SIZE = 7
constants.ENEMY_QUEUE_SIZE = 7
constants.PLAYER_QUEUE_SIZE = 7
constants.CLEANUP_QUEUE_SIZE = 8
constants.ATTACK_QUEUE_SIZE = 18
constants.BASE_QUEUE_SIZE = 1
constants.PROCESS_STATIC_QUEUE_SIZE = 20
constants.PROCESS_PLAYER_BOUND = 128
constants.VICTORY_SCENT_BOUND = 128

constants.TICKS_A_SECOND = 60
constants.TICKS_A_MINUTE = constants.TICKS_A_SECOND * 60

constants.OVERDAMAGEPROTECTION_THRESHOLD = 20

constants.CHUNK_PASS_THRESHOLD = 0.2

-- constants.INTERVAL_PLAYER_PROCESS = 63
-- constants.INTERVAL_MAP_PROCESS = 5
-- constants.INTERVAL_MAP_STATIC_PROCESS = 11
-- constants.INTERVAL_SCAN = 19
-- constants.INTERVAL_CHUNK_PROCESS = 23
-- constants.INTERVAL_LOGIC = 59
-- constants.INTERVAL_TEMPERAMENT = 121
-- constants.INTERVAL_SQUAD = 14
-- constants.INTERVAL_NEST = 16
-- constants.INTERVAL_PASS_SCAN = 29
-- constants.INTERVAL_RESQUAD = 101
-- constants.INTERVAL_SPAWNER = 19
-- constants.INTERVAL_VICTORY = 10
-- constants.INTERVAL_CLEANUP = 34

constants.COOLDOWN_RALLY = constants.TICKS_A_SECOND * 10
constants.COOLDOWN_RETREAT = constants.TICKS_A_SECOND * 10

constants.RESOURCE_NORMALIZER = 1 / 1024

constants.PLAYER_PHEROMONE_MULTIPLER = 100

constants.DURATION_ACTIVE_NEST = 60 * constants.TICKS_A_SECOND

constants.DURATION_ACTIVE_NEST_DIVIDER = 1 / constants.DURATION_ACTIVE_NEST

-- chunk properties

constants.CHUNK_SIZE = 32
constants.CHUNK_AND_HALF_SIZE = constants.CHUNK_SIZE * 1.5
constants.DOUBLE_CHUNK_SIZE = constants.CHUNK_SIZE * 2
constants.TRIPLE_CHUNK_SIZE = constants.CHUNK_SIZE * 3
constants.HALF_CHUNK_SIZE = constants.CHUNK_SIZE / 2
constants.QUARTER_CHUNK_SIZE = constants.HALF_CHUNK_SIZE / 2

constants.CHUNK_SIZE_DIVIDER = 1 / constants.CHUNK_SIZE

constants.CHUNK_IMPASSABLE = 0
constants.CHUNK_NORTH_SOUTH = 1
constants.CHUNK_EAST_WEST = 2
constants.CHUNK_ALL_DIRECTIONS = 3
-- constants.CHUNK_PLAYER_BORDER = 4
-- constants.CHUNK_PLAYER_INTERIOR = 5

constants.BASE_SEARCH_RADIUS = 4 * constants.CHUNK_SIZE
constants.EVOLUTION_INCREMENTS = 0.05

constants.DIVISOR_DEATH_TRAIL_TABLE = { 0.75, 0.65, 0.55, 0.45, 0.35 }

-- ai

constants.MAX_TICKS_BEFORE_SORT_CHUNKS = 60 * 60 * 30 -- 1 tick = 1/60 sec * 60 = 1 second

constants.RESOURCE_MINIMUM_FORMATION_DELTA = 15

constants.MINIMUM_AI_POINTS = 400
constants.AI_SQUAD_COST = 175
constants.RECOVER_NEST_COST = constants.AI_SQUAD_COST
constants.RECOVER_WORM_COST = constants.AI_SQUAD_COST * 0.5
constants.AI_VENGENCE_SQUAD_COST = 45
constants.AI_SETTLER_COST = 300
constants.AI_BASE_BUILDING_COST = 500
constants.AI_TUNNEL_COST = 100
constants.AI_MAX_POINTS = 15500

constants.AI_UNIT_REFUND = 3

constants.AI_MAX_BITER_GROUP_SIZE = 600

constants.AI_SQUAD_MERGE_THRESHOLD = constants.AI_MAX_BITER_GROUP_SIZE * 0.75

constants.AI_MAX_SQUADS_PER_CYCLE = 7

constants.AI_STATE_PEACEFUL = 1
constants.AI_STATE_AGGRESSIVE = 2
constants.AI_STATE_RAIDING = 4
constants.AI_STATE_MIGRATING = 5
constants.AI_STATE_SIEGE = 6
constants.AI_STATE_ONSLAUGHT = 7
constants.AI_STATE_GROWING = 8

constants.stateEnglish = {}
constants.stateEnglish[constants.AI_STATE_PEACEFUL] = "AI_STATE_PEACEFUL"
constants.stateEnglish[constants.AI_STATE_AGGRESSIVE] = "AI_STATE_AGGRESSIVE"
constants.stateEnglish[constants.AI_STATE_RAIDING] = "AI_STATE_RAIDING"
constants.stateEnglish[constants.AI_STATE_MIGRATING] = "AI_STATE_MIGRATING"
constants.stateEnglish[constants.AI_STATE_SIEGE] = "AI_STATE_SIEGE"
constants.stateEnglish[constants.AI_STATE_ONSLAUGHT] = "AI_STATE_ONSLAUGHT"
constants.stateEnglish[constants.AI_STATE_GROWING] = "AI_STATE_GROWING"

constants.BASE_AI_STATE_DORMANT = 0
constants.BASE_AI_STATE_ACTIVE = 1
constants.BASE_AI_STATE_OVERDRIVE = 2
constants.BASE_AI_STATE_MUTATE = 3

constants.AGGRESSIVE_CAN_ATTACK_WAIT_MIN_DURATION = 0.5
constants.AGGRESSIVE_CAN_ATTACK_WAIT_MAX_DURATION = 3

constants.AI_MIN_STATE_DURATION = 10
constants.AI_MAX_STATE_DURATION = 25

constants.AI_MIN_TEMPERAMENT_DURATION = 25	-- ??
constants.AI_MAX_TEMPERAMENT_DURATION = 32

constants.BASE_AI_MIN_STATE_DURATION = 12
constants.BASE_AI_MAX_STATE_DURATION = 20

constants.GROWING_COOLDOWN = 3600

-- ai base

constants.BASE_CLEAN_DISTANCE = 13

constants.BASE_DEADZONE_TTL = constants.TICKS_A_MINUTE * 18

constants.BASE_COLLECTION_THRESHOLD = constants.TICKS_A_MINUTE * 2

constants.BASE_DISTANCE_TO_EVO_INDEX = 1 / settings.startup["rampantFixed--max-evo-dist"].value

constants.BASE_SPAWNER_UPGRADE = 30*60*60	-- 30min	-- 250			
constants.BASE_WORM_UPGRADE = 20*60*60	-- 20min	-- 200
constants.BASE_EVOLVE_THRESHOLD = constants.BASE_SPAWNER_UPGRADE	-- 1st evolve time
constants.GLOBAL_EVOLVE_COOLDOWN = 5*60*60 
constants.GLOBAL_LVLUP_COOLDOWN = 1*60*60

constants.BASE_DISTANCE_THRESHOLD = 30 * constants.CHUNK_SIZE
constants.BASE_DISTANCE_LEVEL_BONUS = 15

constants.BASE_PROCESS_INTERVAL = constants.TICKS_A_SECOND * 2

-- ai retreat

constants.NO_RETREAT_BASE_PERCENT = 0.10
constants.NO_RETREAT_EVOLUTION_BONUS_MAX = 0.25

-- pheromone amounts

constants.MOVEMENT_PENALTY_AMOUNT = 300000
constants.DEATH_PHEROMONE_GENERATOR_AMOUNT = 1300
constants.DOUBLE_DEATH_PHEROMONE_GENERATOR_AMOUNT = constants.DEATH_PHEROMONE_GENERATOR_AMOUNT * 2
constants.TEN_DEATH_PHEROMONE_GENERATOR_AMOUNT = constants.DEATH_PHEROMONE_GENERATOR_AMOUNT * 10
constants.FIVE_DEATH_PHEROMONE_GENERATOR_AMOUNT = constants.DEATH_PHEROMONE_GENERATOR_AMOUNT * 5
constants.SQUAD_PATH_DEATH_PHEROMONE_GENERATOR_AMOUNT = 200
constants.PLAYER_PHEROMONE_GENERATOR_AMOUNT = 300

constants.IMPASSABLE_TERRAIN_GENERATOR_AMOUNT = 0

-- pheromone diffusion amounts

constants.MOVEMENT_GENERATOR_PERSISTANCE = 0.90

-- chunk attributes

constants.BASE_PHEROMONE = 1
constants.PLAYER_PHEROMONE = 2
constants.RESOURCE_PHEROMONE = 3

-- constants.PASSABLE = 5

constants.CHUNK_TICK = 4
constants.BASE_DETECTION_PHEROMONE = 5	-- + !КДА 2021.11 

-- constants.PATH_RATING = 7

-- Squad status

constants.SQUAD_RETREATING = 1 -- used during squad retreat
constants.SQUAD_GUARDING = 2 -- used when squad is idle
constants.SQUAD_BURROWING = 3
constants.SQUAD_RAIDING = 4 -- used when player stuff is close
constants.SQUAD_SETTLING = 5
constants.SQUAD_BUILDING = 6

-- Squad Related

constants.RETREAT_GRAB_RADIUS = 24
constants.RETREAT_SPAWNER_GRAB_RADIUS = 75

constants.BASE_RALLY_CHANCE = 0.02
constants.BONUS_RALLY_CHANCE = 0.06

constants.RALLY_CRY_DISTANCE = 96
constants.SETTLER_DISTANCE = 224
constants.COOLDOWN_HUNT = 600	-- ticks

constants.GROUP_MERGE_DISTANCE = 28

constants.MAX_PENALTY_BEFORE_PURGE = 36000

-- player building pheromones
constants.FACTORISSIMO_ENTITY_FEROMONE = {}		-- + !КДА see also updgrade.lua, chunkUtils.accountPlayerEntity
constants.FACTORISSIMO_ENTITY_FEROMONE[constants.BASE_PHEROMONE] = 5000
constants.FACTORISSIMO_ENTITY_FEROMONE[constants.BASE_DETECTION_PHEROMONE] = 15000


constants.MAX_BASE_DETECTION_PHEROMONES_IN_CHUNK = 10000			
constants.NO_POLLUTION_ATTACK_THRESHOLD = 5900	-- ~ 5 chunks raduis (if 10000 max value)
constants.K_NO_ACTIVE_NESTS = 40
constants.K_TOO_LOW_ACTIVE_NESTS = 20
constants.K_LOW_ACTIVE_NESTS = 10
constants.RAIDING_MINIMUM_BASE_THRESHOLD = 550	-- ~ 27 chunks raduis (if 10000 max value)

constants.GENERATOR_PHEROMONE_LEVEL = {}
local GENERATOR_PHEROMONE_LEVEL = constants.GENERATOR_PHEROMONE_LEVEL
GENERATOR_PHEROMONE_LEVEL["1"] = {}
GENERATOR_PHEROMONE_LEVEL["1"][constants.BASE_PHEROMONE] = 25
GENERATOR_PHEROMONE_LEVEL["1"][constants.BASE_DETECTION_PHEROMONE] = 25
GENERATOR_PHEROMONE_LEVEL["2"] = {}
GENERATOR_PHEROMONE_LEVEL["2"][constants.BASE_PHEROMONE] = 100
GENERATOR_PHEROMONE_LEVEL["2"][constants.BASE_DETECTION_PHEROMONE] = 100
GENERATOR_PHEROMONE_LEVEL["3"] = {}
GENERATOR_PHEROMONE_LEVEL["3"][constants.BASE_PHEROMONE] = 500
GENERATOR_PHEROMONE_LEVEL["3"][constants.BASE_DETECTION_PHEROMONE] = 500
GENERATOR_PHEROMONE_LEVEL["4"] = {}
GENERATOR_PHEROMONE_LEVEL["4"][constants.BASE_PHEROMONE] = 1000
GENERATOR_PHEROMONE_LEVEL["4"][constants.BASE_DETECTION_PHEROMONE] = 1000
GENERATOR_PHEROMONE_LEVEL["5"] = {}
GENERATOR_PHEROMONE_LEVEL["5"][constants.BASE_PHEROMONE] = 1750
GENERATOR_PHEROMONE_LEVEL["5"][constants.BASE_DETECTION_PHEROMONE] = 1750
GENERATOR_PHEROMONE_LEVEL["6"] = {}
GENERATOR_PHEROMONE_LEVEL["6"][constants.BASE_PHEROMONE] = 6000
GENERATOR_PHEROMONE_LEVEL["6"][constants.BASE_DETECTION_PHEROMONE] = 6000
GENERATOR_PHEROMONE_LEVEL["turrets"] = {}
GENERATOR_PHEROMONE_LEVEL["turrets"][constants.BASE_PHEROMONE] = 100
GENERATOR_PHEROMONE_LEVEL["turrets"][constants.BASE_DETECTION_PHEROMONE] = constants.MAX_BASE_DETECTION_PHEROMONES_IN_CHUNK
GENERATOR_PHEROMONE_LEVEL["radar"] = {}
GENERATOR_PHEROMONE_LEVEL["radar"][constants.BASE_PHEROMONE] = 1750
GENERATOR_PHEROMONE_LEVEL["radar"][constants.BASE_DETECTION_PHEROMONE] = constants.MAX_BASE_DETECTION_PHEROMONES_IN_CHUNK

----------------------- 
constants.BUILDING_PHEROMONES = {} 
local BUILDING_PHEROMONES = constants.BUILDING_PHEROMONES
-- -- if changes BUILDING_PHEROMONES, dont forget to increase version in Upgrade.lua		
-- look at ChunkUtils.scorePlayerBuildings, chunkUtils.accountPlayerEntity
BUILDING_PHEROMONES["transport-belt"] = "1"
BUILDING_PHEROMONES["lamp"] = "1"
BUILDING_PHEROMONES["programmable-speaker"] = "1"
BUILDING_PHEROMONES["wall"] = "1"

BUILDING_PHEROMONES["splitter"] = "3"
BUILDING_PHEROMONES["pump"] = "3"
BUILDING_PHEROMONES["offshore-pump"] = "3"
BUILDING_PHEROMONES["solar-panel"] = "3"
BUILDING_PHEROMONES["programmable-speaker"] = "3"
BUILDING_PHEROMONES["accumulator"] = "3"
BUILDING_PHEROMONES["assembling-machine"] = "3"
BUILDING_PHEROMONES["pipe-to-ground"] = "3"
BUILDING_PHEROMONES["storage-tank"] = "3"
BUILDING_PHEROMONES["container"] = "3"

BUILDING_PHEROMONES["furnace"] = "5"
BUILDING_PHEROMONES["lab"] = "5"
BUILDING_PHEROMONES["roboport"] = "5"
BUILDING_PHEROMONES["beacon"] = "5"
BUILDING_PHEROMONES["boiler"] = "5"
BUILDING_PHEROMONES["generator"] = "5"
BUILDING_PHEROMONES["mining-drill"] = "5"

BUILDING_PHEROMONES["artillery-turret"] = "6"
BUILDING_PHEROMONES["reactor"] = "6"
BUILDING_PHEROMONES["rocket-silo"] = "6"

BUILDING_PHEROMONES["turret"] = "turrets"			
BUILDING_PHEROMONES["ammo-turret"] = "turrets"		
BUILDING_PHEROMONES["fluid-turret"] = "turrets"					
BUILDING_PHEROMONES["electric-turret"] = "turrets"

BUILDING_PHEROMONES["radar"] = "radar"	
------
constants.VICTORY_SCENT = {}					-- points if destoyed
for enitityType, pheromoneLvl in pairs(BUILDING_PHEROMONES) do
	if enitityType ~= "wall" then
		constants.VICTORY_SCENT[enitityType] = GENERATOR_PHEROMONE_LEVEL[pheromoneLvl][constants.BASE_PHEROMONE]*10
	end	
end
-------------------------

function constants.GET_ENTITY_PHEROMONES(entity, pheromoneType)	
	local pheromoneLvl
	pheromoneLvl = BUILDING_PHEROMONES[entity.type]
	if not pheromoneLvl then
		return 0
	end
	
	local scoreValue = GENERATOR_PHEROMONE_LEVEL[pheromoneLvl][pheromoneType]
	if constants.FACTORISSIMO_ENTITY(entity) then
		scoreValue = scoreValue + constants.FACTORISSIMO_ENTITY_FEROMONE[pheromoneType]			
	end
	
	return scoreValue
end

local sFind = string.find
-- list of names. Can't be enabled manually/by remote interface
function constants.isExcludedSurface(surfaceName)
	return (sFind(surfaceName, "Factory floor") or
        sFind(surfaceName, " Orbit") or
        sFind(surfaceName, "clonespace") or
        sFind(surfaceName, "BPL_TheLabplayer") or
        sFind(surfaceName, "starmap-") or
        (surfaceName == "aai-signals") or
        sFind(surfaceName, "NiceFill") or
        sFind(surfaceName, "Asteroid Belt") or
        sFind(surfaceName, "Vault ") or
        (surfaceName == "RTStasisRealm") or
        sFind(surfaceName, "spaceship")
		)~=nil
end

-- ignored surfaces (factorissimo at 2021.12). 	!!!!	universe.maps[surfaceIndex] now can be nil	!!!!
function constants.SURFACE_IGNORED(surface, universe)
	if not surface then
		return true
	end
	if not universe.surfaceIgnoringSet then
		universe.surfaceIgnoringSet = {}
	end

	local surfaceIgnoringSet = universe.surfaceIgnoringSet[surface.index]
	if surfaceIgnoringSet then
		return (surfaceIgnoringSet == 1)		-- 1 -> ignored
	end		
	local surfaceName = surface.name
	local isExcludedSurface = false
		
	if not constants.isExcludedSurface(surfaceName) then
		local map_gen_settings = surface.map_gen_settings
		local autoplace_controls = map_gen_settings and map_gen_settings.autoplace_controls  
		if (not autoplace_controls) and (map_gen_settings.default_enable_all_autoplace_controls) then
			autoplace_controls =  game.default_map_gen_settings.autoplace_controls
		end	
		local enemy_base_settings = autoplace_controls and autoplace_controls["enemy-base"]
		if enemy_base_settings and (enemy_base_settings.frequency>0) and (enemy_base_settings.richness>0) and (enemy_base_settings.size>0) then
			-- log(surfaceName..".enemy_base_settings:"..serpent.dump(enemy_base_settings))	-- debug
		else
			-- if enemy_base_settings then
				-- log(surfaceName..".enemy_base_settings:"..serpent.dump(enemy_base_settings))	-- debug
			-- else	
				-- log(surfaceName..".enemy_base_settings: nil")				-- debug
			-- end
			isExcludedSurface = true
		end
	end
	-- game.print(surface.name.." will be ignored: "..tostring(isExcludedSurface))	-- debug
	
	if isExcludedSurface then
		universe.surfaceIgnoringSet[surface.index] = 1
	else
		universe.surfaceIgnoringSet[surface.index] = 0
	end
	
	return isExcludedSurface
end

function constants.FACTORISSIMO_ENTITY(entity)
	local entityNames = {"factory-"}
	if not entity or not entity.valid then
		return false
	end	
	if not entity.type == "storage-tank" then	-- Factorissimo. Yes, this is a "storage-tank" enities
		return false	
	end
	
	local sLen = string.len
	local returnValue = false
	for _, entityName in pairs(entityNames) do
		local lenSurface = sLen(entityName)
		if (sLen(entity.name)>=lenSurface) and (string.sub(entity.name, 1, lenSurface) == entityName) then
			returnValue = true
			break
		end		
	end
	--game.print(entity.name.." is factorissimo building: "..tostring(returnValue))
	return returnValue
end

constants.VANILLA_ENTITIES = {}
constants.VANILLA_ENTITIES["biter-spawner"] = true
constants.VANILLA_ENTITIES["spitter-spawner"] = true
constants.VANILLA_ENTITIES["small-worm-turret"] = true
constants.VANILLA_ENTITIES["medium-worm-turret"] = true
constants.VANILLA_ENTITIES["big-worm-turret"] = true
constants.VANILLA_ENTITIES["behemoth-worm-turret"] = true


-- map settings tweaks

constants.PATH_FINDER_SHORT_REQUEST_RATIO = 0.8
constants.PATH_FINDER_SHORT_CACHE_SIZE = 25
constants.PATH_FINDER_LONG_REQUEST_RATIO = 5
constants.PATH_FINDER_MIN_STEPS_TO_CHECK_PATH = 1000

constants.MAX_FAILED_BEHAVIORS = 1000

constants.UNIT_GROUP_DISOWN_DISTANCE = 100
constants.UNIT_GROUP_TICK_TOLERANCE = 3600000

constants.UNIT_GROUP_MAX_RADIUS = 15
constants.UNIT_GROUP_MAX_SPEED_UP = 2
constants.UNIT_GROUP_MAX_SLOWDOWN = 1.0
constants.UNIT_GROUP_SLOWDOWN_FACTOR = 1.0

constants.CONVERSION_TABLE = {
    "neutral",
    "fire",
    "nuclear",
    "suicide",
    "neutral",
    "acid",
    "fire",
    "physical",
    "laser",
    "inferno",
    "poison",
    "troll",
    "fast",
    "neutral",
    "neutral",
    "neutral",
    "energy-thief",
    "electric",
    "wasp",
    nil,
    "acid",
    "acid",
    "spawner",
    "laser",
    "inferno",
    "suicide",
    "acid",
    "spawner"
}

-- constants.BASE_ALIGNMENT_NEUTRAL = 1
-- constants.BASE_ALIGNMENT_FIRE = 2
-- constants.BASE_ALIGNMENT_NUCLEAR = 3
-- constants.BASE_ALIGNMENT_SUICIDE = 4
-- constants.BASE_ALIGNMENT_INFEST = 5
-- constants.BASE_ALIGNMENT_ACID = 6
-- constants.BASE_ALIGNMENT_FIRE = 7
-- constants.BASE_ALIGNMENT_PHYSICAL = 8
-- constants.BASE_ALIGNMENT_LASER = 9
-- constants.BASE_ALIGNMENT_INFERNO = 10
-- constants.BASE_ALIGNMENT_POISON = 11
-- constants.BASE_ALIGNMENT_TROLL = 12
-- constants.BASE_ALIGNMENT_FAST = 13
-- constants.BASE_ALIGNMENT_WEB = 14
-- constants.BASE_ALIGNMENT_DECAYING = 15
-- constants.BASE_ALIGNMENT_UNDYING = 16
-- constants.BASE_ALIGNMENT_ENERGY_THIEF = 17
-- constants.BASE_ALIGNMENT_ELECTRIC = 18
-- constants.BASE_ALIGNMENT_WASP = 19
-- constants.BASE_ALIGNMENT_DEADZONE = 20
constants.BASE_ALIGNMENT_NE = 21
-- constants.BASE_ALIGNMENT_BOBS = 22
-- constants.BASE_ALIGNMENT_SPAWNER = 23
-- constants.BASE_ALIGNMENT_NE_BLUE = 24
-- constants.BASE_ALIGNMENT_NE_RED = 25
-- constants.BASE_ALIGNMENT_NE_YELLOW = 26
-- constants.BASE_ALIGNMENT_NE_GREEN = 27
-- constants.BASE_ALIGNMENT_NE_PINK = 28

-- sentinels

constants.ENERGY_THIEF_CONVERSION_TABLE = {
    ["generator"] = "unit",
    ["pump"] = "smallUnit",
    ["inserter"] = "smallUnit",
    ["reactor"] = "bigUnit",
    ["accumulator"] = "unit",
    ["solar-panel"] = "unit",
    ["assembling-machine"] = "unit",
    ["roboport"] = "bigUnit",
    ["beacon"] = "bigUnit",
    ["programmable-speaker"] = "unit",
    ["mining-drill"] = "unit",
    ["rocket-silo"] = "bigUnit",
    ["lamp"] = "smallUnit",
    ["radar"] = "bigUnit",
    ["lab"] = "unit",
    ["electric-turret"] = "unit",
    ["electric-pole"] = "pole"
}

constants.ENERGY_THIEF_DRAIN_CRYSTALS = {
    "crystal-v1-drain-rampant",
    "crystal-v2-drain-rampant",
    "crystal-v3-drain-rampant",
    "crystal-v4-drain-rampant",
    "crystal-v5-drain-rampant",
    "crystal-v6-drain-rampant",
    "crystal-v7-drain-rampant",
    "crystal-v8-drain-rampant",
    "crystal-v9-drain-rampant",
    "crystal-v10-drain-rampant"
}

constants.NEIGHBOR_DIVIDER = {1/1, 1/2, 1/3, 1/4, 1/5, 1/6, 1/7, 1/8}

-- unit spawners

local function roundToNearest(number, multiple)
    local num = number + (multiple * 0.5)
    return num - (num % multiple)
end

local tiers10 = {}

local tierStart = settings.startup["rampantFixed--tierStart"].value
local tierEnd = settings.startup["rampantFixed--tierEnd"].value

local tiers10AsIs = {}	-- + !КДА 2021.11
local function buildTier(size, tiers, tiersAsIs)	-- + !КДА 2021.11 tiersAsIs
    local step = (tierEnd - tierStart) / (size - 1)
    local i = tierStart
    for _=1,size do
        tiers[#tiers+1] = roundToNearest(i, 1)
        tiersAsIs[#tiersAsIs+1] = i
        i = i + step
    end
end

buildTier(10, tiers10, tiers10AsIs)	-- + !КДА 2021.11 tiersAsIs

constants.TIER_UPGRADE_SET_10 = tiers10
constants.TIER_UPGRADE_SET_10_AS_IS = tiers10AsIs	-- + !КДА 2021.11	


local variations = (settings.startup["rampantFixed--newEnemyVariations"].value or 1)	-- + !КДА 2021.11

constants.ENERGY_THIEF_LOOKUP = {}

for tier=1, 10 do
    for i=1,variations do
        constants.ENERGY_THIEF_LOOKUP["energy-thief-worm-v" .. i .. "-t" .. tier .. "-rampant"] = true
    end
end

for tier=1, 10 do
    for i=1,variations do
        constants.ENERGY_THIEF_LOOKUP["energy-thief-biter-v" .. i .. "-t" .. tier .. "-rampant"] = true
    end
end

constants.OVERDAMAGE_PROTECTED_LIST = {}
constants.LONGRANGE_IMMUNE_LIST = {}


-- + !КДА see alse: prototypes/utils/UpdateImmunities
constants.FACTION_SET = {}

-- + !КДА 2021.11 add overdamageProtection (max hit = maxHP/N before resists counts) and longRangeImmunity (0 dmg from N+ range) for some units (hello, bobwarfare!)
constants.FACTION_SET[#constants.FACTION_SET+1] = {
    type = "neutral",
    tint = {r=0.9, g=0.9, b=0.9, a=1},
    tint2 = {r=1, g=1, b=1, a=1},	
    -- acceptRate = {1, 7, 0.3, 0.1},	-- + !КДА 2021.10
    acceptRate = {1, 6, 0.15, 0.01},
    evo = 0,
    units = {
        {
            type = "biter",
            attackAttributes = {"melee"},
            name = "biter",
            majorResistances = {},
            minorResistances = {},
            attributes = {},
            drops = {"nilArtifact"}
        },
        {
            type = "spitter",
            attackAttributes = {"spit", "acid"},
            name = "spitter",
            majorResistances = {},
            minorResistances = {},
            attributes = {},
            drops = {"nilArtifact"}
        }
    },
    buildings = {
        {
            type = "spitter-spawner",
            name = "spitter-spawner",
            majorResistances = {},
            acceptRate = {1, 10, 0.3, 0.5},
            minorResistances = {},
            attributes = {},
            drops = {"nilArtifact"},
            buildSets = {
                {"spitter", 1, 10}
            }
        },
        {
            type = "biter-spawner",
            name = "biter-spawner",
            majorResistances = {},
            acceptRate = {1, 10, 0.3, 0.5},
            minorResistances = {},
            attributes = {},
            drops = {"nilArtifact"},
            buildSets = {
                {"biter", 1, 10}
            }
        },
        {
            type = "turret",
            name = "worm",
            majorResistances = {},
            acceptRate = {1, 10, 0.8, 0.6},
            minorResistances = {},
            attackAttributes = {"spit", "acid"},
            attributes = {},
            drops = {"nilArtifact"}
        },
        {
            type = "hive",
            name = "hive",
            majorResistances = {},
            minorResistances = {},
            attributes = {},
            acceptRate = {2, 10, 0.001, 0.0175},
            drops = {"nilArtifact"},
			buildSets = {
				{"spitter", 1, 10},
				{"biter", 1, 10}
			}
        }
    }
}

if settings.startup["rampantFixed--acidEnemy"].value then
    constants.FACTION_SET[#constants.FACTION_SET+1] = {
        type = "acid",
        tint = {r=1, g=1, b=1, a=1},
        tint2 = {r=0.4, g=0.9, b=0.4, a=1},
        -- acceptRate = {1, 10, 0.1, 0.2},
        acceptRate = {1, 10, 0.1, 0.15},	-- + !КДА 2021.10
        evo = 0,
        units = {
            {
                type = "biter",
                attackAttributes = {"melee", "acidPool"},
                name = "biter",
                immunity = {"acid", "poison"},
                attributes = {},
                drops = {"nilArtifact"}
            },
            {
                type = "spitter",
                attackAttributes = {"spit", "acid"},
                name = "spitter",
                immunity = {"acid", "poison"},
                attributes = {},
                drops = {"nilArtifact"}
            }
        },
        buildings = {
            {
                type = "spitter-spawner",
                name = "spitter-spawner",
                immunity = {"acid", "poison"},
                acceptRate = {1, 10, 0.3, 0.5},
                attributes = {},
                drops = {"nilArtifact"},
                buildSets = {
                    {"spitter", 1, 10}
                }
            },
            {
                type = "biter-spawner",
                name = "biter-spawner",
                immunity = {"acid", "poison"},
                acceptRate = {1, 10, 0.3, 0.5},
                attributes = {},
                drops = {"nilArtifact"},
                buildSets = {
                    {"biter", 1, 10}
                }
            },
            {
                type = "turret",
                name = "worm",
                immunity = {"acid", "poison"},
                attackAttributes = {"spit", "acid"},
                acceptRate = {1, 10, 0.8, 0.6},
                attributes = {},
                drops = {"nilArtifact"}
            },
            {
                type = "hive",
                name = "hive",
                immunity = {"acid", "poison"},
                acceptRate = {2, 10, 0.001, 0.0175},
                attributes = {},
                drops = {"nilArtifact"},
                buildSets = {
                    {"spitter", 1, 10},
                    {"biter", 1, 10}
                }
            }
        }
    }
end

if settings.startup["rampantFixed--laserEnemy"].value then
    constants.FACTION_SET[#constants.FACTION_SET+1] = {
        type = "laser",
        tint = {r=0, g=0.6, b=0.6, a=1},		-- + !КДА 2021.11	{r=0.3, g=0.3, b=0.42, a=1}
        tint2 = {r=0, g=1, b=1, a=1},
        acceptRate = {2, 10, 0.1, 0.15},
        evo = 0.10,
        units = {
            {
                type = "biter",
                attackAttributes = {"melee"},
                name = "biter",
				immunity = {"laser"},	
                majorResistances = {"electric"},
                minorResistances = {"fire", "acid"},
                minorWeaknesses = {"physical"},
                attributes = {{"overdamageProtection", 1.5}},		
                drops = {"blueArtifact"}
            },
            {
                type = "spitter",
                attackAttributes = {"spit", "laser", "cluster"},	
                name = "spitter",
				immunity = {"laser"},	
                majorResistances = {"electric"},
                minorResistances = {"fire", "acid"},
                minorWeaknesses = {"physical"},
                attributes = {"quickCooldown", {"overdamageProtection", 1.5}},		
                drops = {"blueArtifact"}
            }
        },
        buildings = {
            {
                type = "spitter-spawner",
                name = "spitter-spawner",
				immunity = {"laser"},	
                minorResistances = {"fire", "acid"},
                minorWeaknesses = {"physical"},
                acceptRate = {1, 10, 0.3, 0.5},
                attributes = {},
                drops = {"blueArtifact"},
                buildSets = {
                    {"spitter", 1, 10}
                }
            },
            {
                type = "biter-spawner",
                name = "biter-spawner",
				immunity = {"laser"},	
                minorResistances = {"fire", "acid"},
                minorWeaknesses = {"physical"},
                acceptRate = {1, 10, 0.3, 0.5},
                attributes = {},
                drops = {"blueArtifact"},
                buildSets = {
                    {"biter", 1, 10}
                }
            },
            {
                type = "turret",
                name = "worm",
				immunity = {"laser"},	
                minorResistances = {"fire", "acid"},
                minorWeaknesses = {"physical"},
                attackAttributes = {"spit", "laser", "cluster"},
                acceptRate = {1, 10, 0.8, 0.6},
                attributes = {},
                drops = {"blueArtifact"}
            },
            {
                type = "hive",
                name = "hive",
				immunity = {"laser"},	
                minorResistances = {"fire", "acid"},
                minorWeaknesses = {"physical"},
                attributes = {},
                acceptRate = {2, 10, 0.001, 0.0175},
                drops = {"blueArtifact"},
                buildSets = {
                    {"spitter", 1, 10},
                    {"biter", 1, 10}
                }
            }
        }
    }
end

if settings.startup["rampantFixed--fireEnemy"].value then
    constants.FACTION_SET[#constants.FACTION_SET+1] = {
        type = "fire",
        tint = {r=1, g=1, b=1, a=1},
        tint2 = {r=0.9, g=0.2, b=0.2, a=1},
        acceptRate = {4, 10, 0.1, 0.15},	-- {2, 10, 0.1, 0.15}
        evo = 0.12,
        units = {
            {
                type = "biter",
                attackAttributes = {"melee"},
                name = "biter",
				immunity = {"fire"},	
                majorResistances = {"acid"},
                minorResistances = {"physical"},
                minorWeaknesses = {"laser"},
                attributes = {"fireDeathCloud"},
                drops = {"redArtifact"}
            },
            {
                type = "spitter",
                attackAttributes = {{"flame", 2}},	--	{"flame", rangebonus}		{"spit", "acid"},
                name = "spitter",
				immunity = {"fire"},	
                majorResistances = {"acid"},
                minorResistances = {"physical"},
                majorWeaknesses = {"laser"},
                attributes = {},
                drops = {"redArtifact"}
            }
        },
        buildings = {
            {
                type = "spitter-spawner",
                name = "spitter-spawner",
				immunity = {"fire","electric"},
                majorResistances = {"acid"},
                minorResistances = {"physical"},
                minorWeaknesses = {"laser"},
                acceptRate = {1, 10, 0.3, 0.5},
                attributes = {"fireDeathCloud"},
                drops = {"redArtifact"},
                buildSets = {
                    {"spitter", 1, 10}
                }
            },
            {
                type = "biter-spawner",
                name = "biter-spawner",
				immunity = {"fire"},
                majorResistances = {"acid"},
                minorResistances = {"physical"},
                minorWeaknesses = {"laser"},
                acceptRate = {1, 10, 0.3, 0.5},
                minorResistances = {},
                attributes = {"fireDeathCloud"},
                drops = {"redArtifact"},
                buildSets = {
                    {"biter", 1, 10}
                }
            },
            {
                type = "turret",
                name = "worm",
				immunity = {"fire"},
                majorResistances = {"acid"},
                minorResistances = {"physical"},
                minorWeaknesses = {"laser"},
                attackAttributes = {{"flame", 8, 5}},	-- , 8, 6: +8 add range, x6 damage			--{"spit", "acid"},
                acceptRate = {1, 10, 0.8, 0.6},
                attributes = {"fireDeathCloud", "largePrepRange"},
                drops = {"redArtifact"}
            },
            {
                type = "hive",
                name = "hive",
				immunity = {"fire"},
                majorResistances = {"acid"},
                minorResistances = {"physical"},
                minorWeaknesses = {"laser"},
                attributes = {},
                acceptRate = {2, 10, 0.001, 0.0175},
                drops = {"redArtifact"},
                buildSets = {
                    {"spitter", 1, 10},
                    {"biter", 1, 10}
                }
            }
        }
    }
end

if settings.startup["rampantFixed--infernoEnemy"].value then
    constants.FACTION_SET[#constants.FACTION_SET+1] = {
        type = "inferno",
        tint = {r=0.5, g=0.1, b=0.1, a=1},
        tint2 = {r=0.9, g=0.1, b=0.1, a=1},
        acceptRate = {6, 10, 0.05, 0.15},	-- + !КДА 2021.11	{3, 10, 0.1, 0.125}
        evo = 0.2,
        units ={
            {
                type = "spitter",
                attackAttributes = {"stream", "acid"},
                name = "spitter",
                extremeResistances = {"acid", "fire"},
                minorWeaknesses = {"poison"},
                majorWeaknesses = {"laser"},
                attributes = {},
                drops = {"orangeArtifact"}
            }
        },
        buildings = {
            {
                type = "spitter-spawner",
                name = "spitter-spawner",
                extremeResistances = {"acid", "fire"},
                minorWeaknesses = {"poison"},
                majorWeaknesses = {"laser"},
                acceptRate = {1, 10, 0.4, 0.6},
                attributes = {},
                drops = {"orangeArtifact"},
                buildSets = {
                    {"spitter", 1, 10}
                }
            },
            {
                type = "turret",
                name = "worm",
                extremeResistances = {"acid", "fire"},
                minorWeaknesses = {"poison"},
                majorWeaknesses = {"laser"},
                acceptRate = {1, 10, 0.8, 0.6},
                attackAttributes = {"stream", "acid"},
                attributes = {},
                drops = {"orangeArtifact"}
            },
            {
                type = "hive",
                name = "hive",
                extremeResistances = {"fire", "acid"},
                minorWeaknesses = {"poison"},
                majorWeaknesses = {"laser"},
                attributes = {},
                acceptRate = {2, 10, 0.001, 0.0175},
                drops = {"orangeArtifact"},
                buildSets = {
                    {"spitter", 1, 10}
                }
            }
        }
    }
end

if settings.startup["rampantFixed--waspEnemy"].value then
    constants.FACTION_SET[#constants.FACTION_SET+1] = {
        type = "wasp",
        tint = {r=1, g=1, b=0, a=1},
        tint2 = {r=0, g=0, b=0, a=1},
        acceptRate = {3, 10, 0.1, 0.15},
        evo = 0.2,
        units = {
            {
                type = "drone",
                attackAttributes = {"spit", "acid"},
                name = "wasp",
                attributes = {"followsPlayer", "notInKillStatistics"},
                drops = {"purpleArtifact"}
            },
            {
                type = "drone",
                attackAttributes = {"lowDamageStream", "acid"},
                name = "worm-wasp",
                attributes = {"stationary", "notInKillStatistics"},
                drops = {}
            },
            {
                type = "spitter",
                attackAttributes = {"capsule", {"drone", "wasp"}},
                name = "spitter",
                attributes = {},
                drops = {"purpleArtifact"}
            }
        },
        buildings = {
            {
                type = "spitter-spawner",
                name = "spitter-spawner",
                attributes = {},
                acceptRate = {1, 10, 0.4, 0.6},
                drops = {"purpleArtifact"},
                buildSets = {
                    {"spitter", 1, 10}
                }
            },
            {
                type = "turret",
                name = "worm",
                attackAttributes = {"capsule", {"drone", "worm-wasp"}},
                acceptRate = {1, 10, 0.8, 0.6},
                attributes = {},
                drops = {"purpleArtifact"}
            },
            {
                type = "hive",
                name = "hive",
                attributes = {},
                acceptRate = {2, 10, 0.001, 0.0175},
                drops = {"purpleArtifact"},
                buildSets = {
                    {"spitter", 1, 10}
                }
            }
        }
    }
end

if settings.startup["rampantFixed--spawnerEnemy"].value then
    constants.FACTION_SET[#constants.FACTION_SET+1] = {
        type = "spawner",
        tint = {r=0.7, g=0.1, b=0.7, a=1},
        tint2 = {r=1, g=0.4, b=1, a=1},
        acceptRate = {3, 10, 0.1, 0.15},
        evo = 0.2,
        units = {
            {
                type = "biter",
                attackAttributes = {"melee"},
                name = "spawn",
                attributes = {"noCollision","fragile", "unstable", "smallest", "selfDamaging", "notInKillStatistics", "noLoot", {"spawnOnDeath", "spawn", -2, 1}},			
                drops = {}
            },
            {
                type = "drone",
                attackAttributes = {"touch", "acid"},
                name = "egg",
                attributes = {"stationary", "bigger", "notInKillStatistics", {"clusterDeath", "spawn"}},	
                drops = {}
            },
            {
                type = "drone",
                attackAttributes = {"touch", "acid"},
                name = "worm-egg",
                attributes = {"stationary", "bigger", "notInKillStatistics", {"clusterDeath", "spawn"}},
                drops = {}
            },
            {
                type = "spitter",
                attackAttributes = {{"spawnSpit", "egg", 0, 1, "drone"}},			--{"capsule", {"drone", "egg"}}
                name = "spitter",
                attributes = {"selfDamaging", {"spawnOnDeath", "spawn", 0, 3}, {"longRangeImmunity", 30}},	
                drops = {"purpleArtifact"}
            }
        },
        buildings = {
            {
                type = "spitter-spawner",
                name = "spitter-spawner",
                attributes = {},
                drops = {"purpleArtifact"},
                acceptRate = {1, 10, 0.4, 0.6},
                buildSets = {
                    {"spitter", 1, 10}
                }
            },
            {
                type = "turret",
                name = "worm",
                attackAttributes = {"capsule", {"drone", "worm-egg"}},
                acceptRate = {1, 10, 0.8, 0.6},
                attributes = {},
                drops = {"purpleArtifact"}
            },
            {
                type = "hive",
                name = "hive",
                attributes = {},
                acceptRate = {2, 10, 0.001, 0.0175},
                drops = {"purpleArtifact"},
                buildSets = {
                    {"spitter", 1, 10}
                }
            }
        }
    }
end

if settings.startup["rampantFixed--electricEnemy"].value then
    constants.FACTION_SET[#constants.FACTION_SET+1] = {
        type = "electric",
        tint = {r=0.7, g=0.7, b=1.0, a=1},
        tint2 = {r=0.2, g=0.2, b=1, a=1},
        acceptRate = {2, 10, 0.1, 0.15},
        evo = 0.1,
        units = {
            {
                type = "biter",
                attackAttributes = {"beam", "electric"},
                name = "biter",
				immunity = {"electric"},	
                minorResistances = {"laser"},
                attributes = {"slowCooldown","lowHealth"},
                drops = {"blueArtifact"}
            }
        },
        buildings = {
            {
                type = "biter-spawner",
                name = "biter-spawner",
				immunity = {"electric"},	
                minorResistances = {"laser"},
                acceptRate = {1, 10, 0.4, 0.6},
                attributes = {},
                drops = {"blueArtifact"},
                buildSets = {
                    {"biter", 1, 10}
                }
            },
            {
                type = "turret",
                name = "worm",
				immunity = {"electric"},	
                minorResistances = {"laser"},
                acceptRate = {1, 10, 0.8, 0.6},
                attackAttributes = 	{"spit", "electric", "cluster"},
                attributes = {},
                drops = {"blueArtifact"}
            },
            {
                type = "hive",
                name = "hive",
				immunity = {"electric"},	
                minorResistances = {"laser"},
                attributes = {},
                acceptRate = {2, 10, 0.001, 0.0175},
                drops = {"blueArtifact"},
                buildSets = {
                    {"biter", 1, 10}
                }
            }
        }
    }
end

if settings.startup["rampantFixed--physicalEnemy"].value then
    constants.FACTION_SET[#constants.FACTION_SET+1] = {
        type = "physical",
        tint = {r=0.5, g=0.5, b=0.5, a=1},	-- + !КДА 2021.11	{r=0.9, g=0.9, b=0.9, a=1}
        tint2 = {r=0.4, g=0.4, b=0.4, a=1},	-- + !КДА 2021.11	{r=0.8, g=0.8, b=0.8, a=1}
        acceptRate = {5, 10, 0.1, 0.15},
        evo = 0.12,
        units = {
            {
                type = "biter",
                attackAttributes = {"melee"},
                name = "biter",
                majorResistances = {"physical", "explosion", "acid"},
                minorResistances = {"fire"},
                minorWeaknesses = {"laser"},
                attributes = {"highHealth", "longReach", "big", "slowMovement", "altBiterArmored", {"overdamageProtection", 2}},
                drops = {"redArtifact"}
            }
        },
        buildings = {
            {
                type = "biter-spawner",
                name = "biter-spawner",
                majorResistances = {"physical", "explosion", "acid"},
                minorResistances = {"fire"},
                minorWeaknesses = {"laser"},
                attributes = {"highHealth", "bigger"},
                acceptRate = {1, 10, 0.4, 0.6},
                drops = {"redArtifact"},
                buildSets = {
                    {"biter", 1, 10}
                }
            },
            {
                type = "turret",
                name = "worm",
                majorResistances = {"physical", "explosion", "acid"},
                minorResistances = {"fire"},
                minorWeaknesses = {"laser"},
                attackAttributes = {"spit", "physical"},
                acceptRate = {1, 10, 0.8, 0.6},
                attributes = {"highHealth", "bigger"},
                drops = {"redArtifact"}
            },
            {
                type = "hive",
                name = "hive",
                majorResistances = {"physical", "explosion", "acid"},
                minorResistances = {"fire"},
                minorWeaknesses = {"laser"},
                attributes = {"highHealth", "bigger"},
                acceptRate = {2, 10, 0.001, 0.0175},
                drops = {"redArtifact"},
                buildSets = {
                    {"biter", 1, 10}
                }
            }
        }
    }
end

if settings.startup["rampantFixed--trollEnemy"].value then
    constants.FACTION_SET[#constants.FACTION_SET+1] = {
        type = "troll",
        tint = {r=0.4, g=0.4, b=0.4, a=1},			-- {r=0.4, g=0.4, b=0.4, a=1}
        tint2 = {r=0.55, g=0, b=0, a=1},			-- {r=1, g=0.2, b=0.2, a=1}
        acceptRate = {3, 10, 0.1, 0.15},
        evo = 0.17,
        units = {
            {
                type = "biter",
                attackAttributes = {"melee"},
                name = "biter",
				majorResistances = {"explosion"},
                minorResistances = {"physical"},
                majorWeaknesses = {"fire"},
                attributes = {"highestHealth", "longReach", "bigger",
                              "highestRegen", "slowMovement", "altBiterArmored", {"overdamageProtection", 5}},
                drops = {"redArtifact"}
            }
        },
        buildings = {
            {
                type = "biter-spawner",
                name = "biter-spawner",
                minorResistances = {"physical", "explosion"},
                majorWeaknesses = {"fire"},
                acceptRate = {1, 10, 0.4, 0.6},
                attributes = {"highestHealth", "bigger", "highestRegen"},
                drops = {"redArtifact"},
                buildSets = {
                    {"biter", 1, 10}
                }
            },
            {
                type = "turret",
                name = "worm",
                minorResistances = {"physical", "explosion"},
                majorWeaknesses = {"fire"},
                attackAttributes = {"spit", "physical"},
                acceptRate = {1, 10, 0.8, 0.6},
                attributes = {"highestHealth", "bigger", "highestRegen"},
                drops = {"redArtifact"}
            },
            {
                type = "hive",
                name = "hive",
                minorResistances = {"physical", "explosion"},
                majorWeaknesses = {"fire"},
                attributes = {"highestHealth", "bigger", "highRegen"},
                acceptRate = {2, 10, 0.001, 0.0175},
                drops = {"redArtifact"},
                buildSets = {
                    {"biter", 1, 10}
                }
            }
        }
    }
end

if settings.startup["rampantFixed--poisonEnemy"].value then
    constants.FACTION_SET[#constants.FACTION_SET+1] = {
        type = "poison",
        tint = {r=0.4, g=0.6, b=0.5, a=1},
        tint2 = {r=0, g=0.7, b=0, a=1},
--        acceptRate = {2, 10, 0.1, 0.15},
        acceptRate = {6, 10, 0.075, 0.15},
        evo = 0.17,
        units = {
            {
                type = "biter",
                attackAttributes = {"melee"},
                name = "biter",
                majorResistances = {"poison"},
                minorResistances = {"fire", "acid"},
                majorWeaknesses = {"laser"},
                minorWeaknesses = {"explosion"},
                attributes = {"poisonDeathCloud"},
                drops = {"greenArtifact"}
            }
        },
        buildings = {
            {
                type = "biter-spawner",
                name = "biter-spawner",
                majorResistances = {"poison"},
                minorResistances = {"fire", "acid"},
                minorWeaknesses = {"explosion", "laser"},
                attributes = {"poisonDeathCloud"},
                acceptRate = {1, 10, 0.4, 0.6},
                drops = {"greenArtifact"},
                buildSets = {
                    {"biter", 1, 10}
                }
            },
            {
                type = "turret",
                name = "worm",
                majorResistances = {"poison"},
                minorResistances = {"fire", "acid"},
                minorWeaknesses = {"explosion", "laser"},
                acceptRate = {1, 10, 0.8, 0.6},
                attackAttributes = {"spit", "poison"},
                attributes = {"poisonDeathCloud"},
                drops = {"greenArtifact"}
            },
            {
                type = "hive",
                name = "hive",
                majorResistances = {"poison"},
                minorResistances = {"fire", "acid"},
                minorWeaknesses = {"explosion", "laser"},
                attributes = {},
                acceptRate = {2, 10, 0.001, 0.0175},
                drops = {"greenArtifact"},
                buildSets = {
                    {"biter", 1, 10}
                }
            }
        }
    }
end

if settings.startup["rampantFixed--suicideEnemy"].value then
    constants.FACTION_SET[#constants.FACTION_SET+1] = {
        type = "suicide",
        tint = {r=0.8, g=0.8, b=0.8, a=1},
        tint2 = {r=1, g=0.5, b=0, a=1},
        acceptRate = {2, 10, 0.1, 0.15},	--{2, 10, 0.05, 0.15}
        evo = 0.35,
        units = {
            {
                type = "biter",
                attackAttributes = {"bomb"},
                name = "biter",
                majorResistances = {"fire", "acid"},
                minorResistances = {"poison"},
                majorWeaknesses = {"explosion"},
                attributes = {"lowestHealth", "quickSpawning", "quickMovement", "killsSelf", "lowestCollision", {"longRangeImmunity", 18}, {"overdamageProtection", 4}},
                drops = {"yellowArtifact"}
            }
        },
        buildings = {
            {
                type = "biter-spawner",
                name = "biter-spawner",
                majorResistances = {"fire", "acid"},
                minorResistances = {"poison"},
                majorWeaknesses = {"explosion"},
                acceptRate = {1, 10, 0.4, 0.6},
                attributes = {},				
                drops = {"yellowArtifact", "quickSpawning", "lowUnits"},	
                buildSets = {
                    {"biter", 1, 10}
                }
            },
            {
                type = "turret",
                name = "worm",
                majorResistances = {"fire", "acid"},
                minorResistances = {"poison"},
                majorWeaknesses = {"explosion"},
                attackAttributes = {"spit", "acid", "slow"},	
                acceptRate = {1, 10, 0.8, 0.6},
                attributes = {},
                drops = {"yellowArtifact"}
            },
            {
                type = "hive",
                name = "hive",
                majorResistances = {"fire", "acid"},
                minorResistances = {"poison"},
                majorWeaknesses = {"explosion"},
                attributes = {},				
                acceptRate = {2, 10, 0.001, 0.0175},
                drops = {"yellowArtifact"},
                buildSets = {
                    {"biter", 1, 10}
                }
            }
        }
    }
end

if settings.startup["rampantFixed--nuclearEnemy"].value then
    constants.FACTION_SET[#constants.FACTION_SET+1] = {
        type = "nuclear",
        tint = {r=0.1, g=0.5, b=0.1, a=1},
        tint2 = {r=1, g=0.5, b=0, a=1},
        --acceptRate = {4, 10, 0.1, 0.125},
        acceptRate = {7, 10, 0.025, 0.15},
        evo = 0.65,
        units = {
            {
                type = "biter",
                attackAttributes = {"nuclear"},
                name = "biter",
                majorResistances = {"fire", "acid"},
                majorWeaknesses = {"explosion"},
                attributes = {"lowestHealth", "quickMovement", "quickSpawning", "killsSelf", {"overdamageProtection", 5}},
                drops = {"yellowArtifact"}
            }
        },
        buildings = {
            {
                type = "biter-spawner",
                name = "biter-spawner",
                majorResistances = {"fire", "acid"},
                majorWeaknesses = {"explosion"},
                acceptRate = {1, 10, 0.4, 0.6},
                attributes = {"quickSpawning"},				
                drops = {"yellowArtifact"},
                buildSets = {
                    {"biter", 1, 10}
                }
            },
            {
                type = "turret",
                name = "worm",
                majorResistances = {"fire", "acid"},
                majorWeaknesses = {"explosion"},
                acceptRate = {1, 10, 0.8, 0.6},
                attackAttributes = {"spit", "acid", "slow"},
                attributes = {},
                drops = {"yellowArtifact"}
            },
            {
                type = "hive",
                name = "hive",
                majorResistances = {"fire", "acid"},
                majorWeaknesses = {"explosion"},
                attributes = {},				
                acceptRate = {2, 10, 0.001, 0.0175},
                drops = {"yellowArtifact"},
                buildSets = {
                    {"biter", 1, 10}
                }
            }
        }
    }
end

if settings.startup["rampantFixed--energyThiefEnemy"].value then
    constants.FACTION_SET[#constants.FACTION_SET+1] = {
        type = "energy-thief",
        tint = {r=0.2, g=0.2, b=0.4, a=1},
        tint2 = {r=0.1, g=0.1, b=0.1, a=1},
        acceptRate = {3, 10, 0.1, 0.15},
        evo = 0.2,
        units = {
            {
                type = "biter",
                attackAttributes = {"beam", "electric", "drainCrystal"},
                name = "biter",
                majorResistances = {"electric", "laser"},
                minorResistances = {"explosion"},
                minorWeaknesses = {"physical"},
                attributes = {"slowCooldown", "not-flammable", {"overdamageProtection", 2}},
                drops = {"blueArtifact"}
            }
        },
        buildings = {
            {
                type = "biter-spawner",
                name = "biter-spawner",
                majorResistances = {"electric", "laser"},
                minorResistances = {"explosion"},
                acceptRate = {1, 10, 0.4, 0.6},
                attributes = {},
                drops = {"blueArtifact"},
                buildSets = {
                    {"biter", 1, 10}
                }
            },
            {
                type = "turret",
                name = "worm",
                majorResistances = {"electric", "laser"},
                minorResistances = {"explosion"},
                acceptRate = {1, 10, 0.8, 0.6},
                attackAttributes = {"beam", "electric", "drainCrystal", {"bonusRange", 14}, {"damageKoefficient", 5}, {"durationKoefficient", 0.8}},
                attributes = {},
                drops = {"blueArtifact"}
            },
            {
                type = "hive",
                name = "hive",
                majorResistances = {"electric", "laser"},
                minorResistances = {"explosion"},
                attributes = {},
                acceptRate = {2, 10, 0.001, 0.0175},
                drops = {"blueArtifact"},
                buildSets = {
                    {"biter", 1, 10}
                }
            }
        }
    }
end

if settings.startup["rampantFixed--fastEnemy"].value then
    constants.FACTION_SET[#constants.FACTION_SET+1] = {
        type = "fast",
        tint = {r=0.9, g=0.9, b=0.9, a=1},
        tint2 = {r=1, g=1, b=0.1, a=1},
        acceptRate = {2, 10, 0.1, 0.15},
        evo = 0.12,
        units = {
            {
                type = "biter",
                attackAttributes = {"melee"},
                name = "biter",
                majorResistances = {},
                minorResistances = {"explosion","acid"},
                attributes = {"quickCooldown", "quickMovement", "not-flammable", {"longRangeImmunity", 20}},			
                drops = {"purpleArtifact"}
            },
            {
                type = "spitter",
                attackAttributes = {"spit", "acid"},
                name = "spitter",
                majorResistances = {},
                minorResistances = {"explosion", "acid"},
                attributes = {"quickCooldown", "quickMovement", "not-flammable", {"longRangeImmunity", 25}, {"bonusRange", -2}},			
                drops = {"purpleArtifact"}
            }
        },
        buildings = {
            {
                type = "spitter-spawner",
                name = "spitter-spawner",
                majorResistances = {},
                minorResistances = {"explosion", "acid"},
                attributes = {"quickSpawning"},			
                acceptRate = {1, 10, 0.3, 0.5},
                drops = {"purpleArtifact"},
                buildSets = {
                    {"spitter", 1, 10}
                }
            },
            {
                type = "biter-spawner",
                name = "biter-spawner",
                majorResistances = {},
                minorResistances = {"explosion", "acid"},		
                acceptRate = {1, 10, 0.3, 0.5},
                attributes = {"quickSpawning"},	
                drops = {"purpleArtifact"},
                buildSets = {
                    {"biter", 1, 10}
                }
            },
            {
                type = "turret",
                name = "worm",
                majorResistances = {},
                minorResistances = {"explosion", "acid"},
                acceptRate = {1, 10, 0.8, 0.6},
                attackAttributes = {"spit", "acid"},
                attributes = {"quickCooldown"},
                drops = {"purpleArtifact"}
            },
            {
                type = "hive",
                name = "hive",
                majorResistances = {},
                minorResistances = {"explosion", "acid"},
                attributes = {"quickSpawning"},		
                acceptRate = {2, 10, 0.001, 0.0175},
                drops = {"purpleArtifact"},
                buildSets = {
                    {"biter", 1, 10},
                    {"spitter", 1, 10}
                }
            }
        }
    }
end

if settings.startup["rampantFixed--JuggernautEnemy"].value then
    constants.FACTION_SET[#constants.FACTION_SET+1] = {
        type = "juggernaut",
        tint = {r=0.7, g=0.2, b=0.2, a=1},
        tint2 = {r=0, g=0.7, b=0, a=0.7},
        acceptRate = {9, 10, 0.10, 0.15},
        evo = 0.75,
        units = {
            {
                type = "biter",
                attackAttributes = {"meleePoisonCloud"},
                name = "biter",
                extremeResistances = {"fire", "physical"},
                majorResistances = {"poison","explosion"},
                minorResistances = {"acid"},
                attributes = {"highestHealth", "longReach", "bigger",
                              {"movement", 0.8}, "altBiterArmored", "poisonDeathCloud"},	
                drops = {"greenArtifact"}
            }
        },
        buildings = {
            {
                type = "biter-spawner",
                name = "biter-spawner",
                extremeResistances = {"fire", "acid", "physical"},
                majorResistances = {"poison","explosion"},
                minorResistances = {},
                attributes = {"highestHealth", "bigger", "highestRegen", "poisonDeathCloud"},
                acceptRate = {1, 10, 0.4, 0.6},
                drops = {"greenArtifact"},
                buildSets = {
                    {"biter", 1, 10}
                }
            },
            {
                type = "turret",
                name = "worm",
                extremeResistances = {"fire", "acid", "physical"},
                majorResistances = {"poison","explosion"},
                minorResistances = {},
                acceptRate = {1, 10, 0.8, 0.6},
                attackAttributes = {"spit", "poison"},
                attributes = {"poisonDeathCloud"},
                drops = {"greenArtifact"}
            },
            {
                type = "hive",
                name = "hive",
                extremeResistances = {"fire", "acid", "physical"},
                majorResistances = {"poison","explosion"},
                attributes = {"highestHealth", "highestRegen", "poisonDeathCloud"},
                minorResistances = {},
                acceptRate = {2, 10, 0.001, 0.0175},
                drops = {"greenArtifact"},
                buildSets = {
                    {"biter", 1, 10}
                }
            }
        }
    }
end

if settings.startup["rampantFixed--ArachnidsEnemy"].value then
    constants.FACTION_SET[#constants.FACTION_SET+1] = {
        type = "arachnids",
        tint = {r=0.6, g=0.2, b=1, a=1},
        tint2 = {r=0.6, g=0.2, b=1, a=1},
        acceptRate = {4, 10, 0.10, 0.15},
        evo = 0.75,
        units = {
            {
                type = "biter",
                attackAttributes = {"melee", "acid"},		--, "acidPool"
                name = "biter",
                immunity = {"acid", "poison"},
                minorResistances = {"laser", "fire"},
                majorWeaknesses = {"physical"},
                attributes = {"highestHealth", {"movement", 0.8}, "altBiterArachnid", {"spawnOnDeath", "egg", 0, 1, "drone"}},	
                drops = {"nilArtifact"}
            },
            {
                type = "drone",
                attackAttributes = {"touch", "acid"},
                name = "egg",
                immunity = {"acid", "poison"},
				majorResistances = {"laser", "explosion", "fire", "electric"}, 
                majorWeaknesses = {"physical"},
                attributes = {"egg", "notInKillStatistics", {"clusterDeath", "biter", 1}},			--{"clusterDeath", "biter", 2}
                drops = {}
            }
        },
        buildings = {
            {
                type = "biter-spawner",
                name = "biter-spawner",
				immunity = {"acid", "poison"},	
                minorResistances = {"laser","fire"},
                attributes = {},
                acceptRate = {1, 10, 0.4, 0.6},
                drops = {"nilArtifact"},
                buildSets = {
                    {"biter", 1, 10}
                }
            },
            {
                type = "turret",
                name = "worm",
				immunity = {"acid", "poison"},	
                minorResistances = {"laser","fire"},
                majorWeaknesses = {"physical"},
                acceptRate = {1, 10, 0.4, 0.6},
                attackAttributes = {"spit", "acidPool"},
                attributes = {},
                drops = {"nilArtifact"}
            },
            {
                type = "hive",
                name = "hive",
				immunity = {"acid", "poison"},	
                minorResistances = {"laser","fire"},
                majorWeaknesses = {"physical"},
                attributes = {},
                acceptRate = {2, 10, 0.001, 0.0175},
                drops = {"nilArtifact"},
                buildSets = {
                    {"biter", 1, 10}
                }
            }
        }
    }
end
constants.HIVE_BUILDINGS_TYPES = {
    "trap",
    "turret",
    "utility",
    "spitter-spawner",
    "biter-spawner",
    "hive"
}

constants.VICTORY_SCENT_MULTIPLER = {}
for x=1,9 do
    for y=1,9 do
        local adjV
        local v
        if x <= 5 and y <= 5 then
            v = math.min(x, y)
        elseif x > 5 and y < 5 then
            v = math.min((10-x), y)
        elseif x < 5 and y > 5 then
            v = math.min(x, (10-y))
        else
            v = math.min((10-x), (10-y))
        end
        if v < 5 then
            adjV = v / 5
        else
            adjV = 1
        end
        constants.VICTORY_SCENT_MULTIPLER[#constants.VICTORY_SCENT_MULTIPLER+1] = adjV
    end
end

constants.HIVE_BUILDINGS_COST = {}
constants.HIVE_BUILDINGS_COST["trap"] = constants.BASE_WORM_UPGRADE * 0.5
constants.HIVE_BUILDINGS_COST["turret"] = constants.BASE_WORM_UPGRADE
constants.HIVE_BUILDINGS_COST["utility"] = constants.BASE_SPAWNER_UPGRADE * 1.5
constants.HIVE_BUILDINGS_COST["spitter-spawner"] = constants.BASE_SPAWNER_UPGRADE
constants.HIVE_BUILDINGS_COST["biter-spawner"] = constants.BASE_SPAWNER_UPGRADE
constants.HIVE_BUILDINGS_COST["hive"] = constants.BASE_SPAWNER_UPGRADE * 2

local biterAndSpitter = {}
biterAndSpitter["biter-spawner"] = 0
biterAndSpitter["spitter-spawner"] = 0	-- any non-nil value

constants.FACTION_CHANGING_MAPPING = {}
constants.FACTION_CHANGING_MAPPING["spitter-spawner"] = biterAndSpitter
constants.FACTION_CHANGING_MAPPING["biter-spawner"] = biterAndSpitter
constants.FACTION_CHANGING_MAPPING["hive"] = {hive = 0}
constants.FACTION_CHANGING_MAPPING["turret"] = {turret = 0}
constants.FACTION_CHANGING_MAPPING["trap"] = {trap = 0}
constants.FACTION_CHANGING_MAPPING["utility"] = {utility = 0}

constants.FACTION_EVOLVE_MAPPING = {}
constants.FACTION_EVOLVE_MAPPING["spitter-spawner"] = {hive = 0}
constants.FACTION_EVOLVE_MAPPING["biter-spawner"] = {hive = 0}
constants.FACTION_EVOLVE_MAPPING["turret"] = biterAndSpitter

constantsG =  constants
return constants
