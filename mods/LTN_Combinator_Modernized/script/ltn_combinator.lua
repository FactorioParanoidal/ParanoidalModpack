local flib_gui = require("__flib__.gui")
local flib_format = require("__flib__.format")
local flib_position = require("__flib__.position")
local flib_box = require("__flib__.bounding-box")
local table = require("__flib__.table")
local math = require("__flib__.math")

local util = require("script.util")
local netui = require("script.network_descriptions")
local storage_data = require("script.storage_data")
local player_data = require("script.player_data")

local config = require("script.config")

local dlog = util.debug_log

--- @enum ToggleType
local tt = {
  bits = 1,
  on = 2,
  off = 3
}

--- Get the combinator data from storage.  Create it if it doesn't exist
---@param entity LuaEntity 
---@return CombinatorData
local function get_or_create_combinator_data(entity)
  local default_cd = { provider = true, requester = true }
  if not entity or not entity.valid or entity.name ~= "ltn-combinator" then
    -- Return a default value
    return default_cd
  end

  if not storage.combinators[entity.unit_number] then
    storage.combinators[entity.unit_number] = default_cd
  end

  return storage.combinators[entity.unit_number]
end -- get_combinator_data()

--- Retrieve an LTN signal from specified entity 
--- If it is not set, return the default value
--- @param ltn_signal_name LTNSignals @ The signal name being retrieved
--- @param ctl LuaConstantCombinatorControlBehavior
--- @return {value: integer, is_default: boolean}
local function get_ltn_signal_from_control(ctl, ltn_signal_name)
  local slot = config.ltn_signals[ltn_signal_name].slot
  local default = config.ltn_signals[ltn_signal_name].default
  local section = ctl.get_section(1)
  local filter = section.get_slot(slot)
  if filter.value then
    return { value = filter.min, is_default = false }
  else
    return { value = default, is_default = true }
  end
end -- get_ltn_signal_from_control()

--- Retrieve an LTN signal from combinator represented by this table 
--- If it is not set, return the default value
--- @param ltn_signal_name LTNSignals @ The signal name being retrieved
--- @param self LTNC
--- @return {value: integer, is_default: boolean}
local function get_ltn_signal(self, ltn_signal_name)
  local ctl = self.control
  return get_ltn_signal_from_control(ctl, ltn_signal_name)
end -- get_ltn_signal

--- @param ctl LuaConstantCombinatorControlBehavior
local function is_depot(ctl)
  return get_ltn_signal_from_control(ctl, "ltn-depot").value > 0 and true or false
end -- is_depot()

--- @param ctl LuaConstantCombinatorControlBehavior
local function is_fuel_station(ctl)
  return get_ltn_signal_from_control(ctl, "ltn-fuel-station").value > 0 and true or false
end -- is_fuel_station()

--- Enable or disable the edit elements in the provider / requester sections.
---@param self LTNC
---@param set_enable boolean
local function toggle_ui_req_prov_panels(self, set_enable)
  local services = { "provider", "requester" }
  for _, service in ipairs(services) do
    local table_name = "table_" .. service
    for _, elem in ipairs(self.elems[table_name].children) do
      elem.enabled = set_enable
    end

    -- Set the provider and requester states to false in storage data
    local chkbox = self.elems["check__" .. service]
    chkbox.enabled = set_enable
  end
end -- toggle_ui_req_prov_panels()

local function update_ui_network_id_label(self, netid)
  local label = self.elems["label__ltn-network-id"]
  label.caption = { "ltnc.encode-net-id", flib_format.number(netid, false) }
end -- update_ui_network_id_label()

--- Parse the Network ID and populate the bitfield editor
--- @param self LTNC
--- @param type ToggleType? @ How should buttons be updated?
local function update_ui_network_id_buttons(self, type)
  type = type or tt.bits
  local gni = storage.network_descriptions
  local btns = self.elems.net_encode_table.children
  local netid = get_ltn_signal(self, "ltn-network-id").value
  update_ui_network_id_label(self, netid)
  for i = 1, 32 do
    if type == tt.bits then
      local bit = 2 ^ (i - 1)
      btns[i].tooltip = { "ltnc.net-description-tip" }
      btns[i].sprite = nil
      btns[i].caption = tostring(i)
      btns[i].style = bit32.btest(netid, bit) and "ltnc_net_id_button_pressed" or "ltnc_net_id_button"
    else
      btns[i].style = type == tt.on and "ltnc_net_id_button_pressed" or "ltnc_net_id_button"
    end

    if gni[i] then
      if gni[i].icon and helpers.is_valid_sprite_path(gni[i].icon) then
        btns[i].sprite = gni[i].icon
        btns[i].caption = ""
      end

      if gni[i].tip then
        btns[i].tooltip = { "", gni[i].tip, "\n\n", { "ltnc.net-description-tip" } }
      end
    end
  end
end -- update_ui_network_id_buttons()

--- Setup the signal reset button associated with each LTN Signal
--- @param self LTNC
--- @param ltn_signal_name LTNSignals
--- @param is_default boolean # Is the named signal the default value
local function update_ui_signal_reset(self, ltn_signal_name, is_default)
  if ltn_signal_name == "ltn-depot"
  or ltn_signal_name == "ltn-fuel-station"
  or ltn_signal_name == "ltn-network-id"
  or ltn_signal_name == "ltn-depot-priority" then
    return
  end

  local elem = self.elems["ltn_signal_reset__" .. ltn_signal_name]
  if is_default then
    elem.enabled = false
    elem.tooltip = { "ltnc-tooltips.signal-is-default" }
  else
    elem.enabled = true
    elem.tooltip = { "ltnc-tooltips.signal-not-default" }
  end
end -- update_ui_signal_reset()

--- Populate a specific LTN Signal in the UI
--- @param ltn_signal_name LTNSignals @ LTN Signal to populate
--- @param self LTNC
local function update_ui_ltn_signal(self, ltn_signal_name)
  local ret = get_ltn_signal(self, ltn_signal_name)
  local transmitted = true
  --- @type LuaGuiElement
  local elem

  if ltn_signal_name == "ltn-depot"
    or ltn_signal_name == "ltn-disable-warnings"
    or ltn_signal_name == "ltn-fuel-station" then
    elem = self.elems["check__" .. ltn_signal_name]
    elem.state = ret.value > 0 and true or false
    update_ui_signal_reset(self, ltn_signal_name, ret.is_default)
    return
  end

  elem = self.elems["text_entry__" .. ltn_signal_name]
  -- TODO: Remove this (maybe) - used during Development.
  if not elem then
    return
  end

  elem.style = "ltnc_entry_text"

  -- Handle threshold values that are maintained even when Request Provide is disabled
  if string.match(ltn_signal_name, "%-threshold$") then
    local cd = get_or_create_combinator_data(self.entity)
    local req_prov = string.match(ltn_signal_name, "ltn%-(.-)%-")

    if not cd[req_prov] then
      if cd[ltn_signal_name] then
        ret.value = cd[ltn_signal_name]
        ret.is_default = false
      else
        ret.value = config.ltn_signals[ltn_signal_name].default
        ret.is_default = true
      end

      transmitted = ret.value == 0
    end
  end

  elem.text = tostring(ret.value)
  update_ui_signal_reset(self, ltn_signal_name, ret.is_default)
  
  -- Set text box style
  if ret.is_default then
    elem.style = "ltnc_entry_text_default_value"
  end
  
  -- Special style for Thresholds that are saved, but not emitted on the signal wire because the
  -- Request or Provide service is disabled for the combinator.  MAX_INT is emitted instead.
  if not transmitted then
    elem.style = "ltnc_entry_text_not_transmitted"
  end

  -- Update Network ID configuration buttons
  if ltn_signal_name == "ltn-network-id" then
    update_ui_network_id_label(self, ret.value)
  end
end -- update_ltn_signal()

--- Populate the LTN signals into their respective UI elements
--- @param self LTNC
local function update_ui_all_ltn_signals(self)
  for ltn_signal, _ in pairs(config.ltn_signals) do
    update_ui_ltn_signal(self, ltn_signal)
  end
end -- update_ltn_signals()

-- Checks if request/provide is enabled and returns the appropriate value to set on the combinator
--- @param entity LuaEntity Entity
--- @param name LTNSignals LTN Threshold Signal name
--- @param value integer Real threshold to store in storage
--- @return integer # Threshold to apply to combinator dependant on request/provide state
local function get_threshold_from_storage(entity, value, name)
  local cd = get_or_create_combinator_data(entity)
  if (string.match(name, "ltn%-requester") and cd.requester)
  or (string.match(name, "ltn%-provider") and cd.provider) then
    return value
  end
  
  if (string.match(name,"stack")) then
    return 0
  else
    return config.high_threshold
  end
end -- check_threshold()

