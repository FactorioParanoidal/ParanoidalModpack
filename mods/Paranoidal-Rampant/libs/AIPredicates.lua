if (aiPredicatesG) then
    return aiPredicatesG
end
local aiPredicates = {}

-- imports

local constants = require("Constants")

-- constants

local AI_STATE_PEACEFUL = constants.AI_STATE_PEACEFUL
local AI_STATE_RAIDING = constants.AI_STATE_RAIDING
local AI_STATE_AGGRESSIVE = constants.AI_STATE_AGGRESSIVE
local AI_STATE_MIGRATING = constants.AI_STATE_MIGRATING
local AI_STATE_SIEGE = constants.AI_STATE_SIEGE
local AI_STATE_ONSLAUGHT = constants.AI_STATE_ONSLAUGHT
local AI_STATE_GROWING = constants.AI_STATE_GROWING

-- imported functions

-- module code

-- The settings can change before the next planning pass updates map.state.
function aiPredicates.truceInfo(map, tick, evolution)
    local all = map.universe.planetAISettings
    local planet = all and (all[map.surface.name] or all.others)
    if not (planet and type(planet.minEvo) == "number") then return false end
    local ends = (map.firstStateTick or 0) + (planet.peacePeriod or 0) * 3600
    if tick < ends then return true, planet.minEvo end
    local minEvolution = planet.minEvo * 0.01
    if minEvolution <= 0 then return false, planet.minEvo end
    local evo = evolution or game.forces.enemy.get_evolution_factor(map.surface)
    return evo < minEvolution, planet.minEvo
end

function aiPredicates.attackAllowed(map, tick, allowDay)
    local surface = map.surface
    return not (map.indexing or surface.peaceful_mode or map.state == AI_STATE_PEACEFUL
        or (not allowDay and map.universe.aiNocturnalMode and surface.darkness <= 0.65)
        or aiPredicates.truceInfo(map, tick))
end

function aiPredicates.canHunt(map, tick)
    local allowDay = map.universe.allowDaytimePlayerHunting
    if allowDay == nil then allowDay = settings.global["rampantFixed--allowDaytimePlayerHunting"].value end
    return aiPredicates.canAttack(map, tick) or (allowDay and map.universe.aiNocturnalMode
        and map.surface.darkness <= 0.65 and aiPredicates.canAttack(map, tick, true))
end

function aiPredicates.canAttack(map, tick, allowDay)
    if not aiPredicates.attackAllowed(map, tick, allowDay) then return false end

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
    return goodAI and universe.enabledMigration and noctural and aiPredicates.attackAllowed(map, game.tick)
end

aiPredicatesG = aiPredicates
return aiPredicates
