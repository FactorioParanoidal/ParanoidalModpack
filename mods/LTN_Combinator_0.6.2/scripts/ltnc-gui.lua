--[[
--]]
require "util"
local config = require "config"

local CHECK_REQUESTER = 1
local CHECK_PROVIDER  = 2
local CHECK_DEPOT     = 3
local RADIO_ON        = 4
local RADIO_OFF       = 5

local _prefix = "ltnc_"


global.gui = global.gui or {}

ltnc_gui = {
}

--[[ ----------------------------------------------------------------------------------
        GUI HELPER
--]] 
local function exists(player_index)
  if not global.gui[player_index] or not global.gui[player_index].main_frame.valid then
    global.gui[player_index] = ltnc_gui.build(game.players[player_index].gui.center)
    if game.active_mods["Teleporters"] ~= nil then
      print("Player #" .. player_index .." is not initialized or destroyed. Please report this message to the author.")
    end
  end
  return true
end

-- TODO: redo tointeger
local function strip_input(text)
    local neg = (string.sub(text, 1, 1) == "-")
    text = string.gsub(text, '[^%d]', '')
  return (neg and "-" or "") .. text
end

local function tointeger(value, min, max)
  -- boolean check
  if type(value) == "boolean" then
    return value == true and 1 or 0
  end

-- no longer needed due to switch to numeric input fields
--  -- strip any non [0-9] characters
  value = (value == "" or value == nil) and 0 or value 
  if tonumber(value) == nil then
    value = string.gsub(value, "[^%d]", "")
  end
  
  value = value ~= "" and math.floor(value) or 0
  
  value = math.min(value, max)
  value = math.max(value, min)
  
  return value
end


--[[ ----------------------------------------------------------------------------------
        MOD INITIALIZE 
--]]
ltnc_gui.mod_init = function()
  -- build uis
  for player_index, player in pairs(game.players) do
    ltnc_gui.on_player_joined({player_index = player_index})
  end
end

ltnc_gui.mod_configuration_changed = function()
  --dlog("LTNC: Mod updated. Rebuilding UIs")
  for player_index, player in pairs(game.players) do
    if global.gui[player_index] ~= nil and global.gui[player_index].main_frame ~= nil and global.gui[player_index].main_frame.valid == true then
      global.gui[player_index].main_frame.destroy()
    end
    global.gui[player_index] = nil
    ltnc_gui.on_player_joined({player_index = player_index})
  end
end

ltnc_gui.mod_settings_changed = function()
end

ltnc_gui.on_player_joined = function(event)
  local player_index = event.player_index
  if global.gui[player_index] ~= nil then
    log("ltnc::on_player_joined: Player #" .. player_index .. " already exists. Please report this message to the author.")
    return
  end
  
  -- new player create gui
  global.gui[player_index] = ltnc_gui.build(game.players[player_index].gui.center)
end

ltnc_gui.event_map = function(events)
  --[[ EVENT MAPS]]--
  events.map_clicked["ltnc_checkRequester"]   = ltnc_gui.ltn_toggle_requester
  events.map_clicked["ltnc_checkProvider"]    = ltnc_gui.ltn_toggle_provider
  events.map_clicked["ltnc_checkDepot"]       = ltnc_gui.ltn_toggle_depot
  events.map_clicked["ltnc_networkid_button"] = ltnc_gui.network_toggle
  events.map_clicked["ltnc_radioOn"]          = ltnc_gui.misc_switch_on
  events.map_clicked["ltnc_radioOff"]         = ltnc_gui.misc_switch_off

  events.map_clicked["ltnc_network_button_all"]    = ltnc_gui.network_select_all
  events.map_clicked["ltnc_network_button_none"]    = ltnc_gui.network_select_none
  events.map_clicked["ltnc_network_button_config"] = ltnc_network.open
    
  events.map_slider["ltnc_misc-slider_element"]      = ltnc_gui.misc_slider_changed
  events.map_text_changed["ltnc_misc-text_element"]  = ltnc_gui.misc_text_changed
  
  -- ltn signals
  for name, entry in pairs(config.ltn_signals) do
    local key = _prefix .. name .. "_element"
    if entry.bounds.min == 0 and entry.bounds.max == 1 then
      events.map_checked[key]  = ltnc_gui.ltn_checkbox_changed
    else
      events.map_text_changed[key]  = ltnc_gui.ltn_text_changed
    end
  end

  -- additional elements
  local key
  for i=1, config.ltnc_misc_slot_count do
    key = string.format(_prefix .. "misc-signal-button%d", i)
    events.map_elem_changed[key] = ltnc_gui.misc_choose_element
    
    key = string.format(_prefix .. "misc-signal-sprite%d", i)
    events.map_clicked[key] = ltnc_gui.misc_signal_clicked
  end
  
  -- network id buttons
  for i=1, 32 do
    key = string.format("ltnc_network_button%d", i)
    events.map_clicked[key] = ltnc_gui.network_button_clicked
  end
