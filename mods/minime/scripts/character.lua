minime.entered_file()

local minime_character = {}


------------------------------------------------------------------------------------
-- Copy properties. Some properties exist only if the character is connected to a --
-- player. Therefore, we can't set them to the dummy character, but have to store --
-- them in a separate table in mod.player_data.                                   --
------------------------------------------------------------------------------------
local function copy_properties(src, dst, flags)
  minime.entered_function({src, dst, flags})

  local index = (src.player and src.player.index) or
                (dst.player and dst.player.index)

minime.show("src", src)
minime.show("src.force", src and src.force)
minime.show("dst", dst)
minime.show("dst.force", dst and dst.force)

  local force = src.force or dst.force

  local keep_opened = flags and flags.keep_opened
minime.show("keep_opened", keep_opened)

  local restore_from_dummy

  -- Source is connected to a player. Copy from character to table!
  if src.player then
    minime.writeDebug("Copying to mod.player_data[%s].char_properties", {index})
    dst = mod.player_data[index].char_properties

    -- When copying from the character, also copy character_inventory_slots_bonus to
    -- the dummy, so its inventory size will be the same as the current character's.
    local dummy = mod.player_data[index].dummy
    dummy.character_inventory_slots_bonus = src.character_inventory_slots_bonus
minime.show("Set dummy.character_inventory_slots_bonus", dummy.character_inventory_slots_bonus)

  -- Destination is connected to a player. Copy from table to character!
  elseif dst.player then
    minime.writeDebug("Copying from mod.player_data[\"%s\"].char_properties",
                      {index})
    src = mod.player_data[index].char_properties
    restore_from_dummy = true
  end

minime.show("src", src)
minime.show("dst", dst)
minime.show("restore_from_dummy", restore_from_dummy)


  for property, p in pairs(minime.copyable_character_properties) do
minime.writeDebug("%s: %s", {property, p})

    -- Property does not depend on a tech, or the prerequisite tech has been researched
    if (not p.need_techs) or
        minime_forces.is_tech_researched(force, p.need_techs) then
minime.show("src["..property.."]", src[property])
      -- When copying to a character, make sure we still can use the GUI from
      -- src.opened! (It may belong to an entity that has become invalid.)
      if property == "opened" then
        if restore_from_dummy then
          local msg
minime.show("src.opened", src.opened)
minime.show("minime.gui_types[src.opened]", minime.gui_types[src.opened])