--- @param value integer
--- @param ltn_signal_name LTNSignals
--- @param ctl LuaConstantCombinatorControlBehavior
local function set_ltn_signal_by_control(ctl, value, ltn_signal_name)
  local loc_settings = settings.global
  local explicit_network = loc_settings["ltnc-emit-default-network-id"].value
  local explicit_default = loc_settings["ltnc-emit-explicit-default"].value
  local signal_data = config.ltn_signals[ltn_signal_name]
  local section = ctl.get_section(1)


  -- Need to store thresholds in storage and set the correct values on the combinator
  -- dependant on provider/requester states
  if string.match(ltn_signal_name, "%-threshold$") then
    local cd = get_or_create_combinator_data(ctl.entity)
    cd[ltn_signal_name] = value ~= 0 and value or nil

    -- Remove default thresholds from storage if explicit_default is not set
    if value == signal_data.default and not explicit_default then
      cd[ltn_signal_name] = nil
    end

    if not (is_depot(ctl) or is_fuel_station(ctl)) then
      value = get_threshold_from_storage(ctl.entity, value, ltn_signal_name)
    end
  end

  -- Remove the signal from combinator if it is zero or non-existent
  if not value or value == 0 then
    section.clear_slot(signal_data.slot)
    return
  end

  --- @type LogisticFilter
  local filter = {
    min = value,
    value = { type = "virtual", name = ltn_signal_name, comparator = "=", quality = "normal" }
  }

  -- Set the non-default values
  if filter.min ~= signal_data.default then
    section.set_slot(signal_data.slot, filter)
    return
  end

  -- Handle setting default values.  Map setting control if values are stored when default
  -- Otherwise, default values are removed.
  if (ltn_signal_name == "ltn-network-id" and explicit_network)
      or (ltn_signal_name ~= "ltn-network-id" and explicit_default) then
    section.set_slot(signal_data.slot, filter)
  else
    section.clear_slot(signal_data.slot)
  end
end -- set_ltn_signal_by_control()

local function set_ltn_signal(self, value, ltn_signal_name)
  set_ltn_signal_by_control(self.control, value, ltn_signal_name)
end -- set_ltn_signal()

--- Retrieve a miscellaneous signal from the combinator
--- @param slot uint @ The slot to get data from
--- @param self LTNC
--- @return Signal
local function get_misc_signal(self, slot)
  local ctl = self.control
  return ctl.sections[1].get_slot(slot + config.ltnc_ltn_signal_count)
end -- get_misc_signal()

--- @param self LTNC
local function close_ui_misc_signal_edit_controls(self)
  local elems = self.elems
  local pt = storage.players[self.player.index]
  if not elems then
    return
  end

  elems.misc_signal_slider.enabled = false
  elems.misc_signal_slider.slider_value = 0
  elems.text_entry__stacks.enabled = false
  elems.text_entry__stacks.text = ""
  elems.text_entry__item_fluid.enabled = false
  elems.text_entry__item_fluid.text = ""
  elems.signal_quantity_confirm.enabled = false
  elems.signal_quantity_cancel.enabled = false

  pt.working_slot = nil
end -- close_misc_signal_edit_controls()

--- Populate a specific miscellaneous signal slot
--- @param slot uint
--- @param self LTNC
local function update_ui_misc_signal(self, slot)
  local ctl = self.control
  local section = ctl.get_section(1)
  local ret = section.get_slot(slot + config.ltnc_ltn_signal_count)
  local button = self.elems["misc_signal_slot__" .. slot]
  local value = button.children[1]
  if ret.value then
    value.caption = flib_format.number(ret.min, true)
    button.elem_value = ret.value
    button.locked = true
  else
    value.caption = ""
    button.elem_value = nil
    button.locked = false
  end
end -- update_misc_signal()

--- Populate the miscellaneous signal table
--- @param self LTNC
local function update_ui_all_misc_signals(self)
  close_ui_misc_signal_edit_controls(self)
  --- @type uint
  for i = 1, config.ltnc_misc_signal_count do
    update_ui_misc_signal(self, i)
  end
end -- update_misc_signal()

--- Set up the UI to set a misc signal value
--- @param slot uint
--- @param self LTNC
local function open_ui_misc_signal_edit_controls(self, slot)
  local pt = storage.players[self.player.index]
  local ws = pt.working_slot
  -- Changing from an already active working slot.
  -- Reset UI and prepare to work on newly selected slot
  if ws and ws.index ~= slot then
    update_ui_misc_signal(self, ws.index)
    pt.working_slot = nil
  end

  local cur = get_misc_signal(self, slot)
  if not cur then
    return
  end

  -- Record the slot player is working with in storage so that values can be
  -- updated with later events
  ws = {
    index = slot,
    panel = self.elems.stack_item_flow,
    slider = self.elems.misc_signal_slider,
    stacks = self.elems.text_entry__stacks,
    items = self.elems.text_entry__item_fluid,
    confirm = self.elems.signal_quantity_confirm,
    cancel = self.elems.signal_quantity_cancel
  }
  pt.working_slot = ws
  local slider_max
  local slider_increment

  ws.slider.enabled = true
  ws.stacks.enabled = true
  ws.items.enabled = true
  ws.confirm.enabled = true
  ws.cancel.enabled = true

  local is_new = false
  if not cur.value then
    -- Must be setting up a new signal slot
    local elem = self.elems["misc_signal_slot__" .. slot]
    cur.value = {
      name = elem.elem_value.name,
      type = elem.elem_value.type or "item",
      quality = elem.elem_value.quality
    }
    cur.min = 1
    is_new = true
  end

  if cur.value.type == "item" then
    ws.stack_size = prototypes.item[cur.value.name].stack_size
    ws.stacks.enabled = true
    slider_max = config.slider_max_stacks * ws.stack_size
    slider_increment = ws.stack_size
  else
    ws.stack_size = 1 -- fluid and virtual signals don't have stacks
    ws.stacks.enabled = false
    -- TODO: Base on user setting on multiples of chosen tank type?
    slider_max = config.slider_max_fluid
    slider_increment = 1000
  end

  ws.items.text = tostring(cur.min)
  ws.stacks.text = "1"
  ws.slider.set_slider_minimum_maximum(0, slider_max)
  ws.slider.set_slider_value_step(slider_increment)

  if cur.value.type == "item" and pt.settings["ltnc-use-stacks"] then
    if is_new then
      util.from_stacks(self.player)
    else
      util.from_items(self.player)
    end

    ws.stacks.enabled = true
    ws.stacks.focus()
    ws.stacks.select_all()
  else
    util.from_items(self.player)
    ws.stacks.enabled = false
    ws.items.focus()
    ws.items.select_all()
  end
end -- open_misc_signal_edit_controls()

--- Clear a miscellaneous signal slot
--- @param slot uint
--- @param self LTNC
local function clear_misc_signal(self, slot)
  local ctl = self.control
  local section = ctl.get_section(1)
  section.clear_slot(slot + config.ltnc_ltn_signal_count)
end -- clear_misc_signal()

--- @param filter Signal
--- @param slot uint
--- @param self LTNC
local function set_misc_signal(self, filter, slot)
  local ctl = self.control
  local section = ctl.get_section(1)
  -- TODO: This probably is a deficiency in the API.  Submitting a bug.
  -- Update with bug information and / or fix later.
  local success, error = pcall(function() section.set_slot(slot, filter) end)
  if not success then
    self.player.create_local_flying_text{text = error, create_at_cursor = true}
  end
end -- set_misc_signal()

--- Refresh the entire UI with current data
--- @param self LTNC
local function update_ui(self)
  -- update enabled / disables status
  if not self.entity.valid then
    return
  end
  if self.control.enabled then
    -- Enabled
    self.elems.on_off.switch_state = "right"
    self.elems.status_indicator.sprite = "flib_indicator_green"
    self.elems.status_label.caption = { "ltnc.status-working" }
  else
    -- Disabled
    self.elems.on_off.switch_state = "left"
    self.elems.status_indicator.sprite = "flib_indicator_red"
    self.elems.status_label.caption = { "ltnc.status-disabled" }
  end
  -- update LTN signals
  update_ui_all_ltn_signals(self)
  update_ui_network_id_buttons(self)
  -- update Misc signals
  update_ui_all_misc_signals(self)
  local cd = get_or_create_combinator_data(self.entity)
  self.elems.check__provider.state = cd.provider
  self.elems.check__requester.state = cd.requester
  if is_depot(self.control) or is_fuel_station(self.control) then
    toggle_ui_req_prov_panels(self, false)
    if is_fuel_station(self.control) then
      self.elems["check__ltn-depot"].enabled = false
    end
    if is_depot(self.control) then
      self.elems["check__ltn-fuel-station"].enabled = false
    end
  end
end -- update_ui()

