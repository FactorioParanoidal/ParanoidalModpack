log("Entered file "..debug.getinfo(1).source)
require("util")


local mod_data = require("__minime__/mod_data")
local common = require("__Pi-C_lib__/common")(mod_data)
--~ common.show("common", common)

  ----------------------------------------------------------------------------------
  -- When looking for alternative characters, use this search pattern
  common.pattern = "SKIN"

  ----------------------------------------------------------------------------------
  -- Pattern for alternative characters from "jetpack"
  common.jetpack_pattern = "-JETPACK"

  ----------------------------------------------------------------------------------
  -- Pattern for alternative characters from "bobclasses"
  common.bobclasses_pattern = "BOB-CHARACTER-"

  ----------------------------------------------------------------------------------
  -- Pattern for replacement characters from "RenaiTransportation"
  common.renaitransportation_pattern = "RTGHOST"

  ----------------------------------------------------------------------------------
  -- Pattern for replacement characters from "katamari"
  common.katamari_pattern = "KATAMARI-DUMMY-"

  ----------------------------------------------------------------------------------
  -- Name of the surface we create as storage for dummy characters
  common.dummy_surface = script and common.modName.."_dummy_dungeon"

  ----------------------------------------------------------------------------------
  -- Name prefix of the surfaces we create as storage for preview characters
  common.preview_surface_name_prefix = script and
                                        common.modName.."_character_previews_"

  ----------------------------------------------------------------------------------
  -- Name of the dummy character prototype
  common.dummy_character_name = common.modName.."_character_dummy"

  ----------------------------------------------------------------------------------
  -- Name of the generic character-corpse
  common.generic_corpse_name = common.modName.."_generic_corpse"

  ----------------------------------------------------------------------------------
  -- List of character properties we must back up (only necessary in control stage)
  common.copyable_character_properties = script and require("character_properties")

  ----------------------------------------------------------------------------------
  -- Prefix for settings belonging to this mod
  common.mod_settings_prefix = mod_data.mod_shortname.."_"

  ----------------------------------------------------------------------------------
  -- Prefix for commands belonging to this mod
  common.command_prefix = mod_data.mod_shortname.."-"

  ----------------------------------------------------------------------------------
  -- Prefix for GUI elements belonging to this mod
  --~ common.mod_elements_prefix = common.mod_settings_prefix
  common.mod_elements_prefix = script and common.mod_settings_prefix

  ----------------------------------------------------------------------------------
  -- Prefix for available-characters list GUI elements
  common.available_chars_prefix = "minime_available_chars_"
  --~ common.available_chars_prefix = script and "minime_available_chars_"

  ----------------------------------------------------------------------------------
  -- Prefix for character-selector GUI elements
  common.character_selector_prefix = "minime_char_selector_"

  ----------------------------------------------------------------------------------
  -- Prefix for names of character GUI buttons
  common.character_button_prefix = common.character_selector_prefix.."characters_"

  ----------------------------------------------------------------------------------
  -- Prefix for names of character preview GUI elements
  common.character_preview_prefix = common.character_selector_prefix.."preview_"
  --~ common.character_preview_prefix = script and
                                    --~ common.character_selector_prefix.."preview_"

  ----------------------------------------------------------------------------------
  -- Prefix for names of character-page selector buttons
  --~ common.character_page_button_prefix = "minime_gui_page_selector_"
  --~ common.character_page_button_prefix = common.character_selector_prefix.."page_selector_"
  common.character_page_button_prefix = script and
                                        common.character_selector_prefix.."page_selector_"

  ----------------------------------------------------------------------------------
  -- Prefix for names of GUI element placeholders
  common.character_placeholder_prefix = script and
                                        common.character_selector_prefix.."placeholder_"

  --~ ----------------------------------------------------------------------------------
  --~ -- Prefix for names of GUI elements for removed character
  --~ common.character_removed_prefix = "minime_removed_character_"

  ----------------------------------------------------------------------------------
  -- Name of God-mode button
  common.godmode_button_name = script and "God-mode"

  ----------------------------------------------------------------------------------
  -- Name of Editor-mode button
  common.editor_button_name = script and "Editor-mode"

  ----------------------------------------------------------------------------------
  -- Name of custom-input and shortcut that toggle the GUI
  common.toggle_gui_input_shortcut_name = "minime_toggle_selector_gui"

  ----------------------------------------------------------------------------------
  -- Names of inventories (armor must be the first as it may affect inventory size)
  common.inventory_list = script and {"armor", "guns", "ammo", "main", "trash"}

  ----------------------------------------------------------------------------------
  -- Names of inventories for moving to corpse when player is leaving
  -- (To prevent item spilling, main inventory must be cleared before armor!)
  common.inventory_list_move_to_corpse = script and
                                          {"main", "guns", "ammo", "trash", "armor"}

  ----------------------------------------------------------------------------------
  -- Names of GUI types we may try to reopen
  if script then
    common.gui_types = {}
    common.writeDebugNewBlock("Making reverse lookup list of GUI types!")
    for k, v in pairs(defines.gui_type) do
