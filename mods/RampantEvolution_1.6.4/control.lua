-- Copyright (C) 2022  veden

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.


-- imports

local gui = require("libs/Gui")

--[[
    Vanilla factors
    time_factor
    :: double
    The amount evolution naturally progresses by every second. Defaults to 0.000004.

    destroy_factor
    :: double
    The amount evolution progresses for every destroyed spawner. Defaults to 0.002.

    pollution_factor
    :: double
    The amount evolution progresses for every unit of pollution. Defaults to 0.0000009.


    Pollution production is the total pollution produced by buildings per tick, not the
    pollution spreading on the map, so it is not reduced by trees or other absorbers.
    e.g. : 10 boilers produce 300 pollution in one minute, raising the evolution factor
    by around 0.027%.

    The percentages are applied on the base of (1 - current_evolution_factor)². So
    for instance destroying enemy spawners in the beginning of the game results in
    increase of evolution factor by 0.002 (0.2%) while doing this when the evolution
    factor is 0.5 the increase is only 0.0005 (0.05%).

    This also means that the evolution factor approaches 1 asymptotically - generally,
    increases past 0.9 or so are very slow and the number never actually reaches 1.0.
--]]

-- constants

local SETTINGS_TO_PERCENT = 1e-7
local SHORT_EVOLUTION_CHECK_DURATION = 5 * 60 * 60
local LONG_EVOLUTION_CHECK_DURATION = 30 * 60 * 60
local LONG_LONG_EVOLUTION_CHECK_DURATION = 60 * 60 * 60


local LOW_VALUE_PLAYER_STRUCTURES = {
    "turret",
    "ammo-turret",
    "electric-turret",
    "fluid-turret",
    "artillery-turret",
    "electric-pole"
}

local MEDIUM_VALUE_PLAYER_STRUCTURES = {
    "solar-panel",
    "accumulator",
    "radar",
    "storage-tank",
    "container",
    "logistic-container",
    "lab"
}

local HIGH_VALUE_PLAYER_STRUCTURES = {
    "assembling-machine",
    "furnace",
    "roboport",
    "beacon",
    "boiler",
    "generator",
    "mining-drill",
    "reactor",
    "rocket-silo"
}

-- imported functions

local sFind = string.find
local mMin = math.min
local mMax = math.max
local roundTo = gui.roundTo
local calculateDisplayValue = gui.calculateDisplayValue

-- local references

local world

-- module code

local function linearInterpolation(percent, min, max)
    return ((max - min) * percent) + min
end

local function variableInterpolation(percent, min, max, exponent)
    return ((max - min) * (percent^exponent)) + min
end

local function onStatsGrabPollution()
    local pollutionStats = game.pollution_statistics
    local counts = pollutionStats.output_counts

    for name,count in pairs(counts) do
        local previousCount = world.pollutionConsumed[name]
        world.pollutionConsumed[name] = count
        local delta
        if not previousCount then
            delta = count
        else
            delta = count - previousCount
        end

        if delta ~= 0 then
            world.pollutionDeltas[name] = (world.pollutionDeltas[name] or 0) + delta
        end
    end
end

local function onStatsGrabTotalPollution()
    if world.evolutionPerPollution ~= 0 then
        local pollutionStats = game.pollution_statistics
        local counts = pollutionStats.input_counts

        for name,count in pairs(counts) do
            local previousCount = world.pollutionProduced[name]
            world.pollutionProduced[name] = count
            local delta
            if not previousCount then
                delta = count
            else
                delta = count - previousCount
            end

            if delta ~= 0 then
                world.pollutionDeltas["totalPollution"] = (world.pollutionDeltas["totalPollution"] or 0) + delta
            end
        end
    end
end

local function onStatsGrabKill()
    local killStats = game.forces.enemy.kill_count_statistics

    local counts = killStats.output_counts
    for name,count in pairs(counts) do
        local previousCount = world.kills[name]
        world.kills[name] = count
        local delta
        if not previousCount then
            delta = count
        else
            delta = count - previousCount
        end

        if delta ~= 0 then
            world.killDeltas[name] = (world.killDeltas[name] or 0) + delta
        end
    end

    counts = killStats.input_counts
    for name,count in pairs(counts) do
        local previousCount = world.kills[name]
        world.kills[name] = count
        local delta
        if not previousCount then
            delta = count
        else
            delta = count - previousCount
        end

        if delta ~= 0 then
            world.killDeltas[name] = (world.killDeltas[name] or 0) + delta
        end
    end