--- Sort the signals within the combinator.
--- @param entity LuaEntity
local function sort_signals(entity)
  local needs_sorting = false
  local cb = entity.get_control_behavior() --[[@as LuaConstantCombinatorControlBehavior]]
  local section = cb.get_section(1)

  -- Validate signal slot locations, If sorting is not needed skip it.
  --- @type uint
  for i = 1, section.filters_count do
    local filter = section.get_slot(i)
    if filter.value ~= nil then
      local name = filter.value.name
      local type = filter.value.type
      -- If LTN Signal, make sure it is in the correct slot.
      if type == "virtual" and config.ltn_signals[name] ~= nil then
        -- Signals with a value of 0 are not emitted on the wire.
        -- In the case of an LTN, absence of a control signal will result in the LTN default
        -- being used.  Remove LTN signals with a value of 0 to remove ambiguity.
        if filter.min == 0 then
          section.clear_slot(i)
        else
          needs_sorting = config.ltn_signals[name].slot ~= i or i > config.ltnc_ltn_signal_count
        end

      else
        -- Not an LTN signal, make sure it is not in an LTN slot
        needs_sorting = i <= config.ltnc_ltn_signal_count
      end
    end

    -- No need to check everything if we already need sorting.
    if needs_sorting then break end
  end

  if needs_sorting then
    local temp_filters = {}
    --- @type uint
    for j = 1, section.filters_count do
      local filter = section.get_slot(j)
      if filter.value ~= nil then
        table.insert(temp_filters, filter)
        section.clear_slot(j)
      end
    end

    --- @type uint
    local misc_slot = config.ltnc_ltn_signal_count + 1
    for _, f in pairs(temp_filters) do
      local name = f.value.name
      if config.ltn_signals[name] ~= nil then
        section.set_slot(config.ltn_signals[name].slot, f)
      else
        section.set_slot(misc_slot, f)
        misc_slot = misc_slot + 1
      end
    end
  end
end -- sort_signals()

--- Called to close the combinator UI
--- @param input EventData.CustomInputEvent | number # This will either be a player_index or an EventData table
local function close(input)
  --- @type uint
  local ndx
  if type(input) == "table" then
    ndx = input.player_index
  else
    ndx = input --[[@as uint]]
  end
  local pt = storage.players[ndx]
  local player = game.get_player(ndx)
  if player and player.valid then
    player.play_sound({path = "entity-close/ltn-combinator"})
  end

  if pt.uis.netui then
    netui.close(pt.uis.netui, ndx)
  end
  if pt.main_elems and pt.main_elems.ltnc_main_window then
    pt.main_elems.ltnc_main_window.destroy()
    pt.main_elems = nil
    pt.uis.main = nil
    pt.working_slot = nil
    pt.unit_number = nil
  end
end -- ltnc_ui.close()

-- Map the LTN settings to the ltn-signal that it controls
local ltn_setting_to_signal = {
  ["ltn-dispatcher-requester-threshold"] = "ltn-requester-threshold",
  ["ltn-dispatcher-provider-threshold"] = "ltn-provider-threshold",
  ["ltn-stop-default-network"] = "ltn-network-id"
}

--- Update the semi-constant "config"table with the new LTN settings
--- @param name string LTN Setting name that changed
local function runtime_setting_changed(name)
  if ltn_setting_to_signal[name] then
    config.ltn_signals[ltn_setting_to_signal[name]].default
      = settings.global[name].value --[[@as number]]
  elseif name == "ltnc-alert-build-disable"
  and not settings.global[name].value
  then
    storage.built_disabled = nil
  end
  
end -- runtime_setting_changed()

--- Update the player runtime setting cache in storage if the player changes their settings
--- @param name string The setting that was changed
--- @param player_index uint Index of the player that changed their setting
local function player_setting_changed(name, player_index)
  local player_settings = storage.players[player_index].settings
  player_settings[name] = settings.get_player_settings(player_index)[name].value
end -- player_setting_changed()

--- Toggle the state of the provider / requester services
--- @param ctl LuaConstantCombinatorControlBehavior
--- @param name string # Service to toggle, ("requester", "provider", or "combinator")
--- @param state boolean # false := disable service, true := enable service
--- @return boolean # Something was actually disabled
local function toggle_service_by_ctl(ctl, name, state)
  local disabled = false
  if name == "combinator" then
    if ctl.enabled == true and state == false then
      disabled = true
    end

    ctl.enabled = state
    return disabled
  end

  local cd = get_or_create_combinator_data(ctl.entity)
  if cd[name] == true and state == false then
    disabled = true
  end

  cd[name] = state
  for _, sig in ipairs{"threshold", "stack-threshold"} do
    local signal = "ltn-" .. name .. "-" .. sig
    local count = cd[signal]
    set_ltn_signal_by_control(ctl, count, signal)
  end
  return disabled
end -- toggle_service_by_ctl()

--- Toggle the state of the provider / requester services
--- @param self LTNC
--- @param name string
--- @param state boolean
local function toggle_service(self, name, state)
  toggle_service_by_ctl(self.control, name, state)
end -- toggle_service()

---Toggle the network config panel
---@param self LTNC
---@param display boolean? # true := Turn on Net Panel, false:= Turn off Net Panel, nil := toggle
local function toggle_network_config(self, display)
  local nf = self.elems.net_encode_flow
  local ef = self.elems.entity_preview_frame
  local function neton()
    nf.visible = true
    ef.visible = false
  end

  local function netoff()
    nf.visible = false
    ef.visible = true
  end

  if display == nil then
    if nf.visible then
      netoff()
    else
      neton()
    end

  elseif display == true then
    neton()
  elseif display == false then
    netoff()
  end
end -- toggle_network_config()
----------------------------------------------------------------------------------------------------
--#region Handlers

