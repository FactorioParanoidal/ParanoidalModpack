minime.entered_file()

local minime_surfaces = {}

local CHAR_NAME_START_POS = string.len(minime.preview_surface_name_prefix) + 1
local new_surface_properties = {
  always_day              = true,
  generate_with_lab_tiles = true,
  no_enemies_mode         = true,
  peaceful_mode           = true,
  --~ deletable               = false,    -- READ ONLY
  show_clouds             = false,
  --~ pollutant_type          = "nil",    -- READ ONLY
  wind_speed              = 0,
}
local map_gen_settings = {
  width = 1,
  height = 1,
  autoplace_controls = {},
  autoplace_settings = {},
  default_enable_all_autoplace_controls = false,
  cliff_settings = nil,
  peaceful_mode = true,
  property_expression_names = {},
  seed = 0,
  starting_area = 0,
  starting_points = {},
  terrain_segmentation = 1,
  water = 0,
}

------------------------------------------------------------------------------------
--     Create a preview character (and surface, if necessary) for all players     --
------------------------------------------------------------------------------------
local function restore_preview_characters(char_name)
  minime.entered_function({char_name})

  if not minime.character_selector then
    minime.entered_function({}, "leave", "Character selector is not active!")
    return
  end

  minime.assert(char_name, "string", "name of character prototype")

  local c_data = mod.minime_characters and
                  mod.minime_characters[char_name] or
                  minime.arg_err(char_name, "character prototype")

minime.show(char_name, c_data)
  if not (c_data.preview and
          c_data.preview.surface and c_data.preview.surface.valid) then
    minime.writeDebug("Must initialize mod.minime_character[%s].preview!",
                      {char_name})
    minime_character.initialize_character_preview(char_name)
  end

  local surface = c_data.preview and c_data.preview.surface
  local chars = c_data.preview and c_data.preview.entities
  local offset = 10


  local player_chars, p_data, pos

  for p, player in pairs(game.players) do
    p_data = mod.player_data[p]
    player_chars = p_data and p_data.available_characters
minime.show("player_chars", player_chars)

    if player_chars[char_name] then
      -- We make sure that preview characters of different players don't overlap by
      -- using the player index to determine the character position
      pos = {(p * offset) - offset, 0}
      chars[p] = surface.create_entity({
        name = char_name,
        position = pos,
        force = player.force,
        direction = defines.direction.south,
      })
      minime.writeDebug("Created preview %s for player %s!",
                        {minime.argprint(chars[p]), minime.argprint(p)})

      if chars[p] and chars[p].valid then
        chars[p].active = false
        minime.writeDebug("Made %s inactive!", {minime.argprint(chars[p])})
      end

      -- Make sure the preview character has the same armor as the player's current
      -- character, so that it will really reflect the player's appearance!
      if player.character then
        minime.writeDebug("Updating armor of preview character!")
        minime_player.update_armor({player_index = p, character = char_name})
      end
    end
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                               Create new surface                               --
------------------------------------------------------------------------------------
minime_surfaces.create_surface = function(surface_name, flags)
  minime.entered_function({surface_name, flags})

  minime.assert(surface_name, "string", "surface name")
  minime.assert(flags, {"table", "nil"}, "table of flags, or nil")

  local surface = game.get_surface(surface_name)

  -- When we create surfaces while initializing the game we will skip the call to
  -- minime_surfaces.hide_surface. We will call that function once all surfaces have
  -- been created.
  local dont_hide = flags and flags.dont_hide

  minime.writeDebugNewBlock("Create surface %s?", {minime.enquote(surface_name)})
  if surface and surface.valid then
    minime.writeDebug("No: surface already exists!")

  else
    --~ minime.writeDebug("Yes!")
    minime.writeDebug("Yes: Trying to blacklist surface %s with other mods!",
                      {minime.argprint(surface_name)})
    minime_surfaces.blacklist_surface(surface_name)

    minime.writeDebugNewBlock("Trying to create surface!")
    surface = game.create_surface(surface_name, map_gen_settings)
    minime.writeDebug("Created %s!", {minime.argprint(surface)})

    if surface and surface.valid then
      -- Adjust some properties
      minime.writeDebugNewBlock("Trying to set surface properties!")
      for p_name, p in pairs(new_surface_properties) do
        if surface[p_name] == p then
          minime.writeDebug("Ignoring property %s!", {minime.enquote(p_name)})
        elseif p == "nil" then
          surface[p_name] = nil
          minime.modified_msg(p_name, surface, "Removed")
        else
          surface[p_name] = p
          minime.modified_msg(p_name, surface)
        end
      end
      --~ minime.writeDebugNewBlock("Trying to blacklist surface with other mods!")
      --~ minime_surfaces.blacklist_surface(surface.name)
    end
  end

  minime.writeDebugNewBlock("Hide surface?")
  if dont_hide then
    minime.writeDebug("No: forbidden by flag!")

  elseif surface and surface.valid then
    minime.writeDebug("Yes!")
    -- Calling function with just the surface name will hide it to all forces!
    minime_surfaces.hide_surface(surface)
  else
    minime.writeDebug("No: %s surface!", {surface and "not a valid" or "no"})
  end


  minime.entered_function("leave")
  return surface
