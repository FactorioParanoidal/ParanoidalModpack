local switches = require("scripts.switches")
-- Quality switched off: the mod does nothing at runtime, as if it were disabled.
if not switches.quality() then return end

local model = require("scripts.defects.model")
local handcraft = require("scripts.defects.handcraft")
local cancel = require("scripts.defects.cancel")
local eligibility = require("scripts.defects.eligibility")
local compiled = require("scripts.defects.compiled")
local automation = require("scripts.defects.automation")
local events = require("scripts.events")
local stats = require("scripts.stats")
local names = require("scripts.expansion.names")
local workshop = require("scripts.expansion.workshop")
local post = require("scripts.expansion.post")
local modes = require("scripts.expansion.modes")
local memory = require("scripts.expansion.memory")
local gui = require("scripts.expansion.gui")
local look = require("scripts.defects.look")
local look_rules = require("scripts.defects.look-rules")

-- Startup settings change only together with a configuration change. Not kept in storage: after a load
-- they are read again from the synchronised settings, so every peer agrees.
local enabled_cache

local function enabled()
    -- Keep the original setting ID so existing saved startup choices are respected.
    if enabled_cache == nil then enabled_cache = switches.defects() end
    return enabled_cache
end

local everywhere_setting = settings.startup["ic-more-qualities-quality-everywhere"]
local quality_everywhere = everywhere_setting ~= nil and everywhere_setting.value == true

local no_quality_cache
local function no_quality()
    if not no_quality_cache then
        local mod_data = prototypes.mod_data[names.mod_data]
        no_quality_cache = mod_data and mod_data.data.no_quality or {}
    end
    return no_quality_cache
end

local function machine_of(record, entity) return compiled.machine(entity, record.name) end

-- One context table for the scheduler: its functions are created once, the data fields are refreshed on
-- every tick that has work (the getters only return caches).
local context = {
    machine = machine_of,
    recipe = compiled.recipe,
    stat = stats.add,
    quality_everywhere = quality_everywhere,
    mode_definition = modes.definition_of_name,
}

local function automation_context()
    context.random = math.random
    return context
end

-- The quality beacon of production modes follows the same recipe rules as the defect scheduler.
modes.context = {recipe = compiled.recipe, no_quality = no_quality, quality_everywhere = quality_everywhere}

-- A machine replaced by a mode switch: the defect scheduler follows the replacement.
local hooks = {track_machine = function(entity, old_id, keep)
    if old_id then automation.track_replaced(entity, old_id, keep) else automation.track(entity) end
end}
memory.hooks = hooks
modes.on_tracked = hooks.track_machine
-- Look of defective buildings: a twin uses the silhouette of its original and is drawn after a mode switch.
look.base_name = modes.base_name
modes.on_swapped = look.draw

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

-- Panel counters of the removed production losses and of the operation counts (2026-10-29).
local OBSOLETE_STATS = {"hand.ops", "hand.loss", "machine.ops", "machine.loss", "drill.ops", "drill.loss",
    "mining.ops", "mining.loss"}