end

--[[ ----------------------------------------------------------------------------------
        LOGIC & HELPER 
--]]
ltnc_gui.open = function(player_index, combinator, registered)
  if not exists(player_index) then return nil end
    
  local window = global.gui[player_index]
  window.combinator = combinator
  window.main_frame.visible = true
  
  -- read and apply ltn signals present in combinator
  for name, signal in pairs(config.ltn_signals) do
    local value = window.combinator:get(name)
    
    if window.ltn.entries[name] ~= nil then
      if window.ltn.entries[name].element.type == "checkbox" then
        window.ltn.entries[name].element.state = value > 0 or false
      else
        window.ltn.entries[name].element.text = value
      end
    end
  end
  
  -- update visibility flags
  local changes = 0
  window.visibility = util.table.deepcopy(global.default_visibility)
  window.visibility, changes = window.combinator:mark_visibility(window.visibility)
  window.visibility["ltn-depot"] = false
  
  
  -- fix: prevent window from jumping around
  if global.default_entry_count > 0 then
    window.ltn.table.style.minimal_height = (global.default_entry_count + changes) * 38
  end
    
  ltnc_gui.ltn_update_visibility(window)

  -- update on/off switch
  local enabled = window.combinator:is_enabled()
  window.ltn.buttons[RADIO_ON].state = enabled
  window.ltn.buttons[RADIO_OFF].state = not enabled
  
  ltnc_gui.misc_update_switch_onoff(window)
  
  -- update additional signal slots
  window.selected_elem = nil
  ltnc_gui.misc_update_inputs(window, nil)
  
  for slot = 1, config.ltnc_misc_slot_count do
    local signal = window.combinator:get_slot(slot)

    ltnc_gui.misc_update_signals(window.misc_signals[slot].button, window.misc_signals[slot].sprite, signal)
    -- reset style for this element
    window.misc_signals[slot].sprite.style = "ltnc_misc_slot_empty"
  end
  
  ltnc_gui.build_network_ui(player_index, window.network)
  window.registered = registered
  window.opened = window.main_frame
  window.main_frame.style.left_margin = 0

  return window.main_frame
end

ltnc_gui.close = function(player_index)
  if not exists(player_index) then return end
  
  local window = global.gui[player_index]

  if window.opened ~= nil and window.opened.name == "ltnc-network-config" then
    if global.network_ui[player_index] ~= nil then
      global.network_ui[player_index].destroy()
    end
  
    global.network_ui[player_index] = nil
  end
  
  window.opened = nil
  window.combinator = nil
  window.main_frame.visible = false
end

ltnc_gui.is_visible = function(player_index)
  if not exists(player_index) then return end
  return global.gui[player_index].main_frame.visible
end

ltnc_gui.is_registered = function(player_index)
  if not exists(player_index) then return end
  return global.gui[player_index].main_frame.registered
end

--[[ ----------------------------------------------------------------------------------
      CORE LTN SIGNALS
--]]

-- ltn_apply_stop_type:
--  
ltnc_gui.ltn_apply_stop_type = function(event)
  local window     = global.gui[event.player_index]
  local visibility = ltnc_gui.ltn_update_visibility(window)
  
  ltnc_gui.ltn_apply_visible_signals(window, visibility)
end

-- ltn_toggle_requester
--
ltnc_gui.ltn_toggle_requester = function(event)
  local window    = global.gui[event.player_index]
  local stop_type = window.combinator:get_stop_type()
  
  -- stop is already set to requester
  if stop_type == config.LTN_STOP_REQUESTER then
    return
  end
  
  local new_stop_type = config.LTN_STOP_REQUESTER
  
  
  -- check for SHIFT modifier
  if event.shift == true then
    -- Activate Requester AND Provider
    if stop_type == config.LTN_STOP_PROVIDER then
      new_stop_type = bit32.bor(config.LTN_STOP_REQUESTER, config.LTN_STOP_PROVIDER)
      
    -- Deselect Requester
    -- 6 = bit32.band(REQUESTER, PROVIDER)
    elseif stop_type == 6 then
      new_stop_type = config.LTN_STOP_PROVIDER
    end
  end
  
  -- appply new stop type
  window.combinator:set_stop_type(new_stop_type)
  ltnc_gui.ltn_apply_stop_type(event)
