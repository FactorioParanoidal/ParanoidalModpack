local table = require("__flib__.table")

function initialize_force_if_needed(force)
    if global.forces[force.name] == nil and next(force.players) ~= nil then -- Don't bother with forces without players
        log("Initializing global for force " .. force.name)
        global_force = {
            complete_milestones = {},
            incomplete_milestones = {},
            milestones_by_group = {},
            item_stats = force.item_production_statistics,
            fluid_stats = force.fluid_production_statistics,
            kill_stats = force.kill_count_statistics,
        }
        global.forces[force.name] = global_force

        local current_group = "Other"
        for i, loaded_milestone in pairs(global.loaded_milestones) do
            if loaded_milestone.type == "group" then
                current_group = loaded_milestone.name
            elseif loaded_milestone.type ~= "alias" then
                local inserted_milestone = table.deep_copy(loaded_milestone)
                inserted_milestone.sort_index = i
                inserted_milestone.group = current_group
                global_force.milestones_by_group[current_group] = global_force.milestones_by_group[current_group] or {}
                -- Intentionally insert the same reference in both tables
                table.insert(global_force.incomplete_milestones, inserted_milestone)
                table.insert(global_force.milestones_by_group[current_group], inserted_milestone)
            end
        end
        remove_invalid_milestones_for_force(global_force)
        return backfill_completion_times(force)
    end
    return false
end

function reinitialize_player(player_index)
    local outer_frame = global.players[player_index].outer_frame
    if outer_frame.valid then
        outer_frame.destroy()
    end
    local player = game.get_player(player_index)
    initialize_player(player)
end

function initialize_player(player)
    local outer_frame, main_frame, inner_frame = build_gui_frames(player)
    global.players[player.index] = {
        outer_frame = outer_frame,
        main_frame = main_frame,
        inner_frame = inner_frame,
        opened_once_before = false,
        pinned = false
    }
end

function clear_force(force_name)
    global.forces[force_name] = nil
end

function clear_player(player_index)
    global.players[player_index] = nil
end
