minime.entered_file()

local selector = {}

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--                              Names of GUI elements                             --
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
local names = minime_gui_names.selector
minime.show("selector names", names)

------------------------------------------------------------------------------------
--                             Character selector GUI                             --
------------------------------------------------------------------------------------
-- Toggle button for the GUI
local toggle_button_name                = names.buttons.toggle_gui

-- Toggle button for the "Available characters" GUI (Added in 1.1.23)
local toggle_button_available_name      = names.buttons.toggle_available_gui

-- The master flow that contains the entire GUI, and its close button
local main_frame_name                   = names.frames.main

local main_frame_close_button_name      = names.buttons.main_frame_close

-- Frame for character previews and buttons
local character_frame_name              = names.frames.characters

-- Flow containing removal flow/info flow/page selector flow
local bottom_flow_name                  = names.flows.bottom

-- Flow (vertical) containing title and buttons flow for removal buttons
local removal_flow_name                 = names.flows.removal

-- Flow (horizontal) for removal buttons
local removal_buttons_flow_name         = names.flows.removal_buttons

-- Flow (horizontal) for removal buttons
local toggle_available_flow_name        = names.flows.toggle_available

-- Flow for information about the current character
local info_flow_name                    = names.flows.info

-- Label showing the name of the current character
local current_char_name                 = names.labels.current_char

-- Numbered tables that function as pages of character previews and buttons
local character_page_prefix             = names.character_page_prefix

--~ -- Number of columns each of these tables will have
--~ local characters_per_page       = 5

-- Flow (vertical) containing title and GUI elements for character-page selector
local character_pages_flow_name         = names.flows.character_pages

-- Flow (horizontal) containing the GUI elements for character-page selector
local character_page_selector_flow_name = names.flows.character_page_selector

-- Buttons for turning to the next/previous character preview page
local prev_button_name                  = names.buttons.previous
local next_button_name                  = names.buttons.next

-- Dropdown list for choosing a character preview page directly
local dropdown_list_name                = names.dropdown_list

-- Add horizontal space of variable width
local spacer_name                       = names.spacer

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--                                 Local functions                                --
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

--~ local function test(parent)
--~ minime.show("Parent", parent and parent.name)
  --~ for k, v in pairs(parent.children) do
  --~ minime.show(k, v)
  --~ end
--~ end

local function make_table(parent, page)
  minime.entered_function({parent, page})

  local player = parent and parent.gui and parent.gui.player
  local p_data = player and mod.player_data[player.index]
  p_data.character_gui_page = p_data.character_gui_page or
                              selector.get_character_gui_page(player)
  local p_page = p_data.character_gui_page
  local visible = (p_page == page)
  local active = p_data.show_character_list and visible or false

  ------------------------------------------------------------------------------------
  -- Create table: entity-previews above clickable buttons
  local ret = parent.add({
    type = "table",
    name = character_page_prefix..page,
    column_count = minime_gui.characters_per_page,
    visible = visible,
  })
  minime.writeDebug("Created %s.", {minime.argprint(ret)})

  local char, element, id, preview, preview_entity
  local chars = p_data.gui_character_pages[page]
  -- Preview the character at twice its unscaled size!
  local zoom = 2 / minime.minime_character_scale
  -- Move the camera down a bit, depending on the scale factor
  local offset = 0.75 * minime.minime_character_scale

  ------------------------------------------------------------------------------------
  -- First table row: Previews
  for i = 1, minime_gui.characters_per_page do
    char = chars[i]
    preview = char and mod.minime_characters[char] and
                        mod.minime_characters[char].preview
minime.show("char", char)
minime.show("preview", preview)
    -- Create preview
    if preview and preview.surface and preview.surface.valid and preview.entities then
      preview_entity = preview.entities[player.index]
minime.show("preview_entity", preview_entity)
      if preview_entity and preview_entity.valid then
        -- We want active entities for their idle animation, which is only visible
        -- when the GUI is visible.
        preview_entity.active = active

        element = minime.character_preview_prefix..char
minime.show("element", element)
        ret.add({
          type = "camera",
          name = element,
          zoom = zoom,
          surface_index = preview.surface.index,
          position = {preview_entity.position.x, preview_entity.position.y - offset},
          -- The camera will function as an alternative to the button. We will set
          -- its real "enabled" state when we update the button states.
          enabled = true,
        })
        ret[element].style.size = 160
minime.show("ret[element]", ret[element])
minime.show("ret[element].position", ret[element].position)
minime.show("preview_entity", preview_entity)
minime.show("preview_entity.position", preview_entity.position)
        minime.writeDebug("Added preview for character \"%s\".", {char})
      end
    -- Add a spacer to fill up the table
    else
minime.writeDebug("Must add spacer!")
      id = (id or 0) + 1
      minime_gui.make_spacer(ret, minime.character_placeholder_prefix..id, 160)
    end
  end

  ------------------------------------------------------------------------------------
  -- Second table row: Character selection buttons
  --~ for char, data in pairs(global.minime_characters) do
  for i = 1, minime_gui.characters_per_page do
    char = chars[i]

    if char and ret[minime.character_preview_prefix..char] then
      element = minime.character_button_prefix..char

      -- All buttons are enabled for now, we'll call the update function to set the
      -- real state at the end of this function.
      ret.add({
        type = "button",
        name = element,
        caption = mod.minime_characters[char].loc_name,
        enabled = true,
        style = "minime_character_button_on",
      })
      minime.writeDebug("Added %s.", {minime.argprint(ret[element])})

    --~ -- Add a spacer to fill up the table
    --~ else
      --~ id = (id or 0) + 1
      --~ make_spacer(ret, minime.character_placeholder_prefix..id, 160)
    end
  end

  -- All columns should be centered horizontally!
  for column = 1, ret.column_count do
    ret.style.column_alignments[column] = "center"
  end

  minime.entered_function("leave")
  return ret
end