end


------------------------------------------------------------------------------------
--                     Mark surface for removal and delete it                     --
------------------------------------------------------------------------------------
minime_surfaces.delete_surface = function(surface)
  minime.entered_function({surface})

  surface = minime.ascertain_surface(surface)

  if surface and surface.valid and minime.prefixed(surface.name, minime.modName) then

    -- Set flag so that we'll ignore on_surface_deleted and don't restore things!
    mod.deleted_surfaces = mod.deleted_surfaces or {}
    mod.deleted_surfaces[surface.index] = surface.name

    -- Delete surface
    minime.writeDebug("Removing %s!", {minime.argprint(surface)})
    game.delete_surface(surface)

    --------------------------------------------------------------------------------
    --  The surface will be removed on a later tick, so we will whitelist it when --
    --  on_surface_deleted is raised for it!
    --------------------------------------------------------------------------------
    --~ -- Whitelist surface with other mods
    --~ minime.writeDebug("Whitelisting %s with other mods!",
                      --~ {minime.argprint(surface)})
    --~ minime_surfaces.whitelist_surface(surface)
    --------------------------------------------------------------------------------
  else
    minime.writeDebug("Nothing to do: %s is not a valid surface!",
                      {minime.argprint(surface)})
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                         Hide preview and dummy surfaces                        --
------------------------------------------------------------------------------------
minime_surfaces.hide_surface = function(surface_or_id, force_or_id)
  minime.entered_function({surface_or_id, force_or_id})

  local surfaces, forces
  do
    -- Use specified surface?
    minime.writeDebugNewBlock("Did we get a surface specification?")
    if surface_or_id then
      minime.writeDebug("Yes! Does it resolve to a valid surface?")
      local surface = minime.ascertain_surface(surface_or_id)
      -- We'll hide just this one surface!
      if surface and surface.valid then
        minime.writeDebug("Yes!")
        surfaces = {surface}
      -- Error: not a valid surface!
      else
        minime.writeDebug("No!")
        minime.arg_err(surface_or_id, "reference to a valid surface")
      end

    -- surface_or_id is nil
    else
      minime.writeDebug("No!")
    end

    -- Use specified force?
    minime.writeDebugNewBlock("Did we get a force specification?")
    if force_or_id then
      minime.writeDebug("Yes! Does it resolve to a valid force?")
      local force = minime.ascertain_force(force_or_id)
      -- We'll hide the surface(s) for just this one force!
      if force and force.valid then
        minime.writeDebug("Yes!")
        forces = force and force.valid and {force}
      -- Error: not a valid force!
      else
        minime.writeDebug("No!")
        minime.arg_err(force_or_id, "reference to a valid force")
      end

    -- force_or_id is nil
    else
      minime.writeDebug("No!")
    end
minime.show("surfaces", surfaces)
minime.show("forces", forces)

    -- Use all our surfaces if none has been specified
    if not surfaces then
      minime.writeDebugNewBlock("Compiling list of surfaces to hide!")
      local s

      surfaces = { game.get_surface(minime.dummy_surface), }
      for c_name, c_data in pairs(mod.minime_characters or minime.EMPTY_TAB) do
        s = c_data.preview and c_data.preview.surface
        if s and s.valid then
          minime.writeDebug("Adding %s!", {minime.argprint(s)})
          table.insert(surfaces, s)
        else
          minime.writeDebug("Ignoring surface for previews of \"%s\"!", {c_name})
        end
      end
    end
minime.show("surfaces", surfaces)

    -- Use all forces if none has been specified
    if not forces then
      minime.writeDebugNewBlock("Compiling list of forces!")
      forces = {}

      for f_name, force in pairs(game.forces) do
        table.insert(forces, force)
      end
    end