------------------------------------------------------------------------------------
-- TODO:
-- As of Factorio 2.0.11, there still is a bug that prevents us to set dst.opened to
-- a value from defines.gui_type. We work around it for now by ignoring all numbers
-- except for defines.gui_type.controller and defines.gui_type.none, which we will
-- handle separately. (See https://forums.factorio.com/viewtopic.php?f=30&t=117362)
          if src.opened and (type(src.opened) == "number" or src.opened.valid) then
minime.show("dst.player", dst.player)
            dst.opened = src.opened
            msg = "Opened GUI: %s!"

          else
            msg = "%s is not a valid GUI!"
          end
          minime.writeDebug(msg, {minime.argprint(src.opened)})
          --~ local t = type(src.opened)
          --~ if src.opened and t ~= "number" and src.opened.valid then
--~ minime.show("dst.player", dst.player)
            --~ dst.opened = src.opened
            --~ msg = "Opened GUI: %s!"

          --~ elseif src.opened == defines.gui_type.controller then
            --~ minime.writeDebug("Opening controller GUI!")
--~ minime.show("dst.player", dst.player)
            --~ dst.opened = dst.player

          --~ elseif src.opened == defines.gui_type.none then
            --~ minime.writeDebug("Setting dst.opened to defines.gui_type.none!")
            --~ dst.opened = nil

          --~ else
            --~ msg = "%s is not a valid GUI!"
          --~ end
          minime.writeDebug(msg, {minime.argprint(src.opened)})
------------------------------------------------------------------------------------

        elseif keep_opened then
          minime.writeDebug("Must keep currently stored GUI!")

        else
          local gui
          if src.opened then
            gui = src.opened
            minime.writeDebug("Using src.opened!")
          elseif src.opened_gui_type and minime.gui_types[src.opened_gui_type] then
            gui = src.opened_gui_type
            minime.writeDebug("Using src.opened_gui_type!")
          elseif src.player and src.player.valid and src.player.opened_self then
            gui = src.player
            minime.writeDebug("Using src.player!")
          end
          dst[property] = gui
        end
      -- Fix for https://pastebin.com/pdRvMxZN
      elseif property == "selected" then
        if src[property] and src[property].valid and
             -- If the player already has selected something else, keep the selected entity!
             not (dst[property] and dst[property].valid) then

          dst[property] = table.deepcopy(src[property])
        end

      -- Changing color will raise an event, so we only do that if the colors differ!
      elseif property == "color" and minime.compare_colors(src.color, dst.color) then
        minime.writeDebug("Color hasn't changed, no need to copy it!")

      else
        dst[property] = table.deepcopy(src[property])
      end

      minime.writeDebug("Copied \"%s\":\t%s",
                        {property, minime.argprint(dst[property])})
    end
  end

  minime.entered_function({src, dst}, "leave")
end

------------------------------------------------------------------------------------
--                               Get character data!                              --
------------------------------------------------------------------------------------
-- Temporary lists
local jetpack_chars = {}
local bobclass_chars = {}
local bobclasses = {}

-- Jetpack compatibility
local function find_jetpack_character(char)
  minime.entered_function({char})

  minime.check_args(char, "string", "character name")

  local ret

  local pattern = string.upper("^"..char..minime.jetpack_pattern):gsub("-", "%%-")

  for jet_char, j in pairs(jetpack_chars) do
    if jet_char:upper():find(pattern) then
      minime.writeDebug("\"%s\" matches pattern \"%s\"", {jet_char, pattern})
      ret = jet_char
      break
    end
  end

  minime.entered_function("leave")
  return ret
end


-- Bob's classes compatibility
local function find_bobclass_characters(char)
  minime.entered_function({char})

  minime.check_args(char, "string", "character name")

  local pattern
  local ret = {}

  for c_name, c_data in pairs(bobclasses) do
    ret[c_name] = {}
    if c_name == "balanced" then
      ret[c_name].character = char
      ret[c_name].jetpack = next(jetpack_chars) and find_jetpack_character(char)
    else
      for bobclass_char, bobclass in pairs(bobclass_chars) do
        if char == "character" then
          pattern = ("^" .. c_data.pattern):gsub("-", "%%-")
        else
          pattern = (char .. ".*-" .. c_data.pattern):gsub("-", "%%-")
        end

        if c_name == bobclass and bobclass_char:find(pattern) then
          minime.writeDebug("%s matches pattern %s", {bobclass_char, pattern})
          ret[c_name].character = bobclass_char
          ret[c_name].jetpack = next(jetpack_chars) and find_jetpack_character(bobclass_char)
          break
        end
      end
    end
  end

  minime.entered_function({char}, "leave")
  -- Return ret if it's not an empty table, or nil
  return next(ret) and ret
end


------------------------------------------------------------------------------------
--          Compile list of character properties stored with player data          --
------------------------------------------------------------------------------------
minime_character.get_minime_character_properties = function(character)
  minime.entered_function({character})

  local chars
  if character then
    minime.show("Function was called for single character", character)
    chars = mod.minime_characters and
            mod.minime_characters[character] and
            { [character] = mod.minime_characters[character] }
  else
    minime.writeDebug("Must get properties of all known characters!")
    chars = mod.minime_characters
  end
minime.show("chars", chars)

  local ret = {}

  for char, c_data in pairs(chars or {}) do

    -- Use data from Bob's classes, if they exist
    if c_data.bobclasses then
minime.writeDebug("Looking for characters from Bob's classes!")
      for class, data in pairs(c_data.bobclasses) do
minime.writeDebug("Adding data for character \"%s\"", {data.character})
        if data.character then
          ret[data.character] = {
            bob_class = class,
            button = minime.character_button_prefix .. char,
            base_name = char,
          }
        end
        if data.jetpack then
minime.writeDebug("Adding data for flying character \"%s\"", {data.character})
          ret[data.jetpack] = {
            bob_class = class,
            button = minime.character_button_prefix .. char,
            base_name = char,
            flying = true,
          }
        end
      end

    -- Use data from base character
    else
minime.writeDebug("Looking for base characters")
minime.writeDebug("Adding data for character \"%s\"", {c_data.character})
      ret[c_data.character] = {
        button = minime.character_button_prefix .. char,
        base_name = char,
      }
      if c_data.jetpack then
minime.writeDebug("Adding data for flying character \"%s\"", {c_data.jetpack})
        ret[c_data.jetpack] = {
          button = minime.character_button_prefix .. char,
          base_name = char,
          flying = true,
        }
      end
    end
  end

  -- Add corpse name to all characters
  local protos = prototypes.get_entity_filtered({
    {filter = "type", type = "character"},
  })
  local proto
  for c_name, c_data in pairs(ret) do
    proto = protos[c_name]
    c_data.corpse = proto and proto.character_corpse and proto.character_corpse.name
  end

  minime.entered_function("leave")
  return ret
end


------------------------------------------------------------------------------------
--         When returning from editor/god mode, reattach stored character!        --
------------------------------------------------------------------------------------
local function announce_swapped_character(data)
  minime.entered_function({data})

  local player = minime.ascertain_player(data.player)
  if not (player and player.valid) then
    minime.arg_err(player, "player specification")
  end

  local old_char  = data.old_character and data.old_character.valid and
                      data.old_character or nil
  local old_id    = data.old_unit_number or (old_char and old_char.unit_number)
  local new_char  = data.new_character and data.new_character.valid and
                      data.new_character or nil
  local new_id    = data.new_unit_number or (new_char and new_char.unit_number)


  local pass_on = {
    player_index = player.index,
    old_character = old_char,
    new_character = new_char,
    old_unit_number = old_id,
    new_unit_number = new_id,
    god_mode = data.god_mode,
    editor_mode = data.editor_mode
  }

  -- Raise custom event
  local event_id = minime.minime_event_ids and
                    minime.minime_event_ids.minime_exchanged_characters
--~ minime.show("minime.minime_event_ids", minime.minime_event_ids)
minime.show("event_id", event_id)
  minime.writeDebugNewBlock("Try to raise event for exchanging characters?")
  if event_id then
    minime.writeDebug("Yes: raising event %s!", {event_id})
    script.raise_event(event_id, pass_on)
  else
    minime.writeDebug("No: not active!")
  end

  -- Remote calls
  minime.writeDebugNewBlock("Trying to tell Jetpack that we swapped the character!")
  pass_on.player_index = nil
  pass_on.god_mode = nil
  pass_on.editor_mode = nil
  minime.remote_call("jetpack", "swap_jetpack_character", pass_on)

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--  Make sure character and player are on the same surface, at the same position! --
------------------------------------------------------------------------------------
local function teleport(move_this, target)
  minime.entered_function({move_this, target})

  minime.assert(move_this, {"LuaPlayer", "LuaEntity"}, "entity to be moved")
  minime.assert(target, {"LuaPlayer", "LuaEntity"}, "target entity")

  local player = (move_this.object_name == "LuaPlayer" and move_this) or
                  (target.object_name == "LuaPlayer" and target)
  if not player and player.valid then
    minime.arg_err(player, "player specification")
  end
minime.show("player", player)

  local ret

  -- We can teleport players across surfaces
  if move_this.object_name == "LuaPlayer" then
    minime.writeDebug("Teleporting player!")
    -- Final value of ret will be the target character
    -- teleport(position, surface, raise_teleported)
    ret = move_this.teleport(target.position, target.surface, true)
    ret = ret and target

  -- We can't teleport characters to another surface, …
  elseif move_this.object_name == "LuaEntity" and move_this.type == "character" then
    -- … but it works on the same surface, so the combat bots following this
    -- character can path to it, if they survive long enough.
minime.show("move_this.surface == target.surface", move_this.surface == target.surface)
    if (move_this.surface == target.surface) then
      minime.writeDebug("Teleporting character on same surface!")
      ret = move_this.teleport(target.position, nil, true)
      ret = ret and move_this


    -- We can, kind of, teleport the character to another surface by creating a
    -- clone there and removing the original. As this is expensive, it is the last
    -- option we resort to. For the same reason, we will leave any following combat
    -- bots behind on the old surface.
    else
      minime.writeDebug("Cloning character to other surface!")
      ret = move_this.clone({
        position = target.position,
        surface = target.surface,
        force = target.force,
        create_build_effect_smoke = false
      })
    end
minime.show("ret", ret)

    -- Announce new character
    if ret and ret.valid and move_this ~= ret then
minime.writeDebug("Announcing character swap!")
      announce_swapped_character({
        player          = player.index,
        old_character   = move_this,
        old_unit_number = move_this and move_this.valid and
                                        move_this.unit_number or nil,
        new_character   = ret,
        new_unit_number = ret.unit_number,
      })
      move_this.destroy()
minime.writeDebug("Destroyed original character!")
    end
  end

minime.show("ret", ret)
  minime.entered_function("leave")
  return ret
end


------------------------------------------------------------------------------------
--         Before entering editor/god mode, store the player's character!         --
------------------------------------------------------------------------------------
local function detach_character(player, flags)
  minime.entered_function({player, flags})

  player = minime.ascertain_player(player)
  if not player and player.valid then
    minime.arg_err(player, "player specification")
  end

  if not mod.player_data[player.index] then
    minime_player.init_player({player = player})
  end
  local player_data = mod.player_data[player.index]

  minime.assert(flags, {"table", "nil"}, "table or nil")
  local skip_announce = flags and flags.skip_announce
  local skip_detach   = flags and flags.skip_detach


  local old_char = player.character

  -- Store player's old character
minime.show("player_data.detached_character", player_data.detached_character)
  player_data.detached_character = old_char
  minime.writeDebug("Stored detached %s with %s!",
                    {minime.argprint(old_char), minime.argprint(player)})

  -- Store player that the character belongs to. This may help us to identify the
  -- player in interface_functions.on_character_swapped()!
  mod.detached_characters = mod.detached_characters or {}
  mod.detached_characters[old_char.unit_number] = player.index
  minime.writeDebug("Stored %s with detached character %s!",
                    {minime.argprint(player), old_char.unit_number})

  -- Update last character in player_data (needed when toggling editor mode)
  player_data.last_character = ""
  player_data.char_entity = nil

  -- Detach old character. We will skip this when called from SE_remote_view_started
  -- as other mods responding to the same event may expect the character to be still
  -- attached to the player!
  if skip_detach then
    minime.writeDebug("Called by %s: won't detach character from player yet!",
                        {minime.enquote("SE_remote_view_started")})
  else
    minime.writeDebug("Detaching character from player!")
    player.character = nil

    -- Mark next on_player_controller_changed event for player to be ignored
    do
      local e_name = "on_player_controller_changed"
      minime.writeDebug("Marking next %s event for %s as ignored!",
                        {e_name, minime.argprint(player)})
      minime_events.setup_skip_event(e_name)
      mod.skip_events[e_name][player.index] = true
    end

    -- Announce character change
    minime.writeDebugNewBlock("Announce change?")
    if skip_announce then
      minime.writeDebug("No: forbidden by flag!")
    else
      minime.writeDebug("Yes!\nPlayer: %s\told_char: %s\tnew_char: %s",
                      {minime.argprint(player), minime.argprint(old_char), "nil"})
      announce_swapped_character({
        player = player,
        old_character = old_char,
        new_character = nil,
        editor_mode = player_data.editor_mode,
        god_mode = player_data.god_mode,
      })
    end
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--  Entering editor/god mode: remove player's character and announce the change!  --
------------------------------------------------------------------------------------
local function detached_character(player, old_id)
  minime.entered_function({player, old_id})

  player = minime.ascertain_player(player)
  if not player and player.valid then
    minime.arg_err(player, "player specification")
  end

  if not mod.player_data[player.index] then
    minime_player.init_player({player = player})
  end
  local player_data = mod.player_data[player.index]
  local old_char = player_data.detached_character
  old_id = old_id or (old_char and old_char.valid and old_char.unit_number) or nil

  -- Announce character change
  minime.writeDebug("Player: %s\told_char: %s\told_id: %s\tnew_char: nil",
      {minime.argprint(player), minime.argprint(old_char), minime.argprint(old_id)})
  announce_swapped_character({
    player = player,
    old_character = old_char,
    old_unit_number = old_id,
    new_character = nil,
    new_unit_number = nil,
    editor_mode = player_data.editor_mode,
    god_mode = player_data.god_mode,
  })

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--         When returning from editor/god mode, reattach stored character!        --
-- When called on account of SE_custom_event_remote_view_stopped, it has already  --
-- reattached the character, so we will just remove it from our data!             --
------------------------------------------------------------------------------------
local function reattach_character(player, flags)
  minime.entered_function({player, flags})

  player = minime.ascertain_player(player)
  if not (player and player.valid) then
    minime.arg_err(player, "player specification")
  end

  minime.assert(flags, {"table", "nil"}, "table of flags or nil")
  local skip_teleporting = flags and flags.skip_teleporting
  local skip_attach = flags and flags.skip_attach

  local ret
  local player_data = mod.player_data[player.index]
  local character = player_data and player_data.detached_character
minime.show("Detached character", character)

  if character and character.valid then
    minime.writeDebug("%s has a valid detached character!", minime.argprint(player))

    -- Remove data of detached character
    local function remove_char_data()
      if mod.detached_characters then
        mod.detached_characters[character.unit_number] = nil

        if not next(mod.detached_characters) then
          mod.detached_characters = nil
        end
      end
      player_data.detached_character = nil
      minime.writeDebug("Removed data of detached character %s",
                        {minime.argprint(character)})
    end

    -- We skip teleporting when we return from SE's remote view
    minime.writeDebugNewBlock("Teleport?")
    if skip_teleporting then
      minime.writeDebug("No! Ignore setting \"character_follows_player\"?")

      if skip_attach then
        minime.writeDebug("Yes: character has already been attached!")
      elseif not player.character then
        minime.writeDebug("No: attaching character!")
        player.character = character
        player_data.char_entity = player.character
      end
      minime.writeDebug("Character of %s: %s",
                        {minime.argprint(player), minime.argprint(character)})

      -- Clean up data
      remove_char_data()

      ret = true

    -- Player and character are detached and may be at different positions. Before
    -- we reattach them, we will move either the player to the character's position
    -- ("player follows character") or the character to the player's position ("char-
    -- acter follows player").
    else
      minime.writeDebug("Yes: must teleport!")
      local character_follows_player = player_data.settings.character_follows_player
      local move_this, target
      move_this   = character_follows_player and character or player
      target      = character_follows_player and player or character

      -- Clean up
      minime.writeDebug("Removing character data!")
      remove_char_data()

      -- Returns the original character if teleporting worked, or a clone of the
      -- original character
      minime.writeDebugNewBlock("Teleporting %s!", {minime.argprint(move_this)})
      character = teleport(move_this, target)
      if character and character.valid then
        minime.writeDebug("Teleported %s. Reattaching %s!",
                          {minime.argprint(move_this), minime.argprint(target)})
        player.character = character
        player_data.char_entity = player.character
        ret = true
      else
        error(string.format("Couldn't teleport %s from %s on %s to %s on %s!",
          minime.argprint(move_this),
          minime.argprint(move_this.position),
          minime.argprint(move_this.surface),
          minime.argprint(target.position),
          minime.argprint(target.surface)
        ))
      end
    end

  -- No character stored
  elseif not character then
    minime.writeDebug("No character found!")

  -- Stored character has become invalid. Remove all entries of characters
  -- detached by player from mod table!
  else
    minime.writeDebug("Character is not valid!")
    player_data.detached_character = nil
    minime.writeDebug("Removed character from player data.")
    -- mod.detached_characters: table of player.index indexed by char.unit_number
    for c_id, c_player in pairs(mod.detached_characters or {}) do
      if c_player == player.index then
        mod.detached_characters[c_id] = nil
        minime.writeDebug("Removed mod.detached_characters[%s].", {c_id})
      end
    end
    if mod.detached_characters and not next(mod.detached_characters) then
      mod.detached_characters = nil
      minime.writeDebug("Removed mod.detached_characters!")
    end
  end
minime.show("ret", ret)

  minime.entered_function("leave")
  return ret
end



------------------------------------------------------------------------------------
--                        Wrapper for toggling editor mode!                       --
-- Editor mode may be toggled by other means than our GUI. When we toggle editor  --
-- mode, set a flag (and remove it again when we're finished). This way, we can   --
-- determine if we really must act in the triggered events.                       --
------------------------------------------------------------------------------------
local function toggle_map_editor(player)
  minime.entered_function({player})

  player = minime.ascertain_player(player)
  if not (player and player.valid) then
    minime.arg_err(player, "player specification")
  end

  local player_data = mod.player_data[player.index]
  minime.writeDebug("Setting  \"raise_toggle_editor\" flag!")
  player_data.raise_toggle_editor = true

  player.toggle_map_editor()

  player_data.raise_toggle_editor = nil
  minime.writeDebug("Cleared \"raise_toggle_editor\" flag!")

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                      Add data to the character prototypes                      --
-- If called without argument (when the game is initialized), this function will  --
-- add data to all characters stored in mod.minime_characters. An argument is     --
-- used if the function is called by another mod via register_characters from the --
-- remote interface.                                                              --
------------------------------------------------------------------------------------
minime_character.set_character_data = function(char_name)
  minime.entered_function({char_name or "nil"})

  -- char_name may be nil, but if it isn't, it must be a string!
  minime.assert(char_name, {"string", "nil"}, "character name or nil")

  -- If called via the remote interface, we should add char_name to the mod
  -- table. If there is no prototype of that name, we'll remove it later on.
  if char_name then
    mod.minime_characters[char_name] = mod.minime_characters[char_name] or {}
minime.show("mod.minime_characters["..char_name.."]", mod.minime_characters[char_name])
  end

  -- If called via the remote interface, add data for just one character!
  local list = char_name and {[char_name] = {}} or mod.minime_characters

  local protos = prototypes.get_entity_filtered({
    {filter = "type", type = "character"},
  })

  for c_name, c_data in pairs(list) do
minime.show("Prototype " .. c_name .. " exists", protos[c_name] and true or false)
    -- Normal: Character prototype is available
    if protos[c_name] then
      mod.minime_characters[c_name].character = c_name
      mod.minime_characters[c_name].loc_name = minime.loc_name(protos[c_name])

      -- Find the matching character from "Jetpack" mod
      if next(jetpack_chars) then
        mod.minime_characters[c_name].jetpack = find_jetpack_character(c_name)
      end

      -- Initialize character classes?
      if next(bobclass_chars) then
minime.writeDebug("Calling find_bobclass_characters(%s)!", {c_name})
        mod.minime_characters[c_name].bobclasses = find_bobclass_characters(c_name)
      end

    -- Something went wrong: Remove character from list
    else
      mod.minime_characters[c_name] = nil
      minime.writeDebug("Removed character %s from list -- prototype doesn't exist!", {c_name})
    end
  end
minime.show("mod.minime_characters", mod.minime_characters)

  minime.entered_function("leave")
end



------------------------------------------------------------------------------------
--                          Get base name of a character                          --
------------------------------------------------------------------------------------
minime_character.get_character_basename = function(player_or_char)
  minime.entered_function({player_or_char})

  -- If we've got a player, use name of player.character or player's last character
  -- if the player is in god/editor mode!
  local player = minime.ascertain_player(player_or_char)
minime.show("player", player)
  local char_name

  if player and player.valid then
    minime.writeDebug("Valid player!")
    local p_data = mod.player_data and mod.player_data[player.index]

    -- Get player's last_character, it's already the base name!
    char_name = p_data.last_character
minime.show("char_name", char_name)

    -- We will always have p_data.detached_character if the player is in god mode,
    -- and we may have it if the player is in editor mode. (Player must have switched
    -- to it directly from god mode.)
    if not (char_name and char_name ~= "") then
      minime.writeDebug("Looking for detached character!")

      local char = p_data.detached_character
minime.show("detached character", char)

      char_name = char and char.valid and char.name
minime.show("char_name", char_name)
    end

  -- No player or no valid character
  else
    minime.writeDebug("No player! Did we get a character or character name?")
    minime.assert(player_or_char, {"LuaEntity", "string"},
                                  "character or character name")

    char_name = (type(player_or_char) == "string" and player_or_char) or
                (player_or_char.valid and player_or_char.type == "character" and
                                          player_or_char.name) or
                nil
minime.show("char_name", char_name)
  end

  local ret = char_name and mod.minime_character_properties[char_name] and
                            mod.minime_character_properties[char_name].base_name
minime.show("ret", ret)

  minime.entered_function("leave")
  return ret
end


------------------------------------------------------------------------------------
--           Compile list of character prototypes available in the game           --
-- (sorted by name of characters base version, if Bob's classes or Jetpack exist) --
------------------------------------------------------------------------------------
minime_character.make_character_list = function()
  minime.entered_function()

  -- Find all character prototypes
  local characters = prototypes.get_entity_filtered({
    {filter = "type", type = "character"}
  })


  --  Get Bob's classes, if they exist
  minime.writeDebug("Checking for remote interface from Bob's classes")
  if remote.interfaces["bobclasses"] and
      remote.interfaces["bobclasses"].get_classes then

    -- Make a temporary list of all classes
    local classes = {}
    for class, c_data in pairs(remote.call("bobclasses", "get_classes") or {}) do
      c_data.class_name = class
      classes[#classes + 1] = c_data
    end

    -- If a class has multiple tiers (e.g. builder and builder-2), the tiered
    -- class must be sorted after the base class!
    table.sort(classes, function(a, b) return a and b and a.class_name < b.class_name end)

    -- Translate temporary table to sorted dictionary indexed by class names
    for c, class in pairs(classes) do
      bobclasses[class.class_name] = {
        -- Not sure if we'll really need the bonuses, but they may be useful!
        bonuses = class.bonuses,
        pattern = class.entity_name,
      }
    end
  end

  ------------------------------------------------------------------------------------
  -- We'll always need the base character!
  mod.minime_characters = {
    -- Use empty tables for now. They will be filled when we've found all characters
    -- that will be used in the GUI!
    ["character"] = {}
  }

minime.show("mod.minime_characters", mod.minime_characters)

  ------------------------------------------------------------------------------------
  -- Find characters with a name matching our pattern
  local name

  local ignore_patterns = {
    script.active_mods["jetpack"] and minime.jetpack_pattern,
    script.active_mods["bobclasses"] and minime.bobclasses_pattern,
    script.active_mods["RenaiTransportation"] and minime.renaitransportation_pattern,
    script.active_mods["katamari"] and minime.katamari_pattern,
  }
  local function add_to_list(chars, by_remote_call)
    local addit, ignored, removed

    for char, c in pairs(chars) do
      name = char:upper()
      -- Find characters that should be added to the GUI
      addit = false
      removed = false
      if (by_remote_call and characters[char]) or name:find(minime.pattern) then
        -- Add character unless the name also matches a pattern from the ignore list!
        addit = true
        for p, pattern in pairs(ignore_patterns) do
          if name:find(pattern, 1, true) then
            addit = false
            break
          end
        end
      elseif by_remote_call then
        mod.mod_registered_characters[char] = nil
        removed = true
      end

      -- If the mod that added the character has been removed from the game, neither
      -- the character nor its derivatives won't be available!
      if removed then
        minime.writeDebug("Removed \"%s\" from list of characters added by mods!",
                          {char})

      -- Add character to list for GUI buttons
      elseif addit then
        mod.minime_characters[char] = {}
        minime.writeDebug("ADDED character \"%s\".", {char})

      -- We don't want this character on the GUI, but perhaps we need it for
      -- compatibility with other mods!
      else
        ignored = true

        -- Jetpack
        if name:find(minime.jetpack_pattern, 2, true) then
          jetpack_chars[char] = true
          ignored = false
          minime.writeDebug("FOUND flying character \"%s\" from \"jetpack\".", {char})
        -- Bob's classes
        elseif next(bobclasses) then
          for class, c_data in pairs(bobclasses) do
            -- Skip "balanced" class: It's associated with the vanilla character,
            -- so the pattern is too general and will match too many names.
            if class ~= "balanced" then
              -- A pattern like "builder" would match both "bob-character-builder" and
              -- "bob-character-builder-2". But as bobclasses is a dictionary sorted by
              -- ascending order of class names, bobclass_chars[char] will be overwritten
              -- by the last pattern matching the name. Caveat: We can't break the loop
              -- after the first match.
              if char:find(c_data.pattern, 1, true) then
                bobclass_chars[char] = class
                ignored = false
                minime.writeDebug("FOUND character \"%s\" from \"Bob's classes\".", {char})
              end
            end
          end
        end
        if ignored then
          minime.writeDebug("IGNORED character \"%s\".", {char})
        end
      end
    end
  end


  add_to_list(characters)

  -- If other mods have registered their characters before we could run on_init or
  -- on_configuration_changed, we must now add these characters, too!
  if mod.mod_registered_characters then
    minime.writeDebugNewBlock("Checking %s characters registered by other mods",
                      {table_size(mod.mod_registered_characters)})
    -- add_to_list(chars, by_remote_call)
    add_to_list(mod.mod_registered_characters, "by_remote_call")
  end

  ----------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------
  -- If "CharSelect" by SpaceCat-Chan is active, get list of provided characters!
  local CS_settings = prototypes.get_mod_setting_filtered({
    {filter = "mod", mod = "CharSelect"},
    {filter = "setting-type", type = "runtime-per-user", mode = "and"}
  })

  -- Look for setting allowing to switch characters! (There's only one setting now, but
  -- more settings could be added in the future.)
  for s, setting in pairs(CS_settings) do
    if setting and setting.name == "Selected-Character" then
      -- Check list of characters allowed by "CharSelect"
      for _, char in ipairs(setting.allowed_values) do
        -- Ignore existing characters and invalid characters
        -- (check against existing list of valid character prototypes)
        if not mod.minime_characters[char] and characters[char] then
          -- Add character to list
          mod.minime_characters[char] = {}
          minime.writeDebug("Added character %s from list of \"%s\".", {char, setting.mod})
        end
      end
      -- We've found the relevant setting and added the characters -- time to quit!
      break
    end
  end


  -- Now that we have made a list of all relevant characters, add the data!
  minime_character.set_character_data()

  -- Make a list of each character's properties that will be used as player data
  mod.minime_character_properties = minime_character.get_minime_character_properties()

minime.show("Final character list", mod.minime_characters)

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                              Update character list                             --
-- Backup current character list, rebuild character list, and remove previews of  --
-- characters from removed mods (surface + entities).                             --
------------------------------------------------------------------------------------
minime_character.update_character_list = function(event)
  minime.entered_function({event})

  ------------------------------------------------------------------------------------
  -- Back up list of character prototypes
  minime.writeDebug("Backing up list of available character prototypes!")
  local character_list_backup = table.deepcopy(mod.minime_characters)

  ------------------------------------------------------------------------------------
  -- Rebuild list of character prototypes
  minime.writeDebug("Creating list of available character prototypes!")
  minime_character.make_character_list()

minime.show("mod.minime_characters", mod.minime_characters)
minime.show("mod.minime_character_properties", mod.minime_character_properties)


  ------------------------------------------------------------------------------------
  -- Destroy preview surfaces and characters for characters from removed mods
  minime.writeDebug("Looking for removed character prototypes!")

  local surface


  -- Match list of characters from the last run against list of current characters
  for old_name, old_data in pairs(character_list_backup or {}) do
minime.writeDebug("old_data.preview: %s", {old_data.preview}, "line")
minime.show("old_data", old_data)
minime.show("\""..old_name.."\" still exists",
            mod.minime_characters[old_name] and true or false)

    -- Old character prototype is no longer available
    if old_data.preview and not mod.minime_characters[old_name] then

      -- Remove character from player data!
      minime.writeDebug("Removing character %s from player data!",
                        {minime.enquote(old_name)})
      for p, p_data in pairs(mod.player_data) do
        -- Last character of the player was flying version of a removed character
minime.show("p_data.last_character", p_data.last_character)
minime.show("p_data.last_character == old_name", p_data.last_character == old_name)
minime.show("p_data.flying", p_data.flying)
        if p_data.last_character == old_name and p_data.flying then
          p_data.flying = nil
          minime.writeDebug("Removed \"flying\" property from data of player %s!", {p})
        end


        -- Remove character from list of characters available on player's GUI
minime.show("p_data.available_characters["..old_name.."]",
            p_data.available_characters and p_data.available_characters[old_name])
        if p_data.available_characters and
            p_data.available_characters[old_name] ~= nil then

          -- Adjust hidden characters count?
          if p_data.hidden_characters and p_data.hidden_characters > 0 and
              not p_data.available_characters[old_name] then
            minime.writeDebug("Character was hidden!")
            p_data.hidden_characters = p_data.hidden_characters -1
          end

          p_data.available_characters[old_name] = nil
          minime.writeDebug("Removed \"%s\" from data of player %s]!",
                            {old_name, p})
        end
      end

      -- Remove preview surfaces?
        minime.writeDebug("Checking mod.minime_characters[%s] for surface data",
                          {minime.enquote(old_name)})
        surface = old_data.preview.surface
minime.show("surface", surface)
        -- Remove surface with all entities, if we have surface data
        if surface and surface.valid then
          minime_surfaces.delete_surface(surface)

        -- If the old surface still exists but we didn't store it for some reason, we
        -- may still be able to access it via the entities
        elseif old_data.preview.entities then
          minime.writeDebug("Checking preview entities for %s!", {minime.argprint(surface)})
          for e, entity in pairs(old_data.preview.entities) do
            if entity.valid and entity.surface and entity.surface.valid then
              minime_surfaces.delete_surface(entity.surface)
            end
          end
        end
    end
  end

  minime.writeDebug("Must update GUI character pages!")
  for p, player in pairs(game.players) do
    if player.connected then
      minime.writeDebug("Making character pages for %s!", {minime.argprint(player)})
      minime_gui.make_gui_character_pages(player)
    else
      minime.writeDebug("Skipping %s (not connected)!", {minime.argprint(player)})
    end
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                            Copy character settings!                            --
------------------------------------------------------------------------------------
minime_character.copy_character = function(src, dst, flags)
  minime.entered_function({src, dst, flags})

  if type(src) ~= "userdata" or not (src.valid and src.type == "character") then
    minime.arg_err(minime.argprint(src), "character (src)")
  elseif type(dst) ~= "userdata" or not (dst.valid and dst.type == "character") then
    minime.arg_err(minime.argprint(dst), "character (dst)")
  else
    minime.assert(flags, {"table", "nil", "table of flags or nil"})
  end

  local copy_to_player  = flags and flags.backup_to_player
  local keep_opened     = flags and flags.keep_opened
minime.show("copy_to_player", copy_to_player)
minime.show("keep_opened", keep_opened)

  ----------------------------------------------------------------------------------
  -- Copy properties
  minime.writeDebugNewBlock("Copying properties!")
  do
    local passon_flags = {keep_opened = keep_opened}
    copy_properties(src, dst, passon_flags)
  end

  ----------------------------------------------------------------------------------
  --~ -- Copying inventory slots may fail if gun and ammo aren't compatible, so clear
  --~ -- the ammo inventories of the destination before copying from source!
  --~ local inventory = dst.get_inventory(defines.inventory.character_ammo)
  --~ if inventory and inventory.valid and not inventory.is_empty() then
    --~ inventory.clear()
    --~ minime.writeDebug("Emptied ammo inventory of %s.", {minime.argprint(dst)})
  --~ end

  -- Copying inventory slots may fail if gun and ammo aren't compatible, so clear
  -- as many ammo ammo slots in the destination as are available in the source!
  local inventory = dst.get_inventory(defines.inventory.character_ammo)
  do
    minime.writeDebugNewBlock("Try to clear ammo slots in destination?")
    if inventory and inventory.valid and not inventory.is_empty() then
      minime.writeDebug("Yes! Do src and dst have the same size?")
      local s_inv = src.get_inventory(defines.inventory.character_ammo)
      if #inventory == #s_inv then
        minime.writeDebug("Yes: clearing destination!")
        inventory.clear()
        minime.writeDebug("Emptied ammo inventory of %s.", {minime.argprint(dst)})
      else
        minime.writeDebug("No: clearing first %s slots in destination!", {#s_inv})
        for s = 1, #s_inv do
          inventory[s].clear()
          minime.writeDebug("Emptied slot %s!", {s})
        end
      end
    else
      minime.writeDebug("No: %s!", {
        (inventory and inventory.valid and "inventory is empty") or
        (inventory and "no valid inventory") or
        "no inventory"
      })
    end
  end

  ----------------------------------------------------------------------------------
  -- Transfer inventories
  minime.writeDebugNewBlock("Transferring items!")
  do
    local s, d, e_name
    for i, inv_name in ipairs(minime.inventory_list) do
      minime.writeDebugNewBlock("%s: Trying to transfer items from %s inventory!",
                                {i, inv_name})
      inventory = defines.inventory["character_"..inv_name]
      s = src.get_inventory(inventory)
      d = dst.get_inventory(inventory)
      -- Mark next on_player_*_inventory_changed events to be ignored if we've
      -- transferred armor/gun inventory items from dummy to player character!
      if minime_inventories.transfer_inventory(s, d) > 0 and copy_to_player and
          (inv_name == "armor" or inv_name == "gun") then

        e_name = string.format("on_player_%s_inventory_changed", inv_name)
        minime.writeDebug("Ignore next %s event for %s!",
                  {e_name, copy_to_player and "player "..copy_to_player or "dummy"})
        minime_events.setup_skip_event(e_name)
minime.show("mod.skip_events["..e_name.."]", mod.skip_events[e_name])
        mod.skip_events[e_name][copy_to_player] = true
      end
    end
  end


  ----------------------------------------------------------------------------------
  -- Post-processing

--TODO: ADJUST THIS FOR FACTORIO 2.0!
  --~ -- Copy settings/filters from Personal logistic slots
  --~ local slots = src.request_slot_count
--~ minime.show("src.request_slot_count", src.request_slot_count)
--~ minime.show("dst.request_slot_count", dst.request_slot_count)

  --~ local id = dst.unit_number
--~ minime.show("dst", dst)
--~ minime.show("id", id)

  --~ local function must_copy(slot)
    --~ local s = src.get_personal_logistic_slot(slot)
    --~ local d = dst.get_personal_logistic_slot(slot)
    --~ return not util.table.compare(s, d) and s
  --~ end
  --~ local copy_this


  --~ local e_name = "on_entity_logistic_slot_changed"
  --~ minime_events.setup_skip_event(e_name)
  --~ local skip = mod.skip_events[e_name]

  --~ local cnt = 0

  --~ for i = 1, slots do
    --~ copy_this = must_copy(i)
    --~ if copy_this then
      --~ minime.writeDebugNewBlock("Marking slot %s for on_entity_logistic_slot_changed!",
                                --~ {i})
      --~ -- Key: unit_number of dummy or player char. Value: slot index
      --~ skip[id] = i

      --~ minime.writeDebug("Copying personal logistic slot %s!", {i})
      --~ dst.set_personal_logistic_slot(i, copy_this)
      --~ cnt = cnt + 1
    --~ else
      --~ minime.writeDebugNewBlock("Ignoring slot %s!", {i})
    --~ end
  --~ end
  --~ minime.writeDebug("Copied %s of %s personal logistic slots from %s to %s.",
                    --~ {cnt, slots, minime.argprint(src), minime.argprint(dst)})
  --~ -- on_entity_logistic_slot_changed will be raised immediately after a slot has
  --~ -- changed, so we can clean up mod.skip_events now!
  --~ minime.writeDebugNewBlock("Trying to clean up mod.skip_events!")
  --~ skip[id] = nil
  --~ minime_events.remove_skip_event(e_name)

  -- Copy settings/filters from Personal logistic slots. This has been severely
  -- fucked up by Factorio 2.0!
  do
    local src_logistics = src.get_requester_point()
minime.show("src_logistics", src_logistics)

    local dst_logistics = dst.get_requester_point()
minime.show("dst_logistics", dst_logistics)

    minime.writeDebugNewBlock("Do we have valid requester points?")
    if src_logistics and src_logistics.valid and
        dst_logistics and dst_logistics.valid then


      -- Update trash_not_requested
      minime.writeDebug("Yes: updating trash_not_requested!")
      dst_logistics.trash_not_requested = src_logistics.trash_not_requested

      -- Update trash_not_requested
      minime.writeDebug("Yes: updating 'enabled' state!")
      dst_logistics.enabled = src_logistics.enabled

      --Update sections
      minime.writeDebugNewBlock("Updating sections!")
      local s_section, d_section

      local function copy_property(p)
        minime.writeDebug("Copy property '%s'?", {p})
        if (d_section[p] == s_section[p]) or
              (type(p) == "table" and
                util.table.compare(s_section[p], d_section[p])) then
          minime.writeDebug("No: src and dst are the same!")
        else
          minime.writeDebug("Yes!")
          d_section[p] = table.deepcopy(s_section[p])
        end
minime.show("d_section[p]", d_section[p])
      end


      for s = 1, src_logistics.sections_count do
        minime.writeDebugNewBlock("Checking section %s!", {s})

        s_section = src_logistics.get_section(s)
        d_section = dst_logistics.get_section(s)

        if s_section and s_section.valid then
          minime.writeDebug("Found valid section in src!")

          -- Create section?
          minime.writeDebug("Does section %s exist in dst?", {s})
          if d_section and d_section.valid then
            minime.writeDebug("Yes!")
            copy_property("group")
          else
            minime.writeDebug("No: adding new section!")
            d_section = dst_logistics.add_section(s_section.group)
          end
minime.show("d_section", d_section)

          minime.writeDebugNewBlock("Copying to section in dst!")
          copy_property("filters")
          copy_property("active")
          copy_property("multiplier")
        end
      end

      if dst_logistics.sections_count > src_logistics.sections_count then
        minime.writeDebugNewBlock("Removing excess sections from dst!")
        for s = src_logistics.sections_count + 1, dst_logistics.sections_count do
          minime.writeDebug("Removing section %s!", {s})
          dst_logistics.remove_section(s)
        end
      end

    else
      minime.writeDebug("No (src: %s, dst: %s)!",
                  {minime.argprint(src_logistics), minime.argprint(dst_logistics)})
    end
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                   Compile list of character-corpse prototypes                  --
------------------------------------------------------------------------------------
minime_character.make_armor_list = function()
  minime.entered_function()

  -- Find all character prototypes
  local armors = prototypes.get_item_filtered({
    {filter = "type", type = "armor"}
  })

  mod.minime_armor_prototypes = {}
  -- Make lookup table to store inventory size boni of the individual armors
  local boni
  for a, armor in pairs(armors) do
    mod.minime_armor_prototypes[armor.name] = {inventory_size_bonus = {}}
    boni = mod.minime_armor_prototypes[armor.name].inventory_size_bonus

    -- Since Factorio 2.0, the bonus depends on quality!
    for quality, q in pairs(prototypes.quality) do
      boni[quality] = armor.get_inventory_size_bonus(quality)
    end
  end
minime.show("mod.minime_armor_prototypes", mod.minime_armor_prototypes)

  minime.entered_function("leave")
end



------------------------------------------------------------------------------------
--                               Switch characters!                               --
------------------------------------------------------------------------------------
-- The GUI just selects a skin, this is about picking a character version for the
-- skin that matches character class, flying state, etc.
minime_character.pick_character_version = function(player)
  minime.entered_function({player})

  player = minime.ascertain_player(player)
  if not (player and player.valid) then
    minime.arg_err(player,"player specification")
  end

  local ret, versions
  local p_data = mod.player_data and mod.player_data[player.index]
  local class = p_data.bob_class
  minime.writeDebug("Bob's classes: Player %s  has class \"%s\"",
                    {player.index, class or "nil"})

  -- Pick the new character
  local skin = p_data.last_character
  if class then
    versions = mod.minime_characters and mod.minime_characters[skin] and
                mod.minime_characters[skin].bobclasses and
                mod.minime_characters[skin].bobclasses[class]
    minime.writeDebug("Using character versions from Bob's classes! Versions for class %s: %s",
                      {class, versions or "nil"})
  else
    versions = mod.minime_characters and mod.minime_characters[skin]
    minime.writeDebug("Using default character versions: ", {versions or "nil"})
  end

  if versions then
    ret = p_data.flying and versions.jetpack or versions.character
  end

minime.show("ret", ret)

  minime.entered_function("leave")
  return ret
end


-- Switch to selected character/leave character mode
minime_character.switch_characters = function(player, flags)
  minime.entered_function({player, flags})

  ------------------------------------------------------------------------------------
  -- We may want to quit early!
  player = minime.ascertain_player(player)
  if not (player and player.valid) then
    minime.arg_err(player, "player specification")
  end

  local controller = minime.controller_names[player.controller_type]
minime.show("controller", controller)

  -- Leave immediately unless we're in default (character), editor, or god mode!
  if controller ~= "character" and controller ~= "editor" and controller ~= "god" then
    minime.entered_function({player, flags}, "leave",
                            "unexpected controller type "..controller)
    return
  end

  minime.assert(flags, {"table", "nil"}, "table of flags, or nil")
  -- Just sync character with dummy if character has been changed by another mod
  local restore = flags and flags.restore
  -- Don't overwrite stored property 'opened' (the GUI opened when the player last
  -- had a character)
  local keep_opened = flags and flags.keep_opened


  ------------------------------------------------------------------------------------
  -- We can proceed. Define some more local stuff!
  local player_data = mod.player_data[player.index]
  if not (player_data.dummy and player_data.dummy.valid) then
    player_data.dummy = minime_player.make_dummy(player)
  end
  local backup = player_data.dummy

  local old_char = player.character
  local old_id = old_char and old_char.valid and old_char.unit_number or nil
minime.show("old_char", old_char)

  -- Store name of the current character. We need it later to determine whether we
  -- must disable its button when a new character on another page has been selected.
  local old_char_name = old_id and minime_character.get_character_basename(old_char)

  local new_char, char_version

  -- Store player's zoom factor, so we can restore it after switching characters!
  local player_zoom = player.zoom
minime.show("player_zoom", player_zoom)

  -- Are any combat bots following the old character?
  local combat_bots = old_char and old_char.valid and old_char.following_robots or {}
minime.show("combat_bots", combat_bots)

  -- Store status of flashlight. Use state of player if there is no character!
  local flashlight = old_char and old_char.valid and
                      old_char.is_flashlight_enabled() or
                      player.is_flashlight_enabled()
minime.show("flashlight", flashlight)

  -- Are we in editor mode? Make this a function so the result is always up to date!
  local function in_editor()
    return controller == "editor"
  end

  -- Switch flashlight of player or character on or off
  local function set_flashlight(entity, state)
    if entity and entity.valid then
        if state then
          entity.enable_flashlight()
        else
          entity.disable_flashlight()
        end
        minime.writeDebug("%sabled flashlight for %s.",
                          {flashlight and "En" or "Dis", minime.argprint(entity)})
    end
  end

  -- Store and clear player's crafting queue
  minime.writeDebugNewBlock("Do we have to consider the crafting queue?")
minime.show("in_editor()", in_editor())
  if in_editor() then
    minime.writeDebug("No: in editor mode!")
  elseif not player.crafting_queue then
    minime.writeDebug("No: not crafting!")
  else
    minime.writeDebug("Yes!")

    player_data.crafting_queue = {}

    local i, item, add_this

    while player.crafting_queue do
      i = player.crafting_queue_size
      item = player.crafting_queue[i]

      -- Store the last crafting queue item. This will be the recipe for a main
      -- product, not a prerequisite recipe!
      add_this = { count = item.count, recipe = item.recipe }
      player_data.crafting_queue[i] = add_this
      minime.writeDebug("Added item to player_data.crafting queue: %s", {add_this})

      -- Remove last recipe (and any prerequisites) from player's crafting queue!
      minime.writeDebug("Cancelling crafting of queue item %s: %s",
                        {i, item}, "line")
      player.cancel_crafting({index = i, count = item.count})
    end
  end

  ------------------------------------------------------------------------------------
  -- We already have a character
  minime.writeDebugNewBlock("Does the player already have a character?")
  if old_char and old_char.valid then
    minime.writeDebug("Yes!")

    -- If character has been changed by another mod, we just make sure the character
    -- is in sync with the dummy (restore inventories and settings from backup)!
    if restore then
      minime.writeDebug("Restore mode: not exchanging characters!")
      new_char = old_char
      player_data.char_entity = new_char

    -- Exchange the characters!
    else
      minime.writeDebug("Exchanging characters!")

      -- Backup inventory and settings from old character while it's still attached
      -- to the player. Otherwise, we may miss some properties!
      local passon_flags = {keep_opened = keep_opened}
      minime_character.copy_character(old_char, backup, passon_flags)
      minime.writeDebug("Copied inventories and settings from %s to %s",
                    {minime.argprint(old_char), minime.argprint(backup)}, "line")

      -- Store position and surface of the old character
      local old_pos = old_char.position
minime.show("Position of old character", old_pos)
      local old_surface = old_char.surface
minime.show("Surface of old character", old_surface)

      -- Check if there really is a version of the new character
      char_version = minime_character.pick_character_version(player)

minime.show("player.character.name",
            player.character and player.character.valid and player.character.name or
                                                            "No (valid) character!")
minime.show("char_version", char_version)
minime.show("player_data.last_character", player_data.last_character)

      -- We've picked a character prototype. Create and switch to new character!
      if player_data.last_character and
          player_data.last_character ~= "" and char_version then

        if char_version ~= old_char.name then
          -- Detach old character so we can create the new one
          player.character = nil

          player.create_character(char_version)
          new_char = player.character
          --~ player_data.char_entity = player.character
minime.show("new_char", new_char)

          announce_swapped_character({
            player = player,
            -- We know old_char is valid, or we wouldn't be here!
            old_character = old_char,
            old_unit_number = old_id,
            -- There's a chance new_char is nil or not valid.
            new_character = new_char,
            new_unit_number = new_char and new_char.valid and new_char.unit_number,
          })
          minime.writeDebug("Created new character %s for player %s",
                            {minime.loc_name(new_char), player.name}, "line")
        else
          minime.writeDebug("Will reuse old character!")
          new_char = old_char
          --~ player_data.char_entity = new_char
        end
minime.show("new_char", new_char)

      -- Player is leaving character mode. Detach and store old character!
      elseif player_data.last_character == "" and
              (player_data.editor_mode or player_data.god_mode) then
        minime.writeDebug("Entering %s mode!",
                          {player_data.god_mode and "god" or "editor"})
minime.show("player_data", player_data)

        -- This is only necessary when switching to god mode as the detached
        -- character will become invalid once we've switched to editor mode!
        if player_data.god_mode and not player_data.detached_character then
          minime.writeDebug("Storing old character!")
          detach_character(player, {skip_announce = true})
        end

        -- Toggle editor mode with toggle_map_editor instead of set_controller to
        -- make sure we trigger on_player_toggled_map_editor! Bob's classes will
        -- update the info text on its GUIs when this event triggers, so we must
        -- fire this event to sync info text and player's actual controller type.
        local ed = in_editor()
minime.show("ed", ed)
        -- Enter editor mode, or switch from editor to god mode
        local enter_ed = (player_data.editor_mode and not ed) and "enter"
        local leave_ed = (ed and not player_data.editor_mode) and "leave"
        if enter_ed or leave_ed then
          minime.writeDebug("Toggling editor mode for %s (%s)!",
                            {minime.argprint(player), enter_ed or leave_ed})
          toggle_map_editor(player)
          minime.writeDebug("Toggled editor mode for %s (%s)!",
                            {minime.argprint(player), enter_ed or leave_ed})
minime.show("player_data.detached_character", player_data.detached_character)

        -- Switch from character to god mode
        else
          player.character = nil
          minime.writeDebug("Detached character of %s! (In editor mode: %s)",
                            {minime.argprint(player), ed})
        end
        detached_character(player, old_id)


      -- Player switched between editor and god mode. No new character!
      elseif controller ~= "character" then
        minime.writeDebug("Couldn't create new character! (Reason: %s mode)",
                          {controller})
      -- Player tried to switch to an unavailable version of a character!
      else
        local reason = char_version and "invalid name "..minime.enquote(char_version)
        if not reason then
          reason = string.format("required version of character not found: %s%s%s",
            (player_data.bob_class and minime.enquote(player_data.bob_class)),
            (player_data.bob_class and player_data.flying and ", " or ""),
            (player_data.flying and "flying" or "")
          )
        end
        minime.writeDebug("Couldn't create new character! (Reason: %s)", {reason})
      end

      -- Remove old character unless we've stored it as detached character
      if old_char and old_char.valid and
          not (player_data.detached_character and
                player_data.detached_character.valid and
                player_data.detached_character.unit_number == old_char.unit_number) then
minime.writeDebug("Old character not stored as detached_character")
        -- Don't remove old char if it's the same as the new one!
        if new_char and new_char.valid then
          if old_char ~= new_char then
            old_char.destroy()
            minime.writeDebug("Removed old character!")
          else
            minime.writeDebug("New character (%s) is the same as old character (%s)!",
                              {minime.argprint(new_char), minime.argprint(old_char)})
          end
        end
      else
        minime.writeDebug("Old character %s!",
                          {old_char and old_char.valid and
                          "has been stored as detached_character" or "does not exist"})
      end

      -- If there was an old character when the new character was created, the new
      -- character couldn't occupy the same position and was moved a bit. Let's move
      -- it back to the old character's place!
      if new_char and new_char.valid and new_char ~= old_char then
        minime.writeDebug("Moving new character from %s to old position: %s",
                          {player.character.position, old_pos}, "line")
        -- teleport(position, surface?, raise_teleported?)
        new_char.teleport(old_pos, nil, true)

        minime.writeDebug("Moved new character to old position: %s",
                          {player.character.position}, "line")
      else
        local no_new = (not new_char and "No new character") or
                        (not new_char.valid and "No valid new character")
        local same = (new_char == old_char) and "Character didn't change"
        minime.writeDebug("%s -- skipped teleporting!", {no_new or same})
      end


    end

  ------------------------------------------------------------------------------------
  -- We don't have a character yet!
  else
    minime.writeDebug("No!")
    -- Create character?
    char_version = minime_character.pick_character_version(player)
minime.show("char_version", char_version)

    -- Player selected a character
    if player_data.last_character and player_data.last_character ~= "" and
                                      char_version then
minime.writeDebug("Player selected a character")
      -- If we are in editor mode, creating a character for the player will crash
      -- the game, so we must turn editor mode off first!
      if in_editor() then
minime.writeDebug("Toggling map editor")
        toggle_map_editor(player)
      end

      -- We now may have player.character (on leaving editor mode) or a detached
      -- character (on leaving god mode). Use those instead of creating a new one!
minime.writeDebug("Looking for detached character")
      local attached = (player_data.detached_character and reattach_character(player)) or
                        (player.character and player.character.valid)
minime.show("attached", attached)

      -- There was a detached character, and we could reattach it!
      if attached then
        minime.writeDebug("Successfully reattached %s. Replacing it with \"%s\" now!", {
          minime.argprint(player.character), player_data.last_character
        })
        new_char = player.character

        -- Announce character change
        announce_swapped_character({
          player = player,
          old_character = old_char,
          old_unit_number = old_id,
          new_character = new_char,
          new_unit_number = new_char and new_char.valid and new_char.unit_number or
                            nil,
        })

        -- Now that we've reattached the old character, recurse to switch to the
        -- character the player selected, restore zoom, and return!
        minime_character.switch_characters(player, {keep_opened = true})
minime.show("player.zoom", player.zoom)
        player.zoom = player_zoom
minime.show("player.zoom", player.zoom)

        minime.entered_function({}, "leave",
          "Returned from calling the function with reattached char, skip the rest!")
        return

      -- We must create a new character!
      else
        minime.writeDebug("Creating new character for player %s", {player.name}, "line")
        player.create_character(char_version)
        new_char = player.character

        -- Announce character change
        announce_swapped_character({
          player = player,
          old_character = old_char,
          old_unit_number = old_id,
          new_character = new_char,
          new_unit_number = new_char and new_char.valid and new_char.unit_number or nil,
        })

      end

    -- Player switched between editor and god mode. Make sure that player's
    -- controller is in sync with the state stored in player_data!
    elseif player_data.last_character == "" then
      minime.writeDebug("%s has no new character. (Reason: \"%s\")",
                        {minime.argprint(player), controller})

      -- Mode stored in player data differs from player.controller_type.
      -- Toggle editor mode with toggle_map_editor instead of set_controller to
      -- make sure we trigger on_player_toggled_map_editor! Bob's classes will
      -- update the info text on its GUIs when this event triggers, so we must
      -- fire this event to sync info text and player's actual controller type.
      local ed = in_editor()
      if (ed and not player_data.editor_mode) or
        (player_data.editor_mode and not ed) then
        toggle_map_editor(player)
        minime.writeDebug("Toggled editor mode!")
minime.show("player_data", player_data)
      end

    -- Invalid character
    else
      minime.writeDebug("Player %s has no new character. (\"%s\" is not a valid character)",
                        {minime.argprint(player), char_version or "nil"})
    end
  end

  ----------------------------------------------------------------------------------
  -- Post processing
minime.show("new_char", new_char)
minime.show("old_char", old_char)
  -- We have a new character
  if new_char and new_char.valid then
    minime.writeDebug("Player switched to %s, storing char_entity!",
                      {minime.argprint(player)})
    player_data.char_entity = new_char

    -- If the new character is on another GUI page than the old character, update
    -- buttons on the old page again!
minime.show("new_char.name", new_char.name)
minime.show("old_char_name", old_char_name)
    minime.writeDebugNewBlock("Are old and new character on the same GUI page?")
    if new_char.name ~= old_char_name then
      local pages = player_data.gui_character_pages_lookup
      local old_page = pages[old_char_name]
minime.show("old_page", old_page)
      if old_page and pages[new_char.name] ~= old_page then
        minime.writeDebug("No! Enabling button for old char again!")

        --~ local names = minime_gui_names.selector
--~ minime.show("names", names)
        --~ local gui = player.gui.screen[names.frames.main]
--~ minime.show("gui", gui)
        --~ local previews = gui[names.frames.characters]
--~ minime.show("previews", previews)
        --~ local old_tab = previews[names.character_page_prefix..old_page]
--~ minime.show("old_tab", old_tab)
--~ minime.writeDebugNewBlock("Elements of old page!")
        --~ if old_tab and old_tab.valid then
          minime_gui.selector.gui_update(player, old_page)
        --~ end
      else
        minime.writeDebug("%s!", {old_page and "Yes" or "No: no old character"})
      end
    end


    -- This only makes sense if the new character is not the same as the old one!
    if new_char ~= old_char then
      -- Restore properties and inventories from backup, if we have one.
      if backup then
        local passon_flags = { backup_to_player = player.index, }
        minime_character.copy_character(backup, new_char, passon_flags)
        minime.writeDebug("Restored inventories and settings of %s from backup.",
                          {minime.argprint(new_char)})
      end
    else
      minime.writeDebug("Character didn't change: skipped restoring from backup!")
    end

    -- Try to resume crafting if we have stored a crafting queue!
    local items = player_data.crafting_queue
    if items then
      minime.writeDebug("Restart crafting!")
      local crafting
      local cnt = 0
      for i, item in pairs(items or {}) do
        cnt = cnt + 1
        minime.writeDebug("Added recipe %s to crafting queue: %s",
                          {cnt , items[i]}, "line")
        crafting = player.begin_crafting(items[i])
        minime.writeDebug("Crafting %s items.", {crafting})
        player_data.crafting_queue[i] = nil
        minime.writeDebug("Removed player_data.crafting_queue[%s]!", {i})
      end
      player_data.crafting_queue = nil
      minime.writeDebug("Removed crafting queue from player data!")
    else
      minime.writeDebug("No crafting queue stored for %s!",
                        {minime.argprint(player)})
    end

    -- If the old character was followed by combat bots, turn the bots over
    -- to the new character!
    minime.writeDebug("Must check %s combat bots!", {table_size(combat_bots)})
    for c, combat_bot in pairs(combat_bots) do
      if combat_bot.valid and combat_bot.combat_robot_owner ~= new_char then
        combat_bot.combat_robot_owner = new_char
        minime.writeDebug("%s: %s now follows %s.",
                        {c, minime.argprint(combat_bot), minime.argprint(new_char)})
      end
    end

    -- As we have a character, we can't be in editor/god mode. Remove the flags!
    player_data.god_mode = nil
    player_data.editor_mode = nil
    minime.writeDebug("Removed player_data.god_mode and player_data.editor_mode!")

  else
    minime.writeDebugNewBlock("Do we have an old char?")
    if old_char_name then
      minime.writeDebug("Yes! Try to reset its button?")
minime.show("player_data.character_gui_page", player_data.character_gui_page)
      local pages = player_data.gui_character_pages_lookup
      local old_page = pages[old_char_name]
minime.show("old_page", old_page)
      if old_page and player_data.character_gui_page ~= old_page then
        minime.writeDebug("Yes! Enabling button for old char again!")
          minime_gui.selector.gui_update(player, old_page)
      else
        minime.writeDebug("No: %s!",
                          {old_page and "already on old page" or "no old character"})
      end
    end
  end

  -- Update the button states of our GUIs
  minime.writeDebug("Updating character selector  GUI!")
minime.show("player_data.detached_character", player_data.detached_character)
  minime_gui.selector.gui_update(player)

  minime.writeDebug("Updating GUI for available characters!")
  minime_gui.available.update_all_checkboxes(player)

  --~ -- If the player had opened any other GUI that has been closed by exchanging the
  --~ -- character, open it again!
  --~ player.opened = open_GUI
  --~ minime.show("Re-open GUI", minime.argprint(player.opened))

  -- Update flashlight of valid entities
  set_flashlight(player, flashlight)
  set_flashlight(new_char, flashlight)
  minime.writeDebug("Flashlight is %s.", {flashlight and "on" or "off"})

  -- Restore zoom factor of player
  minime.writeDebug("Changing player.zoom from %s to %s!",
                    {player.zoom, player_zoom})
  player.zoom = player_zoom



  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                           Before entering editor mode                          --
--  Editor mode may be entered by other means than our GUI (other mods, keyboard  --
--  shortcuts, /editor command etc.), so we should listen to the event to catch   --
--  attempts to bypass our GUI and update our data.                               --
------------------------------------------------------------------------------------
minime_character.on_pre_player_toggled_map_editor = function(event)
  minime.entered_function({event})

  local player = minime.ascertain_player(event.player_index)

  if not mod.player_data[player.index] then
    minime_player.init_player({player = player})
  end
  local p_data = mod.player_data[player.index]

  -- Leave early when we came here because editor mode was toggled via our own GUI!
  if p_data.raise_toggle_editor then
    minime.entered_function({event}, "leave", "player used our GUI to toggle editor mode")
    return
  end

  local controller = minime.controller_names[player.controller_type]

  minime.writeDebug("Player: \"%s\"\tController: \"%s\"\tData: %s",
                    {player.name, controller, p_data or "nil"})

  if (controller == "character" or controller == "god") and not p_data.editor_mode then
    minime.writeDebug("Switching from %s to editor mode!", {controller})
    p_data.last_character = ""
    p_data.god_mode = nil
    p_data.editor_mode = true

    --~ if controller == "character" then
      --~ minime.writeDebug("Must store %s with player data!", {minime.argprint(player.character)})
      --~ detach_character(player)
    --~ end
minime.show("p_data", p_data)
    minime_gui.selector.gui_update(player)

  -- Nothing to do
  else
    minime.writeDebug("Nothing to do!")
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                           After leaving editor mode                            --
--  Editor mode may be left by other means than our GUI (other mods, keyboard     --
--  shortcuts, /editor command etc.), so we should listen to the event to catch   --
--  attempts to bypass our GUI and update our data.                               --
------------------------------------------------------------------------------------
minime_character.on_player_toggled_map_editor = function(event)
  minime.entered_function({event})

  local player = minime.ascertain_player(event.player_index)
  local controller = minime.controller_names[player.controller_type]

  if not mod.player_data[player.index] then
    minime_player.init_player({player = player})
  end
  local p_data = mod.player_data[player.index]

  minime.writeDebug("Player: \"%s\"\tController: \"%s\"\tData: %s",
                    {player.name, controller, p_data or "nil"})

  -- Player had a character before entering god mode and has been automatically
  -- returned to the old character
  if controller == "character" then
    minime.writeDebug("Switching from editor to character mode!")
    local char = mod.minime_character_properties[player.character.name]
minime.show("char and char.base_name", char and char.base_name)
minime.show("p_data.last_character", p_data.last_character)
    if p_data.last_character == "" then
      p_data.last_character = char and char.base_name or ""
minime.show("p_data.last_character", p_data.last_character)
    end
    p_data.editor_mode = nil

    if p_data.god_mode then
      minime.writeDebug("Will continue to switch from character to god mode!")
      detach_character(player)
    else
      minime.writeDebug("Character mode is final destination -- remove detached character!")
      local detached = p_data and p_data.detached_character
minime.show("detached", detached)
      if detached then
minime.writeDebug("We've stored a detached character!")
        if detached.valid then
minime.writeDebug("Detached character is valid!")
          -- Remove data of detached character
minime.show("mod.detached_characters", mod.detached_characters)
          if mod.detached_characters then
            mod.detached_characters[detached.unit_number] = nil
minime.writeDebug("Removed mod.detached_characters[%s]!", {detached.unit_number})
          end
          p_data.detached_character = nil
        else
minime.writeDebug("Detached character is not valid!")
          for c_id, c_player in pairs(mod.detached_characters or {}) do
            if mod.player_data and mod.player_data[c_player] and
                mod.player_data[c_player].detached_character and
                not mod.player_data[c_player].detached_character.valid then
minime.writeDebug("Removing invalid detached character %s of player %s!", {c_id, c_player})
              mod.detached_characters[c_id] = nil
              mod.player_data[c_player].detached_character = nil
            end
          end
minime.show("next(mod.detached_characters)",
            mod.detached_characters and next(mod.detached_characters))
          if not (mod.detached_characters and
                  next(mod.detached_characters)) then
            minime.writeDebug("Removed mod.detached_characters!")
            mod.detached_characters = nil
          end
        end
      end
    end
minime.show("p_data", p_data)
    minime_gui.selector.gui_update(player)

  -- When the controller type is "god", the player didn't have a character before
  -- entering editor mode and is directly returning to god mode.
  elseif (controller == "god") then
    minime.writeDebug("Switching from editor to god mode!")
    p_data.god_mode = true
    p_data.editor_mode = nil

minime.show("p_data", p_data)
    minime_gui.selector.gui_update(player)

  -- Nothing to do
  else
    minime.writeDebug("Switched to %s mode!", {controller})
  end


  -- Mark next on_player_controller_changed to be skipped!
  local skip_event = "on_player_controller_changed"
  minime.writeDebugNewBlock("Marking next %s to be skipped by %s!",
                            {skip_event, minime.argprint(player)})
  minime_events.setup_skip_event(skip_event)
  mod.skip_events[skip_event][player.index] = true


  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                           Player controller changed                            --
--              Catch attempts to bypass our GUI and update our data.             --
------------------------------------------------------------------------------------
minime_character.on_player_controller_changed = function(event)
  minime.entered_function({event})

  local player = minime.ascertain_player(event.player_index)
  local player_string = minime.argprint(player)

  -- Return if editor mode has been toggled!
  do
    local e_name = "on_player_controller_changed"
    minime.writeDebugNewBlock("Did %s toggle editor mode?", {player_string})
    if mod.skip_events and mod.skip_events[e_name] and
                            mod.skip_events[e_name][player.index] then
      minime.writeDebug("Yes: cleaning up mod.skip_events!")
      mod.skip_events[e_name][player.index] = nil
      minime_events.remove_skip_event(e_name)

      local reason = "already handled on_player_toggled_map_editor"
      minime.entered_function({}, "leave", reason)
      return

    else
      minime.writeDebug("No: proceeding!")
    end
  end

  local p_data = mod.player_data[player.index]
  local new = minime.controller_names[player.controller_type]
  local old = minime.controller_names[event.old_type]

  -- Player toggled between god and character mode
  minime.writeDebugNewBlock("Did %s enter character or god mode?", {player_string})
  if (old == "character" and new == "god") or
      (old == "god" and new == "character") then
    minime.writeDebug("Yes: Switching from %s to %s mode!", {old, new})
minime.show("p_data", p_data)
    -- Entered god mode
    if new == "god" then
      p_data.last_character = ""
      p_data.god_mode = true
      p_data.detached_character = p_data.char_entity
      p_data.char_entity = nil

    -- Entered character mode
    else
      p_data.last_character = player.character.name
      p_data.god_mode = nil
      p_data.char_entity = player.character
      p_data.detached_character = nil
    end
    minime_character.switch_characters(player)

  else
    minime.writeDebug("No: ignoring change from %s to %s mode!", {old, new})
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--             Player entered god mode by starting remote view in SE!             --
------------------------------------------------------------------------------------
minime_character.SE_remote_view_started = function(event_data)
  minime.entered_function(event_data)

  local player = minime.ascertain_player(event_data.player_index)
  if not player and player.valid then
    minime.arg_err(player, "player specification")
  end

  local p_data = mod.player_data[player.index]
  local controller = minime.controller_names[player.controller_type]
  minime.writeDebug("Controller of %s! Current mode: %s\tCurrent character: %s", {
    minime.argprint(player), controller, minime.argprint(player.character)})

  local char = player.character
  if char and char.valid then
    minime.writeDebug("Backing up character of %s!", {minime.argprint(player)})
    minime_character.copy_character(char, p_data.dummy)

    minime.writeDebug("Detaching character from player!")
    detach_character(player, {skip_detach = true})
  end

  p_data.god_mode = true
  p_data.editor_mode = nil
  p_data.SE_nav_view = true

  -- Update GUI!
  minime_gui.selector.gui_update(player)

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--          Player returned from god mode by stopping remote view in SE!          --
------------------------------------------------------------------------------------
minime_character.SE_remote_view_stopped = function(event_data)
--~ minime.set_debug_state(true)
  minime.entered_function(event_data)


  local player = minime.ascertain_player(event_data.player_index)
  if not player and player.valid then
    minime.arg_err(player, "player specification")
  end

  local p_data = mod.player_data[player.index]
  local controller = minime.controller_names[player.controller_type]
  minime.writeDebug("Controller of %s: \"%s\"\tCurrent character: %s",
                    {minime.argprint(player), controller,
                      minime.argprint(player.character)})
minime.show("player.opened", player.opened)
  local keep_last_character = p_data and p_data.keep_last_character
minime.show("keep_last_character", keep_last_character)

  local char = player.character
minime.show("char", char)
  if char and char.valid then
    minime.writeDebug("Updating data of reattached character!")
    reattach_character(player, {skip_teleporting = true, skip_attach = true})
minime.show("player.character after reattach_character", player.character)
minime.show("player.opened", player.opened)

    -- Fix for crash related to dummy becoming invalid when stopping SE remote view.
    -- We'd really better find out why it has become invalid, but so far, I couldn't
    -- reproduce this myself.
    -- (https://mods.factorio.com/mod/minime/discussion/6484c2f28a3657b839f23e8f)
minime.show("p_data.dummy before check", p_data.dummy)
    if not (p_data.dummy and p_data.dummy.valid) then
      p_data.dummy = minime_player.make_dummy(player)
minime.show("Created p_data.dummy", p_data.dummy)
    end

    minime.writeDebug("Restoring character of %s!", {minime.argprint(player)})
    copy_properties(p_data.dummy, char)

    if keep_last_character then
      minime.writeDebug("Won't overwrite last_character!")
    else
      p_data.last_character = minime_character.get_character_basename(char)
minime.show("p_data.last_character", p_data.last_character)
    end
minime.show(p_data.last_character)
    p_data.detached_character = nil
    p_data.god_mode = nil
    p_data.editor_mode = nil
    p_data.SE_nav_view = nil

  end

  -- Update GUI!
  minime_gui.selector.gui_update(player)

  minime.entered_function("leave")
--~ minime.set_debug_state(false)
end


------------------------------------------------------------------------------------
--                          Initialize character previews                         --
------------------------------------------------------------------------------------
minime_character.initialize_character_preview = function(char_name, passon_flags)
  minime.entered_function({char_name, passon_flags})

  local c_name = minime.assert(char_name, "string", "character name") and char_name

  -- Flags are passed on directly to minime_surfaces.create_surface!
  minime.assert(passon_flags, {"table", "nil"}, "table of flags, or nil")

  local chars = mod.minime_characters
  local c_data = chars and chars[c_name] or minime.arg_err(char_name, "valid character name")
  local surface_name = minime.preview_surface_name_prefix..c_name

  local created_surface

  c_data.preview = c_data.preview or {}

  -- Make sure we have a surface for the preview entities
  if game.surfaces[surface_name] and game.surfaces[surface_name].valid then
    minime.writeDebug("Using existing surface \"%s\"!", {surface_name})
    c_data.preview.surface = game.surfaces[surface_name]
  else
    c_data.preview.surface = minime_surfaces.create_surface(surface_name, passon_flags)
    if not (c_data.preview.surface and c_data.preview.surface.valid) then
      error(string.format("Couldn't create surface \"%s\"!", surface_name))
    end
    created_surface = true
minime.show("Created", c_data.preview.surface)
  end

  c_data.preview.surface.generate_with_lab_tiles = false
  c_data.preview.surface.always_day = true
  c_data.preview.surface.show_clouds = false

  -- Blacklist surface with "Abandoned Ruins" etc.
  -- (This has already been done if we created the surface!)
  if not created_surface then
    minime_surfaces.blacklist_surface(c_data.preview.surface.name)
  end

  -- Initialize table for preview entities
  c_data.preview.entities = c_data.preview.entities or {}

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
minime.entered_file("leave")

return minime_character
