local table = require("__flib__.table")

require("scripts.util")
require("presets.presets")
require("presets.presets_pymods")
require("presets.preset_addons")

local function validate_milestone_presets(interface_name, presets_to_validate, existing_table)
    local valid = true
    if type(presets_to_validate) ~= "table" then
        print_delayed_red("Interface " .. interface_name .. " should return a table.")
        valid = false
    else
        for preset_name, preset in pairs(presets_to_validate) do
            if type(preset_name) ~= "string" then
                print_delayed_red("Interface " .. interface_name .. " should return a table with named keys.")
                valid = false
                break
            end
            if existing_table[preset_name] then
                log("Preset " .. preset_name .. " already exists. Overriding.")
            end
            if not preset.required_mods then
                print_delayed_red("Preset " .. preset_name .. " is missing a `required_mods` value.")
                valid = false
            end
            if not preset.milestones then
                print_delayed_red("Preset " .. preset_name .. " is missing a `milestones` value.")
                valid = false
            else
                _, error = validate_milestones(preset.milestones)
                if error then
                    print_delayed_red({"", "Preset ", preset_name, ": ", error})
                    valid = false
                end
            end
        end
    end
    if not valid then
        print_delayed_red("[img=utility/danger_icon] Please warn the mod author for " .. interface_name .. " about the errors above.")
    end
    return valid
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

local function validate_and_add_to_preset_table(interface_name, remote_milestones_presets, existing_table)
    if validate_milestone_presets(interface_name, remote_milestones_presets, existing_table) then
        ---@cast remote_milestones_presets table
        for remote_preset_name, remote_preset in pairs(remote_milestones_presets) do
            existing_table[remote_preset_name] = remote_preset
        end
    end
end

function fetch_remote_presets()
    -- See presets.lua to find out how to use these reverse remote interface to add your own preset or preset addon.
    storage.remote_presets = {}
    storage.remote_preset_addons = {}
    for interface_name, functions in pairs(remote.interfaces) do
        if functions["milestones_presets"] then
            local remote_milestones_presets = remote.call(interface_name, "milestones_presets")
            validate_and_add_to_preset_table("milestones_presets", remote_milestones_presets, storage.remote_presets)
        end
        if functions["milestones_preset_addons"] then
            local remote_milestones_presets = remote.call(interface_name, "milestones_preset_addons")
            validate_and_add_to_preset_table("milestones_preset_addons", remote_milestones_presets, storage.remote_preset_addons)
        end
    end
end

function add_remote_presets_to_preset_tables()
    if storage.remote_presets then -- Should always be set in on_init, but just for migration safety
        for remote_preset_name, remote_preset in pairs(storage.remote_presets) do
            presets[remote_preset_name] = remote_preset
        end
    end
    if storage.remote_preset_addons then
        for remote_preset_name, remote_preset in pairs(storage.remote_preset_addons) do
            preset_addons[remote_preset_name] = remote_preset
        end
    end
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
    log("Valid presets found: " .. serpent.line(storage.valid_preset_names))

    if storage.current_preset_name == nil then
        storage.current_preset_name = get_auto_detected_preset_name()
        log("Auto-detected preset used: " .. storage.current_preset_name)
        -- Paranoidal: no chat message about the auto-detected preset.
        -- table.insert(storage.delayed_chat_messages, {"milestones.message_loaded_presets", storage.current_preset_name})
        storage.loaded_milestones = table.deep_copy(presets[storage.current_preset_name].milestones)
    end
end

function load_preset_addons()
    local preset_addons_loaded = {}
    for preset_addon_name, preset_addon in pairs(preset_addons) do
        if is_preset_mods_enabled(preset_addon) then
            table.insert(preset_addons_loaded, preset_addon_name)
            for _, milestone in pairs(preset_addon.milestones) do
                table.insert(storage.loaded_milestones, milestone)
            end
        end
    end
    log("Preset addons loaded: " .. serpent.line(preset_addons_loaded))

    -- Paranoidal: no chat message about loaded preset addons.
    -- if #preset_addons_loaded == 1 then
    --     table.insert(storage.delayed_chat_messages, {"milestones.message_loaded_preset_addons_singular", preset_addons_loaded[1]})
    -- elseif #preset_addons_loaded > 1 then
    --     table.insert(storage.delayed_chat_messages, {"milestones.message_loaded_preset_addons_plural", table.concat(preset_addons_loaded, ", ")})
    -- end
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
    for _, preset_addon in pairs(preset_addons) do
        if is_preset_mods_enabled(preset_addon) then
            for _, milestone in pairs(preset_addon.milestones) do
                table.insert(milestones, table.deep_copy(milestone))
            end
        end
    end
    return milestones
end

local function count_milestone_signatures(milestones)
    local counts = {}
    for _, milestone in pairs(milestones) do
        local signature = serpent.line(milestone, {sortkeys = true, comment = false})
        counts[signature] = (counts[signature] or 0) + 1
    end
    return counts
end

local function is_same_milestone_multiset(a, b)
    if #a ~= #b then return false end
    local counts_a, counts_b = count_milestone_signatures(a), count_milestone_signatures(b)
    for signature, count in pairs(counts_a) do
        if counts_b[signature] ~= count then return false end
    end
    return true
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
    if not is_same_milestone_multiset(storage.loaded_milestones, get_default_milestones_for_preset(current_name)) then
        log("Preset " .. current_name .. " was modified, not switching to " .. best_name)
        return
    end

    log("Switching unmodified preset " .. current_name .. " to " .. best_name)
    local new_milestones = get_default_milestones_for_preset(best_name)
    storage.current_preset_name = best_name
    storage.loaded_milestones = table.deep_copy(new_milestones)
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
