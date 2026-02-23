minime.entered_file()

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--                              Names of GUI elements                             --
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

local names = {}
names.available = {}
names.selector = {}

local available, selector = names.available, names.selector

local avail_prefix = "minime_available_chars_"
local select_prefix = "minime_char_selector_"
------------------------------------------------------------------------------------
--                             Character selector GUI                             --
------------------------------------------------------------------------------------
selector.buttons = {
  -- Toggle button for the GUI
  toggle_gui                            = select_prefix.."toggle_button",
  -- Toggle button for "Available characters" GUI (Added in 1.1.23)
  toggle_available_gui                  = select_prefix.."toggle_button_available",
  -- Close button for main frame
  main_frame_close                      = select_prefix.."close_window_button",
  -- Buttons for turning to the next/previous character preview page
  previous                              = minime.character_page_button_prefix.."back",
  next                                  = minime.character_page_button_prefix.."next",
}

selector.frames = {
  -- The master flow that contains the entire GUI
  main                                  = select_prefix.."main_frame",
  -- Frame for character previews and buttons
  characters                            = select_prefix.."character_frame",
}

selector.flows = {
  -- Flow containing removal flow/info flow/page selector flow
  bottom                                = select_prefix.."container_bottom_flow",
  -- Flow (vertical) containing title and buttons flow for removal buttons
  removal                               = select_prefix.."container_removal_flow",
  -- Flow (horizontal) for removal buttons
  removal_buttons                       = select_prefix.."removal_buttons_flow",
  -- Flow (horizontal) for toggle button of "Available Characters" GUI
  toggle_available                      = select_prefix.."toggle_available_flow",
  -- Flow for information about the current character
  info                                  = select_prefix.."info_flow",
  -- Flow (vertical) containing title and GUI elements for character-page selector
  character_pages                       = select_prefix.."container_page_selector_flow",
  -- Flow (horizontal) containing the GUI elements for character-page selector
  character_page_selector               = select_prefix.."page_selector_elements_flow",
}

selector.labels = {
  -- Label showing the name of the current character
  current_char                          = select_prefix.."current_character_name_label"
}

-- Numbered tables that function as pages of character previews and buttons
selector.character_page_prefix          = "character_preview_page_"

-- Dropdown list for choosing a character preview page directly
selector.dropdown_list                  = minime.character_page_button_prefix.."dropdown"

-- Add horizontal space of variable width
selector.spacer                         = "spacer"


------------------------------------------------------------------------------------
--                        GUI for available-character list                        --
------------------------------------------------------------------------------------
available.buttons = {
  -- Close button for main frame
  main_frame_close                      = avail_prefix.."close_window_button",

  -- Button to close GUI/apply changes + close GUI
  apply                                 = avail_prefix.."apply_changes_button",

  -- Buttons for bulk changes
  enable_all                            = avail_prefix.."enable_all_button",
  disable_all                           = avail_prefix.."disable_all_button",
  toggle_all                            = avail_prefix.."toggle_all_button",
}

available.frames = {
  -- The master frame that contains the entire GUI
  main                                  = avail_prefix.."main_frame",
}

available.flows = {
  -- Horizontal flow containing character table and button flow
  main                                  = avail_prefix.."main_flow",

  -- Flow for buttons (bulk operations + apply)
  buttons                               = avail_prefix.."buttons_flow",
}

available.tables = {
  -- Table containing rows with character icon + character name + checkbox
  character_list                        = avail_prefix.."table",
}

available.scrollpane = {
  -- Table containing rows with character icon + character name + checkbox
  character_list                        = avail_prefix.."scrollpane",
}

available.prefixes = {
  -- Row index prefix
  row_number                            = avail_prefix.."row_",
  -- Sprite prefix
  sprites                               = avail_prefix.."sprite_",
  -- Label prefix
  labels                                = avail_prefix.."label_",
  -- Checkbox prefix
  checkboxes                            = avail_prefix.."checkbox_",
}

minime.show("Names of GUI elements", names)

------------------------------------------------------------------------------------
minime.entered_file("leave")
return names
