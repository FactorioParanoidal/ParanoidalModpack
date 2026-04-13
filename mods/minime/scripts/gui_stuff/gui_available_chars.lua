minime.entered_file()

local available = {}


------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--                              Names of GUI elements                             --
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
local names = minime_gui_names.available

------------------------------------------------------------------------------------
--                        GUI for available-character list                        --
------------------------------------------------------------------------------------
-- Toggle button for list of available characters (enable/disable)
--~ local toggle_button_name                = names.buttons.toggle_gui

-- Main frame
local main_frame_name                   = names.frames.main
local main_frame_close_button_name      = names.buttons.main_frame_close

-- Horizontal flow containing character table and button flow
local main_flow_name                    = names.flows.main

-- Flow for buttons
local button_flow_name                  = names.flows.buttons

-- Scroll pane
local scroll_pane_name                  = names.scrollpane.character_list

-- Table containing rows with character icon + character name + checkbox
local button_table_name                 = names.tables.character_list

-- Table rownumber prefix
local table_row_prefix                  = names.prefixes.sprites

-- Sprite prefix
local sprite_prefix                     = names.prefixes.sprites

-- Label prefix
local label_prefix                      = names.prefixes.labels

-- Checkbox prefix
local checkbox_prefix                   = names.prefixes.checkboxes

-- Button to close GUI/apply changes + close GUI
local apply_button_name                 = names.buttons.apply

-- Buttons for bulk changes
local enable_all_button_name            = names.buttons.enable_all
local disable_all_button_name           = names.buttons.disable_all
local toggle_all_button_name            = names.buttons.toggle_all


------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--                                 Local functions                                --
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
local function set_button_state(button_data)
  minime.entered_function({button_data})

  -- We must get a table with button data!
  minime.assert(button_data, "table")

  -- These arguments must exist!
  local player = minime.ascertain_player(button_data.player)
  if not player and player.valid then
    minime.arg_err(player, "player specification")
  end

  local name = minime.assert(button_data.name, "string", "button name") and
                button_data.name

  -- This will be true if anything except false/nil has been passed on, or false
  local state = button_data.state and true or false

  -- Tooltip is optional (may be nil)
  local tooltip = (button_data.tooltip ~= nil) and button_data.tooltip or {""}

minime.show("player", player)
minime.show("name", name)
minime.show("state", state)
minime.show("tooltip", tooltip)

  local buttons = player.gui.screen[main_frame_name][main_flow_name][button_flow_name]
  local button = buttons[name]
  if button and button.valid then
    button.enabled = state
    button.tooltip = tooltip
    minime.writeDebug("%sabled %s.",
                      {state and "En" or "Dis", minime.argprint(button)})
  else
    minime.arg_err(name, "button name")
  end

  minime.entered_function("leave")
end


local function get_checkboxes(player)
  local gui = player and player.valid and player.gui.screen[main_frame_name]
  if not (gui and gui.valid) then
    available.init_gui(player)
  end
  return gui and gui[main_flow_name][scroll_pane_name][button_table_name]
end

local function set_checkbox_state(player, name, state)
  minime.entered_function({player, name, state})

  player = minime.ascertain_player(player)
  if not player and player.valid then
    minime.arg_err(player, "player specification")
  elseif not minime.assert(state, "boolean") then
    minime.arg_err(state, "Boolean value")
  end

  name = minime.assert(name, "string") and
          checkbox_prefix..name or minime.arg_err(name, "button name")

minime.show("name", name)
minime.show("state", state)

  local checkboxes = get_checkboxes(player)
  if checkboxes[name] then
    checkboxes[name].state = state
    minime.writeDebug("%sabled %s.",
                      {state and "En" or "Dis", minime.argprint(checkboxes[name])})
  else
    minime.arg_err(name, "button name")
  end

  minime.entered_function("leave")
end