minime.show("forces", forces)
  end


  -- Hide the surfaces!
  do
    if #surfaces > #forces then
      for f, force in pairs(forces) do
        if force.valid then
          minime.writeDebugNewBlock("Hiding these surfaces from %s:",
                                    {minime.argprint(force)})
          for s, surface in pairs(surfaces) do
            if surface.valid then
              minime.writeDebug("%s", {minime.argprint(surface)})
              force.set_surface_hidden(surface, true)
            end
          end
        end
      end

    else
      for s, surface in pairs(surfaces) do
        if surface.valid then
          minime.writeDebugNewBlock("Hiding %s from these forces:",
                                    {minime.argprint(surface)})

          for f, force in pairs(forces) do
            if force.valid then
              minime.writeDebug("%s", {minime.argprint(force)})
              force.set_surface_hidden(surface, true)
            end
          end
        end
      end
    end
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
-- A surface is about to be deleted. Store its index if it's one of our surfaces! --
------------------------------------------------------------------------------------
minime_surfaces.on_pre_surface_deleted = function(event)
  minime.entered_function({event})

  local surface = game.surfaces[event.surface_index]
  local index, name = surface.index, surface.name

  -- We've deleted the surface ourselves!
  if mod.deleted_surfaces and mod.deleted_surfaces[index] then
    minime.writeDebug("%s was marked for deletion!", {minime.argprint(surface)})

  -- Some other mod destroyed one of our surfaces!
  elseif name == minime.dummy_surface or
                  minime.prefixed(name, minime.preview_surface_name_prefix) then
    mod.restore_surfaces = mod.restore_surfaces or {}
    mod.restore_surfaces[index] = name

    minime.writeDebug("Marked %s for restoring!", {minime.argprint(surface)})
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--               A surface has been deleted -- did it belong to us?               --
------------------------------------------------------------------------------------
minime_surfaces.on_surface_deleted = function(event)
  minime.entered_function({event})

  local index = event.surface_index

  -- Whitelist surface with other mods if we have deleted it ourselves!
  minime.writeDebugNewBlock("Did we delete surface %s ourselves?", {index})
  if mod.deleted_surfaces and mod.deleted_surfaces[index] then
    minime.writeDebug("Yes! Whitelisting surface \"%s\" with other mods!",
                      {mod.deleted_surfaces[index]})
    minime_surfaces.whitelist_surface(mod.deleted_surfaces[index])

    minime.writeDebugNewBlock("Removing mod.deleted_surfaces[%s]!", {index})
    mod.deleted_surfaces[index] = nil
    if not next(mod.deleted_surfaces) then
      mod.deleted_surfaces = nil
      minime.writeDebug("Removed mod.deleted_surfaces!")
    end

    minime.entered_function({}, "leave", "all done")
    return

  -- Proceed if it was deleted by some other mod
  else
    minime.writeDebug("No: proceeding!")
  end


  local name = mod.restore_surfaces and mod.restore_surfaces[index]

  -- Leave if this surface doesn't concern us!
  if not name then
    local reason = "nothing to do for surface "..index
    minime.entered_function({}, "leave", reason)
    return
  end


  -- Recreate dummy surface and dummies?
  if name == minime.dummy_surface then
    minime.writeDebug("Restoring dummy surface!")
    minime_surfaces.create_surface(name)

    minime.writeDebug("Recreating dummies!")
    local p_data
    for p, player in pairs(game.players) do
      p_data = mod.player_data[p]
      if p_data then
        minime.writeDebug("Creating new dummy for %s!", {minime.argprint(player)})
        p_data.dummy = minime_player.make_dummy(p)
      else
        minime.writeDebug("Skipping: %s has no player data yet!")
      end
    end

  -- Recreate surface for preview character and reinitialize preview data
  elseif minime.prefixed(name, minime.preview_surface_name_prefix) then
    local char_name = string.sub(name, CHAR_NAME_START_POS)
    minime.writeDebug("Restoring preview surface for \"%s\"!", {char_name})
    restore_preview_characters(char_name)
  end

  mod.restore_surfaces[index] = nil
  minime.writeDebug("Removed mod.restore_surfaces[%s]!", {index})

  if not next(mod.restore_surfaces) then
    mod.restore_surfaces = nil
    minime.writeDebug("Removed mod.restore_surfaces!")
  end

  minime.entered_function("leave")
end


----------------------------------------------------------------------------------
--        Mods like Bilka's "Abandoned Ruins" should ignore this surface        --
----------------------------------------------------------------------------------
minime_surfaces.blacklist_surface = function(surface)
  minime.entered_function({surface})

  surface = (type(surface) == "string" and surface) or
            (type(surface) == "userdata" and surface.object_name == "LuaSurface" and
              surface.valid and surface.name)
  minime.assert(surface, "string", "surface name or surface")

  local mod_interfaces = {
    ["AbandonedRuins"] = {
      f_name = "exclude_surface",
      args = {surface}
    },
    ["RSO"] = {
      f_name = "ignoreSurface",
      args =  {surface}
    },
  }

  for mod_name, mod_data in pairs(mod_interfaces) do
    minime.writeDebugNewBlock("Trying to blacklist surface %s with mod \"%s\"!",
                              {minime.argprint(surface), mod_name})
    minime.remote_call(mod_name, mod_data.f_name, table.unpack(mod_data.args))
  end

  minime.entered_function("leave")
end



----------------------------------------------------------------------------------
--              Whitelist surface with mods like "Abandoned Ruins"              --
----------------------------------------------------------------------------------
minime_surfaces.whitelist_surface = function(surface)
  minime.entered_function({surface})

  surface = (type(surface) == "string" and surface) or
            (type(surface) == "userdata" and surface.valid and
              surface.object_name == "LuaSurface" and surface.name)
  minime.assert(surface, "string", "surface name or surface")

  local mod_interfaces = {
    ["AbandonedRuins"] = {
      f_name = "reinclude_surface",
      args = {surface}
    },
  }

  for mod_name, mod_data in pairs(mod_interfaces) do
    minime.writeDebug("Trying to whitelist surface \"%s\" with mod \"%s\"!",
                      {surface, mod_name})
    minime.remote_call(mod_name, mod_data.f_name, table.unpack(mod_data.args))
  end

  minime.entered_function("leave")
end



------------------------------------------------------------------------------------
minime.entered_file("leave")

return minime_surfaces
