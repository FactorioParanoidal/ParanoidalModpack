--[[
This file is part of the mod InserterFuelLeech that is licensed under the
GNU GPL-3.0. See the file COPYING for a copy of the GNU GPLv3.0.
]]

--[[
Inserter (re-)discovery to eventually rediscover inserters which didn't need
management before but do now or have been discarded or missed by the event handlers.
]]

local InserterDiscoveryStateVersion = 328

--- @class InserterDiscoveryState
--- @field version uint
--- @field cycleStartTick uint?
--- @field surfaces LuaSurface[]
--- @field surfaceIndex uint
--- @field cycleSurfacesCount uint
--- @field chunks LuaChunkIterator?
--- @field chunksSurface LuaSurface?
--- @field cycleChunksCount uint
--- @field inserters LuaEntity[]
--- @field inserterIndex uint
--- @field cycleInsertersCount uint
--- @field cycleNewInsertersCount uint

--- @param version uint32
--- @return InserterDiscoveryState
local function makeInserterDiscoveryState(version)
    return {
        version = version,
        cycleStartTick = nil,
        surfaces = {},
        surfaceIndex = 0,
        cycleSurfacesCount = 0,
        chunks = nil,
        chunksSurface = nil,
        cycleChunksCount = 0,
        inserters = {},
        inserterIndex = 0,
        cycleInsertersCount = 0,
        cycleNewInsertersCount = 0,
    }
end

--- @type InserterDiscoveryState
local state = makeInserterDiscoveryState(0)

--- @param tick uint
--- @param logger Logger?
--- @return nil
function initInserterDiscovery(tick, logger)
    logger = logger or getLogger(settingsCache.logLowTrafficPlayers, false)
    state = makeInserterDiscoveryState(InserterDiscoveryStateVersion)
    storage.inserterDiscoveryState = state
    logger("Initialized inserter discovery state.", nil)
end

--- @param tick uint
--- @return nil
local function initInserterDiscoveryIfNeeded(tick)
    if not state or state.version ~= InserterDiscoveryStateVersion then
        initInserterDiscovery(tick, nil)
    end
end

--- @return nil
function inserterDiscoveryOnLoad()
    if storage.inserterDiscoveryState then
        state = storage.inserterDiscoveryState
    end
end

--- @param tick uint
--- @return nil
function discoverUnknownInserters(tick)
    initInserterDiscoveryIfNeeded(tick)
    local discoverPerTick = settingsCache.discoverPerTick
    if discoverPerTick < 1 then
        return
    end
    local inserters = state.inserters
    local inserterIndex = state.inserterIndex
    local insertersCount = state.cycleInsertersCount
    local newInsertersCount = state.cycleNewInsertersCount

    -- Process inserters:
    if inserterIndex > 0 then
        for _ = 1, discoverPerTick do
            if inserterIndex > 0 then
                local inserter = inserters[inserterIndex]
                if inserter and inserter.valid then
                    insertersCount = insertersCount + 1
                    if registerInserter(tick, inserter, nil) then
                        newInsertersCount = newInsertersCount + 1
                    end
                end
            end
            inserterIndex = inserterIndex - 1
        end
        state.inserterIndex = inserterIndex
        state.cycleInsertersCount = insertersCount
        state.cycleNewInsertersCount = newInsertersCount
        return
    end

    -- Find next chunk with inserters:
    local chunks = state.chunks
    local chunksSurface = state.chunksSurface
    local chunksCount = state.cycleChunksCount
    if chunksSurface and chunksSurface.valid and chunks and chunks.valid then
        local maxEmptyToCheck = settingsCache.discoverEmptyChunksPerTick
        local emptyDiscovered = 0
        for chunk in chunks do
            if not chunk then
                break
            end
            chunksCount = chunksCount + 1
            if chunksSurface.is_chunk_generated(chunk) then
                inserters = chunksSurface.find_entities_filtered { area = chunk.area, type = "inserter" }
                inserterIndex = #inserters
                if inserterIndex == 0 then
                    emptyDiscovered = emptyDiscovered + 1
                    if emptyDiscovered >= maxEmptyToCheck then
                        state.cycleChunksCount = chunksCount
                        return
                    end
                else
                    state.inserters = inserters
                    state.inserterIndex = inserterIndex
                    state.cycleChunksCount = chunksCount
                    return
                end
            end
        end
        state.cycleChunksCount = chunksCount
    end

    -- Next surface:
    local surfaces = state.surfaces
    local surfaceIndex = state.surfaceIndex
    local surfacesCount = state.cycleSurfacesCount
    if surfaceIndex > 0 then
        local surface = surfaces[surfaceIndex]
        if surface and surface.valid then
            surfacesCount = surfacesCount + 1
            state.chunks = surface.get_chunks()
            state.chunksSurface = surface
        end
        state.surfaceIndex = surfaceIndex - 1
        state.cycleSurfacesCount = surfacesCount
        return
    end

    -- New cycle:
    if state.cycleStartTick ~= nil then
        local logPlayers = settingsCache.logDiscoveryCyclePlayers
        logMsg(logPlayers, false, table.concat({
            "Inserter discovery cycle complete. Found ",
            insertersCount,
            " inserters (",
            newInsertersCount,
            " new) on ",
            chunksCount,
            " chunks on ",
            surfacesCount,
            " surfaces in ",
            formatTickForLog(tick - state.cycleStartTick),
            ".",
        }), nil)
    end
    surfaces = {}
    surfaceIndex = 0
    for _, surface in pairs(game.surfaces) do
        surfaceIndex = surfaceIndex + 1
        surfaces[surfaceIndex] = surface
    end
    state.cycleStartTick = tick
    state.surfaces = surfaces
    state.surfaceIndex = surfaceIndex
    state.cycleSurfacesCount = 0
    state.chunks = nil
    state.chunksSurface = nil
    state.cycleChunksCount = 0
    state.inserters = {}
    state.inserterIndex = 0
    state.cycleInsertersCount = 0
    state.cycleNewInsertersCount = 0
end
