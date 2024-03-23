if (aiPredicatesG) then
    return aiPredicatesG
end
local aiPredicates = {}

-- imports

local constants = require("Constants")

-- constants

local AI_STATE_RAIDING = constants.AI_STATE_RAIDING
local AI_STATE_AGGRESSIVE = constants.AI_STATE_AGGRESSIVE
local AI_STATE_MIGRATING = constants.AI_STATE_MIGRATING
local AI_STATE_SIEGE = constants.AI_STATE_SIEGE
local AI_STATE_ONSLAUGHT = constants.AI_STATE_ONSLAUGHT
local AI_STATE_GROWING = constants.AI_STATE_GROWING

-- imported functions

-- module code

function aiPredicates.canAttack(map, tick)
    local surface = map.surface
	if surface.peaceful_mode then
		return false
	end	
	if map.universe.aiNocturnalMode and (surface.darkness <= 0.65) then
		return false
	end
		
    local goodAI = (((map.state == AI_STATE_AGGRESSIVE) and (map.canAttackTick < tick)) or
            (map.state == AI_STATE_RAIDING) or
            (map.state == AI_STATE_SIEGE) or
            (map.state == AI_STATE_MIGRATING) or
			(map.state == AI_STATE_ONSLAUGHT) or
			(map.state == AI_STATE_GROWING)
		   )
   return goodAI
end

function aiPredicates.canMigrate(map)
    local surface = map.surface
    local universe = map.universe
    local nocturalMode = universe.aiNocturnalMode
    local goodAI = (map.state == AI_STATE_MIGRATING) or (map.state == AI_STATE_SIEGE)
    local noctural = (not nocturalMode) or (nocturalMode and surface.darkness > 0.65)
    return goodAI and universe.expansion and not surface.peaceful_mode and noctural
end

aiPredicatesG = aiPredicates
return aiPredicates
