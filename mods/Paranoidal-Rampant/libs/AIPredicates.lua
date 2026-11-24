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

local function truceValue(proposed, stored, max)
    if type(proposed) == "number" and proposed >= 0 and proposed <= max then return proposed end
    if type(stored) == "number" and stored >= 0 and stored <= max then return stored end
end

-- Invalid edits keep the previous value; a save already missing a value uses the planet default.
function aiPredicates.planetTruceValues(name, row, minEvo, period)
    return truceValue(minEvo, row.minEvo, 100)
            or (name == "nauvis" and settings.global["rampantFixed--nauvisMinEvo"].value
                or (name == "vulcanus" and 25 or 20)),
        truceValue(period, row.peacePeriod, math.floor(2^53 / 3600)) or (name == "nauvis" and 60 or 120)
end

aiPredicates.FLYER_MIN_EVOLUTION = 0.10 -- also used by the native spawn curves in SwarmUtils

function aiPredicates.isRampantFlyer(name)
    return name:find("%-flyer%-v%d+%-t%d+%-rampant$") ~= nil
end

-- The credited unit, not its group's rally point or majority, proves a ground contact.
function aiPredicates.groundMember(surface, squad, unit)
    if not (unit and unit.valid and unit.type == "unit" and unit.surface == surface)
        or aiPredicates.isRampantFlyer(unit.name) then return false end
    local group, commandable = squad.group, unit.commandable
    return group and group.valid and commandable and commandable.parent_group == group
end

function aiPredicates.flyerEvolutionAllows(surface)
    return game.forces.enemy.get_evolution_factor(surface) >= aiPredicates.FLYER_MIN_EVOLUTION
end

function aiPredicates.canCreateUnitOnSurface(name, surface)
    return not aiPredicates.isRampantFlyer(name) or aiPredicates.flyerEvolutionAllows(surface)
end

-- The settings can change before the next planning pass updates map.state.
function aiPredicates.truceInfo(map, tick, evolution)
    local all = map.universe.planetAISettings
    local name = map.surface.name
    local planet = all and (all[name] or all.others)
    if not planet then
        local ends = map.truceEndTick or 0
        return tick < ends, nil, ends
    end
    local minEvo, period = aiPredicates.planetTruceValues(all[name] and name or "others", planet)
    local ends = (map.firstStateTick or 0) + period * 3600
    if tick < ends then return true, minEvo, ends end
    if minEvo <= 0 then return false, minEvo, ends end
    local evo = evolution or game.forces.enemy.get_evolution_factor(map.surface)
    return evo < minEvo * 0.01, minEvo, ends
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
