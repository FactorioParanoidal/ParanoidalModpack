local constants = require "scripts.constants"
local config = require "scripts.config"
local log = require("scripts.logger").combinator.class

--- @type Signal
--- @diagnostic disable-next-line assign-type-mismatch
local EMPTY_SIGNAL = { signal = nil, count = 0 }

local CYBERSYN_SECTION_ID = 2
local NETWORK_SECTION_ID = 3

--- @class CybersynCombinator
--- @field entity LuaEntity
local CC = {
  CYBERSYN_SECTION_ID = CYBERSYN_SECTION_ID,
  NETWORK_SECTION_ID = NETWORK_SECTION_ID
}

local CC_meta = {
  __index = CC
}

script.register_metatable("CybersynCombinator_meta", CC_meta)

--- @param name string?
--- @return boolean
local function should_emit_default(name)
  local is_r = name == constants.SETTINGS.CS_REQUEST_THRESHOLD
  local is_fr = name == constants.SETTINGS.CS_FLUID_REQUEST_THRESHOLD
  local is_p = name == constants.SETTINGS.CS_PRIORITY
  local is_l = name == constants.SETTINGS.CS_LOCKED_SLOTS
  local is_f = name == constants.SETTINGS.CS_RESERVED_FLUID_CAPACITY
  local e_r = settings.global[constants.SETTINGS.EMIT_DEFAULT_REQUEST_THRESHOLD].value
  local e_fr = settings.global[constants.SETTINGS.EMIT_DEFAULT_FLUID_REQUEST_THRESHOLD].value
  local e_p = settings.global[constants.SETTINGS.EMIT_DEFAULT_PRIORITY].value
  local e_l = settings.global[constants.SETTINGS.EMIT_DEFAULT_LOCKED_SLOTS].value
  local e_f = settings.global[constants.SETTINGS.EMIT_DEFAULT_RESERVED_FLUID_CAPACITY].value

  return (is_r and e_r == true)
      or (is_fr and e_fr == true)
      or (is_p and e_p == true)
      or (is_l and e_l == true)
      or (is_f and e_f == true)
end

--- @param entity LuaEntity
--- @param sort_all boolean? `true` if all signals should be sorted, otherwise `false` or `nil`.
--- @return CybersynCombinator
function CC:new(entity, sort_all)
  if not entity or not entity.valid then
    log:error("new: entity must be valid")
    error("CybersynCombinator:new: entity must be valid")
  end
  local name = entity.name == "entity-ghost" and entity.ghost_name or entity.name
  if name ~= constants.ENTITY_NAME then
    log:error("new: entity must be valid instance of ", constants.ENTITY_NAME, ", but ", entity.name, " was passed")
    error("CybersynCombinator:new: entity has to be a valid instance of " .. constants.ENTITY_NAME)
  end

  local instance = setmetatable({ entity = entity }, CC_meta)

  instance:validate(sort_all)

  return instance
end

--- Ensures class instance uses the correct metatable instance
--- (the one that has been registered with the game).
---
--- The only purpose is usage in migration.
function CC:ensure_metatable()
  setmetatable(self, CC_meta)
end

--- @param sort_all boolean?
function CC:validate(sort_all)
  if not self:is_valid_entity() then return end

  if sort_all then
    self:sort_signals()
  end

  self:sort_network_signals()
  self:validate_cs_signals()
end

--- @return boolean
function CC:is_enabled()
  if not self:is_valid_entity() then return false end
  local control = self:get_control_behavior()
  if not control then return false end
  return control.enabled
end

--- @param enabled boolean
function CC:set_enabled(enabled)
  if not self:is_valid_entity() then return end
  local control = self:get_control_behavior()
  if not control then return end
  control.enabled = enabled
end

function CC:enable() self:set_enabled(true) end

function CC:disable() self:set_enabled(false) end

function CC:is_ghost()
  return self.entity.name == "entity-ghost"
end

--- @return string
function CC:get_description()
  return self.entity.combinator_description
end

--- @param description string
function CC:set_description(description)
  self.entity.combinator_description = description
end

