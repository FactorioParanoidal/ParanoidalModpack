local model = require("scripts.defects.model")
local handcraft = require("scripts.defects.handcraft")
local production_loss = require("scripts.defects.production-loss")
local eligibility = require("scripts.defects.eligibility")
local mining = require("scripts.defects.mining")
local automation = require("scripts.defects.automation")
local events = require("scripts.events")
local stats = require("scripts.stats")
local names = require("scripts.expansion.names")
local workshop = require("scripts.expansion.workshop")
local post = require("scripts.expansion.post")
local modes = require("scripts.expansion.modes")
local memory = require("scripts.expansion.memory")
local gui = require("scripts.expansion.gui")

local function enabled()
    -- Keep the original setting ID so existing saved startup choices are respected.
    return settings.startup["ic-more-qualities-defects-preview"].value
end

local function exclude_finished()
    return settings.global["ic-more-qualities-loss-exclude-finished"].value
end

local function initial_loss_percent()
    return settings.global["ic-more-qualities-initial-loss-percent"].value
end

-- Deterministic caches derived from prototypes only (identical on all peers).
local category_min, min_energy_cache, emissions_cache, no_quality_cache = nil, {}, {}, nil

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

local function no_quality()
    if not no_quality_cache then
        local mod_data = prototypes.mod_data[names.mod_data]
        no_quality_cache = mod_data and mod_data.data.no_quality or {}
    end
    return no_quality_cache
end

local function automation_context()
    return {
        random = math.random,
        finished = eligibility.finished(),
        exclude_finished = exclude_finished(),
        initial_loss_percent = initial_loss_percent(),
        min_energy = min_energy,
        emissions = emissions,
        stat = stats.add,
        no_quality = no_quality(),
        mode_definition = modes.definition,
        mode_power = function(entity, definition, working)
            return modes.draw_power(entity, definition, working, game.tick)
        end,
        mode_boost = function(entity, quality, definition)
            return modes.boost(entity, quality, definition, math.random)
        end,
    }
end