end

-- ltn_toggle_provider:
--
ltnc_gui.ltn_toggle_provider = function(event)
  local window    = global.gui[event.player_index]
  local stop_type = window.combinator:get_stop_type()
  
  -- stop is already set to requester
  if stop_type == config.LTN_STOP_PROVIDER then
    return
  end
  
  local new_stop_type = config.LTN_STOP_PROVIDER
  
  -- check for SHIFT modifier
  if event.shift == true then
    -- Activate Requester AND Provider
    if stop_type == config.LTN_STOP_REQUESTER then
      new_stop_type = bit32.bor(config.LTN_STOP_REQUESTER, config.LTN_STOP_PROVIDER)
      
    -- Deselect provider
    -- 6 = bit32.band(REQUESTER, PROVIDER)
    elseif stop_type == 6 then
      new_stop_type = config.LTN_STOP_REQUESTER
    end
  end
  
  -- reset provider threshold if visible 
  if bit32.band(new_stop_type, config.LTN_STOP_PROVIDER) then
    local threshold = window.ltn.entries["ltn-provider-threshold"].element.text
    if threshold == tostring(config.high_threshold_count) then
      window.ltn.entries["ltn-provider-threshold"].element.text = config.ltn_signals["ltn-provider-threshold"].default
    end
  end
  
  -- appply new stop type
  window.combinator:set_stop_type(new_stop_type)
  ltnc_gui.ltn_apply_stop_type(event)
end

-- ltn_toggle_depot
--
ltnc_gui.ltn_toggle_depot = function(event)
  local window = global.gui[event.player_index]
  
  -- switch to depot
  window.combinator:set_stop_type(config.LTN_STOP_DEPOT)
  ltnc_gui.ltn_apply_stop_type(event)
end

-- ltn_apply_visible_signals
--
ltnc_gui.ltn_apply_visible_signals = function(window, visibility)
  for signal_name, entry in pairs(visibility) do
    if visibility[signal_name] ~= nil and visibility[signal_name] == true then
      local min   = config.ltn_signals[signal_name].bounds.min
      local max   = config.ltn_signals[signal_name].bounds.max
      local value = nil
      if window.ltn.entries[signal_name].element.type == "checkbox" then
        value = window.ltn.entries[signal_name].element.state
      else
        value = window.ltn.entries[signal_name].element.text
      end 
      
      window.combinator:set(signal_name, tointeger(value, min, max))
    end
  end
end


-- ltn_text_changed
--
ltnc_gui.ltn_text_changed = function(event)
  local element = event.element
  local signal_name = string.match(element.name, "_([a-zA-Z-]+)_")
  
  -- validate input
  local min = -2000000000
  local max = 2000000000
  if config.ltn_signals[signal_name] ~= nil then
    min = config.ltn_signals[signal_name].bounds.min
    max = config.ltn_signals[signal_name].bounds.max
  end
  
  local value = tointeger(strip_input(element.text), min, max)
  if value ~= tonumber(element.text) and element.text ~= "" and element.text ~= "-" then
    element.text = value
  end
  
  if value ~= nil then
    global.gui[event.player_index].combinator:set(signal_name, value)
    
    if signal_name == "ltn-network-id" then
      ltnc_gui.network_update_buttons(event, value)
    end
  end
end

-- ltn_checkbox_changed
--
ltnc_gui.ltn_checkbox_changed = function(event)
  local element = event.element
  local signal_name = string.match(element.name, "_([a-zA-Z-]+)_")
  
  local value = (element.state == true) and 1 or 0
  global.gui[event.player_index].combinator:set(signal_name, value)
end