selector.toggle_character_page_entities = function(player, page, state)
  minime.entered_function({player, page})

  player = minime.ascertain_player(player)
  if not player and player.valid then
    minime.argerr(player, "player specification")
  elseif not minime.check_args(page, "number") then
    minime.argerr(page, "page number")
  elseif not minime.check_args(state, "boolean") then
    minime.argerr(state, "Boolean value")
  end

  local p_data = mod.player_data[player.index]

  -- Make preview entities on page active/inactive (depending on state)
  local chars = mod.minime_characters
  local previews = p_data.gui_character_pages[page]

  local preview

  for c, char in ipairs(previews or {}) do
    preview = chars[char] and chars[char].preview and
                              chars[char].preview.entities and
                              chars[char].preview.entities[player.index]

    if preview and preview.valid then
      preview.active = state
      minime.writeDebug("%sctivated preview %s.",
                        {preview.active and "A" or "Dea", minime.argprint(preview)})
    end
  end

  minime.entered_function("leave")
end

------------------------------------------------------------------------------------
--                                   UPDATE GUI!                                  --
------------------------------------------------------------------------------------
local function prepare_button_state(data)
  minime.entered_function({data})

  local clicked_condition = data and data.condition

  -- "styles" may be nil, but must be a table if it is not nil!
  local styles = data and data.styles
  if styles and type(styles) ~= "table" then
    minime.argerr(styles, "table of button style names")
  end

  -- If there are at least this many green buttons, we'll use the plural form
  -- of the caption.
  local green_button_plural_threshold = data and
                                        data.green_button_plural_threshold or 2

  -- Whether the singular or plural tooltip will be used for the character buttons
  -- depends on whether a character selection or removal button has been clicked!
  local select_char = data and data.select_char
  local remove_char = data and data.remove_char

  local ret = {}

  -- Button has been clicked, disable it!
  if clicked_condition then
    local char_cnt = table_size(mod.minime_characters)

    ret.enabled = false
    ret.style = (styles and styles.disabled) or "minime_button_off"

    if select_char then
      ret.tooltip = (char_cnt == 1 and
                      {"minime-GUI.disabled-button-tooltip-single-button"}) or
                    (char_cnt < green_button_plural_threshold and
                      {"minime-GUI.disabled-button-tooltip"}) or
                    {"minime-GUI.disabled-button-tooltip-plural"}
    elseif remove_char then
      ret.tooltip = char_cnt < green_button_plural_threshold and
                      {"minime-GUI.disabled-removal-button-tooltip"} or
                      {"minime-GUI.disabled-removal-button-tooltip-plural"}
    end

  -- Another button has been clicked, this one must be enabled!
  else
    ret.enabled = true
    ret.style = (styles and styles.enabled) or "minime_character_button_on"
    ret.tooltip = ""
  end

  minime.entered_function("leave")
  return ret
end


local function set_button_state(button, state)
  minime.entered_function({button, state})

  if button and state then
    for k, v in pairs(state) do
      button[k] = table.deepcopy(state[k])
    end
minime.writeDebug("Updated state of button \"%s\"", {button.name})
  end

  minime.entered_function("leave")
end


local function update_character_buttons(player_data, buttons)
  minime.entered_function({player_data, buttons})

  if player_data and buttons then
    --~ local state, short_name, removed, camera
    local state, short_name, camera

    -- If one of the green buttons has been clicked, there must be at least 2 OTHER
    -- green buttons (i.e. a total of 3) before we can use the plural form. If a red
    -- button has been clicked, all green buttons will be enabled and we can use the
    -- plural if there are at least 2 green buttons.
    local plural_threshold = (player_data.god_mode or player_data.editor_mode) and
                              2 or 3

    -- Toggle buttons
    for b, button in pairs(buttons.children) do

      if button.type == "button" then
minime.writeDebug("Updating button \"%s\"", {button.name})
        short_name = button.name:gsub("^"..minime.character_button_prefix, "")
minime.show("short_name", short_name)
        -- Get new button state
        state = prepare_button_state({
          --~ condition = removed or (short_name == player_data.last_character),
          condition = (short_name == player_data.last_character),
          green_button_plural_threshold = plural_threshold,
          select_char = true,
        })

        -- Update button state
        set_button_state(button, state)

        -- Set camera state (clickable?)
        camera = buttons[minime.character_preview_prefix..short_name]
minime.show("camera", camera)
        if camera and camera.valid then
          camera.enabled = state.enabled
minime.show("camera.enabled", camera.enabled)
        end
      else
minime.writeDebug("Ignoring %s \"%s\"!", {button.type, button.name})
      end
    end
  else
    minime.arg_err(player_data, "player data")
  end
  minime.entered_function("leave")
end


local function update_removal_buttons(player_data, buttons)
  minime.entered_function({player_data, buttons})

  if player_data and buttons then
    local god_mode = minime.character_button_prefix..minime.godmode_button_name
    local editor_mode = minime.character_button_prefix..minime.editor_button_name


    -- Toggle buttons
    local nocharacter_styles = {enabled = "minime_nocharacter_button_on"}

    -- If one of the red buttons was clicked, all green buttons will be active, so
    -- we must use the plural if there are at least 2 green buttons.
    local plural_threshold = 2

    local state
    for b, button in pairs(buttons.children) do
      -- We only have these two buttons now, but perhaps we'll need something
      -- else later.
      if (button.name == god_mode) or (button.name == editor_mode) then
minime.writeDebug("Updating button \"%s\"", {button.name})
        state = prepare_button_state({
          condition = (button.name == god_mode and player_data.god_mode) or
                      (button.name == editor_mode and player_data.editor_mode),
          styles = nocharacter_styles,
          green_button_plural_threshold = plural_threshold,
          remove_char = true,
        })
        set_button_state(button, state)
      else
minime.writeDebug("Ignoring %s \"%s\"!", {button.type, button.name})
      end
    end
  else
    minime.arg_err(player_data, "player data")
  end
  minime.entered_function("leave")
end


