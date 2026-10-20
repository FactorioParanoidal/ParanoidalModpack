-- Managing the Research of each Force's Sandboxes
local Research = {}

-- Set a Force's Sandboxes Research equal to that of the Force's (or all research)
---@param originalForce LuaForce
---@param sandboxForce LuaForce
function Research.Sync(originalForce, sandboxForce)
    if settings.global[Settings.allowAllTech].value then
        sandboxForce.research_all_technologies()
        log("Researching everything for: " .. sandboxForce.name)
    else
        -- Paranoidal: the old single pass wrote `level` unconditionally (writing it re-researches
        -- a level-based technology only up to the previous level, i.e. it can unresearch it) and
        -- copied `researched` in arbitrary order, so after "Unlock all" -> off the Sandbox could
        -- lose almost the whole tree. Now: unresearch first, then levels (only multi-level and only
        -- if different), then research; repeat while anything still differs (cascades).
        local techs = sandboxForce.technologies
        local original = originalForce.technologies
        for pass = 1, 5 do
            local changed = false
            for name, sandboxTech in pairs(techs) do
                local originalTech = original[name]
                if originalTech and sandboxTech.researched and not originalTech.researched then
                    sandboxTech.researched = false
                    changed = true
                end
            end
            for name, sandboxTech in pairs(techs) do
                local originalTech = original[name]
                local proto = sandboxTech.prototype
                if originalTech and proto.max_level > proto.level and sandboxTech.level ~= originalTech.level then
                    sandboxTech.level = originalTech.level
                    changed = true
                end
            end
            for name, sandboxTech in pairs(techs) do
                local originalTech = original[name]
                if originalTech and originalTech.researched and not sandboxTech.researched then
                    sandboxTech.researched = true
                    changed = true
                end
            end
            if not changed then break end
            if pass == 5 then
                log("Research.Sync did not converge for: " .. sandboxForce.name)
            end
        end
        log("Copied all Research from: " .. originalForce.name .. " -> " .. sandboxForce.name)
    end
end

-- Set a Force's Sandboxes Research Queue equal to that of the Force's
---@param originalForce LuaForce
---@param sandboxForce LuaForce
function Research.SyncQueue(originalForce, sandboxForce)
    if settings.global[Settings.allowAllTech].value then
        sandboxForce.research_queue = nil
        log("Emptying Research Queue for: " .. sandboxForce.name)
    else
        local newQueue = {}
        for _, tech in pairs(originalForce.research_queue) do
            table.insert(newQueue, tech.name)
        end
        sandboxForce.research_queue = newQueue
        log("Copied Research Queue from: " .. originalForce.name .. " -> " .. sandboxForce.name)
    end
end

-- Check if any Players on a Force are inside of a Sandbox
---@param force LuaForce
---@return boolean
local function IsAnyPlayerInSandbox(force)
    local anyPlayersInSandbox = false
    for _, player in pairs(force.players) do
        if Sandbox.IsPlayerInsideSandbox(player) then
            anyPlayersInSandbox = true
            break
        end
    end
    return anyPlayersInSandbox
end

-- Enable the Infinity Input/Output Recipes
---@param force LuaForce
function Research.EnableSandboxSpecificResearchIfNecessary(force)
    local anyPlayersInSandbox = IsAnyPlayerInSandbox(force)
    if not anyPlayersInSandbox then return end

    log("Unlocking hidden Recipes for: " .. force.name)
    function enable(name)
        if force.recipes[name] then force.recipes[name].enabled = true end
    end

    enable(BPSB.pfx .. "loader")
    enable(BPSB.pfx .. "fast-loader")
    enable(BPSB.pfx .. "express-loader")
    enable(BPSB.pfx .. "turbo-loader")
    enable(BPSB.pfx .. "heat-interface")
    enable(BPSB.pfx .. "electric-energy-interface")
    enable(BPSB.pfx .. "infinity-chest")
    enable(BPSB.pfx .. "infinity-pipe")
    enable(BPSB.pfx .. "infinity-cargo-wagon")

    EditorExtensionsCheats.EnableTestingRecipes(force)