---@param control LuaConstantCombinatorControlBehavior?
---@param exclude_section LuaLogisticSection?
---@param signal_predicate fun(signal: SignalFilter): boolean
---@return LuaLogisticSection?
local function try_get_section(control, exclude_section, signal_predicate)
  if not control or not control.valid then return end
  if control.sections_count == 0 then return end
  local valid_empty_section = nil
  for _, section in pairs(control.sections) do
    if not section or not section.valid then goto continue end
    if section.filters_count == 0 then
      if not valid_empty_section and section.group == "" and section ~= exclude_section then
        valid_empty_section = section
      end
      goto continue
    end
    local found = true
    for _, filter in pairs(section.filters) do
      if not filter then goto f_continue end
      local value = filter.value
      if not value or not value.name then goto f_continue end
      if not signal_predicate(value) then
        found = false
        break
      end
      ::f_continue::
    end
    if found then return section end
    ::continue::
  end
  if valid_empty_section then return valid_empty_section end
end

--- @param id integer
--- @return LuaLogisticSection? section
function CC:get_or_create_section(id)
  if not self:is_valid_entity() then return nil end
  local control = self:get_control_behavior()
  if not control then return nil end
  if not storage.combinator_sections then
    storage.combinator_sections = {}
  end
  local unit_number = self.entity.unit_number
  if not unit_number then return nil end
  if not storage.combinator_sections[unit_number] then
    storage.combinator_sections[unit_number] = {}
  end
  local section = storage.combinator_sections[unit_number][id]
  if section and section.valid then
    return section
  end
  if id == CYBERSYN_SECTION_ID then
    section = try_get_section(control, storage.combinator_sections[unit_number][NETWORK_SECTION_ID], function(signal)
      local cs_signal = config.cs_signals[signal.name]
      return signal.type == "virtual" and cs_signal ~= nil
    end)
  elseif id == NETWORK_SECTION_ID then
    section = try_get_section(control, storage.combinator_sections[unit_number][CYBERSYN_SECTION_ID], function(signal)
      local cs_signal = config.cs_signals[signal.name]
      return signal.type == "virtual" and not cs_signal
    end)
  end
  if not section or not section.valid then
    section = control.add_section()
  end
  storage.combinator_sections[unit_number][id] = section

  if not section then
    log:error("get_or_create_section: failed to create section")
  end

  return section
end

---@param id integer
---@param index integer
function CC:set_section_index(id, index)
  if not self:is_valid_entity() then return end
  local control = self:get_control_behavior()
  if not control then return end
  if not storage.combinator_sections then
    storage.combinator_sections = {}
  end
  local unit_number = self.entity.unit_number
  if not unit_number then return end
  if not storage.combinator_sections[unit_number] then
    storage.combinator_sections[unit_number] = {}
  end
  local section = control.get_section(index)
  if not section then return end
  storage.combinator_sections[unit_number][id] = section
end

--- @param name string
--- @return integer?
function CC:get_cs_value(name)
  if not self:is_valid_entity() then return 0 end
  if not config.cs_signals[name] then
    log:warn("get_cs_value: ", name, " is not a valid cybersyn signal")
    return nil
  end

  local section = self:get_or_create_section(CYBERSYN_SECTION_ID)
  if not section then return nil end
  local filter = section.get_slot(config.cs_signals[name].slot)
  if not filter or not filter.value or not filter.min then
    return config.cs_signals[name].default
  end

  return filter.min
end

--- @param name string
--- @param value integer?
--- @return boolean success
--- @return string? error_msg
function CC:set_cs_value(name, value)
  if not self:is_valid_entity() then return false end
  if not config.cs_signals[name] then
    log:warn("set_cs_value: ", name, " is not a valid cybersyn signal")
    return false
  end

  local slot = config.cs_signals[name].slot

  local section = self:get_or_create_section(CYBERSYN_SECTION_ID)
  if not section then return false end

  if value then
    local filter = {
      value = {
        type = "virtual",
        name = name,
        quality = "normal"
      },
      min = value
    }

    local success, error = pcall(section.set_slot, slot, filter)

    if not success then
      return false, type(error) == "string" and error or serpent.line(error)
    end
  else
    section.clear_slot(slot)
  end

  self:validate_cs_signals()

  return true
