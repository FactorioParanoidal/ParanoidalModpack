minime.entered_file()

local minime_player = {}


------------------------------------------------------------------------------------
--     Create all preview characters (and surfaces, if necessary) for a player    --
------------------------------------------------------------------------------------
minime_player.initialize_player_previews = function(player, flags)
  minime.entered_function({player})

  player = minime.ascertain_player(player)
  if not (player and player.valid) then
    minime.arg_err(player, "player specification")
  end

  minime.assert(flags, {"table", "nil"}, "flags or nil")
  -- If called from minime_update.armor, we won't call it back!
  local ignore_armor = flags and flags.ignore_armor

  local p = player.index
  local p_data = mod.player_data[p]
  --~ local player_chars = mod.player_data[p].available_characters
  p_data.available_characters = p_data.available_characters or
                                minime_gui.available.init_player_character_list(player)

  local player_chars = mod.player_data[p].available_characters
minime.show("player_chars", player_chars)
  if minime.character_selector then
    minime.writeDebug("Character selector is active!")

    -- Find all character prototypes
    local characters = prototypes.get_entity_filtered({
      {filter = "type", type = "character"}
    })

    local chars, surface

    -- We make sure that preview characters of different players don't overlap by
    -- using the player index to determine the character position
    local offset = 10
    local pos = {(p * offset) - offset, 0}

    -- Look for preview characters
    minime.writeDebug("Looking for preview characters.")
    local remove_these = {}
    for c_name, c_data in pairs(mod.minime_characters) do
minime.show(c_name, c_data)
      -- Character prototype exists!
      if characters[c_name] then
        --~ if not (c_data.preview and
                --~ c_data.preview.surface and c_data.preview.surface.valid) then
        -- We can ignore this character if the player has turned it off
        minime.writeDebugNewBlock("Is character \"%s\" available to player?",
                                  {c_name})
        if player_chars and player_chars[c_name] then
          minime.writeDebug("Yes!")

          if not (c_data.preview and c_data.preview.surface and
                                      c_data.preview.surface.valid) then
            minime.writeDebug("Must initialize mod.minime_character[%s].preview!",
                              {c_name})
            minime_character.initialize_character_preview(c_name)
          end
          surface = c_data.preview and c_data.preview.surface
          chars = c_data.preview and c_data.preview.entities
minime.show("chars[p]", chars[p])

          -- There are no data of that character for this player. We may have lost the
          -- data (look for entity at the expected position), or we really didn't create
          -- one yet (do so now).
          --~ if player_chars[c_name] and not (chars[p] and chars[p].valid) then
          if not (chars[p] and chars[p].valid) then
            chars[p] = surface.find_entity(c_name, pos)
            if chars[p] and chars[p].valid then
              minime.writeDebug("Reusing existing preview %s for player %s!",
                                {minime.argprint(chars[p]), minime.argprint(p)})
            else
              chars[p] = surface.create_entity({
                name = c_name,
                position = pos,
                force = player.force,
                direction = defines.direction.south,
              })
              minime.writeDebug("Created preview %s for player %s!",
                                {minime.argprint(chars[p]), minime.argprint(p)})
            end
          end

          if chars[p] and chars[p].valid and chars[p].active then
            chars[p].active = false
            minime.writeDebug("Made %s inactive!", {minime.argprint(chars[p])})
          end

        -- Player turned off this character
        elseif player_chars then
          minime.writeDebug("No: player must have it turned off!")

        -- For some reason, player_chars is still nil
        else
          minime.writeDebug("No: player_chars not yet initialized!")
        end

      -- Character prototype has been removed from game. We'll mark it for removal
      -- from the table (removing it now would mess with the table iterator).
      else
        minime.writeDebug("Marking \"%s\" for removal.", {c_name})
        table.insert(remove_these, c_name)
      end
    end

    -- Remove obsolete characters from character list
    for c, c_name in pairs(remove_these) do
      minime.writeDebug("Removing mod.minime_characters.%s!", {c_name})
      mod.minime_characters[c_name] = nil
    end

    -- Make sure all preview characters have the same armor as the player's current
    -- character, so that the previews will really reflect the player's appearance!
    if player.character then
      if ignore_armor then
        minime.writeDebug("Skipping callback to minime_player.update_armor!")
      else
        minime.writeDebug("Updating armors of preview characters!")
        minime_player.update_armor({player_index = p})
      end
    end
  end

  minime.entered_function("leave")
end




--~ ------------------------------------------------------------------------------------
--~ --     Create a preview character (and surface, if necessary) for all players     --
--~ ------------------------------------------------------------------------------------
--~ local function initialize_preview_characters(char_name)
  --~ minime.entered_function({char_name})

  --~ minime.assert(char_name, "string", "name of character prototype")

  --~ local p = player.index
  --~ local player_chars = global.player_data[p].available_characters

--~ minime.show("player_chars", player_chars)
  --~ if minime.character_selector then
    --~ minime.writeDebug("Character selector is active!")
    --~ local chars, char, surface

    --~ -- We make sure that preview characters of different players don't overlap by
    --~ -- using the player index to determine the character position
    --~ local offset = 10
    --~ local pos = {(p * offset) - offset, 0}

    --~ -- Look for preview characters
    --~ minime.writeDebug("Looking for preview characters.")
    --~ for c_name, c_data in pairs(global.minime_characters) do
--~ minime.show(c_name, c_data)
      --~ if not (c_data.preview and
              --~ c_data.preview.surface and c_data.preview.surface.valid) then
        --~ minime.writeDebug("Must initialize global.minime_character[%s].preview!",
                          --~ {c_name})
        --~ minime_character.initialize_character_preview(c_name)
      --~ end
      --~ surface = c_data.preview and c_data.preview.surface
      --~ chars = c_data.preview and c_data.preview.entities

      --~ -- There are no data of that character for this player. We may have lost the
      --~ -- data (look for entity at the expected position), or we really didn't create
      --~ -- one yet (do so now).
      --~ if player_chars[c_name] and not (chars[p] and chars[p].valid) then
        --~ chars[p] = surface.find_entity(c_name, pos)
        --~ if chars[p] and chars[p].valid then
          --~ minime.writeDebug("Reusing existing preview %s for player %s!",
                            --~ {minime.argprint(chars[p]), minime.argprint(p)})
        --~ else
          --~ chars[p] = surface.create_entity({
            --~ name = c_name,
            --~ position = pos,
            --~ force = player.force,
            --~ direction = defines.direction.south,
          --~ })
          --~ minime.writeDebug("Created preview %s for player %s!",
                            --~ {minime.argprint(chars[p]), minime.argprint(p)})
        --~ end
      --~ end

      --~ if chars[p] and chars[p].valid then
        --~ chars[p].active = false
        --~ minime.writeDebug("Made %s inactive!", {minime.argprint(chars[p])})
      --~ end

    --~ end

    --~ -- Make sure all preview characters have the same armor as the player's current
    --~ -- character, so that the previews will really reflect the player's appearance!
    --~ if player.character then
      --~ minime.writeDebug("Updating armors of preview characters!")
      --~ minime_player.update_armor({player_index = p})
    --~ end
  --~ end

  --~ minime.entered_function("leave")
