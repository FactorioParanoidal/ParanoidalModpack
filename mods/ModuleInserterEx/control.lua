local gui = require("__flib__.gui")
local migration = require("__flib__.migration")
local table = require("__flib__.table")

local mi_gui = require("scripts.gui")
local types = require("scripts.types")
local util = require("scripts.util")
local migrations = require("scripts.migrations")

--- @type GlobalData
storage = {} ---@diagnostic disable-line: missing-fields

local control = {}

--- @param e GuiEventData|EventData|EventData.on_mod_item_opened|EventData.CustomInputEvent|EventData.on_lua_shortcut
--- @return MiEventInfo
local function make_event_info(e)
    return {
        event = e,
        player = game.get_player(e.player_index),
        pdata = storage._pdata[e.player_index],
    }
end

local function get_module_inserter(e)
    local player = game.get_player(e.player_index)
    if not player then return end
    player.clear_cursor()
    player.cursor_stack.set_stack({ name = "module-inserter-ex" })
end

--- @param player LuaPlayer
--- @return boolean is_holding true if the player currently has the module inserter selection tool in cursor
local function player_is_holding_module_inserter(player)
    if not player then return false end
    if not player.cursor_stack then return false end
    if not player.cursor_stack.valid_for_read then return false end
    return player.cursor_stack.name == "module-inserter-ex"
end

