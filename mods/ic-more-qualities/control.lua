local switches = require("scripts.switches")
-- Quality switched off: the mod does nothing at runtime, as if it were disabled.
if not switches.quality() then return end

local model = require("scripts.defects.model")
local handcraft = require("scripts.defects.handcraft")
local production_loss = require("scripts.defects.production-loss")
local cancel = require("scripts.defects.cancel")
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
local classify = require("scripts.defects.classify")

-- Setting caches (read on every tick otherwise). Startup settings change only together with a
-- configuration change, map settings raise on_runtime_mod_setting_changed. Not kept in storage:
-- after a load they are read again from the synchronised settings, so every peer agrees.
local enabled_cache, exclude_cache, loss_cache

local function enabled()
    -- Keep the original setting ID so existing saved startup choices are respected.
    if enabled_cache == nil then enabled_cache = switches.defects() end
    return enabled_cache
end

local function exclude_finished()
    if exclude_cache == nil then exclude_cache = settings.global["ic-more-qualities-loss-exclude-finished"].value end
    return exclude_cache
end

local function initial_loss_percent()
    if loss_cache == nil then loss_cache = settings.global["ic-more-qualities-initial-loss-percent"].value end
    return loss_cache
end

local function reset_settings()
    enabled_cache, exclude_cache, loss_cache = nil, nil, nil
end

-- Deterministic caches derived from prototypes only (identical on all peers).
local category_min, min_energy_cache, emissions_cache, no_quality_cache = nil, {}, {}, nil
-- Recycling only: fastest recipe per category whose item can be defective, and the per-machine caches.
local watched_min, watched_cache, recycler_cache = nil, {}, {}

local function lower(map, category, energy)
    if not map[category] or energy < map[category] then map[category] = energy end
end

-- watched: only recycling recipes of items that can be defective (classify.watched_recycling).
local function min_energy(entity, watched)
    local name = entity.name
    local cache = watched and watched_cache or min_energy_cache
    local cached = cache[name]
    if cached == nil then
        if not category_min then
            category_min, watched_min = {}, {}
            local finished, no_defect = eligibility.finished(), eligibility.no_defect()
            for _, recipe in pairs(prototypes.recipe) do
                local energy, category = recipe.energy, recipe.category
                if energy > 0 then
                    lower(category_min, category, energy)
                    if classify.watched_recycling(recipe, finished, no_defect) then
                        lower(watched_min, category, energy)
                    end
                end
            end
        end
        local by_category = watched and watched_min or category_min
        cached = false
        for category in pairs(entity.prototype.crafting_categories or {}) do
            local energy = by_category[category]
            if energy and (not cached or energy < cached) then cached = energy end
        end
        cache[name] = cached
    end
    return cached or nil
end

local function is_recycler(entity)
    local name = entity.name
    local cached = recycler_cache[name]
    if cached == nil then
        cached = false
        for category in pairs(entity.prototype.crafting_categories or {}) do
            if classify.recycling[category] then cached = true end
        end
        recycler_cache[name] = cached
    end
    return cached
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

local everywhere_setting = settings.startup["ic-more-qualities-quality-everywhere"]
local quality_everywhere = everywhere_setting ~= nil and everywhere_setting.value == true

local function no_quality()
    if not no_quality_cache then
        local mod_data = prototypes.mod_data[names.mod_data]
        no_quality_cache = mod_data and mod_data.data.no_quality or {}
    end
    return no_quality_cache
end

-- One context table for the scheduler: its functions are created once, the data fields are
-- refreshed on every tick that has work (the getters only return caches).
local context = {
    min_energy = min_energy,
    is_recycler = is_recycler,
    emissions = emissions,
    stat = stats.add,
    quality_everywhere = quality_everywhere,
    mode_definition = modes.definition,
    mode_power = function(entity, definition, working)
        return modes.draw_power(entity, definition, working, game.tick)
    end,
    mode_boost = function(entity, quality, definition)
        return modes.boost(entity, quality, definition, math.random)
    end,
}

local function automation_context()
    context.random = math.random
    context.finished = eligibility.finished()
    context.no_defect = eligibility.no_defect()
    context.exclude_finished = exclude_finished()
    context.initial_loss_percent = initial_loss_percent()
    context.no_quality = no_quality()
    return context
end

-- Production modes need the defect scheduler to watch the machine.
local hooks = {track_machine = function(entity) automation.track(entity) end}
memory.hooks = hooks

