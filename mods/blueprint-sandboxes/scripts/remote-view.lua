-- Code for Factorio's new Remote controller
local RemoteView = {}

RemoteView.chartAllSandboxesTick = 120

-- When initialized, setup default hidden states
function RemoteView.Init()
    RemoteView.SyncSurfaceVisibility()
end

---@param surface LuaSurface
---@param force LuaForce
local function Show(surface, force)
    force.set_surface_hidden(surface, false)
end

---@param surface LuaSurface
---@param force LuaForce
local function Hide(surface, force)
    force.set_surface_hidden(surface, true)
end

-- When requested, fully synchronize the toggled states
function RemoteView.SyncSurfaceVisibility()
    for _, force in pairs(game.forces) do
        if Sandbox.IsSandboxForce(force) then
            RemoteView.HideEverythingFromSandboxForce(force)
        else
            RemoteView.DetermineVisibilityOfAllSandboxes(force)
        end
    end
end

-- When not fully isolated, each force can see all of their own sandboxes
---@param surface LuaSurface
---@param force LuaForce
---@return boolean
local function DetermineVisibilityOfSandbox(surface, force)
    local shouldShow = not force.get_surface_hidden(surface)
    if Sandbox.IsSandbox(surface) then
        shouldShow = false
        if Isolation.IsNone() then
            local surfaceData = storage.labSurfaces[surface.name]
            if surfaceData then
                local sandboxForceData = storage.sandboxForces[surfaceData.sandboxForceName]
                if sandboxForceData and sandboxForceData.forceName == force.name then
                    shouldShow = true
                end
            end
        end
    end
    if shouldShow then Show(surface, force)
    else Hide(surface, force) end
    return shouldShow
end

-- When a Sandbox is created, hide it from everyone
---@param surface LuaSurface
function RemoteView.DetermineVisibilityForEveryone(surface)
    log("Showing/Hiding a new Sandbox for all Forces: " .. surface.name)
    for _, force in pairs(game.forces) do
        DetermineVisibilityOfSandbox(surface, force)
    end
end

-- When a Force is created, hide all Sandboxes from them
---@param force LuaForce
function RemoteView.DetermineVisibilityOfAllSandboxes(force)
    log("Showing/Hiding all Sandboxes from new Force: " .. force.name)
    for _, surface in pairs(game.surfaces) do
        DetermineVisibilityOfSandbox(surface, force)
    end
end

-- When a Surface is created, hide it from all Sandboxes
---@param surface LuaSurface
function RemoteView.HideSurfaceFromAllSandboxes(surface)
    log("Hiding a new Surface from all Sandbox Forces: " .. surface.name)
    for _, force in pairs(game.forces) do
        if Sandbox.IsSandboxForce(force) then
            Hide(surface, force)
        end
    end
end

-- When a Sandbox Force is created, hide all Surfaces from them
---@param sandboxForce LuaForce
function RemoteView.HideEverythingFromSandboxForce(sandboxForce)
    log("Hiding everything from Sandbox Force: " .. sandboxForce.name)
    for _, surface in pairs(game.surfaces) do
        Hide(surface, sandboxForce)
    end
end

---@param player LuaPlayer
---@return number The number of chunks to generate in each direction
local function CalculateChunkRadiusFromZoom(player)
    local resolution = player.display_resolution
    local visibleTilesWidth = resolution.width / player.zoom / 32
    local visibleTilesHeight = resolution.height / player.zoom / 32
    local chunksWidth = math.ceil(visibleTilesWidth / 32)
    local chunksHeight = math.ceil(visibleTilesHeight / 32)
    return math.min(8, math.max(chunksWidth, chunksHeight) / 2)
end

-- Charts and generates chunks for all players in sandboxes
function RemoteView.ChartAndGenerateOccupiedSandboxes()
    local charted = {}
    for _, player in pairs(game.players) do
        local hash = player.force.name .. player.surface.name
        if Sandbox.IsSandbox(player.surface) and not charted[hash] then
            local chunkRadius = CalculateChunkRadiusFromZoom(player)
            player.surface.request_to_generate_chunks(player.position, chunkRadius)
            player.force.chart_all(player.surface)
            charted[hash] = true
        end
    end
end

return RemoteView
