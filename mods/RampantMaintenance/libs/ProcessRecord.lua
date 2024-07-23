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


if processRecordG then
    return processRecordG
end

-- imports

local constants = require("Constants")

-- constants

local DEFINES_ENTITY_STATUS_LOW_POWER = defines.entity_status.low_power
local DEFINES_ENTITY_STATUS_WORKING = defines.entity_status.working
local DEFINES_ENTITY_STATUS_LOW_INPUT_FLUID = defines.entity_status.low_input_fluid
local DEFINES_ENTITY_STATUS_NO_AMMO = defines.entity_status.no_ammo

local ENTITES_WITHOUT_DOWNTIME = constants.ENTITES_WITHOUT_DOWNTIME

-- imported functions

local getResearch = constants.getResearch
local mRandom = math.random
local calculateLowFailure = constants.calculateLowFailure
local calculateHighFailure = constants.calculateHighFailure
local calculateLowCooldown = constants.calculateLowCooldown
local calculateHighCooldown = constants.calculateHighCooldown
local calculateLowDowntime = constants.calculateLowDowntime
local calculateHighDowntime = constants.calculateHighDowntime
local calculateLowDamage = constants.calculateLowDamage
local calculateHighDamage = constants.calculateHighDamage

-- modules

local processRecord = {}

local function calculateFailureChance(world, entityRecord, invertedHealthPercent)
    local lowFailure = calculateLowFailure(world, entityRecord, invertedHealthPercent)
    local highFailure = calculateHighFailure(world, entityRecord, invertedHealthPercent)
    local rangeFailure = highFailure - lowFailure
    return (mRandom() * rangeFailure) + lowFailure
end

local function calculateCooldown(world, entityRecord, healthPercent)
    local lowCooldown = calculateLowCooldown(world, entityRecord, healthPercent)
    local highCooldown = calculateHighCooldown(world, entityRecord, healthPercent)
    local rangeCooldown = highCooldown - lowCooldown
    return (mRandom() * rangeCooldown) + lowCooldown
end

local function calculateDowntime(world, entityRecord, invertedHealthPercent)
    local lowDowntime = calculateLowDowntime(world, entityRecord, invertedHealthPercent)
    local highDowntime = calculateHighDowntime(world, entityRecord, invertedHealthPercent)
    local rangeDowntime = highDowntime - lowDowntime
    return (mRandom() * rangeDowntime) + lowDowntime
end

local function calculateDamage(world, entityRecord, invertedHealthPercent)
    local lowDamage = calculateLowDamage(world, entityRecord, invertedHealthPercent)
    local highDamage = calculateHighDamage(world, entityRecord, invertedHealthPercent)
    local rangeDamage = highDamage - lowDamage
    return (mRandom() * rangeDamage) + lowDamage
end

local function disable(disableQuery, tick, entityRecord, world)
    local entity = entityRecord.e
    local healthPercent = entity.get_health_ratio()
    local invertedHealthPercent = 1 - healthPercent
    local entityType = entity.type

    local chanceOfFailure = calculateFailureChance(world, entityRecord, invertedHealthPercent)
    local useCooldown = false
    local cooldown

    if (mRandom() < chanceOfFailure) then
        local downtimes = world.buildDowntime[entityType]
        if downtimes and entity.active and entityRecord.a then
            cooldown = calculateDowntime(world, entityRecord, invertedHealthPercent)
            entity.active = false
            entityRecord.a = false
            if world.showBreakdownSprite then
                disableQuery.target = entity
                disableQuery.surface = entity.surface
                disableQuery.time_to_live = cooldown
                rendering.draw_sprite(disableQuery)
            end
        else
            useCooldown = true
        end
        local energy = entity.energy
        if (energy and (energy > 0)) then
            entity.energy = entity.energy * getResearch(entity.force.name, world, "energy")
        end
        entity.damage(
            calculateDamage(world, entityRecord, invertedHealthPercent) * entity.prototype.max_health,
            entity.force
        )
        if not entity.valid then
            return 0
        end
        entityRecord.fC = entityRecord.fC + 1
    else
        useCooldown = true
    end

    if useCooldown then
        cooldown = calculateCooldown(world, entityRecord, healthPercent)
    end
    return cooldown
end

