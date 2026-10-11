-- First-time Setup for new Games and new Players
local Init = {}

-- Setup Player, if necessary
---@param player LuaPlayer
function Init.Player(player)
    if storage.players[player.index] then
        return
    end

    local playerLabName = Lab.NameFromPlayer(player)
    local sandboxForceName = Sandbox.NameFromForce(player.force --[[@as LuaForce]])
    storage.players[player.index] = {
        forceName = player.force.name,
        labName = playerLabName,
        sandboxForceName = sandboxForceName,
        selectedSandbox = Sandbox.player,
        sandboxInventory = nil,
        insideSandbox = nil,
        lastSandboxPositions = {},
    }
    ToggleGUI.Init(player)
end

-- Reset all Mod data
function Init.FirstTimeInit()
    storage.version = Migrate.version
    storage.forces = {}
    storage.players = {}
    storage.labSurfaces = {}
    storage.sandboxForces = {}
    storage.asyncCreateQueue = Queue.New()
    storage.asyncUpgradeQueue = Queue.New()
    storage.asyncDestroyQueue = Queue.New()
    storage.lastSettingForAsyncGodTick = settings.global[Settings.godAsyncTick].value

    -- Warning: do not rely on this alone; new Saves have no Players/Forces yet
    for _, force in pairs(game.forces) do
        Force.Init(force)
    end
    for _, player in pairs(game.players) do
        Init.Player(player)
    end

    -- Check existing surfaces for any Labs and initialize their data again
    for _, surface in pairs(game.surfaces) do
        if Lab.IsLab(surface) then
            local surfaceData = storage.labSurfaces[surface.name]
            if not surfaceData then
                surface.localised_name = Lab.LocalisedNameFromLabName(surface.name)

                local forceName = nil
                local sandboxForceName = nil

                -- Check if this is a player lab
                for _, playerData in pairs(storage.players) do
                    if playerData.labName == surface.name then
                        forceName = playerData.forceName
                        sandboxForceName = playerData.sandboxForceName
                        break
                    end
                end

                -- If not a player lab, check if it's a force lab
                if not forceName then
                    for _, sandboxForceData in pairs(storage.sandboxForces) do
                        if sandboxForceData.labName == surface.name then
                            forceName = sandboxForceData.forceName
                            sandboxForceName = Sandbox.NameFromForce(game.forces[forceName])
                            break
                        end
                    end
                end

                if forceName and sandboxForceName then
                    log("Reinitializing existing Lab data for surface: " .. surface.name)
                    storage.labSurfaces[surface.name] = {
                        forceName = forceName,
                        sandboxForceName = sandboxForceName,
                        equipmentBlueprints = Equipment.Init(Lab.equipmentString),
                    }
                end
            end
        end
    end

    -- Check existing surfaces for any Sandbox Forces and initialize their data again
    for _, force in pairs(game.forces) do
        if Sandbox.IsSandboxForce(force) then
            local sandboxForceData = storage.sandboxForces[force.name]
            if not sandboxForceData then
                local mainForceName = nil
                for _, mainForceData in pairs(storage.forces) do
                    if mainForceData.sandboxForceName == force.name then
                        mainForceName = mainForceData.forceName
                        break
                    end
                end

                if mainForceName then
                    log("Reinitializing existing Sandbox Force data for force: " .. force.name)
                    local mainForce = game.forces[mainForceName]
                    local forceLabName = Lab.NameFromForce(mainForce)
                    storage.sandboxForces[force.name] = {
                        forceName = mainForceName,
                        hiddenItemsUnlocked = false,
                        labName = forceLabName,
                    }
                    Force.ConfigureSandboxForce(mainForce, force)
                end
            end
        end
    end
end

return Init