-- Have all character checkboxes been checked?
local function is_all_enabled(player)
  minime.entered_function({player})

  player = minime.ascertain_player(player)
  if not player and player.valid then
    minime.arg_err(player, "player specification")
  end

  local checkboxes = get_checkboxes(player)
  local ret = true

  for e, element in pairs(checkboxes.children) do
    -- Skip disabled checkbox -- we always want to keep at least one character!
    if element.type == "checkbox" and element.enabled and not element.state then
      ret = false
      minime.writeDebug("Found disabled %s!", {minime.argprint(element)})
      break
    end
  end
minime.show("ret", ret)

  minime.entered_function("leave")
  return ret
end


-- Have all character checkboxes been unchecked?
local function is_all_disabled(player)
  minime.entered_function({player})

  player = minime.ascertain_player(player)
  if not player and player.valid then
    minime.arg_err(player, "player specification")
  end

  local checkboxes = get_checkboxes(player)
  local ret = true

  for e, element in pairs(checkboxes.children) do
    -- Skip disabled checkbox -- we always want to keep at least one character!
    if element.type == "checkbox" and element.enabled and element.state then
      ret = false
      minime.writeDebug("Found enabled character %s!", {minime.argprint(element)})
      break
    end
  end
minime.show("ret", ret)

  minime.entered_function("leave")
  return ret
end


local function update_all_buttons(player)
  minime.entered_function({player})

  player = minime.ascertain_player(player)
  if not player and player.valid then
    minime.arg_err(player, "player specification")
  end

  local p_data = mod.player_data[player.index]

  local function debug_msg(name, state)
    minime.writeDebug("%sabled button \"%s\".", {state and "En" or "Dis", name})
  end

  local state = not is_all_enabled(player)
  set_button_state({
    player = player,
    name = enable_all_button_name,
    state = state,
    tooltip = state and {"minime-GUI.available-list-enable-all-button-tooltip"} or nil
  })
  debug_msg(enable_all_button_name, state)

  state = not is_all_disabled(player)
  set_button_state({
    player = player,
    name = disable_all_button_name,
    state = state,
    tooltip = state and {"minime-GUI.available-list-disable-all-button-tooltip"} or nil,
  })
  debug_msg(disable_all_button_name, state)

  state = p_data.available_pending_changes and next(p_data.available_pending_changes)
  set_button_state({
    player = player,
    name = apply_button_name,
    state = state,
    tooltip = state and {"minime-GUI.available-list-apply-changes-tooltip"},
  })
  debug_msg(apply_button_name, state)

  -- Update tooltip of close button
  local close_button = player.gui.screen[main_frame_name].header[main_frame_close_button_name]
  close_button.tooltip = state and {"minime-GUI.available-list-close-button-tooltip"} or {""}
minime.show("Tooltip of close button", close_button.tooltip)

  minime.entered_function("leave")
end


available.update_all_checkboxes = function(player)
  minime.entered_function({player})

  player = minime.ascertain_player(player)
  if not player and player.valid then
    minime.arg_err(player, "player specification")
  end
  local p_data = mod.player_data[player.index]

  local checkboxes = get_checkboxes(player)
minime.show("checkboxes", checkboxes)

  minime.writeDebugNewBlock("Do we have a valid table for checkboxes?")
  if checkboxes and checkboxes.valid then
    minime.writeDebug("Yes!")
    local char_name
    for c, checkbox in pairs(checkboxes.children) do
minime.show(c, checkbox)
      -- Ignore labels/sprites
      if checkbox.type == "checkbox" then
        char_name = checkbox.name:match(checkbox_prefix.."(.+)")