-- ltn_update_visibility
--
ltnc_gui.ltn_update_visibility = function (window)
  -- grab current stop type
  local stop_type = window.combinator:get_stop_type()
  if stop_type == nil then
    stop_type = 0
  end
  
  -- reset to default values
  window.ltn.buttons[CHECK_REQUESTER].state = false
  window.ltn.buttons[CHECK_REQUESTER].style.font = "default"
  window.ltn.buttons[CHECK_REQUESTER].style.font_color = {1, 1, 1}
  window.ltn.buttons[CHECK_PROVIDER].state = false
  window.ltn.buttons[CHECK_PROVIDER].style.font = "default"
  window.ltn.buttons[CHECK_PROVIDER].style.font_color = {1, 1, 1}
  window.ltn.buttons[CHECK_DEPOT].state = false
  window.ltn.buttons[CHECK_DEPOT].style.font = "default"
  window.ltn.buttons[CHECK_DEPOT].style.font_color = {1, 1, 1}
  
  local visibility = util.table.deepcopy(window.visibility)
  
  -- Depot
  if stop_type == config.LTN_STOP_DEPOT then
    visibility["ltn-provider-threshold"] = false
    visibility["ltn-provider-stack-threshold"] = false
    visibility["ltn-provider-priority"] = false
    visibility["ltn-requester-threshold"] = false
    visibility["ltn-requester-stack-threshold"] = false
    visibility["ltn-requester-priority"] = false
    visibility["ltn-min-train-length"] = false
    visibility["ltn-max-train-length"] = false
    visibility["ltn-max-trains"] = false
    visibility["ltn-locked-slots"] = false
    visibility["ltn-disable-warnings"] = false
    
    window.ltn.buttons[CHECK_DEPOT].state = true
    window.ltn.buttons[CHECK_DEPOT].style.font = "default-bold"
    window.ltn.buttons[CHECK_DEPOT].style.font_color = {255, 230, 192}
  end
  
  -- adjust visibility of entries depending on stop type
  if stop_type == config.LTN_STOP_REQUESTER then
    visibility["ltn-provider-threshold"] = false
    visibility["ltn-provider-stack-threshold"] = false
    visibility["ltn-provider-priority"] = false
    visibility["ltn-locked-slots"] = false
  elseif stop_type == config.LTN_STOP_PROVIDER then
    visibility["ltn-requester-threshold"] = false
    visibility["ltn-requester-stack-threshold"] = false
    visibility["ltn-requester-priority"] = false
    visibility["ltn-disable-warnings"] = false
  elseif stop_type == config.LTN_STOP_NONE then
    visibility["ltn-network-id"] = false
    visibility["ltn-provider-threshold"] = false
    visibility["ltn-provider-stack-threshold"] = false
    visibility["ltn-provider-priority"] = false
    visibility["ltn-requester-threshold"] = false
    visibility["ltn-requester-stack-threshold"] = false
    visibility["ltn-requester-priority"] = false
    visibility["ltn-min-train-length"] = false
    visibility["ltn-max-train-length"] = false
    visibility["ltn-max-trains"] = false
    visibility["ltn-locked-slots"] = false
    visibility["ltn-disable-warnings"] = false
  end
  
  -- 
  if bit32.band(stop_type, config.LTN_STOP_REQUESTER) > 0 then
    window.ltn.buttons[CHECK_REQUESTER].state = true
    window.ltn.buttons[CHECK_REQUESTER].style.font = "default-bold"
    window.ltn.buttons[CHECK_REQUESTER].style.font_color = {255, 230, 192}
  end
  
  if bit32.band(stop_type, config.LTN_STOP_PROVIDER) > 0 then
    window.ltn.buttons[CHECK_PROVIDER].state = true
    window.ltn.buttons[CHECK_PROVIDER].style.font = "default-bold"
    window.ltn.buttons[CHECK_PROVIDER].style.font_color = {255, 230, 192}
  end
  
  -- finally apply visibility
  local visible = false 
  for virtual_signal, entry in pairs(window.ltn.entries) do
    visible = visibility[virtual_signal] or false
    entry.sprite.visible = visible
    entry.label.visible = visible
    entry.element.visible = visible
    entry.element.ignored_by_interaction = not visible
  end
  
  return visibility
end

--[[ ----------------------------------------------------------------------------------
      NETWORK ID SELECTOR
--]]
ltnc_gui.network_toggle = function(event)
  local window = global.gui[event.player_index]
  
  window.network.frame.visible = not window.network.frame.visible
  
  window.main_frame.style.left_margin = window.network.frame.visible and 253 or 0

  if event.element and event.element.type == "sprite-button" then
    event.element.style = window.network.frame.visible and "ltnc_network_network_button_pressed" or "ltnc_network_network_button"
  end
  
  if window.network.frame.visible then
    ltnc_gui.network_update_buttons(event)
  end
end

ltnc_gui.network_button_clicked = function(event)
  local id = tonumber(string.match(event.element.name,"%d+"))
  if id == nil or id < 1 or id > 32 then return end
  
  local window = global.gui[event.player_index]

  local encoded_id = window.combinator:get("ltn-network-id")
  local bit  = (bit32.band(encoded_id, 2^(id-1)) > 0)
    
  if bit == true then
    -- bit is set, unset
    encoded_id = bit32.bxor(encoded_id, 2^(id-1))
    
    event.element.style = "ltnc_network_sprite_button"
  else
    -- bit is unset, set
    encoded_id = bit32.bor(encoded_id, 2^(id-1))
    
    event.element.style = "ltnc_network_sprite_button_pressed"
  end
  
  -- if bit 32 is set, convert to a negative number
  if bit32.band(encoded_id, 2^31) > 0 then
    local new_id = -2^31
    for i = 1, 31 do  
      if bit32.band(encoded_id, 2^(i-1)) > 0 then
        new_id = new_id + 2^(i-1)
      end
    end
    
    encoded_id = new_id
  end
  
  -- apply 
  window.combinator:set("ltn-network-id", encoded_id)
  window.ltn.entries["ltn-network-id"].element.text = encoded_id
