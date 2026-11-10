local table = require("__flib__.table")

require("milestones.util")
require("milestones.presets.presets")
require("milestones.presets.presets_pymods")
require("milestones.presets.preset_addons")

local schema = require("milestones.schema")
local builtin_presets = table.deep_copy(presets)
local builtin_addons = table.deep_copy(preset_addons)

local function ordered_names(values)
    local names = {}
    for name in pairs(values) do if type(name) == "string" then names[#names + 1] = name end end
    table.sort(names)
    return names
end

local function normalize_preset(preset)
    if type(preset) ~= "table" or getmetatable(preset) ~= nil then return nil end
    local required = schema.mod_names(preset.required_mods)
    local forbidden = schema.mod_names(preset.forbidden_mods, true)
    if not required or not forbidden then return nil end
    local milestones, err = validate_milestones(preset.milestones)
    if not milestones then return nil, err end
    return {required_mods = required, forbidden_mods = forbidden, milestones = milestones}
end

function is_preset_mods_enabled(preset)
    local forbidden_mods = preset.forbidden_mods or {}
    for _, mod_name in pairs(preset.required_mods) do
        if not script.active_mods[mod_name] then return false end
    end
    for _, mod_name in pairs(forbidden_mods) do
        if script.active_mods[mod_name] then return false end
    end
    return true
end

local function fetch_provider(interface_name, method, destination)
    local ok, supplied = pcall(remote.call, interface_name, method)
    if not ok or type(supplied) ~= "table" or getmetatable(supplied) ~= nil then
        local reason = not ok and tostring(supplied) or "expected a plain preset table"
        print_delayed_red({"milestones.message_preset_provider_error", interface_name, method, reason})
        return
    end
    for name in pairs(supplied) do
        if type(name) ~= "string" or name == "" then
            print_delayed_red({"milestones.message_preset_provider_error", interface_name, method, "invalid preset name"})
        end
    end
    for _, name in ipairs(ordered_names(supplied)) do
        if name ~= "" then
            local preset, err = normalize_preset(supplied[name])
            if preset then
                if destination[name] then log("Preset " .. name .. " overridden by " .. interface_name) end
                destination[name] = preset
            else
                print_delayed_red({"", {"milestones.message_preset_provider_error", interface_name, name, "invalid preset"}, " ", err or ""})
            end
        end
    end
end

function fetch_remote_presets()
    storage.remote_presets, storage.remote_preset_addons = {}, {}
    local interfaces = remote.interfaces
    for _, name in ipairs(ordered_names(interfaces)) do
        local functions = interfaces[name]
        if functions.milestones_presets then fetch_provider(name, "milestones_presets", storage.remote_presets) end
        if functions.milestones_preset_addons then fetch_provider(name, "milestones_preset_addons", storage.remote_preset_addons) end
    end
end

local function rebuild_table(destination, builtin, supplied)
    for name in pairs(destination) do destination[name] = nil end
    for name, preset in pairs(builtin) do destination[name] = table.deep_copy(preset) end
    for _, name in ipairs(ordered_names(supplied or {})) do
        local preset = normalize_preset(supplied[name])
        if preset then destination[name] = preset end
    end
end

function add_remote_presets_to_preset_tables()
    -- Local tables only: safe in on_load, and removed providers leave no stale local presets.
    rebuild_table(presets, builtin_presets, storage.remote_presets)
    rebuild_table(preset_addons, builtin_addons, storage.remote_preset_addons)
end

function get_auto_detected_preset_name()
    local chosen_preset_name
    local max_nb_mods_matched = -1
    for _, preset_name in pairs(storage.valid_preset_names) do
        local preset = presets[preset_name]
        if preset and #preset.required_mods > max_nb_mods_matched then
            max_nb_mods_matched = #preset.required_mods
            chosen_preset_name = preset_name
        end
    end
    return chosen_preset_name
end

function load_presets()
    storage.valid_preset_names = {"Empty"}

    for preset_name, preset in pairs(presets) do
        if is_preset_mods_enabled(preset) then
            table.insert(storage.valid_preset_names, preset_name)
        end
    end
    table.sort(storage.valid_preset_names)
    log("Valid presets found: " .. serpent.line(storage.valid_preset_names))

    if storage.current_preset_name == nil then
        storage.current_preset_name = get_auto_detected_preset_name()
        log("Auto-detected preset used: " .. storage.current_preset_name)
        storage.loaded_milestones = table.deep_copy(presets[storage.current_preset_name].milestones)
    end
end

function load_preset_addons()
    local preset_addons_loaded = {}
    for _, preset_addon_name in ipairs(ordered_names(preset_addons)) do
        local preset_addon = preset_addons[preset_addon_name]
        if is_preset_mods_enabled(preset_addon) then
            table.insert(preset_addons_loaded, preset_addon_name)
            for _, milestone in pairs(preset_addon.milestones) do
                table.insert(storage.loaded_milestones, table.deep_copy(milestone))
            end
        end
    end
    log("Preset addons loaded: " .. serpent.line(preset_addons_loaded))

    storage.default_milestones_snapshot = table.deep_copy(storage.loaded_milestones)
end

function reload_presets()
    log("Reloading presets")
    local added_presets = {}
    local new_valid_preset_names = {"Empty"}

    for preset_name, preset in pairs(presets) do
        if is_preset_mods_enabled(preset) then
            table.insert(new_valid_preset_names, preset_name)
            if not table_contains(storage.valid_preset_names, preset_name) then
                table.insert(added_presets, preset_name)
            end
        end
    end
    table.sort(new_valid_preset_names)
    table.sort(added_presets)
    storage.valid_preset_names = new_valid_preset_names
    log("New presets found: " .. serpent.line(added_presets))
    log("New list of valid presets: " .. serpent.line(storage.valid_preset_names))
    if #added_presets == 1 then
        table.insert(storage.delayed_chat_messages, {"milestones.message_reloaded_presets_singular", added_presets[1]})
    elseif #added_presets > 1 then
        table.insert(storage.delayed_chat_messages, {"milestones.message_reloaded_presets_plural", table.concat(added_presets, ", ")})
    end
    return added_presets
end

-- Paranoidal: the milestones a preset loads in on_init: the preset plus every enabled addon.
local function get_default_milestones_for_preset(preset_name)
    local milestones = table.deep_copy(presets[preset_name].milestones)
    for _, name in ipairs(ordered_names(preset_addons)) do
        local preset_addon = preset_addons[name]
        if is_preset_mods_enabled(preset_addon) then
            for _, milestone in pairs(preset_addon.milestones) do
                table.insert(milestones, table.deep_copy(milestone))
            end
        end
    end
    return milestones
end

local function is_unmodified_preset(current_name)
    local baseline = storage.default_milestones_snapshot or get_default_milestones_for_preset(current_name)
    local current = validate_milestones(storage.loaded_milestones)
    local expected = validate_milestones(baseline)
    return current ~= nil and expected ~= nil and table.deep_compare(current, expected)
end

-- Paranoidal: when a mod update adds a preset that auto-detection now prefers (e.g. "Paranoidal"
-- over "Vanilla"), switch existing saves to it, but only if the current set was never edited, i.e.
-- it still equals the old preset plus the enabled addons. Completed milestones keep their times
-- (merge_new_milestones), new ones are backfilled from statistics. Upstream only printed a hint.
function upgrade_unmodified_preset(added_presets)
    if not added_presets or #added_presets == 0 then return end
    local current_name = storage.current_preset_name
    if current_name == nil or presets[current_name] == nil then return end -- "Imported", "Empty", removed
    local best_name = get_auto_detected_preset_name()
    if best_name == nil or best_name == current_name or not table_contains(added_presets, best_name) then return end
    if not is_unmodified_preset(current_name) then
        log("Preset " .. current_name .. " was modified, not switching to " .. best_name)
        return
    end

    log("Switching unmodified preset " .. current_name .. " to " .. best_name)
    local new_milestones = get_default_milestones_for_preset(best_name)
    storage.current_preset_name = best_name
    storage.loaded_milestones = table.deep_copy(new_milestones)
    storage.default_milestones_snapshot = table.deep_copy(new_milestones)
    storage.milestones_revision = (storage.milestones_revision or 0) + 1
    initialize_alias_table()
    remove_invalid_aliases()
    local backfilled_anything = false
    for force_name, force in pairs(game.forces) do
        if storage.forces[force_name] ~= nil then
            merge_new_milestones(force_name, new_milestones)
            remove_invalid_milestones_for_force(storage.forces[force_name])
            backfilled_anything = backfill_completion_times(force) or backfilled_anything
        end
    end
    table.insert(storage.delayed_chat_messages, {"milestones.message_loaded_presets", best_name})
    if backfilled_anything then
        table.insert(storage.delayed_chat_messages, {"milestones.message_loaded_into_exiting_game"})
    end
    for _, player in pairs(game.players) do
        if storage.players[player.index] then
            refresh_gui_for_player(player)
        end
    end
end
