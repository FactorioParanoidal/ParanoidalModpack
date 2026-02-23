minime.entered_file()

------------------------------------------------------------------------------------
--                              Remove the old GUIs!                              --
------------------------------------------------------------------------------------
-- We now use get_button_flow (toggle button) and get_frame_flow (character list).
do
  local gui
  minime.writeDebugNewBlock("Trying to remove old GUIs of players!")
  for p, player in pairs(game.players) do
    gui = player.gui and player.gui.top and player.gui.top["minime_gui"]
    if gui then
      gui.destroy()
      minime.writeDebug("Removed GUI of player %s!", {player.name or "nil"})
    end
  end
end

------------------------------------------------------------------------------------
--       We'd better include the mod name in the name of our dummy surface!       --
------------------------------------------------------------------------------------
do
  minime.writeDebugNewBlock("Trying to rename surfaces!")
  local old = "dummy_dungeon"
  local new = minime.dummy_surface

  if game.surfaces[old] and not game.surfaces[new] then

    -- Create surface
    --~ local surface = game.create_surface(new, {width = 1, height = 1})
    local surface = minime_surfaces.create_surface(new)
    minime.writeDebug("Created dummy surface %s!",
                      {minime.argprint(surface)}, "line")

    if surface and surface.valid then
      -- Clone dummy of each player
      local clone, dummy
      for p, p_data in pairs(storage.player_data or {}) do
        dummy = p_data.dummy
        if dummy and dummy.valid then
          clone = dummy.clone({
            position = dummy.position,
            surface = surface,
            force = dummy.force,
            create_build_effect_smoke = false,
          })

          -- If everything went fine, replace the old dummy in the table
          if clone then
            minime.writeDebug("Successfully cloned %s!", {minime.print_name_id(dummy)})
            minime.created_msg(clone)
            storage.player_data[p].dummy = clone
          else
            minime.writeDebug("Couldn't clone %s!", {minime.print_name_id(dummy)})
            error("Something went wrong!")
          end
        end
      end
      -- Remove old surface
      --~ game.delete_surface(old)
      minime_surfaces.delete_surface(old)
      minime.writeDebug("Removed surface %s!", {old})
    end
  end
end

------------------------------------------------------------------------------------
--                                Changes to global                               --
------------------------------------------------------------------------------------
if storage.player_data then
  local data

  minime.writeDebugNewBlock("Trying to remove obsolete table player_data.researched!")
  for player, p_data in pairs(game.players) do
    data = storage.player_data[player]

    -- Remove obsolete variables
    if data and data.researched then
      data.researched = nil
      minime.writeDebug("Removed table storage.player_data[%s].researched!",
                        {player})
    end
  end
end


minime.entered_file("leave")