function processRecord.process(predicate, entityRecord, tick, world)
    local entity = entityRecord.e
    local canActivate = (not ENTITES_WITHOUT_DOWNTIME[entity.type]) and not entity.active and not entityRecord.a

    if (tick > entityRecord.c)
        or (world.entityRobotRepaired and canActivate and (entity.get_health_ratio() == 1))
    then
        if canActivate then
            entity.active = true
            entityRecord.a = true
            entityRecord.d = entityRecord.d + (tick - entityRecord.lE)
        else
            entityRecord.u = entityRecord.u + (tick - entityRecord.lE)
        end

        local cooldown
        if predicate(entity) then
            cooldown = disable(world.queries.disableQuery,
                               tick,
                               entityRecord,
                               world)
        else
            cooldown = calculateCooldown(world,
                                         entityRecord,
                                         entity.get_health_ratio())
        end

        entityRecord.c = tick + cooldown
        entityRecord.lE = tick
    end
end

function processRecord.recordSelection(entityRecord, tick)
    local entity = entityRecord.e
    local entityType = entityRecord.e.type
    if (not ENTITES_WITHOUT_DOWNTIME[entityType]) and (not entity.active) then
        entityRecord.d = entityRecord.d + (tick - entityRecord.lE)
    else
        entityRecord.u = entityRecord.u + (tick - entityRecord.lE)
    end
    entityRecord.lE = tick
end

function processRecord.activateEntity(entityRecord, tick)
    local entity = entityRecord.e
    local entityType = entityRecord.e.type
    if (not ENTITES_WITHOUT_DOWNTIME[entityType]) and (not entity.active) then
        entity.active = true
        entityRecord.d = entityRecord.d + (tick - entityRecord.lE)
        entityRecord.lE = tick
    end
end

processRecord["inserter"] = function (entity)
    return entity.held_stack.valid_for_read
end

processRecord["lab"] = function (entity)
    local status = entity.status
    return status == DEFINES_ENTITY_STATUS_WORKING or
        status == DEFINES_ENTITY_STATUS_LOW_POWER
end

processRecord["lamp"] = function (entity)
    return (entity.energy > 0.01) and
        (entity.surface.darkness > 0.4)
end

processRecord["generator"] = function (entity)
    return entity.energy_generated_last_tick > 0.01
end

processRecord["mining-drill"] = function (entity)
    local status = entity.status
    return status == DEFINES_ENTITY_STATUS_LOW_POWER or
        status == DEFINES_ENTITY_STATUS_WORKING
end

processRecord["offshore-pump"] = function (entity)
    return entity.fluidbox.get_flow(1) > 0.01
end

processRecord["solar-panel"] = function (entity)
    return entity.surface.darkness < 0.5
end

processRecord["accumulator"] = function (entity)
    return entity.energy > 0.01
end

processRecord["boiler"] = function (entity)
    local status = entity.status
    return status == DEFINES_ENTITY_STATUS_WORKING or
        status == DEFINES_ENTITY_STATUS_LOW_POWER or
        status == DEFINES_ENTITY_STATUS_LOW_INPUT_FLUID
end

processRecord["beacon"] = function (entity)
    return entity.energy > 0.01
end

processRecord["assembling-machine"] = function (entity)
    local status = entity.status
    return status == DEFINES_ENTITY_STATUS_LOW_POWER or
        status == DEFINES_ENTITY_STATUS_WORKING
end

processRecord["furnace"] = function (entity)
    local status = entity.status
    return status == DEFINES_ENTITY_STATUS_LOW_POWER or
        status == DEFINES_ENTITY_STATUS_WORKING
end

processRecord["rocket-silo"] = function (entity)
    local status = entity.status
    return status == DEFINES_ENTITY_STATUS_LOW_POWER or
        status == DEFINES_ENTITY_STATUS_WORKING
end

processRecord["radar"] = function (entity)
    return entity.energy > 0.01
end

processRecord["roboport"] = function (entity)
    return entity.energy > 0.01
end

processRecord["fluid-turret"] = function (entity)
    return entity.shooting_target ~= nil
end

processRecord["ammo-turret"] = function (entity)
    return entity.shooting_target ~= nil
end

processRecord["electric-turret"] = function (entity)
    return entity.shooting_target ~= nil
end

processRecord["reactor"] = function (entity)
    return entity.temperature > 0.01
end

processRecord["pump"] = function (entity)
    return entity.fluidbox.get_flow(1) > 0.01
end

processRecord["artillery-turret"] = function (entity)
    return entity.status ~= DEFINES_ENTITY_STATUS_NO_AMMO
end

processRecord["electric-pole"] = function (entity)
    return true
end

processRecordG = processRecord
return processRecord