minime.show("char_name", char_name)
minime.show("p_data.last_character", p_data.last_character)
        if char_name ~= "character" then
          checkbox.enabled = (char_name ~= p_data.last_character)
          minime.writeDebug("%sabled checkbox for %s!",
                            {checkbox.enabled and "En" or "Dis", char_name})

          local tip = "minime-GUI.available-list-disabled-checkbox-tooltip"
          checkbox.tooltip = (not checkbox.enabled) and {tip} or nil
          minime.writeDebug("%s tooltip for checkbox!",
                            {checkbox.enabled and "No" or "Set"})
        end
      end
    end

  else
    minime.writeDebug("No!")
  end

  minime.entered_function("leave")
end




-- Enable single character
local function enable_character(player, char)
  minime.entered_function({player, char})

  player = minime.ascertain_player(player)
  if not player and player.valid then
    minime.arg_err(player, "player specification")
  elseif not (char and mod.minime_characters[char]) then
    minime.arg_err(char, "character name")
  end

  local p_data = mod.player_data[player.index]
  local pending

  p_data.available_pending_changes = p_data.available_pending_changes or {}
  pending = p_data.available_pending_changes
minime.show("Pending changes", pending)

  -- Only add the character to pending changes if there is no pending change yet!
  if pending[char] == nil then
    minime.writeDebug("New pending change: Must enable \"%s\"!", {char})
    pending[char] = true

  -- Pending change: Character was to be disabled, revert the change!
  elseif pending[char] == false then
    minime.writeDebug("Reverting pending change: Will keep \"%s\" enabled!", {char})
    pending[char] = nil

    if not next(pending) then
      p_data.available_pending_changes = nil
      minime.writeDebug("There are no pending changes!")
    end

  -- Pending change: Character already was to be enabled, ignore this request
  -- (Relevant if a checkbox has been enabled before "Enable all" was used.)
  else
    minime.writeDebug("Nothing to do: There already is a pending change to enable \"%s\"!", {char})
  end

  minime.entered_function("leave")
end


-- Enable all characters
local function enable_all_characters(player)
  minime.entered_function({player})

  player = minime.ascertain_player(player)
  if not player and player.valid then
    minime.arg_err(player, "player specification")
  end

  local checkboxes = get_checkboxes(player)
  local char

  for e, element in pairs(checkboxes.children) do
minime.show(e, element)
    -- Skip disabled checkbox -- we always want to keep at least one character!
minime.show("element.enabled", element.enabled)
    if element.type == "checkbox" and element.enabled and not element.state then
      char = element.name:match(checkbox_prefix.."(.+)")
minime.show("char", char)

      enable_character(player, char)
      set_checkbox_state(player, char, true)
    end
  end

  minime.entered_function("leave")
end

-- Disable single character
local function disable_character(player, char)
  minime.entered_function({player, char})

  player = minime.ascertain_player(player)
  if not player and player.valid then
    minime.arg_err(player, "player specification")
  end

  local p_data = mod.player_data[player.index]
  local pending

  p_data.available_pending_changes = p_data.available_pending_changes or {}
  pending = p_data.available_pending_changes

  -- Only add the character to pending changes if there is no pending change yet!
  if pending[char] == nil then
    minime.writeDebug("New pending change: Must disable \"%s\"!", {char})
    pending[char] = false

  -- Pending change: Character was to be enabled, revert the change!
  elseif pending[char] == true then
    minime.writeDebug("Reverting pending change: Will keep \"%s\" disabled!", {char})
    pending[char] = nil

    if not next(pending) then
      p_data.available_pending_changes = nil
      minime.writeDebug("There are no pending changes!")
    end

  -- Pending change: Character already was to be disabled, ignore this request
  -- (Relevant if a checkbox has been disabled before "Disable all" was used.)
  else
    minime.writeDebug("Nothing to do: There already is a pending change to disable \"%s\"!", {char})
  end

  minime.entered_function("leave")
end


-- Disable all characters
local function disable_all_characters(player)
  minime.entered_function({player})

  player = minime.ascertain_player(player)
  if not player and player.valid then
    minime.arg_err(player, "player specification")
  end

  local checkboxes = get_checkboxes(player)
  local char

  for e, element in pairs(checkboxes.children) do