--~ end


------------------------------------------------------------------------------------
--             Remove a single preview surface + characters for player            --
------------------------------------------------------------------------------------
minime_player.remove_single_character_preview = function(player, char)
  minime.entered_function({player, char})

  player = minime.ascertain_player(player)
  if not (player and player.valid) then
    minime.arg_err(player, "player specification")
  end

  local p = player.index

  --~ local chars, surface, s_name
  local chars, surface

  -- The character we're looking for exists
  local c_data = mod.minime_characters[char]
  if c_data then

    surface = c_data.preview and c_data.preview.surface
    chars = c_data.preview and c_data.preview.entities
minime.show("chars", chars)
minime.show("chars[p]", chars[p])
    -- Remove preview character
    if chars[p] and chars[p].valid then
      chars[p].destroy()
      chars[p] = nil
      minime.writeDebug("Removed preview character \"%s\" for player %s!",
                        {char, p})
    end
    --~ if surface and surface.valid and not next(chars[p]) then
      --~ s_name = surface.name

      --~ -- Remove surface
      --~ game.delete_surface(s_name)
      --~ minime.writeDebug("Removed surface \"%s\"!", {s_name})

      --~ -- Remove surface from ignorelist of "Abandoned Ruins"
      --~ minime.AR_reinclude(s_name)
    --~ end
minime.show("surface", surface)
minime.show("chars", chars)
minime.show("next(chars)", next(chars), "line")
    if surface and surface.valid and not next(chars) then
      minime.writeDebug("Removing %s!", {minime.argprint(surface)})
      minime_surfaces.delete_surface(surface)
minime.show("surface", surface)
    end
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                Remove preview surface and characters for player                --
------------------------------------------------------------------------------------
local function remove_player_previews(player)
  minime.entered_function({player})

  player = minime.ascertain_player(player)
  if not (player and player.valid) then
    minime.arg_err(player, "player specification")
  end

  --~ local p = player.index

  --~ local chars, char, surface, s_name

  -- Look for preview characters
  for c_name, c_data in pairs(mod.minime_characters) do
minime.show(c_name, c_data)
    minime_player.remove_single_character_preview(player, c_name)
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                             Update global settings                             --
------------------------------------------------------------------------------------
minime_player.update_global_settings = function(setting, flags)
  minime.entered_function({setting, flags})

  minime.assert(setting, {"string", "nil", "table"}, "setting name or nil")
  minime.assert(flags, {"table", "nil"}, "table of flags or nil")

  -- If only flags have been passed on, we might end up with a table for setting
  -- and nil for flags!
  if type(setting) == "table" then
    if not flags then
      flags = table.deepcopy(setting)
      setting = nil
      minime.writeDebug("Moved \"setting\" to \"flags\"!")
    else
      minime.arg_err(setting, "setting name")
    end
  end
minime.show("setting", setting)
minime.show("flags", flags)

  -- Crash when the setting isn't valid, so we'll notice wrong setting names!
  if setting and not settings.global[setting] then
    minime.arg_err(setting, "map setting \""..setting.."\" doesn't exist")
  end

  -- We skip updating the GUIs if the function is called from on_init!
  local keep_gui = flags and flags.keep_gui
minime.show("keep_gui", keep_gui)

  -- If no setting is given, update all settings
  local update_all = not setting

  local stored = mod.map_settings

  local setting_list = {
    ["minime_show-character-removal-buttons"] = "show_removal_buttons",
  }

  --~ local s_name, value
  local value

  for s, s_name in pairs(setting_list) do
    -- Show character removal buttons (for entering god/editor mode)!
    --~ local s = "minime_show-character-removal-buttons"
    if update_all or setting == s then
      --~ s_name = "show_removal_buttons"
      value = minime.get_global_setting(s)

      -- We won't do anything if setting doesn't differ from stored value!
      if stored[s_name] ~= value then
        minime.writeDebug("Storing new value of setting %s!",
                          {minime.enquote(s_name)})
        stored[s_name] = value
        minime.writeDebug("mod.map_settings[\"%s\"]: %s", {
          s_name,
          mod.map_settings[s_name] ~= nil and mod.map_settings[s_name] or "nil"
        })
      end

      -- Show removal buttons?
      if s_name == "show_removal_buttons" then
          -- Don't initialize GUIs if called from on_init as we have no player data yet!
          if keep_gui then
            minime.writeDebug("Won't initialize GUIs yet!")

          -- Rebuild GUIs if called from on_runtime_mod_setting_changed
          else
            for p, player in pairs(game.players) do
              minime.writeDebug("Initializing GUIs of %s!", {minime.argprint(player)})
              minime_gui.init_guis(player)
            end
          end

      --~ -- Create corpse when player is leaving multiplayer game? (This will always be
      --~ -- false in singleplayer games!)
      --~ elseif s_name == "create_corpse_on_leaving" then
        --~ stored[s_name] = game.is_multiplayer() and stored[s_name]
      else
        minime.writeDebug("Value of setting \"%s\" hasn't changed!")
      end
    end
  end
  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                             Update player settings                             --
------------------------------------------------------------------------------------
local function update_player_settings(player, setting)
  minime.entered_function({player, setting})

  player = minime.ascertain_player(player)
  if not (player and player.valid) then
    minime.arg_err(player, "player specification")
  end

  minime.assert(setting, {"string", "nil"}, "setting name or nil")
  local update_all = not setting
minime.show("update_all", update_all)

  -- Make sure player data are initialized
  if not mod.player_data[player.index] then
    minime_player.init_player({player = player})
  end

  local p_data = mod.player_data[player.index]
  local p_settings = settings.get_player_settings(player)

  local s, s_name, v

  local log_setting_name = function(name)
    minime.writeDebug("Trying to update setting %s!", {minime.enquote(name)})
  end
  local log_setting_value = function(name)