end

--- @param name string
--- @return boolean success
--- @return string? error_msg
function CC:reset_cs_value(name)
  if not config.cs_signals[name] then
    log:warn("reset_cs_value: ", name, " is not a valid cybersyn signal")
    return false
  end

  return self:set_cs_value(name, config.cs_signals[name].default)
end

--- @param name string
function CC:remove_cs_value(name)
  self:set_cs_value(name, nil)
end

function CC:get_item_section(index)
  if not self:is_valid_entity() then return nil end
  local control = self:get_control_behavior()
  if not control then return nil end
  return control.get_section(index)
end

function CC:get_item_section_count()
  if not self:is_valid_entity() then return 0 end
  local control = self:get_control_behavior()
  if not control then return 0 end
  self:get_or_create_section(CYBERSYN_SECTION_ID)
  self:get_or_create_section(NETWORK_SECTION_ID)
  if control.sections_count < 2 then return 0 end
  return control.sections_count - 2
end

---@param group string?
---@return LuaLogisticSection?
function CC:add_item_section(group)
  if not self:is_valid_entity() then return end
  local control = self:get_control_behavior()
  if not control or not control.valid then return end
  return control.add_section(group)
end

---@param index integer
function CC:remove_item_section(index)
  if not self:is_valid_entity() then return end
  local control = self:get_control_behavior()
  if not control or not control.valid then return end
  control.remove_section(index)
end

function CC:remove_item_sections()
  if not self:is_valid_entity() then return end
  local control = self:get_control_behavior()
  if not control or not control.valid then return end
  local cs_sec = self:get_or_create_section(CYBERSYN_SECTION_ID)
  local net_sec = self:get_or_create_section(NETWORK_SECTION_ID)
  local index = 1
  for _ = 1, control.sections_count do
    local section = control.get_section(index)
    if section == cs_sec or section == net_sec then
      index = index + 1
    else
      control.remove_section(index)
    end
  end
end

---@return fun(sections: LuaLogisticSection[], index: integer): integer?, LuaLogisticSection?
---@return LuaLogisticSection[]?
---@return integer?
function CC:iter_item_sections()
  if not self:is_valid_entity() then return function() end, nil, nil end
  local control = self:get_control_behavior()
  if not control or not control.valid then return function() end, nil, nil end
  local cs_sec = self:get_or_create_section(CYBERSYN_SECTION_ID)
  local net_sec = self:get_or_create_section(NETWORK_SECTION_ID)
  local sections = control.sections

  return function(t, k)
    k = k + 1
    local section = t[k]
    if not section then return end
    while not section.valid or section == cs_sec or section == net_sec do
      k = k + 1
      section = t[k]
      if not section then return end
    end
    return k, section
  end, sections, 0
end

---@param section_index integer?
---@param slot uint?
---@return Signal
function CC:get_item_slot(section_index, slot)
  if not section_index then return EMPTY_SIGNAL end
  if not slot then return EMPTY_SIGNAL end
  if not self:is_valid_entity() then return EMPTY_SIGNAL end
  local section = self:get_item_section(section_index)
  if not section then return EMPTY_SIGNAL end
  local filter = section.get_slot(slot)
  if not filter or not filter.value or not filter.min then return EMPTY_SIGNAL end
  return { signal = filter.value, count = filter.min }
end

---@param section_index integer?
---@param slot uint?
---@param signal Signal
function CC:set_item_slot(section_index, slot, signal)
  if not section_index then return end
  if not slot then return end
  if not self:is_valid_entity() then return end
  local section = self:get_item_section(section_index)
  if not section then return end
  ---@type LogisticFilter
  local filter = {
    value = {
      type = signal.signal.type,
      name = signal.signal.name,
      ---@diagnostic disable-next-line: undefined-field
      quality = signal.signal.quality or "normal"
    },
    min = signal.count
  }
  section.set_slot(slot, filter)
end

