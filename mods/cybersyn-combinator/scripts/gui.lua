local constants = require "scripts.constants"
local config = require "scripts.config"
local log = require("scripts.logger").gui
local cc_util = require "scripts.cc_util"
local masking = require "scripts.masking"
local expression = require "scripts.expression"
local CybersynCombinator = require "scripts.combinator"
local util = require "__core__.lualib.util"
local flib_gui = require "__flib__.gui"

local ceil = math.ceil
local floor = math.floor
local gsub = string.gsub

--- @param num number
--- @return number
local function round(num) return floor(num + 0.5) end

--- @param count number
--- @return string
local function format_signal_count(count)
  local formatted = util.format_number(count, true)
  local trimmed = gsub(formatted, "(%d%d%d)[%.,]%d+", "%1")
  return trimmed
end

local WINDOW_ID = "cybersyn-constant-combinator-window"
local DIMMER_ID = "cybersyn-constant-combinator-dimmer"
local ENCODER_ID = "cybersyn-constant-combinator-encoder"
local DESC_EDIT_ID = "cybersyn-constant-combinator-description-edit"
local LOGI_GROUP_EDIT_ID = "cybersyn-constant-combinator-logistic-group-edit"

local DIALOG_IDS = {
  [ENCODER_ID] = true,
  [DESC_EDIT_ID] = true,
  [LOGI_GROUP_EDIT_ID] = true
}

local RED = "utility/status_not_working"
local GREEN = "utility/status_working"
local YELLOW = "utility/status_yellow"
local STATUS_SPRITES = {
  [defines.entity_status.working] = GREEN,
  [defines.entity_status.normal] = GREEN,
  [defines.entity_status.ghost] = YELLOW,
  [defines.entity_status.no_power] = RED,
  [defines.entity_status.low_power] = YELLOW,
  [defines.entity_status.disabled_by_control_behavior] = RED,
  [defines.entity_status.disabled_by_script] = RED,
  [defines.entity_status.marked_for_deconstruction] = RED
}
local DEFAULT_STATUS_SPRITE = RED
local GHOST_STATUS_SPRITE = YELLOW
local STATUS_NAMES = {
  [defines.entity_status.working] = { "entity-status.working" },
  [defines.entity_status.normal] = { "entity-status.normal" },
  [defines.entity_status.ghost] = { "entity-status.ghost" },
  [defines.entity_status.no_power] = { "entity-status.no-power" },
  [defines.entity_status.low_power] = { "entity-status.low-power" },
  [defines.entity_status.disabled_by_control_behavior] = { "entity-status.disabled" },
  [defines.entity_status.disabled_by_script] = { "entity-status.disabled-by-script" },
  [defines.entity_status.marked_for_deconstruction] = { "entity-status.marked-for-deconstruction" }
}
local DEFAULT_STATUS_NAME = { "entity-status.disabled" }
local GHOST_STATUS_NAME = { "entity-status.ghost" }

local SLOT_BUTTON_STYLE = "cybersyn-combinator_signal-button"
local SLOT_BUTTON_PRESSED_STYLE = "cybersyn-combinator_signal-button_pressed"
-- local SLOT_BUTTON_DISABLED_STYLE = "cybersyn-combinator_signal-button_disabled"
-- local SLOT_BUTTON_DISABLED_PRESSED_STYLE = "cybersyn-combinator_signal-button_disabled_pressed"
local SLOT_BUTTON_DISABLED_STYLE = SLOT_BUTTON_STYLE
local SLOT_BUTTON_DISABLED_PRESSED_STYLE = SLOT_BUTTON_PRESSED_STYLE

local BIT_BUTTON_STYLE = "cybersyn-combinator_encoder_bit-button"
local BIT_BUTTON_PRESSED_STYLE = "cybersyn-combinator_encoder_bit-button_pressed"

--- @param pressed boolean
local function bit_button_style(pressed)
  return pressed and BIT_BUTTON_PRESSED_STYLE or BIT_BUTTON_STYLE
end

local SLOT_COL_COUNT = 10
local MAX_SLOT_COUNT = 1000

---@param filter_count integer
---@return integer
local function calc_slot_rows(filter_count)
  return math.floor(filter_count / SLOT_COL_COUNT) + 1
end

---@param section LuaLogisticSection
local function calc_slot_count(section)
  local filter_count = section.filters_count
  local slot_rows = calc_slot_rows(filter_count)
  if slot_rows > MAX_SLOT_COUNT then return MAX_SLOT_COUNT end
  return slot_rows * SLOT_COL_COUNT
end

local handlers = {}

local cc_gui = {
  WINDOW_ID = WINDOW_ID,
  ENCODER_ID = ENCODER_ID
}

--- @class SignalEntry
--- @field button LuaGuiElement

--- @class NetworkMaskState
--- @field section_group_checkbox LuaGuiElement
--- @field list LuaGuiElement
--- @field signal_button LuaGuiElement
--- @field textfield LuaGuiElement
--- @field add_button LuaGuiElement
--- @field signal Signal?
--- @field mask integer?
--- @field slot integer?

--- @class EncoderState
--- @field dialog LuaGuiElement?
--- @field signal_button LuaGuiElement
--- @field textfield LuaGuiElement
--- @field bit_buttons LuaGuiElement
--- @field mask integer?
--- @field display_dec LuaGuiElement
--- @field display_hex LuaGuiElement
--- @field display_bin LuaGuiElement
--- @field display_oct LuaGuiElement
--- @field confirm_button LuaGuiElement

--- @class DescriptionEditState
--- @field dialog LuaGuiElement?
--- @field textfield LuaGuiElement

--- @class LogisticGroupEditState
--- @field dialog LuaGuiElement?
--- @field section LuaLogisticSection
--- @field search_textfield LuaGuiElement.add_param.textfield
--- @field search_button LuaGuiElement.add_param.button
--- @field group_name_textfield LuaGuiElement.add_param.textfield
--- @field group_multiplier_textfield LuaGuiElement.add_param.textfield
--- @field group_confirm_button LuaGuiElement.add_param.button
--- @field group_list LuaGuiElement
--- @field confirmed boolean

--- @class UiState
--- @field main_window LuaGuiElement
--- @field status_sprite LuaGuiElement
--- @field status_label LuaGuiElement
--- @field entity_preview LuaGuiElement
--- @field cs_signals_group_checkbox LuaGuiElement.add_param.checkbox
--- @field on_off LuaGuiElement
--- @field item_total_label LuaGuiElement
--- @field item_stacks_label LuaGuiElement
--- @field fluid_total_label LuaGuiElement
--- @field signal_value_stacks LuaGuiElement
--- @field signal_value_items LuaGuiElement
--- @field signal_value_confirm LuaGuiElement
--- @field entity LuaEntity
--- @field combinator CybersynCombinator
--- @field section_container LuaGuiElement
--- @field selected_section_index integer?
--- @field selected_slot uint?
--- @field selected_slot_button LuaGuiElement?
--- @field stack_size integer?
--- @field network_mask NetworkMaskState
--- @field add_description_button LuaGuiElement.add_param.button
--- @field description_header LuaGuiElement.add_param.flow
--- @field description_scroll LuaGuiElement.add_param.scroll_pane
--- @field description_label LuaGuiElement
--- @field dialog_close_clicked boolean
--- @field dimmer LuaGuiElement?
--- @field encoder EncoderState?
--- @field description_edit DescriptionEditState?
--- @field logistic_group_edit LogisticGroupEditState?

--- @param player_index PlayerIdentification?
--- @return UiState?
local function get_player_state(player_index)
  if not player_index then return nil end
  local data = cc_util.get_player_data(player_index)
  if not data then return nil end
  return data.state --[[@as UiState?]]
end

--- @param player_index uint
--- @param state UiState
local function set_player_state(player_index, state)
  local data = cc_util.get_player_data(player_index)
  if not data then
    log:error("failed to get player data table for player ", player_index, " for writing state")
    return -- TODO: Throw error?
  end
  data.state = state
end

--- @param player_index integer
--- @return { name: string, count: number? }[]
local function get_logistic_groups(player_index)
  local no_group = "[No group assigned]"
  local player_data = cc_util.get_player_data(player_index)
  if player_data and player_data.translations then
    no_group = player_data.translations["gui-train.empty-train-group"] or no_group
  end
  local result = {
    { name = no_group }
  }

  local player = game.get_player(player_index)

  if not player or not player.valid then return result end

  -- always LuaForce when reading
  local force = player.force --[[@as LuaForce]]

  if not force.valid then return result end

  local api_groups = force.get_logistic_groups()

  for _, api_group_name in pairs(api_groups) do
    local api_group = force.get_logistic_group(api_group_name)
    log:debug(serpent.line(api_group))
    -- local count = 0
    -- for _, section in pairs(api_group.members) do
    --   log:debug("member ", count, "( ", section.index, ")")
    --   count = count + 1
    -- end
    local count = #api_group.members
    table.insert(result, { name = api_group_name, count = count })
  end

  return result
end

---@param section LuaLogisticSection
---@return string|LocalisedString
local function create_logistic_section_caption(section)
  local group_active = section.active
  ---@type string|LocalisedString?
  local group = section.group
  local multiplier = section.multiplier

  if not group or group == "" then
    group = { "gui-train.empty-train-group" }
  end

  local caption = group

  if multiplier ~= 1 then
    caption = { "description.creates-number-entities-value", group, multiplier }
  end

  return caption
end

--- @param player LuaPlayer
--- @param window_id string
--- @return boolean
local function destroy(player, window_id)
  local screen = player.gui.screen
  if window_id == DIMMER_ID then
    local state = get_player_state(player)
    if state then state.dimmer = nil end
  end
  if not screen[window_id] then
    log:debug("destroy called on ", window_id, " but it doesn't exist")
    return false
  end
  screen[window_id].destroy()
  log:debug("destroyed ", window_id)
  return true
end

--- @param element LuaGuiElement
--- @param player PlayerIdentification?
--- @param fallback number?
--- @return number?
local function resolve_textfield_number(element, player, fallback)
  if not element or not element.text then return nil end
  local min = tonumber(element.tags.min) or constants.INT32_MIN
  local max = tonumber(element.tags.max) or constants.INT32_MAX
  local enable_expressions = false
  if player then
    enable_expressions = settings.get_player_settings(player)[constants.SETTINGS.ENABLE_EXPRESSIONS].value == true
  end

  --- @type number?
  local value

  if enable_expressions then
    value = expression.parse(element.text, fallback)
  else
    value = tonumber(element.text) or fallback
  end

  if not value then return nil end

  if value < 0 and element.tags.allow_negative == false then
    value = 0
  end

  if element.tags.allow_decimal == false then
    value = round(value)
  end

  return util.clamp(value, min, max)
end

--- @param state UiState
local function update_totals(state)
  if not state then return end

  local item_request_total = 0
  local item_request_stacks = 0
  local fluid_request_total = 0

  for section_index, section in state.combinator:iter_item_sections() do
    local slot_count = section.filters_count

    for slot = 1, slot_count do
      local signal = state.combinator:get_item_slot(section_index, slot --[[@as uint]])
      if signal and signal.signal then
        if signal.signal.type == "item" and signal.count < 0 then
          local stack_size = prototypes.item[signal.signal.name].stack_size
          local stacks = math.floor(signal.count / stack_size)
          item_request_total = item_request_total + signal.count
          item_request_stacks = item_request_stacks + stacks
        elseif signal.signal.type == "fluid" and signal.count < 0 then
          fluid_request_total = fluid_request_total + signal.count
        end
      end
    end
  end

  item_request_total = math.abs(item_request_total)
  item_request_stacks = math.abs(item_request_stacks)
  fluid_request_total = math.abs(fluid_request_total)
  state.item_total_label.caption = format_signal_count(item_request_total)
  state.item_total_label.tooltip = util.format_number(item_request_total, false)
  state.item_stacks_label.caption = format_signal_count(item_request_stacks)
  state.item_stacks_label.tooltip = util.format_number(item_request_stacks, false)
  state.fluid_total_label.caption = format_signal_count(fluid_request_total)
  state.fluid_total_label.tooltip = util.format_number(fluid_request_total, false)
end

--- @param state UiState
local function update_cs_signals(state)
  local section = state.combinator:get_or_create_section(CybersynCombinator.CYBERSYN_SECTION_ID)
  if section then
    state.cs_signals_group_checkbox.state = section.active
    local caption = create_logistic_section_caption(section)
    state.cs_signals_group_checkbox.caption = caption
    state.cs_signals_group_checkbox.tooltip = caption
  end
  for name, data in pairs(config.cs_signals) do
    local value = state.combinator:get_cs_value(name)
    local default = data.default
    if settings.global[name] and settings.global[name].value then
      default = settings.global[name].value --[[@as number]]
    end
    local element = state[name]
    local reset = state[name .. "_reset"]
    if element then
      element.text = tostring(value)
    end
    if reset then
      reset.enabled = value ~= default
    end
  end
