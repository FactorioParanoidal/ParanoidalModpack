local migrations = {}

--- @param e ConfigurationChangedData
function migrations.on_configuration_changed(e)
  local rcalc_changes = e.mod_changes[script.mod_name]
  if not rcalc_changes then
    return
  end

  local old_version = rcalc_changes.old_version
  if not old_version or helpers.compare_versions(old_version, "3.0.0") >= 0 then
    return
  end

  for _, player in pairs(game.players) do
    for _, child in pairs(player.gui.screen.children) do
      if child.get_mod() == "RateCalculator" then
        child.destroy()
      end
    end
  end
  global = { gui = {} }
end

return migrations