end

-- Enable the Infinity Input/Output Recipes
---@param force LuaForce
function Research.DisableSandboxSpecificResearchIfNecessary(force)
    local anyPlayersInSandbox = IsAnyPlayerInSandbox(force)
    if anyPlayersInSandbox then return end

    log("Locking hidden Recipes for: " .. force.name)
    function disable(name)
        if force.recipes[name] then force.recipes[name].enabled = false end
    end

    disable(BPSB.pfx .. "loader")
    disable(BPSB.pfx .. "fast-loader")
    disable(BPSB.pfx .. "express-loader")
    disable(BPSB.pfx .. "turbo-loader")
    disable(BPSB.pfx .. "heat-interface")
    disable(BPSB.pfx .. "electric-energy-interface")
    disable(BPSB.pfx .. "infinity-chest")
    disable(BPSB.pfx .. "infinity-pipe")
    disable(BPSB.pfx .. "infinity-cargo-wagon")

    EditorExtensionsCheats.DisableTestingRecipes(force)
end

-- For all Forces with Sandboxes, Sync their Research
function Research.SyncAllForces()
    for _, force in pairs(game.forces) do
        -- Paranoidal: skip instead of `return`, which stopped at the first force without a Sandbox
        if not Sandbox.IsSandboxForce(force) then
            local sandboxForce = Force.GetSandboxForce(force)
            if sandboxForce then
                Research.Sync(force, sandboxForce)
                Research.SyncQueue(force, sandboxForce)
            end
        end
    end
    -- Paranoidal: re-copy the force bonuses (they are left unsynced while everything is unlocked)
    Force.SyncAllForces()
end

-- As a Force's Research Queue changes, keep the Force's Sandboxes in-sync
---@param event EventData.on_research_moved
function Research.OnResearchReordered(event)
    if settings.global[Settings.allowAllTech].value then return end
    if Sandbox.IsSandboxForce(event.force) then return end
    local sandboxForce = Force.GetSandboxForce(event.force)
    if not sandboxForce then return end
    log("Research queue reordered: " .. event.force.name .. " -> " .. sandboxForce.name)
    Research.SyncQueue(event.force, sandboxForce)
end

-- As a Force's Research changes, keep the Force's Sandboxes in-sync
---@param event EventData.on_research_finished | EventData.on_research_reversed
function Research.OnResearched(event)
    if settings.global[Settings.allowAllTech].value then return end
    local force = event.research.force
    if Sandbox.IsSandboxForce(force) then return end
    local sandboxForce = Force.GetSandboxForce(force)
    if not sandboxForce then return end
    log("New Research: " .. event.research.name .. " from " .. force.name .. " -> " .. sandboxForce.name)
    local sandboxTech = sandboxForce.technologies[event.research.name]
    local normalTech = force.technologies[event.research.name]
    if sandboxTech.researched ~= normalTech.researched then
        sandboxTech.researched = normalTech.researched
    end
    if sandboxTech.level ~= normalTech.level then
        sandboxTech.level = normalTech.level
    end
    sandboxForce.play_sound { path = "utility/research_completed" }
    Research.SyncQueue(force, sandboxForce)
end

-- As a Force's Research Queue changes, show it in the Force's Sandboxes
---@param event EventData.on_research_started
function Research.OnResearchStarted(event)
    if settings.global[Settings.allowAllTech].value then return end
    local force = event.research.force
    if Sandbox.IsSandboxForce(force) then return end
    local sandboxForce = Force.GetSandboxForce(force)
    if not sandboxForce then return end
    log("New Research Queued: " .. event.research.name .. " from " .. force.name .. " -> " .. sandboxForce.name)
    Research.SyncQueue(force, sandboxForce)
end

return Research