end

-- - @param event EventData.on_gui_click|EventData.on_gui_elem_changed
--- @param state UiState
--- @param player_index string|integer
local function change_signal_count(state, player_index)
  local section_index = state.selected_section_index
  local slot = state.selected_slot
  local signal = state.combinator:get_item_slot(section_index, slot)
  if not signal or not signal.signal then
    cc_gui:close(player_index)
    return
  end

  local signal_type = signal.signal.type
  local signal_name = signal.signal.name

  local value = signal.count
  log:debug("change_signal_count: signal type is ", signal_type, ", name is ", signal_name)

  local focus_stacks = false

  state.signal_value_items.enabled = true
  state.signal_value_items.text = tostring(value)
  state.signal_value_confirm.enabled = true

  if signal_type == "item" or signal_type == "fluid" then
    --- @type integer
    local stack_size
    if signal_type == "item" then
      stack_size = prototypes.item[signal_name].stack_size
      state.signal_value_stacks.enabled = true
      if settings.get_player_settings(player_index)[constants.SETTINGS.USE_STACKS].value then
        focus_stacks = true
      end
    elseif signal_type == "fluid" then
      stack_size = 1
      state.signal_value_stacks.enabled = false
    end
    local stacks = value / stack_size
    state.signal_value_stacks.text = tostring(stacks >= 0 and ceil(stacks) or floor(stacks))
    state.stack_size = stack_size
  else
    state.signal_value_stacks.enabled = false
    state.stack_size = 1
  end

  if focus_stacks then
    state.signal_value_stacks.focus()
    state.signal_value_stacks.select_all()
  else
    state.signal_value_items.focus()
    state.signal_value_items.select_all()
  end
end


--- @param element LuaGuiElement
--- @param player PlayerIdentification?
--- @param update_element boolean
local function set_cs_signal_value(element, player, update_element)
  local state = get_player_state(player)
  if not state then return end
  local signal_name = element.tags.signal_name --[[@as string]]
  local current = state.combinator:get_cs_value(signal_name)
  local value = resolve_textfield_number(element, player, current)
  if value then
    log:debug("cs_signal_value_changed: ", signal_name, " changed to ", value)
  else
    log:debug("cs_signal_value_changed: invalid new value, resetting to current (", current, ")")
    value = current
  end
  if not value then return end
  local min = constants.INT32_MIN
  local max = constants.INT32_MAX
  if config.cs_signals[signal_name] then
    min = config.cs_signals[signal_name].min
    max = config.cs_signals[signal_name].max
  end
  value = util.clamp(value, min, max)
  state.combinator:set_cs_value(signal_name, value)
  local default = config.cs_signals[signal_name].default
  if settings.global[signal_name] and settings.global[signal_name].value then
    default = settings.global[signal_name].value --[[@as number]]
  end
  local is_default = value == default
  local reset = state[signal_name .. "_reset"]
  if reset then reset.enabled = not is_default end
  if update_element then element.text = tostring(value) end
end

--- @param player PlayerIdentification?
--- @param state UiState?
local function refresh_network_list(player, state)
  if not state then return end
  local list = state.network_mask.list
  list.clear()
  local section = state.combinator:get_or_create_section(CybersynCombinator.NETWORK_SECTION_ID)
  if section then
    local group_checkbox = state.network_mask.section_group_checkbox
    group_checkbox.state = section.active
    local caption = create_logistic_section_caption(section)
    group_checkbox.caption = caption
    group_checkbox.tooltip = caption
  end
  local signals = state.combinator:get_network_signals()
  for slot, signal in ipairs(signals) do
    local mask = signal.count
    local formatted_mask = masking.format(mask, player, true)
    local rich_type = signal.signal.type == "virtual" and "virtual-signal" or signal.signal.type
    ---@diagnostic disable-next-line: undefined-field
    local quality = signal.signal.quality or "normal"
    local rich = "[" .. rich_type .. "=" .. signal.signal.name .. ",quality=" .. quality .. "] " .. formatted_mask
    local dec = masking.format_explicit(mask, masking.Mode.DECIMAL, false, true)
    local hex = masking.format_explicit(mask, masking.Mode.HEX, false, true)
    local bin = masking.format_explicit(mask, masking.Mode.BINARY, false, true)
    local oct = masking.format_explicit(mask, masking.Mode.OCTAL, false, true)
    flib_gui.add(list, {
      type = "button",
      style = "cybersyn-combinator_network-list_item",
      caption = rich,
      tooltip = { "cybersyn-combinator-window.network-list-item-tooltip", dec, hex, bin, oct },
      handler = {
        [defines.events.on_gui_click] = handlers.network_list_item_click
      },
      tags = {
        slot = slot,
        mask = mask,
        signal_type = signal.signal.type,
        signal_name = signal.signal.name
      }
    })
  end
end

--- @param state UiState?
local function focus_network_mask_input(state)
  if not state then return end
  state.network_mask.textfield.focus()
  state.network_mask.textfield.select_all()
end

--- @param player PlayerIdentification?
--- @param state UiState?
local function add_network_mask(player, state)
  if not state then return end
  local signal = state.network_mask.signal
  if not signal or signal.count == 0 then return end
  local rich_type = signal.signal.type == "virtual" and "virtual-signal" or signal.signal.type
  local mask = signal.count
  local formatted_mask = masking.format(mask, player)
  local rich = "[" .. rich_type .. "=" .. signal.signal.name .. "] " .. formatted_mask
  log:debug("result rich text: ", rich)

  state.combinator:add_or_update_network_signal(signal)
  refresh_network_list(player, state)

  state.network_mask.signal_button.elem_value = nil
  state.network_mask.signal = nil
  state.network_mask.add_button.enabled = false
end

--- @param event EventData.on_gui_click
function handlers.close(event)
  log:debug("close button clicked")
  cc_gui:close(event.player_index)
end

--- @param event EventData.on_gui_click
function handlers.dialog_close(event)
  log:debug("dialog close button clicked")
  local player = game.get_player(event.player_index)
  local state = get_player_state(event.player_index)
  if not state then return end
  state.dialog_close_clicked = true
  if state.main_window then
    player.opened = state.main_window
  end
end

---@type fun(state: UiState, reset: boolean, reset_section_index: integer?, deleted_group: string?, updated_group: string?)
local update_signal_sections

---@type fun(state: UiState, signal_table: LuaGuiElement, reset: boolean?)
local update_signal_table

--- @param event EventData.on_gui_switch_state_changed
function handlers.on_off(event)
  local element = event.element
  if not element then return end
  local enabled = element.switch_state == "right"
  local state = get_player_state(event.player_index)
  if not state then return end
  log:debug("combinator switch changed to ", enabled)
  state.combinator:set_enabled(enabled)
  local status = state.entity.status
  local is_ghost = state.entity.name == "entity-ghost"
  state.status_sprite.sprite = is_ghost and GHOST_STATUS_SPRITE or STATUS_SPRITES[status] or DEFAULT_STATUS_SPRITE
  state.status_label.caption = is_ghost and GHOST_STATUS_NAME or STATUS_NAMES[status] or DEFAULT_STATUS_NAME
  update_signal_sections(state, false, nil, nil, nil)
end

--- @param event EventData.on_gui_elem_changed
function handlers.signal_changed(event)
  local element = event.element
  local state = get_player_state(event.player_index)
  if not state then return end
  local section_index = element.tags.section_index --[[@as integer]]
  local section = state.combinator:get_item_section(section_index)
  if not section then return end
  local slot = element.tags.slot --[[@as uint]]
  local signal = { signal = element.elem_value, count = 0 }
  if not signal.signal then return end
  if not cc_util.is_valid_output_signal(signal) then
    element.elem_value = nil
    element.style = SLOT_BUTTON_STYLE
    local player = game.get_player(event.player_index)
    if not player then return end
    player.play_sound { path = constants.CANNOT_BUILD_SOUND }
    player.print({ "cybersyn-combinator-window.invalid-signal" })
    return
  end
  local is_dupe, orig_slot = state.combinator:has_item_signal(signal.signal, section_index, slot)
  if is_dupe then
    element.elem_value = nil
    element.style = SLOT_BUTTON_STYLE
    local player = game.get_player(event.player_index)
    if not player then return end
    player.play_sound { path = constants.CANNOT_BUILD_SOUND }
    player.create_local_flying_text({ text = { "gui-logistic-section.conflict-error", orig_slot }, create_at_cursor = true })
    player.print({ "gui-logistic-section.conflict-error", orig_slot })
    return
  end
  log:debug("elem changed in section", section_index, ", slot ", slot, ": ", serpent.line(element.elem_value))
  if state.selected_slot_button and state.selected_slot_button.valid then
    state.selected_slot_button.style = SLOT_BUTTON_STYLE
  end
  state.selected_section_index = section_index
  state.selected_slot = slot
  state.selected_slot_button = element
  state.combinator:set_item_slot(section_index, slot, signal)
  element.locked = true
  element.style = SLOT_BUTTON_PRESSED_STYLE
  element.label.caption = "0"
  change_signal_count(state, event.player_index)
end

--- @param event EventData.on_gui_click
function handlers.signal_click(event)
  local element = event.element
  local state = get_player_state(event.player_index)
  if not state then return end
  local combinator = state.combinator
  local section_index = element.tags.section_index --[[@as integer]]
  local slot = element.tags.slot --[[@as uint]]
  local section = combinator:get_item_section(section_index)
  if not section then return end
  local total_count = section.filters_count
  local active = section.active
  log:debug("signal click on slot ", slot, " in section ", section_index, ": ", element.elem_value)

  if event.button == defines.mouse_button_type.right then
    state.combinator:remove_item_slot(section_index, slot)
    element.locked = false
    element.elem_value = nil
    element.label.caption = ""
    element.style = SLOT_BUTTON_STYLE
    if state.selected_section_index == section_index and state.selected_slot == slot then
      state.signal_value_stacks.enabled = false
      state.signal_value_items.enabled = false
      state.signal_value_confirm.enabled = false
    end
    if state.selected_slot_button == element then
      state.selected_slot_button = nil
      state.selected_section_index = nil
      state.selected_slot = nil
    end
    if slot == total_count then
      for _, section_element in pairs(state.section_container.children) do
        if section_element.tags.section_index == section_index then
          update_signal_table(state, section_element.signal_table, true)
          break
        end
      end
    else
      update_totals(state)
    end
    if section.group ~= "" then
      update_signal_sections(state, false, nil, nil, section.group)
    end
  elseif event.button == defines.mouse_button_type.left then
    state.selected_section_index = nil
    state.selected_slot = nil
    if state.selected_slot_button and state.selected_slot_button.valid then
      state.selected_slot_button.style = SLOT_BUTTON_STYLE
    end
    state.selected_slot_button = nil
    state.signal_value_stacks.enabled = false
    state.signal_value_items.enabled = false
    state.signal_value_confirm.enabled = false
    if element.elem_value then
      state.selected_section_index = section_index
      state.selected_slot = slot
      state.selected_slot_button = element
      element.style = active and SLOT_BUTTON_PRESSED_STYLE or SLOT_BUTTON_DISABLED_PRESSED_STYLE
      change_signal_count(state, event.player_index)
    end
  end
end

--- @param event EventData.on_gui_text_changed
function handlers.signal_value_changed(event)
  local element = event.element
  local state = get_player_state(event.player_index)
  if not state then return end
  local value = resolve_textfield_number(element, event.player_index)
  if not value then
    state.signal_value_confirm.enabled = false
    return
  end
  log:debug("value of ", element.name, " changed to : ", value)
  state.signal_value_confirm.enabled = true
  if element.name == "signal_value_items" then
    local stack_size = state.stack_size
    if state.stack_size == nil then
      -- Try to recover stack size
      if state.selected_section_index == nil or state.selected_slot == nil then
        log:error("Unexpected nil values in handlers.signal_value_changed while handling change in ", element.name, " please tell a developer")
        return
      end
      log:warn("stack size for current selection unexpectedly nil")
      local combi_sig = state.combinator:get_item_slot(state.selected_section_index, state.selected_slot)
      if combi_sig.signal.type == "item" then
        stack_size = prototypes.item[combi_sig.signal.name].stack_size
      else
        stack_size = 1
      end
    end
    local stack = value / stack_size
    state.signal_value_stacks.text = tostring(stack >= 0 and ceil(stack) or floor(stack))
  elseif element.name == "signal_value_stacks" then
    state.signal_value_items.text = tostring(value * state.stack_size)
  end
