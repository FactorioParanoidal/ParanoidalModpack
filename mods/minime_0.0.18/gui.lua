--~ require("util")
log("Entered script gui.lua!")
local minime = require("__minime__/common")("minime")

local minime_gui = {}

------------------------------------------------------------------------------------
--                             Initialize player GUI!                             --
-- player: player index or player entity                                          --
-- remove_character (optional): anything (Won't create button for last_character  --
-- if this is set!)                                                               --
------------------------------------------------------------------------------------
minime_gui.init_gui = function(player, remove_character)
  local f_name = "init_gui"
  minime.dprint("Entered function " .. f_name .. " (" .. tostring(player) .. ")")

  player = (type(player) == "number" and game.players[player]) or player
  minime.dprint("player: " .. serpent.line(player.name))

  if not (player and player.valid and player.is_player()) then
    error(tostring(player) .. " is not a valid player!")
  end

  local gui = player.gui.top

  ------------------------------------------------------------------------------------
  -- Define GUI
  gui.add{
    type = "flow",
    name = "minime_gui",
    enabled = true,
    direction = "vertical"
  }
  gui = gui["minime_gui"]

  ------------------------------------------------------------------------------------
  -- Toggle button
  gui.add{
    type = "sprite-button",
    name = "minime_toggle_list",
    caption = {"minime-GUI.gui-name"},
    tooltip = {"minime-GUI.gui-name-tooltip"},
    enabled = true,
    ignored_by_interaction = false,
    style = "minime_toggle_button"
  }

  ------------------------------------------------------------------------------------
  -- Frame
  gui.add{
    type = "frame",
    name = "minime_character_list",
    caption = {"minime-GUI.gui-name-tooltip"},
    direction = "vertical",
    visible = global.player_data[player.index].show_character_list,
  }
  local buttons = gui["minime_character_list"]

  ------------------------------------------------------------------------------------
  -- Add buttons for characters, all buttons are active for now

  local last_character = global.player_data[player.index].last_character or
                          player.character and player.character.name

  --~ -- Add button to activate God mode
  --~ buttons.add{
    --~ type = "button",
    --~ name = "minime_characters_" .. minime.remove_character_name,
    --~ caption = {"minime-GUI.god-mode-button"},
    --~ enabled = true,
    --~ style = "minime_button_on",
  --~ }


  -- If the player's character is not on our list, let's just assume it's a valid cha-
  -- racter and create a button with a warning as tooltip.
  --~ if last_character and not remove_character and not global.minime_characters[last_character] then
  if last_character and not (last_character == "") and remove_character and not global.minime_characters[last_character] then
    minime.dprint({"" , "Creating button for unknown character ",
                        serpent.line(minime.loc_name(player.character))})
    buttons.add{
      type = "button",
      name = "minime_characters_" .. last_character,
      caption = minime.loc_name(player.character),
      enabled = true,
      style = "minime_button_on",
    }
-- Move "end" after the separator line as long as we don't have a working god mode button yet!
  --~ end

  -- Add separator line
  buttons.add{
    type = "line",
    name = "minime-unknown-character-separator",
    style = "minime_separator_line",
    direction = "horizontal",
  }
  end

  -- Create normal buttons for known characters from our list
  for char, loc_name in pairs(global.minime_characters) do
    minime.dprint("Adding button for registered character " .. serpent.line(char))
    buttons.add{
      type = "button",
      name = "minime_characters_" .. char,
      caption = loc_name,
      enabled = true,
      style = "minime_button_on",
    }
  end

  -- Do we have a button for the player's character?
  minime.dprint("Last character: " .. serpent.line(last_character))

  -- Turn other buttons red if button for current character should be removed
  if remove_character and not global.minime_characters[last_character] then
    minime.dprint("Must turn buttons red!")
    for _, button in ipairs(buttons.children) do
      button.style = "minime_button_warning"
      button.tooltip = {"minime-GUI.remove-character-button-warning",
                        minime.loc_name(player.character)}
    end
  -- Turn button for current character off
  else
    for _, button in ipairs(buttons.children) do
      if string.gsub(button.name, "^minime_characters_", "") == last_character then
        button.style = "minime_button_off"
        button.tooltip = table_size(global.minime_characters) == 2 and
                          {"minime-GUI.disabled-button-tooltip"} or
                          {"minime-GUI.disabled-button-tooltip-plural"}
        button.enabled = false
        break
      end
    end
  end

  minime.dprint("End of function " .. f_name .. " (" .. player.index .. ")")
