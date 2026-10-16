local function print_vegetation_disabled_warning(event)
  if not script.active_mods["nullius"] and settings.startup["alien-biomes-disable-vegetation"].value == "Enabled" then
    game.print({"alien-biomes.vegetation-disabled-warning"})
  end
end
-- Called when the starting cutscene ends or is skipped
script.on_event(defines.events.on_cutscene_cancelled, print_vegetation_disabled_warning)