end

ltnc_gui.network_update_buttons = function(event)
  local window = global.gui[event.player_index]
  
  local encoded_id = window.combinator:get("ltn-network-id")
  for i=1, 32 do
    if window.network.buttons[i] then
      local bit  = (bit32.band(encoded_id, 2^(i-1)) > 0)
      local name = string.format("ltnc_network_button%d", i)
      
      if bit then
        window.network.buttons[i].style = "ltnc_network_sprite_button_pressed"
      else
        window.network.buttons[i].style = "ltnc_network_sprite_button"
      end
    end
  end
end

ltnc_gui.network_select_all = function(event)
  local window = global.gui[event.player_index]

  window.combinator:set("ltn-network-id", -1)
  window.ltn.entries["ltn-network-id"].element.text = -1
  
  ltnc_gui.network_update_buttons(event)
end

ltnc_gui.network_select_none = function(event)
  local window = global.gui[event.player_index]

  window.combinator:set("ltn-network-id", 0)
  window.ltn.entries["ltn-network-id"].element.text = 0
  
  ltnc_gui.network_update_buttons(event)
end

--[[ ----------------------------------------------------------------------------------
      BASE COMBINATOR VIEW
--]]

-- misc_switch_on
--
ltnc_gui.misc_switch_on = function(event)
  local window = global.gui[event.player_index]
  
  window.combinator:set_enabled(true)
  
  window.ltn.buttons[RADIO_ON].state = true
  window.ltn.buttons[RADIO_OFF].state = false
  ltnc_gui.misc_update_switch_onoff(window)
end

-- misc_switch_off
--
ltnc_gui.misc_switch_off = function(event)
  local window = global.gui[event.player_index]
  
  window.combinator:set_enabled(false)

  window.ltn.buttons[RADIO_ON].state = false
  window.ltn.buttons[RADIO_OFF].state = true
  ltnc_gui.misc_update_switch_onoff(window)
end

-- misc_update_switch_onoff
--
ltnc_gui.misc_update_switch_onoff = function(window)
  if window.ltn.buttons[RADIO_ON].state == true then
    window.ltn.buttons[RADIO_ON].style.font = "default-bold"
    window.ltn.buttons[RADIO_ON].style.font_color = {255, 230, 192}
    window.ltn.buttons[RADIO_OFF].style.font = "default"
    window.ltn.buttons[RADIO_OFF].style.font_color = {1, 1, 1}
  else
    window.ltn.buttons[RADIO_ON].style.font = "default"
    window.ltn.buttons[RADIO_ON].style.font_color = {1, 1, 1}
    window.ltn.buttons[RADIO_OFF].style.font = "default-bold"
    window.ltn.buttons[RADIO_OFF].style.font_color = {255, 230, 192}
  end
end
 
-- misc_choose_element
--
ltnc_gui.misc_choose_element = function(event)
  local slot = tonumber(string.match(event.element.name,"%d+"))
  if slot == nil or slot < 1 or slot > config.ltnc_misc_slot_count then return end

  local window = global.gui[event.player_index]
  
  if not event.element or not event.element.elem_value then return end
  
  local signal = {
    count = 1,
    signal = event.element.elem_value,
  }
  
  window.combinator:set_slot(slot, signal)
  ltnc_gui.misc_update_inputs(window, signal.count)
  ltnc_gui.misc_update_signals(window.misc_signals[slot].button, window.misc_signals[slot].sprite, signal)
  ltnc_gui.misc_update_selection(window, window.misc_signals[slot].sprite, signal.count)
  
  window.element_focus = true
end