end

--- @param player_index uint
--- @param state UiState
--- @param value integer
--- @param clear_selected boolean
local function set_new_signal_value(player_index, state, value, clear_selected)
  local player = game.get_player(player_index)
  local new_value = util.clamp(value, constants.INT32_MIN, constants.INT32_MAX)
  local convert = settings.get_player_settings(player_index)[constants.SETTINGS.NEGATIVE_SIGNALS].value == true
  local current = state.combinator:get_item_slot(state.selected_section_index, state.selected_slot)
  if convert and current.signal.type ~= "virtual" and new_value > 0 then
    new_value = -new_value
  end
  local success, error_msg = state.combinator:set_item_slot_value(state.selected_section_index, state.selected_slot, new_value)

  if not success and player and player.valid then
    player.play_sound { path = constants.CANNOT_BUILD_SOUND }
    player.create_local_flying_text({ text = error_msg, create_at_cursor = true })
    player.print(error_msg)
  end

  state.signal_value_items.enabled = false
  state.signal_value_stacks.enabled = false
  state.signal_value_confirm.enabled = false

  if success then
    state.signal_value_items.text = tostring(new_value)
    if state.stack_size then
      local stacks = value / state.stack_size
      state.signal_value_stacks.text = tostring(stacks >= 0 and ceil(stacks) or floor(stacks))
    end
    state.selected_slot_button.label.caption = format_signal_count(new_value)
  end
  local section_index = state.selected_slot_button.tags.section_index --[[@as integer]]
  local section = state.combinator:get_item_section(section_index) --state.combinator:get_section_by_index(section_index)
  local slot = state.selected_slot
  local total_slots = section and section.filters_count or nil
  if clear_selected then
    state.selected_section_index = nil
    state.selected_slot = nil
    state.selected_slot_button = nil
  end
  state.stack_size = nil
  if not success then return end
  if slot == total_slots then
    for _, section_element in pairs(state.section_container.children) do
      if section_element.tags.section_index == section_index then
        update_signal_table(state, section_element.signal_table, true)
        break
      end
    end
  else
    update_totals(state)
  end
  if section and section.group ~= "" then
    update_signal_sections(state, false, nil, nil, section.group)
  end
end

--- @param event EventData.on_gui_confirmed
function handlers.signal_value_confirmed(event)
  local state = get_player_state(event.player_index)
  if not state or not state.selected_section_index or not state.selected_slot then return end
  local slot_button = state.selected_slot_button
  if slot_button then slot_button.style = "flib_slot_button_default" end
  local current = state.combinator:get_item_slot(state.selected_section_index, state.selected_slot)
  local value = resolve_textfield_number(state.signal_value_items, event.player_index, current.count or 0)
  if not value then
    if current and current.count then
      state.signal_value_items.text = tostring(current.count)
      if state.stack_size then
        local stacks = current.count / state.stack_size
        state.signal_value_stacks.text = tostring(stacks >= 0 and ceil(stacks) or floor(stacks))
      end
    end
    state.signal_value_confirm.enabled = false
    return
  end
  set_new_signal_value(event.player_index, state, value, true)
end

--- @param player_index integer
--- @param state UiState?
--- @param clear_selected boolean
local function confirm_signal_value(player_index, state, clear_selected)
  if not state or not state.selected_section_index or not state.selected_slot then return end
  local slot_button = state.selected_slot_button
  if slot_button and slot_button.valid then slot_button.style = "flib_slot_button_default" end
  local current = state.combinator:get_item_slot(state.selected_section_index, state.selected_slot)
  if not current.signal or not current.signal.name then return end
  local value = resolve_textfield_number(state.signal_value_items, player_index, current.count or 0)
  if not value then
    state.signal_value_confirm.enabled = false
    return
  end
  set_new_signal_value(player_index, state, value, clear_selected)
end

--- @param event EventData.on_gui_click
function handlers.signal_value_confirm(event)
  local state = get_player_state(event.player_index)
  confirm_signal_value(event.player_index, state, true)
  -- if not state or not state.selected_slot then return end
  -- local slot_button = state.selected_slot_button
  -- if slot_button then slot_button.style = "flib_slot_button_default" end
  -- local current = state.combinator:get_item_slot(state.selected_slot)
  -- local value = resolve_textfield_number(state.signal_value_items, event.player_index, current.count or 0)
  -- if not value then
  --   state.signal_value_confirm.enabled = false
  --   return
  -- end
  -- set_new_signal_value(event.player_index, state, value)
end

--- @param event EventData.on_gui_click
function handlers.dimmer_click(event)
  local state = get_player_state(event.player_index)
  if not state then return end
  local player = game.get_player(event.player_index)
  if not player then return end
  destroy(player, DIMMER_ID)
  if state.main_window then
    player.opened = state.main_window
  end
end

--- @param player_index integer
local function create_dimmer(player_index)
  local player = game.get_player(player_index)
  if not player then return end
  local screen = player.gui.screen
  if screen[DIMMER_ID] then
    log:debug("dimmer already exists")
    return
  end
  local _, dimmer = flib_gui.add(screen, {
    type = "frame",
    name = DIMMER_ID,
    style = "cybersyn-combinator_frame_transparent",
    style_mods = {
      natural_width = 1000000,
      natural_height = 1000000,
      padding = 0,
      use_header_filler = false
    },
    handler = {
      [defines.events.on_gui_click] = handlers.dimmer_click
    }
  })
  dimmer.location = { 0, 0 }
  local state = get_player_state(player_index)
  if state then state.dimmer = dimmer end
end

--- @param state UiState
local function show_all_logistic_groups(state)
  if not state.logistic_group_edit then return end
  for _, elem in pairs(state.logistic_group_edit.group_list.children) do
    elem.visible = true
  end
end

local function set_logistic_group_search(state, enable)
  if not state.logistic_group_edit then return end
  local textfield = state.logistic_group_edit.search_textfield
  local current = textfield.visible
  if enable then
    textfield.visible = true
    textfield.focus()
    state.logistic_group_edit.search_button.toggled = true
    if current then
      textfield.select_all()
    end
  else
    textfield.visible = false
    textfield.text = ""
    state.logistic_group_edit.search_button.toggled = false
    show_all_logistic_groups(state)
  end
end

--- @param state UiState
local function toggle_logistic_group_search(state)
  if not state.logistic_group_edit then return end
  local textfield = state.logistic_group_edit.search_textfield
  set_logistic_group_search(state, not textfield.visible)
end

--- @param event EventData.on_gui_click
function handlers.logistic_group_search_click(event)
  local state = get_player_state(event.player_index)
  if not state then return end
  toggle_logistic_group_search(state)
end

--- @param event EventData.on_gui_text_changed
function handlers.logistic_group_search_text_changed(event)
  local state = get_player_state(event.player_index)
  if not state then return end
  local filter = event.element.text:upper()
  for _, elem in pairs(state.logistic_group_edit.group_list.children) do
    ---@type string
    ---@diagnostic disable-next-line: param-type-mismatch
    local group = elem.tags.group:upper()
    local matches = group:find(filter, nil, true) ~= nil
    elem.visible = matches
  end
end

--- @param player_index integer
--- @param close boolean
local function confirm_logistic_group(player_index, close)
  local player = game.get_player(player_index)
  if not player then return end
  local state = get_player_state(player_index)
  if not state then return end

  local group = state.logistic_group_edit.group_name_textfield.text
  local multiplier_text = state.logistic_group_edit.group_multiplier_textfield.text
  local multiplier = tonumber(multiplier_text) or 1

  local special_no_group = "[No group assigned]"
  local player_data = cc_util.get_player_data(player_index)
  if player_data and player_data.translations and player_data.translations["gui-train.empty-train-group"] then
    log:debug("Updating 'no group' string from cached translation")
    special_no_group = player_data.translations["gui-train.empty-train-group"]
  end

  if group == special_no_group then
    group = ""
  end

  log:debug("confirm logistic group '", group, "' with multiplier ", multiplier)

  state.logistic_group_edit.section.group = group or ""
  state.logistic_group_edit.section.multiplier = multiplier

  update_cs_signals(state)
  refresh_network_list(player, state)
  update_signal_sections(state, false, state.logistic_group_edit.section.index)

  state.logistic_group_edit.confirmed = true

  if not close then return end

  player.opened = state.main_window
end

--- @param event EventData.on_gui_confirmed
function handlers.logistic_group_confirmed(event)
  confirm_logistic_group(event.player_index, true)
end

--- @param event EventData.on_gui_click
function handlers.logistic_group_confirm(event)
  confirm_logistic_group(event.player_index, true)
end

--- @param event EventData.on_gui_click
function handlers.logistic_group_item_click(event)
  local element = event.element
  local group = element.tags.group --[[@as string?]]
  if not group then return end
  local state = get_player_state(event.player_index)
  if not state then return end
  if not state.logistic_group_edit then return end
  state.logistic_group_edit.group_name_textfield.text = group
end

--- @param event EventData.on_gui_click
function handlers.logistic_group_item_delete_click(event)
  local element = event.element
  local group = element.tags.group --[[@as string?]]
  if not group then return end
  local state = get_player_state(event.player_index)
  if not state then return end
  if not state.logistic_group_edit then return end
  log:debug("logistic group item delete clicked for group: ", group)
  state.logistic_group_edit.section.group = ""
  element.parent.destroy()
  local player = game.get_player(event.player_index)
  if not player or not player.valid then return end
  local force = player.force
  if not force.valid then return end
  log:debug("deleting logistic group: ", group)
  force.delete_logistic_group(group)
  update_signal_sections(state, false, nil, group)
end

--- @param name string?
--- @param count number?
--- @param is_empty boolean
local function make_logistic_group_item(name, count, is_empty)
  count = count or 0
  local group = name or ""
  ---@type string|LocalisedString
  local caption = name
  if group == "" then
    caption = { "gui-train.empty-train-group" }
  end
  local item = {
    type = "flow",
    direction = "horizontal",
    style = "packed_horizontal_flow",
    tags = {
      group = group
    },
    children = {
      {
        type = "button",
        style = "list_box_item",
        style_mods = {
          horizontally_stretchable = true,
          horizontal_align = "right"
        },
        caption = (group == "" or is_empty) and "" or tostring(count),
        tooltip = caption,
        mouse_button_filter = { "left" },
        tags = {
          group = group
        },
        handler = {
          [defines.events.on_gui_click] = handlers.logistic_group_item_click
        },
        children = {
          {
            type = "label",
            caption = caption,
            style_mods = {
              -- horizontally_stretchable = true
              width = group == "" and 300 or 300 - 28 - 40
            }
          }
        }
      },
      {
        type = "sprite-button",
        style = "tool_button_red",
        sprite = "utility/trash",
        visible = group ~= "" and not is_empty,
        mouse_button_filter = { "left" },
        tags = {
          group = group
        },
        handler = {
          [defines.events.on_gui_click] = handlers.logistic_group_item_delete_click
        }
      }
    }
  }

  return item
end

