--[[
This file is part of the mod InserterFuelLeech that is licensed under the
GNU GPL-3.0. See the file COPYING for a copy of the GNU GPLv3.0.
]]

local min = math.min
local max = math.max

local InserterRepoStateVersion = 250102

--- @class InserterRepoTickState
--- @field lastInserterIndex uint
--- @field inserters uint64[] list of inserter unit numbers

--- @class InserterRepoState
--- @field version uint32
--- @field registeredInserters table<uint64,LuaEntity?>
--- @field insertersByTickLength uint Length of the inserter update scheduling ring buffer in game ticks
--- @field insertersByTick InserterRepoTickState[] Index is tick % insertersByTickLength + 1
--- @field watchedInserterPlayers table<uint64,integer?>
--- @field watchedPlayerInserters table<integer,uint64?>

--- @param version uint32
--- @param insertersByTickLength uint32
--- @return InserterRepoState
local function makeInserterRegistryState(version, insertersByTickLength)
    return {
        version = version,
        registeredInserters = {},
        insertersByTickLength = insertersByTickLength,
        insertersByTick = {},
        watchedInserterPlayers = {},
        watchedPlayerInserters = {},
    }
end

--- @type InserterRepoState
local state = makeInserterRegistryState(0, 10)

local function initInserterRepoIfNeeded(tick)
    if not state or state.version ~= InserterRepoStateVersion or state.insertersByTickLength ~= settingsCache.maxTicksToWait then
        initInserterRepo(tick, nil)
    end
end

--- @param tick uint
--- @param logger Logger?
--- @return nil
function initInserterRepo(tick, logger)
    logger = logger or getLogger(settingsCache.logLowTrafficPlayers, false)
    logger("Initializing inserter repository state...", nil)

    state = makeInserterRegistryState(InserterRepoStateVersion, settingsCache.maxTicksToWait)
    storage.inserterRepoState = state

    for _, surface in pairs(game.surfaces) do
        local surfaceInserters = surface.find_entities_filtered{type = "inserter"}
        for i = 1, #surfaceInserters do
            local inserter = surfaceInserters[i]
            registerInserter(tick, inserter, nil)
        end
    end

    logger("Initialized inserter repository state.", nil)
    logger("", getInserterStats(tick))
end

--- @return nil
function inserterRepoOnLoad()
    if storage.inserterRepoState then
        state = storage.inserterRepoState -- Migrations are done on first use.
    end
end

--- @class InserterRepoStats
--- @field knownInserters uint
--- @field knownInsertersByType table<string,uint>
--- @field knownInsertersNeedingFuelThemselves uint
--- @field knownInsertersNeedingFuelThemselvesByType table<string,uint>
--- @field knownInsertersWithTargetNeedingFuel uint
--- @field knownInsertersWithTargetNeedingFuelByType table<string,uint>

--- @param tick uint
--- @return InserterRepoStats
function getInserterStats(tick)
    initInserterRepoIfNeeded(tick)
    local knownInsertersCount = 0
    --- @type table<string,uint>
    local knownInsertersByType = {}
    local knownInsertersNeedingFuelThemselvesCount = 0
    --- @type table<string,uint>
    local knownInsertersNeedingFuelThemselvesByType = {}
    local knownInsertersWithTargetNeedingFuelCount = 0
    --- @type table<string,uint>
    local knownInsertersWithTargetNeedingFuelByType = {}
    for _, inserter in pairs(state.registeredInserters) do
        if inserter and inserter.valid then

            knownInsertersCount = knownInsertersCount + 1
            knownInsertersByType[inserter.name] = (knownInsertersByType[inserter.name] or 0) + 1

            if inserter.burner then
                knownInsertersNeedingFuelThemselvesCount = knownInsertersNeedingFuelThemselvesCount + 1
                knownInsertersNeedingFuelThemselvesByType[inserter.name] = (knownInsertersNeedingFuelThemselvesByType[inserter.name] or 0) + 1
            end

            if inserter.drop_target and inserter.drop_target.burner then
                knownInsertersWithTargetNeedingFuelCount = knownInsertersWithTargetNeedingFuelCount + 1
                knownInsertersWithTargetNeedingFuelByType[inserter.name] = (knownInsertersWithTargetNeedingFuelByType[inserter.name] or 0) + 1
            end

        end
    end
    return {
        knownInserters = knownInsertersCount,
        knownInsertersByType = knownInsertersByType,
        knownInsertersNeedingFuelThemselves = knownInsertersNeedingFuelThemselvesCount,
        knownInsertersNeedingFuelThemselvesByType = knownInsertersNeedingFuelThemselvesByType,
        knownInsertersWithTargetNeedingFuel = knownInsertersWithTargetNeedingFuelCount,
        knownInsertersWithTargetNeedingFuelByType = knownInsertersWithTargetNeedingFuelByType,
    }
end

--- @param slotIndex uint
--- @return InserterRepoTickState
local function getInsertersByTickSlot(slotIndex)
    local slot = state.insertersByTick[slotIndex]
    if not slot then
        slot = {lastInserterIndex = 0, inserters = {}}
        state.insertersByTick[slotIndex] = slot
    end
    return slot