end

local function reset()
    world.killDeltasIterator = nil
    world.pollutionDeltasIterator = nil
    world.kills = {}
    world.killDeltas = {
        ["time"] = math.floor(game.tick / 60)
    }
    world.totalEvolution = 0
    world.researchCompleted = 0
    world.totalResearch = 0
    world.ticksAccrued = 0
    world.researchEvolutionMultiplier = 0
    world.tickEvolutionMultiplier = 0
    world.totalPostiveEvolution = 0
    world.totalNegativeEvolution = 0
    world.pollutionConsumed = {}
    world.pollutionProduced = {}
    world.pollutionDeltas = {}
    world.stats = {
        ["tile"] = 0,
        ["tree"] = 0,
        ["dyingTree"] = 0,
        ["absorbed"] = 0,
        ["spawner"] = 0,
        ["hive"] = 0,
        ["unit"] = 0,
        ["worm"] = 0,
        ["totalPollution"] = 0,
        ["time"] = 0,
        ["evolutionMultiplier"] = 0,
        ["minimumEvolution"] = 0,
        ["researchEvolutionCap"] = 0,
        ["lowPlayer"] = 0,
        ["mediumPlayer"] = 0,
        ["highPlayer"] = 0
    }
end

local function onModSettingsChange(event)

    if event and (string.sub(event.setting, 1, #"rampant-evolution") ~= "rampant-evolution") then
        return false
    end

    world.processingPerTick = settings.global["rampant-evolution--processingPerTick"].value

    world.evolutionPerSpawnerAbsorbed = settings.global["rampant-evolution-evolutionPerSpawnerAbsorbed"].value * SETTINGS_TO_PERCENT
    world.evolutionPerTreeAbsorbed = settings.global["rampant-evolution-evolutionPerTreeAbsorbed"].value * SETTINGS_TO_PERCENT
    world.evolutionPerTreeDied = settings.global["rampant-evolution-evolutionPerTreeDied"].value * SETTINGS_TO_PERCENT
    world.evolutionPerTileAbsorbed = settings.global["rampant-evolution-evolutionPerTileAbsorbed"].value * SETTINGS_TO_PERCENT
    world.evolutionPerSpawnerKilled = settings.global["rampant-evolution-evolutionPerSpawnerKilled"].value * SETTINGS_TO_PERCENT
    world.evolutionPerUnitKilled = settings.global["rampant-evolution-evolutionPerUnitKilled"].value * SETTINGS_TO_PERCENT
    world.evolutionPerHiveKilled = settings.global["rampant-evolution-evolutionPerHiveKilled"].value * SETTINGS_TO_PERCENT
    world.evolutionPerWormKilled = settings.global["rampant-evolution--evolutionPerWormKilled"].value * SETTINGS_TO_PERCENT

    world.evolutionPerTime = settings.global["rampant-evolution--evolutionPerTime"].value * SETTINGS_TO_PERCENT
    world.evolutionPerPollution = settings.global["rampant-evolution--evolutionPerPollution"].value * SETTINGS_TO_PERCENT

    world.displayEvolutionMsg = settings.global["rampant-evolution--displayEvolutionMsg"].value
    world.displayEvolutionMsgInterval = math.ceil(settings.global["rampant-evolution--displayEvolutionMsgInterval"].value * (60 * 60))

    world.minimumDevolutionPercentage = settings.global["rampant-evolution--minimumDevolutionPercentage"].value

    world.evolutionResolutionLevel = settings.global["rampant-evolution--evolutionResolutionLevel"].value

    world.spawnerLookup = {}
    world.hiveLookup = {}
    world.wormLookup = {}
    world.unitLookup = {}

    if settings.global["rampant-evolution--recalculateAllEvolution"].value then
        reset()
        game.forces.enemy.evolution_factor = 0
        game.print({"description.rampant-evolution--refreshingEvolution"})
    end

    for entityName, entityPrototype in pairs(game.entity_prototypes) do
        if (entityPrototype.type == "unit-spawner") and sFind(entityName, "-spawner") then
            world.spawnerLookup[entityName] = 1
        elseif (entityPrototype.type == "unit-spawner") and sFind(entityName, "-hive") then
            world.hiveLookup[entityName] = 1
        elseif (entityPrototype.type == "turret") and sFind(entityName, "-worm") then
            world.wormLookup[entityName] = 1
        elseif (entityPrototype.type == "unit") and (sFind(entityName, "biter") or sFind(entityName, "spitter")) then
            world.unitLookup[entityName] = 1
        end
    end

    world.enabledResearchEvolutionCap = settings.global["rampant-evolution--researchEvolutionCap"].value
    world.researchLookup = {}
    world.researchTotals = {}
    world.researchCurrent = {}

    local sciencePackWeightLookup = {
        [1] = settings.global["rampant-evolution--technology-automation-science-multiplier"].value,
        [2] = settings.global["rampant-evolution--technology-logistic-science-multiplier"].value,
        [3] = settings.global["rampant-evolution--technology-military-science-multiplier"].value,
        [4] = settings.global["rampant-evolution--technology-chemical-science-multiplier"].value,
        [5] = settings.global["rampant-evolution--technology-production-science-multiplier"].value,
        [6] = settings.global["rampant-evolution--technology-utility-science-multiplier"].value,
        [7] = settings.global["rampant-evolution--technology-space-science-multiplier"].value
    }
    local sciencePackOrder = {
        "automation-science-pack",
        "logistic-science-pack",
        "military-science-pack",
        "chemical-science-pack",
        "production-science-pack",
        "utility-science-pack",
        "space-science-pack"
    }
    local sciencePackOrderLookup = {}
    for index, science in pairs(sciencePackOrder) do
        sciencePackOrderLookup[science] = index
        world.researchTotals[index] = 0
        world.researchCurrent[index] = 0
    end

    local totalTechnology = 0
    local includeUpgrades = settings.global["rampant-evolution--researchEvolutionCapIncludeUpgrades"].value

    for technologyName, technologyPrototype in pairs(game.technology_prototypes) do
        local highestOrder = -1

        if not technologyPrototype.research_unit_count_formula
            and technologyPrototype.enabled
            and not technologyPrototype.hidden
            and ((not technologyPrototype.upgrade) or (technologyPrototype.upgrade and includeUpgrades))
        then
            for _, ingredient in pairs(technologyPrototype.research_unit_ingredients) do
                if sciencePackOrderLookup[ingredient.name] then
                    if highestOrder < sciencePackOrderLookup[ingredient.name] then
                        highestOrder = sciencePackOrderLookup[ingredient.name]
                    end
                end
            end
            if (highestOrder ~= -1) then
                local weight = sciencePackWeightLookup[highestOrder]
                totalTechnology = totalTechnology + weight
                world.researchTotals[highestOrder] = (world.researchTotals[highestOrder] or 0) + weight
                world.researchLookup[technologyName] = {weight, highestOrder}
                world.totalResearch = world.totalResearch + 1
            end
        end
    end

    for tech, value in pairs(world.researchLookup) do
        world.researchLookup[tech][1] = value[1] / totalTechnology
    end
    for scienceIndex=1,#sciencePackOrder do
        world.researchTotals[scienceIndex] = world.researchTotals[scienceIndex] / totalTechnology
    end

    for technologyName, technology in pairs(game.forces.player.technologies) do
        if technology.researched then
            local evolutionIncrease = world.researchLookup[technologyName]
            if evolutionIncrease then
                world.researchCompleted = world.researchCompleted + 1
                if world.enabledResearchEvolutionCap then
                    world.researchCurrent[evolutionIncrease[2]] = world.researchCurrent[evolutionIncrease[2]] + evolutionIncrease[1]
                    world.stats["researchEvolutionCap"] = world.stats["researchEvolutionCap"] + evolutionIncrease[1]
                end
            end
        end
    end

    if not world.enabledResearchEvolutionCap then
        world.stats["researchEvolutionCap"] = 0.9999999999999
    end

    world.toggleResearchEvolutionMultiplier = settings.global["rampant-evolution--toggleResearchEvolutionMultiplier"].value
    world.startResearchEvolutionMultiplier = settings.global["rampant-evolution--startResearchMultiplier"].value
    world.endResearchEvolutionMultiplier = settings.global["rampant-evolution--endResearchMultiplier"].value
    world.researchMultiplierExponent = settings.global["rampant-evolution--researchMultiplierExponent"].value

    world.toggleTickEvolutionMultiplier = settings.global["rampant-evolution--toggleTickEvolutionMultiplier"].value
    world.startTickEvolutionMultiplier = settings.global["rampant-evolution--startTickMultiplier"].value
    world.endTickEvolutionMultiplier = settings.global["rampant-evolution--endTickMultiplier"].value
    world.tickMultiplierExponent = settings.global["rampant-evolution--tickMultiplierExponent"].value

    if world.toggleResearchEvolutionMultiplier then
        world.researchEvolutionMultiplier = variableInterpolation(
            (world.researchCompleted / world.totalResearch),
            world.startResearchEvolutionMultiplier,
            world.endResearchEvolutionMultiplier,
            world.researchMultiplierExponent
        )

        world.stats.evolutionMultiplier = world.researchEvolutionMultiplier + world.tickEvolutionMultiplier
    end

    world.totalTicksAccruable = settings.global["rampant-evolution--totalTickMultiplier"].value * (60 * 60)

    world.evolutionPerLowPlayer = settings.global["rampant-evolution--evolutionPerLowPlayer"].value * SETTINGS_TO_PERCENT
    world.evolutionPerMediumPlayer = settings.global["rampant-evolution--evolutionPerMediumPlayer"].value * SETTINGS_TO_PERCENT
    world.evolutionPerHighPlayer = settings.global["rampant-evolution--evolutionPerHighPlayer"].value * SETTINGS_TO_PERCENT

    local structureTypeLookup = {}
    for _, structure in pairs(LOW_VALUE_PLAYER_STRUCTURES) do
        structureTypeLookup[structure] = {world.evolutionPerLowPlayer, "lowPlayer"}
    end
    for _, structure in pairs(MEDIUM_VALUE_PLAYER_STRUCTURES) do
        structureTypeLookup[structure] = {world.evolutionPerMediumPlayer, "mediumPlayer"}
    end
    for _, structure in pairs(HIGH_VALUE_PLAYER_STRUCTURES) do
        structureTypeLookup[structure] = {world.evolutionPerHighPlayer, "highPlayer"}
    end

    world.playerStructureLookup = {}
    for entityName, entityPrototype in pairs(game.entity_prototypes) do
        local structureType = structureTypeLookup[entityPrototype.type]
        if structureType then
            world.playerStructureLookup[entityName] = structureType
        end
    end

    if settings.global["rampant-evolution--setMapSettingsToZero"].value then
        game.map_settings.enemy_evolution.enabled = false
    else
        game.map_settings.enemy_evolution.enabled = true
    end

    for playerIndex in pairs(world.playerGuiTick) do
        world.playerGuiTick[playerIndex] = nil
    end

    onStatsGrabPollution()
    onStatsGrabKill()
    onStatsGrabTotalPollution()

    if not settings.global["rampant-evolution--recalculateAllEvolution"].value then
        world.killDeltasIterator = nil
        world.pollutionDeltasIterator = nil
        world.killDeltas = {}
        world.pollutionDeltas = {}
    end

    return true
end

local function onConfigChanged()
    if not world.version or world.version < 11 then
        world.version = 11

        reset()

        world.tickModAdded = game.tick

        world.playerGuiOpen = {}
        world.playerGuiTick = {}

        world.lastChangeShortTick = 0
        world.lastChangeShortEvolution = 0
        world.lastChangeShort = 0
        world.lastChangeLongTick = 0
        world.lastChangeLongEvolution = 0
        world.lastChangeLong = 0
        world.lastChangeLongLongTick = 0
        world.lastChangeLongLongEvolution = 0
        world.lastChangeLongLong = 0
        world.playerIterator = nil

        onModSettingsChange()

        game.print("Rampant Evolution - Version 1.6.4")
    end
end

local function calculateEvolution(evo, evolutionModifier, stats, statField, runsRemaining)
    if world.toggleTickEvolutionMultiplier
        and (statField == "time")
    then
        world.ticksAccrued = world.ticksAccrued + (60 * runsRemaining)

        world.tickEvolutionMultiplier = variableInterpolation(
            world.ticksAccrued / world.totalTicksAccruable,
            world.startTickEvolutionMultiplier,
            world.endTickEvolutionMultiplier,
            world.tickMultiplierExponent
        )

        world.stats.evolutionMultiplier = world.researchEvolutionMultiplier + world.tickEvolutionMultiplier
    end

    if (evolutionModifier ~= 0) then
        local totalEvolution = world.totalEvolution
        local totalPostiveEvolution = world.totalPostiveEvolution
        local totalNegativeEvolution = world.totalNegativeEvolution
        local minimumEvolution = stats.minimumEvolution
        local evolutionMultiplier = 1 + stats.evolutionMultiplier
        local maximumEvolution = mMin(stats.researchEvolutionCap, 0.9999999999999)
        local minimumTotalEvolution = mMax(minimumEvolution / (1 - minimumEvolution), 0)
        local maximumTotalEvolution = maximumEvolution / (1 - maximumEvolution)
        local process = true

        while (runsRemaining > 0) and process do
            runsRemaining = runsRemaining - 1
            local contribution = (((1 - evo)^2) * evolutionModifier)
            local adjustedEvo = totalEvolution + (contribution * evolutionMultiplier)
            if adjustedEvo <= minimumTotalEvolution then
                contribution = minimumTotalEvolution - totalEvolution
                process = false
            elseif adjustedEvo >= maximumTotalEvolution then
                contribution = maximumTotalEvolution - totalEvolution
                process = false
            end

            if contribution > 0 then
                if process then
                    contribution = contribution * evolutionMultiplier
                end
                totalPostiveEvolution = totalPostiveEvolution + contribution
            else
                totalNegativeEvolution = totalNegativeEvolution + contribution
            end

            totalEvolution = totalEvolution + contribution
            evo = totalEvolution / (1+totalEvolution)
            stats[statField] = stats[statField] + contribution
        end
        local newMinimumEvolution = world.minimumDevolutionPercentage * evo
        if newMinimumEvolution > minimumEvolution then
            stats.minimumEvolution = newMinimumEvolution
        end
        world.totalNegativeEvolution = totalNegativeEvolution
        world.totalPostiveEvolution = totalPostiveEvolution
        world.totalEvolution = totalEvolution
    end
    return evo
end

local function processKill(evo, initialRunsRemaining)
    local name = world.killDeltasIterator
    local count
    if not name then
        name,count = next(world.killDeltas, nil)
    else
        count = world.killDeltas[name]
    end
    if not name then
        return evo
    end
    world.killDeltasIterator = next(world.killDeltas, name)
    local runsRemaining = math.min(initialRunsRemaining, count)
    count = count - runsRemaining
    if count <= 0 then
        world.killDeltas[name] = nil
    else
        world.killDeltas[name] = count
    end

    local evolutionModifier = 0
    local statField

    if name == "time" then
        evolutionModifier = world.evolutionPerTime
        statField = "time"
    elseif world.spawnerLookup[name] then
        evolutionModifier = world.evolutionPerSpawnerKilled
        statField = "spawner"
    elseif world.hiveLookup[name] then
        evolutionModifier = world.evolutionPerHiveKilled
        statField = "hive"
    elseif world.wormLookup[name] then
        evolutionModifier = world.evolutionPerWormKilled
        statField = "worm"
    elseif world.unitLookup[name] then
        evolutionModifier = world.evolutionPerUnitKilled
        statField = "unit"
    elseif world.playerStructureLookup[name] then
        local evolutionDeltaPair = world.playerStructureLookup[name]
        if evolutionDeltaPair and evolutionDeltaPair[1] ~= 0 then
            evolutionModifier = evolutionDeltaPair[1]
            statField = evolutionDeltaPair[2]
        end
    end

    return calculateEvolution(
        evo,
        evolutionModifier,
        world.stats,
        statField,
        runsRemaining
    )
end

local function processPollution(evo, initialRunsRemaining)
    local name = world.pollutionDeltasIterator
    local count
    if not name then
        name,count = next(world.pollutionDeltas, nil)
    else
        count = world.pollutionDeltas[name]
    end
    if not name then
        return evo
    end
    world.pollutionDeltasIterator = next(world.pollutionDeltas, name)
    local runsRemaining = math.min(initialRunsRemaining, count)
    count = count - runsRemaining
    if count <= 0 then
        world.pollutionDeltas[name] = nil
    else
        world.pollutionDeltas[name] = count
    end

    local evolutionModifier = 0
    local statField

    if (name == "tile-proxy") then
        evolutionModifier = world.evolutionPerTileAbsorbed
        statField = "tile"
    elseif (name == "tree-proxy") then
        evolutionModifier = world.evolutionPerTreeAbsorbed
        statField = "tree"
    elseif (name == "tree-dying-proxy") then
        evolutionModifier = world.evolutionPerTreeDied
        statField = "dyingTree"
    elseif (name == "totalPollution") then
        evolutionModifier = world.evolutionPerPollution
        statField = "totalPollution"
    elseif world.spawnerLookup[name] then
        evolutionModifier = world.evolutionPerSpawnerAbsorbed
        statField = "absorbed"
    end

    return calculateEvolution(
        evo,
        evolutionModifier,
        world.stats,
        statField,
        runsRemaining
    )
end

local function printEvolutionMsg()
    local enemy = game.forces.enemy
    local stats = world.stats
    local enemyEvo = enemy.evolution_factor
    game.print({
            "description.rampant-evolution--displayEvolutionMsg",
            roundTo(enemyEvo*100,0.001),
            roundTo(calculateDisplayValue(stats["tile"], world, enemyEvo)*100, 0.001),
            roundTo(calculateDisplayValue(stats["tree"], world, enemyEvo)*100, 0.001),
            roundTo(calculateDisplayValue(stats["dyingTree"], world, enemyEvo)*100, 0.001),
            roundTo(calculateDisplayValue(stats["absorbed"], world, enemyEvo)*100, 0.001),
            roundTo(calculateDisplayValue(stats["spawner"], world, enemyEvo)*100, 0.001),
            roundTo(calculateDisplayValue(stats["hive"], world, enemyEvo)*100, 0.001),
            roundTo(calculateDisplayValue(stats["unit"], world, enemyEvo)*100, 0.001),
            roundTo(calculateDisplayValue(stats["worm"], world, enemyEvo)*100, 0.001),
            roundTo(calculateDisplayValue(stats["totalPollution"], world, enemyEvo)*100, 0.001),
            roundTo(calculateDisplayValue(stats["time"], world, enemyEvo)*100, 0.001),
            roundTo(calculateDisplayValue(stats["lowPlayer"], world, enemyEvo)*100, 0.001),
            roundTo(calculateDisplayValue(stats["mediumPlayer"], world, enemyEvo)*100, 0.001),
            roundTo(calculateDisplayValue(stats["highPlayer"], world, enemyEvo)*100, 0.001),
            roundTo(stats["evolutionMultiplier"]*100, 0.001),
            roundTo(stats["minimumEvolution"]*100, 0.001),
            roundTo(stats["researchEvolutionCap"]*100, 0.001),
            roundTo(world.lastChangeShort*100, 0.001),
            roundTo(world.lastChangeLong*100, 0.001),
            roundTo(world.lastChangeLongLong*100, 0.001)
    })
end

local function processing(resolutionLevel, evo)
    return processKill(
        processPollution(
            evo,
            resolutionLevel
        ),
        resolutionLevel
    )
end

local function onProcessingWrapper(event)
    local enemy = game.forces.enemy
    local tick = event.tick
    local resolutionLevel = world.evolutionResolutionLevel
    if resolutionLevel == 0 then
        local x = tick / 43200000 -- (60 * 60 * 60 * 200)
        resolutionLevel = linearInterpolation(
            mMin(x, 1),
            20,
            4000
        )
    end

    local evo = enemy.evolution_factor
    for _ = 1, world.processingPerTick do
        evo = processing(resolutionLevel, evo)
    end
    enemy.evolution_factor = evo

    if (tick % 60) == 0 then
        world.killDeltas["time"] = (world.killDeltas["time"] or 0) + 1
    end

    if (tick - world.lastChangeShortTick) >= SHORT_EVOLUTION_CHECK_DURATION then
        world.lastChangeShortTick = tick
        world.lastChangeShort = evo - world.lastChangeShortEvolution
        world.lastChangeShortEvolution = evo
    end

    if (tick - world.lastChangeLongTick) >= LONG_EVOLUTION_CHECK_DURATION then
        world.lastChangeLongTick = tick
        world.lastChangeLong = evo - world.lastChangeLongEvolution
        world.lastChangeLongEvolution = evo
    end

    if (tick - world.lastChangeLongLongTick) >= LONG_LONG_EVOLUTION_CHECK_DURATION then
        world.lastChangeLongLongTick = tick
        world.lastChangeLongLong = evo - world.lastChangeLongLongEvolution
        world.lastChangeLongLongEvolution = evo
    end

    if world.displayEvolutionMsg and ((tick % world.displayEvolutionMsgInterval) == 0) then
        printEvolutionMsg()
    end

    local playerId = world.playerIterator
    if not playerId then
        world.playerIterator = next(game.connected_players, world.playerIterator)
    else
        world.playerIterator = next(game.connected_players, playerId)
        gui.update(world, playerId, tick)
    end
end

local function onInit()
    global.world = {}

    world = global.world

    onConfigChanged()
end

local function onLoad()
    world = global.world
end

local function onLuaShortcut(event)
    if event.prototype_name == "rampant-evolution--info" then
        local playerIndex = event.player_index
        local guiPanel = world.playerGuiOpen[playerIndex]
        if not guiPanel then
            world.playerGuiOpen[playerIndex] = gui.create(game.players[playerIndex], world)
        else
            gui.close(world, event.player_index)
        end
    end
end

local function onPlayerRemoved(event)
    world.playerIterator = nil
end

local function onResearchCompleted(event)
    if not world.researchLookup then
        return
    end
    local research = event.research
    local technologyName = research.name
    local evolutionIncrease = world.researchLookup[technologyName]
    if world.toggleResearchEvolutionMultiplier
        and evolutionIncrease
        and research.force.name == "player"
    then
        world.researchCompleted = world.researchCompleted + 1
        world.researchEvolutionMultiplier = variableInterpolation(
            (world.researchCompleted / world.totalResearch),
            world.startResearchEvolutionMultiplier,
            world.endResearchEvolutionMultiplier,
            world.researchMultiplierExponent
        )

        world.stats.evolutionMultiplier = world.researchEvolutionMultiplier + world.tickEvolutionMultiplier

        if world.enabledResearchEvolutionCap then
            world.researchCurrent[evolutionIncrease[2]] = world.researchCurrent[evolutionIncrease[2]] + evolutionIncrease[1]
            world.stats["researchEvolutionCap"] = world.stats["researchEvolutionCap"] + evolutionIncrease[1]
        end
    end
end

local function onResearchUncompleted(event)
    if not world.researchLookup then
        return
    end
    local research = event.research
    local technologyName = research.name
    local evolutionIncrease = world.researchLookup[technologyName]
    if world.toggleResearchEvolutionMultiplier
        and evolutionIncrease
        and research.force.name == "player"
    then
        world.researchCompleted = world.researchCompleted - 1
        world.researchEvolutionMultiplier = variableInterpolation(
            (world.researchCompleted / world.totalResearch),
            world.startResearchEvolutionMultiplier,
            world.endResearchEvolutionMultiplier,
            world.researchMultiplierExponent
        )

        world.stats.evolutionMultiplier = world.researchEvolutionMultiplier + world.tickEvolutionMultiplier

        if world.enabledResearchEvolutionCap then
            world.researchCurrent[evolutionIncrease[2]] = world.researchCurrent[evolutionIncrease[2]] + evolutionIncrease[1]
            world.stats["researchEvolutionCap"] = world.stats["researchEvolutionCap"] - evolutionIncrease[1]
        end
    end
end

-- hooks

script.on_event(
    {
        defines.events.on_player_left_game,
        defines.events.on_player_kicked,
        defines.events.on_player_removed,
        defines.events.on_player_banned
    },
    onPlayerRemoved)
script.on_event(defines.events.on_lua_shortcut, onLuaShortcut)
script.on_nth_tick((2*60*60)+0, onStatsGrabPollution)
script.on_nth_tick((2*60*60)+1, onStatsGrabKill)
script.on_nth_tick((2*60*60)+2, onStatsGrabTotalPollution)
script.on_event(defines.events.on_tick, onProcessingWrapper)
script.on_event(defines.events.on_research_finished, onResearchCompleted)
script.on_event(defines.events.on_research_reversed, onResearchUncompleted)

script.on_init(onInit)
script.on_load(onLoad)
script.on_event(defines.events.on_runtime_mod_setting_changed, onModSettingsChange)
script.on_configuration_changed(onConfigChanged)

-- commands

local function rampantEvolution(event)
    printEvolutionMsg()
end

commands.add_command('rampantEvolution', "", rampantEvolution)