---@param section_index integer?
---@param slot uint?
---@param value integer
---@return boolean success
---@return string? error
function CC:set_item_slot_value(section_index, slot, value)
  if not section_index then return false end
  if not slot then return false end
  if not self:is_valid_entity() then return false end
  local section = self:get_item_section(section_index)
  if not section then return false end
  local filter = section.get_slot(slot)
  if not filter or not filter.value then return false end
  filter.min = value
  if filter.max and filter.min > filter.max then
    filter.max = filter.min
  end
  if filter.value.comparator ~= "=" and filter.min ~= 0 then
    filter.value.comparator = "="
  end

  local success, error = pcall(section.set_slot, slot, filter)

  if success then return true end

  return false, type(error) == "string" and error or serpent.line(error)
end

---@param section_index integer?
---@param slot uint?
function CC:remove_item_slot(section_index, slot)
  if not section_index then return end
  if not slot then return end
  if not self:is_valid_entity() then return end
  local section = self:get_item_section(section_index)
  if not section then return end
  section.clear_slot(slot)
end

---@param section_index integer
function CC:clear_item_slots(section_index)
  if not self:is_valid_entity() then return end
  local control = self:get_control_behavior()
  if not control or not control.valid then return end
  local section = control.get_section(section_index)
  if not section or not section.valid then return end
  for i = section.filters_count, 1, -1 do
    section.clear_slot(i)
  end
end

---@param signal SignalID|table|string
---@param section_index integer
---@param exclude_slot uint?
---@return boolean, integer?
function CC:has_item_signal(signal, section_index, exclude_slot)
  if not self:is_valid_entity() then return false end
  if type(signal) == "string" then signal = { name = signal } end
  if not signal or not signal.name then return false end
  local section = self:get_item_section(section_index)
  if not section then return false end
  local signal_quality = signal.quality or "normal"
  local signal_type = signal.type or "item"
  for filter_index, filter in pairs(section.filters) do
    if not filter or not filter.value or filter_index == exclude_slot then goto continue end
    if filter.value.name ~= signal.name then goto continue end
    local filter_quality = filter.value.quality or "normal"
    local filter_type = filter.value.type or "item"
    if filter_quality == signal_quality and filter_type == signal_type then
      return true, filter_index
    end
    ::continue::
  end
  return false
end

--- @param slot uint?
--- @return Signal
function CC:get_network_slot(slot)
  return self:get_slot(slot, NETWORK_SECTION_ID)
end

--- @param slot uint?
--- @param signal Signal
function CC:set_network_slot(slot, signal)
  self:set_slot(slot, signal, NETWORK_SECTION_ID)
  self:sort_network_signals()
end

--- @param slot uint?
--- @param value integer
--- @return boolean success
--- @return string? error_msg
function CC:set_network_slot_value(slot, value)
  return self:set_slot_value(slot, value, NETWORK_SECTION_ID)
end

--- @param slot uint?
function CC:remove_network_slot(slot)
  self:remove_slot(slot, NETWORK_SECTION_ID)
  self:sort_network_signals()
end

--- @return Signal[]
function CC:get_network_signals()
  local signals = {}
  local section = self:get_or_create_section(NETWORK_SECTION_ID)
  if not section then return signals end
  for _, filter in pairs(section.filters) do
    local value = filter.value
    if value and value.name then
      signals[#signals + 1] = {
        signal = value,
        count = filter.min
      }
    end
  end
  return signals
end

--- @param signal Signal
function CC:add_or_update_network_signal(signal)
  self:sort_network_signals()
  ---@diagnostic disable-next-line: undefined-field
  local quality = signal.signal.quality or "normal"
  local signals = self:get_network_signals()
  for slot, existing in ipairs(signals) do
    ---@diagnostic disable-next-line: undefined-field
    local e_quality = existing.signal.quality or "normal"
    if existing.signal.type == signal.signal.type and existing.signal.name == signal.signal.name and e_quality == quality then
      self:set_network_slot_value(slot --[[@as uint]], signal.count)
      return
    end
  end
  local slot = #signals --[[@as uint]] + 1
  self:set_network_slot(slot, signal)
end