local handlers = {
  --- @param e EventData.on_gui_click
  --- @param self LTNC
  network_id_config = function(self, e)
    toggle_network_config(self)
  end, -- network_id_config()

  --- @param e EventData.on_gui_click
  --- @param self LTNC
  network_id_toggle = function (self, e)
    local elem = e.element
    local netid_textbox = self.elems["text_entry__ltn-network-id"]
    netid_textbox.style = "ltnc_entry_text"
    if elem.name == "net_id_all" then
      update_ui_network_id_buttons(self, tt.on)
    elseif elem.name == "net_id_none" then
      update_ui_network_id_buttons(self, tt.off)
    elseif e.shift then
      netui.open_single(e, update_ui_network_id_buttons)
    else
      if elem.style.name == "ltnc_net_id_button_pressed" then
        elem.style = "ltnc_net_id_button"
      else
        elem.style = "ltnc_net_id_button_pressed"
      end
    end
    util.from_netid_buttons(self.player)
    local value = tonumber(netid_textbox.text) --[[@as integer]]
    set_ltn_signal(self, value, "ltn-network-id")
    update_ui_ltn_signal(self, "ltn-network-id")
  end, -- network_id_toggle()

  --- @param e EventData.on_gui_click
  --- @param self LTNC
  misc_signal_confirm = function(self, e)
    local ws = storage.players[e.player_index].working_slot
    local loc_settings = settings.get_player_settings(e.player_index)
    -- Prevent a crash is somehow the working slot becomes invalid 
    if not ws then
      close_ui_misc_signal_edit_controls(self)
      return
    end
    
    local value = tonumber(ws.items.text)
    if not value or value < math.min_int or value > math.max_int then
      return
    end

    local elem = self.elems["misc_signal_slot__" .. ws.index]
    -- Prevent a crash if somehow the element is no longer valid and the edit controls are still open
    if not elem or not elem.elem_value then
      close_ui_misc_signal_edit_controls(self)
      return
    end

    local name = elem.elem_value.name
    local type = elem.elem_value.type or "item"
    local quality = "normal"
    if type == "item" and elem.elem_value.quality then
      quality = elem.elem_value.quality
    end

    if (type == "item" or type == "fluid")
    and value > 0
    and (
      loc_settings["ltnc-negative-signals"].value and not e.shift
      or e.shift and not loc_settings["ltnc-negative-signals"].value
    ) then
        value = value * -1
    end

    set_misc_signal(
      self,
      {min = value, value = { name = name, type = type, quality = quality}},
      ws.index + config.ltnc_ltn_signal_count
    )
    update_ui_misc_signal(self, ws.index)
    close_ui_misc_signal_edit_controls(self)
  end, -- misc_signal_confirm()

  --- @param e EventData.on_gui_click
  --- @param self LTNC
  misc_signal_cancel = function(self, e)
    local ws = storage.players[e.player_index].working_slot
    if ws then
      update_ui_misc_signal(self, ws.index)
    end
    close_ui_misc_signal_edit_controls(self)
  end, -- misc_signal_cancel

  --- @param e EventData.on_gui_text_changed
  --- @param self LTNC
  misc_signal_stacks_text_changed = function(self, e)
    util.from_stacks(self.player)
  end, -- misc_signal_stacks_text_changed()

  --- @param e EventData.on_gui_text_changed
  --- @param self LTNC
  misc_signal_items_text_changed = function(self, e)
    if not e.element or not e.element.text then
      return
    end

    local value = tonumber(e.element.text)
    if not value then
      return
    end

    if value < math.min_int or value > math.max_int then
      e.element.style = "ltnc_entry_text_invalid_value"
    else
      e.element.style = "ltnc_entry_text"
    end

    util.from_items(self.player)
  end, -- misc_signal_items_text_changed()

  --- @param e EventData.on_gui_value_changed
  --- @param self LTNC
  misc_signal_slider_changed = function(self, e)
    util.from_slider(self.player)
  end, -- misc_signal_slider_changed()

  --- @param e EventData.on_gui_elem_changed
  --- @param self LTNC
  misc_signal_elem_changed = function(self, e)
    local elem = e.element
    if not elem.elem_value then
      return
    end

    if table.find(config.bad_signals, elem.elem_value.name) then
      game.print({"ltnc.bad-signal", elem.elem_value.name})
      elem.elem_value = nil
      return
    end

    local _, _, slot = string.find(elem.name, "__(%d+)")
    slot = tonumber(slot) --[[@as uint]]
    open_ui_misc_signal_edit_controls(self, slot)
  end, -- misc_signal_elem_changed()

  --- @param e EventData.on_gui_click
  --- @param self LTNC
  misc_signal_clicked = function(self, e)
    local elem = e.element
    local _, _, slot = string.find(elem.name, "__(%d+)")
    slot = tonumber(slot) --[[@as uint]]
    if e.button == defines.mouse_button_type.right then
      -- Right click, clear the slot
      elem.locked = false
      clear_misc_signal(self, slot)
      update_ui_misc_signal(self, slot)
      close_ui_misc_signal_edit_controls(self)
    elseif e.button == defines.mouse_button_type.left then
      -- Left click.  If the slot has a signal we don't want choose a new one, just update the value.
      if not elem.locked then
      return
    end
      open_ui_misc_signal_edit_controls(self, slot)
    end
  end, -- misc_signal_clicked()

  --- @param e EventData.on_gui_switch_state_changed
  --- @param self LTNC
  enable_disable_combinator = function(self, e)
    local ctl = self.control
    if not ctl.valid then
      return
    end
    if e.element.switch_state == "left" then
      ctl.enabled = false
    else
      ctl.enabled = true
    end
    update_ui(self)
  end, -- enable_disable_combinator()

  --- @param e EventData.on_gui_checked_state_changed
  --- @param self LTNC
  provide_request_state_changed = function(self, e)
    local elem = e.element
    local name = string.match(elem.name, "__(.*)")
    toggle_service(self, name, elem.state)
    update_ui(self)
  end, -- ltnc_ui:provide_request()

  --- @param e EventData.on_gui_checked_state_changed
  --- @param self LTNC
  ltn_checkbox_state_change = function(self, e)
    local elem = e.element
    if not elem then
      return
    end

    local name = string.match(elem.name, "__(.*)$")
    local value = 0
    if elem.state then
      value = 1
    end
    
    set_ltn_signal(self, value, name)
    update_ui_signal_reset(self, name, get_ltn_signal(self, name).is_default)
  end, -- ltn_checkbox_state_change()

  --- @param e EventData.on_gui_click
  --- @param self LTNC
  ltn_depot_toggle = function(self, e)
    if not e.element then
      return
    end

    if e.shift then
      -- Remove and disable signals associated with requesters and providers
      for signal, details in pairs(config.ltn_signals) do
        if details.group == "provider" or details.group == "requester" then
          set_ltn_signal(self, 0, signal )
        end
      end
      e.element.state = true
    end

    local value = 0
    if e.element.state then
      value = 1
      toggle_service(self, "provider", false)
      toggle_service(self, "requester", false)
    end

    set_ltn_signal(self, value, "ltn-depot")
    -- element.state is true if we made the station a depot.  Therefore the req/prov panels should
    -- be disabled (not e.element.state)
    toggle_ui_req_prov_panels(self, not e.element.state)
    self.elems["check__ltn-fuel-station"].enabled = not e.element.state

    update_ui(self)
  end, -- ltn_depot_toggle()

  --- @param e EventData.on_gui_click
  --- @param self LTNC
  ltn_fuel_toggle = function(self, e)
    if not e.element then
      return
    end

    if e.shift then
      -- Remove and disable signals associated with requesters and providers
      for signal, details in pairs(config.ltn_signals) do
        if details.group == "provider" or details.group == "requester" then
          set_ltn_signal(self, 0, signal )
        end
      end
      e.element.state = true
    end

    local value = 0
    if e.element.state then
      value = 1
      toggle_service(self, "provider", false)
      toggle_service(self, "requester", false)
    end

    set_ltn_signal(self, value, "ltn-fuel-station")
    -- element.state is true if we made this a fuel station.  Therefore the req/prov panels should
    -- be disabled (not e.element.state)
    toggle_ui_req_prov_panels(self, not e.element.state)
    self.elems["check__ltn-depot"].enabled = not e.element.state

    update_ui(self)
  end, -- ltn_fuel_toggle()

  --- @param e EventData.on_gui_text_changed
  --- @param self LTNC
  ltn_signal_textbox_changed = function(self, e)
    local elem = e.element
    local value = tonumber(e.text)
    local name = string.match(elem.name, "__(.*)$")
    -- value == nil is still valid - results in removing the signal and reverting to LTN default
    if not util.is_valid(name, value) then
      elem.style = "ltnc_entry_text_invalid_value"
      return
    end

    elem.style = "ltnc_entry_text"
    update_ui_signal_reset(self, name, false)
    -- Do not remove signal while typing if they only deleted the text before typing
    -- If player explicitly types '0' remove the signal as typed
    if value then
      set_ltn_signal(self, value, name)
    end

    if name == "ltn-network-id" then
      update_ui_network_id_buttons(self)
    end
  end, -- ltn_signal_textbox_click()

  --- @param e EventData.on_gui_click
  --- @param self LTNC
  ltn_signal_textbox_click = function(self, e)
    e.element.select_all()
    --e.element.style = "ltnc_entry_text"
  end, -- ltn_signal_textbox_click()

  --- @param e EventData.on_gui_confirmed
  --- @param self LTNC
  ltn_signal_textbox_confirmed = function(self, e)
    local elem = e.element
    --- @type LTNSignals
    local name = string.match(elem.name, "__(.*)$")
    local value = tonumber(elem.text) --[[@as integer]]
    if not util.is_valid(name, value) then
      elem.focus()
      return
    end
    -- If the player is CONFIRMING an empty edit box, remove the signal
    if not value then
      set_ltn_signal(self, value, name)
    end
    update_ui_ltn_signal(self, name)
  end, -- ltn_signal_textbox_confirmed()

  --- @param e EventData.on_gui_click
  --- @param self LTNC
  reset_ltn_signal = function(self, e)
    local name = string.match(e.element.name, "__(.*)$")
    set_ltn_signal(self, 0, name)
    update_ui_ltn_signal(self, name)
    update_ui_signal_reset(self, name, true)
  end,  -- reset_ltn_signal()

  --- @param e EventData.CustomInputEvent
  --- @param self LTNC
  close_ltnc_ui = function(self, e)
    close(e)
  end, -- close_ltnc_ui()
} -- handlers

flib_gui.add_handlers(handlers, function(e, handler)
  local self = storage.players[e.player_index].uis.main
  if self then
    handler(self, e)
  end
end)
--#endregion
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
--#region GUI

--- Generate the tooltip for the LTN Signal textbox
--- @param name LTNSignals
--- @return LocalisedString
local function signal_tooltip(name)
  local d = config.ltn_signals[name]
  local max = d.max
  if name == "ltn-locked-slots" then
    -- Max wagon size...
    max = 40
  end
  return {
    "",
    { "ltnc-signal-tips." .. name },
    { "ltnc-signal-tips.zero-value" },
    {
      "ltnc-signal-tips.min-max-default",
      flib_format.number(d.min, false),
      flib_format.number(max, false),
      flib_format.number(d.default, false)
    }
  }
end -- signal_tooltip()

--- Render a checkbox
--- @param name string @ Name to give the textbox element "text_entry__\<name\>"
--- @param handler function|function[] @ Handler(s) for the checkbox
--- @param caption LocalisedString? @ Optional: Text next to the checkbox
--- @param tooltip LocalisedString? @ Optional: Checkbox's tooltip
--- @return GuiElemDef
local function check_box(name, handler, caption, tooltip)
  return
  {
    type = "checkbox",
    state = false,
    name = "check__" .. name,
    caption = caption or "",
    tooltip = tooltip or nil,
    handler = handler,
  }
end -- check_box()

--- Render LTN Signal textbox
--- @param name LTNSignals
--- @return GuiElemDef
local function ltn_signal_edit_box(name)
  local handler = {
    [defines.events.on_gui_text_changed] = handlers.ltn_signal_textbox_changed,
    [defines.events.on_gui_click] = handlers.ltn_signal_textbox_click,
    [defines.events.on_gui_confirmed] = handlers.ltn_signal_textbox_confirmed,
  }
  local negative = false
  if config.ltn_signals[name].min < 0 then
      negative = true
  end
  return
  {
    type = "textfield",
    style = "ltnc_entry_text",
    name = "text_entry__" .. name,
    numeric = true,
    allow_decimal = false,
    allow_negative = negative,
    clear_and_focus_on_right_click = true,
    lose_focus_on_confirm = true,
    tooltip = signal_tooltip(name),
    handler = handler,
  }
end -- ltn_signal_edit_box()