-- Paranoidal: every quality is available from the start (e.g. a quality module found in ruins).
local function unlock_all_qualities(force)
    if not (prototypes and prototypes.quality and force.unlock_quality) then return end -- test mocks
    for name, quality in pairs(prototypes.quality) do
        if not quality.hidden and name ~= "quality-unknown" and not force.is_quality_unlocked(name) then
            force.unlock_quality(name)
        end
    end
end

local function configure_force(force)
    unlock_all_qualities(force)
    if not enabled() then return end
    for tier = 1, 5 do force.unlock_quality("ic-defect-" .. tier) end
    for level = 1, 10 do
        local technology = force.technologies[model.research(level).name]
        if technology then technology.enabled = true end
    end
end

local function configure_all()
    reset_settings()
    eligibility.reset()
    category_min, min_energy_cache, emissions_cache, no_quality_cache = nil, {}, {}, nil
    watched_min, watched_cache, recycler_cache = nil, {}, {}
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
    -- After quality control 10 no new defects appear: chat stays silent, the log keeps the line.
    if automation.level(player.force) < 10 then player.print({"ic-defects.skipped-result", detail, status}) end
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
    -- Research 10 (required for green science): no loss and no new roll. Only a defective result (from
    -- defective ingredients) or, with "quality everywhere" off, a positive material needs handling; skip
    -- the queue scan and the handlers for everything else.
    if model.completed_level(player.force.technologies) == 10 then
        local quality = stack.quality.name
        if not model.is_defect(quality)
            and (quality == "normal" or quality_everywhere or eligibility.finished()[stack.name]) then
            return
        end
    end
    local recipe_name = event.recipe and event.recipe.name
    local queue = player.character and player.crafting_queue
    if production_loss.queued_prerequisite(queue, recipe_name, stack.name, prototypes.recipe) then
        -- A cancelled consumer returns it: it gets its roll then (scripts/defects/cancel.lua).
        if stack.quality.name == "normal" then
            cancel.remember(player.index, stack.name, eligibility.finished(), eligibility.no_defect())
        end
        return
    end
    cancel.forget_if_idle(player)
    local finished = eligibility.finished()
    local loss = production_loss.handle(event, player, math.random, finished, exclude_finished(), initial_loss_percent())
    if loss ~= "ignored" then
        stats.add(player.force.index, "hand.ops")
        if loss == "empty-result" then stats.add(player.force.index, "hand.loss") end
    end
    if loss == "empty-result" or loss == "ignored" then return end
    local status, detail = handcraft.handle(event, player, game.create_inventory, math.random, finished, quality_everywhere, eligibility.no_defect())
    if status == "changed" and type(detail) == "string" then
        stats.add(player.force.index, "grade." .. model.grade_of(detail))
    end
    if reported[status] then warn_player(player, status, detail) end
end)

events.on(defines.events.on_pre_player_crafted_item, function(event)
    if not enabled() then return end
    local player = game.get_player(event.player_index)
    if player and player.valid then cancel.forget_if_idle(player) end
end)
events.on(defines.events.on_player_cancelled_crafting, function(event)
    if enabled() then cancel.on_cancelled(event, eligibility.finished(), eligibility.no_defect()) end
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
-- The hotkeys exist only with defects (data.lua): without them the engine rejects their names.
if enabled() then
    events.on(names.rotate, function(event) rotate(event, 1) end)
    events.on(names.reverse_rotate, function(event) rotate(event, 3) end)
end

local function toggle_panel(event)
    if not enabled() then return end
    local player = game.get_player(event.player_index)
    if player then gui.toggle_panel(player) end
end
if enabled() then events.on(names.panel_hotkey, toggle_panel) end
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
    cancel.remove_player(event.player_index)
end)

events.on(defines.events.on_runtime_mod_setting_changed, function() reset_settings() end)

local workshop_context = {}
events.on(defines.events.on_tick, function(event)
    if not enabled() then return end
    local tick = event.tick
    workshop_context.tick, workshop_context.random = tick, math.random
    workshop.on_tick(workshop_context)
    post.on_tick(tick)
    if cancel.has_pending() then
        cancel.process(tick, game.get_player, math.random, eligibility.finished(), eligibility.no_defect())
    end
    if tick % 10 == 0 then gui.on_refresh(tick) end
    if tick % 60 == 0 then memory.cleanup() end
end)

events.bind()