selector.update_page_selector_buttons = function(data)
  minime.entered_function({data})

  -- Check arguments
  if not minime.check_args(data, "table") then
    minime.arg_err(data, "table")
  end

  local player = minime.ascertain_player(data.player_index) or
                  minime.arg_err(data.player_index, "player specification")
  local element = minime.check_args(data.element, "LuaGuiElement") and data.element or
                  minime.arg_err(data and data.element, "LuaGuiElement")


  local player_data = mod.player_data[player.index]
  local old_page = player_data.character_gui_page or
                    selector.get_character_gui_page(player)

  local new_page
  local last_page = table_size(player_data.gui_character_pages)

  local gui = player.gui.screen[main_frame_name]
  local elements = gui[bottom_flow_name][character_pages_flow_name][character_page_selector_flow_name]
  local previews = gui[character_frame_name]


  local function set_button(button, enabled)
    if enabled then
      --~ button.style = "minime_character_button_on"
      button.style = "minime_arrow_button_on"
      button.enabled = true
    else
      --~ button.style = "minime_button_off"
      button.style = "minime_arrow_button_off"
      button.enabled = false
    end
    minime.writeDebug("%sabled %s!", {enabled and "En" or "Dis", minime.argprint(button)})
  end


  -- A new page has been chosen via the drop-down list. Just update these buttons!
  if element.name == dropdown_list_name then
    minime.writeDebug("Dropdown list was used. Must update state of character-page selector buttons!")

    new_page = elements[dropdown_list_name].selected_index

  -- One of the buttons has been used
  else
    minime.writeDebug("%s was used!", {minime.argprint(element)})

    new_page = (element.name == prev_button_name and old_page - 1) or
                (element.name == next_button_name and old_page + 1) or
                old_page

    -- Make sure the new page is within range
    if new_page < 1 then
      new_page = 1
    elseif new_page > last_page then
      new_page = last_page
    end

    -- Deactivate preview entities from the old page, and hide the old page
    selector.toggle_character_page_entities(player, old_page, false)
    previews[character_page_prefix..old_page].visible = false
    minime.writeDebug("%s is now hidden!", {minime.argprint(previews[character_page_prefix..old_page])})

    -- Activate preview entities from the new page, and unhide it
    selector.toggle_character_page_entities(player, new_page, true)
    previews[character_page_prefix..new_page].visible = true
    minime.writeDebug("%s is now visible!", {minime.argprint(previews[character_page_prefix..new_page])})

    -- Update the dropdown list!
    minime_gui.on_gui_selection_state_changed(data)

    -- Don't forget to store new_page in the global table!
    player_data.character_gui_page = new_page
  end

  -- Button for previous page is enabled on all pages but the first
  set_button(elements[prev_button_name], new_page > 1)

  -- Button for next page is enabled on all pages but the last
  set_button(elements[next_button_name], new_page < last_page)


  minime.entered_function("leave")
end


local function update_character_info(player)
  minime.entered_function({player})

  -- Check arguments
  player = minime.ascertain_player(player)
  if not player and player.valid then
    minime.arg_err(player, "player specification")
  end

minime.show("Player", player)

  local p_data = mod.player_data[player.index]
  local gui = player.gui.screen and player.gui.screen[main_frame_name]
  local elements = gui[bottom_flow_name][info_flow_name]

  --~ local show_removal_buttons = player.admin and minime.show_removal_buttons
  local show_removal_buttons = player.admin and
                                mod.map_settings.show_removal_buttons

  -- What name should be displayed?
  local char
  -- Use the localized character name if the character is valid
  if p_data.last_character ~= "" then
    char = mod.minime_characters[p_data.last_character] and
            mod.minime_characters[p_data.last_character].loc_name or ""
    minime.writeDebug("Player has a character!")
  -- We're in god or editor mode. If removal buttons are shown, we output nothing.
  elseif show_removal_buttons then
    char = ""
    minime.writeDebug("Player has no character, removal buttons are shown.")
  -- We're in god or editor mode, the removal buttons are hidden. Output mode.
  else
    char = (p_data.editor_mode and {"minime-GUI.editor-mode-button-caption"}) or
            (p_data.god_mode and {"minime-GUI.god-mode-button-caption"}) or
            ""
    minime.writeDebug("Player has no character, removal buttons are hidden.")
  end
minime.show("char", char)
  elements[current_char_name].caption = char

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--                                Shared functions                                --
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------


------------------------------------------------------------------------------------
--         Make list of characters that will go together on one GUI page!         --
------------------------------------------------------------------------------------
selector.make_gui_character_pages = function(player)
  minime.entered_function({player})

  player = minime.ascertain_player(player)
  if not player and player.valid then
    minime.arg_err(player, "player specification")
  end

  local p_data = mod.player_data[player.index]
  p_data.gui_character_pages = {}
  p_data.gui_character_pages_lookup = {}

  -- Make the list of characters available to the player
  minime.writeDebugNewBlock("Initializing player character list!")
  minime_gui.available.init_player_character_list(player)

  local chars = p_data.available_characters
  local pages = p_data.gui_character_pages
  local lookup = p_data.gui_character_pages_lookup

  local cnt = 1
  local page = 1

  for char, c_state in pairs(chars) do
minime.show(char, c_state)
    -- Characters are enabled (true) or disabled (false)
    if c_state then
      if cnt > minime_gui.characters_per_page then
        page = page + 1
        cnt = 1
      end

      pages[page] = pages[page] or {}
      pages[page][cnt] = char

      lookup[char] = page

      cnt = cnt + 1
    end
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                 Which GUI page has the preview of a character?                 --
--  Find character with the name passed on, or the current/detached character of  --
--  the player.                                                                   --
------------------------------------------------------------------------------------
selector.get_character_gui_page = function(player)
  minime.entered_function({player})

  player = minime.ascertain_player(player)
  if not player and player.valid then
    minime.arg_err(player, "player specification or character name")
  end

  local player_data = mod.player_data[player.index]
  local chars = mod.minime_characters
  local available = player_data.available_characters or minime.EMPTY_TAB
  local char

  -- The character name we've stored for the player points to a valid prototype
  if player_data and player_data.last_character and
                      chars[player_data.last_character] and
                      available[player_data.last_character] then
    char = player_data.last_character
    minime.writeDebug("Using player_data.last_character: %s!", {char})
  -- We may have a detached character if the player is in god mode
  elseif player_data and player_data.detached_character and
                          player_data.detached_character.valid and
                          available[player_data.detached_character] then
    char = chars[player_data.detached_character.name] and
            player_data.detached_character.name
    minime.writeDebug("Using player_data.detached_character %s!", {char})
  end

  local ret = player_data and player_data.gui_character_pages_lookup[char] or 1

minime.show("ret", ret)

  minime.entered_function("leave")
  return ret
end


