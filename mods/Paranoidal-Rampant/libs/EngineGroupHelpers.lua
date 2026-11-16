-- Helpers of engine-made enemy groups (RampantFixed 2.01.01 work-around, reworked by Reforged Paranoidal).
--
-- Factorio 2.0 does not let an engine group made only of modded units build a base, so RampantFixed adds one
-- vanilla small-biter to every group the engine creates and removes it when the group finishes gathering.
-- The old code put the helper at the gathering point wherever it was (also inside the player base), removed
-- the first member instead of the helper and never removed it if the group was destroyed or vanished before
-- that. Here:
--  * no helper where it would stand in the player base: a chunk with player buildings, or player turrets in the
--    3x3 chunks around (expansion groups do not gather there; attack groups do not need a helper);
--  * no helper during the truce: Rampant destroys engine groups when they finish gathering;
--  * the helper itself is remembered and removed when the group finishes gathering, is destroyed by Rampant,
--    vanishes, loses the helper, or gathers longer than the engine allows.
-- Data: universe.engineGroupHelpers[group.unique_id] = {group, helper (nil if none), tick}; created on first use.

if engineGroupHelpersG then
    return engineGroupHelpersG
end
local engineGroupHelpers = {}

local constants = require("Constants")
local mapUtils = require("MapUtils")
local chunkPropertyUtils = require("ChunkPropertyUtils")
local squadCompression = require("SquadCompression")

local CHUNK_SIZE = constants.CHUNK_SIZE
local AI_STATE_PEACEFUL = constants.AI_STATE_PEACEFUL

local getChunkByPosition = mapUtils.getChunkByPosition
local getPlayerBaseGenerator = chunkPropertyUtils.getPlayerBaseGenerator
local getPlayerTurretCount = chunkPropertyUtils.getPlayerTurretCount
local takeUnitFromPack = squadCompression.takeUnitFromPack

engineGroupHelpers.HELPER_NAME = "small-biter"
local HELPER_NAME = engineGroupHelpers.HELPER_NAME
local TIMEOUT_MARGIN = 1800     -- ticks after the longest gathering the engine allows

local function getRecords(universe)
    local records = universe.engineGroupHelpers
    if not records then
        records = {}
        universe.engineGroupHelpers = records
    end
    return records
end

-- the helper would stand in the player base: player buildings in the chunk or player turrets in the 3x3 around
function engineGroupHelpers.inPlayerBase(map, position)
    local chunk = getChunkByPosition(map, position)
    if chunk == -1 then
        return false
    end
    if getPlayerBaseGenerator(map, chunk) > 0 then
        return true
    end
    local x = chunk.x
    local y = chunk.y
    for dx = -CHUNK_SIZE, CHUNK_SIZE, CHUNK_SIZE do
        local column = map[x + dx]
        if column then
            for dy = -CHUNK_SIZE, CHUNK_SIZE, CHUNK_SIZE do
                local c = column[y + dy]
                if c and (getPlayerTurretCount(map, c) > 0) then
                    return true
                end
            end
        end
    end
    return false
end

-- removes one helper unit; a helper that became the carrier of a compressed pack only gives up one unit
local function removeHelperUnit(universe, helper)
    if helper and helper.valid then
        if not takeUnitFromPack(universe, helper) then
            helper.destroy()
        end
    end
end

-- on_unit_group_created for a group made by the engine (not script driven) on a Rampant surface
-- allowNonRampantActions: rampantFixed--allowDaytimeNonRampantActions (engine groups survive the truce)
function engineGroupHelpers.onGroupCreated(universe, map, group, tick, allowNonRampantActions)
    if not map.hasNonmoddedBiters then
        return
    end
    local records = getRecords(universe)
    local record = {group = group, tick = tick}
    records[group.unique_id] = record
    if (map.state == AI_STATE_PEACEFUL) and (not allowNonRampantActions) then
        return      -- destroyed when it finishes gathering anyway
    end
    local position = group.position
    if engineGroupHelpers.inPlayerBase(map, position) then
        return
    end
    local helper = group.surface.create_entity({
        name = HELPER_NAME,
        position = position,
        force = group.force,
    })
    if helper and helper.valid then
        group.add_member(helper)
        record.helper = helper
    end
end

-- The group finished gathering or is about to be destroyed: its helper is not needed any more.
-- Groups made before this version have no record; as before, their first member goes, but only if it is a helper.
function engineGroupHelpers.release(universe, map, group)
    local records = universe.engineGroupHelpers
    local id = group.unique_id
    local record = records and records[id]
    if record then
        records[id] = nil
        removeHelperUnit(universe, record.helper)
        return
    end
    if map.hasNonmoddedBiters and (not universe.engineGroupHelpersSince or (id < universe.engineGroupHelpersSince)) then
        local first = group.members[1]
        if first and first.valid and (first.name == HELPER_NAME) then
            removeHelperUnit(universe, first)
        end
    end
end

-- id of the first group seen by this version: older groups are handled by the fallback in release
function engineGroupHelpers.noteGroupId(universe, id)
    if not universe.engineGroupHelpersSince then
        universe.engineGroupHelpersSince = id
    end
end

-- every few seconds: helpers of vanished groups, helpers that left their group, gatherings past the engine limit
function engineGroupHelpers.sweep(universe, tick)
    local records = universe.engineGroupHelpers
    if not records or (next(records) == nil) then
        return
    end
    local unitGroupSettings = game.map_settings.unit_group
    local timeout = unitGroupSettings.max_group_gathering_time + unitGroupSettings.max_wait_time_for_late_members
        + TIMEOUT_MARGIN
    for id, record in pairs(records) do
        local group = record.group
        local helper = record.helper
        if not group.valid then
            records[id] = nil
            removeHelperUnit(universe, helper)
        elseif (tick - record.tick) > timeout then
            records[id] = nil
            removeHelperUnit(universe, helper)
        elseif helper then
            if not helper.valid then
                record.helper = nil         -- killed: nothing to remove later
            else
                local commandable = helper.commandable
                if (not commandable) or (commandable.parent_group ~= group) then
                    record.helper = nil
                    removeHelperUnit(universe, helper)
                end
            end
        end
    end
end

engineGroupHelpersG = engineGroupHelpers
return engineGroupHelpers