minime.show(element.name, element.enabled)
    -- Skip disabled checkbox -- we always want to keep at least one character!
    if element.type == "checkbox" and element.enabled and element.state then
      minime.writeDebug("Disabling checkbox for character \"%s\"", {element.name})
      char = element.name:match(checkbox_prefix.."(.+)")

      disable_character(player, char)
      set_checkbox_state(player, char, false)
    end
  end

  minime.entered_function("leave")
end



-- Toggle all characters
local function toggle_all_characters(player)
  minime.entered_function({player})

  player = minime.ascertain_player(player)
  if not player and player.valid then
    minime.arg_err(player, "player specification")
  end

  local p_data = mod.player_data[player.index]
  local checkboxes = get_checkboxes(player)
  local char

  for e, element in pairs(checkboxes.children) do
    -- Skip disabled checkbox -- we always want to keep at least one character!
    if element.type == "checkbox" and element.enabled then
      char = element.name:match(checkbox_prefix.."(.+)")

      -- Disable checkbox
      if element.state then
        disable_character(player, char)

      -- Enable checkbox
      else
        enable_character(player, char)
      end

      -- Update checkbox state
      set_checkbox_state(player, char, not element.state)
    end
  end

  -- Update number of hidden characters
  p_data.hidden_characters = available.count_hidden_characters(player)
  minime.writeDebug("Updated number of hidden characters (%s)!", {p_data.hidden_characters})

  minime.entered_function("leave")
end


-- Apply all changes
local function apply_changes(player)
  minime.entered_function({player})

  player = minime.ascertain_player(player)
  if not player and player.valid then
    minime.arg_err(player, "player specification")
  end

  local p_data = mod.player_data[player.index]

  for char, state in pairs(p_data.available_pending_changes) do
    -- Update table of available characters
    p_data.available_characters[char] = state

    -- If a character was removed from the character selector, we can also remove
    -- the preview entity!
    if not state then
      minime_player.remove_single_character_preview(player, char)
      minime.writeDebug("Removed preview entity for hidden character \"%s\"!",
                        {char})
    end
  end
  minime.writeDebug("Applied all changes to player data!")

  -- Remove list of pending changes
  p_data.available_pending_changes = nil
  minime.writeDebug("Removed list of pending changes!")

  -- Count hidden characters (turned off by the player)
  p_data.hidden_characters = available.count_hidden_characters(player)
  minime.writeDebug("Number of characters turned off by %s: %s",
                    {minime.argprint(player), p_data.hidden_characters})

  -- Update character selector
  minime_player.init_player({player = player})

  minime.entered_function("leave")
end



------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--                                Shared functions                                --
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
--          Initialize list of characters that are available to a player          --
------------------------------------------------------------------------------------
available.init_player_character_list = function(player)
  minime.entered_function({player})

  player = minime.ascertain_player(player)
  if not player and player.valid then
    minime.arg_err(player, "player specification")
  end

  local p_data = mod.player_data[player.index]
  p_data.available_characters = p_data.available_characters or {}

  local chars = mod.minime_characters

  -- Temporary list starts with all characters used in the game
  local tmp = {}
  for char, c in pairs(chars) do
    tmp[char] = true
  end

  -- Copy state of players's available characters to temporary list
  for a_name, a_char in pairs(p_data.available_characters) do
    if tmp[a_name] then
      tmp[a_name] = a_char
    end
  end

  -- Move temporary list to list of available characters
  p_data.available_characters = table.deepcopy(tmp)

minime.show("p_data.available_characters", p_data.available_characters)

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--         Make list of characters that will go together on one GUI page!         --
------------------------------------------------------------------------------------
available.count_hidden_characters = function(player)
  minime.entered_function({player})

  player = minime.ascertain_player(player)
  if not player and player.valid then
    minime.arg_err(player, "player specification")
  end

  local p_data = mod.player_data[player.index]
  local ret = 0

  for char, state in pairs(p_data.available_characters) do
    if not state then
      minime.writeDebug("Found hidden character: \"%s\"", {char})
      ret = ret + 1
    end
  end
  minime.show("Hidden characters", ret)

  minime.entered_function("leave")
  return ret