minime.show("p_data.settings[\""..name.."\"]", p_data.settings[name])
  end

  local get_value = function(name)
    return p_settings[name] and p_settings[name].value
  end

  -- Use toggle button or shortcut to toggle character selector GUI?
  s = "minime_toggle-gui-with"
  if update_all or setting == s then
    log_setting_name(s)

    v = get_value(s)
    s_name = "toggle_gui_with"
    if p_data.settings[s_name] ~= v then
      p_data.settings[s_name] = v
      log_setting_value(s_name)

      -- Enable shortcuts
      if minime.character_selector and v == "shortcut" then
        minime_events.attach_events(minime.optional_events.shortcut)
        mod.optional_events.shortcut = true
        player.set_shortcut_available(minime.toggle_gui_input_shortcut_name, true)
        minime.writeDebug("Activated shortcut for %s!", minime.argprint(player))

        -- Remove the toggle button of the main GUI!
        minime_gui.selector.remove_toggle_button(player)
        minime.writeDebug("Removed toggle button!")

      -- Disable shortcuts
      else
        local unregister = true

        if minime.character_selector then
          player.set_shortcut_available(minime.toggle_gui_input_shortcut_name, false)
          minime.writeDebug("Deactivated shortcut for %s!",
                            {minime.argprint(player)})

          --~ local check_data

          --~ for p, player in pairs(game.players) do
            --~ check_data = global.player_data[p] and global.player_data[p].settings
            --~ if check_data and check_data[s_name] == "shortcut" then
              --~ unregister = false
              --~ minime.writeDebug("%s still needs shortcut events!",
                                --~ {minime.argprint(player)})
              --~ break
            --~ end
          --~ end
          for p, data in pairs(mod.player_data) do
            if data.settings and data.settings[s_name] == "shortcut" then
              unregister = false
              minime.writeDebug("%s still needs shortcut events!", {p})
              break
            end
          end
        end
        if unregister then
          minime.writeDebug("Unregistering shortcut events!")
          minime_events.detach_events(minime.optional_events.shortcut)
          if mod.optional_events then
            mod.optional_events.shortcut = nil
          end
        end

        -- Add toggle button for the main GUI?
        if minime.character_selector then
          minime_gui.selector.create_toggle_button(player)
          minime.writeDebug("Added toggle button!")

        -- Remove toggle button of main GUI!
        else
          minime.writeDebug("Removing toggle button!")
          minime_gui.selector.remove_toggle_button(player)
        end
      end
    end
  end

  -- Close GUI after a character has been selected?
  s = "minime_close-gui-on-selection"
  if update_all or setting == s then
    log_setting_name(s)

    v = get_value(s)
    s_name = "close_gui_on_selection"
    if p_data.settings[s_name] ~= v then
      p_data.settings[s_name] = v
      log_setting_value(s_name)
    end
  end

  -- Should the character follow the player when leaving god/editor mode?
  s = "minime_followmode"
  if update_all or setting == s then
    log_setting_name(s)

    v = (get_value(s) == "character_follows_player")
    s_name = "character_follows_player"
    if p_data.settings[s_name] ~= v then
      p_data.settings[s_name] = v
      log_setting_value(s_name)
    end
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                  UPDATE ARMOR OF A PLAYER'S PREVIEW CHARACTERS                 --
------------------------------------------------------------------------------------
minime_player.on_runtime_mod_setting_changed = function(event)
  minime.entered_function({event})

  local setting = event.setting

  if not minime.prefixed(setting, minime.mod_settings_prefix) then
    minime.entered_function({}, "leave", "not our setting")
    return
  end


  -- Global runtime setting was changed. Update all GUIs of all players!
  if event.setting_type == "runtime-global" then
    minime_player.update_global_settings(setting)

  -- One of our player settings was changed. Update player data!
  elseif minime.prefixed(setting, minime.mod_elements_prefix) then
    update_player_settings(event.player_index, setting)
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                           PLAYER USED A LUA SHORTCUT                           --
------------------------------------------------------------------------------------
minime_player.on_lua_shortcut = function(event)
  minime.entered_function({event})

  -- Selector GUI has been toggled
  if event.prototype_name == minime.toggle_gui_input_shortcut_name then
    minime.writeDebug("Must toggle character selector GUI for player %s!",
                      {event.player_index})
    minime_gui.selector.gui_toggle(event.player_index)
  end

  minime.entered_function("leave")
end



------------------------------------------------------------------------------------
--                           PLAYER USED A CUSTOM-INPUT                           --
------------------------------------------------------------------------------------
minime_player.on_custom_input = function(event)
  minime.entered_function({event})

  -- Selector GUI has been toggled
  if event.input_name == minime.toggle_gui_input_shortcut_name then
    minime.writeDebug("Must toggle character selector GUI for player %s!",
                      {event.player_index})
    minime_gui.selector.gui_toggle(event.player_index)
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                  UPDATE ARMOR OF A PLAYER'S PREVIEW CHARACTERS                 --
-- If event.character exists, only the specified character will be updated!
------------------------------------------------------------------------------------
minime_player.update_armor = function(event)
  minime.entered_function({event})
--~ minime_player.update_armor = function(event, flags)
  --~ minime.entered_function({event, flags})

  local p = event.player_index
  local player = p and minime.ascertain_player(p)
  if not (player and player.valid) then
    minime.arg_err(p, "player index")
  end

  --~ minime.assert(flags, {"table", "nil"}´, "table of flags or nil")

  ----------------------------------------------------------------------------------
  --                    Return if the player has no character!                    --
  ----------------------------------------------------------------------------------
  if not (player.character and player.character.valid) then
    minime.entered_function({}, "leave", "player has no character")
    return
  end


  ----------------------------------------------------------------------------------
  --                       Player has a character, proceed!                       --
  ----------------------------------------------------------------------------------
  -- Check all characters or just some?
  minime.assert(event.character, {"string", "nil"}, "character name or nil")
  local update = event.character and
                  {[event.character] = mod.minime_characters[event.character]} or
                  mod.minime_characters
minime.show("update", update)

  -- The new contents of the character's armor inventory (there's only 1 slot)
  local p_armor = player.character.get_inventory(defines.inventory.character_armor)
  p_armor = p_armor and p_armor[1]

  -- Name of the new armor
  local p_name = p_armor and p_armor.valid_for_read and p_armor.name or nil

minime.show("p_name", p_name)

  ----------------------------------------------------------------------------------
  -- Update armor of the preview characters. This is just about looks, as particular
  -- animations are chosen depending on the armor.
  local char, c_armor, c_name, flags

  local player_data = mod.player_data and mod.player_data[p]
  local available = player_data and player_data.available_characters or
                                    minime.EMPTY_TAB
minime.show("available", available)

  for char_name, char_data in pairs(update) do
    minime.writeDebugNewBlock("Trying to set armor of preview character %s!",
                              {minime.enquote(char_name)})

    -- We must have a valid preview character!
    char = char_data.preview and char_data.preview.entities and
                                  char_data.preview.entities[p]
minime.show("char", char)
minime.show("available[char_name]", available[char_name])

    --~ if not (char and char.valid) then
    if available[char_name] and not (char and char.valid) then
      minime.writeDebug("Must re-initialize previews of %s!",
                        {minime.argprint(player)})
      flags = {ignore_armor = true}
      minime_player.initialize_player_previews(player, flags)
      char = char_data.preview and char_data.preview.entities and
                                    char_data.preview.entities[p]
    end
