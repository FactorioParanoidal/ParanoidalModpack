local table = require("__flib__.table")

function initialize_force_if_needed(force)
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
end

function clear_player(player_index)
    storage.players[player_index] = nil
end