--- Render GuiElemDef for LTN signals in the given group
--- @param group LTNGroups @ Group to build signals for
--- @return GuiElemDef
local function ltn_signals_by_group(group)
  local group_signals =
      table.filter(
        config.ltn_signals,
        function(v) return v.group == group end
      )
  local elems = {}
  local function text_or_check(name)
    if group == "requester" and name == "ltn-disable-warnings" then
      return check_box(name, handlers.ltn_checkbox_state_change, nil, { "ltnc-signal-tips.ltn-disable-warnings" })
    else
      return ltn_signal_edit_box(name)
    end
  end

  for ltn_signal_name, _ in pairs(group_signals) do
    elems = table.array_merge { elems, {
      {
        type = "sprite-button",
        style = "ltnc_cancel_button",
        name = "ltn_signal_reset__" .. ltn_signal_name,
        style_mods = { size = 14 },
        elem_mods = { enabled = false },
        mouse_button_filter = { "left" },
        sprite = "utility/reset",
        handler = { [defines.events.on_gui_click] = handlers.reset_ltn_signal },
      },
      {
        type = "sprite",
        sprite = "virtual-signal/" .. ltn_signal_name,
        style = "ltnc_entry_sprite"
      },
      {
        type = "label",
        caption = { "virtual-signal-name." .. ltn_signal_name },
        style = "caption_label"
      },
      {
        type = "empty-widget",
        style = "flib_horizontal_pusher"
      },
      text_or_check(ltn_signal_name),
    } }
  end
  return elems
end -- ltn_signals_by_group()

--- Render a panel of LTN signal for the given group
--- @param group LTNGroups @ The group of signals desired
--- @return GuiElemDef
local function ltn_signal_panel(group)
  return {
    type = "flow",
    direction = "vertical",
    { type = "label", style = "ltnc_header_label", caption = { "ltnc." .. group .. "-heading" } },
    {
      type = "frame",
      direction = "vertical",
      style = "flib_shallow_frame_in_shallow_frame",
      style_mods = { padding = 6 },
      {
        type = "table",
        name = "table_" .. group,
        column_count = 5,
        style_mods = { cell_padding = 2, horizontally_stretchable = true },
        children = ltn_signals_by_group(group)
      }
    }
  }
end -- ltn_signal_panel()

--- Render GuiElemDef for the miscellaneous signal slot buttons
--- @param slot_count integer @ Number of signal slots to build
--- @return GuiElemDef
local function misc_signal_buttons(slot_count)
  local buttons = {}

  for i = 1, slot_count do
    buttons[i] = {
      type = "choose-elem-button",
      name = "misc_signal_slot__" .. tostring(i),
      style = "flib_slot_button_default",
      elem_type = "signal",
      handler = {
        [defines.events.on_gui_elem_changed] = handlers.misc_signal_elem_changed,
        [defines.events.on_gui_click] = handlers.misc_signal_clicked,
      },
      {
        type = "label",
        style = "signal_count",
        ignored_by_interaction = true,
        caption = "",
      }
    }
  end
  return buttons
end -- misc_signal_button()

--- Generate the buttons for the network encoder UI
--- @param buttons uint
--- @return GuiElemDef
local function net_encode_toggle_buttons(buttons)
  local t =
  {
    type = "table",
    name = "net_encode_table",
    column_count = 8,
    children = {},
  }
  for i = 1, buttons do
    t.children[i] =
    {
      type = "sprite-button",
      handler = { [defines.events.on_gui_click] = handlers.network_id_toggle },
      style = "ltnc_net_id_button",
      caption = tostring(i),
      mouse_button_filter = { "left" },
    }
  end
  return t
end -- net_encode_toggle_buttons()

---@param player LuaPlayer
---@return table?
local function confirm_tooltip(player)
  if settings.get_player_settings(player)["ltnc-negative-signals"].value then
    return { "ltnc-tooltips.signal-confirm" }
  end
end

--- Build the LTN Main UI window
--- @param player LuaPlayer @ Player object that is opening the combinator
--- @return GuiElemDef
---@diagnostic disable:missing-fields
local function build(player)
  local elems = flib_gui.add(player.gui.screen, {
    { -- Main Window Frame
      type = "frame",
      direction = "vertical",
      name = "ltnc_main_window",
      handler = { [defines.events.on_gui_closed] = handlers.close_ltnc_ui},
      { -- Title Bar
        type = "flow",
        style = "flib_titlebar_flow",
        drag_target = "ltnc_main_window",
        {
          type = "label",
          style = "frame_title",
          caption = { "ltnc.window-title" },
          ignored_by_interaction = true,
        },
        {
          type = "empty-widget",
          style = "flib_titlebar_drag_handle",
          ignored_by_interaction = true,
        },
        {
          type = "sprite-button",
          style = "frame_action_button",
          sprite = "utility/close",
          --hovered_sprite = "utility/close_black",
          --clicked_sprite = "utility/close_black",
          mouse_button_filter = { "left" },
          handler = { [defines.events.on_gui_click] = handlers.close_ltnc_ui },
        }
      },
      { -- UI Content
        type = "flow",
        { -- Primary panel
          type = "frame",
          style = "inside_shallow_frame_with_padding",
          direction = "vertical",
          style_mods = { top_padding = 8 },
          { -- Status indicator
            type = "flow",
            style = "flib_indicator_flow",
            style_mods = { bottom_padding = 10 },
            {
              type = "sprite",
              name = "status_indicator",
              sprite = "flib_indicator_green",
              style_mods = { size = 16, stretch_image_to_widget_size = true },
            },
            {
              type = "label",
              name = "status_label",
              caption = { "ltnc.status-working" },
            }
          },
          { -- Network Encode Pane
            type = "frame",
            style = "flib_shallow_frame_in_shallow_frame",
            style_mods = {
              padding = 8,
            },
            name = "net_encode_flow",
            visible = false,
            direction = "vertical",
            {
              type = "flow",
              style_mods = {
                horizontally_stretchable = true,
                minimal_height = 128,
                vertical_align = "center",
              },
              net_encode_toggle_buttons(32),
              {
                type = "flow",
                direction = "vertical",
                style_mods = {
                  horizontally_stretchable = true,
                  vertically_stretchable = true,
                  minimal_height = 128,
                  horizontal_align = "right",
                  vertical_align = "center",
                },
                {
                  type = "button",
                  name = "net_id_all",
                  style_mods = { minimal_width = 94 },
                  handler = { [defines.events.on_gui_click] = handlers.network_id_toggle },
                  caption = { "ltnc.btn-all" },
                  tooltip = { "ltnc-signal-tips.ltn-network-id-all" }
                },
                {
                  type = "button",
                  name = "net_id_none",
                  style_mods = { minimal_width = 94 },
                  handler = { [defines.events.on_gui_click] = handlers.network_id_toggle },
                  caption = { "ltnc.btn-none" },
                  tooltip = { "", { "ltnc-signal-tips.ltn-network-id-none" }, { "ltnc-signal-tips.zero-value" } },
                },
                ltn_signal_edit_box("ltn-network-id"),
              },
            },
          },
          { -- Entity Preview
            type = "frame",
            name = "entity_preview_frame",
            style = "flib_shallow_frame_in_shallow_frame",
            {
              type = "entity-preview",
              name = "entity_preview",
              style_mods = {
                minimal_height = 128,
                horizontally_stretchable = true,
                vertically_stretchable = true,
              },
            }
          },
          { -- Network ID
            type = "table",
            name = "netid",
            column_count = 2,
            style_mods = { top_margin = 8, cell_padding = 2, horizontally_stretchable = true },
            {
              type = "sprite-button",
              style = "ltnc_small_button",
              sprite = "virtual-signal/ltn-network-id",
              tooltip = { "ltnc.net-config-tip" },
              handler = { [defines.events.on_gui_click] = handlers.network_id_config },
              mouse_button_filter = { "left" },
            },
            {
              type = "label",
              style = "caption_label",
              name = "label__ltn-network-id",
            }
          },
          { -- On/Off switch / Services / Depot priority
            type = "table",
            column_count = 5,
            style_mods = { horizontally_stretchable = true, cell_padding = 2 },
            { -- Switch
              type = "flow",
              direction = "vertical",
              { type = "label", caption = { "ltnc.output" } },
              {
                type = "switch",
                name = "on_off",
                left_label_caption = { "ltnc.off" },
                right_label_caption = { "ltnc.on" },
                handler = { [defines.events.on_gui_switch_state_changed] = handlers.enable_disable_combinator },
              }
            },
            { type = "empty-widget", style = "flib_horizontal_pusher" },
            { -- Request / Provide
              type = "flow",
              direction = "vertical",
              check_box(
                "provider",
                { [defines.events.on_gui_checked_state_changed] = handlers.provide_request_state_changed },
                { "ltnc.provider" },
                { "ltnc.provider-tip" }
              ),
              check_box(
                "requester",
                { [defines.events.on_gui_checked_state_changed] = handlers.provide_request_state_changed },
                { "ltnc.requester" },
                { "ltnc.requester-tip" }
              ),
              {
                type = "table",
                column_count = 2,
                style_mods = { horizontally_stretchable = true },
                check_box(
                  "ltn-fuel-station",
                  { [defines.events.on_gui_click] = handlers.ltn_fuel_toggle },
                  --{ [defines.events.on_gui_checked_state_changed] = handlers.ltn_depot_toggle },
                  { "ltnc.ltn-fuel-station" },
                  { "ltnc-signal-tips.ltn-fuel-station" }
                ),
              },
            },
            { -- Depot Priority
              type = "flow",
              direction = "vertical",
              style_mods = { horizontal_align = "right" },
              {
                type = "table",
                column_count = 2,
                style_mods = { cell_padding = 2, horizontally_stretchable = true },
                {
                  type = "sprite",
                  sprite = "virtual-signal/ltn-depot-priority",
                  style = "ltnc_entry_sprite"
                },
                check_box(
                  "ltn-depot",
                  { [defines.events.on_gui_click] = handlers.ltn_depot_toggle },
                  --{ [defines.events.on_gui_checked_state_changed] = handlers.ltn_depot_toggle },
                  { "ltnc.depot" },
                  { "ltnc-signal-tips.ltn-depot" }
                ),
                {
                  type = "label",
                  caption = { "ltnc.priority" },
                  style = "caption_label",
                },
                ltn_signal_edit_box("ltn-depot-priority"),
              },
            },
          },
          { -- Line
            type = "line", style_mods = { top_margin = 4, bottom_margin = 4 }
          },
          {
            type = "flow",
            style_mods = { minimal_height = 56 },
            {
            type = "flow",
            direction = "vertical",
            name = "stack_item_flow",
            { --Stack / Item / Confirm
              type = "flow",
              style_mods = { vertical_align = "center" },
              { type = "empty-widget", style = "flib_horizontal_pusher" },
              {
                type = "flow",
                name = "stack_flow",
                { type = "label",        caption = { "ltnc.label-stacks" } },
                {
                  type = "textfield",
                  style = "ltnc_entry_text",
                  name = "text_entry__stacks",
                  elem_mods = { enabled = false },
                  numeric = true,
                  allow_negative = true,
                  allow_decimal = true,
                  lose_focus_on_confirm = true,
                  clear_and_focus_on_right_click = true,
                  handler = {
                    [defines.events.on_gui_text_changed] = handlers.misc_signal_stacks_text_changed,
                    [defines.events.on_gui_confirmed] = handlers.misc_signal_confirm,
                  },
                },
              },
              { type = "label", caption = { "ltnc.label-items" } },
              {
                type = "textfield",
                style = "ltnc_entry_text",
                name = "text_entry__item_fluid",
                elem_mods = { enabled = false },
                numeric = true,
                allow_negative = true,
                allow_decimal = true,
                lose_focus_on_confirm = true,
                clear_and_focus_on_right_click = true,
                handler = {
                  [defines.events.on_gui_text_changed] = handlers.misc_signal_items_text_changed,
                  [defines.events.on_gui_confirmed] = handlers.misc_signal_confirm,
                },
              },
              {
                type = "sprite-button",
                style = "ltnc_confirm_button",
                name = "signal_quantity_confirm",
                elem_mods = { enabled = false },
                mouse_button_filter = { "left" },
                tooltip = confirm_tooltip(player),
                sprite = "utility/check_mark",
                handler = { [defines.events.on_gui_click] = handlers.misc_signal_confirm },
              },
              {
                type = "sprite-button",
                style = "ltnc_cancel_button",
                name = "signal_quantity_cancel",
                elem_mods = { enabled = false },
                mouse_button_filter = { "left" },
                sprite = "utility/reset",
                handler = { [defines.events.on_gui_click] = handlers.misc_signal_cancel },
              },
            },
            { -- Slider
              type = "slider",
              name = "misc_signal_slider",
              elem_mods = { enabled = false },
              style_mods = {
                horizontally_stretchable = true,
                top_margin = 4,
                bottom_margin = 4
              },
              minimum_value = -1,
              maximum_value = 50,
              handler = { [defines.events.on_gui_value_changed] = handlers.misc_signal_slider_changed }
            },
          },
          },
          { type = "line", style_mods = { top_margin = 4, bottom_margin = 4 }},
          { -- Signal Table Label
            type = "label",
            style = "ltnc_header_label",
            caption = { "ltnc.output-signals" }
          },
          { -- Miscellaneous signal table
            type = "frame",
            direction = "vertical",
            style = "slot_button_deep_frame",
            {
              type = "table",
              style = "slot_table",
              column_count = 10,
              children = misc_signal_buttons(config.ltnc_misc_signal_count)
            }
          },
        },
        { -- Spacing
          type = "empty-widget",
          style_mods = { width = 2 },
          visible = true,
        },
        { -- LTN Signal panels
          type = "frame",
          style = "inside_shallow_frame_with_padding",
          direction = "vertical",
          style_mods = { top_padding = 4 },
          visible = true,
          ltn_signal_panel("common"),
          ltn_signal_panel("provider"),
          ltn_signal_panel("requester"),
        }
      }
    }
  })
  return elems
