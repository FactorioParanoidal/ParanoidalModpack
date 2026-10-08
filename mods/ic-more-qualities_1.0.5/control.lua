local model = require("scripts.defects.model")
local handcraft = require("scripts.defects.handcraft")
local production_loss = require("scripts.defects.production-loss")
local eligibility = require("scripts.defects.eligibility")
local mining = require("scripts.defects.mining")
local automation = require("scripts.defects.automation")

local function enabled()
    -- Keep the original setting ID so existing saved startup choices are respected.
    return settings.startup["ic-more-qualities-defects-preview"].value
end

local function exclude_finished()
    return settings.global["ic-more-qualities-loss-exclude-finished"].value
end

-- Deterministic caches derived from prototypes only (identical on all peers).
local category_min, min_energy_cache, emissions_cache = nil, {}, {}

local function min_energy(entity)
    local name = entity.name
    local cached = min_energy_cache[name]
    if cached == nil then
        if not category_min then
            category_min = {}
            for _, recipe in pairs(prototypes.recipe) do
                local energy, category = recipe.energy, recipe.category
                if energy > 0 and (not category_min[category] or energy < category_min[category]) then
                    category_min[category] = energy
                end
            end
        end
        cached = false
        for category in pairs(entity.prototype.crafting_categories or {}) do
            local energy = category_min[category]
            if energy and (not cached or energy < cached) then cached = energy end
        end
        min_energy_cache[name] = cached
    end
    return cached or nil
end

local function emissions(entity)
    local name = entity.name
    local cached = emissions_cache[name]
    if cached == nil then
        local prototype = entity.prototype
        local source = prototype.electric_energy_source_prototype or prototype.burner_prototype
        cached = source and source.emissions_per_joule or false
        emissions_cache[name] = cached
    end
    return cached or nil
end

local function automation_context()
    return {
        random = math.random,
        finished = eligibility.finished(),
        exclude_finished = exclude_finished(),
        min_energy = min_energy,
        emissions = emissions,
    }
end

local function configure_force(force)
    if not enabled() then return end
    for tier = 1, 5 do force.unlock_quality("ic-defect-" .. tier) end
    for level = 1, 10 do
        local technology = force.technologies[model.research(level).name]
        if technology then technology.enabled = true end
    end
end

local function configure_all()
    eligibility.reset()
    category_min, min_energy_cache, emissions_cache = nil, {}, {}
    -- Registry of the abandoned per-tick machine prototype of this branch.
    storage.ic_defect_machines = nil
    for _, force in pairs(game.forces) do configure_force(force) end
    if enabled() then automation.rescan() else automation.clear() end
end

script.on_init(configure_all)
script.on_configuration_changed(configure_all)
script.on_event(defines.events.on_force_created, function(event) configure_force(event.force) end)
script.on_event(defines.events.on_force_reset, function(event) configure_force(event.force) end)

local function warn_player(player, status, detail)
    -- Explicitly report unsupported results instead of silently calling the
    -- entire pack compatible. No inventory conversion fallback.
    storage.ic_defect_warnings = storage.ic_defect_warnings or {}
    local key = player.index .. ":" .. status .. ":" .. detail
    if storage.ic_defect_warnings[key] then return end
    storage.ic_defect_warnings[key] = true
    player.print({"ic-defects.skipped-result", detail, status})
    log("IC defects: left crafted result unchanged: " .. detail .. " (" .. status .. ")")
end

local reported = {
    ["unsupported-item"] = true, ["occupied-grid"] = true, ["entity-data"] = true,
    ["unsupported-durability"] = true, ["candidate-rejected"] = true, ["swap-rejected"] = true,
}

script.on_event(defines.events.on_player_crafted_item, function(event)
    if not enabled() then return end
    local player = game.get_player(event.player_index)
    local stack = event.item_stack
    if not player or not player.valid or not stack or not stack.valid_for_read then return end
    local recipe_name = event.recipe and event.recipe.name
    local queue = player.character and player.crafting_queue
    if production_loss.queued_prerequisite(queue, recipe_name, stack.name, prototypes.recipe) then return end
    local finished = eligibility.finished()
    local loss = production_loss.handle(event, player, math.random, finished, exclude_finished())
    if loss == "empty-result" or loss == "ignored" then return end
    local status, detail = handcraft.handle(event, player, game.create_inventory, math.random, finished)
    if reported[status] then warn_player(player, status, detail) end
end)

local mining_filters = {}
for _, kind in ipairs(mining.event_types) do mining_filters[#mining_filters + 1] = {filter = "type", type = kind} end
script.on_event(defines.events.on_player_mined_entity, function(event)
    if not enabled() then return end
    local player = game.get_player(event.player_index)
    if player and player.valid then mining.handle(event.entity, event.buffer, player.force, math.random) end
end, mining_filters)
script.on_event(defines.events.on_robot_mined_entity, function(event)
    if not enabled() then return end
    local robot = event.robot
    if robot and robot.valid then mining.handle(event.entity, event.buffer, robot.force, math.random) end
end, mining_filters)

automation.register(enabled, automation_context)
