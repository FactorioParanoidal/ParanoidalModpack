-- Managing the isolation state
local Isolation = {}

Isolation.none = "none"
Isolation.full = "full"

Isolation.level = Isolation.none

---@return boolean
function Isolation.IsNone()
    return Isolation.level == Isolation.none
end

---@return boolean
function Isolation.IsFull()
    return Isolation.level == Isolation.full
end

-- Ensure the value from the settings is globally available
function Isolation.StoreCurrentLevel()
    Isolation.level = settings.global[Settings.isolationLevel].value
    log("Detected isolation level: " .. Isolation.level)
end

local function KickAllPlayersFromSandboxes()
    for _, player in pairs(game.players) do
        if Sandbox.IsPlayerInsideSandbox(player) then
            Sandbox.Exit(player)
        end
    end
end

-- Make adjustments if the isolation level changes
---@param event EventData.on_runtime_mod_setting_changed
function Isolation.OnLevelChanged(event)
    local newLevel = settings.global[Settings.isolationLevel].value
    if Isolation.level ~= newLevel then
        log("Changing isolation level: " .. Isolation.level .. " -> " .. newLevel)

        KickAllPlayersFromSandboxes()

        -- These operations depend on the new/old value
        for _, surface in pairs(game.surfaces) do
            if Sandbox.IsSandbox(surface) then
                local surfaceData = storage.labSurfaces[surface.name]
                if surfaceData then
                    local sandboxForceName = surfaceData.sandboxForceName
                    local sandboxForceData = storage.sandboxForces[sandboxForceName]
                    local mainForceName = sandboxForceData.forceName
                    local mainForce = game.forces[mainForceName]
                    if newLevel == Isolation.none then
                        Lab.AssignEntitiesToForce(surface, mainForce)
                    elseif newLevel == Isolation.full then
                        local sandboxForce = Force.GetOrCreateSandboxForce(mainForce)
                        Lab.AssignEntitiesToForce(surface, sandboxForce)
                    end
                end
            end
        end

        -- TODO: Cleanup permissions?
        -- TODO: Cleanup forces?

        Isolation.level = newLevel

        -- These react to the current isolation level
        RemoteView.SyncSurfaceVisibility()
    end
end

return Isolation