minime.show("char", char)

    if char and char.valid then
      -- Get armor/armor name of preview character
      c_armor = char.get_inventory(defines.inventory.character_armor)
      c_armor = c_armor and c_armor.valid and c_armor[1]
      c_name = c_armor and c_armor.valid_for_read and c_armor.name or nil

      -- As we don't know whether changing the armor will change the animation, we'd
      -- better change armor when player and preview armor have different names.
      -- (This won't raise an event as preview characters are not player.character!)
      if (p_name ~= c_name) then
        -- Set armor, or …
        if p_name then
          c_armor.set_stack(p_armor)
          minime.writeDebug("Changed armor from \"%s\" to \"%s\"!",
                            {c_name, p_name})
        -- … remove armor
        else
          c_armor.clear()
          minime.writeDebug("Removed \"%s\"!", {c_name})
        end
      end
    end
  end

  ----------------------------------------------------------------------------------
  -- Copy character to dummy if inventory_size_bonus of char and dummy armor differ?
  -- If we've just switched to this character, we've copied it from the backup, so
  -- there is no use in writing back the same data again!
  minime.writeDebugNewBlock("Are we allowed to back up the character?")
  local e_name = "on_player_armor_inventory_changed"
  local skip = mod.skip_events and mod.skip_events[e_name]

  if skip and skip[p] then
    minime.writeDebug("No: just restored character from backup!")
    skip[p] = nil
    minime.writeDebug("Removed skip_events.on_player_armor_inventory_changed[%s]!",
                      {p})
    minime.writeDebugNewBlock("Trying to clean up mod.skip_events!")
    minime_events.remove_skip_event(e_name)

  -- Back up the character!
  else
    minime.writeDebug("Yes!")
    char = mod.player_data[p] and mod.player_data[p].dummy
    c_armor = char and char.valid and
                        char.get_inventory(defines.inventory.character_armor)
    c_armor = c_armor and c_armor.valid and c_armor[1]
    c_name  = c_armor and c_armor.valid_for_read and c_armor.name
minime.show("char", char)

    local p_bonus = 0
    local c_bonus = 0
    do
      local protos = mod.minime_armor_prototypes
      if p_name then
        p_bonus = protos[p_name] and
                    protos[p_name].inventory_size_bonus and
                    protos[p_name].inventory_size_bonus[p_armor.quality.name] or
                  0
      end
      if c_name then
        c_bonus = protos[c_name] and
                    protos[c_name].inventory_size_bonus and
                    protos[c_name].inventory_size_bonus[c_armor.quality.name] or
                  0
      end
    end
minime.show("char", char and char.valid and char.name)
minime.show("c_name", c_name)
minime.show("c_armor", c_armor, "line")
minime.show("p_armor", p_armor, "line")
minime.show("c_bonus", c_bonus)
minime.show("p_bonus", p_bonus)
minime.show("c_armor.quality", c_name and c_armor.quality)
minime.show("p_armor.quality", p_name and p_armor.quality)

    -- TODO: CHECK FOR COPY_TO_PLAYER!
    minime.writeDebugNewBlock("Does inventory_size_bonus of %s and %s differ?",
                              {minime.enquote(p_name), minime.enquote(c_name)})
    if p_bonus ~= c_bonus then
      minime.writeDebug("Yes: %s vs. %s. Copying character!", {p_bonus, c_bonus})
      minime_character.copy_character(player.character, char)
    else
      minime.writeDebug("No: won't back up %s!",
                        {minime.argprint(player.character)})
    end
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                  UPDATE GUN INVENTORY OF A PLAYER'S PREVIEW CHARACTERS                 --
-- If event.character exists, only the specified character will be updated!
------------------------------------------------------------------------------------
minime_player.update_gun_inventory = function(event)
  minime.entered_function({event})

  local p = event.player_index
  local player = p and minime.ascertain_player(p)
  if not (player and player.valid) then
    minime.arg_err(p, "player index")
  end

  -- If we've just switched to this character, we've copied it from the backup, so
  -- there is no use in writing back the same data again!
  minime.writeDebugNewBlock("Are we allowed to back up the character?")
  local e_name = "on_player_gun_inventory_changed"
  local skip = mod.skip_events and mod.skip_events[e_name]
  if skip and skip[p] then
    minime.writeDebug("No: just restored character from backup!")
    skip[p] = nil
    minime.writeDebug("Removed skip_events.on_player_gun_inventory_changed[%s]!",
                      {p})
    minime.writeDebugNewBlock("Trying to clean up mod.skip_events!")
    minime_events.remove_skip_event(e_name)

  -- Back up the character!
  else
    minime.writeDebug("Yes!")
    minime_player.backup_player(event)
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--             UPDATE COLOR OF A PLAYER'S DUMMY AND PREVIEW CHARACTERS            --
------------------------------------------------------------------------------------
minime_player.update_character_color = function(event)
  minime.entered_function({event})

  local entity = event.entity
  local msg
  if entity.type ~= "character" then
    msg = minime.argprint(entity).." is not a character"
  elseif not (entity.player and entity.player.valid) then
    msg = minime.argprint(entity).." is not connected to a player"
  end

  if msg then
    minime.entered_function({}, "leave", msg)
    return
  end

  local player = entity.player
  local p = player.index
minime.show("player", player)

  local color = entity.color
minime.show("color", color)
  ----------------------------------------------------------------------------------
  -- Update color of the preview characters
  local char
  minime.writeDebugNewBlock("Trying to change color of preview characters")
  for c_name, c_data in pairs(mod.minime_characters) do
    -- We must have a valid preview character!
    char = c_data.preview and c_data.preview.entities and c_data.preview.entities[p]
--~ minime.show("char", char)
--~ minime.show("char.color", char and char.valid and char.color)
    if char and char.valid then
      if not minime.compare_colors(char.color, color) then
        minime.writeDebug("Changing color of preview %s!",
                          {minime.argprint(char)})
        char.color = color
      else
        minime.writeDebug("Color of  preview %s hasn't changed!",
                          {minime.argprint(char)})
      end
    else
      minime.writeDebug("%s is not a valid character!", {minime.argprint(char)})
    end
  end

  ----------------------------------------------------------------------------------
  -- Update color in player data
  if mod.player_data[p] and mod.player_data[p].char_properties then
    mod.player_data[p].char_properties.color = color
    minime.writeDebug("Updated color in player_data.char_properties!")
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--               UPDATE LOGISTIC SLOTS OF A PLAYER'S DUMMY CHARACTER              --
------------------------------------------------------------------------------------
--~ minime_player.update_logistic_slots = function(event)
  --~ minime.entered_function({event})

  --~ local char = event.entity
  --~ if char.type ~= "character" then
    --~ minime.entered_function({}, "leave",
                                --~ minime.argprint(char).." is not a character")
    --~ return
  --~ end

  --~ local slot = event.slot_index

  --~ local e_name = "on_entity_logistic_slot_changed"
  --~ local skip = mod.skip_events and mod.skip_events[e_name] and
                                    --~ mod.skip_events[e_name][char.unit_number]
--~ minime.show("slot", slot)
--~ minime.show("skip", skip)
  --~ -- Return if we must ignore the event for this slot!
  --~ if skip == slot then
    --~ local msg = string.format("Must ignore event for logistic slot %s of %s)!",
                              --~ slot, minime.argprint(char))
    --~ mod.skip_events[e_name][char.unit_number] = nil
    --~ minime.entered_function({}, "leave", msg)
    --~ return
  --~ end


  --~ local player = char.player
  --~ if not (player and player.valid) then
    --~ minime.entered_function({}, "leave",
                                --~ minime.argprint(char).." has no player")
    --~ return
  --~ end

  --~ local dummy = mod.player_data[player.index] and
                --~ mod.player_data[player.index].dummy

  --~ if dummy and dummy.valid then

    --~ local char_slot = char.get_personal_logistic_slot(slot)
--~ minime.show("char_slot", char_slot)
    --~ local dummy_slot = dummy.get_personal_logistic_slot(slot)
--~ minime.show("dummy_slot", char_slot)

    --~ -- Prevent raising on_entity_logistic_slot_changed unnecessarily: We set the
    --~ -- dummy slot only if it differs fom character slot!
    --~ local slots_differ = util.table.compare(char_slot, dummy_slot)
--~ minime.show("slots_differ", slots_differ)
    --~ minime.writeDebugNewBlock("Does char_slot differ from dummy_slot?")

    --~ -- Set slot
    --~ if slots_differ then
      --~ minime.writeDebug("Yes: setting slot %s!", slot)
      --~ -- Make sure that char_slot.min <= char_slot.max!
      --~ -- (Fixes <https://pastebin.com/BN8XK1g0>, reported by baladon_23
      --~ -- in https://pastebin.com/BN8XK1g0)
      --~ local set_slot = {
        --~ name = char_slot.name,
        --~ min = math.min(char_slot.min or 0, char_slot.max or 0),
        --~ max = math.max(char_slot.min or 0, char_slot.max or 0),
      --~ }
--~ minime.show("set_slot", set_slot)
      --~ dummy.set_personal_logistic_slot(slot, set_slot)
    --~ -- Ignore slot if it hasn't changed!
    --~ else
      --~ minime.writeDebug("No: ignoring slot %s!", slot)
    --~ end
  --~ end

  --~ minime.entered_function("leave")
--~ end

minime_player.update_logistic_slots = function(event)
  minime.entered_function({event})

  local char = event.entity
  if char.type ~= "character" then
    minime.entered_function({}, "leave",
                                minime.argprint(char).." is not a character")
    return
  end

  local slot = event.slot_index
  local section_id = event.section and event.section.index

  local e_name = "on_entity_logistic_slot_changed"
  local skip = mod.skip_events and mod.skip_events[e_name] and
                                    mod.skip_events[e_name][char.unit_number]
minime.show("slot", slot)
minime.show("skip", skip)
  -- Return if we must ignore the event for this slot!
  if skip == slot then
    local msg = string.format("Must ignore event for logistic slot %s of %s)!",
                              slot, minime.argprint(char))
    mod.skip_events[e_name][char.unit_number] = nil
    minime.entered_function({}, "leave", msg)
    return
  end


  local player = char.player
  if not (player and player.valid) then
    minime.entered_function({}, "leave",
                                minime.argprint(char).." has no player")
    return
  end

  local dummy = mod.player_data[player.index] and
                mod.player_data[player.index].dummy

  if dummy and dummy.valid then

    local src_logistics = player.get_requester_point()
minime.show("src_logistics", src_logistics)

    local dst_logistics = dummy.get_requester_point()
minime.show("dst_logistics", dst_logistics)

    minime.writeDebugNewBlock("Do we have valid requester points?")
    if src_logistics and src_logistics.valid and
        dst_logistics and dst_logistics.valid then

      local s_section = src_logistics.get_section(event.section.index)
      local d_section = dst_logistics.get_section(event.section.index)

      if s_section and s_section.valid then
        minime.writeDebug("Found valid section in src!")

        -- Create section?
        minime.writeDebugNewBlock("Does section %s exist in dst?", {section_id})
        if d_section and d_section.valid then
          minime.writeDebug("Yes: copying group!")
          d_section.group = s_section.group
        else
          minime.writeDebug("No: creating it!")
          d_section = dst_logistics.add_section(s_section.group)
        end

        -- Are slot filters different?
        minime.writeDebugNewBlock("Do slot filters differ?")
        do
          local s = s_section.filters[slot]
          local d = d_section.filters[slot]
minime.show("s", s)
minime.show("d", d)
          if s and d and util.table.compare(s, d) then
            minime.writeDebug("No!")
          elseif s then
            --~ minime.writeDebug("Yes: copying filter!")
            --~ d_section.set_slot(slot, s)
            minime.writeDebug("Yes! Is filter already set in destination?")
            local cleared
            for f, filter in pairs(d_section.filters) do
minime.show("Filter "..f, filter)
minime.show("s.value", s.value)
              if table.compare(filter.value or minime.EMPTY_TAB,
                                s.value or minime.EMPTY_TAB) then
                minime.writeDebug("Yes: clearing slot %s!", f)
                d_section.clear_slot(f)
                cleared = true
                break
              end
            end
            if not cleared then
              minime.writeDebug("No!")
            end
            minime.writeDebug("Copying filter!")
            d_section.set_slot(slot, s)
          else
            minime.writeDebug("Yes: clearing filter!")
            d_section.clear_slot(slot)
          end
        end
      end
    end
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                      Create a dummy character for player!                      --
------------------------------------------------------------------------------------
minime_player.make_dummy = function(player)
  minime.entered_function({player})

  player = minime.ascertain_player(player)
  if not (player and player.valid) then
    minime.arg_err(player, "player specification")
  end

  -- Check if we have an old dummy that we need to migrate if
  -- minime.dummy_character_name has been changed.
  local p_data = mod.player_data[player.index]
  local old_dummy = p_data and p_data.dummy
  local new_dummy

  local function create()
    return game.surfaces[minime.dummy_surface].create_entity({
      name = minime.dummy_character_name,
      force = player.force,
      position = {player.index * 3, 0}
    })
  end

  -- Player has no dummy yet
  if not (old_dummy and old_dummy.valid) then
    minime.writeDebug("Creating dummy for player %s (no dummy yet)!",
                      {player.index})
    new_dummy = create()

  -- We decided to change the dummy name, migrate old dummy!
  elseif old_dummy.name ~= minime.dummy_character_name then
    minime.writeDebug("Dummy \"%s\" has not the expected name \"%s\"!",
                      {old_dummy.name, minime.dummy_character_name})
    new_dummy = create()
    minime_character.copy_character(old_dummy, new_dummy)
    minime.writeDebug("Copied %s to %s", {minime.argprint(old_dummy), minime.argprint(new_dummy)})
    old_dummy.destroy()
    minime.writeDebug("Removed old dummy!")

  -- Player already has a dummy with the expected name, use that!
  else
    minime.writeDebug("Using old dummy!")
    new_dummy = old_dummy
  end

  minime.entered_function("leave")
  return new_dummy
end


------------------------------------------------------------------------------------
--                            INITIALIZE A NEW PLAYER!
-- table: {player = player_arg, remove_character = remove_arg, restore = restore_arg}
-- player_arg:                  player_index (number) OR player (Lua object)
-- remove_arg (optional):       anything (Will be passed on to init_gui!)
-- restore_arg (optional):      anything (Will be passed on to switch_characters!)
------------------------------------------------------------------------------------
minime_player.init_player = function(event)
  minime.entered_function({event})

  minime.check_args(event, "table", "event data")

  -- Mandatory argument
  local player = minime.ascertain_player(event.player or event.player_index)
  if not (player and player.valid) then
    error(serpent.line(event) .. " contains no valid player data!")
  end


minime.show("player.character", player.character and player.character.name or "nil")
minime.show("player.cutscene_character", player.cutscene_character and player.cutscene_character.name or "nil")

  -- Only proceed if player is connected!
  if not player.connected then
    minime.writeDebug("Removing GUI of player %s (not connected)!", {player.name})
    minime_gui.remove_gui(player)

    local reason = minime.argprint(player).." is not connected"
    minime.entered_function({event}, "leave", reason)
    return
  end
  minime.writeDebugNewBlock("%s is connected -- proceeding with initialization!",
                            {minime.argprint(player)})

  -- Optional arguments
  --~ local remove_character = event.remove_character
  local restore = event.restore and true or false

minime.show("mod.minime_characters",
              mod.minime_characters and table_size(mod.minime_characters))

  -- Get player's controller type
  local controller = minime.controller_names[player.controller_type]
  minime.writeDebug("Current controller of %s: %s",
                    {minime.argprint(player), controller})

  -- Initialize player data
  local p = player.index
  mod.player_data[p] = mod.player_data[p] or {}
  local p_data = mod.player_data[p]

  -- Create dummy, if necessary
  if not (p_data.dummy and p_data.dummy.valid) then
    p_data.dummy = minime_player.make_dummy(p)
  end
minime.show("p_data.dummy", p_data.dummy)

minime.show("p_data", p_data)

  -- Read player settings
  minime.writeDebugNewBlock("Updating player settings.")
  p_data.settings = {}
  update_player_settings(p)

  -- Some properties will only exist if a character is connected to a player. As that will
  -- never be the case for the dummy, we store such properties in a separate table.
  minime.writeDebugNewBlock("Have we already stored char_properties?")
  p_data.char_properties = p_data.char_properties or {}
  if next(p_data.char_properties) then
    minime.writeDebug("Yes!")
  else
    minime.writeDebug("No: initializing p_data.char_properties!")
    local target = p_data.char_properties

   --~ local researched = global.researched_by[player.force.name]

    -- Player has a character
    if player.character then
      minime.writeDebug("Player has a character!")
      for property_name, property in pairs(minime.copyable_character_properties) do
minime.show(property_name, property)
        -- Property does not depend on a tech: Copy it from the character!
        if property.need_techs == nil then
          minime.writeDebug("Copying from character!")
          target[property_name] = table.deepcopy(player.character[property_name])
        -- Only copy property if the prerequisite tech has been researched!
        elseif minime_forces.is_tech_researched(player.force, property.need_techs) then
          minime.writeDebug("Required techs have been researched. Copying from character!")
          target[property_name] = table.deepcopy(player.character[property_name])
        end
minime.show("p_data.char_properties["..minime.enquote(property_name).."]",
            p_data.char_properties[property_name])
      end

    -- Player is in god or editor mode
    else
      minime.writeDebug("Player has no character!")
      for property_name, property in pairs(minime.copyable_character_properties) do
minime.show(property_name, property)
        -- We can get the property from the player
        if property.init_from_player then
          minime.writeDebug("Get property from player!")
          -- Only copy property from player if it either doesn't depend on a tech
          -- or if the tech has been researched!
          -- if (not p.need_techs) or minime.is_tech_researched(player.force, p.need_techs) then
          if (not property.need_techs) or
              minime_forces.is_tech_researched(player.force, property.need_techs) then
            minime.writeDebug("Copying property from player!")
            target[property_name] = table.deepcopy(player[property_name])
          -- Skip property
          else
            minime.writeDebug("Skipping property %s (depends on unresearched techs)!",
                              {minime.enquote(property_name)})
          end

        -- Fall back to the default value
        else
          minime.writeDebug("Falling back to default value!")
          target[property_name] = property.default
        end
minime.show("p_data.char_properties["..property_name.."]",
            p_data.char_properties[property_name])
      end
    end
    target.last_user = player
  end

  -- If we have no character and there is no record that we have switched to god or
  -- editor mode, check whether SE put us there and try to update our data!
  minime.writeDebugNewBlock("Does the player have a character?")
  if player.character then
    minime.writeDebug("Yes!")
  else
    minime.writeDebug("No: checking remote interfaces of SE!")
    local SE_remote_view = minime.SE_remote_view(player)
minime.show("SE_remote_view", SE_remote_view)
    if SE_remote_view then
      minime.writeDebug("SE removed character of %s! Current mode: %s", {
        minime.argprint(player),
        minime.controller_names[player.controller_type]
      })
minime.show("p_data", p_data)
minime.show("p_data.detached_character", p_data.detached_character)
      p_data.last_character = ""
      p_data.detached_character = minime.SE_player_char(player)
      p_data.god_mode = (controller == "god") or nil
      p_data.editor_mode = (controller == "editor") or nil
      p_data.SE_nav_view = true
minime.show("p_data.detached_character", p_data.detached_character)
minime.show("p_data.detached_character after calling SE", p_data.detached_character)
minime.show("p_data.god_mode", p_data.god_mode)
minime.show("p_data.editor_mode", p_data.editor_mode)
minime.show("p_data.SE_nav_view", p_data.SE_nav_view)

      if p_data.detached_character and p_data.detached_character.valid and
          p_data.dummy and p_data.dummy.valid then

        minime.writeDebug("Backing up detached character!")
        minime_character.copy_character(p_data.detached_character, p_data.dummy)
      end
    else
      minime.writeDebug("Not in remote view!")
    end
  end

  -- Initialize list of characters available to that player
  minime.writeDebugNewBlock("Making character pages, adds list of available chars!")
  minime_gui.make_gui_character_pages(player)

  -- Which character does the player use? It must be available on the GUI!
  --~ local available = p_data.available_characters or minime.EMPTY_TAB
  local available = p_data.available_characters or
                    minime_gui.available.init_player_character_list(player)
  local p_basename = player.character and player.character.valid and
                      minime_character.get_character_basename(player.character)

  -- Another mod changed the character already -- use that!
  if restore and player.character then
    minime.writeDebug("Restore character \"%s\"!", {player.character.name})
    --~ p_data.last_character = minime_character.get_character_basename(player.character)
    p_data.last_character = p_basename
    --~ p_data.char_entity = player.character

  -- The character used last time still exists and is available to the player (not
  -- turned off in available-characters GUI)
  --~ elseif p_data.last_character and available[p_data.last_character] and
                                   --~ mod.minime_characters[p_data.last_character] then
  elseif p_data.last_character and available[p_data.last_character] then
    minime.writeDebug("Using same character as last time (\"%s\")!",
                      {p_data.last_character})

  -- The character currently in use (e.g. after starting a new game or adding the
  -- mod to an existing game) is the base version of a skin character
  --~ elseif player.character and available[player.character.name] and
                              --~ mod.minime_characters[player.character.name] then
  elseif player.character and available[player.character.name] then
    minime.writeDebug("Initialize with current base character (\"%s\")!",
                      {player.character.name})
    p_data.last_character = player.character.name

  -- The character currently in use (e.g. after adding the mod to an existing game)
  -- is a variety (flying, class, etc.) of a skin character.
  --~ elseif player.character and available[player.character.name] and
            --~ mod.minime_character_properties[player.character.name] then
  elseif player.character and p_basename and available[p_basename] and
                        mod.minime_character_properties[player.character.name] then
    minime.writeDebug("Initialize with current character version (\"%s\")!",
                      {player.character.name})

    -- Get the name of the base character
    local data = mod.minime_character_properties[player.character.name]
    --~ p_data.last_character = data.button and
                            --~ data.button:gsub("^"..minime.character_button_prefix, "")
    p_data.last_character = data.base_name
    -- Add info about class, flying state, etc. to player data
    p_data.bob_class = data.bob_class
    p_data.flying = data.flying

  -- The player doesn't have a character (e.g. in god mode) --> empty string!
  else
    minime.writeDebug("Player has %s character!",
                      {player.character and "no valid" or "no"})
    p_data.last_character = ""
  end

  -- SE respawn event: If the player has a character, remove p_data.god_mode,
  -- p_data.editor_mode, and p_data.detached_character!
minime.show("controller", controller)
  minime.writeDebugNewBlock("Check for SE respawn event?")
  if controller == "character" then
    minime.writeDebug("Yes!")
    if p_data.god_mode then
      p_data.god_mode = nil
      minime.writeDebug("Removed p_data.god_mode!")
    elseif p_data.editor_mode then
      p_data.editor_mode = nil
      minime.writeDebug("Removed p_data.editor_mode!")
    end
    local old = p_data.detached_character
    if old then
      p_data.detached_character = nil
      minime.writeDebug("Removed p_data.detached_character!")

      -- Remove the detached character from mod.detached_characters!
      if mod.detached_characters then
        -- If the old character is still valid, we can use its unit_number
        if old.valid and mod.detached_characters[old.unit_number] then
          mod.detached_characters[old.unit_number] = nil
          minime.writeDebug("Removed mod.detached_characters[%s]!",
                            {old.unit_number})

        -- We can't identify the old character directly, so we'll loop over the
        -- complete list and remove all entries made for the player.
        elseif not old.valid then
          for c_id, c_player in pairs(mod.detached_characters) do
            if c_player == player.index then
              mod.detached_characters[c_id] = nil
              minime.writeDebug("Removed mod.detached_characters[%s].", {c_id})
            end
          end
        end

        -- Remove the list if it is empty!
        if not next(mod.detached_characters) then
          mod.detached_characters = nil
          minime.writeDebug("Removed mod.detached_characters!")
        end
      end
    end
  else
    minime.writeDebug("No: player's controller type is %s, not \"character\"!",
                      {controller})
  end
minime.show("p_data", p_data)


  --~ -- Initialize list of characters available to that player
  --~ minime.writeDebugNewBlock("Making character pages")
  --~ minime_gui.make_gui_character_pages(player)

  -- If we have a legit character, on which GUI page can we find it?
  minime.writeDebugNewBlock("Trying to get page with current character!")
  p_data.character_gui_page = minime_gui.selector.get_character_gui_page(p)
minime.show("p_data.character_gui_page", p_data.character_gui_page)

  -- Create preview entities, if necessary
  minime.writeDebugNewBlock("Initializing player previews!")
  minime_player.initialize_player_previews(p)


  -- Is the GUI open?
  p_data.show_character_list = p_data.show_character_list or false
minime.show("mod.player_data["..p.."].show_character_list",
            mod.player_data[p].show_character_list)

  p_data.show_available_character_list = p_data.show_available_character_list or false
minime.show("mod.player_data["..p.."].show_available_character_list",
            mod.player_data[p].show_available_character_list)


  --~ -- Copy p_data to global table for long-term storage
  --~ global.player_data[p] = p_data
  minime.show("Initialised mod.player_data["..p.."]", mod.player_data[p])

  minime_inventories.main_inventory_resized(p)

  -- Remove the GUI, we will rebuild it!
--~ local av_gui = player.gui.screen["minime_available_chars_main_frame"]
--~ local sel_gui = player.gui.screen["minime_char_selector_main_frame"]
  minime_gui.remove_gui(p)
  minime.show("Removed GUI of player", p)

  -- Create GUI for list of available characters
  minime.writeDebugNewBlock("Creating available-characters GUI for player %s", {p})
  minime_gui.available.init_gui(p)

  -- Count characters that have been turned off by the player
  minime.writeDebugNewBlock("Updating number of characters turned off by player!",
                    {mod.player_data[p].hidden_characters})
  p_data.hidden_characters = p_data.hidden_characters or
                              minime_gui.available.count_hidden_characters(p)
minime.show("p_data.hidden_characters", p_data.hidden_characters)

  -- We always need a GUI now because we can switch to god or editor mode
  minime.writeDebugNewBlock("Creating character-selector GUI for player %s!", {p})
  local removed = (p_data.last_character == "" and
                    not (p_data.god_mode or p_data.editor_mode))
minime.show("removed", removed)
  minime_gui.selector.init_gui(p, removed)

  minime.writeDebug("Current character: %s \tLast character: %s",
                    {player.character and player.character.name or "nil",
                      p_data.last_character})
                    --~ {minime.argprint(player.character), p_data.last_character})


  -- Default: If we are not in god mode and if the character has changed, switch to
  -- the stored character! If any value has been passed to init, this will be passed
  -- on to switch_characters() as well, so we can restore the inventory if we react
  -- to a character change by another mod.
  minime.writeDebugNewBlock("Switch to stored character?")
  local c = player.character
  if (p_data.last_character ~= "" and restore) or
     p_data.last_character ~= (c and c.name) then

    minime.writeDebug("Yes: %s --> %s!",
                      {c and c.name or "nil", p_data.last_character}, "line")
    local passon_flags = {restore = restore}
    minime_character.switch_characters(p, passon_flags)

  -- Otherwise just make a backup of the current character
  elseif player.character then
    minime.writeDebug("No: backing up old character!")
    minime_character.copy_character(player.character, p_data.dummy)

  -- Last character has been removed, so the player actually is in god mode but
  -- didn't select this.
  elseif p_data.last_character == "" and
          not (p_data.god_mode or p_data.editor_mode) then
    minime.writeDebug("No: last character of player has been removed!")
  end

  if player.character and player.character.valid then
    p_data.char_entity = player.character
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                                   NEW PLAYER!                                  --
------------------------------------------------------------------------------------
minime_player.on_player_created = function(event)
  minime.entered_event(event)

  -- If we are in a scenario that doesn't support characters, we must disable our
  -- shortcuts! (This is important if a new player is joining.)
  if mod.no_characters then
    minime.writeDebug("Scenario doesn't support characters!")

    local player = minime.ascertain_player(event.player_index)
    local shortcut = minime.toggle_gui_input_shortcut_name

    -- Disable shortcuts
    minime.writeDebug("Disable shortcuts for %s?", {minime.argprint(player)})
    --~ if game.shortcut_prototypes[shortcut] and
    if prototypes.shortcut[shortcut] and
        player.is_shortcut_available(shortcut) then

      player.set_shortcut_available(shortcut, false)
      minime.writeDebug("Disabled shortcut of %s!", {minime.argprint(player)})
    end

    -- If CharacterModHelper is not running, warn player that character selector
    -- mode has been disabled!
    minime.writeDebug("Warn %s that selector mode is disabled?",
                      {minime.argprint(player)})
    if not script.active_mods["CharacterModHelper"] then
      minime.writeDebug("\"CharacterModHelper\" is not active!")
      local reason = {
        "minime-selector-mode.disabled-no-char-scenario",
        script.level.level_name,
        {"mod-name."..script.level.mod_name} or script.level.mod_name,
      }

      local msg = {
        "minime-selector-mode.wrapper",
        {"mod-name."..script.mod_name},
        reason,
      }
      game.print(msg)
      minime.show("Printed warning", msg)
    end
  end

  minime.entered_event(event, "leave")
end


------------------------------------------------------------------------------------
--                               PLAYER JOINED GAME!                              --
------------------------------------------------------------------------------------
minime_player.on_player_joined_game = function(event)
  minime.entered_function({event})
  local player = minime.ascertain_player(event.player_index)

  local force = player.force
  if force and force.valid and not(mod.researched_by[force.name]) then
    --~ minime_player.init_force_data(force)
    minime_forces.init_force_data(force)
  end


  -- We're still in a cutscene. Wait until it is finished!
  if player.cutscene_character then
    minime.writeDebug("Player has no character yet. Waiting for cutscene to finish!")

  -- Cutscene has finished or wasn't played. Initialize player immediately!
  else
    minime.writeDebug("Not in cutscene!")

    -- Initialize player data
      minime.writeDebug("Initializing %s!", {minime.argprint(player)})
      minime_player.init_player(event)

    -- Warn player that character selector mode has been disabled?
    minime.writeDebug("Warn %s that selector mode is disabled?",
                      {minime.argprint(player)})
    if mod.no_characters and not script.active_mods["CharacterModHelper"] then
      minime.writeDebug("\"CharacterModHelper\" is not active!")
      local reason = {
        "minime-selector-mode.disabled-no-char-scenario",
        script.level.level_name,
        {"mod-name."..script.level.mod_name} or script.level.mod_name,
      }

      local msg = {
        "minime-selector-mode.wrapper",
        {"mod-name."..script.mod_name},
        reason,
      }
      game.print(msg)
      minime.show("Printed warning", msg)

    else
      minime.writeDebug("No!")
    end

  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                         PLAYER IS ABOUT TO LEAVE GAME!                         --
------------------------------------------------------------------------------------
minime_player.on_pre_player_left_game = function(event)
  minime.entered_function({event})
  local player = minime.ascertain_player(event.player_index)
  local p = minime.argprint(player)

  if not (player and player.valid) then
    minime.entered_function({event}, "leave", p.." is not a valid player")
    return
  end

  --~ -- Create corpse?
  --~ if global.map_settings and global.map_settings.create_corpse_on_leaving and
      --~ player.character and player.character.valid then
    --~ minime.writeDebug("Creating corpse for %s!", {p})

    --~ local pos = player.position
    --~ -- TODO: Actually create the corpse!
  --~ end

  -- Back up player data
  minime.writeDebugNewBlock("Backing up data of %s!", {p})
  minime_player.backup_player(event)

  minime.entered_function("leave")
end

------------------------------------------------------------------------------------
--                                 REMOVE PLAYER!                                 --
------------------------------------------------------------------------------------
-- TODO: move inventory to corpse?
minime_player.remove_player = function(event)
  minime.entered_function({event})

  local p = event.player_index
  local p_data = mod.player_data and mod.player_data[p]
  local player = minime.ascertain_player(p)
  local entity

  -- Remove GUI
  minime_gui.remove_gui(player)
  minime.writeDebug("Removed GUI of %s", {player})

  -- Remove dummy and shortcut
  if p_data then
    -- Dummy
    if p_data.dummy and p_data.dummy.valid then
      p_data.dummy.destroy()
      minime.writeDebug("Removed dummy character!")
    end

    --~ -- Shortcut
    --~ if p_data.settings and p_data.settings.toggle_gui_with == "shortcut" then

    --~ end
    mod.player_data[p] = nil
    minime.writeDebug("Removed data of player %s!", {p or "nil"})
  end

  -- Disable shortcut?
  if player and player.valid and
      player.is_shortcut_available(minime.toggle_gui_input_shortcut_name) then

    player.set_shortcut_available(minime.toggle_gui_input_shortcut_name, false)
    minime.writeDebug("Disabled shortcut of %s!", {minime.argprint(player)})
  end

  -- Remove preview entities
  for c_name, c_data in pairs(mod.minime_characters or {}) do
    if c_data.preview and c_data.preview.entities then
      entity = c_data.preview.entities[p]
      if entity and entity.valid then
        minime.writeDebug("Removing %s!", {minime.argprint(entity)})
        entity.destroy()
      end
    end
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--          Compile list of character properties stored with player data          --
------------------------------------------------------------------------------------
minime_player.backup_player = function(event)
  minime.entered_function({event})

  local player = minime.ascertain_player(event.player_index or event.player)

  if not player and player.valid then
    minime.arg_err(player, "player specification")
  end

  local p = player.index
  if not mod.player_data[p] then
    minime_player.init_player(event)
  elseif not (mod.player_data[p].dummy and mod.player_data[p].dummy.valid) then
    mod.player_data[p].dummy = minime_player.make_dummy(p)
  end

  local char = player.character
  local dummy = mod.player_data[p].dummy

  if char and char.valid and dummy and dummy.valid then
    minime_character.copy_character(char, dummy)
    minime.writeDebug("Made backup of character for player \"%s\".", {player.name})
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--      If the player has activated remote_view from SE (god mode), leave it!     --
------------------------------------------------------------------------------------
minime_player.stop_SE_remote_view = function(player, flags)
  minime.entered_function({player, flags})

  player = minime.ascertain_player(player)
  if not player and player.valid then
    minime.arg_err(player, "player specification")
  end
  local p_data = mod.player_data[player.index]

  minime.assert(flags, {"table", "nil"}, "table of flags or nil")
  -- Don't remove record of detached_character if the player is changing from remote
  -- view (god mode) to editor mode!
  local keep_detached_character = flags and flags.keep_detached_character

  -- If called from minime_gui.select_character, we must keep p_data.last_character
  -- as it already has the name of the character we want to change to.
  local keep_last_character = flags and flags.keep_last_character

  --~ if minime.SE_remote_view(player) then
  if p_data.SE_nav_view then
    minime.writeDebug("Must exit remote view of SE!")

    --~ local p_data = global.player_data[player.index]

    if keep_last_character then
      p_data.keep_last_character = keep_last_character
      minime.writeDebug("Set flag p_data.keep_last_character!")
    end

    minime.writeDebug("Trying to call SE's remote function!")
    minime.remote_call("space-exploration", "remote_view_stop", {player = player})

    if keep_last_character then
      p_data.keep_last_character = nil
      minime.writeDebug("Removed flag p_data.keep_last_character!")
    end


    --~ local controller = minime.controller_names[player.controller_type]
    minime.writeDebug("Controller of %s! Current mode: %s\tCurrent character: %s", {
      minime.argprint(player),
      minime.controller_names[player.controller_type],
      minime.argprint(player.character)
    })
minime.show("p_data", p_data)

    --~ if not keep_last_character then
      --~ local char = player.character and player.character.valid and
                    --~ global.minime_character_properties[player.character.name]

      --~ p_data.last_character = char and char.base_name or ""
    --~ end
    if not keep_detached_character then
      p_data.detached_character = nil
    end
    p_data.god_mode = nil
    p_data.SE_nav_view = nil
p_data.char_entity = player.character

    --~ p_data.editor_mode = nil
    minime.writeDebug("Backing up player's new character!")
    if player.character and player.character.valid then
      minime_character.copy_character(player.character, p_data.dummy)
    end
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
minime.entered_file("leave")
return minime_player