end


------------------------------------------------------------------------------------
--                  Initialize GUI for available-character list!                  --
------------------------------------------------------------------------------------
available.init_gui = function(player)
  minime.entered_function({player})

  player = minime.ascertain_player(player)

  if not (player and player.valid) then
    minime.arg_err(player, "player specification")
  end

  -- Leave early if character-selector mode has been turned off
  if not minime.character_selector then
    minime.writeDebug("Character selector is disabled -- check if any players have a GUI.")
    for p_index, p in pairs(game.players) do
      available.remove_gui(p)
    end

    minime.entered_function({player}, "leave", "Character selector is disabled!")
    return
  end

  ------------------------------------------------------------------------------------
  local p_data = mod.player_data[player.index]

  -- Make sure player has a  list of available characters!
  if not p_data.available_characters then
    minime.writeDebug("Initializing list of available characters for %s!",
                      {minime.argprint(player)})
    minime_gui.available.init_player_character_list(player)
  end
minime.show("p_data.available_characters", p_data.available_characters)
minime.show("table_size(p_data.available_characters)", table_size(p_data.available_characters))

  -- Leave early and remove GUI if there are not enough characters available
  -- (This GUI is only useful if there are at least 2 characters to choose from.)
  if table_size(p_data.available_characters) < 2 then
    minime.writeDebug("Not enough characters available -- check if any players have a GUI.")
    for p_index, p in pairs(game.players) do
      available.remove_gui(p)
    end

    minime.entered_function({player}, "leave", "not enough characters available!")
    return
  end


  ------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------
  --                              DEFINE TOGGLE BUTTON                              --
  ------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------

  -- Moved toggle button from button flow to selector GUI in 1.1.23!



  ------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------
  --                                   CREATE GUI                                   --
  ------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------
  local gui = player.gui.screen

  ------------------------------------------------------------------------------------
  --            Construct the main frame that will contain the entire GUI           --
  ------------------------------------------------------------------------------------
  -- Create main frame (contains header and main flow)
  local main_frame = gui[main_frame_name]
  if not (main_frame and main_frame.valid) then
    main_frame = gui.add({
      type = "frame",
      name = main_frame_name,
      direction = "vertical",
      visible = p_data.show_available_character_list or false,
    })
    minime.writeDebug("Created %s!", {minime.argprint(main_frame)})
  else
    main_frame.clear()
    minime.writeDebug("Cleared %s!", {minime.argprint(main_frame)})
  end

  gui = main_frame

  -- Create header
  local header = minime_gui.make_flow({
    parent = gui,
    name = "header",
    caption = {"minime-GUI.available-chars-frame-caption"},
    direction = "horizontal"
  })
  minime.writeDebug("Created %s", {minime.argprint(header)})
  header.style.vertically_stretchable = false
  header.title.drag_target = gui

  -- Spacer to push closing button to the right (can be used to drag GUI)
  local dragspace = header.add({
    type = 'empty-widget',
    name = 'dragspace',
    style = 'draggable_space_header',
  })
  dragspace.drag_target = gui
  dragspace.style.horizontally_stretchable = true
  dragspace.style.vertically_stretchable = true

  -- Closing button
  header.add({
    type = "sprite-button",
    name = main_frame_close_button_name,
    visible = true,
    style = "frame_action_button",
    --~ sprite = "utility/close_white",
    sprite = "utility/close",
    mouse_button_filter = {"left"},
  })
  minime.writeDebug("Created GUI header!")


  ------------------------------------------------------------------------------------
  -- Create horizontal main flow (for list of available characters and button flow)
  local main_flow = minime_gui.make_flow({
    parent = gui,
    name = main_flow_name,
    direction = "horizontal"
  })
  minime.writeDebug("Created %s", {minime.argprint(header)})
  main_flow.style.vertical_align = "bottom"
  main_flow.style.maximal_height = 500



  ------------------------------------------------------------------------------------
  -- Create scroll pane: Container for table listing available characters
  local scroll_pane =  main_flow.add({
    type = "scroll-pane",
    name = scroll_pane_name,
  })

  ------------------------------------------------------------------------------------
  -- Create table: List of available characters
  local elements = scroll_pane.add({
    type = "table",
    name = button_table_name,
    column_count = 4,
    visible = true,
  })
  minime.writeDebug("Created %s.", {minime.argprint(elements)})

  local element

  local cnt = 0
  for char, c in pairs(p_data.available_characters) do
    cnt = cnt + 1
    -- Row number
    element = elements.add({
      type = "label",
      name = table_row_prefix..cnt,
      caption = cnt,
      visible = true,

    })
    minime.writeDebug("Created %s.", {minime.argprint(element)})

    -- Sprite
    element = elements.add({
      type = "sprite",
      name = sprite_prefix..char,
      sprite = "entity/"..char,
      visible = true,
    })
    minime.writeDebug("Created %s.", {minime.argprint(element)})

    -- Label
    element = elements.add({
      type = "label",
      name = label_prefix..char,
      caption = mod.minime_characters[char].loc_name,
      visible = true,
    })
    minime.writeDebug("Created %s.", {minime.argprint(element)})

    -- Checkbox
    element = elements.add({
      type = "checkbox",
      name = checkbox_prefix..char,
      state = p_data.available_characters[char],
      visible = true,
      enabled = p_data.last_character ~= char,
    })
    minime.writeDebug("Created %s.", {minime.argprint(element)})

    -- Are there pending changes? If the GUI is re-initialized (e.g. for
    -- on_configuration_changed), we must account for that when setting the state!
    local pending = p_data.available_pending_changes
    if pending and pending[char] ~= nil then
      element.state = pending[char]
      minime.writeDebug("Changed state of %s to %s (change pending)!",
                        {minime.argprint(element), element.state})
    end

    -- Default character can't be disabled
    if char == "character" then
      element.enabled = false
      minime.writeDebug("Disabled %s!", {minime.argprint(element)})
    end
  end


  ----------------------------------------------------------------------------------
  -- Create spacer
  local spacer = minime_gui.make_spacer(main_flow, button_table_name.."spacer", 100)
  minime.writeDebug("Created %s.", {minime.argprint(spacer)})


  ----------------------------------------------------------------------------------
  -- Create vertical flow for buttons
  local button_flow = minime_gui.make_flow({
    parent = main_flow,
    name = button_flow_name,
  })
  minime.writeDebug("Added %s.", {minime.argprint(button_flow)})



  -- Create "Enable all" button
  element = button_flow.add({
    type = "button",
    name = enable_all_button_name,
    caption = {"minime-GUI.available-list-enable-all-button-caption"},
    enabled = not is_all_enabled(player) and true or false,
    visible = true,
    style = "minime_character_button_on",
  })
  minime.writeDebug("Added %s.", {minime.argprint(element)})

  -- Create "Disable all" button
  element = button_flow.add({
    type = "button",
    name = disable_all_button_name,
    caption = {"minime-GUI.available-list-disable-all-button-caption"},
    enabled = not is_all_disabled(player) and true or false,
    visible = true,
    style = "minime_character_button_on",
  })
  minime.writeDebug("Added %s.", {minime.argprint(element)})

  -- Create "Toggle all" button
  element = button_flow.add({
    type = "button",
    name = toggle_all_button_name,
    caption = {"minime-GUI.available-list-toggle-all-button-caption"},
    enabled = true,
    visible = true,
    tooltip = {"minime-GUI.available-list-toggle-all-button-tooltip"},
    style = "minime_character_button_on",
  })
  minime.writeDebug("Added %s.", {minime.argprint(element)})

  -- Create button to close available character list and apply changes
  element = button_flow.add({
    type = "button",
    name = apply_button_name,
    caption = {"minime-GUI.available-list-apply-changes-caption"},
    enabled = p_data.available_pending_changes and next(p_data.available_pending_changes) and
              true or false,
    visible = true,
    style = "minime_character_button_on",
  })
  minime.writeDebug("Added %s.", {minime.argprint(element)})

  -- Update buttons
  update_all_buttons(player)

  minime.entered_function("leave")
  return gui