common.show(k, v)
      common.gui_types[v] = k
    end
  end

  ----------------------------------------------------------------------------------
  -- Number of dummy's bonus trash slots
  common.character_trash_slot_count_bonus = 500


  ----------------------------------------------------------------------------------
  -- Enable character selector?
  common.character_selector = common.get_startup_setting("minime_character-selector")

  --~ ----------------------------------------------------------------------------------
  --~ -- Toggle character selector GUI with shortcut or button?
  --~ common.toggle_gui_with = common.get_startup_setting("minime_toggle-gui-with")

  --~ ----------------------------------------------------------------------------------
  --~ -- Enable character selector?
  --~ -- common.show_removal_buttons = settings.startup["minime_show-character-removal-buttons"] and
                                --~ -- settings.startup["minime_show-character-removal-buttons"].value
  --~ common.show_removal_buttons = common.get_startup_setting("minime_show-character-removal-buttons")

  ----------------------------------------------------------------------------------
  -- Scale factor for character size
  common.minime_character_scale = common.get_startup_setting("minime_character-size")
  common.minime_character_scale = common.minime_character_scale and
                                  common.minime_character_scale / 100


  common.scenarios_without_character = {
    ["base"]            = "sandbox",
    ["brave-new-world"] = "bnw",
  }

  ----------------------------------------------------------------------------------
  -- List of custom events
  common.custom_events = {
    -- Custom event that is raised when we have exchanged a character. The player
    -- may or may not have a new character (e.g. when switching to god/editor mode).
    -- If we must destroy the old character, we will do this AFTER raising the event.
   "minime_exchanged_characters",
  }


  common.scenarios_without_character = {
    ["base"]            = "sandbox",
    ["brave-new-world"] = "bnw",
  }


  ----------------------------------------------------------------------------------
  --   Ask "Space Exploration" whether player is in navigator view (god mode)     --
  ----------------------------------------------------------------------------------
  if script then
    common.SE_remote_view = function(player)
      common.entered_function({player})

      player = common.ascertain_player(player)
      local args = player and player.valid and {player = player}
      if args then
        return common.remote_call("space-exploration", "remote_view_is_active", args)
      end

      common.entered_function("leave")
    end
  end


  ----------------------------------------------------------------------------------
  --                 Ask "Space Exploration" for player character                 --
  ----------------------------------------------------------------------------------
  if script then
    common.SE_player_char = function(player)
      player = common.ascertain_player(player)
      local args = player and player.valid and {player = player}
minime.show("player", player)
minime.show("args", args)
      if args then
        return common.remote_call("space-exploration", "get_player_character", args)
      end
    end
  end


  ----------------------------------------------------------------------------------
  --                Get list of character prototypes we must ignore               --
  ----------------------------------------------------------------------------------
  if data then
    common.get_ignore_characters = function()
      common.entered_function()

      local chars = data.raw.character
      local ignore_characters = {}
      local mod_ignore_map = {
        ["space-exploration"] = {"se-spaceship-enemy-proxy",}
      }

      for mod_name, patterns in pairs(mod_ignore_map) do
        if mods[mod_name] then
          for p, pattern in pairs(patterns) do
            for char, c in pairs(chars) do
              -- Check for literal strings first, then for regular expressions
              if char:find(pattern, 1, true) or char:find(pattern) then
                common.writeDebug("Ignoring character %s", {common.argprint(char)})
                ignore_characters[char] = true
              end
            end
          end
        end
      end

      common.entered_function("leave")
      return ignore_characters
    end
  end


  ----------------------------------------------------------------------------------
  log("End of common.lua!")
  return common