--- @private
--- @param slot uint?
--- @param section_id integer
--- @return Signal
function CC:get_slot(slot, section_id)
  if not self:is_valid_entity() then return EMPTY_SIGNAL end
  if not slot then return EMPTY_SIGNAL end
  local section = self:get_or_create_section(section_id)
  if not section then return EMPTY_SIGNAL end
  local filter = section.get_slot(slot)
  if not filter or not filter.value or not filter.min then return EMPTY_SIGNAL end
  return { signal = filter.value, count = filter.min }
end

--- @param slot uint?
--- @param signal Signal
--- @param section_id integer
function CC:set_slot(slot, signal, section_id)
  if not self:is_valid_entity() then return end
  if not slot then return end
  local section = self:get_or_create_section(section_id)
  if not section then return end
  local filter = {
    value = {
      type = signal.signal.type,
      name = signal.signal.name,
      ---@diagnostic disable-next-line: undefined-field
      quality = signal.signal.quality or "normal"
    },
    min = signal.count
  }
  section.set_slot(slot, filter)
end

--- @param slot uint?
--- @param value integer
--- @param section_id integer
--- @return boolean success
--- @return string? error_msg
function CC:set_slot_value(slot, value, section_id)
  if not self:is_valid_entity() then return false end
  if not slot then return false end
  local section = self:get_or_create_section(section_id)
  if not section then return false end
  local filter = section.get_slot(slot)
  if not filter or not filter.value then return false end
  filter.min = value
  if filter.max and filter.min > filter.max then
    filter.max = filter.min
  end
  if filter.value.comparator ~= "=" and filter.min ~= 0 then
    filter.value.comparator = "="
  end

  local success, error = pcall(section.set_slot, slot, filter)

  if success then return true end

  return false, type(error) == "string" and error or serpent.line(error)
end

--- @param slot uint?
--- @param section_id integer
function CC:remove_slot(slot, section_id)
  if not self:is_valid_entity() then return end
  if not slot then return end
  local section = self:get_or_create_section(section_id)
  if not section then return end
  section.clear_slot(slot)
end

--- @param section_id integer
function CC:clear_section(section_id)
  if not self:is_valid_entity() then return end
  local section = self:get_or_create_section(section_id)
  if not section then return end
  for i = section.filters_count, 1, -1 do
    section.clear_slot(i)
  end
end

--- @param signal SignalID|table|string
--- @param section_id integer
--- @param exclude_slot uint?
--- @return boolean, integer?
function CC:has_signal(signal, section_id, exclude_slot)
  if not self:is_valid_entity() then return false end
  if type(signal) == "string" then signal = { name = signal } end
  if not signal or not signal.name then return false end
  local section = self:get_or_create_section(section_id)
  if not section then return false end
  local signal_quality = signal.quality or "normal"
  for filter_index, filter in pairs(section.filters) do
    if not filter or not filter.value or filter_index == exclude_slot then goto continue end
    if filter.value.name ~= signal.name then goto continue end
    local filter_quality = filter.value.quality or "normal"
    if filter_quality == signal_quality then return true, filter_index end
    ::continue::
  end
  return false
end

--- @private
function CC:is_valid_entity()
  return self.entity and self.entity.valid
end

--- @private
--- @return LuaConstantCombinatorControlBehavior?
function CC:get_control_behavior()
  if not self:is_valid_entity() then
    log:warn("get_control_behavior: entity is not valid")
    return nil
  end
  local control = self.entity.get_or_create_control_behavior()
  if not control then
    log:warn("get_control_behavior: control behavior is nil")
    return nil
  end
  if control.type ~= defines.control_behavior.type.constant_combinator then
    log:warn("get_control_behavior: unexpected type. expected constant combinator but was ", control.type)
    return nil
  end

  return control --[[@as LuaConstantCombinatorControlBehavior]]
end

function CC:validate_cs_signals()
  if not self:is_valid_entity() then return end

  local section = self:get_or_create_section(CYBERSYN_SECTION_ID)
  if not section then return end
  for i, filter in pairs(section.filters) do
    local value = filter.value
    if not value or not value.name then goto continue end
    local type = value.type
    local name = value.name
    local cs_signal = config.cs_signals[name]

    if type ~= "virtual" or not cs_signal then
      section.clear_slot(i)
      goto continue
    end

    local emit_default = should_emit_default(name)

    if not filter.min or filter.min == 0 or (filter.min == cs_signal.default and not emit_default) then
      section.clear_slot(i)
    elseif cs_signal.slot ~= i and not section.get_slot(cs_signal.slot).value then
      section.clear_slot(i)
      section.set_slot(cs_signal.slot, filter)
    end

    ::continue::
  end
