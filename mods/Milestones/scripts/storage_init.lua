local table = require("__flib__.table")

-- Paranoidal: Blueprint Sandboxes moves the player into a temporary force "bpsb-sb-f-<force>".
-- Upstream tracked it as a separate force forever (full milestone list, backfill, polling).
-- These forces are not tracked; their players see the milestones of the parent force.
local SANDBOX_FORCE_PREFIX = "bpsb-sb-"
local SANDBOX_FORCE_PATTERN = "^bpsb%-sb%-f%-(.+)$"

function is_ignored_force_name(force_name)
    return script.active_mods["blueprint-sandboxes"] ~= nil
        and string.sub(force_name, 1, #SANDBOX_FORCE_PREFIX) == SANDBOX_FORCE_PREFIX
end

-- Returns storage_force, LuaForce whose milestones this force's players see (nil, nil if none).
function get_display_storage_force(force)
    local storage_force = storage.forces[force.name]
    if storage_force then return storage_force, force end
    if is_ignored_force_name(force.name) then
        local parent_name = string.match(force.name, SANDBOX_FORCE_PATTERN)
        local parent = parent_name and game.forces[parent_name]
        if parent and storage.forces[parent_name] then
            return storage.forces[parent_name], parent
        end
    end
    return nil, nil
end

-- Players of the sandbox force of `force` (they look at the parent force's milestones).
function get_sandbox_force(force)
    if not script.active_mods["blueprint-sandboxes"] then return nil end
    return game.forces[SANDBOX_FORCE_PREFIX .. "f-" .. force.name]
end

function remove_ignored_forces()
    for force_name, _ in pairs(storage.forces) do
        if is_ignored_force_name(force_name) then
            log("Removing storage for ignored force " .. force_name)
            storage.forces[force_name] = nil
        end
    end
end

-- Paranoidal: the periodic tracker keeps a snapshot of what it reads (see tracker.lua).
-- Any structural change restarts it at the next cycle boundary.
function reset_milestones_tracker()
    storage.tracker = nil
end

function initialize_force_if_needed(force)
    if is_ignored_force_name(force.name) then return false end
    if storage.forces[force.name] == nil and next(force.players) ~= nil then -- Don't bother with forces without players
        log("Initializing storage for force " .. force.name)
        local storage_force = {
            complete_milestones = {},
            incomplete_milestones = {},
            milestones_by_group = {},
            item_stats = {},
            fluid_stats = {},
            kill_stats = {},
        }

        storage.forces[force.name] = storage_force
        reset_milestones_tracker()

        add_flow_statistics_to_storage_force(force)

        local current_group = "Other"
        for i, loaded_milestone in pairs(storage.loaded_milestones) do
            if loaded_milestone.type == "group" then
                current_group = loaded_milestone.name
            elseif loaded_milestone.type ~= "alias" then
                local inserted_milestone = table.deep_copy(loaded_milestone)
                inserted_milestone.sort_index = i
                inserted_milestone.group = current_group
                storage_force.milestones_by_group[current_group] = storage_force.milestones_by_group[current_group] or {}
                -- Intentionally insert the same reference in both tables
                table.insert(storage_force.incomplete_milestones, inserted_milestone)
                table.insert(storage_force.milestones_by_group[current_group], inserted_milestone)
            end
        end
        remove_invalid_milestones_for_force(storage_force)
        return backfill_completion_times(force)
    end
    return false
end

function add_flow_statistics_to_storage_force(force)
    local storage_force = storage.forces[force.name]
    for surface_name, _surface in pairs(game.surfaces) do
        -- TODO: Check for surfaces that the force has not built on and skip them?
        table.insert(storage_force.item_stats, force.get_item_production_statistics(surface_name))
        table.insert(storage_force.fluid_stats, force.get_fluid_production_statistics(surface_name))
        table.insert(storage_force.kill_stats, force.get_kill_count_statistics(surface_name))
    end
end

function reinitialize_player(player_index)
    local storage_player = storage.players[player_index]
    if storage_player then
        local outer_frame = storage_player.outer_frame
        if outer_frame.valid then
            outer_frame.destroy()
        end
    end
    local player = game.get_player(player_index)
    if player then
        initialize_player(player)
    end
end

function initialize_player(player)
    local outer_frame, main_frame, inner_frame = build_gui_frames(player)
    storage.players[player.index] = {
        outer_frame = outer_frame,
        main_frame = main_frame,
        inner_frame = inner_frame,
        opened_once_before = false,
        pinned = false
    }
end

function clear_force(force_name)
    storage.forces[force_name] = nil
    reset_milestones_tracker()
end

function clear_player(player_index)
    storage.players[player_index] = nil
end
