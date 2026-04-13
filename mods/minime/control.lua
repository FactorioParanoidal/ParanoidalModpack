minime = require(string.format("__%s__/common", script.mod_name))

minime.entered_file()

-- (https://mods.factorio.com/mod/gvv)
-- If that mod is active, you can inspect minime's global table at runtime.
if script.active_mods["gvv"] then
  require("__gvv__.gvv")()
end

BP_SANDBOXES = script.active_mods["blueprint-sandboxes"] and true or false
mod = storage

------------------------------------------------------------------------------------

local scripts = minime.modRoot..".scripts."

minime_gui = require(scripts.."gui")
minime_forces = require(scripts.."forces")
minime_player = require(scripts.."player")
minime_character = require(scripts.."character")
minime_corpse = require(scripts.."corpse")
minime_inventories = require(scripts.."inventories")
minime_surfaces = require(scripts.."surfaces")
minime_if = require(scripts.."remote_interface")
minime_events = require(scripts.."events")
minime_commands = require(scripts.."commands")



------------------------------------------------------------------------------------
--                             Attach event handlers!                             --
------------------------------------------------------------------------------------
local function attach_events()
  minime.entered_function()

    minime_events.get_event_handlers()
    minime_events.attach_events()

  minime.entered_function("leave")
end


local function remove_guis()
  minime.entered_function()
  minime.writeDebug("Character selector is disabled -- check if any players have a GUI.")

  for p, player in pairs(game.players) do
    minime_gui.remove_gui(player)
  end

  minime.entered_function("leave")
end



------------------------------------------------------------------------------------
--                 Are we in a scenario that supports characters?                 --
------------------------------------------------------------------------------------
local function scenario_supports_characters()
  minime.entered_function()

  local ret = true

  for mod_name, level_name in pairs(minime.scenarios_without_character or {}) do
    if script.level.mod_name == mod_name and
        script.level.level_name == level_name then

      ret = false
      minime.writeDebug("%s scenario \"%s\" is active!", {
        mod_name == "base" and "Vanilla" or
        "Mod "..minime.enquote(mod_name).."'s",
        level_name
      })
      break
    end
  end
minime.show("Return", ret)

  minime.entered_function("leave")
  return ret
end

------------------------------------------------------------------------------------
--                             INITIALIZE A NEW GAME!                             --
------------------------------------------------------------------------------------
--~ local function init()
init = function(event)
  minime.entered_function({event})

  mod = storage

  local in_game = (game.tick > 0)

  ----------------------------------------------------------------------------------
  --                Are we in a scenario that supports characters?                --
  ----------------------------------------------------------------------------------
  do
    if minime.is_debug then
      minime.writeDebugNewBlock("Debug mode: checking prototype translations!")
      helpers.check_prototype_translations()
    else
      log("\nDebug mode: disabled!\n")
    end

    local mod_name = minime.modName
    local remote = "CharacterModHelper"
    if scenario_supports_characters() then
      minime.writeDebug("Scenario supports characters!")
      if mod.no_characters then
        mod.no_characters = nil
        minime.writeDebug("Removed flag mod.no_characters!")

        minime.remote_call(remote, "selector_mode_active", mod_name)
        minime.remote_call(remote, "allow_character_commands", mod_name)
      end

    else
      minime.writeDebug("Scenario doesn't support characters!")
      local reason = {
        "minime-selector-mode.disabled-no-char-scenario",
        script.level.level_name,
        {"mod-name."..script.level.mod_name} or script.level.mod_name,
      }
      -- "CharacterModHelper" will warn that the scenario doesn't support characters
      -- if it is active
      if script.active_mods["CharacterModHelper"] then
        minime.writeDebug("Asking \"CharacterModHelper\" to print warning!")
        minime.remote_call(remote, "selector_mode_disabled", mod_name, reason)
        minime.remote_call(remote, "forbid_character_commands", mod_name)

      -- When "CharacterModHelper" is not active, we'll print the warning ourselves
      else
        minime.writeDebug("\"CharacterModHelper\" is not active!")
        local msg = {
          "minime-selector-mode.wrapper",
          {"mod-name."..script.mod_name},
          reason,
        }
        game.print(msg)
      end

      mod.no_characcters = true
      minime.writeDebug("Set flag mod.no_characters!")

      -- Remove GUIs
      minime.writeDebug("Remove GUIs?")
      for p, player in pairs(game.players) do
        minime.writeDebug("Trying to remove GUIs of %s!", {minime.argprint(player)})
        minime_gui.remove_gui(player)
      end

      -- Disable shortcuts?
      minime.writeDebug("Disable shortcuts?")
      local shortcut = minime.toggle_gui_input_shortcut_name
      --~ if game.shortcut_prototypes[shortcut] then
      if prototypes.shortcut[shortcut] then
        for p, player in pairs(game.players) do
          if player.is_shortcut_available(shortcut) then
            player.set_shortcut_available(shortcut, false)
            minime.writeDebug("Disabled shortcut of %s!", {minime.argprint(player)})
          end
        end
      end

      -- If new players are added, we must disable their shortcuts!
      local e_name = "on_player_created"
      script.on_event(defines.events[e_name], minime_player[e_name])
      minime.writeDebug("Added listener for event \"%s\"!", {e_name})

      minime.entered_function({}, "leave", "scenario doesn't support characters")
      return
    end
  end


  ----------------------------------------------------------------------------------
  -- Initialize tables
  do
    minime.writeDebugNewBlock("Checking global tables!")
    local function init_table(tab)
      local msg = mod[tab] and "Reusing" or "Initialized"
      mod[tab] = mod[tab] or {}
      minime.writeDebug("%s storage.%s", {msg, tab})
    end

    local tabs = {
      "player_data",
      "force_data",
      "minime_corpses",
      "researched_by",
      "map_settings",
      "optional_events",
    }
    for t, tab in pairs(tabs) do
      init_table(tab)
    end
  end

  ----------------------------------------------------------------------------------
  -- If this function is run for on_init, there may already be players if the mod
  -- has been added to a running game. They have no player_data yet, therefore
  -- 'last_character' will be set to "", which puts the player in god mode. We must
  -- initialize this variable with the name of the character currently used by the
  -- player. (This actually should be the default character!)
  minime.writeDebugNewBlock("Try to pre-init player data with last_character?")
  do
    local controllers = minime.controller_names
    local controller, char

    -- Mod is added to an existing game
    if event.name == "on_init" and in_game then
      minime.writeDebug("Yes: we're in %s!", {event.name})

      for p, player in pairs(game.players) do
        minime.writeDebugNewBlock("Try to pre-initialize data for %s?",
                          {minime.argprint(player)})

        -- Only connected players have a character attached!
        if player.connected then
          minime.writeDebug("Yes!")
          controller = controllers[player.controller_type]
minime.show("controller", controller)

          minime.writeDebugNewBlock("Do we have a character?")
          if player.character and player.character.valid then
            minime.writeDebug("Yes: using player.character!")
            char = player.character
          elseif player.cutscene_character and player.cutscene_character.valid then
            minime.writeDebug("Yes: using player.cutscene_character!")
            char = player.cutscene_character
          else
            minime.writeDebug("No!")
            -- Make sure we don't reuse the char of a previous player!
            char = nil
          end

          if not mod.player_data[p] then
            mod.player_data[p] = {
              last_character = char and char.name or "",
              char_entity = char,
              god_mode = (controller == "god") or nil,
              editor_mode = (controller == "editor") or nil,
            }
minime.show("mod.player_data["..p.."]", mod.player_data[p])
          end

        -- Player is not connected
        else
          minime.writeDebug("No: not connected!")
        end
      end

    -- Mod existed, but we're reinitializing because of on_configuration_changed
    elseif in_game then
      minime.writeDebug("No: %s by %s!", {
        event.name and "called" or "not called",
        event.name or "on_init"
      })

    -- We're starting a new game, there are no players yet!
    else
      minime.writeDebug("No: just started a new game!"  )
    end
  end

  local create_surface_passon = {dont_hide = true}

  ----------------------------------------------------------------------------------
  -- Create surface for placing dummy characters
  minime.writeDebugNewBlock("Create dummy surface?")
  if not (game.surfaces[minime.dummy_surface] and
          game.surfaces[minime.dummy_surface].valid) then
    minime.writeDebug("Yes!")
    minime_surfaces.create_surface(minime.dummy_surface, create_surface_passon)
  else
    minime.writeDebug("No: surface already exists, making sure it's blacklisted!")
    minime_surfaces.blacklist_surface(minime.dummy_surface)
  end

  ----------------------------------------------------------------------------------
  -- Rebuild list of armor prototypes (relevant for inventory_size_bonus)
  minime.writeDebugNewBlock("Creating list of available armor prototypes!")
  minime_character.make_armor_list()

  ----------------------------------------------------------------------------------
  -- Build/rebuild list of character prototypes, and remove preview surfaces
  -- created for characters from removed mods
  minime.writeDebugNewBlock("Updating list of character prototypes")
  minime_character.update_character_list()

  ----------------------------------------------------------------------------------
  -- Rebuild list of character-corpse prototypes
  -- (Must be run after update_character_list when used in init(), but the function
  -- is also called from migration scripts, so we must keep it separate.)
  minime.writeDebugNewBlock("Creating list of available character-corpse prototypes!")
  minime_corpse.make_corpse_list()

  ----------------------------------------------------------------------------------
  -- Create surfaces for placing characters for entity preview
  minime.writeDebugNewBlock("Is character selection mode active?")
  if minime.character_selector then
    minime.writeDebugNewBlock("Yes: checking preview surfaces!")
    for c_name, c_data in pairs(mod.minime_characters) do
      minime.writeDebug("Initializing surface for previews of character \"%s\"!",
                        {c_name})
      minime_character.initialize_character_preview(c_name, create_surface_passon)
    end
  else
    minime.writeDebug("No!")
  end

  ----------------------------------------------------------------------------------
  -- Hide all surfaces (previews and dummy)
  minime.writeDebugNewBlock("Trying to hide surfaces for dummy and previews!")
  minime_surfaces.hide_surface()  -- No args: hide all our surfaces to all forces

  ----------------------------------------------------------------------------------
  -- Read global settings
  minime.writeDebugNewBlock("Reading global settings!")
  minime_player.update_global_settings({keep_gui = true})

  ----------------------------------------------------------------------------------
  -- Initialize players – this doesn't make sense on tick 0 as no player has joined
  -- the game yet!
  minime.writeDebugNewBlock("Try to initialize player data?")
  if in_game then
    minime.writeDebug("Yes!")
    for p, player in pairs(game.players) do
      minime.writeDebug("Calling init_player for %s.", {player.name})
      minime_player.init_player({ player = player })
    end
  else
    minime.writeDebug("No: game is just starting, there are no players yet!")
  end

  ----------------------------------------------------------------------------------
  -- Remove GUIs?
  minime.writeDebugNewBlock("Remove GUIs?")
  if minime.character_selector then
    minime.writeDebug("No: selector is enabled!")
  elseif in_game then
    minime.writeDebug("Yes: character selector has been turned off!")
    remove_guis()
  else
    minime.writeDebug("No: game has just started, no GUIs yet!")
  end

  ----------------------------------------------------------------------------------
  -- Attach events!
  minime.writeDebugNewBlock("Attaching events!")
  attach_events()

  minime.writeDebugNewBlock("Looking for optional events!")
  for event_list, e in pairs(mod.optional_events or {}) do
    minime.writeDebug("Attaching %s events!", {event_list})
    minime_events.attach_events(minime.optional_events[event_list])
  end

  ----------------------------------------------------------------------------------
  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------


------------------------------------------------------------------------------------
--                            REGISTER EVENT HANDLERS!                            --
------------------------------------------------------------------------------------


------------------------------------------------------------------------------------
--                    EVENTS RELATED TO STARTING/LOADING A GAME                   --
------------------------------------------------------------------------------------
-- New game
script.on_init(function()
  local event = {name = "on_init"}
  minime.entered_event(event)

    init(event)

  minime.entered_event(event, "leave")
end)


------------------------------------------------------------------------------------
-- Configuration changed
script.on_configuration_changed(function(event)
  event.name = "on_configuration_changed"
  minime.entered_event(event)
minime.show("mod.minime_characters", mod.minime_characters)

minime.show("minime.character_selector", minime.character_selector)

  -- Check whether player data contains properties from removed mods. If we don't
  -- delete them, a non-existant character may be picked. While the button of the
  -- proper character would be selected on the GUI, the player would still be in god
  -- mode.
  local p_data
  for p, player in pairs(game.players) do
    p_data = mod.player_data and mod.player_data[p]
    -- Bob's classes
    if p_data and p_data.bob_class and not script.active_mods["bobclasses"] then
      minime.writeDebug("Removing Bob's class \"%s\" from data of %s.",
                        {p_data.bob_class, minime.argprint(player)})
      p_data.bob_class = nil
    end
    -- Jetpack
    if p_data and p_data.flying and not script.active_mods["jetpack"] then
      minime.writeDebug("Removing Jetpack property \"flying\" from data of %s.",
                        {minime.argprint(player)})
      p_data.flying = nil
    end
  end

  -- Re-initialize game?
  minime.writeDebugNewBlock("Re-initialize game?")
  do
    local changes = event.mod_changes and event.mod_changes.minime

    -- Run init if 'changes' is nil (other mods have changed) or changes.old_version
    -- exists (we have been updated)!
    if (not changes) or changes.old_version then
      minime.writeDebug("Yes!")
      init(event)

    -- Skip init if we have changes.new_version without changes.old_version (mod has
    -- been added to the game and we've already run this from on_init)!
    else
      minime.writeDebug("No: have just run handler for on_init! Rebuild previews?")
      -- If this flag has been set in a migration script, we must rebuild the
      -- preview characters!
      if storage.rebuild_preview_characters then
        minime.writeDebug("Yes: a migration may have removed preview characters!")
        for p, player in pairs(game.players) do
          minime.writeDebugNewBlock("Re-initializing previews for %s!", {player})
          minime_player.initialize_player_previews(player)
        end

        minime.writeDebug("Removing flag storage.rebuild_preview_characters!")
        storage.rebuild_preview_characters = nil
      else
        minime.writeDebug("No: no migration removing previews has been run!")
      end
    end
  end

  -- Exit if the currently used scenario doesn't support characters!
  if mod.no_characters then
    local msg = string.format("Scenario \"%s\" (%s) doesn't support characters!",
                              script.level.level_name, script.level.mod_name)
    minime.entered_event(event, "leave", msg)
    return
  end

  -- Update force data
  for f, force in pairs(game.forces) do
    minime_forces.init_force_data(f)
  end

  -- Is character selector mode active?
  minime.writeDebugNewBlock("Is character selector mode active?")
  if minime.character_selector then
    minime.writeDebug("Yes!")

  else
    minime.writeDebug("No: character selector mode has been disabled!")

    -- Don't leave players stranded without a character!
    local last_char, fallback_char

    minime.writeDebugNewBlock("Trying to give players a character!")
    for p, player in pairs(game.players) do

      p_data = mod.player_data and mod.player_data[p]
      last_char = p_data and p_data.last_character
minime.show("last_char of player " .. player.name, last_char or "nil")
minime.show("Current char of player "..player.name, player.character)
minime.show("next(mod.minime_characters)", mod.minime_characters and
                                              next(mod.minime_characters) or "nil")

      -- No character stored for player
      if not last_char then
        minime.writeDebug("No character stored for player %s! Don't do anything.",
                          {p})

      -- Player was in god mode when the game was last saved
      elseif last_char == "" then
        minime.writeDebug("Player %s was in god mode! Don't do anything.", {p})

      -- Player's last character still exists
      elseif mod.minime_characters[last_char] then
        minime.writeDebug("Player %s can still use character \"%s\". Don't do anything.",
                          {p, last_char})

      -- Last character of player has been removed
      else
        -- Fall back to the default character, if it exists, …
        fallback_char = mod.minime_characters["character"] and "character" or
        -- … or to the next character that's available
                        next(mod.minime_characters)
        minime.writeDebug("Last character of player %s (\"%s\") has been removed. Falling back to \"%s\"!",
                          {p, last_char, fallback_char})

        p_data.last_character = fallback_char
        minime_character.switch_characters(player)
      end

    end

    -- Remove existing GUIs
    remove_guis()

    -- Remove preview surfaces!
    do
minime.writeDebug("Remove preview surfaces?")
for s_name, s in pairs(game.surfaces) do
  minime.show("s_name", s_name)
end
minime.show("mod.minime_characters", mod.minime_characters)
      -- Remove preview surfaces and entities stored in our data
      local preview
      for c_name, c_data in pairs(mod.minime_characters or {}) do
minime.show(c_name, c_data)
        preview = c_data.preview
        if preview then
          -- Remove surface
          if preview.surface and preview.surface.valid then
            minime_surfaces.delete_surface(preview.surface)
          end

          -- Entities are removed when surface is destroyed, remove their data!
          if preview.entities then
            preview.entities = nil
            minime.writeDebug("Removed preview entities!")
          end
        end
      end

      -- Look for preview surfaces we may have missed, using our name prefix
      for s_name, surface in pairs(game.surfaces) do
minime.show(s_name, surface)
        if s_name:match("^"..minime.preview_surface_name_prefix)  then
          minime_surfaces.delete_surface(surface)
        end
      end

    end
  end

  -- Check if all character-corpse prototypes still exist, and replace missing
  -- corpses with a generic one!
  minime.writeDebugNewBlock("Checking corpses!")
  minime_corpse.check_corpses()

  minime.entered_event(event, "leave")
end)


--------------------------------------------------------------------------------------------
-- Loaded existing game
script.on_load(function()
  minime.entered_event({name = "on_load"})

  mod = storage

  if scenario_supports_characters() then
    -- Attach events
    attach_events()

    -- Attach optional events
    minime.writeDebug("Looking for optional events!")
    for event_list, e in pairs(mod.optional_events or {}) do
      minime.writeDebug("Attaching %s events!", {event_list})
      minime_events.attach_events(minime.optional_events[event_list])
    end

  else
    minime.writeDebug("Scenario \"%s\" of mod \"%s\" doesn't support events!",
                      {script.level.level_name, script.level.mod_name})
  end

  minime.entered_event({name = "on_load"}, "leave")
end)

minime.writeDebug("Outside of on_load -- attaching remote interface!")
minime_if.attach_interfaces()



------------------------------------------------------------------------------------
-- Learned that from eradicator: It basically checks that there are no undefined  --
-- global variables                                                               --
------------------------------------------------------------------------------------
do
  -- luacheck: no unused (Inline option for luacheck: ignore unused vars in block)

  local allowed_vars = {
    data = true,
    game = true,
    script= true,
    mods = not script,
  }
  setmetatable(_ENV, {
    __newindex  = function(self, key, value)    -- locked_global_write
      error('\n\n[ER Global Lock] Forbidden global *write*:\n' ..
            serpent.line({key = key or '<nil>', value = value or '<nil>'})..'\n')
    end,
    __index     = function(self, key)           -- locked_global_read
      if not allowed_vars[key] then
        error('\n\n[ER Global Lock] Forbidden global *read*:\n' ..
            serpent.line({key = key or '<nil>'})..'\n')
      end
    end
  })
end

------------------------------------------------------------------------------------
minime.entered_file("leave")