end

--- @private
function CC:sort_network_signals()
  if not self:is_valid_entity() then return end
  local section = self:get_or_create_section(NETWORK_SECTION_ID)
  if not section then return end

  local previous = {}

  for i, filter in pairs(section.filters) do
    local value = filter.value
    if value and value.name then
      previous[#previous + 1] = { value = value, min = filter.min }
    end
    section.clear_slot(i)
  end

  for i, filter in ipairs(previous) do
    section.set_slot(i, filter)
  end
end

function CC:sort_signals()
  log:debug("performing sort")
  if not self:is_valid_entity() then return end
  local control = self:get_control_behavior()
  if not control then return end

  local cs_sec = self:get_or_create_section(CYBERSYN_SECTION_ID)
  local net_sec = self:get_or_create_section(NETWORK_SECTION_ID)

  if not cs_sec or not net_sec then
    log:error("sort_signals: failed to get sections")
    return
  end

  local net_lookup = {}

  for index, filter in pairs(net_sec.filters) do
    if not filter or not filter.value or not filter.value.name then goto continue end
    local key = filter.value.name .. "__|__" .. (filter.value.quality or "normal")
    net_lookup[key] = index
    ::continue::
  end

  for _, section in pairs(control.sections) do
    if not section or not section.valid then goto continue end
    if section == cs_sec or section == net_sec then goto continue end
    if section.group ~= "" then goto continue end
    local multiplier = section.multiplier or 1
    for filter_index, filter in pairs(section.filters) do
      local value = filter.value
      if not value or not value.name then goto filter_continue end
      local type = value.type
      local name = value.name
      local count = filter.min * multiplier
      local cs_signal = config.cs_signals[name]

      if type == "virtual" and cs_signal ~= nil then
        local cs_slot = cs_signal.slot
        local cs_filter = cs_sec.get_slot(cs_slot)
        if cs_filter and cs_filter.value then
          cs_filter.min = cs_filter.min + count
          local success, error = pcall(cs_sec.set_slot, cs_slot, cs_filter)
          if not success then
            log:error("Failed to set CS signal ", serpent.line(cs_filter), " in slot ", cs_slot, ": ", serpent.line(error))
          end
        else
          local success, error_msg = self:set_cs_value(name, count)
          if not success then
            log:error("Failed to set CS signal ", name, " to ", tostring(count), ": ", error_msg)
          end
        end
        section.clear_slot(filter_index)
      elseif type == "virtual" then
        local net_key = name .. "__|__" .. (value.quality or "normal")
        local net_slot = net_lookup[net_key]
        if net_slot then
          log:debug("found net signal ", net_key, " in slot ", net_slot)
          local net_filter = net_sec.get_slot(net_slot)
          net_filter.min = net_filter.min + count
          net_sec.set_slot(net_slot, net_filter)
        else
          log:debug("net signal ", net_key, " not found, creating it")
          net_slot = net_sec.filters_count + 1
          filter.min = count
          net_sec.set_slot(net_slot, filter)
          net_lookup[net_key] = net_slot
        end
        section.clear_slot(filter_index)
      end
      ::filter_continue::
    end
    ::continue::
  end

  local section_count = control.sections_count
  local section_index = 1
  while section_index <= section_count do
    local section = control.get_section(section_index)
    if section and section.valid and section.group == "" and section.filters_count == 0 then
      control.remove_section(section_index)
    else
      section_index = section_index + 1
    end
  end
end

--- @private
--- @return boolean
function CC:needs_sorting()
  if not self:is_valid_entity() then return false end
  local control = self:get_control_behavior()
  if not control then return false end
  self:get_or_create_section(CYBERSYN_SECTION_ID)
  self:get_or_create_section(NETWORK_SECTION_ID)

  return control.sections_count > 2
end

return CC