--- @param player_index integer
--- @param state UiState
--- @param section_id integer?
--- @param section_index integer?
local function create_logistic_group_edit(player_index, state, section_id, section_index)
  if not section_id and not section_index then
    error("create_logistic_group_edit: Either section_id or section_index must be provided")
  end

  local player = game.players[player_index]
  local screen = player.gui.screen
  create_dimmer(player_index)

  local section

  if section_id then
    section = state.combinator:get_or_create_section(section_id)
  elseif section_index then
    -- section = state.combinator.entity.get_control_behavior().get_section(section_index)
    section = state.combinator:get_item_section(section_index)
  end

  local named, dialog

  do
    local titlebar = {
      type = "flow",
      direction = "horizontal",
      drag_target = LOGI_GROUP_EDIT_ID,
      style = "frame_header_flow",
      style_mods = {
        vertically_stretchable = false
      },
      children = {
        {
          type = "label",
          style = "frame_title",
          caption = { "gui-rename.rename-group" },
          drag_target = LOGI_GROUP_EDIT_ID,
          style_mods = {
            vertically_stretchable = true,
            horizontally_squashable = true,
            top_margin = -3,
            bottom_padding = 3
          }
        },
        {
          type = "empty-widget",
          style = "draggable_space_header",
          drag_target = LOGI_GROUP_EDIT_ID,
          style_mods = {
            height = 24,
            natural_height = 24,
            horizontally_stretchable = true,
            vertically_stretchable = true
          }
        },
        {
          type = "sprite-button",
          style = "frame_action_button",
          name = "search_button",
          sprite = "utility/search",
          mouse_button_filter = { "left" },
          handler = {
            [defines.events.on_gui_click] = handlers.logistic_group_search_click
          }
        },
        {
          type = "sprite-button",
          style = "close_button",
          name = DESC_EDIT_ID .. "_close",
          sprite = "utility/close",
          mouse_button_filter = { "left" },
          handler = {
            [defines.events.on_gui_click] = handlers.dialog_close
          }
        }
      }
    }

    local entry_header = {
      type = "frame",
      style = "subheader_frame",
      style_mods = {
        width = 300
      },
      children = {
        {
          type = "flow",
          direction = "horizontal",
          style_mods = {
            vertical_align = "center"
          },
          children = {
            {
              type = "textfield",
              name = "group_name_textfield",
              style = "textbox",
              style_mods = {
                maximal_width = 0,
                horizontally_stretchable = true
              },
              text = section and section.group or "",
              icon_selector = true,
              handler = {
                [defines.events.on_gui_confirmed] = handlers.logistic_group_confirmed
              }
            },
            {
              type = "label",
              caption = "×"
            },
            {
              type = "textfield",
              name = "group_multiplier_textfield",
              style = "very_short_number_textfield",
              style_mods = {
                width = 40,
                natural_width = 40
              },
              text = section and section.multiplier or 1,
              numeric = true,
              allow_decimal = true,
              allow_negative = false,
              handler = {
                [defines.events.on_gui_confirmed] = handlers.logistic_group_confirmed
              }
            },
            {
              type = "sprite-button",
              name = "confirm_button",
              style = "item_and_count_select_confirm",
              sprite = "utility/enter",
              mouse_button_filter = { "left" },
              handler = {
                [defines.events.on_gui_click] = handlers.logistic_group_confirm
              }
            }
          }
        }
      }
    }

    local entry_list = {
      type = "scroll-pane",
      name = "group_list",
      direction = "vertical",
      style = "cybersyn-combinator_group-list_scroll-pane",
      style_mods = {
        width = 300,
        minimal_height = 130,
        maximal_height = 400
      },
      horizontal_scroll_policy = "never"
    }

    local content = {
      type = "flow",
      direction = "vertical",
      style = "inset_frame_container_vertical_flow",
      style_mods = {
        top_margin = -12
      },
      children = {
        {
          type = "frame",
          direction = "vertical",
          style = "inside_deep_frame",
          children = {
            entry_header,
            entry_list
          }
        }
      }
    }

    named, dialog = flib_gui.add(screen, {
      name = LOGI_GROUP_EDIT_ID,
      type = "frame",
      style = "inset_frame_container_frame",
      direction = "vertical",
      style_mods = {
        -- width = 324,
        maximal_height = 1290
      },
      tags = {
        section_id = section_id,
        section_index = section_index
      },
      children = {
        titlebar,
        {
          type = "textfield",
          style = "search_popup_textfield",
          name = "search_textfield",
          visible = false,
          style_mods = {
            top_margin = -46,
            bottom_margin = 6,
            left_margin = 132
          },
          handler = {
            [defines.events.on_gui_text_changed] = handlers.logistic_group_search_text_changed
          }
        },
        content
      }
    })
  end

  local group_list = named.group_list
  local logistic_groups = get_logistic_groups(player_index)
  for _, group in pairs(logistic_groups) do
    flib_gui.add(group_list, make_logistic_group_item(group.name, group.count, group.count == nil))
  end

  state.logistic_group_edit = {
    dialog = dialog,
    section = section --[[@as LuaLogisticSection]],
    search_textfield = named.search_textfield,
    search_button = named.search_button,
    group_name_textfield = named.group_name_textfield,
    group_multiplier_textfield = named.group_multiplier_textfield,
    group_confirm_button = named.confirm_button,
    group_list = group_list,
    confirmed = false
  }

  dialog.force_auto_center()
  named.group_name_textfield.select_all()
  named.group_name_textfield.focus()
  player.opened = dialog
end

--- @param event EventData.on_gui_click
function handlers.logistic_group_edit_click(event)
  local state = get_player_state(event.player_index)
  if not state then return end
  log:debug("Showing logistic group editor")
  local section_id = event.element.tags.section_id --[[@as integer]]
  local section_index = event.element.tags.section_index --[[@as integer]]
  create_logistic_group_edit(event.player_index, state, section_id, section_index)
end

---@param event EventData.on_gui_checked_state_changed
function handlers.signal_section_group_checked_state_changed(event)
  local section_index = event.element.tags.section_index
  if not section_index then return end
  local state = get_player_state(event.player_index)
  if not state then return end
  local enabled = event.element.state
  local section = state.combinator:get_item_section(section_index)
  section.active = enabled
  local container = state.section_container
  for _, section_entry in pairs(container.children) do
    if section_entry.tags.section_index == section_index then
      -- section_entry.signal_table.enabled = enabled
      update_signal_table(state, section_entry.signal_table, false)
      break
    end
  end
end

---@param event EventData.on_gui_click
function handlers.signal_section_remove_clicked(event)
  local section_index = event.element.tags.section_index
  if not section_index then return end
  local state = get_player_state(event.player_index)
  if not state then return end
  ---@cast section_index integer
  state.combinator:remove_item_section(section_index)
  update_signal_sections(state, true)
end

---@param section LuaLogisticSection
local function create_signal_section(section)
  local section_index = section.index
  local active = section.active
  local caption = create_logistic_section_caption(section)
  local rows = calc_slot_rows(section.filters_count)
  local overlay_height = 40 * rows

  local header = {
    type = "frame",
    name = "header",
    style = "repeated_subheader_frame",
    style_mods = {
      horizontally_stretchable = true
    },
    children = {
      {
        type = "checkbox",
        name = "checkbox",
        style = "subheader_caption_checkbox",
        caption = caption,
        state = active,
        handler = {
          [defines.events.on_gui_checked_state_changed] = handlers.signal_section_group_checked_state_changed
        },
        tags = {
          section_index = section_index
        }
      },
      {
        type = "sprite-button",
        style = "mini_button_aligned_to_text_vertically_when_centered",
        sprite = "utility/rename_icon",
        mouse_button_filter = { "left" },
        handler = {
          [defines.events.on_gui_click] = handlers.logistic_group_edit_click
        },
        tags = {
          section_index = section_index
        }
      },
      {
        type = "empty-widget",
        style_mods = {
          horizontally_stretchable = true,
          vertically_stretchable = true
        }
      },
      {
        type = "sprite-button",
        style = "tool_button_red",
        sprite = "utility/trash",
        mouse_button_filter = { "left" },
        handler = {
          [defines.events.on_gui_click] = handlers.signal_section_remove_clicked
        },
        tags = {
          section_index = section_index
        }
      }
    }
  }

  local signal_table = {
    type = "table",
    name = "signal_table",
    style = "slot_table",
    column_count = SLOT_COL_COUNT,
    enabled = active,
    tags = {
      section_index = section_index
    }
  }

  local section_element = {
    type = "flow",
    direction = "vertical",
    style_mods = {
      vertical_spacing = 0
    },
    tags = {
      section_index = section_index
    },
    children = {
      header,
      signal_table,
      {
        type = "frame",
        name = "overlay",
        visible = not active,
        style = "cybersyn-combinator_frame_semitransparent",
        style_mods = {
          width = 400,
          height = overlay_height,
          top_margin = -overlay_height
        },
        ignored_by_interaction = true
      }
    }
  }

  return section_element
end

---@param state UiState
---@param section LuaLogisticSection
---@return { [string]: LuaGuiElement } named
---@return LuaGuiElement element
local function add_signal_section(state, section)
  log:debug("adding new signal section to GUI")
  local container = state.section_container
  local section_element = create_signal_section(section)
  local named, element = flib_gui.add(container, section_element)
  update_signal_table(state, named.signal_table, true)
  return named, element
end

---@param state UiState
---@param signal_table LuaGuiElement
---@param reset boolean?
update_signal_table = function(state, signal_table, reset)
  if not state then return end
  if not signal_table or not signal_table.valid then return end

  local combinator = state.combinator
  local section = combinator:get_item_section(signal_table.tags.section_index)

  if not section then
    error("Failed to get signals section")
  end

  local section_index = section.index
  local active = section.active and combinator:is_enabled()
  local slot_rows = calc_slot_rows(section.filters_count)
  local slot_count = calc_slot_count(section)
  local button_style = active and SLOT_BUTTON_STYLE or SLOT_BUTTON_DISABLED_STYLE
  local overlay_height = 40 * slot_rows

  if reset then
    if state.selected_section_index == section_index then
      if state.selected_slot_button and state.selected_slot_button.valid then
        state.selected_slot_button.style = SLOT_BUTTON_STYLE
      end
      state.signal_value_stacks.enabled = false
      state.signal_value_items.enabled = false
      state.signal_value_confirm.enabled = false
      state.selected_section_index = nil
      state.selected_slot = nil
      state.selected_slot_button = nil
    end

    ---@diagnostic disable-next-line: undefined-field
    signal_table.clear()

    log:debug("Adding ", slot_count, " slots to signal table for section ", section.index)

    for slot = 1, slot_count do
      local signal = state.combinator:get_item_slot(section_index, slot --[[@as uint]])
      local _, button = flib_gui.add(signal_table, {
        type = "choose-elem-button",
        style = button_style,
        style_mods = {
          padding = 0
        },
        elem_type = "signal",
        handler = {
          [defines.events.on_gui_elem_changed] = handlers.signal_changed,
          [defines.events.on_gui_click] = handlers.signal_click
        },
        tags = {
          section_index = section_index,
          slot = slot
        },
        children = {
          {
            type = "label",
            name = "comparator",
            style = "cybersyn-combinator_signal-comparator",
            style_mods = {
              top_padding = -8
            },
            ignored_by_interaction = true,
            caption = "",
            visible = false
          },
          {
            type = "flow",
            name = "any_quality",
            direction = "vertical",
            ignored_by_interaction = true,
            visible = false,
            style_mods = {
              size = 36,
              vertical_align = "bottom",
              margin = 0,
              padding = 0,
              bottom_padding = 4
            },
            children = {
              {
                type = "sprite",
                sprite = "utility/any_quality",
                resize_to_sprite = false,
                style_mods = {
                  size = 13,
                  margin = 0
                },
                ignored_by_interaction = true
              }
            }
          },
          {
            type = "label",
            name = "label",
            style = "cybersyn-combinator_signal-count",
            ignored_by_interaction = true,
            caption = ""
          }
        }
      })
      if signal and signal.signal then
        button.elem_value = signal.signal
        log:debug(serpent.line(signal.signal))
        if signal.signal.comparator and signal.signal.quality then
          button.comparator.visible = signal.signal.comparator ~= "="
          button.comparator.caption = signal.signal.comparator
        else
          button.comparator.visible = false
          button.comparator.caption = ""
        end
        button.any_quality.visible = signal.signal.quality == nil
        button.label.caption = format_signal_count(signal.count)
        button.locked = true
      end
    end
  else
    for _, button in pairs(signal_table.children) do
      button.style = button_style
      local slot = button.tags.slot --[[@as uint]]
      if not slot then goto continue end
      local signal = state.combinator:get_item_slot(section_index, slot)
      if signal and signal.signal then
        button.elem_value = signal.signal
        if signal.signal.comparator and signal.signal.quality then
          button.comparator.visible = signal.signal.comparator ~= "="
          button.comparator.caption = signal.signal.comparator
        else
          button.comparator.visible = false
          button.comparator.caption = ""
        end
        button.any_quality.visible = signal.signal.quality == nil
        button.label.caption = format_signal_count(signal.count)
        button.locked = true
      else
        button.locked = false
      end
      ::continue::
    end
  end

  local overlay = signal_table.parent.overlay
  overlay.visible = not active
  overlay.style.height = overlay_height
  overlay.style.top_margin = -overlay_height

  update_totals(state)
end

---@param state UiState
---@param reset boolean
---@param reset_section_index integer?
---@param deleted_group string?
---@param updated_group string?
update_signal_sections = function(state, reset, reset_section_index, deleted_group, updated_group)
  if not state then return end

  local container = state.section_container

  if reset then
    if state.selected_slot_button and state.selected_slot_button.valid then
      state.selected_slot_button.style = SLOT_BUTTON_STYLE
    end
    state.signal_value_stacks.enabled = false
    state.signal_value_items.enabled = false
    state.signal_value_confirm.enabled = false
    state.selected_section_index = nil
    state.selected_slot = nil
    state.selected_slot_button = nil
    container.clear()
    for section_index, section in state.combinator:iter_item_sections() do
      add_signal_section(state, section)
    end
  else
    for _, section_entry in pairs(container.children) do
      local section_index = section_entry.tags.section_index
      if not section_index then goto continue end
      local section = state.combinator:get_item_section(section_index)
      if not section then goto continue end
      if updated_group and updated_group ~= "" and section.group ~= updated_group then
        goto continue
      end
      local active = section.active
      local caption = create_logistic_section_caption(section)
      section_entry.header.checkbox.state = active
      section_entry.header.checkbox.caption = caption
      if not deleted_group then
        update_signal_table(state, section_entry.signal_table, reset or reset_section_index == section.index or (updated_group and updated_group ~= ""))
      end
      ::continue::
    end
  end