local function configure_all()
    enabled_cache, no_quality_cache = nil, nil
    eligibility.reset()
    automation.reset_cache()
    handcraft.reset_cache()
    workshop.reset_cache()
    post.reset_cache()
    modes.reset_cache()
    look.reset_cache()
    -- Registry of the abandoned per-tick machine prototype of this branch.
    storage.ic_defect_machines = nil
    for _, counters in pairs(storage.ic_stats or {}) do
        for _, key in ipairs(OBSOLETE_STATS) do counters[key] = nil end
    end
    for _, force in pairs(game.forces) do configure_force(force) end
    if enabled() then
        local found = {}
        for _, surface in pairs(game.surfaces) do
            for _, entity in pairs(surface.find_entities_filtered({name = names.workshop})) do found[#found + 1] = entity end
        end
        workshop.rescan(found)
        post.rescan()
        -- Before automation.rescan: older machines in a mode become twins, which the scheduler then finds.
        modes.rescan()
        automation.rescan()
        look.redraw_all()
    else
        -- Without defects there are no production modes: every machine goes back to its original.
        modes.revert_all()
        automation.clear()
        look.clear_all()
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
    local level = automation.level(player.force)
    local recipe_name = event.recipe and event.recipe.name
    local normal_result = recipe_name ~= nil and eligibility.normal_result()[recipe_name] == true
    -- Research 10 (required for green science): no new roll. Only a defective result (from defective
    -- ingredients), a positive result of a registry "ic-normal-result" recipe or, with "quality everywhere"
    -- off, a positive material needs handling; skip the queue scan and the handler for everything else.
    if level == 10 then
        local quality = stack.quality.name
        if not model.is_defect(quality) and not (normal_result and quality ~= "normal")
            and (quality == "normal" or quality_everywhere or eligibility.finished()[stack.name]) then
            return
        end
    end
    local queue = player.character and player.crafting_queue_size > 0 and player.crafting_queue
    if queue and handcraft.queued_prerequisite(queue, recipe_name, stack.name, prototypes.recipe) then
        -- A cancelled consumer returns it: it gets its roll then (scripts/defects/cancel.lua).
        if stack.quality.name == "normal" then
            cancel.remember(player.index, stack.name, eligibility.finished(), eligibility.no_defect())
        end
        return
    end
    cancel.forget_if_idle(player)
    local status, detail = handcraft.handle(event, player, game.create_inventory, math.random, eligibility.finished(),
        quality_everywhere, eligibility.no_defect(), level, normal_result)
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

-- Buildings of the expansion: workshop, control post and machines with production modes.
local building_filters = {
    {filter = "type", type = "furnace"}, {filter = "type", type = "container"},
    {filter = "type", type = "assembling-machine"},
}
-- The dispatcher merges the filters of one event: the look handlers below widen them, so these handlers
-- check the type themselves.
local building_types = {furnace = true, container = true, ["assembling-machine"] = true}

automation.register(enabled, automation_context, events)

---------------------------------------------------------------------------------------------------
-- Quality-control expansion: workshop, control post, production modes, panel
---------------------------------------------------------------------------------------------------
local function on_built(event)
    if not enabled() then return end
    local entity = event.entity
    if not (entity and entity.valid and building_types[entity.type]) then return end
    local settings = memory.tags_of(event)
    -- A mode from tags or a replaced machine swaps the machine: continue with the replacement.
    if settings then entity = memory.import(entity, settings, hooks) else entity = memory.consume(entity, hooks) end
    if not (entity and entity.valid) then return end
    -- A twin built from its ghost (a destroyed machine in a mode) or by a script.
    if modes.split(entity.name) then modes.adopt(entity) end
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
    if not (destination and destination.valid and building_types[destination.type]) then return end
    local settings = memory.export(source)
    if settings then destination = memory.import(destination, settings, hooks) end
    if not (destination and destination.valid) then return end
    if modes.split(destination.name) then modes.adopt(destination) end
    if destination.name == names.workshop then workshop.track(destination)
    elseif destination.name == names.post then post.track(destination) end
end, building_filters)
-- A cloned mode beacon belongs to no machine: the cloned twin gets its own.
events.on(defines.events.on_entity_cloned, function(event)
    local destination = event.destination
    if destination and destination.valid and destination.name == names.mode_beacon then destination.destroy() end
end, {{filter = "name", name = names.mode_beacon}})
-- Moved by a script (dollies): the mode beacon follows.
events.on(defines.events.script_raised_teleported, function(event)
    if enabled() then modes.wake(event.entity) end
end, {{filter = "type", type = "assembling-machine"}, {filter = "type", type = "furnace"}})

-- Look of defective buildings (scripts/defects/look.lua): after the expansion handlers, so that a machine
-- replaced by its mode twin is drawn by the swap hook.
local look_filters = {}
for _, kind in ipairs(look_rules.types) do look_filters[#look_filters + 1] = {filter = "type", type = kind} end
local function look_built(event)
    if enabled() then look.draw(event.entity) end
end
for _, id in ipairs({defines.events.on_built_entity, defines.events.on_robot_built_entity,
    defines.events.script_raised_built, defines.events.script_raised_revive}) do
    events.on(id, look_built, look_filters)
end
events.on(defines.events.on_entity_cloned, function(event)
    if enabled() then look.draw(event.destination) end
end, look_filters)
events.on(defines.events.on_player_rotated_entity, function(event)
    if enabled() then look.draw(event.entity) end
end)
events.on(defines.events.on_player_flipped_entity, function(event)
    if enabled() then look.draw(event.entity) end
end)
events.on(defines.events.on_runtime_mod_setting_changed, function(event)
    if enabled() and look.is_setting(event.setting) then look.redraw_all() end
end)

events.on(defines.events.on_object_destroyed, function(event)
    local id = event.useful_id
    if event.type ~= defines.target_type.entity or not id or id == 0 then return end
    look.forget(id)
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
    -- A pasted mode may replace the destination (an open window follows it).
    local destination = memory.on_settings_pasted(event, hooks)
    if not (destination and destination.valid) then return end
    modes.wake(destination)
    local player = game.get_player(event.player_index)
    if player and player.opened == destination then gui.open_entity(player, destination) end
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
    if event.entity then
        gui.close_entity(player)
        if enabled() then modes.wake(event.entity) end
    end
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

local workshop_context = {}
events.on(defines.events.on_tick, function(event)
    if not enabled() then return end
    local tick = event.tick
    workshop_context.tick, workshop_context.random = tick, math.random
    workshop.on_tick(workshop_context)
    post.on_tick(tick)
    modes.on_tick(tick)
    look.on_tick()
    if cancel.has_pending() then
        cancel.process(tick, game.get_player, math.random, eligibility.finished(), eligibility.no_defect())
    end
    if tick % 10 == 0 then gui.on_refresh(tick) end
    if tick % 60 == 0 then memory.cleanup() end
end)

-- Read-only counters of the quality-control panel (workshop attempts and so on) for other mods:
-- the base journal of paranoidal-CodexRPG shows them on its "Quality" page.
remote.add_interface("ic-more-qualities", {
    get_counters = function(force_index) return stats.get(force_index) end,
})

events.bind()