-- misc_signal_clicked
--
ltnc_gui.misc_signal_clicked = function(event)
  local slot = tonumber(string.match(event.element.name,"%d+"))
  if slot == nil or slot < 1 or slot > config.ltnc_misc_slot_count then return end
   
  local window = global.gui[event.player_index]

  -- Sprite-Button: check for rightclick -> remove entry
  if event.button == defines.mouse_button_type.right and event.element.type == "sprite-button" then
    window.combinator:remove_slot(slot)
    ltnc_gui.misc_update_signals(window.misc_signals[slot].button, window.misc_signals[slot].sprite, nil)
    
    if window.selected_elem == event.element then
      ltnc_gui.misc_update_selection(window, nil, nil)
    end
    
    return
  end

  -- Sprite-Button: check for leftclick -> toggle selection
  if event.button == defines.mouse_button_type.left and event.element.type == "sprite-button" then
    local value = nil
    local new_element = nil
    
    if event.element ~= window.selected_elem then
      new_element = event.element
      value = window.combinator:get_slot(slot).count
    end
    
    -- update slider and textbox, value might be nil
    ltnc_gui.misc_update_selection(window, new_element, value)
    window.element_focus = true
    return 
  end
end

-- misc_update_signals
--
ltnc_gui.misc_update_signals = function(button, sprite, signal)
  if signal ~= nil and signal.signal ~= nil then
    sprite.visible = true
    button.visible = false
    
    button.elem_value = nil
    
    local type = signal.signal.type == "virtual" and "virtual-signal" or signal.signal.type
    sprite.sprite = type .. "/" .. signal.signal.name
    sprite.number = signal.count
  else
    sprite.visible = false
    button.visible = true
    
    button.elem_value = nil
  end
end

-- misc_update_selection
--
ltnc_gui.misc_update_selection = function(window, new_element, value)
    -- either way, deselect current slot
    if window.selected_elem ~= nil then
      window.selected_elem.style  = "ltnc_misc_slot_empty"
    end
    
    if new_element ~= nil and new_element ~= window.selected_elem then
      -- make slot selected
      new_element.style  = "ltnc_misc_slot_selected"
    end
    
    window.selected_elem = new_element
    
    -- update slider and textbox, value might be nil
    ltnc_gui.misc_update_inputs(window, value)
end

-- misc_slider_changed
--
ltnc_gui.misc_slider_changed = function(event)
  if not ltnc_gui.is_visible(event.player_index) then return end
  if not event.element or event.element.name ~= "ltnc_misc-slider_element" then return end
  
  local window = global.gui[event.player_index]
  if window.selected_elem == nil then return end
  
  local slot = tointeger(window.selected_elem.name, 1, 100)
  if slot == nil or slot < 1 or slot > config.ltnc_misc_slot_count then return end
  
  local value  = math.floor(event.element.slider_value)
  if value >= 9 then
    value = 10^(math.floor(value/10)) * ((value % 10)+1)
  else
    value = value + 1
  end
  
  window.selected_elem.number = value
  window.misc.text.text = value
  window.combinator:set_slot_value(slot, value)
  window.element_focus = true
end

-- ltnc_gui.misc_text_changed(event):
--  event listener for textfield, sets the value for the currently selected 
--  signal in a combinator
ltnc_gui.misc_text_changed = function(event)
  local window = global.gui[event.player_index]
  if window.selected_elem == nil then return end
  
  local slot = tointeger(window.selected_elem.name, 1, 100)
  if slot == nil or slot < 1 or slot > config.ltnc_misc_slot_count then return end
  
  -- validate input
  local value = tointeger(strip_input(event.element.text), -2000000000, 2000000000)
  if value ~= tonumber(event.element.text) and event.element.text ~= "" and event.element.text ~= "-" then
    event.element.text = value
  end
  
  if value > 10 then
    window.misc.slider.slider_value = math.floor(math.log10(value) * 10)
  else
    window.misc.slider.slider_value = value
  end

  window.selected_elem.number = value
  window.combinator:set_slot_value(slot, value)
end

-- misc_update_inputs
--
ltnc_gui.misc_update_inputs = function(window, value)
  if value == nil then
    window.misc.slider.visible = false
    window.misc.text.visible = false
    return
  end
  
  if value > 10 then
    window.misc.slider.slider_value = math.floor(math.log10(value) * 10)
  else
    window.misc.slider.slider_value = value
  end
  
  window.misc.slider.visible = true
  window.misc.text.visible = true
  window.misc.text.text    = value
end

ltnc_gui.on_tab_key = function(event)
  if not ltnc_gui.is_visible(event.player_index) then return end
  
  local window = global.gui[event.player_index]
  
  if not window.element_focus then
    -- find first visible element 
    for key, visible in pairs(window.visibility) do
      if visible == true then
        window.ltn.entries[key].element.focus()
        break
      end
    end
  end
  
  if window.element_focus ~= nil then
    window.element_focus = nil
    window.misc.text.focus() 
  end
end

--[[ ----------------------------------------------------------------------------------
        GRAPHICAL USER INTERFACE  
--]]