end -- build()
---@diagnostic enable:missing-fields
--#endregion
----------------------------------------------------------------------------------------------------

local function add_to_built_disabled(entity)
  storage.built_disabled = storage.built_disabled or {}
  storage.built_disabled[entity.unit_number] = entity
end -- add_to_built_disabled()

local function remove_from_built_disabled(unit_number)
  local bd = storage.built_disabled
  if bd and bd[unit_number] then
    bd[unit_number] = nil
  end
end -- remove_from_built_disabled()

--- Called to open the combinator UI
--- @param player LuaPlayer
--- @param entity LuaEntity
local function open_gui(player, entity)
  local pt = storage.players[player.index]
  -- Check to see if the player has an LTNC open already.
  if pt.unit_number then
    if pt.unit_number == entity.unit_number then
      -- Player already has this combinator open.  Reset player.opened to the existing UI.
      player.opened = pt.main_elems.ltnc_main_window
      return
    end

    --  Opening a different LTN Combinator, need to first close the existing before opening the new.
    close(player.index)
  end

  --- @type LTNC
  local new_ui = {
    player = player,
    entity = entity,
    control = entity.get_or_create_control_behavior() --[[@as LuaConstantCombinatorControlBehavior]],
    elems = build(player)
  }
  new_ui.elems.entity_preview.entity = new_ui.entity
  new_ui.elems.ltnc_main_window.force_auto_center()
  sort_signals(entity)
  update_ui(new_ui)

  if player.mod_settings["ltnc-show-net-panel"].value then
    toggle_network_config(new_ui, true)
  end

  pt.uis.main = new_ui
  pt.main_elems = new_ui.elems
  pt.unit_number = new_ui.entity.unit_number

  -- Check if this combinator is in the built-disabled alerts and remove
  remove_from_built_disabled(pt.unit_number)

  player.opened = pt.main_elems.ltnc_main_window
end -- open_gui()

--- @param player LuaPlayer
--- @param entity LuaEntity
local function increase_reach(player, entity)
  if player.controller_type ~= defines.controllers.character then
    return
  end

  local pt = storage.players[player.index]
  local new_reach_bonus = flib_position.distance(player.position, entity.position)
  pt.original_reach_bonus = player.character_reach_distance_bonus
  player.character_reach_distance_bonus = new_reach_bonus
end -- increase_reach()

--- @param player LuaPlayer
local function reset_reach(player)
  if player.controller_type ~= defines.controllers.character then
    return
  end

  local pt = storage.players[player.index]
  if not pt.original_reach_bonus then
    return
  end

  player.character_reach_distance_bonus = pt.original_reach_bonus
  pt.original_reach_bonus = nil
end -- reset_reach()

--- Handle opening the custom GUI to replace the builtin one when it opens.
--- @param e EventData.on_gui_opened
local function on_gui_opened(e)
  local player = game.get_player(e.player_index)
  if not player or player.opened_gui_type ~= defines.gui_type.entity then
    return
  end

  local entity = e.entity
    if not entity or not entity.valid or entity.name ~= "ltn-combinator" then
    return
  end

  open_gui(player, entity)
  reset_reach(player)
end -- on_gui_opened()

--- Create the storage data from an existing combinator
--- This will address Pre-2.0 Blueprints that don't have this data in stored tags.
---@param entity LuaEntity
---@return CombinatorData
local function create_storage_data_from_combinator(entity)
  sort_signals(entity)
  local ctl = entity.get_control_behavior()
  --- @cast ctl LuaConstantCombinatorControlBehavior
  --  Save non-zero thresholds into storage
  local cd = get_or_create_combinator_data(entity)
  for _, service in ipairs{ "provider", "requester" } do
    -- If threshold is set to high-threshold, disable the service in storage_data
    local name = "ltn-" .. service .. "-threshold"
    local value = get_ltn_signal_from_control(ctl, name)
    if value == config.high_threshold then
      cd[service] = false
    else
      -- Normalize based on mod-settings (i.e. remove if default value and not storing explicitly)
      set_ltn_signal_by_control(ctl, value.value, name)
    end

    -- Normalize the stack threshold in storage if one exists.
    name = "ltn-" .. service .. "-stack-threshold"
    value = get_ltn_signal_from_control(ctl, name)
    set_ltn_signal_by_control(ctl, value.value, name)
  end

  -- If depot is set, all provider and requester signals are ignored.
  -- Disable requester and provider and clear requester provider signals
  if is_depot(ctl) or is_fuel_station(ctl) then
    toggle_service_by_ctl(ctl, "provider", false)
    toggle_service_by_ctl(ctl, "requester", false)
  end

  return cd
