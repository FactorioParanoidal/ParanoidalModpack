function debug_print_forces()
    game.print(serpent.block(global.forces))
    log(serpent.block(global.forces))
end
commands.add_command("milestones-debug-print-forces", {"milestones.commands.debug-print-forces"}, debug_print_forces)

function debug_print_loaded_milestones()
    game.print(serpent.block(global.loaded_milestones))
    log(serpent.block(global.loaded_milestones))
end
commands.add_command("milestones-debug-print-loaded-milestones", {"milestones.commands.debug-print-loaded-milestones"}, debug_print_loaded_milestones)

function debug_set_milestones_time(command_data)
    local force = game.get_player(command_data.player_index).force
    local global_force = global.forces[force.name]
    local parameters = {}
    for k, v in string.gmatch(command_data.parameter, "([^,]+)") do
        table.insert(parameters, k)
    end
    local name = parameters[1]
    local lower_bound_tick = tonumber(parameters[2])
    local tick = tonumber(parameters[3])
    local i = 1
    while i <= #global_force.incomplete_milestones do
        local milestone = global_force.incomplete_milestones[i]
        if milestone.name == name then
            mark_milestone_reached(global_force, milestone, tick, i, lower_bound_tick)
            refresh_gui_for_force(force)
            game.print("Milestone set.")
            return
        end
        i = i + 1
    end
    game.print("Milestone not found.")
end
commands.add_command("milestones-debug-set-milestone-time", {"milestones.commands.debug-set-milestone-time"}, debug_set_milestones_time)

function reinitialize_gui(command_data)
    reinitialize_player(command_data.player_index)
end
commands.add_command("milestones-reinitialize-gui", {"milestones.commands.reinitialize-gui"}, reinitialize_gui)

function reinitialize_global()
    for _, force in pairs(game.forces) do
        initialize_force_if_needed(force)
    end

    for _, player in pairs(game.players) do
        reinitialize_player(player.index)
    end
end
commands.add_command("milestones-reinitialize-global", {"milestones.commands.reinitialize-global"}, reinitialize_global)