-- Production modes need the defect scheduler to watch the machine.
local hooks = {track_machine = function(entity) automation.track(entity) end}
memory.hooks = hooks

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
    category_min, min_energy_cache, emissions_cache, no_quality_cache = nil, {}, {}, nil
    workshop.reset_cache()
    modes.reset_cache()
    -- Registry of the abandoned per-tick machine prototype of this branch.
    storage.ic_defect_machines = nil
    for _, force in pairs(game.forces) do configure_force(force) end
    if enabled() then
        local found = {}
        automation.rescan(function(entity)
            if entity.name == names.workshop then found[#found + 1] = entity end
        end)
        workshop.rescan(found)
        post.rescan()
        modes.rescan()
    else
        automation.clear()
    end
end

script.on_init(configure_all)
script.on_configuration_changed(configure_all)
events.on(defines.events.on_force_created, function(event) configure_force(event.force) end)
events.on(defines.events.on_force_reset, function(event) configure_force(event.force) end)

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

events.on(defines.events.on_player_crafted_item, function(event)
    if not enabled() then return end
    local player = game.get_player(event.player_index)
    local stack = event.item_stack
    if not player or not player.valid or not stack or not stack.valid_for_read then return end
    local recipe_name = event.recipe and event.recipe.name
    local queue = player.character and player.crafting_queue
    if production_loss.queued_prerequisite(queue, recipe_name, stack.name, prototypes.recipe) then return end
    local finished = eligibility.finished()
    local loss = production_loss.handle(event, player, math.random, finished, exclude_finished(), initial_loss_percent())
    if loss ~= "ignored" then
        stats.add(player.force.index, "hand.ops")
        if loss == "empty-result" then stats.add(player.force.index, "hand.loss") end
    end
    if loss == "empty-result" or loss == "ignored" then return end
    local status, detail = handcraft.handle(event, player, game.create_inventory, math.random, finished)
    if status == "changed" and type(detail) == "string" then
        stats.add(player.force.index, "grade." .. model.grade_of(detail))
    end
    if reported[status] then warn_player(player, status, detail) end
end)

-- Mining: natural objects (loss) and the workshop (an interrupted series returns its grade).
local mined_filters = {}
for _, kind in ipairs(mining.event_types) do mined_filters[#mined_filters + 1] = {filter = "type", type = kind} end
local building_filters = {
    {filter = "type", type = "furnace"}, {filter = "type", type = "container"},
    {filter = "type", type = "assembling-machine"},
}

local function mined_natural(entity, buffer, force)
    local status = mining.handle(entity, buffer, force, math.random, initial_loss_percent())
    if status == "lost" or status == "survived" or status == "loss-free" then
        stats.add(force.index, "mining.ops")
        if status == "lost" then stats.add(force.index, "mining.loss") end
    end
end

events.on(defines.events.on_player_mined_entity, function(event)
    if not enabled() then return end
    local player = game.get_player(event.player_index)
    if player and player.valid then mined_natural(event.entity, event.buffer, player.force) end
end, mined_filters)
events.on(defines.events.on_robot_mined_entity, function(event)
    if not enabled() then return end
    local robot = event.robot
    if robot and robot.valid then mined_natural(event.entity, event.buffer, robot.force) end
end, mined_filters)
for _, id in ipairs({defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity}) do
    events.on(id, function(event)
        if enabled() and event.entity and event.entity.valid and event.entity.name == names.workshop then
            workshop.on_mined(event.entity, event.buffer)
        end
    end, building_filters)
end

automation.register(enabled, automation_context, events)

---------------------------------------------------------------------------------------------------
-- Quality-control expansion: workshop, control post, production modes, panel
---------------------------------------------------------------------------------------------------
local function on_built(event)
    if not enabled() then return end
    local entity = event.entity
    if not (entity and entity.valid) then return end
    local settings = memory.tags_of(event)
    if settings then memory.import(entity, settings, hooks) else memory.consume(entity, hooks) end
    if entity.name == names.workshop then
        workshop.track(entity)
    elseif entity.name == names.post and not post.get(entity) then
        local facing = event.player_index and gui.player_settings(event.player_index).post_facing
        post.track(entity, nil, facing)
    end
end
for _, id in ipairs({defines.events.on_built_entity, defines.events.on_robot_built_entity,
    defines.events.script_raised_built, defines.events.script_raised_revive}) do
    events.on(id, on_built, building_filters)
end
events.on(defines.events.on_entity_cloned, function(event)
    if not enabled() then return end
    local source, destination = event.source, event.destination
    if not (destination and destination.valid) then return end
    local settings = memory.export(source)
    if settings then memory.import(destination, settings, hooks) end
    if destination.name == names.workshop then workshop.track(destination)
    elseif destination.name == names.post then post.track(destination) end
end, building_filters)

events.on(defines.events.on_object_destroyed, function(event)
    local id = event.useful_id
    if event.type ~= defines.target_type.entity or not id or id == 0 then return end
    local kinds = {
        {"workshop", storage.ic_workshops, workshop},
        {"post", storage.ic_posts, post},
        {"mode", storage.ic_modes, modes},
    }
    for _, kind in ipairs(kinds) do
        local record = kind[2] and kind[2].records[id]
        if record then
            memory.remember(kind[1], record)
            kind[3].forget(id)
        end
    end
end)
events.on(defines.events.on_post_entity_died, function(event)
    if enabled() then memory.on_post_died(event) end
end)
events.on(defines.events.on_entity_settings_pasted, function(event)
    if not enabled() then return end
    memory.on_settings_pasted(event, hooks)
    local player = game.get_player(event.player_index)
    if player and player.opened == event.destination then gui.open_entity(player, event.destination) end
end)
events.on(defines.events.on_player_setup_blueprint, function(event)
    if enabled() then memory.on_setup_blueprint(event) end
end)

local function rotate(event, step)
    if not enabled() then return end
    local player = game.get_player(event.player_index)
    if not player then return end
    local selected = player.selected
    if selected and selected.valid and selected.name == names.post then
        local record = post.track(selected)
        if record then
            post.rotate(record, step)
            if player.opened == selected then gui.open_entity(player, selected) end
        end
        return
    end
    local cursor = player.cursor_stack
    if cursor and cursor.valid_for_read and cursor.name == names.post then
        local settings = gui.player_settings(player.index)
        settings.post_facing = ((settings.post_facing or 0) + step) % 4
        player.create_local_flying_text({text = {"ic-quality.post-facing-" .. settings.post_facing}, create_at_cursor = true})
    end
end
events.on(names.rotate, function(event) rotate(event, 1) end)
events.on(names.reverse_rotate, function(event) rotate(event, 3) end)

local function toggle_panel(event)
    if not enabled() then return end
    local player = game.get_player(event.player_index)
    if player then gui.toggle_panel(player) end
end
events.on(names.panel_hotkey, toggle_panel)
events.on(defines.events.on_lua_shortcut, function(event)
    if event.prototype_name == names.panel_shortcut then toggle_panel(event) end
end)

events.on(defines.events.on_gui_opened, function(event)
    if not enabled() then return end
    local player = game.get_player(event.player_index)
    if player and event.entity then gui.open_entity(player, event.entity) end
end)
events.on(defines.events.on_gui_closed, function(event)
    local player = game.get_player(event.player_index)
    if not player then return end
    if event.entity then gui.close_entity(player) end
    if event.element and event.element.valid and event.element.name == "ic_quality_panel" then gui.close_panel(player) end
end)
events.on(defines.events.on_gui_click, function(event) gui.on_click(event, hooks) end)
events.on(defines.events.on_gui_checked_state_changed, function(event) gui.on_checked(event, hooks) end)
events.on(defines.events.on_gui_elem_changed, gui.on_elem_changed)
events.on(defines.events.on_gui_selection_state_changed, gui.on_selection)
events.on(defines.events.on_gui_text_changed, gui.on_text)
events.on(defines.events.on_gui_confirmed, gui.on_text)
events.on(defines.events.on_gui_selected_tab_changed, gui.on_tab)
events.on(defines.events.on_player_removed, function(event)
    if storage.ic_players then storage.ic_players[event.player_index] = nil end
end)

events.on(defines.events.on_tick, function(event)
    if not enabled() then return end
    local tick = event.tick
    workshop.on_tick({tick = tick, random = math.random})
    post.on_tick(tick)
    if tick % 10 == 0 then gui.on_refresh(tick) end
    if tick % 60 == 0 then memory.cleanup() end
end)

events.bind()