------------------------------------------------------------------------------------
--                              Create toggle button                              --
------------------------------------------------------------------------------------
selector.create_toggle_button = function(player)
  minime.entered_function({player})

  player = minime.ascertain_player(player)
  if not player and player.valid then
    minime.arg_err(player, "player specification or character name")
  end

  local p_data = mod.player_data[player.index]

    -- Create toggle button unless shortcuts are used instead
  if p_data and p_data.settings and
                p_data.settings.toggle_gui_with == "button" then

    local buttons = mod_gui.get_button_flow(player)

    if buttons and buttons.valid then
      local toggle = buttons[toggle_button_name]
      if not (toggle and toggle.valid) then
        buttons.add({
          type = "sprite-button",
          name = toggle_button_name,
          --~ caption = {"minime-GUI.toggle-char-selector-button-caption"},
          sprite = "toggle-char-selector-gui",
          tooltip = {"minime-GUI.toggle-char-selector-button-tooltip"},
          enabled = true,
          ignored_by_interaction = false,
          --~ style = "minime_toggle_button"
          style = "minime_toggle_button_in_flow"
        })
        minime.writeDebug("Created character-selector toggle button!")
      end
    end
  end

  minime.entered_function("leave")
  return
end


------------------------------------------------------------------------------------
--                              Remove toggle button                              --
------------------------------------------------------------------------------------
selector.remove_toggle_button = function(player)
  minime.entered_function({player})

  player = minime.ascertain_player(player)
  if not player and player.valid then
    minime.arg_err(player, "player specification or character name")
  end

  local p_data = mod.player_data and mod.player_data[player.index]

  local buttons = mod_gui.get_button_flow(player)

  -- Remove toggle button
  local toggle = buttons and buttons.valid and buttons[toggle_button_name]
  if toggle and toggle.valid then
    toggle.destroy()
    minime.writeDebug("Destroyed old toggle button!")
  else
    minime.writeDebug("Player has no valid toggle button!")
  end

  -- Remove button flow if it contains no other elements, or an empty frame will be
  -- visible in the top-left corner of the screen!
  local function must_remove(element)
    return element and element.valid and table_size(element.children) == 0
  end

  --~ if minime.toggle_gui_with ~= "button" and
  --~ if buttons and buttons.valid and
      --~ p_data and p_data.settings and p_data.settings.toggle_gui_with ~= "button" and
      --~ table_size(buttons.children) == 0 then

  local have_button = p_data and p_data.settings and
                                  p_data.settings.toggle_gui_with == "button"
minime.show("have_button", have_button)
minime.show("must_remove(buttons)", must_remove(buttons))
  --~ if not minime.character_selector or
      --~ (not have_button and must_remove(buttons)) then
  if (not minime.character_selector or not have_button) and
      must_remove(buttons) then

    -- Button flow is an inner frame. We must remove the outer frame as well if it's
    -- empty after we have removed the inner frame.
    local parent = buttons.parent
minime.show("parent frame", parent)

    -- Remove inner fame
    buttons.destroy()
    minime.writeDebug("Destroyed button flow!")

    -- Remove outer frame?
    --~ if parent and parent.valid and table_size(parent.children) == 0 then
    if must_remove(parent) then
      parent.destroy()
      minime.writeDebug("Destroyed parent of button flow!")
    end
  end

  minime.entered_function("leave")
  return
end


------------------------------------------------------------------------------------
--                       Initialize character-selector GUI!                       --
-- player: player index, name or entity                                          --
-- remove_character (optional): anything (Won't create button for last_character  --
-- if this is set!)                                                               --
------------------------------------------------------------------------------------
selector.init_gui = function(player, remove_character)
  minime.entered_function({player, remove_character})

  player = minime.ascertain_player(player)

  if not (player and player.valid) then
    minime.arg_err(player, "player specification")
  end