end -- create_storage_data_from_combinator()

--- When building a new entity set defaults according to mod settings
--- @param e BuildEvent
local function on_built(e)
  local entity = e.created_entity or e.entity or e.destination
  if not entity or not entity.valid then
    return
  end

  -- Only care about (ghosts of) LTN Combinators
  local name = entity.name == "entity-ghost" and entity.ghost_name or entity.name
  if name ~= "ltn-combinator" then
    return
  end

  -- Check to see if there was a recently removed LTNC at the same location that needs to have
  -- its configuration restored.
  --   - Upgrade / replace?
  --   - Rotate by robot?
  --   - Undo?
  local pos_int = util.pack_position(entity.position)
  local sreps = storage.replacements[entity.surface_index]
  local rep = sreps and sreps[pos_int] or nil
  --- @type CombinatorData
  local cd = rep and rep.combinator_data or nil

  if entity.name == "entity-ghost" then
    -- do ghostly things
    -- If the ghost already has tags, presume they are correct. (likely from BP)
    if not entity.tags and cd then
      entity.tags = {
        ltnc = cd,
        no_auto_disable = rep.no_auto_disable
      }
    end
  else
    -- do corporeal things
    if e.tags and e.tags.ltnc then
      cd = e.tags.ltnc --[[@as CombinatorData]]
    else
      cd = cd or create_storage_data_from_combinator(entity)
    end
    storage.combinators[entity.unit_number] = cd
  end

  -- Remove any historical combinator data at this location if it existed.
  if sreps then
    sreps[pos_int] = nil
    if not next(sreps) then
      storage.replacements[entity.surface_index] = nil
    end
  end

  -- Don't toggle services when building ghosts or this entity has been tagged
  -- "no_auto_disable" when the ghost was created.
  if entity.name == "entity-ghost"        -- Ghost
  or not e.tags and not rep               -- Just placing item from inventory
  or e.tags and e.tags.no_auto_disable    -- Likely an undo
  or rep and rep.no_auto_disable then     -- Likely an upgrade / fast replace / rotation by robot
    return
  end

  sort_signals(entity)

  -- Disable services based on mod settings
  local build_disable = settings.global["ltnc-disable-built-combinators"].value
  local ctl = entity.get_control_behavior() --[[@as LuaConstantCombinatorControlBehavior]]
  local disabled_something = false
  if build_disable == "off" and ctl.enabled then
    disabled_something = toggle_service_by_ctl(ctl, "combinator", false)
  elseif build_disable == "requester" then
    disabled_something = toggle_service_by_ctl(ctl, "requester", false)
  elseif build_disable == "provider" then
    disabled_something = toggle_service_by_ctl(ctl, "provider", false)
  elseif build_disable == "all" then
    disabled_something = toggle_service_by_ctl(ctl, "provider", false)
    disabled_something = toggle_service_by_ctl(ctl, "requester", false)
  end

  if disabled_something and settings.global["ltnc-alert-build-disable"].value then
    add_to_built_disabled(entity)
  end
end -- on_built()