end

---@param event EventData.on_gui_checked_state_changed
function handlers.cs_group_checked_state_changed(event)
  local enabled = event.element.state
  local state = get_player_state(event.player_index)
  if not state then return end
  local section = state.combinator:get_or_create_section(CybersynCombinator.CYBERSYN_SECTION_ID)
  section.active = enabled
  update_cs_signals(state)
end

--- @param event EventData.on_gui_text_changed
function handlers.cs_signal_value_changed(event)
  local element = event.element
  if not element then return end
  set_cs_signal_value(element, event.player_index, false)
end

--- @param event EventData.on_gui_confirmed
function handlers.cs_signal_value_confirmed(event)
  local element = event.element
  if not element then return end
  set_cs_signal_value(element, event.player_index, true)
end

--- @param event EventData.on_gui_click
function handlers.cs_signal_reset(event)
  local element = event.element
  if not element then return end
  local state = get_player_state(event.player_index)
  if not state then return end
  local name = element.tags.signal_name --[[@as string?]]
  if not name then return end
  local cs_signal = config.cs_signals[name]
  if not cs_signal then return end
  local field = state[name]
  if not field then return end
  state.combinator:reset_cs_value(name)
  field.text = tostring(cs_signal.default)
  element.enabled = false
end

---@param event EventData.on_gui_checked_state_changed
function handlers.network_group_checked_state_changed(event)
  local state = get_player_state(event.player_index)
  if not state then return end
  local enabled = event.element.state
  local section = state.combinator:get_or_create_section(CybersynCombinator.NETWORK_SECTION_ID)
  section.active = enabled
end

--- @param event EventData.on_gui_elem_changed
--- @param on_failure function
--- @return Signal|false
function handlers.mask_signal_changed(event, on_failure)
  local state = get_player_state(event.player_index)
  if not state then return false end
  local element = event.element
  if not element then return false end
  --- @type Signal
  local signal = { signal = element.elem_value --[[@as SignalID]], count = 0 }
  if not signal.signal then
    on_failure()
    return false
  end
  if not cc_util.is_valid_output_signal(signal) then
    event.element.elem_value = nil
    on_failure()
    local player = game.get_player(event.player_index)
    if not player then return false end
    player.play_sound { path = constants.CANNOT_BUILD_SOUND }
    player.print({ "cybersyn-combinator-window.invalid-signal" })
    return false
  end
  if signal.signal.type ~= "virtual" then
    event.element.elem_value = nil
    on_failure()
    log:info("attempt to use non-virtual signal as network mask")
    local player = game.get_player(event.player_index)
    if not player then return false end
    player.play_sound { path = constants.CANNOT_BUILD_SOUND }
    player.print { "cybersyn-combinator-window.non-virtual-network-mask", signal.signal.type, signal.signal.name }
    return false
  end
  return signal
end

--- @param event EventData.on_gui_elem_changed
function handlers.network_mask_signal_changed(event)
  local state = get_player_state(event.player_index)
  if not state then return end
  local signal = handlers.mask_signal_changed(event, function()
    state.network_mask.signal = nil
    state.network_mask.add_button.enabled = false
  end)
  if not signal then return end
  state.network_mask.signal = signal
  log:debug("network signal changed to ", serpent.block(signal))
  --- @type integer?
  local new_count = nil
  local use_cs_default = settings.get_player_settings(event.player_index)[constants.SETTINGS.NETWORK_MASK_USE_CS_DEFAULT].value
  local cs_default = settings.global[constants.SETTINGS.CS_NETWORK_FLAG].value
  if use_cs_default and cs_default ~= nil then
    new_count = cs_default --[[@as integer]]
  elseif state.network_mask.mask then
    new_count = state.network_mask.mask
  end
  if new_count ~= nil then
    signal.count = new_count
    state.network_mask.textfield.text = masking.format_for_input(new_count, event.player_index)
    state.network_mask.add_button.enabled = true
  else
    state.network_mask.add_button.enabled = false
  end

  focus_network_mask_input(state)
end

--- @param event EventData.on_gui_click
function handlers.network_mask_signal_click(event)
  local state = get_player_state(event.player_index)
  if not state then return end
  if event.button == defines.mouse_button_type.right then
    state.network_mask.signal = nil
    state.network_mask.add_button.enabled = false
  end
end

--- @param event EventData.on_gui_text_changed
function handlers.network_mask_changed(event)
  local state = get_player_state(event.player_index)
  if not state then return end
  local text = event.element.text
  local mask = masking.parse(text, event.player_index)
  if state.network_mask.signal then state.network_mask.signal.count = mask end
  if mask == 0 then
    state.network_mask.mask = nil
    state.network_mask.add_button.enabled = false
    return
  end
  state.network_mask.mask = mask
  state.network_mask.add_button.enabled = state.network_mask.signal ~= nil
end

--- @param event EventData.on_gui_confirmed
function handlers.network_mask_confirmed(event)
  local state = get_player_state(event.player_index)
  add_network_mask(event.player_index, state)
end

--- @param event EventData.on_gui_click
function handlers.network_mask_add_click(event)
  local state = get_player_state(event.player_index)
  add_network_mask(event.player_index, state)
end

--- @param player_index integer
---@param close boolean
local function confirm_encoder(player_index, close)
  local state = get_player_state(player_index)
  if not state then return end
  state.network_mask.signal.signal = state.encoder.signal_button.elem_value --[[@as SignalID]]
  state.network_mask.signal.count = masking.uint_to_int(state.encoder.mask)
  add_network_mask(player_index, state)
  if not close then return end
  local player = game.get_player(player_index)
  if player and state.main_window then
    player.opened = state.main_window
  end
end

--- @param player_index integer
--- @param close boolean
local function confirm_description(player_index, close)
  local state = get_player_state(player_index)
  if not state then return end
  local description = state.description_edit.textfield.text
  state.combinator:set_description(description)
  state.description_label.caption = description
  local has_description = description ~= ""
  state.add_description_button.visible = not has_description
  state.description_header.visible = has_description
  state.description_scroll.visible = has_description
  if not close then return end
  local player = game.get_player(player_index)
  if player and state.main_window then
    player.opened = state.main_window
  end
end

--- @param event EventData.on_gui_click
function handlers.encoder_confirm(event)
  log:debug("encoder confirm button clicked")
  confirm_encoder(event.player_index, true)
end

--- @param event EventData.on_gui_click
function handlers.description_edit_confirm(event)
  log:debug("description edit confirm button clicked")
  confirm_description(event.player_index, true)
end

--- @param player_index integer
--- @param state UiState
--- @param update_textfield boolean
local function refresh_encoder(player_index, state, update_textfield)
  state.encoder.confirm_button.enabled = state.encoder.signal_button.elem_value ~= nil
  if not state.encoder.bit_buttons then return end
  local mask = state.encoder.mask
  if not mask then return end
  if update_textfield then
    state.encoder.textfield.text = masking.format_for_input(mask, player_index)
  end
  state.encoder.display_dec.caption = masking.format_explicit(mask, masking.Mode.DECIMAL, false, true)
  state.encoder.display_hex.caption = masking.format_explicit(mask, masking.Mode.HEX, false, true)
  state.encoder.display_bin.caption = masking.format_explicit(mask, masking.Mode.BINARY, false, true)
  state.encoder.display_oct.caption = masking.format_explicit(mask, masking.Mode.OCTAL, false, true)
  for i, button in ipairs(state.encoder.bit_buttons.children) do
    local bit_index = i - 1
    local bit_value = bit32.extract(state.encoder.mask, bit_index)
    if bit_value == 1 then
      button.style = BIT_BUTTON_PRESSED_STYLE
    else
      button.style = BIT_BUTTON_STYLE
    end
  end
end

--- @param event EventData.on_gui_elem_changed
function handlers.encoder_signal_changed(event)
  local state = get_player_state(event.player_index)
  if not state then return end
  local signal = handlers.mask_signal_changed(event, function()
    state.encoder.signal_button.elem_value = nil
  end)
  refresh_encoder(event.player_index, state, true)
  if not signal then return end
  state.encoder.textfield.focus()
  state.encoder.textfield.select_all()
end

--- @param event EventData.on_gui_click
function handlers.encoder_signal_click(event)
  local state = get_player_state(event.player_index)
  if not state then return end
  refresh_encoder(event.player_index, state, true)
end

--- @param event EventData.on_gui_text_changed
function handlers.encoder_mask_changed(event)
  local state = get_player_state(event.player_index)
  if not state then return end
  local text = event.element.text
  local mask = masking.parse(text, event.player_index)
  state.encoder.mask = mask
  refresh_encoder(event.player_index, state, false)
end

-- --- @param event EventData.on_gui_confirmed
-- function handlers.encoder_mask_confirmed(event)
--   local state = get_player_state(event.player_index)
--   if not state then return end
-- end

--- @param event EventData.on_gui_click
function handlers.encoder_bit_button_click(event)
  local state = get_player_state(event.player_index)
  if not state then return end
  local index = event.element.tags.index
  local bit_index = event.element.tags.bit_index --[[@as integer]]
  state.encoder.mask = bit32.bxor(state.encoder.mask, bit32.lshift(1, bit_index))
  log:debug("Pressed bit button ", index, " (bit ", bit_index, ")")
  refresh_encoder(event.player_index, state, true)
end

--- @param event EventData.on_gui_click
function handlers.encoder_all(event)
  local state = get_player_state(event.player_index)
  if not state then return end
  state.encoder.mask = 0xFFFFFFFF
  refresh_encoder(event.player_index, state, true)
end

--- @param event EventData.on_gui_click
function handlers.encoder_none(event)
  local state = get_player_state(event.player_index)
  if not state then return end
  state.encoder.mask = 0
  refresh_encoder(event.player_index, state, true)
end