minime.show("player", player.name)


  if not minime.character_selector then
    minime.writeDebug("Character selector is disabled -- check if any players have a GUI.")
    --~ for p, player in pairs(game.players) do
      --~ selector.remove_gui(player)
    --~ end
    for p_index, p in pairs(game.players) do
      selector.remove_gui(p)
    end

    minime.entered_function({player, remove_character}, "leave", "Character selector is disabled!")
    return
  end

  local player_data = mod.player_data[player.index]
  if not player_data then
    minime.entered_function({player, remove_character}, "leave", "Player data not yet initialized!")
    return
  end


  ----------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------
  --                             DEFINE TOGGLE BUTTON                             --
  ----------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------

  -- Remove old toggle button
  selector.remove_toggle_button(player)

  -- Create toggle button, if necessary
  selector.create_toggle_button(player)

  ------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------
  --                                   CREATE GUI                                   --
  ------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------
  local gui = player.gui.screen

  ------------------------------------------------------------------------------------
  --            Construct the main frame that will contain the entire GUI           --
  ------------------------------------------------------------------------------------
  if gui[main_frame_name] and gui[main_frame_name].valid then
    gui[main_frame_name].destroy()
  end

  -- Create main frame
  gui.add({
    type = "frame",
    name = main_frame_name,
    direction = "vertical",
    visible = player_data.show_character_list,
  })
  minime.writeDebug("Created %s!", {minime.argprint(gui[main_frame_name])})

  gui = gui[main_frame_name]
  gui.auto_center = true

  -- Create header

  -- Flow for GUI title and closing button
  local header = minime_gui.make_flow({
    parent = gui,
    name = "header",
    caption = {"mod-name.minime"},
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


  ----------------------------------------------------------------------------------
  --                      Create the character preview frame!                     --
  -- Tables have no visible caption, so we need a container for the table holding --
  -- the entity-previews and buttons.                                             --
  ----------------------------------------------------------------------------------

  ----------------------------------------------------------------------------------
  -- Create wrapper frame
  local char_window = gui.add({
    type = "frame",
    name = character_frame_name,
    caption = {"minime-GUI.gui-name-charselector-caption"},
    direction = "vertical",
    visible = true,
    style = "inside_shallow_frame_with_padding",
  })
  char_window.style.use_header_filler = false
  minime.writeDebug("Created %s for character buttons.", {minime.argprint(char_window)})

  local element, flow, main_flow, button_flow, spacer_width

  ----------------------------------------------------------------------------------
  -- Create table: entity-previews above clickable buttons
  for p_index, p in ipairs(player_data.gui_character_pages) do
    element = make_table(char_window, p_index)
    minime.writeDebug("Created %s.", {minime.argprint(element)})
minime.show("Width of inner table", element.style.natural_width)
  end


  -----------------------------------------------------------------------------------
  --             DEFINE CONTAINER FOR REMOVAL BUTTONS/INFO/PAGE TURNER             --
  --    Only needed if character removal buttons or the page selector are shown!   --
  -----------------------------------------------------------------------------------
  -- As god and editor mode can only be entered if the player has admin rights, it
  -- doesn't make sense in multiplayer games to create the buttons for all players
  -- (but we'll always create them in singleplayer games, as the player is admin).
  local create_removal_buttons = player.admin and
                                  mod.map_settings.show_removal_buttons

  local create_page_selector = #player_data.gui_character_pages > 1

  -- Moved toggle button for "Available characters" GUI from button flow to selector
  -- GUI in 1.1.23
  local create_toggle_available = player_data.available_characters and
                                  table_size(player_data.available_characters) > 1

  if create_removal_buttons or create_page_selector or create_toggle_available then
    main_flow = gui.add({
      type = "flow",
      name = bottom_flow_name,
      direction = "horizontal",
      visible = true,
    })
    minime.writeDebug("Created %s.", {minime.argprint(main_flow)})
  end

  -----------------------------------------------------------------------------------
  --                  Create frame for character removal buttons!                  --
  -----------------------------------------------------------------------------------
  -- Create frame
  if create_removal_buttons then
    flow = minime_gui.make_flow({
      parent = main_flow,
      name = removal_flow_name,
      caption = {"minime-GUI.gui-name-charremoval-caption"},
    })
    minime.writeDebug("Created %s", {minime.argprint(flow)})

    -- Add flow containing buttons for character removal (editor/god mode)
    button_flow = flow.add({
      type = "flow",
      name = removal_buttons_flow_name,
      direction = "horizontal",
      visible = true,
    })
    minime.writeDebug("Created %s", {minime.argprint(button_flow)})

    -- Create buttons
    for b, button in pairs({minime.godmode_button_name, minime.editor_button_name}) do
      element = minime.character_button_prefix .. button
      button_flow.add({
        type = "button",
        name = element,
        enabled = true,
        style = "minime_nocharacter_button_on",
      })
      button_flow[element].caption = {
        string.format("minime-GUI.%s-mode-button-caption",
                      button == minime.godmode_button_name and "god" or "editor")
      }
      minime.writeDebug("Added %s.", {minime.argprint(button_flow[element])})
    end

    -- Add spacer
    if create_page_selector or create_toggle_available then
      local e_name  = removal_flow_name.."-"..spacer_name
      spacer_width = 25

      element = minime_gui.make_spacer(main_flow, e_name, spacer_width)
      minime.writeDebug("Added %s.", {minime.argprint(element)})
    end
  end

  -----------------------------------------------------------------------------------
  --                  Create flow for "Available characters" toggle button!                  --
  -----------------------------------------------------------------------------------
  if create_toggle_available then
    flow = minime_gui.make_flow({
      parent = main_flow,
      name = toggle_available_flow_name,
      --~ caption = {"minime-GUI.gui-name-charremoval-caption"},
      caption = {"minime-GUI.gui-name-available-toggle-caption"},
      --~ caption = "",
    })
    minime.writeDebug("Created %s", {minime.argprint(flow)})

    -- Add toggle button for "Available characters GUI?
    local available = table_size(player_data.available_characters) or 0
    local hidden = player_data.hidden_characters or 0

    element = flow.add({
      type = "sprite-button",
      name = toggle_button_available_name,
      caption = {"minime-GUI.toggle-available-list-button-caption",
                  available - hidden, available},
      tooltip = {"minime-GUI.toggle-available-list-button-tooltip",
                  {"minime-GUI.toggle-char-selector-button-caption"}},
      enabled = true,
      ignored_by_interaction = false,
      visible = true,
      style = "minime_toggle_button_in_gui"
    })
    minime.writeDebug("Added %s.", {minime.argprint(element)})

    -- Add spacer
    if create_page_selector then
      local e_name = toggle_button_available_name.."-"..spacer_name
      spacer_width = 15
      element = minime_gui.make_spacer(main_flow, e_name, spacer_width)
      minime.writeDebug("Added %s.", {minime.argprint(element)})
    end
  end

  -----------------------------------------------------------------------------------
  --                        Create flow for character info!                       --
  -----------------------------------------------------------------------------------
  if create_page_selector then
    -- Create flow
    flow = minime_gui.make_flow({
      parent = main_flow,
      name = info_flow_name,
      caption = {"minime-GUI.gui-name-infoframe-caption"},
    })
    minime.writeDebug("Created %s", {minime.argprint(flow)})

    -- Add text (name of the character )
    element = flow.add({
      type = "label",
      name = current_char_name,
      direction = "horizontal",
      visible = true,
    })
    minime.writeDebug("Created %s", {minime.argprint(element)})

    local e_name  = current_char_name.."-"..spacer_name
    spacer_width = 15

    element = minime_gui.make_spacer(main_flow, e_name, spacer_width)
    minime.writeDebug("Added %s.", {minime.argprint(element)})
  end


  -----------------------------------------------------------------------------------
  --                         Create flow for page selector!                        --
  -----------------------------------------------------------------------------------
  -- Create container
  if create_page_selector then
    local hidden = player_data.hidden_characters

    flow = minime_gui.make_flow({
      parent = main_flow,
      name = character_pages_flow_name,
      caption = {"minime-GUI.gui-name-pageselector-caption"},
    })
    minime.writeDebug("Created %s", {minime.argprint(flow)})

    -- Create flow for the elements
    button_flow = flow.add({
      type = "flow",
      name = character_page_selector_flow_name,
      direction = "horizontal",
      visible = true,
    })
    minime.writeDebug("Created %s", {minime.argprint(button_flow)})

    -- Create "Back" button
    element = button_flow.add({
      type = "sprite-button",
      name = prev_button_name,
      sprite = "utility/left_arrow",
      tooltip = {"minime-GUI.preview-page-previous-tooltip"},
      enabled = true,
      ignored_by_interaction = false,
      mouse_button_filter = {"left"},
      style = "minime_arrow_button_on",
    })
    minime.writeDebug("Created %s", {minime.argprint(element)})

    -- Create drop-down list
    element = button_flow.add({
      type = "drop-down",
      name = dropdown_list_name,
      tooltip = {"minime-GUI.preview-page-dropdown-tooltip"},
      enabled = true,
      ignored_by_interaction = false,
      mouse_button_filter = {"left"},
    })
    minime.writeDebug("Created %s", {minime.argprint(element)})

    -- Add items to drop-down list
    local first, last
    local total = table_size(player_data.available_characters) - (hidden or 0)

    for page, p in pairs(player_data.gui_character_pages) do
      -- Get indices of first and last character on this page
      first = (page - 1) * minime_gui.characters_per_page + 1
      last = page * minime_gui.characters_per_page

      -- Adjust the last number in case there are empty slots on last page!
      last = (last > total) and total or last

      element.add_item({
        "minime-GUI.gui-name-gui-page-characters",
        first,
        last,
        total
      }, page)
      minime.writeDebug("Added item for page %s to %s.",
                        {page, minime.argprint(element)})
    end
    element.selected_index = player_data.character_gui_page

    -- Create "Next" button
    element = button_flow.add({
      type = "sprite-button",
      name = next_button_name,
      sprite = "utility/right_arrow",
      tooltip = {"minime-GUI.preview-page-next-tooltip"},
      enabled = true,
      ignored_by_interaction = false,
      mouse_button_filter = {"left"},
      style = "minime_arrow_button_on",
    })
    minime.writeDebug("Created %s", {minime.argprint(element)})
  end


  -----------------------------------------------------------------------------------
  -- When the mod providing the player's last character has been removed from the
  -- game, we are effectively in god mode, but the flag isn't set.
  if remove_character then
    player_data.god_mode = true
  end

  -----------------------------------------------------------------------------------
  -- Update GUI
  minime.writeDebug("Updating GUI of %s!", {minime.argprint(player)})
  selector.gui_update(player)

  if create_page_selector then
    selector.update_page_selector_buttons({
      player_index = player.index,
      element = button_flow[dropdown_list_name]
    })
  end

  minime.entered_function("leave")
end


--~ ------------------------------------------------------------------------------------
--~ --               Reinitialize GUI when runtime settings are changed!              --
--~ ------------------------------------------------------------------------------------
--~ selector.init_guis = function()
  --~ minime.entered_function()

  --~ for p, player in pairs(game.players) do
    --~ minime_gui.init_available_character_gui(player)
    --~ selector.init_gui(player)
  --~ end

  --~ minime.entered_function("leave")
--~ end


------------------------------------------------------------------------------------
--                                    HIDE GUI!                                   --
------------------------------------------------------------------------------------
selector.hide_gui = function(player)
  minime.entered_function({player})

  -- This function can be called with index/name/entity of a real player, or with
  -- event data (player_index).
  player = minime.ascertain_player(player)

  if player and player.valid then
    minime.writeDebug("Trying to disable GUI of player %s", player.name)

    -- Disable toggle button
    do
      local gui_buttons = mod_gui.get_button_flow(player)
      local button = gui_buttons and gui_buttons[toggle_button_name]
      if button and button.valid then
        button.enabled = false
        button.tooltip = {"minime-GUI.toggle-char-selector-button-tooltip-hidden"}
        minime.writeDebug("Disabled GUI toggle button of player %s!",
                          {player.name or "nil"})
      end
    end

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
selector.unhide_gui = function(player)
  minime.entered_function({player})

  -- This function can be called with index/name/entity of a real player, or with
  -- event data (player_index).
  player = minime.ascertain_player(player)

  if player and player.valid then
    minime.writeDebug("Trying to enable GUI of player %s", player.name)


    -- Enable toggle button
    do
      local gui_buttons = mod_gui.get_button_flow(player)
      local button = gui_buttons and gui_buttons[toggle_button_name]
      if button and button.valid then
        button.enabled = true
        button.tooltip = {"minime-GUI.toggle-char-selector-button-tooltip"}
        minime.writeDebug("Enabled GUI toggle button of player %s!",
                          {player.name or "nil"})
      end
    end

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
--                                   REMOVE GUI!                                  --
------------------------------------------------------------------------------------
selector.remove_gui = function(player)
  minime.entered_function({player})

  -- This function can be called with index/name/entity of a real player, or with
  -- event data (player_index).
  player = minime.ascertain_player(player) or
          (type(player) == "table" and player.player_index and
                                        game.get_player(player.player_index))

  if player and player.valid then
    minime.writeDebug("Trying to remove GUI of player %s", player.name)

    -- Remove toggle button
    --~ local gui_buttons = mod_gui.get_button_flow(player)
    --~ if gui_buttons and gui_buttons[toggle_button_name] then
      --~ gui_buttons[toggle_button_name].destroy()
      --~ minime.writeDebug("Removed GUI toggle button of player %s!", {player.name or "nil"})
    --~ end
    selector.remove_toggle_button(player)

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
--                                   TOGGLE GUI!                                  --
------------------------------------------------------------------------------------
selector.gui_toggle = function(player)
  minime.entered_function({player})

  player = minime.ascertain_player(player)
  if not (player and player.valid) then
    minime.arg_err(player, "player specification")
  end

  -- Change visibility of list
  local gui = player.gui.screen and player.gui.screen[main_frame_name]
  gui.visible = not gui.visible

  -- If GUI is visible, it should be in the foreground
  if gui.visible then
    gui.bring_to_front()
    minime.writeDebug("%s is now on top!", {minime.argprint(gui)})
  end
minime.show("player", player)
minime.show("mod", mod)
  -- Copy that setting to mod.player_data
  local p_data = mod.player_data[player.index]
  p_data.show_character_list = gui.visible
minime.show("p_data.show_character_list", p_data.show_character_list)

  -- Preview entities should only be active when the GUI is visible and when they
  -- are on the page that is currently displayed.
  local entity, page, active
  local player_page = p_data.character_gui_page or 1
  local page_lookup = p_data.gui_character_pages_lookup

  for c_name, c_data in pairs(mod.minime_characters) do
    entity = c_data.preview and c_data.preview.entities and
                                c_data.preview.entities[player.index]
    entity = (entity and entity.valid) and entity or nil

    -- Proceed if the GUI has been turned on and we have a valid preview entity
    if gui.visible and entity then
      page = page_lookup[c_name]
      active = (player_page == page)
      minime.writeDebug("Player's page: %s\tCharacter page: %s",
                        {player_page, page or "nil"})

    -- All entities will be turned off if the GUI is invisible!
    else
      active = false
    end

    if entity then
      entity.active = active
      minime.writeDebug("Turned preview %s %s.",
                        {minime.argprint(entity), active and "on" or "off"})
-- TODO: Destroy camera for inactive previews!
    end
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                                   UPDATE GUI!                                  --
------------------------------------------------------------------------------------
selector.gui_update = function(player, page)
  minime.entered_function({player, page})
minime.show("type(page)", type(page))

  if not minime.character_selector then
    minime.entered_function({}, "leave", "Character selector is disabled!")
    return
  end

  player = minime.ascertain_player(player)
  if not (player and player.valid) then
    minime.arg_err(player, "player specification")
  end

  --~ page = tonumber(page)
  minime.assert(page, {"number", "nil"}, "page number or nil")

  if not (mod.player_data and mod.player_data[player.index]) then
    minime_player.init_player(player)
  end

  if not (player.gui.screen and player.gui.screen[main_frame_name]) then
    minime_gui.init_guis(player)
  end

  local p_data = mod.player_data and mod.player_data[player.index]
  local gui = player.gui.screen and player.gui.screen[main_frame_name]

  --~ local gui_page = p_data and p_data.character_gui_page and
                              --~ character_page_prefix..p_data.character_gui_page
  local gui_page = page and character_page_prefix..page
  if not gui_page then
    gui_page = p_data.character_gui_page and
                character_page_prefix..p_data.character_gui_page
  end
minime.show("gui_page", gui_page)
minime.show("type(gui_page)", type(gui_page))
  --~ if not (global.player_data and global.player_data[player.index]) then
    --~ minime_player.init_player(player)
  --~ end

  --~ if not (player.gui.screen and player.gui.screen[main_frame_name]) then
    -- minime_gui.init_gui(player)
    --~ minime_gui.init_guis(player)
  --~ end

  if p_data and gui then
    -- Character selector
if gui[character_frame_name] then
  minime.writeDebugNewBlock("Checking gui[\"%s\"] for tabs!", {character_frame_name})
  for k, v in pairs(gui[character_frame_name].children or minime.EMPTY_TAB) do
    minime.show(k, v)
  end
end
    --~ local tab_name = names.character_page_prefix..gui_page
    --~ if gui[character_frame_name] and gui[character_frame_name][tab_name] then
      --~ minime.writeDebug("Updating character buttons!")
      --~ update_character_buttons(p_data, gui[character_frame_name][tab_name])
    --~ end
    if gui[character_frame_name] and gui[character_frame_name][gui_page] then
      minime.writeDebug("Updating character buttons!")
      update_character_buttons(p_data, gui[character_frame_name][gui_page])
    end

    -- Container at bottom of GUI
    if gui[bottom_flow_name] then
minime.show("Have bottom flow", gui[bottom_flow_name])
      -- God/editor mode
      if gui[bottom_flow_name][removal_flow_name] then
        minime.writeDebug("Updating removal buttons!")
        update_removal_buttons(p_data, gui[bottom_flow_name][removal_flow_name][removal_buttons_flow_name])
      end

      -- Character info
      if gui[bottom_flow_name][info_flow_name] then
        minime.writeDebug("Updating character info!")
        update_character_info(player)
      end
    end

  --~ -- Errors
  --~ elseif not p_data then
    --~ minime.arg_err(p_data, "player data", player.index)
  --~ else
    --~ minime.arg_err(gui, "GUI frame")
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                              GUI-ACTION DETECTED!                              --
------------------------------------------------------------------------------------
--~ selector.on_gui_click = function(event)
  --~ minime.entered_function({event})

  --~ local button = event.element.name
  --~ if not minime.prefixed(button, minime.character_selector_prefix) then
    --~ minime.entered_function({}, "leave", "Nothing to do for %s \""..
                                          --~ minime.argprint(button).."\"!")
    --~ return
  --~ end

  --~ -- Return the GUI if one of its elements has been clicked (will be nil if clicked
  --~ -- element was the toggle button)
  --~ local ret =

  --~ local player = minime.ascertain_player(event.player_index)
  -- local p_data = player and global.player_data and global.player_data[player.index]

  --~ -- Respond to click on element for character selection/removal (button or
  --~ -- character preview)
  --~ local function character_button_click(clicked_button)
    --~ minime.entered_function({clicked_button})

    --~ minime_gui.select_character(player, clicked_button)
    --~ minime_character.switch_characters(player)

    --~ minime.entered_function("leave")
  --~ end


  --~ ------------------------------------------------------------------------------------
  --~ -- Toggle button for character selector was clicked
--~ minime.writeDebugNewBlock("What did the player do?")
  --~ if button == toggle_button_name then
    --~ minime.writeDebug("%s toggled the selection list.", {player.name})
    --~ selector.gui_toggle(player)



  --~ -- Toggle button for "Available characters" GUI was clicked (Added in 1.1.23)
  --~ elseif button == toggle_button_available_name then
    --~ minime.writeDebug("%s toggled the list of available characters.", {player.name})
    --~ minime_gui.available.gui_toggle(player)

  --~ -- Close button was clicked
  --~ elseif button == main_frame_close_button_name then
    --~ minime.writeDebug("%s closed the selection list.", {player.name})
    --~ selector.gui_toggle(player)

  --~ -- Player clicked a character selection or removal (god/editor mode) button.
  --~ elseif minime.prefixed(button, minime.character_button_prefix) then
    --~ minime.writeDebug("%s clicked button \"%s\".", {player.name, button})
    --~ character_button_click(button)

  --~ -- Player clicked on a character preview. Let's pretend it was the button!
  --~ elseif minime.prefixed(button, minime.character_preview_prefix) then
    --~ minime.writeDebug("%s clicked preview \"%s\".", {player.name, button})
    --~ character_button_click(button:gsub(minime.character_preview_prefix,
                                        --~ minime.character_button_prefix))

  --~ -- Player clicked on a character-page selector button!
  --~ elseif minime.prefixed(button, minime.character_page_button_prefix) and
          --~ button ~= dropdown_list_name then
    --~ minime.writeDebug("%s clicked character-page selector button \"%s\".", {player.name, button})
    --~ selector.update_page_selector_buttons(event)

  --~ -- Something else from our GUI has been clicked
  --~ else
    --~ minime.writeDebug("Nothing to do for element \"%s\"!", {button})
  --~ end

  --~ minime.entered_function("leave")
--~ end
selector.on_gui_click = function(event)
  minime.entered_function({event})

  local element = event.element.name
  --~ if not minime.prefixed(element, minime.character_selector_prefix) then
    --~ minime.entered_function({}, "leave", "Nothing to do for %s \""..
                                          --~ minime.argprint(element).."\"!")
    --~ return
  --~ end
  if not minime.prefixed(element, minime.character_selector_prefix) or
      element == character_page_selector_flow_name then
    minime.entered_function({}, "leave", "Nothing to do for "..
                                          minime.argprint(element).."!")
    return
  end

  local element_string = minime.argprint(element)


  local player = minime.ascertain_player(event.player_index)
  --~ local p_data = player and global.player_data and global.player_data[player.index]

  -- Respond to click on element for character selection/removal (button or
  -- character preview)
  local function character_button_click(clicked)
    minime.entered_function({clicked})

    minime_gui.select_character(player, clicked)
    minime_character.switch_characters(player)

    minime.entered_function("leave")
  end


  ------------------------------------------------------------------------------------
  -- Toggle button for character selector was clicked
minime.writeDebugNewBlock("What did the player do?")
  if element == toggle_button_name then
    minime.writeDebug("%s toggled the selection list.", {player.name})
    selector.gui_toggle(player)


  -- Toggle button for "Available characters" GUI was clicked (Added in 1.1.23)
  elseif element == toggle_button_available_name then
    minime.writeDebug("%s toggled the list of available characters.", {player.name})
    minime_gui.available.gui_toggle(player)

  -- Close button was clicked
  elseif element == main_frame_close_button_name then
    minime.writeDebug("%s closed the selection list.", {player.name})
    selector.gui_toggle(player)

  -- Player clicked a character selection or removal (god/editor mode) button.
  elseif minime.prefixed(element, minime.character_button_prefix) then
    minime.writeDebug("%s clicked %s.", {player.name, element_string})
    character_button_click(element)

  -- Player clicked on a character preview. Let's pretend it was the button!
  elseif minime.prefixed(element, minime.character_preview_prefix) then
    minime.writeDebug("%s clicked preview %s.", {player.name, element_string})
    character_button_click(element:gsub(minime.character_preview_prefix,
                                        minime.character_button_prefix))

  -- Player clicked on a character-page selector button!
  elseif minime.prefixed(element, minime.character_page_button_prefix) and
          element ~= dropdown_list_name then
    minime.writeDebug("%s clicked character-page selector %s.",
                      {player.name, element_string})
    selector.update_page_selector_buttons(event)

  -- Something else from our GUI has been clicked
  else
    minime.writeDebug("Nothing to do for %s!", {element_string})
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                          GUI-ACTION (DROP-DOWN LIST)!                          --
------------------------------------------------------------------------------------
selector.on_gui_selection_state_changed = function(event)
  minime.entered_function({event})

  local element = event.element



  if not minime.prefixed(element.name, minime.character_page_button_prefix) then
    minime.entered_function({},"leave", "Nothing to do!")
    return
  end

  local player = minime.ascertain_player(event.player_index)
  local player_data = mod.player_data[player.index]

  local old_page, new_page

  local buttons = minime_gui_names.selector.buttons
  local main_frame = player.gui.screen[main_frame_name]

  -- Dropdown list was used to change the page
  if element.name == dropdown_list_name then
    minime.writeDebug("Value of %s has been changed. New page: %s!",
                      {minime.argprint(element), element.selected_index})
    local previews = main_frame[character_frame_name]

    old_page = player_data.character_gui_page or
                selector.get_character_gui_page(player)
    new_page = element.selected_index

    -- Deactivate preview entities from the old page, and hide the old page
    selector.toggle_character_page_entities(player, old_page, false)
    previews[character_page_prefix..old_page].visible = false
    minime.writeDebug("%s is now hidden!", {minime.argprint(previews[character_page_prefix..old_page])})

    -- Activate preview entities from the new page, and unhide it
    selector.toggle_character_page_entities(player, new_page, true)
    previews[character_page_prefix..new_page].visible = true
    minime.writeDebug("%s is now visible!", {minime.argprint(previews[character_page_prefix..new_page])})

    -- Update the buttons for previous/next character preview page!
    selector.update_page_selector_buttons(event)

    -- Don't forget to store new_page in the global table!
    player_data.character_gui_page = new_page


  -- A button was used to turn the page, so we can calculate the new one.
  else
    local elements = main_frame[bottom_flow_name][character_pages_flow_name][character_page_selector_flow_name]
    local last_page = table_size(player_data.gui_character_pages)

    old_page = elements[dropdown_list_name].selected_index
    new_page = (element.name == buttons.previous and old_page - 1) or
                (element.name == buttons.next and old_page + 1) or
                old_page
-- Trying to fix "attempt to compare boolean with number" bug
-- (https://mods.factorio.com/mod/minime/discussion/64ef0572ea67fadfc867f2df)
minime.writeDebug("element.name: %s\nbuttons.previous: %s\nbuttons.next: %s",
                  {element.name, buttons.previous, buttons.next})
minime.show("element.name == buttons.previous", element.name == buttons.previous)
minime.show("element.name == buttons.next", element.name == buttons.next)

    if new_page < 1 then
      new_page = 1
    elseif new_page > last_page then
      new_page = last_page
    end
minime.writeDebug("minime: dropdown list index\n"..
                  "new_page: %s\tlast_page: %s\nnew_page is in allowd range: %s",
                  {new_page, last_page, (new_page > 0 and new_page <= last_page)})
    elements[dropdown_list_name].selected_index = new_page
    minime.writeDebug("Updated page via buttons!")

  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
minime.entered_file("leave")
return selector