end

--- @param tick uint
--- @return uint
local function getInsertersByTickSlotIndex(tick)
    local insertersByTickLength = state.insertersByTickLength
    return tick % insertersByTickLength + 1
end

--- @alias LastInserterLogger fun(msg: string, data: any): nil

--- @type PlayerSettingsCache[]
local inserterDebugPlayers = {}

--- @param inserterId uint64
--- @return LastInserterLogger?
local function getInserterDebugLogger(inserterId)
    local playerIndex = state.watchedInserterPlayers[inserterId]
    if not playerIndex then
        return nil
    end
    local playerSettingsCache = settingsCache.watchLastInserterPlayers[playerIndex]
    if not playerSettingsCache then
        return nil
    end
    inserterDebugPlayers[1] = playerSettingsCache
    return function(msg, data) logMsg(inserterDebugPlayers, false, msg, data) end
end

--- @param inserterId uint64
--- @param reason string
--- @return nil
local function forgetInserter(inserterId, reason)
    if not state.registeredInserters[inserterId] then
        return
    end
    local debugLogger = getInserterDebugLogger(inserterId)
    _ = debugLogger and debugLogger("Forgetting watched inserter because " .. reason .. ".", nil)
    state.registeredInserters[inserterId] = nil
    local oldLastInserterPlayer = state.watchedInserterPlayers[inserterId]
    if oldLastInserterPlayer then
        state.watchedInserterPlayers[inserterId] = nil
        state.watchedPlayerInserters[oldLastInserterPlayer] = nil
    end
end

--- @param tick uint
--- @param inserterId uint64
--- @param ticksToWait uint
--- @param debugLogger LastInserterLogger?
--- @return nil
local function scheduleNextInserterUpdate(tick, inserterId, ticksToWait, debugLogger)
    ticksToWait = max(1, min(state.insertersByTickLength, ticksToWait))
    local nextUpdateTick = tick + ticksToWait
    local nextUpdateSlotIndex = getInsertersByTickSlotIndex(nextUpdateTick)
    local nextUpdateSlot = getInsertersByTickSlot(nextUpdateSlotIndex)
    local nextUpdateSlotLastIndex = nextUpdateSlot.lastInserterIndex + 1
    nextUpdateSlot.lastInserterIndex = nextUpdateSlotLastIndex
    nextUpdateSlot.inserters[nextUpdateSlotLastIndex] = inserterId
    _ = debugLogger and debugLogger("Next watched inserter update in " .. formatTickForLog(ticksToWait) .. ".", nil)
end

--- @param tick uint
--- @return nil
function updateInserters(tick)
    initInserterRepoIfNeeded(tick)
    local slotIndex = getInsertersByTickSlotIndex(tick)
    local slot = getInsertersByTickSlot(slotIndex)
    local slotInserters = slot.inserters
    local slotInsertersLength = slot.lastInserterIndex
    slot.lastInserterIndex = 0

    local enabledInserterTypes = settingsCache.inserterTypes
    for inserterIndex = 1, slotInsertersLength do
        local inserterId = slotInserters[inserterIndex]
        local inserter = state.registeredInserters[inserterId]

        if not inserter or not inserter.valid then
            forgetInserter(inserterId, "it became invalid")
        elseif not enabledInserterTypes[inserter.name] then
            forgetInserter(inserterId, "mod functionality has been disabled for its type.")
        else
            local debugLogger = getInserterDebugLogger(inserterId)
            local ticksToWait = updateInserter(inserter, debugLogger)
            scheduleNextInserterUpdate(tick, inserterId, ticksToWait, debugLogger)
        end
    end
end

--- @param tick uint
--- @param inserter LuaEntity?
--- @param builderPlayerIndex uint32?
--- @return boolean
function registerInserter(tick, inserter, builderPlayerIndex)
    initInserterRepoIfNeeded(tick)
    if not inserter or not inserter.valid or inserter.type ~= "inserter" or not settingsCache.inserterTypes[inserter.name] then
        return false
    end
    local inserterId = inserter.unit_number
    if not inserterId or state.registeredInserters[inserterId] then
        return false
    end

    if builderPlayerIndex and settingsCache.watchLastInserterPlayers[builderPlayerIndex] then
        local oldLastInserter = state.watchedPlayerInserters[builderPlayerIndex]
        if oldLastInserter then
            state.watchedInserterPlayers[oldLastInserter] = nil
            state.watchedPlayerInserters[builderPlayerIndex] = nil
        end
        state.watchedInserterPlayers[inserterId] = builderPlayerIndex
        state.watchedPlayerInserters[builderPlayerIndex] = inserterId
    end

    local debugLogger = getInserterDebugLogger(inserterId)
    _ = debugLogger and debugLogger("Watching newly built " .. inserter.name .. ".", nil)
    state.registeredInserters[inserterId] = inserter
    scheduleNextInserterUpdate(tick, inserterId, 1, debugLogger)
    return true
end