--- @param e MiEventInfo
--- @param cycleNext boolean true to go to next preset, false for previous
local function cycle_active_preset(e, cycleNext)
    -- Only activate if the config window is open, or the player is holding the inserter
    if not mi_gui.window_is_open(e) and not player_is_holding_module_inserter(e.player) then
        return
    end
    for i, preset in pairs(e.pdata.saved_presets) do
        if preset == e.pdata.active_config then
            local new_preset
            if cycleNext then
                if i == #e.pdata.saved_presets then
                    new_preset = e.pdata.saved_presets[1]
                else
                    new_preset = e.pdata.saved_presets[i + 1]
                end
            else
                if i == 1 then
                    new_preset = e.pdata.saved_presets[#e.pdata.saved_presets]
                else
                    new_preset = e.pdata.saved_presets[i - 1]
                end
            end

            mi_gui.update_active_preset(e.player, e.pdata, new_preset, not mi_gui.window_is_open(e))
            break
        end
    end
end

local function update_on_tick_listener()
    -- Unregister any previous listener
    script.on_nth_tick(nil)
    storage.nth_tick_registered = nil
    if storage.delayed_work[1] then
        -- Register the handler for the next tick if there is work remaining
        -- Also keep track of this in storage, so we can restore it in on_load (which doesn't have access to the `game` object)
        storage.nth_tick_registered = game.tick + 1
        script.on_nth_tick(game.tick + 1, control.delayed_creation)
    end
end

function control.delayed_creation(e)
    local work_data = storage.delayed_work[1]
    if work_data then
        local player = game.players[work_data.player_index]
        local max_proxies = settings.global["module-inserter-ex-proxies-per-tick"].value

        local num = 0
        for key, entity in pairs(work_data.entities) do
            work_data.entities[key] = nil
            if not entity.valid then
                goto continue
            end
            --skip the entity if it is a tile ghost
            if entity.type == "tile-ghost" then
                goto continue
            end

            local is_ghost = entity.type == "entity-ghost"

            local ent_name
            if is_ghost then
                ent_name = entity.ghost_name
            else
                ent_name = entity.name
            end

            ent_name = util.convert_entity_name(ent_name)

            if not storage.name_to_slot_count[ent_name] then
                -- No module in this entity (e.g. stone furnace)
                goto continue
            end

            --- @type PrototypeWithQuality?
            local recipe = nil
            recipe = util.recipe_pair_from_entity(entity)

            local cache_key
            if recipe then
                cache_key = ent_name .. "|" .. recipe.name .. "|" .. recipe.quality
            else
                cache_key = ent_name
            end


            local cached_value = work_data.entity_recipe_to_config_cache[cache_key]
            local messages
            if cached_value == nil then
                local set_to_use = util.find_module_set_to_use_for_entity(ent_name, recipe, work_data.preset)
                if set_to_use == true then
                    cached_value = true
                else
                    cached_value, messages = util.choose_module_config_from_set(ent_name, recipe, set_to_use)
                end
                work_data.entity_recipe_to_config_cache[cache_key] = cached_value
            end

            if cached_value == true then
                goto continue -- Don't set anything on this entity type
            end

            if cached_value then
                util.create_request_proxy(entity, cached_value --[[@as ModuleConfig]], true)
            end
            if messages then
                for k, v in pairs(messages) do
                    work_data.result_messages[k] = v
                end
            end
            num = num + 1
            if (num >= max_proxies) then
                break
            end
            ::continue::
        end
        if not next(work_data.entities) then
            for _, message in pairs(work_data.result_messages) do
                if player then player.print(message) end
            end
            table.remove(storage.delayed_work, 1)
        end
    end
    update_on_tick_listener()
end

--- Adds the given data to the delayed work queue
local function add_work_data(player_index, preset, entities)
    --- @type DelayedWorkData
    local work_data = {
        preset = preset,
        entities = entities,
        player_index = player_index,
        clear = false,
        result_messages = {},
        entity_to_set_cache = {},
        entity_recipe_to_config_cache = {},
    }
    table.insert(storage.delayed_work, work_data)
    update_on_tick_listener()
end

---@param e EventData.on_player_selected_area
local function on_player_selected_area(e)
    local player_index = e.player_index
    if e.item ~= "module-inserter-ex" or not player_index then return end
    local player = game.get_player(player_index)
    if not player then return end
    local pdata = storage._pdata[player_index]
    local preset = pdata.active_config
    if not preset then
        player.print({ "module-inserter-ex-config-not-set" })
        return
    end
    preset = table.deep_copy(preset)

    add_work_data(e.player_index, preset, e.entities)
end

---@param e EventData.on_player_alt_selected_area
local function on_player_alt_selected_area(e)
    if e.item ~= "module-inserter-ex" then return end
    local empty_config = types.make_module_config()
    for _, entity in pairs(e.entities) do
        util.create_request_proxy(entity, empty_config, false)
    end
end

---@param e EventData.on_player_reverse_selected_area
local function on_player_reverse_selected_area(e)
    local player_index = e.player_index
    if e.item ~= "module-inserter-ex" or not player_index then return end
    local empty_config = types.make_module_config()
    for _, entity in pairs(e.entities) do
        util.create_request_proxy(entity, empty_config, true)
    end
end

---@param prototype LuaEntityPrototype
local function is_ignored_entity(prototype)
    if prototype.name:match("^se-.*-spaced$") then
        -- "grounded" entities from SE get special handling, so we ignore them here
        -- and when applying modules automatically treat them as the non-grounded type
        -- there is also at least one "spaced" entitiy that accepts different modules
        -- so we will keep it as an option for the player to set differently
        return false
    end
    if prototype.hidden then return true end
    return false
end

local function create_lookup_tables()
    storage.type_to_slot_bonus = {}
    storage.name_to_slot_count = {}
    storage.module_entities = {}
    storage.min_slot_count = 0
    storage.max_slot_count = 0

    local function update_bonus_entry(key, new_value)
        storage.type_to_slot_bonus[key] = math.max(storage.type_to_slot_bonus[key] or 0, new_value)
    end
    for _, prototype in pairs(prototypes.quality) do
        update_bonus_entry("assembling-machine", prototype.crafting_machine_module_slots_bonus)
        update_bonus_entry("furnace", prototype.crafting_machine_module_slots_bonus)
        update_bonus_entry("rocket-silo", prototype.crafting_machine_module_slots_bonus)
        update_bonus_entry("beacon", prototype.beacon_module_slots_bonus)
        update_bonus_entry("lab", prototype.lab_module_slots_bonus)
        update_bonus_entry("mining-drill", prototype.mining_drill_module_slots_bonus)
    end

    for name, prototype in pairs(prototypes.entity) do
        local base_slots = prototype.module_inventory_size
        if base_slots > 0 then
            if not is_ignored_entity(prototype) then
                local max_slots = base_slots
                if prototype.quality_affects_module_slots then
                    max_slots = base_slots + storage.type_to_slot_bonus[prototype.type]
                end
                if base_slots and base_slots > 0 then
                    storage.name_to_slot_count[name] = max_slots
                    table.insert(storage.module_entities, name)
                    storage.max_slot_count = math.max(storage.max_slot_count, max_slots)
                    if storage.min_slot_count == 0 or storage.min_slot_count > base_slots then
                        storage.min_slot_count = base_slots
                    end
                end
            end
        end
    end
    storage.use_slot_count_target = (storage.min_slot_count ~= storage.max_slot_count)
end

local function remove_invalid_items()
    local removed_entities = {}
    local removed_recipes = {}
    local removed_modules = {}
    local removed_qualities = {}
    -- Possibly could take the first item from the quality prototypes instead of nil?
    local replacement_quality = prototypes.quality["normal"] and "normal" or nil

    --- @param preset PresetConfig
    local function _clean(preset)
        --- @param module_config ModuleConfigSet
        local function _clean_module_config(module_config)
            for _, mc in pairs(module_config.configs) do
                for i = #mc.module_list, 1, -1 do
                    local m = mc.module_list[i]
                    local name = m and m.module and m.module.name
                    ---@diagnostic disable-next-line
                    name = name or m and m.name -- For the older module list format
                    local quality = m and m.module and m.module.quality
                    ---@diagnostic disable-next-line
                    quality = m and m.quality
                    if name and not prototypes.item[name] then
                        removed_modules[name] = true
                        table.remove(mc.module_list, i)
                    elseif quality and not prototypes.quality[quality] then
                        removed_qualities[quality] = true
                        mc.module_list[i].module.quality = replacement_quality
                    end
                end
            end
        end
        _clean_module_config(preset.default)
        for _, row in pairs(preset.rows) do
            for i = #row.target.entities, 1, -1 do
                local target = row.target.entities[i]
                -- Checks both if an entity was removed, or if its module slots were removed
                if target and not storage.name_to_slot_count[target] then
                    removed_entities[target] = true
                    table.remove(row.target.entities, i)
                end
            end
            if row.target.recipes then
                for i = #row.target.recipes, 1, -1 do
                    local target = row.target.recipes[i]
                    if target and not prototypes.recipe[target.name] then
                        removed_recipes[target.name] = true
                        table.remove(row.target.recipes, i)
                    end
                end
            end
            _clean_module_config(row.module_configs)
        end
    end
    for _, pdata in pairs(storage._pdata) do
        _clean(pdata.active_config)
        for _, preset in pairs(pdata.saved_presets) do
            _clean(preset)
        end
    end
    for _, work in pairs(storage.delayed_work) do
        _clean(work.preset)
        work.entity_recipe_to_config_cache = {} -- clear the cache
    end
    for k in pairs(removed_entities) do
        log("Module Inserter: Removed Entity " .. k .. " from all configurations")
    end
    for k in pairs(removed_recipes) do
        log("Module Inserter: Removed Recipe " .. k .. " from all configurations")
    end
    for k in pairs(removed_modules) do
        log("Module Inserter: Removed module " .. k .. " from all configurations")
    end
    for k in pairs(removed_qualities) do
        log("Module Inserter: Removed Quality " .. k .. " from all configurations")
    end
end

local function init_global()
    storage.delayed_work = storage.delayed_work or {}
    storage.name_to_slot_count = storage.name_to_slot_count or {}
    storage._pdata = storage._pdata or {}
end

local function init_player(i)
    init_global()
    local pdata = storage._pdata[i] or {}
    local active_config = pdata.active_config or types.make_preset_config("Default Config")
    util.normalize_preset_config(active_config)
    storage._pdata[i] = {
        active_config = active_config,
        saved_presets = pdata.saved_presets or { active_config },
        gui = pdata.gui or {},
        pinned = false,
        cursor = false,
    }
    mi_gui.create(i)
end

local function init_players()
    for i, _ in pairs(game.players) do
        init_player(i)
    end
end

script.on_init(function()
    create_lookup_tables()
    init_global()
    init_players()
end)

script.on_load(function()
    if storage.nth_tick_registered then
        script.on_nth_tick(storage.nth_tick_registered, control.delayed_creation)
    end
end)


local function normalize_all_presets()
    for _, player in pairs(game.players) do
        local pdata = storage._pdata[player.index]
        for _, preset in pairs(pdata.saved_presets) do
            util.normalize_preset_config(preset)
        end
    end
    for _, work in pairs(storage.delayed_work) do
        util.normalize_preset_config(work.preset)
    end
end

local function migrate_to_v_7()
    -- Major update breaking compatibility - remove all storage and existing gui
    for _, player in pairs(game.players) do
        -- player.gui.top.mod_gui_top_frame.mod_gui_inner_frame.module_inserter_config_button
        local pdata = storage._pdata[player.index]
        if player.gui.top and player.gui.top.mod_gui_top_frame and player.gui.top.mod_gui_top_frame.mod_gui_inner_frame then
            local frame = player.gui.top.mod_gui_top_frame.mod_gui_inner_frame
            if frame.module_inserter_config_button and frame.module_inserter_config_button.valid then
                frame.module_inserter_config_button.destroy()
            end
        end
        if pdata.gui then
            if pdata.gui.main.window and pdata.gui.main.window.valid then
                pdata.gui.main.window.destroy()
            end
            if pdata.gui.import and pdata.gui.import.window and pdata.gui.import.window.valid then
                pdata.gui.import.window.destroy()
            end
        end
    end
    storage = {}
    create_lookup_tables()
    init_global()
    init_players()
end

script.on_configuration_changed(function(e)
    -- Special handling to do the major migration to v 7 first (nukes all player data)
    local changes = e.mod_changes[script.mod_name]
    local old_version = changes and changes.old_version
    if old_version and migration.is_newer_version(old_version, "7.0.0") then
        migrate_to_v_7()
    else
        create_lookup_tables()
    end

    remove_invalid_items()
    migration.on_config_changed(e, migrations)
    normalize_all_presets()
    -- Always remove/rebuild guis
    for pi, pdata in pairs(storage._pdata) do
        mi_gui.destroy(pdata, game.get_player(pi) --[[@as LuaPlayer]])
        mi_gui.create(pi)
    end
    update_on_tick_listener()
end)

script.on_event("toggle-module-inserter-ex", function(e)
    mi_gui.toggle(make_event_info(e))
end)
script.on_event("get-module-inserter-ex", get_module_inserter)
script.on_event(defines.events.on_lua_shortcut, function(e)
    if e.prototype_name == "miex-get-module-inserter" then
        get_module_inserter(e)
    elseif e.prototype_name == "miex-configure-module-inserter" then
        mi_gui.toggle(make_event_info(e))
    end
end)
script.on_event(defines.events.on_player_selected_area, on_player_selected_area)
script.on_event(defines.events.on_player_alt_selected_area, on_player_alt_selected_area)
script.on_event(defines.events.on_player_reverse_selected_area, on_player_reverse_selected_area)
script.on_event("module-inserter-ex-next-preset", function(e)
    cycle_active_preset(make_event_info(e), true)
end)
script.on_event("module-inserter-ex-previous-preset", function(e)
    cycle_active_preset(make_event_info(e), false)
end)
script.on_event(defines.events.on_runtime_mod_setting_changed, function(e)
    if e.setting == "module-inserter-ex-slots-before-alt-ui" then
        local player = game.get_player(e.player_index)
        if not player then return end
        local pdata = storage._pdata[e.player_index]
        mi_gui.update_module_config_table(player, pdata)
    end
end)

gui.handle_events()

--- @return table<string, fun(e: flib.GuiEventData)>
local function make_handler_table()
    handler_table = {}
    for group_name, group in pairs(mi_gui.handlers) do
        for name, func in pairs(group) do
            handler_table[group_name .. "_" .. name] = func
        end
    end
    return handler_table
end

gui.add_handlers(make_handler_table(), function(e, handler)
    handler(make_event_info(e))
end)

script.on_event(defines.events.on_player_created, function(e)
    init_player(e.player_index)
end)

script.on_event(defines.events.on_player_removed, function(e)
    storage._pdata[e.player_index] = nil
end)

remote.add_interface("ModuleInserterEx", {

    --- @param player int|LuaPlayer player index or LuaPlayer to source the config from
    --- @param entity string|LuaEntity Entity name or LuaEntity to get the config for
    --- @return (false|ItemIDAndQualityIDPair)[]? modules nil if no config for the given entity, or an array the same length as modules slots in the config,
    ---         with each index either an ItemIDAndQualityIDPair of the module to place there or false to leave that slot empty
    get_modules_for_entity = function(player, entity)
        if type(player) == "number" then player = game.players[player] end
        if not player or not player.valid then return end

        local ent_name
        local recipe
        if type(entity) == "string" then
            ent_name = entity
        else
            if not entity.valid then return end
            ent_name = util.get_entity_name(entity)
            recipe = util.recipe_pair_from_entity(entity)
        end

        ent_name = util.convert_entity_name(ent_name)

        local set_to_use = util.find_module_set_to_use_for_entity(ent_name, recipe,
            storage._pdata[player.index].active_config)
        if set_to_use == true then return end -- Don't set anything on this entity type
        module_config, messages = util.choose_module_config_from_set(ent_name, recipe, set_to_use)
        if not module_config then return end

        local module_list = module_config and module_config.module_list
        local module_count = storage.name_to_slot_count[ent_name]
        while #module_list > module_count do
            table.remove(module_list)
        end
        return module_config and module_config.module_list or nil
    end,

    --- @param player int|LuaPlayer player index or LuaPlayer to source the config from
    --- @param entity_list LuaEntity[] Array of entities to apply modules to
    apply_module_config_to_entities = function(player, entity_list)
        if type(player) == "number" then player = game.players[player] end
        if not player or not player.valid then return end

        -- Filter the entities we get to only valid ones
        local valid_types = {
            ["mining-drill"] = true,
            ["furnace"] = true,
            ["assembling-machine"] = true,
            ["lab"] = true,
            ["beacon"] = true,
            ["rocket-silo"] = true,
        }
        for key, entity in pairs(entity_list) do
            if not entity or not entity.valid then
                entity_list[key] = nil
            else
                if not valid_types[util.get_entity_type(entity)] then
                    entity_list[key] = nil
                end
            end
        end

        add_work_data(player.index, storage._pdata[player.index].active_config, entity_list)
    end

})