--- @param player_index integer
--- @param state UiState
local function create_encoder(player_index, state)
  local player = game.players[player_index]
  local screen = player.gui.screen
  local signal = state.network_mask.signal
  if not signal then
    return
  end
  create_dimmer(player_index)
  local named, dialog = flib_gui.add(screen, {
    {
      type = "frame",
      direction = "vertical",
      name = ENCODER_ID,
      tags = {
        unit_number = state.entity.unit_number
      },
      style_mods = {
        -- minimal_width = 240
        width = 450
      },
      children = {
        {
          type = "flow",
          direction = "horizontal",
          drag_target = ENCODER_ID,
          tooltip = { "cybersyn-combinator-encoder.tooltip" },
          children = {
            {
              type = "label",
              style = "frame_title",
              caption = {
                "",
                { "cybersyn-combinator-encoder.title" },
                " [img=info]"
              },
              tooltip = { "cybersyn-combinator-encoder.tooltip" },
              elem_mods = { ignored_by_interaction = true }
            },
            {
              type = "empty-widget",
              style = "flib_titlebar_drag_handle",
              elem_mods = { ignored_by_interaction = true }
            }
          }
        },
        {
          type = "frame",
          direction = "vertical",
          style = "inside_shallow_frame_with_padding",
          style_mods = {
            horizontally_stretchable = true,
            vertically_stretchable = true,
            horizontal_align = "center",
            padding = 8
          },
          children = {
            { -- Signal and text field
              type = "flow",
              direction = "horizontal",
              style_mods = {
                vertical_align = "center",
                bottom_margin = 4
              },
              children = {
                {
                  type = "flow",
                  style_mods = { horizontally_stretchable = true }
                },
                {
                  type = "choose-elem-button",
                  name = "encoder_signal_button",
                  elem_type = "signal",
                  style_mods = { width = 48, height = 48 },
                  handler = {
                    [defines.events.on_gui_elem_changed] = handlers.encoder_signal_changed,
                    [defines.events.on_gui_click] = handlers.encoder_signal_click
                  }
                },
                {
                  type = "textfield",
                  name = "encoder_mask_textfield",
                  style = "cybersyn-combinator_network-mask-text-input",
                  style_mods = { left_margin = 8, width = 200 },
                  numeric = false,
                  clear_and_focus_on_right_click = true,
                  lose_focus_on_confirm = true,
                  handler = {
                    [defines.events.on_gui_text_changed] = handlers.encoder_mask_changed
                    -- [defines.events.on_gui_confirmed] = handlers.encoder_mask_confirmed
                  }
                },
                {
                  type = "flow",
                  style_mods = { horizontally_stretchable = true }
                }
              }
            },
            { -- Bit buttons
              type = "flow",
              direction = "vertical",
              style_mods = {
                horizontally_stretchable = true,
                horizontal_align = "center",
                top_margin = 4,
                bottom_margin = 4
              },
              children = {
                {
                  type = "table",
                  name = "bit_buttons",
                  column_count = 8
                }
              }
            },
            { -- All/None buttons
              type = "flow",
              direction = "horizontal",
              style_mods = {
                horizontally_stretchable = true,
                horizontal_align = "center",
                top_margin = 4,
                bottom_margin = 4
              },
              children = {
                {
                  type = "button",
                  caption = { "cybersyn-combinator-encoder.all" },
                  mouse_button_filter = { "left" },
                  handler = handlers.encoder_all
                },
                {
                  type = "button",
                  caption = { "cybersyn-combinator-encoder.none" },
                  mouse_button_filter = { "left" },
                  handler = handlers.encoder_none
                }
              }
            },
            {
              type = "table",
              name = "mask_display_table",
              column_count = 2,
              style_mods = {
                horizontally_stretchable = true
              },
              children = {
                {
                  type = "label",
                  caption = { "cybersyn-combinator-encoder.decimal" }
                },
                {
                  type = "flow",
                  direction = "vertical",
                  style_mods = {
                    horizontally_stretchable = true,
                    horizontal_align = "right"
                  },
                  children = {
                    {
                      type = "label",
                      name = "display_dec",
                      style_mods = {
                        horizontal_align = "right",
                        horizontally_stretchable = true
                      }
                    }
                  }
                },
                {
                  type = "label",
                  caption = { "cybersyn-combinator-encoder.hexadecimal" }
                },
                {
                  type = "flow",
                  direction = "vertical",
                  style_mods = {
                    horizontally_stretchable = true,
                    horizontal_align = "right"
                  },
                  children = {
                    {
                      type = "label",
                      name = "display_hex",
                      style_mods = {
                        horizontal_align = "right",
                        horizontally_stretchable = true
                      }
                    }
                  }
                },
                {
                  type = "label",
                  caption = { "cybersyn-combinator-encoder.binary" }
                },
                {
                  type = "flow",
                  direction = "vertical",
                  style_mods = {
                    horizontally_stretchable = true,
                    horizontal_align = "right"
                  },
                  children = {
                    {
                      type = "label",
                      name = "display_bin",
                      style_mods = {
                        horizontal_align = "right",
                        horizontally_stretchable = true
                      }
                    }
                  }
                },
                {
                  type = "label",
                  caption = { "cybersyn-combinator-encoder.octal" }
                },
                {
                  type = "flow",
                  direction = "vertical",
                  style_mods = {
                    horizontally_stretchable = true,
                    horizontal_align = "right"
                  },
                  children = {
                    {
                      type = "label",
                      name = "display_oct",
                      style_mods = {
                        horizontal_align = "right",
                        horizontally_stretchable = true
                      }
                    }
                  }
                }
              }
            }
          }
        },
        {
          type = "flow",
          direction = "horizontal",
          style_mods = {
            horizontal_spacing = 0
          },
          children = {
            {
              type = "button",
              style = "back_button",
              caption = { "gui.cancel" },
              name = ENCODER_ID .. "_close",
              mouse_button_filter = { "left" },
              handler = handlers.dialog_close
            },
            {
              type = "empty-widget",
              style = "flib_dialog_footer_drag_handle",
              drag_target = ENCODER_ID
            },
            {
              type = "button",
              name = "confirm_button",
              style = "confirm_button",
              caption = { "gui.confirm" },
              tooltip = nil,
              mouse_button_filter = { "left" },
              handler = handlers.encoder_confirm
            }
          }
        }
      }
    }
  })
  local bit_buttons = named.bit_buttons
  state.encoder = {
    mask = state.network_mask.mask,
    dialog = dialog,
    signal_button = named.encoder_signal_button,
    textfield = named.encoder_mask_textfield,
    bit_buttons = bit_buttons,
    display_dec = named.display_dec,
    display_hex = named.display_hex,
    display_bin = named.display_bin,
    display_oct = named.display_oct,
    confirm_button = named.confirm_button
  }
  state.encoder.signal_button.elem_value = signal.signal
  state.encoder.textfield.text = masking.format_for_input(signal.count, player_index)
  local settings = settings.get_player_settings(player_index)
  local zeroIndex = settings[constants.SETTINGS.ENCODER_ZERO_INDEX].value
  for i = 1, 32 do
    local bit_index = i - 1
    local is_active = bit32.extract(state.encoder.mask, bit_index) == 1
    local bb_style = bit_button_style(is_active)
    flib_gui.add(bit_buttons, {
      type = "sprite-button",
      caption = tostring(zeroIndex and bit_index or i),
      style = bb_style,
      mouse_button_filter = { "left" },
      tags = {
        index = i,
        bit_index = bit_index
      },
      handler = handlers.encoder_bit_button_click
    })
  end
  refresh_encoder(player_index, state, true)
  dialog.force_auto_center()
  -- state.main_window.visible = false
  player.opened = dialog
end

---@param player_index integer
---@param state UiState
local function create_description_edit(player_index, state)
  local player = game.players[player_index]
  local screen = player.gui.screen
  create_dimmer(player_index)
  local named, dialog
  do
    named, dialog = flib_gui.add(screen, {
      name = DESC_EDIT_ID,
      type = "frame",
      style = "inset_frame_container_frame",
      direction = "vertical",
      style_mods = {
        width = 400,
        maximal_height = 1290
      },
      children = {
        { -- Titlebar
          type = "flow",
          direction = "horizontal",
          drag_target = DESC_EDIT_ID,
          style = "frame_header_flow",
          style_mods = {
            vertically_stretchable = false
          },
          children = {
            {
              type = "label",
              style = "frame_title",
              caption = { "gui-edit-label.edit-description" },
              drag_target = DESC_EDIT_ID,
              style_mods = {
                vertically_stretchable = true,
                horizontally_squashable = true,
                top_margin = -3,
                bottom_padding = 3
              }
            },
            {
              type = "empty-widget",
              style = "draggable_space_header",
              drag_target = DESC_EDIT_ID,
              style_mods = {
                height = 24,
                natural_height = 24,
                horizontally_stretchable = true,
                vertically_stretchable = true
              }
            },
            {
              type = "sprite-button",
              style = "cancel_close_button",
              name = DESC_EDIT_ID .. "_close",
              sprite = "utility/close",
              mouse_button_filter = { "left" },
              handler = {
                [defines.events.on_gui_click] = handlers.dialog_close
              }
            }
          }
        },
        { -- Content
          type = "flow",
          direction = "vertical",
          style = "inset_frame_container_vertical_flow",
          style_mods = {
            horizontal_align = "right",
            top_margin = -12
          },
          children = {
            {
              type = "text-box",
              name = "description",
              style = "edit_blueprint_description_textbox",
              style_mods = {
                horizontally_stretchable = true
              },
              text = state.combinator:get_description(),
              icon_selector = true
            },
            {
              type = "flow",
              style = "horizontal_flow",
              direction = "horizontal",
              children = {
                {
                  type = "empty-widget",
                  style = "draggable_space",
                  style_mods = {
                    left_margin = 0,
                    horizontally_stretchable = true,
                    vertically_stretchable = true
                  },
                  drag_target = DESC_EDIT_ID
                },
                {
                  type = "button",
                  style = "confirm_button",
                  caption = { "gui-edit-label.save-description" },
                  mouse_button_filter = { "left" },
                  handler = {
                    [defines.events.on_gui_click] = handlers.description_edit_confirm
                  }
                }
              }
            }
          }
        }
      }
    })
  end

  ---@type DescriptionEditState
  state.description_edit = {
    dialog = dialog,
    textfield = named.description
  }

  dialog.force_auto_center()
  named.description.focus()
  player.opened = dialog
end

--- @param event EventData.on_gui_click
function handlers.network_list_item_click(event)
  local state = get_player_state(event.player_index)
  if not state then return end
  local element = event.element
  if not element then return end
  local slot = element.tags.slot --[[@as uint?]]
  if not slot then return end
  log:debug("clicked on network list button for slot ", slot, " with button ", event.button)
  if event.button == defines.mouse_button_type.right then
    state.combinator:remove_network_slot(slot)
    refresh_network_list(event.player_index, state)
    log:debug("removed network signal at slot ", slot)
    return
  end
  if event.button ~= defines.mouse_button_type.left then return end
  local signal = state.combinator:get_network_slot(slot)
  if not signal then return end
  state.network_mask.signal = signal
  state.network_mask.mask = signal.count
  state.network_mask.slot = slot
  if event.control then
    log:debug("Showing network encoder!")
    create_encoder(event.player_index, state)
  else
    state.network_mask.signal_button.elem_value = signal.signal
    state.network_mask.textfield.text = masking.format_for_input(signal.count, event.player_index)
    state.network_mask.add_button.enabled = true
    focus_network_mask_input(state)
  end
end

---@param event EventData.on_gui_click
function handlers.logistic_section_add_click(event)
  log:debug("add section button click")
  local state = get_player_state(event.player_index)
  if not state then return end
  local section = state.combinator:add_item_section()
  if not section then
    log:error("Failed to add logistic section")
    return
  end
  add_signal_section(state, section)
end

--- @param event EventData.on_gui_click
function handlers.description_edit_click(event)
  local state = get_player_state(event.player_index)
  if not state then return end
  log:debug("Showing description editor")
  create_description_edit(event.player_index, state)
end

