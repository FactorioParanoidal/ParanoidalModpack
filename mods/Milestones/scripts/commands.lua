function debug_print_forces()
  game.print(serpent.block(storage.forces))
  log(serpent.block(storage.forces))
end
commands.add_command("milestones-debug-print-forces",
  "- Print the mod's internal storage table, for debugging purposes.",
  debug_print_forces)

function debug_print_loaded_milestones()
  game.print(serpent.block(storage.loaded_milestones))
  log(serpent.block(storage.loaded_milestones))
end
commands.add_command("milestones-debug-print-loaded-milestones",
  "- Print the json of loaded milestones. Same as the \"export\" string available in settings.",
  debug_print_loaded_milestones)

function debug_set_milestones_time(command_data)
  if not command_data.parameter then return end
  local force = game.get_player(command_data.player_index).force
  local storage_force = storage.forces[force.name]
  local parameters = {}
  for word in string.gmatch(command_data.parameter, "([^,]+)") do -- Split comma-seperated string
    table.insert(parameters, word)
  end
  local name = parameters[1]
  local lower_bound_tick = tonumber(parameters[2])
  local tick = tonumber(parameters[3])
  local i = 1
  while i <= #storage_force.incomplete_milestones do
    local milestone = storage_force.incomplete_milestones[i]
    if milestone.name == name then
      mark_milestone_reached(storage_force, milestone, tick, i, lower_bound_tick)
      refresh_gui_for_force(force)
      game.print("Milestone set.")
      return
    end
    i = i + 1
  end
  game.print("Milestone not found.")
end
commands.add_command("milestones-set-milestone-time",
"- Manually set a time for a milestone. Usage: milestone_name,lower_bound_tick,tick. Example: `/milestones-set-milestone-time iron-plate,600,6000` will set the iron-plate milestone time to be between 10 seconds and 100 seconds.",
  debug_set_milestones_time)

function debug_reset_milestones(command_data)
  if not command_data.parameter then return end
  local force = game.get_player(command_data.player_index).force
  local storage_force = storage.forces[force.name]
  local name = command_data.parameter
  local i = 1
  while i <= #storage_force.complete_milestones do
    local milestone = storage_force.complete_milestones[i]
    if milestone.name == name then
      mark_milestone_unreached(storage_force, milestone, i)
      refresh_gui_for_force(force)
      game.print("Milestone reset.")
      return
    end
    i = i + 1
  end
  game.print("Milestone not found.")
end
commands.add_command("milestones-reset-milestone",
"- Manually reset a milestone. Usage: milestone_name. Example: `/milestones-reset-milestone iron-plate` will reset the iron-plate milestone.",
  debug_reset_milestones)

function reinitialize_gui(command_data)
  if not command_data.player_index then return end
  reinitialize_player(command_data.player_index)
end
commands.add_command("milestones-reinitialize-gui",
  "- Reset the mod's internal variables related to the GUI, only for the player using the command. Try this if you experience GUI-related crashes.",
  reinitialize_gui)


function reinitialize_surfaces()
  for force_name, storage_force in pairs(storage.forces) do
    local force = game.forces[force_name]
    if force then
      storage_force.item_stats = {}
      storage_force.fluid_stats = {}
      storage_force.kill_stats = {}
      add_flow_statistics_to_storage_force(force)
      backfill_completion_times(force)
      force.print("Done. Incomplete milestones were estimated.")
    end
  end
end
commands.add_command("milestones-reinitialize-surfaces",
  "- Reset the mod's tracking of surfaces and estimate incomplete milestones. Try this if some milestones didn't trigger for you when you would expect it (and please report this issue).",
  reinitialize_surfaces)

function reinitialize_storage()
  for _, force in pairs(game.forces) do
    initialize_force_if_needed(force)
  end

  for _, player in pairs(game.players) do
    reinitialize_player(player.index)
  end
end
commands.add_command("milestones-reinitialize-storage",
  "- Reset all of the mod's internal variables (except achieved milestones) for all players. Try this as a last resort.",
  reinitialize_storage)