end

--~ ------------------------------------------------------------------------------------
--~ --               Reinitialize GUI when runtime settings are changed!              --
--~ ------------------------------------------------------------------------------------
--~ minime_gui.init_guis = function()
  --~ minime.entered_function()

  --~ for p, player in pairs(game.players) do
    --~ minime_gui.init_available_character_gui(player)
    --~ minime_gui.init_gui(player)
  --~ end

  --~ minime.entered_function("leave")
--~ end

------------------------------------------------------------------------------------
--                                   REMOVE GUI!                                  --
------------------------------------------------------------------------------------
available.remove_gui = function(player)
  minime.entered_function({player})

  -- This function can be called with index/name/entity of a real player, or with
  -- event data (player_index).
  player = minime.ascertain_player(player)

  if player and player.valid then
    minime.writeDebug("Trying to remove GUI of player %s", player.name)

    -- Remove character list
    local gui_frames = player.gui.screen
    if gui_frames and gui_frames[main_frame_name] and
                      gui_frames[main_frame_name].valid then
      gui_frames[main_frame_name].destroy()
      minime.writeDebug("Removed GUI of player %s!", {player.name or "nil"})
    end

  end
  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                                    HIDE GUI!                                   --
------------------------------------------------------------------------------------
available.hide_gui = function(player)
  minime.entered_function({player})

  -- This function can be called with index/name/entity of a real player, or with
  -- event data (player_index).
  player = minime.ascertain_player(player)

  if player and player.valid then
    minime.writeDebug("Trying to hide GUI of player %s", player.name)

    -- Hide character list
    do
      local gui_frames = player.gui.screen
      local gui = gui_frames and gui_frames[main_frame_name]
      if gui and gui.valid then
        local tags = gui.tags