--- @param player LuaPlayer
--- @param combinator CybersynCombinator
--- @return UiState
local function create_window(player, combinator)
  local entity = combinator.entity
  local screen = player.gui.screen

  local network_list_width = 200
  local description_width = 640

  if settings.get_player_settings(player)[constants.SETTINGS.NETWORK_MASK_DISPLAY_MODE].value == "BINARY" then
    network_list_width = 340
    description_width = 780
  end

  local enable_expressions = settings.get_player_settings(player)[constants.SETTINGS.ENABLE_EXPRESSIONS].value == true

  local named, main_window

  do
    local titlebar = {
      type = "flow",
      drag_target = WINDOW_ID,
      children = {
        {
          type = "label",
          style = "frame_title",
          caption = { "cybersyn-combinator-window.title" },
          elem_mods = { ignored_by_interaction = true },
          style_mods = {
            maximal_width = 600
          }
        },
        {
          type = "empty-widget",
          style = "flib_titlebar_drag_handle",
          elem_mods = { ignored_by_interaction = true }
        },
        {
          type = "sprite-button",
          style = "close_button",
          mouse_button_filter = { "left" },
          sprite = "utility/close",
          name = WINDOW_ID .. "_close",
          handler = handlers.close
        }
      }
    }

    local connection_header = {
      type = "frame",
      style = "subheader_frame",
      style_mods = {
        horizontally_stretchable = true,
        horizontally_squashable = true,
        top_margin = -8,
        left_margin = -12,
        right_margin = -12
      },
      children = {
        {
          type = "flow",
          name = "connection_header_items",
          style = "player_input_horizontal_flow"
        }
      }
    }

    local network_section = combinator:get_or_create_section(CybersynCombinator.NETWORK_SECTION_ID) --[[@as LuaLogisticSection]]
    local network_caption = create_logistic_section_caption(network_section)

    local network_list = { -- Network list
      type = "frame",
      style = "deep_frame_in_shallow_frame",
      style_mods = { width = network_list_width, vertically_stretchable = true },
      direction = "vertical",
      children = {
        {
          type = "frame",
          style = "subheader_frame",
          direction = "vertical",
          style_mods = { horizontally_stretchable = true, maximal_height = 90 },
          children = {
            {
              type = "flow",
              direction = "horizontal",
              style_mods = { left_padding = 4 },
              children = {
                {
                  type = "label",
                  style = "caption_label",
                  caption = {
                    "",
                    { "cybersyn-combinator-window.network-list-title" },
                    " [img=info]"
                  },
                  tooltip = { "cybersyn-combinator-window.network-list-tooltip" }
                },
                {
                  type = "empty-widget",
                  style = "flib_horizontal_pusher"
                }
              }
            },
            {
              type = "flow",
              direction = "horizontal",
              style_mods = {
                horizontally_stretchable = true,
                left_padding = 4,
                right_padding = 4
              },
              children = {
                {
                  type = "checkbox",
                  name = "network_list_group_checkbox",
                  caption = network_caption,
                  tooltip = network_caption,
                  -- style = "caption_checkbox",
                  style_mods = {
                    horizontally_squashable = true
                  },
                  state = network_section.active,
                  handler = {
                    [defines.events.on_gui_checked_state_changed] = handlers.network_group_checked_state_changed
                  }
                },
                {
                  type = "sprite-button",
                  style = "mini_button_aligned_to_text_vertically",
                  sprite = "utility/rename_icon",
                  mouse_button_filter = { "left" },
                  tags = {
                    section_id = CybersynCombinator.NETWORK_SECTION_ID
                  },
                  handler = {
                    [defines.events.on_gui_click] = handlers.logistic_group_edit_click
                  }
                }
              }
            },
            {
              type = "flow",
              direction = "horizontal",
              style_mods = { left_padding = 3, right_padding = 3 },
              children = {
                {
                  type = "choose-elem-button",
                  name = "network_mask_signal_button",
                  elem_type = "signal",
                  style_mods = { width = 32, height = 32 },
                  handler = {
                    [defines.events.on_gui_elem_changed] = handlers.network_mask_signal_changed,
                    [defines.events.on_gui_click] = handlers.network_mask_signal_click
                  }
                },
                {
                  type = "textfield",
                  name = "network_mask_textfield",
                  style = "cybersyn-combinator_network-mask-text-input",
                  style_mods = { horizontally_stretchable = true, minimal_width = 50, maximal_width = 300 },
                  text = "",
                  numeric = false,
                  clear_and_focus_on_right_click = true,
                  lose_focus_on_confirm = true,
                  handler = {
                    [defines.events.on_gui_text_changed] = handlers.network_mask_changed,
                    [defines.events.on_gui_confirmed] = handlers.network_mask_confirmed
                  }
                },
                {
                  type = "sprite-button",
                  name = "network_mask_add_button",
                  sprite = "utility/check_mark",
                  style = "flib_tool_button_light_green",
                  enabled = false,
                  mouse_button_filter = { "left" },
                  handler = {
                    [defines.events.on_gui_click] = handlers.network_mask_add_click
                  }
                }
              }
            }
          }
        },
        {
          type = "scroll-pane",
          name = "network_list",
          style = "cybersyn-combinator_network-list_scroll-pane",
          vertical_scroll_policy = "auto"
        }
      }
    }

    local status_and_preview = {
      type = "flow",
      direction = "vertical",
      style_mods = { horizontal_align = "left" },
      children = {
        { -- Status
          type = "flow",
          direction = "horizontal",
          style_mods = { vertical_align = "center", horizontally_stretchable = true, bottom_padding = 4 },
          children = {
            {
              type = "sprite",
              name = "status_sprite",
              sprite = entity.name == "entity-ghost" and GHOST_STATUS_SPRITE or STATUS_SPRITES[entity.status] or DEFAULT_STATUS_SPRITE,
              style = "status_image",
              style_mods = { stretch_image_to_widget_size = true }
            },
            {
              type = "label",
              name = "status_label",
              caption = entity.name == "entity-ghost" and GHOST_STATUS_NAME or STATUS_NAMES[entity.status] or DEFAULT_STATUS_NAME
            }
          }
        },
        { -- Preview
          type = "frame",
          style = "deep_frame_in_shallow_frame",
          style_mods = { minimal_width = 0, horizontally_stretchable = true, padding = 0 },
          children = {
            {
              type = "entity-preview",
              name = "preview",
              style = "wide_entity_button",
              style_mods = {
                width = 128,
                maximal_height = 500,
                horizontally_stretchable = true,
                vertically_stretchable = true
              }
            }
          }
        }
      }
    }

    local cs_section = combinator:get_or_create_section(CybersynCombinator.CYBERSYN_SECTION_ID) --[[@as LuaLogisticSection]]
    local cs_caption = create_logistic_section_caption(cs_section)

    local cs_signals_pane = { -- CS signal pane
      type = "flow",
      direction = "vertical",
      style_mods = { top_margin = 25, left_padding = 8, width = 300, horizontal_align = "center", vertically_stretchable = true },
      children = {
        {
          type = "flow",
          direction = "horizontal",
          style_mods = {
            horizontally_stretchable = true,
            horizontal_align = "left",
            left_padding = 5
          },
          children = {
            {
              type = "checkbox",
              name = "cs_signals_group_checkbox",
              caption = cs_caption,
              tooltip = cs_caption,
              style = "caption_checkbox",
              style_mods = {
                horizontally_squashable = true
              },
              state = cs_section.active,
              handler = {
                [defines.events.on_gui_checked_state_changed] = handlers.cs_group_checked_state_changed
              }
            },
            {
              type = "sprite-button",
              style = "mini_button_aligned_to_text_vertically",
              sprite = "utility/rename_icon",
              mouse_button_filter = { "left" },
              tags = {
                section_id = CybersynCombinator.CYBERSYN_SECTION_ID
              },
              handler = {
                [defines.events.on_gui_click] = handlers.logistic_group_edit_click
              }
            }
          }
        },
        {
          type = "table",
          name = "cs_signals_table",
          column_count = 4,
          style_mods = { cell_padding = 2, horizontally_stretchable = true, vertical_align = "center" }
        }
      }
    }

    local on_off = { -- On/off switch
      type = "flow",
      style_mods = {
        horizontal_align = "left",
        maximal_width = 110
      },
      direction = "vertical",
      children = {
        {
          type = "label",
          style = "semibold_label",
          caption = { "gui-constant.output" }
        },
        {
          type = "switch",
          name = "on_off",
          handler = {
            [defines.events.on_gui_switch_state_changed] = handlers.on_off
          },
          left_label_caption = { "gui-constant.off" },
          right_label_caption = { "gui-constant.on" }
        }
      }
    }

    local request_totals = {
      type = "flow",
      style_mods = {
        horizontal_align = "right",
        horizontally_stretchable = true,
        left_margin = 10
      },
      direction = "horizontal",
      children = {
        {
          type = "flow",
          direction = "vertical",
          style_mods = { maximal_width = 105 },
          children = {
            {
              type = "label",
              style = "semibold_label",
              caption = {
                "",
                { "cybersyn-combinator-window.item-total" },
                " [img=info]"
              },
              tooltip = { "cybersyn-combinator-window.item-total-description" }
            },
            {
              type = "label",
              name = "item_total",
              style_mods = { minimal_width = 80 },
              caption = "0",
              tooltip = "0"
            }
          }
        },
        {
          type = "flow",
          direction = "vertical",
          style_mods = { maximal_width = 105 },
          children = {
            {
              type = "label",
              style = "semibold_label",
              caption = {
                "",
                { "cybersyn-combinator-window.item-stacks" },
                " [img=info]"
              },
              tooltip = { "cybersyn-combinator-window.item-stacks-description" }
            },
            {
              type = "label",
              name = "item_stacks",
              style_mods = { minimal_width = 80 },
              caption = "0",
              tooltip = "0"
            }
          }
        },
        {
          type = "flow",
          direction = "vertical",
          style_mods = { maximal_width = 105 },
          children = {
            {
              type = "label",
              style = "semibold_label",
              caption = {
                "",
                { "cybersyn-combinator-window.fluid-total" },
                " [img=info]"
              },
              tooltip = { "cybersyn-combinator-window.fluid-total-description" }
            },
            {
              type = "label",
              name = "fluid_total",
              style_mods = { minimal_width = 80 },
              caption = "0",
              tooltip = "0"
            }
          }
        }
      }
    }

    local signals_container = { -- Signals container
      type = "flow",
      direction = "vertical",
      style = "two_module_spacing_vertical_flow",
      style_mods = { top_margin = 4, horizontal_align = "center", horizontally_stretchable = true },
      children = {
        {
          type = "scroll-pane",
          direction = "vertical",
          style = "deep_slots_scroll_pane",
          style_mods = {
            minimal_width = 400,
            minimal_height = 80
          },
          children = {
            {
              type = "flow",
              name = "section_container",
              direction = "vertical",
              style = "packed_vertical_flow"
            },
            {
              type = "button",
              style_mods = {
                horizontally_stretchable = true
              },
              caption = { "gui-logistic.add-section" },
              mouse_button_filter = { "left" },
              handler = {
                [defines.events.on_gui_click] = handlers.logistic_section_add_click
              }
            }
          }
        },
        {
          type = "flow",
          direction = "horizontal",
          style_mods = { horizontal_align = "right" },
          children = {
            {
              type = "label",
              style_mods = { top_margin = 5 },
              caption = { "cybersyn-combinator-window.stacks" }
            },
            {
              type = "textfield",
              name = "signal_value_stacks",
              enabled = false,
              style_mods = { horizontal_align = "right", horizontally_stretchable = false, width = 100 },
              lose_focus_on_confirm = true,
              clear_and_focus_on_right_click = true,
              text = "0",
              numeric = not enable_expressions,
              allow_decimal = false,
              allow_negative = true,
              handler = {
                [defines.events.on_gui_text_changed] = handlers.signal_value_changed,
                [defines.events.on_gui_confirmed] = handlers.signal_value_confirmed
              },
              tags = {
                allow_decimal = true,
                allow_negative = true,
                min = constants.INT32_MIN,
                max = constants.INT32_MAX
              }
            },
            {
              type = "label",
              style_mods = { top_margin = 5 },
              caption = { "cybersyn-combinator-window.items" }
            },
            {
              type = "textfield",
              name = "signal_value_items",
              enabled = false,
              style_mods = { horizontal_align = "right", horizontally_stretchable = false, width = 100 },
              lose_focus_on_confirm = true,
              clear_and_focus_on_right_click = true,
              text = "0",
              numeric = not enable_expressions,
              allow_decimal = false,
              allow_negative = true,
              handler = {
                [defines.events.on_gui_text_changed] = handlers.signal_value_changed,
                [defines.events.on_gui_confirmed] = handlers.signal_value_confirmed
              },
              tags = {
                allow_decimal = false,
                allow_negative = true,
                min = constants.INT32_MIN,
                max = constants.INT32_MAX
              }
            },
            {
              type = "sprite-button",
              name = "signal_value_confirm",
              style = "item_and_count_select_confirm",
              sprite = "utility/check_mark",
              enabled = false,
              mouse_button_filter = { "left" },
              handler = {
                [defines.events.on_gui_click] = handlers.signal_value_confirm
              }
            }
          }
        }
      }
    }

    local main_view = {
      type = "flow",
      direction = "vertical",
      style_mods = { left_margin = 8 },
      children = {
        { -- status, preview, CS signals
          type = "flow",
          direction = "horizontal",
          children = {
            status_and_preview,
            cs_signals_pane
          }
        },
        {
          type = "flow",
          direction = "horizontal",
          style_mods = { top_margin = 8 },
          children = {
            on_off,
            request_totals
          }
        },
        { -- Separator
          type = "line",
          style_mods = { top_margin = 5 }
        },
        signals_container
      }
    }

    ---@type string
    local description

    if entity.name == "entity-ghost" then
      if not entity.tags then
        entity.tags = { description = "" }
      end
      description = entity.tags.description or "" --[[@as string]]
    else
      description = entity.combinator_description
    end

    local has_description = description ~= ""

    local description_container = {
      type = "flow",
      direction = "vertical",
      children = {
        {
          type = "button",
          name = "add_description_button",
          caption = { "gui-edit-label.add-description" },
          visible = not has_description,
          mouse_button_filter = { "left" },
          handler = {
            [defines.events.on_gui_click] = handlers.description_edit_click
          }
        },
        {
          type = "flow",
          name = "description_header",
          direction = "horizontal",
          visible = has_description,
          children = {
            {
              type = "label",
              style = "semibold_label",
              caption = { "description.player-description" }
            },
            {
              type = "sprite-button",
              style = "mini_button_aligned_to_text_vertically",
              sprite = "utility/rename_icon",
              mouse_button_filter = { "left" },
              handler = {
                [defines.events.on_gui_click] = handlers.description_edit_click
              }
            }
          }
        },
        {
          type = "scroll-pane",
          name = "description_scroll",
          direction = "vertical",
          visible = has_description,
          style = "shallow_scroll_pane",
          style_mods = {
            width = description_width,
            minimal_height = 100,
            maximal_height = 200
          },
          children = {
            {
              type = "label",
              name = "description_label",
              caption = description,
              style_mods = {
                horizontally_squashable = false,
                single_line = false
              }
            }
          }
        }
      }
    }

    named, main_window = flib_gui.add(screen, {
      {
        type = "frame",
        direction = "vertical",
        name = WINDOW_ID,
        tags = {
          unit_number = entity.unit_number
        },
        style_mods = {
          maximal_height = 1290
        },
        children = {
          titlebar,
          { -- Content
            type = "frame",
            direction = "vertical",
            style = "entity_frame",
            children = {
              connection_header,
              {
                type = "flow",
                direction = "horizontal",
                children = {
                  network_list,
                  main_view
                }
              },
              { type = "line" },
              description_container
            }
          }
        }
      }
    })
  end

  ---@type LuaGuiElement.add_param.flow
  local connection_header_items = named.connection_header_items

  local red = entity.get_circuit_network(defines.wire_connector_id.circuit_red)
  local green = entity.get_circuit_network(defines.wire_connector_id.circuit_green)
  local red_id = red and red.valid and red.network_id or nil
  local green_id = green and green.valid and green.network_id or nil

  if not red_id and not green_id then
    flib_gui.add(connection_header_items, {
      type = "label",
      style = "subheader_label",
      caption = { "gui.not-connected" }
    })
  else
    flib_gui.add(connection_header_items, {
      type = "label",
      style = "subheader_label",
      caption = { "gui-control-behavior.connected-to-network" }
    })

    if red_id then
      flib_gui.add(connection_header_items, {
        type = "label",
        caption = { "", { "gui-control-behavior.red-network-id", red_id }, " [img=info]" },
        tooltip = { "", { "gui-control-behavior.circuit-network" }, ": ", tostring(red_id) }
      })
    end

    if green_id then
      flib_gui.add(connection_header_items, {
        type = "label",
        caption = { "", { "gui-control-behavior.green-network-id", green_id }, " [img=info]" },
        tooltip = { "", { "gui-control-behavior.circuit-network" }, ": ", tostring(green_id) }
      })
    end
  end

  local cs_signals_table = named.cs_signals_table
  if not cs_signals_table then
    error("cs_signals_table is nil")
  end
  ---@type UiState
  ---@diagnostic disable-next-line: missing-fields
  local state = {}
  for signal_name, data in pairs(config.cs_signals) do
    local default = data.default
    if settings.global[signal_name] and settings.global[signal_name].value then
      default = settings.global[signal_name].value --[[@as number]]
    end
    flib_gui.add(cs_signals_table, {
      type = "sprite",
      style = "cybersyn-combinator_cs-signal-sprite",
      sprite = "virtual-signal/" .. signal_name
    })
    flib_gui.add(cs_signals_table, {
      type = "label",
      style = "cybersyn-combinator_cs-signal-label",
      caption = { "virtual-signal-name." .. signal_name }
    })
    local _, field = flib_gui.add(cs_signals_table, {
      type = "textfield",
      name = "cybersyn-combinator_cs-signal__" .. signal_name,
      style = "cybersyn-combinator_cs-signal-text",
      text = tostring(default),
      numeric = false,
      clear_and_focus_on_right_click = true,
      lose_focus_on_confirm = true,
      handler = {
        [defines.events.on_gui_text_changed] = handlers.cs_signal_value_changed,
        [defines.events.on_gui_confirmed] = handlers.cs_signal_value_confirmed
      },
      tags = {
        signal_name = signal_name,
        allow_decimal = false,
        allow_negative = data.min < 0,
        min = data.min,
        max = data.max
      }
    })
    local _, reset = flib_gui.add(cs_signals_table, {
      type = "sprite-button",
      style = "cybersyn-combinator_cs-signal-reset",
      sprite = "utility/reset",
      tooltip = { "cybersyn-combinator-window.cs-signal-reset" },
      mouse_button_filter = { "left" },
      handler = {
        [defines.events.on_gui_click] = handlers.cs_signal_reset
      },
      tags = {
        signal_name = signal_name
      }
    })
    state[signal_name] = field
    state[signal_name .. "_reset"] = reset
  end

  local preview = named.preview
  preview.entity = entity
  main_window.force_auto_center()

  state.main_window = main_window
  state.status_sprite = named.status_sprite
  state.status_label = named.status_label
  state.entity_preview = preview
  state.cs_signals_group_checkbox = named.cs_signals_group_checkbox
  state.on_off = named.on_off
  state.item_total_label = named.item_total
  state.item_stacks_label = named.item_stacks
  state.fluid_total_label = named.fluid_total
  state.section_container = named.section_container
  state.signal_value_stacks = named.signal_value_stacks
  state.signal_value_items = named.signal_value_items
  state.signal_value_confirm = named.signal_value_confirm
  state.entity = entity
  state.network_mask = {
    section_group_checkbox = named.network_list_group_checkbox,
    list = named.network_list,
    signal_button = named.network_mask_signal_button,
    textfield = named.network_mask_textfield,
    add_button = named.network_mask_add_button
  }

  state.add_description_button = named.add_description_button
  state.description_header = named.description_header
  state.description_scroll = named.description_scroll
  state.description_label = named.description_label

  return state