--- @param e EventData.on_player_setup_blueprint
local function on_player_setup_blueprint(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end

  local bp = e.stack or e.record
  if not bp then
    return
  end

  local entities = bp.get_blueprint_entities()
  if not entities then
    return
  end

  for i, entity in pairs(entities) do
  --- @cast i uint
    if entity.name ~= "ltn-combinator" then
      goto continue
    end

    local real_entity = e.surface.find_entity(entity.name, entity.position)
    if not real_entity then
      goto continue
    end

    -- CD to tags...
    bp.set_blueprint_entity_tag(i, "ltnc", get_or_create_combinator_data(real_entity))
    ::continue::
  end

end -- on_player_setup_blueprint()

local function on_player_removed(e)
  storage.players[e.player_index] = nil
end -- on_player_removed()

--- @param e EventData.on_player_created
local function on_player_created(e)
  local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
  player_data.init(player)
end -- on_player_created()

--- @param e EventData.on_player_joined_game
local function on_player_joined(e)
  local pt = storage.players[e.player_index]
  if pt.uis.main or pt.uis.netui then
    -- bug hunting
    log(string.format("[LTNC] Closing existing LTNC UIs for: %s as they're joining.\n", game.get_player(e.player_index).name))
    close(e.player_index)
  end
end -- on_player_joined()

--- @param e EventData.on_runtime_mod_setting_changed
local function on_settings_changed(e)
  if e.setting_type == "runtime-per-user" then
    player_setting_changed(e.setting, e.player_index)

  else
    runtime_setting_changed(e.setting)
  end
end -- on_settings_changed()

--- Add custom settings from the combinator to storage to track for undo, rotations, and upgrades
---@param entity LuaEntity # LuaEntity making a replacement of
---@param e EventData # Calling event
local function add_replacement(entity, e)
  local rep = {}
  rep.tick = e.tick
  rep.name = entity.name
  rep.pos = entity.position

  if entity.type == "entity-ghost" and entity.ghost_name == "ltn-combinator" then
    rep.name = entity.ghost_name
    if entity.tags then
      rep.combinator_data = entity.tags.ltnc or nil
      rep.no_auto_disable = entity.tags.no_auto_disable or nil
    end

  elseif entity.name == "ltn-combinator" then
    rep.combinator_data = storage.combinators[entity.unit_number]
    rep.no_auto_disable = true

  elseif entity.name == "constant-combinator" then
    --rep.combinator_data = create_storage_data_from_combinator(entity)
    rep.no_auto_disable = true
  end

  local gr = storage.replacements[entity.surface_index] or {}
  gr[util.pack_position(entity.position)] = rep
  storage.replacements[entity.surface_index] = gr
end -- add_replacement()

--- @param e DestroyEvent
local function on_destroy(e)
local entity = e.entity
  if not entity or not entity.valid then
    return
  end

  -- Only interested in (ghosts of) ltn-combinators
  --if name ~= "ltn-combinator" and name ~= "constant-combinator" then
  local name = entity.name
  local unit_number = entity.unit_number
  if entity.type == "entity-ghost" then
    name = entity.ghost_name
    unit_number = entity.ghost_unit_number
  end

  if name ~= "ltn-combinator" then
    return
  end

  add_replacement(entity, e)
  if name ~= "ltn-combinator" or not unit_number then
    return
  end

  -- Close the UI for all players that have this entity open
  for ndx, p in ipairs(storage.players) do
    if p.unit_number == unit_number then
      close(ndx)
    end
  end

  storage.combinators[unit_number] = nil
end -- on_destroy()

--- @param e EventData.on_post_entity_died
local function on_post_died(e)
  if e.prototype.name ~= "ltn-combinator" then
    return
  end

  local ghost = e.ghost
  if not ghost or not ghost.valid or not e.unit_number then
    storage.combinators[e.unit_number] = nil
    return
  end

  ghost.tags = {
    ltnc = storage.combinators[e.unit_number],
    no_auto_disable = true
  }

  storage.combinators[e.unit_number] = nil
end -- on_post_died()

--- @param e EventData.on_entity_settings_pasted
local function on_settings_pasted(e)
  local player = game.get_player(e.player_index)
  if player and player.valid then
    reset_reach(player)
  end

  local source, destination = e.source, e.destination
  if not source.valid or not destination.valid then
    return
  end

  if source.name ~= "ltn-combinator" or destination.name ~= "ltn-combinator" then
    return
  end

  local cd = storage.combinators
  cd[destination.unit_number] = table.deep_copy(cd[source.unit_number])
end -- on_settings_pasted()

---@param e EventData.CustomInputEvent
local function on_linked_paste_settings(e)
  if not e.selected_prototype
  or e.selected_prototype.base_type ~= "entity"
  or e.selected_prototype.name ~= "ltn-combinator" then
    return
  end

  local player = game.get_player(e.player_index)
  if not player or not player.valid
  or not player.entity_copy_source or not player.entity_copy_source.valid
  or player.entity_copy_source.type ~= "constant-combinator"
  or not player.selected
  or not player.selected.valid then
    return
  end

  local dest = player.selected --[[@as LuaEntity]]
  if player.controller_type == defines.controllers.character
  and not player.can_reach_entity(dest) then
    increase_reach(player, dest)
  end
end -- on_linked_paste_settings

--- Handle putting an ltn-combinator ghost down over existing ltn-combinator ghosts
--- or over existing constant-combinators (and ghosts)
--- Handle blueprint copy-pasting
---@param e EventData.on_pre_build
local function on_pre_build(e)
  local player = game.get_player(e.player_index)
  if not player or not player.valid then
    return
  end

  if player.is_cursor_blueprint() then
    local bp = util.get_blueprint(player)

    if not bp then
      return
    end

    local entities = bp.get_blueprint_entities()

    if not entities then
      return
    end

    local combinators = table.filter(
      entities,
      function(v)
        return v.name == "ltn-combinator"
      end,
      false
    )
    if not next(combinators) then
      return
    end

    -- Calculate where blueprint will be stamped down and figure out
    -- if any ltn-combinators will be re-stamped.  Make sure
    -- storage.combinators data get updated accordingly.
    local bp_box, grid_size = util.get_blueprint_bounding_box(entities)
    local bp_center = flib_box.center(bp_box)
    local center = util.get_placed_blueprint_center(bp_box, e.position, grid_size)
    local offset = flib_position.sub(bp_center, center)
    local surface = player.surface
    for _, c in pairs(combinators) do
      local dest_positions = flib_position.sub(c.position, offset)
      -- TODO: Based on e.direction and e.flipped...  Adjust position
      local existing_entity = surface.find_entity(
        "ltn-combinator",
        dest_positions
      )
      if existing_entity then
        if not c.tags then
          -- This BP is broken - Likely from selecting new contents for a Blueprint
          -- that was in the Blueprint Library
          -- https://forums.factorio.com/viewtopic.php?f=182&t=88100
          -- Attempt to make the resulting combinator less broken
          log("[LTNC] Pasted over existing combinator with broken Blueprint.  https://forums.factorio.com/viewtopic.php?f=182&t=88100\n")
          c.tags = {
            ltnc = create_storage_data_from_combinator(existing_entity)
          }
        end
        storage.combinators[existing_entity.unit_number] = c.tags.ltnc --[[@as CombinatorData]]
      end
    end

    return
  end

  local entities = {}
  local cs = player.cursor_stack
  if cs and cs.valid and cs.valid_for_read and cs.name == "ltn-combinator" then
    if not e.shift_build then
      goto constant_only
    end
  else
    cs = nil
  end

  if not cs and not player.cursor_ghost and player.cursor_ghost ~= "ltn-combinator" then
    return
  end

  -- For ltn-combinator ghosts need to handle a change in rotation so the tags don't get lost
  entities = player.surface.find_entities_filtered{
    position = e.position,
    ghost_name = "ltn-combinator"
  }

  if next(entities) then
    if entities[1].ghost_name == "ltn-combinator" then
      entities[1].direction = e.direction
    end

    return
  end

  ::constant_only::
  entities = player.surface.find_entities_filtered{
    position = e.position,
    name = "constant-combinator"
  }
  if next(entities) and entities[1].name == "constant-combinator" then
    add_replacement(entities[1], e)
  end
end -- on_pre_build()

---
---@param e EventData.on_gui_closed
local function on_closed(e)
  local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
  if e.gui_type == defines.gui_type.item
  and e.item
  and e.item.is_blueprint
  and e.item.is_blueprint_setup()
  and player.cursor_stack
  and player.cursor_stack.valid_for_read
  and player.cursor_stack.is_blueprint
  and not player.cursor_stack.is_blueprint_setup()
  then
    storage.previous_opened_blueprint_for[e.player_index] = {
      blueprint = e.item,
      tick = e.tick
    }
  else
    storage.previous_opened_blueprint_for[e.player_index] = nil
  end
end -- on_closed()

--- @class LTNC
--- @field player LuaPlayer Player operating this UI
--- @field entity LuaEntity
--- @field control LuaConstantCombinatorControlBehavior
--- @field elems table<string, LuaGuiElement>
local ltnc = {}

function ltnc.on_init()
  storage_data.init()
  for _, player in pairs(game.players) do
    player_data.init(player)
  end

  for k, _ in pairs(ltn_setting_to_signal) do
    runtime_setting_changed(k)
  end
end -- on_init()

function ltnc.on_load()
  for k, _ in pairs(ltn_setting_to_signal) do
    runtime_setting_changed(k)
  end
  -- Bug hunting
  for i, pt in pairs(storage.players) do
    if pt.uis.main then
      local ws = pt.working_slot and pt.working_slot.index or nil
      local unit = pt.unit_number
      local logstring =
        string.format(
          "[LTNC] Player index %d has an LTNC UI open in storage. Unit: %s, WS: %s\n",
          i, tostring(unit), tostring(ws)
        )
      log(logstring)
    end
  end
end -- on_load()

--- Find closest LTN combinator on a circuit network attached to this entity
--- @param entity LuaEntity # Target entity to begin search for connected combinator
--- @return LuaEntity? # The LTN Combinator or nil if none found within max_depth
local function find_attached_ltn_combinator(entity)

  if not entity or not entity.valid then
    return
  end

  local first_entity = {[entity.unit_number] = entity}
  return util.find_connected_entity("ltn-combinator", first_entity, 10)
end -- find_attached_ltn_combinator()

function ltnc.add_commands()
  commands.add_command("ltnc-unset-requester", {"ltnc.unset-requester-help"}, function()
    local entities = {}
    for _, surface in pairs(game.surfaces) do
      entities = table.array_merge({entities, surface.find_entities_filtered({name = "ltn-combinator"})})
    end
    for _, entity in ipairs(entities) do
      local ctl = entity.get_control_behavior() --[[@as LuaConstantCombinatorControlBehavior]]
      for i = config.ltnc_ltn_signal_count + 1, config.ltnc_slot_count do
        --- @cast i uint
        local signal = ctl.get_signal(i)
        if signal.signal and signal.count < 0 then
          goto continue
        end
      end

      toggle_service_by_ctl(ctl, "requester", false)
      ::continue::
    end
  end)
end -- add_commands()

--- Open closest combinator to the supplied entity found on an attached circuit network
--- @param player_index uint
--- @param entity LuaEntity
--- @param register boolean? # Currently not implemented
--- @return boolean
local function remote_open_gui(player_index, entity, register)
  if not entity or not entity.valid or entity.type == "entity-ghost" then
    return false
  end

  local player = game.get_player(player_index)
  if not player or not player.valid then
    return false
  end

  local combinator = find_attached_ltn_combinator(entity)
  if not combinator or not combinator.valid then
    return false
  end

  open_gui(player, combinator)
  return true
end -- remote_open_gui()

function ltnc.add_remote_interface()
  remote.add_interface("ltn-combinator", {
    -- Usage: result = remote.call("ltn-combinator", "open_ltn_combinator", player_index (integer), entity (LuaEntity), register (boolean))
    --  player_index: (required)
    --  entity: any entity that is in the same green-circuit-network as the wanted ltn-combinator (required)
    --  register: registers the opened window in game.player[i].opened (optional, default true)
    --  returns a boolean, whether a combinator was opened
    open_ltn_combinator = remote_open_gui,
    -- Usage: result = remote.call("ltn-combinator", "close_ltn_combinator", player_index (integer))
    --  player_index: (required)
    --
    --  Calling this interface is only required if a ltn-combinator was previously opened with register = false.
    --  Use this method to keep your own window open.
    close_ltn_combinator = close
  })
end -- add_remote_interfaces()

ltnc.on_nth_tick = {
  [180] = function() -- 3 Seconds
    if not storage.built_disabled then
      return
    end

    for i, entity in pairs(storage.built_disabled) do
      --- @cast entity LuaEntity
      if not entity.valid then
        storage.built_disabled[i] = nil
        goto continue
      end

      for _, player in ipairs(entity.force.players) do
        player.add_custom_alert(
          entity,
          { name = "ltn-combinator", type = "item" },
          { "ltnc-alerts.built" },
          true
        )
      end

    ::continue::
    end

    if not next(storage.built_disabled) then
      storage.built_disabled = nil
    end
  end,

  [18000] = function () -- 5 minutes
    -- Cleanup replacements in storage
    if not next(storage.replacements) then
      return
    end
    
    for surface_index, reps in pairs(storage.replacements) do
      for pos_int, rep in pairs(reps) do
        local tick = game.tick
        if tick - rep.tick > 216000 then -- 1 hour
          reps[pos_int] = nil
          dlog(string.format("Removed pos: %d\n", pos_int))
        end
      end

      if not next(reps) then
        storage.replacements[surface_index] = nil
        dlog(string.format("Removed surface: %d\n", surface_index))
      end
    end
  end
}

ltnc.events = {
  [defines.events.on_player_setup_blueprint] = on_player_setup_blueprint,
  [defines.events.on_runtime_mod_setting_changed] = on_settings_changed,
  [defines.events.on_entity_settings_pasted] = on_settings_pasted,
  [defines.events.on_gui_opened] = on_gui_opened,
  [defines.events.on_player_removed] = on_player_removed,
  [defines.events.on_player_created] = on_player_created,
  [defines.events.on_player_joined_game] = on_player_joined,
  --  Need this to overcome https://forums.factorio.com/viewtopic.php?f=7&t=106710
  [defines.events.on_pre_build] = on_pre_build,
  [defines.events.on_built_entity] = on_built,
  [defines.events.on_entity_cloned] = on_built,
  [defines.events.on_robot_built_entity] = on_built,
  [defines.events.script_raised_built] = on_built,
  [defines.events.script_raised_revive] = on_built,
  [defines.events.on_robot_mined_entity] = on_destroy,
  [defines.events.on_player_mined_entity] = on_destroy,
  [defines.events.script_raised_destroy] = on_destroy,
  [defines.events.on_post_entity_died] = on_post_died,
  ["ltnc-linked-paste-settings"] = on_linked_paste_settings,
  [defines.events.on_gui_closed] = on_closed,
}

return ltnc