minime.show("tags", tags)
        tags.visible = gui.visible
        gui.tags = tags
        gui.visible = false
        minime.writeDebug("GUI of player %s is now invisible!",
                          {player.name or "nil"})
      end
    end

  end
  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                                   UNHIDE GUI!                                  --
------------------------------------------------------------------------------------
available.unhide_gui = function(player)
  minime.entered_function({player})

  -- This function can be called with index/name/entity of a real player, or with
  -- event data (player_index).
  player = minime.ascertain_player(player)

  if player and player.valid then
    minime.writeDebug("Trying to unhide GUI of player %s", player.name)


    -- Unhide character list
    do
      local gui_frames = player.gui.screen
      local gui = gui_frames and gui_frames[main_frame_name]
      if gui and gui.valid then
        local tags = gui.tags or {}
minime.show("tags", tags)
          --~ gui.tags = tags
        --~ if tags ~= nil then
          --~ gui.visible = tags.visible
        --~ else
          --~ gui.visible = true
        --~ end
--~ minime.show("gui.visible", gui.visible)

        --~ tags.visible = nil
            if tags.visible ~= nil then
              gui.visible = tags.visible
            else
              gui.visible = true
              tags.visible = true
            end
    minime.show("gui.visible", gui.visible)

        gui.tags = tags
        minime.writeDebug("GUI of player %s is now %s!",
                  {player.name or "nil", gui.visible and "visible" or "invisible"})
      end
    end

  end
  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                      TOGGLE LIST OF AVAILABLE CHARACTERS!                      --