end


------------------------------------------------------------------------------------
--                                   REMOVE GUI!                                  --
------------------------------------------------------------------------------------
minime_gui.remove_gui = function(player)
  local f_name = "remove_gui"
  minime.dprint("Entered function " .. f_name .. " (" .. tostring(player) .. ")")

  player = player and                                                   -- player exists,
          (type(player) == "number" and game.players[player]) or        -- is a plain player index or
          (type(player) == "table" and
            game.players[player.player_index] or                        -- a player index in event data or
            player)                                                     -- an entity

  if player and player.valid and player.is_player() and player.gui.top["minime_gui"] then
    player.gui.top["minime_gui"].destroy()
    minime.dprint("Removed GUI of player " .. tostring(player.name) .. "!")
  end

  minime.dprint("End of function " .. f_name .. " (" .. tostring(player.name) .. ")")
end


------------------------------------------------------------------------------------
--                                   TOGGLE GUI!                                  --
------------------------------------------------------------------------------------
minime_gui.gui_toggle = function(player)
  local f_name = "gui_toggle"
  minime.dprint("Entered function " .. f_name .. " (" .. tostring(player) .. ")")

  player = (type(player) == "number" and game.players[player]) or player
  if not (player and player.valid and player.is_player()) then
    error(tostring(player) .. " is not a valid player!")
  end

  -- Change visibility of list
  local list = player.gui.top["minime_gui"]["minime_character_list"]
  list.visible = not list.visible

  -- Copy that setting to global.player_data
  global.player_data[player.index].show_character_list = list.visible
minime.dprint("global.player_data[player.index].show_character_list: " .. serpent.line(global.player_data[player.index].show_character_list))
  minime.dprint("End of function " .. f_name .. " (" .. tostring(player.index) .. ")")
end


------------------------------------------------------------------------------------
--                                SELECT CHARACTER!                               --
------------------------------------------------------------------------------------
minime_gui.select_character = function(player, clicked)
  local f_name = "select_character"
  minime.dprint("Entered function " .. f_name .. " (" .. tostring(player) .. ", " ..
                serpent.line(clicked) ..")")

  player = (type(player) == "number" and game.players[player]) or player
  if not (player and player.valid and player.is_player()) then
    error(tostring(player) .. " is not a valid player!")
  elseif not clicked then
    error(tostring(clicked) .. " is not a valid button!")
  end

  local buttons = player.gui.top["minime_gui"]["minime_character_list"]
  minime.dprint(player.name .. " clicked button " .. serpent.line(clicked))

  -- Toggle buttons
  if buttons[clicked] then
    for _, button in pairs(buttons.children) do
      --Turn off clicked button
      if button.name == clicked then
        button.style = "minime_button_off"
        button.tooltip = table_size(global.minime_characters) == 2 and
                            {"minime-GUI.disabled-button-tooltip"} or
                            {"minime-GUI.disabled-button-tooltip-plural"}
        button.enabled = false
      -- Switch other buttons back to normal state (check button.type to prevent crashes with
      -- separator lines or other GUI elements)
      elseif button.type == "button" then
        button.style = "minime_button_on"
        button.tooltip = ""
        button.enabled = true
      end
    end

    -- Store selected character
    global.player_data[player.index].last_character = string.gsub(clicked, "^minime_characters_", "")
    minime.dprint("Changed last_character for player " ..player.name .. " to "..
                  serpent.line(global.player_data[player.index].last_character))

    -- Close GUI if setting "minime_close_gui_on_selection" is enabled
    if minime.minime_close_gui_on_selection then
      minime_gui.gui_toggle(player)
    end
  end

  minime.dprint("End of function " .. f_name .. " (" .. tostring(player.index) .. ", " ..
                serpent.line(clicked) ..")")
end


log("End of script gui.lua!")
return minime_gui