ltnc_gui.build = function(parent)
  local main_frame, combinator_frame 
  local element, container
  
  main_frame = parent.add {type="flow", name="ltnc-main-container", direction="horizontal"}
  main_frame.style.margin = 0
  main_frame.style.padding = 0
  main_frame.style.horizontal_spacing=3
  
  --[[ Combinator Frame ]]--
  combinator_frame = main_frame.add {type="flow", name="ltn-combinator-frame", direction="vertical"}
  combinator_frame.style.margin = 0
  combinator_frame.style.padding = 0
  combinator_frame.style.horizontally_stretchable = true
  combinator_frame.style.vertical_spacing = 0
  combinator_frame.style.minimal_width=320
  
  --[[ Network ID Frame ]]--
  local network = {
    frame = nil,
    table = nil,
    buttons = {},
  }
  
  network.frame = main_frame.add {type="flow", direction="vertical"}
  network.frame.style.margin = 0
  network.frame.style.padding = 0
  network.frame.style.vertical_spacing=0
  network.frame.style.minimal_width = 250
  network.frame.visible = false
  
  container = network.frame.add {type="frame", caption={"virtual-signal-name.ltn-network-id"}, direction="horizontal", style="ltnc_network_frame"}
  container.add {type = "button", name="ltnc_network_button_all", style="ltnc_network_button_all", caption={"ltnc.ltnc-all"}}
  container.add {type = "button", name="ltnc_network_button_none", style="ltnc_network_button_all", caption={"ltnc.ltnc-none"}}
  container.add {type = "sprite-button", name="ltnc_network_button_config", style="ltnc_network_button_config", sprite="item/iron-gear-wheel"}
  
  container = network.frame.add {type="frame", direction = "vertical", style="ltnc_network_frame"}
  network.table = container.add {type="table", column_count=6}
  network.table.style.horizontal_spacing = 5
  network.table.style.vertical_spacing = 5
  
  --[[ Upper Combinator Frame ]]--
  local upper_frame = combinator_frame.add {type="frame", caption={"entity-name.ltn-combinator"}, direction="vertical", style="ltnc_frame_style"}
  upper_frame.style.horizontally_stretchable = true
  
  --[[ RadioButton Group ]]--
  container = upper_frame.add {type="flow", direction="horizontal"}
  container.style.horizontal_align = "center"
  container.style.horizontally_stretchable = true
  
  local checkbuttons = {}
  checkbuttons[CHECK_REQUESTER] = container.add {type = "checkbox", name = _prefix .. "checkRequester", caption = {"ltnc.ltn-stop-requester"}, style="ltnc_checkbox_style", state = true}
  checkbuttons[CHECK_REQUESTER].tooltip = {"ltnc.ltnc-toggle-requester"}
  --checkbuttons[CHECK_REQUESTER].style.width=190
  checkbuttons[CHECK_PROVIDER]  = container.add {type = "checkbox", name = _prefix .. "checkProvider", caption =  {"ltnc.ltn-stop-provider"}, style="ltnc_checkbox_style", state = false}
  checkbuttons[CHECK_PROVIDER].tooltip = {"ltnc.ltnc-toggle-provider"}
  checkbuttons[CHECK_DEPOT]     = container.add {type = "checkbox", name = _prefix .. "checkDepot", caption = {"ltnc.ltn-stop-depot"}, style="ltnc_checkbox_style", state = false}
  checkbuttons[CHECK_DEPOT].tooltip = {"ltnc.ltnc-toggle-depot"}
  
  --[[ LTN Settings ]]--
  local ltn_table = upper_frame.add {type="table", column_count=3}
  ltn_table.style.cell_padding = 2
  ltn_table.style.horizontally_stretchable = true
  
  local ltn_entries = {}
  for name, signal in pairs(config.ltn_signals) do
    local tmp_entry = {}
    
    if name == "ltn-network-id" then
      tmp_entry.sprite = ltn_table.add {type="sprite-button",   name=_prefix .."networkid_button",  style="ltnc_network_network_button", sprite="virtual-signal/" .. name}
      network.toggle_button = tmp_entry.sprite
    else
      -- {element suffix, virtual signal, caption, default value}
      tmp_entry.sprite  = ltn_table.add {type="sprite",   name=_prefix .. name .. "_sprite", style="ltnc_entry_sprite", sprite="virtual-signal/" .. name}
    end
    tmp_entry.label   = ltn_table.add {type="label",    name=_prefix .. name .. "_label",  style="ltnc_entry_label", caption={"virtual-signal-name." .. name}}
    
    if name == "ltn-disable-warnings" then
      local state = signal.default > 0 or false
      tmp_entry.element = ltn_table.add {type="checkbox", name=_prefix .. name .. "_element", style="ltnc_entry_checkbox", state=state}
    else
      tmp_entry.element = ltn_table.add {type="textfield", name=_prefix .. name .. "_element", style="ltnc_entry_text", text=signal.default, numeric=true, allow_decimal=false, allow_negative=false}
      
      if signal.bounds.min < 0 then
        tmp_entry.element.allow_negative=true
      end
    end
    
    ltn_entries[name] = tmp_entry
  end
  
  local ltn = {
    buttons = checkbuttons,
    table   = ltn_table,
    entries = ltn_entries,
  }
  
  --[[ Lower Combinator Frame ]]--
  local lower_frame = combinator_frame.add {type="frame", direction = "vertical", style="ltnc_frame_style"}
  lower_frame.style.horizontally_stretchable = true

  --[[ Caption && On/Off Switch ]]--
  container = lower_frame.add{type="table", column_count=3}
  container.style.maximal_width = 276
  container.style.horizontally_stretchable = true
  container.style.left_margin = 10
  
  element = container.add {type="label", caption={"ltnc.ltnc-output"}, style="large_caption_label"}
  element.style.horizontally_stretchable = true
  checkbuttons[RADIO_ON]  = container.add {type = "radiobutton", name = _prefix .. "radioOn",  caption = {"ltnc.ltnc-on"}, state = true}
  checkbuttons[RADIO_ON].style.horizontally_stretchable = false
  checkbuttons[RADIO_ON].style.right_padding = 10
  checkbuttons[RADIO_OFF] = container.add {type = "radiobutton", name = _prefix .. "radioOff", caption = {"ltnc.ltnc-off"}, state = false}
  checkbuttons[RADIO_OFF].style.horizontally_stretchable = false
  checkbuttons[RADIO_OFF].style.right_padding = 0
  
  --[[ Element Box ]]--
  container = lower_frame.add {type="table", name = _prefix .. "elemTable", column_count=7}
  container.style.left_margin = 10
  
  local misc_signals = {}
  for i=1, config.ltnc_misc_slot_count do
    misc_signals[i] = {sprite = nil, button = nil}
    misc_signals[i].sprite =
        container.add({
          name = string.format(_prefix .. "misc-signal-sprite%d", i),
          type = "sprite-button",
          style = "ltnc_misc_slot_empty",
        })
    misc_signals[i].sprite.visible = true
    
    misc_signals[i].button = 
        container.add({
          name = string.format(_prefix .. "misc-signal-button%d", i),
          type = "choose-elem-button",
          style = "ltnc_misc_slot_empty",
          elem_type = "signal",
        })
  end 
  
  --[[ Misc Signal Value Changer ]]--
  container = lower_frame.add{type="table", column_count=2}
  container.style.maximal_width = 276
  container.style.minimal_height = 30
  container.style.horizontally_stretchable = true
  container.style.left_margin = 10
  container.style.top_margin = 5
  
  local misc_slider = container.add {type="slider", name=_prefix .. "misc-slider_element", minimum_value=-1, maximum_value=50}
  misc_slider.style.horizontally_stretchable = true
  misc_slider.style.right_padding = 10
  
  local misc_text   = container.add {type="textfield", name=_prefix .. "misc-text_element", style="ltnc_entry_text", numeric=true, text=0, allow_decimal=false, allow_negative=true} 
  
  main_frame.visible = false
  
  local misc = {
    signals = misc_signals,
    text    = misc_text,
    slider  = misc_slider,
  }

  return {main_frame = main_frame, network = network, ltn = ltn, misc_signals = misc_signals, misc = misc}
end

ltnc_gui.build_network_ui = function(player_index, network) 
  local container, element

  network.buttons = {}
  network.table.clear()

  for i = 1, 32 do
    -- add a spritebutton
    local key = string.format("ltnc_network_button%d", i)
    if global.network_icons[i] ~= nil then
      local type   = global.network_icons[i].type
      local name = global.network_icons[i].name
      
      network.buttons[i] = network.table.add {type="sprite-button", name = key, sprite = type .. "/" .. name, style = "ltnc_network_sprite_button"}  
      
    -- add a normal button
    else
      network.buttons[i] = network.table.add {type = "button", name = key, caption=i, style = "ltnc_network_sprite_button"}
    end
  end
  
  network.frame.visible = false
  network.toggle_button.style = "ltnc_network_network_button"
end 

--[[ 
        THIS IS THE END  
--]] ----------------------------------------------------------------------------------
return ltnc_gui