------------------------------------------------------------------------------------
available.gui_toggle = function(player)
  minime.entered_function({player})

  player = minime.ascertain_player(player)
  if not (player and player.valid) then
    minime.arg_err(player, "player specification")
  end

  -- Change visibility of list
  local gui = player.gui.screen and player.gui.screen[main_frame_name]

  if not (gui and gui.valid) then
    minime.writeDebug("Initializing GUI!")
    gui = available.init_gui(player)
  end
minime.show("gui", gui)

minime.show("gui.visible", gui and gui.valid and gui.visible)
  gui.visible = not gui.visible
minime.show("Toggled gui.visible", gui and gui.valid and gui.visible)

  -- If GUI is visible, it should be in the foreground
  if gui.visible then
    gui.bring_to_front()
    minime.writeDebug("%s is now on top!", {minime.argprint(gui)})
  end

  -- Copy that setting to mod.player_data
  local p_data = mod.player_data[player.index]
  p_data.show_available_character_list = gui.visible
minime.show("p_data.show_available_character_list", p_data.show_available_character_list)

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--                              GUI-ACTION DETECTED!                              --
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
--                               Button was clicked                               --
------------------------------------------------------------------------------------
available.on_gui_click = function(event)
  minime.entered_function({event})

  local button = event.element.name

  if not minime.prefixed(button, minime.available_chars_prefix) then
    minime.entered_function({}, "leave", "Nothing to do for %s \""..minime.argprint(event.element).."\"!")
    return
  end

  local player = minime.ascertain_player(event.player_index)
  local update_buttons = true

  ------------------------------------------------------------------------------------
  -- Close button was clicked
  if button == main_frame_close_button_name then
    minime.writeDebug("%s closed the selection list.", {player.name})
    available.gui_toggle(player)

  -- Apply button was clicked
  elseif button == apply_button_name then
    minime.writeDebug("%s applied the changes.", {player.name})
    apply_changes(player)

  -- Enable all
  elseif button == enable_all_button_name then
    minime.writeDebug("%s enabled all characters.", {player.name})
    enable_all_characters(player)

  -- Disable all
  elseif button == disable_all_button_name then
    minime.writeDebug("%s disabled all characters.", {player.name})
    disable_all_characters(player)

  -- Toggle all
  elseif button == toggle_all_button_name then
    minime.writeDebug("%s toggled all characters.", {player.name})
    toggle_all_characters(player)

  -- Something else from our GUI has been clicked
  else
    update_buttons = false
    minime.writeDebug("Nothing to do for \"%s\"!", {button})
  end

  if update_buttons then
    minime.writeDebug("Must update buttons!")
    update_all_buttons(player)
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                           Checkbox state has changed                           --
------------------------------------------------------------------------------------
available.on_gui_checked_state_changed = function(event)
  minime.entered_function({event})

  local checkbox = event.element

  local player = minime.ascertain_player(event.player_index)

  if not minime.prefixed(checkbox.name, minime.available_chars_prefix) then
    minime.entered_function({}, "leave", "Nothing to do for %s \""..minime.argprint(checkbox).."\"!")
    return
  end


  ------------------------------------------------------------------------------------
  local char_name = checkbox.name:match(checkbox_prefix.."(.+)")
minime.show("checkbox.name", checkbox.name)
minime.show("checkbox_prefix", checkbox_prefix)
minime.show("char_name", char_name)


  -- We also want to handle enabling/disabling checkboxes in response to other GUI
  -- events, so let's call different functions depending on the checkbox state!
  if checkbox.state then
    enable_character(player, char_name)
  else
    disable_character(player, char_name)
  end

  -- Update buttons
  update_all_buttons(player)

  minime.entered_function("leave")
end

------------------------------------------------------------------------------------
minime.entered_file("leave")
return available
