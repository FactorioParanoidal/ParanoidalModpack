minime.entered_file()


local minime_if = {}

local interface_functions = {}

------------------------------------------------------------------------------------
-- Add one or several new characters to the GUI
-- chars: character name (string) or array of character names
interface_functions.register_characters = function(chars)
  minime.entered_function({chars})

  if not chars or (type(chars) ~= "string" and type(chars) ~="table") then
    minime.arg_err(chars, "string or array of strings")
  end

  -- Make sure we have a table!
  if type(chars) == "string" then
    chars = {chars}
  end

  minime.writeDebug("Queueing %s character(s) for registration!", {#chars})
  mod.mod_registered_characters = mod.mod_registered_characters or {}
  for c, char in pairs(chars) do
    mod.mod_registered_characters[char] = true
    minime.writeDebug("Added \"%s\" to queue!", {char})
  end

  if not mod.minime_characters then
    minime.entered_function({}, "leave", "tables not yet ready")
    return
  end


  --~ local characters = game.get_filtered_entity_prototypes({
  local characters = prototypes.get_entity_filtered({
    {filter = "type", type = "character"}
  })

  local rebuild_gui, tmp_data

  for c, char in pairs(chars) do
    -- Sanity checks
    -- Character name must be a string
    if type(char) ~= "string" then
      error(serpent.line(char).." is not a valid name!")
    -- Character name must represent a valid character prototype
    elseif not characters[char] then
      error(serpent.line(char).." is not a valid character!")
    end

    -- Skip if character already has been registered
    if mod.minime_characters[char] and next(mod.minime_characters[char]) then
      minime.writeDebug("Character %s has already been registered -- nothing to do!", {char}, "line")
    -- Register character
    else
      minime.writeDebug("Registering character %s", {char}, "line")

      -- Try to add data of the character. If there is no character prototype with
      -- the given name, mod.minime_characters[char] will still be nil!
      minime_character.set_character_data(char)

      -- If we succeeded in setting character data, add the character properties!
      if mod.minime_characters[char] then
        minime.writeDebug("Try to add mod.minime_character_properties[%s]",
                          {char})
        tmp_data = minime_character.get_minime_character_properties(char)
minime.show("tmp_data", tmp_data)
        --~ mod.minime_character_properties[char] = tmp_data and tmp_data[char]
        for cp, c_data in pairs(tmp_data or minime.EMPTY_TAB) do
minime.show(cp, c_data)
          mod.minime_character_properties[cp] = table.deepcopy(tmp_data[cp])
        end
        rebuild_gui = true
      end
    end
  end

  -- Rebuild the GUIs
  if rebuild_gui then
    for p, player in pairs(game.players) do
      minime_player.init_player({ player = player })
    end
  end

  minime.entered_function("leave")
end


-- Remove one or several characters from the GUI
-- chars: character name (string) or array of character names
interface_functions.unregister_characters = function(chars)
  minime.entered_function({chars})

  if not chars or (type(chars) ~= "string" and type(chars) ~="table") then
    error(serpent.line(chars) .. " is not a valid argument! (Must be string or array of strings.)")
  end

  -- Make sure we have a table!
  if type(chars) == "string" then
    chars = {chars}
  end

  local rebuild_gui

  for c, char in pairs(chars) do
    -- Sanity check: Character name must be a string
    minime.check_args(char, "string", "character name")

    -- Remove character from list
    if mod.minime_characters[char] then
      mod.minime_characters[char] = nil
      minime.writeDebug("Removed character %s from list!", {char}, "line")
      rebuild_gui = true
    end
  end

  -- Update GUIs
  if rebuild_gui then
    minime.writeDebug("Removing character(s) from GUIs!")
    for p, player in pairs(game.players) do
      minime_player.init_player({ player = player, remove_character = true })
    end
  end

  minime.entered_function("leave")
end


-- Get character list (so other mods can update their list of selectable characters)
-- Return: Table with { ["character"] = character.localized_name or character.name}
interface_functions.get_character_list = function()
  minime.entered_function()
  return mod.minime_characters
end

-- A player's character will be changed -- make a backup!
interface_functions.pre_player_changed_character = function(player)
  minime.entered_function({player})

  player = minime.ascertain_player(player)
  if not (player and player.valid) then
    minime.arg_err(player, "player specification")
  end

  minime_player.backup_player({player_index = player.index})

  minime.entered_function("leave")
end

-- Backup character! (Just an alias for pre_player_changed_character, with a name
-- telling what the function does, not when it should be called.)
interface_functions.backup_player = interface_functions.pre_player_changed_character


-- A player's character has been changed by another mod. Rebuild the player's GUI!
interface_functions.player_changed_character = function(player)
  minime.entered_function({player})

  player = minime.ascertain_player(player)
  if not (player and player.valid) then
    minime.arg_err(player, "player specification")
  end

  minime.writeDebug("Player changed character to %s.", {player.character})
  minime_player.init_player({ player = player, restore = true })

  minime.entered_function("leave")
end



------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- DEPRECATED! These functions will be removed in one of the next versions!
-- Custom events are now defined during data stage. You can find their ID just like
-- you would with normal events: in defines.events!
-- (Check out the definition of 'custom_events' in common.lua for the event names!)
------------------------------------------------------------------------------------
-- The original function. We'll keep it for compatibility with other mods
--~ interface_functions.get_minime_event_id = function()
  --~ local event = "minime_exchanged_characters"
  --~ minime.writeDebug("Returning ID of event \"%s\" (%s)!",
                    --~ {event, minime.minime_event_ids[event]})
  --~ return minime.minime_event_ids["minime_exchanged_characters"]
--~ end
interface_functions.get_minime_event_id = function()
  local event = "minime_exchanged_characters"
  minime.writeDebug("Returning ID of event \"%s\" (%s)!",
                    {event, defines.events[event]})
  return defines.events[event]
end

-- Return list of all custom events and their IDs (currently, there's just one)
interface_functions.get_minime_event_ids = function()
  minime.writeDebug("Returning IDs of custom events defined by \"%s\": %s",
                    {minime.modName, minime.minime_event_ids})
  local ret = {}
  for e, e_name in pairs(minime.custom_events) do
    ret[e_name] = defines.events[e_name]
  end
  return ret
end
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------


-- Debugging: Dump contents of dummy inventory
interface_functions.dump = function(player, inventory_list)
  minime.entered_function({player, inventory_list})

  player = minime.ascertain_player(player)
  if not (player and player.valid) then
    minime.arg_err(player, "player specification")
  end

  inventory_list = inventory_list and (
                          (type(inventory_list) == "string" and {inventory_list}) or
                          (type(inventory_list) == "table" and inventory_list)
                        ) or minime.inventory_list

  local inv, slots, test
  for i, inventory in pairs(inventory_list) do
    minime.writeDebug("Inventory %s:", {inventory}, "line")
    inv = defines.inventory["character_" .. inventory]
    slots = mod.player_data[player.index].dummy.get_inventory(inv)
    for x = 1, #slots do
      test = slots[x].valid_for_read
      minime.writeDebug("%s:\t%s %s",
        {x, test and slots[x].name or "NOT VALID FOR READ",
            test and " ("..slots[x].count..")" or  ""}, "line")
    end
  end

  minime.entered_function("leave")
end


-- Jetpack expects this function on other mods' remote interfaces. We can use that
-- for other mods as well.
--
-- Event data used by Jetpack:
-- {new_unit_number = uint, old_unit_number = uint,
--  new_character = luaEntity, old_character = luaEntity}
--
-- Additional (optional) event data used by Bob's classes:
-- player_index = uint,
-- editor_mode = boolean, god_mode = boolean
interface_functions.on_character_swapped = function(event)
  minime.entered_function({event})

  local new_char = event.new_character
  local new = new_char and new_char.name

  local old_char = event.old_character
  local old = old_char and old_char.name
  local old_id = event.old_unit_number

  -- A player may already be without character (i.e., be in editor or god mode)
  -- when the old character is changed (e.g. Jetpack character runs out of fuel).
  -- In this case, we must update the detached character stored with the player.
  local player = (event.player_index and game.get_player(event.player_index)) or
                  (new_char and (new_char.player or new_char.associated_player)) or
                  (old_char and (old_char.player or old_char.associated_player))
  local p_data, char_data

  -- We've got the player from event data
  if player then
    p_data = mod.player_data and mod.player_data[player.index]

    minime.writeDebug("Swapped character of %s from \"%s\" to \"%s\"!",
                      {minime.print_name_id(player), old or "nil", new or "nil"})

    -- Player switched to another character
    if new then
      -- Lookup character properties in dictionary
      minime.writeDebug("Looking up data for character %s!", {new})
      char_data = mod.minime_character_properties and
                  mod.minime_character_properties[new]
      -- We have data for character with this name!
      if char_data then
        -- Adjust player data
        p_data.flying = char_data.flying
        p_data.bob_class = char_data.bob_class

        -- Simulate GUI click to select new character
        if minime.character_selector then
          if (p_data.god_mode or p_data.editor_mode) and not old then
            p_data.god_mode = nil
            p_data.editor_mode = nil
            minime.writeDebug("Reset flags for editor/god mode!")
          end
          minime_gui.select_character(player, char_data.button)
          minime_gui.selector.gui_update(player)

        -- Get the base character from the button name that we've stored with the
        -- character prototype
        elseif char_data.button then
          p_data.last_character = char_data.button:gsub("^"..minime.character_button_prefix, "")
        end

        -- Make sure the preview characters have the correct armor
        minime_player.update_armor({player_index = player.index})

      -- Something went wrong!
      else
        minime.arg_err(char_data, "known character")
      end

    -- Player switched to God or Editor mode
    else
  minime.writeDebug("Player %s switched to God or Editor mode!", {player.index})
      p_data.last_character = ""
      p_data.god_mode = event.god_mode
      p_data.editor_mode = event.editor_mode

      if minime.character_selector then
        minime.writeDebug("Updating GUI of %s", minime.argprint(player))
        minime_gui.selector.gui_update(player)
      end
    end

  -- Try to get the player from detached characters
  else
    minime.writeDebug("Looking for detached character %s",
                      {old_char and old_char.unit_number or "nil"})


    if old_id and mod.detached_characters then
      local p = mod.detached_characters[old_id]
      p_data = p and mod.player_data and mod.player_data[p]
      if p_data then
minime.writeDebug("Updating detached character!")
        -- Update pointer from detached character to player
        if new_char and new_char.valid then
          mod.detached_characters[new_char.unit_number] = p
        end
        mod.detached_characters[old_id] = nil

        p_data.detached_character = new_char
        -- Update class and flying state
        char_data = mod.minime_character_properties and
                    mod.minime_character_properties[new]
        if char_data then
          p_data.flying = char_data.flying
          p_data.bob_class = char_data.bob_class
        end
      end

      -- We're still in god or editor mode, so we can skip the GUI update!

      -- Make sure the preview characters have the correct armor
      minime_player.update_armor({player_index = p})
    end
  end

  minime.entered_function("leave")
end


-- For mods like Kagebunshin_mode that want to create a "clone" of the player's
-- character which should look like the character, but that don't care about class
-- properties or flying state. (In this mod, the clone can't be manipulated by the
-- player, but will start exploring from the player position until it hits an
-- obstacle. A flying character would actually be cheaty because it would go on
-- until it hits the end of the map.)
interface_functions.get_character_basename = function(player)
  minime.entered_function({player})

  player = minime.ascertain_player(player)
  local ret
  if player and player.valid then
    ret = minime_character.get_character_basename(player)
  end

minime.show("ret", ret)

  minime.entered_function("leave")
  return ret
end


-- Bob's Classes compatibility
-- A character class will be changed. Get the name of the new character that should
-- be created.
interface_functions.bob_class_pick_character = function(player, class_data)
  minime.entered_function({player, class_data})

  player = minime.ascertain_player(player)
  if not (player and player.valid) then
    minime.arg_err(player,"player specification")
  end

  local ret
  local p_data = mod.player_data and mod.player_data[player.index]
  local class = class_data and class_data.class_name
minime.show("p_data", p_data)
  minime.writeDebug("Bob's classes: Player %s changed class to \"%s\"",
                    {player.index, class})

  -- Store new class with player data!
  p_data.bob_class = class

  -- Pick the new character
  ret = minime_character.pick_character_version(player)

minime.show("ret", ret)

  minime.entered_function("leave")
  return ret
end


-- Bob's classes: classes have been added or removed
interface_functions.bob_classes_update = function()
  minime.entered_function()

  if not next(mod) then
minime.writeDebug("Must initialize game!")
    --~ init()
    init({name = "on_init"})
  end
  minime_character.update_character_list()

  minime.entered_function("leave")
end


-- Bob's classes: entity died, get entity.player/entity.associated_player
interface_functions.on_entity_died = function(event)
  minime.entered_function({event})

  minime_corpse.on_entity_died(event)

  minime.entered_function("leave")
end

-- First_One_Is_Free/InfiniteInventory: Main inventory changed size because of
-- changed player.character_inventory_slots_bonus. Shift contents of dummy's main
-- inventory slots up or down, so they're not overwritten when we make a backup of
-- the character!
interface_functions.main_inventory_resized = function(player)
  minime.entered_function({player})

  minime_inventories.main_inventory_resized(player)

  minime.entered_function("leave")
end



------------------------------------------------------------------------------------
--                           REGISTER REMOTE INTERFACES!                          --
------------------------------------------------------------------------------------
minime_if.attach_interfaces = function()
  minime.entered_function()

    if remote.interfaces['minime'] then
      log("Remote interface already exists!")
    else
      log("Adding remote interface \"minime\".")
      remote.add_interface('minime', interface_functions)
    end
    log("Interface has these functions: " .. serpent.line(remote.interfaces["minime"]))

  minime.entered_function("leave")
end

------------------------------------------------------------------------------------
--                          UNREGISTER REMOTE INTERFACES!                         --
------------------------------------------------------------------------------------
minime_if.detach_interfaces = function()
  minime.entered_function()

  local removed = remote.remove_interface('minime')
  local msg = removed and "Removed remote interface!" or "Couldn't remove remote interface!"

  if game then
    minime.writeDebug(msg)
  else
    log(msg)
  end

  minime.entered_function("leave")
end

------------------------------------------------------------------------------------
minime.entered_file("leave")
return minime_if