end

--- @param player_index uint?
--- @param entity LuaEntity
--- @return boolean
function cc_gui:open(player_index, entity)
  if not player_index then return false end
  local player = game.get_player(player_index)
  if not player then return false end
  if not entity or not entity.valid then return false end
  local screen = player.gui.screen
  if screen[WINDOW_ID] then
    if screen[WINDOW_ID].tags.unit_number == entity.unit_number then
      player.opened = screen[WINDOW_ID]
      return true
    end
    self:close(player_index)
  end
  log:debug("GUI open for entity ", entity.unit_number, ", player index ", player_index)

  local combinator = CybersynCombinator:new(entity)
  local state = create_window(player, combinator)
  state.combinator = combinator

  if not combinator then
    log:error("Failed to create combinator object")
  end

  state.on_off.switch_state = combinator:is_enabled() and "right" or "left"

  update_cs_signals(state)
  update_signal_sections(state, true)
  refresh_network_list(player_index, state)

  set_player_state(player_index, state)

  update_totals(state)

  player.opened = state.main_window
  return true
end

--- @param player_index string|uint?
function cc_gui:close(player_index, silent)
  if not player_index then return end
  local player = game.get_player(player_index)
  if not player then return end
  log:debug("GUI close, player index ", player_index)
  local destroyed = destroy(player, WINDOW_ID)
  local player_data = cc_util.get_player_data(player_index)
  if player_data and player_data.state and player_data.state.combinator then
    player_data.state.combinator:validate()
    player_data.state = nil
  end
  if not destroyed then return end
  if not silent then
    player.play_sound { path = constants.ENTITY_CLOSE_SOUND }
  end
end

--- @param event EventData.on_gui_opened
function cc_gui:on_gui_opened(event)
  local entity = event.entity
  if not entity or not entity.valid then return end
  local player_index = event.player_index
  local player = game.get_player(player_index)
  if not player then return end
  local screen = player.gui.screen
  local name = entity.name == "entity-ghost" and entity.ghost_name or entity.name
  if name ~= constants.ENTITY_NAME then
    if screen[WINDOW_ID] then
      self:close(player_index)
    end
    return
  end
  log:debug("on_gui_opened: opening")
  self:open(player_index, entity)
end

--- @param event EventData.on_gui_closed
function cc_gui:on_gui_closed(event)
  local element = event.element
  if not element then return end
  local player_index = event.player_index
  local player = game.get_player(player_index)
  if not player then return end
  local state = get_player_state(player_index)
  local screen = player.gui.screen
  if DIALOG_IDS[element.name] then
    log:debug("dialog is closing")
    if screen[LOGI_GROUP_EDIT_ID] and screen[DIMMER_ID] and state and state.logistic_group_edit then
      local is_searching = state.logistic_group_edit.search_textfield.visible
      local confirmed = state.logistic_group_edit.confirmed
      if is_searching and not confirmed and not state.dialog_close_clicked then
        toggle_logistic_group_search(state)
        player.opened = state.logistic_group_edit.dialog
        return
      end
    end
    destroy(player, element.name)
    destroy(player, DIMMER_ID)
    if state then
      state.encoder = nil
      state.description_edit = nil
      state.logistic_group_edit = nil
      state.dialog_close_clicked = false
      if state.main_window then
        state.main_window.visible = true
        log:debug("opening main window back")
        player.opened = state.main_window
      end
    end
    return
  end
  if element.name ~= WINDOW_ID then return end
  if state then
    state.dialog_close_clicked = false
    if state.encoder or state.description_edit or state.logistic_group_edit then return end
    if state.selected_section_index or state.selected_slot or state.selected_slot_button then
      player.opened = state.main_window
      state.selected_section_index = nil
      state.selected_slot = nil
      state.selected_slot_button = nil
      return
    end
  end
  self:close(player_index)
end

--- @param event EventData.CustomInputEvent
function cc_gui:on_input_close(event)
  local state = get_player_state(event.player_index)
  if not state then return end
  local player = game.get_player(event.player_index)
  if not player then return end
  local screen = player.gui.screen
  if screen[ENCODER_ID] or screen[DESC_EDIT_ID] or screen[LOGI_GROUP_EDIT_ID] then return end
  if screen[WINDOW_ID] then self:close(event.player_index, false) end
end

--- @param event EventData.CustomInputEvent
function cc_gui:on_input_confirm(event)
  local state = get_player_state(event.player_index)
  if not state then return end
  local player = game.get_player(event.player_index)
  if not player then return end
  local screen = player.gui.screen
  local encoder = screen[ENCODER_ID]
  if encoder and state.encoder then
    confirm_encoder(event.player_index, false)
    return
  end
  local desc_edit = screen[DESC_EDIT_ID]
  if desc_edit and state.description_edit then
    confirm_description(event.player_index, false)
    return
  end
  local lg_edit = screen[LOGI_GROUP_EDIT_ID]
  if lg_edit and state.logistic_group_edit then
    local is_searching = state.logistic_group_edit.search_textfield.visible
    confirm_logistic_group(event.player_index, false)
    return
  end
  ---@type LuaGuiElement?
  local window = screen[WINDOW_ID]
  if window and state.selected_section_index and state.selected_slot then
    log:debug("input_confirm from ", event.player_index)
    confirm_signal_value(event.player_index, state, false)
  end
end

--- @param event EventData.CustomInputEvent
function cc_gui:on_focus_search(event)
  local state = get_player_state(event.player_index)
  if not state then return end
  local player = game.get_player(event.player_index)
  if not player then return end
  local screen = player.gui.screen
  if not screen[LOGI_GROUP_EDIT_ID] then return end
  if not state.logistic_group_edit then return end
  set_logistic_group_search(state, true)
end

---@param entity LuaEntity?
function cc_gui:on_entity_built(entity)
  if not entity then return end
  local unit_number = entity.unit_number
  ---@type uint?
  local ghost_unit_number = nil
  if entity.name == "entity-ghost" then
    ghost_unit_number = entity.ghost_unit_number
  end
  if not unit_number and not ghost_unit_number then return end
  log:debug("entity built: ", unit_number, " (", ghost_unit_number, ")")
  for _, player in pairs(game.players) do
    if not player or not player.valid then goto continue end
    local screen = player.gui.screen
    local window = screen[WINDOW_ID]
    if not window or not window.tags.unit_number then goto continue end
    log:debug("current window unit number: ", window.tags.unit_number)
    if window.tags.unit_number == unit_number or window.tags.unit_number == ghost_unit_number then
      log:debug("closing window")
      self:close(player.index)
      goto continue
    end
    local state = get_player_state(player)
    if state and (not state.entity or not state.entity.valid) then
      log:debug("closing window, entity no longer valid")
      self:close(player.index)
    end
    ::continue::
  end
end

--- @param unit_number uint?
function cc_gui:on_entity_destroyed(unit_number)
  if not unit_number then return end
  for _, player in pairs(game.players) do
    if not player then goto continue end
    local screen = player.gui.screen
    local window = screen[WINDOW_ID]
    if not window then goto continue end
    log:debug("current window unit number: ", window.tags.unit_number)
    if window.tags.unit_number == unit_number then
      log:debug("closing window")
      self:close(player.index)
    end

    ::continue::
  end
end

function cc_gui:register()
  flib_gui.add_handlers(handlers)
  flib_gui.handle_events()
  script.on_event(defines.events.on_gui_opened, function(event) self:on_gui_opened(event) end)
  script.on_event(defines.events.on_gui_closed, function(event) self:on_gui_closed(event) end)
  script.on_event(constants.MOD_NAME .. "-toggle-menu",
    function(event) self:on_input_close(event --[[@as EventData.CustomInputEvent]]) end)
  script.on_event(constants.MOD_NAME .. "-confirm-gui",
    function(event) self:on_input_confirm(event --[[@as EventData.CustomInputEvent]]) end)
  script.on_event(constants.MOD_NAME .. "-focus-search",
    function(event) self:on_focus_search(event --[[@as EventData.CustomInputEvent]]) end)
end

return cc_gui
