local bounding_box = require("__flib__.bounding-box")
local dictionary = require("__flib__.dictionary-lite")
local format = require("__flib__.format")
local math = require("__flib__.math")
local table = require("__flib__.table")

local constants = require("constants")

local core_util = require("__core__.lualib.util")

local util = {}

--- @return AmountIdent
function util.build_amount_ident(input)
  --- @class AmountIdent
  return {
    amount = input.amount or false,
    amount_min = input.amount_min or false,
    amount_max = input.amount_max or false,
    catalyst_amount = input.catalyst_amount or false,
    probability = input.probability or false,
    format = input.format or "format_amount",
  }
end

-- HACK: Requiring `formatter` in this file causes a dependency loop
local function format_number(value)
  return format.number(math.round(value, 0.01))
end

--- @class TemperatureIdent
--- @field string string
--- @field short_string string
--- @field min double
--- @field max double

--- Builds a `TemperatureIdent` based on the fluid input/output parameters.
function util.build_temperature_ident(fluid)
  local temperature = fluid.temperature
  local temperature_min = fluid.minimum_temperature
  local temperature_max = fluid.maximum_temperature
  local temperature_string
  local short_temperature_string
  local short_top_string
  if temperature then
    temperature_string = format_number(temperature)
    short_temperature_string = core_util.format_number(temperature, true)
    temperature_min = temperature
    temperature_max = temperature
  elseif temperature_min and temperature_max then
    if temperature_min == math.min_double then
      temperature_string = "≤" .. format_number(temperature_max)
      short_temperature_string = "≤" .. core_util.format_number(temperature_max, true)
    elseif temperature_max == math.max_double then
      temperature_string = "≥" .. format_number(temperature_min)
      short_temperature_string = "≥" .. core_util.format_number(temperature_min, true)
    else
      temperature_string = "" .. format_number(temperature_min) .. "-" .. format_number(temperature_max)
      short_temperature_string = core_util.format_number(temperature_min, true)
      short_top_string = core_util.format_number(temperature_max, true)
    end
  end

  if temperature_string then
    return {
      string = temperature_string,
      short_string = short_temperature_string,
      short_top_string = short_top_string,
      min = temperature_min,
      max = temperature_max,
    }
  end
end

--- Get the "sorting number" of a temperature. Will sort in ascending order, with absolute, then min range, then max range.
--- @param temperature_ident TemperatureIdent
function util.get_sorting_number(temperature_ident)
  if temperature_ident.min == math.min_double then
    return temperature_ident.max + 0.001
  elseif temperature_ident.max == math.max_double then
    return temperature_ident.min + 0.003
  elseif temperature_ident.min ~= temperature_ident.max then
    return temperature_ident.min + 0.002
  else
    return temperature_ident.min
  end
end

function util.convert_and_sort(tbl)
  for key in pairs(tbl) do
    tbl[#tbl + 1] = key
  end
  table.sort(tbl)
  return tbl
end

function util.unique_string_array(initial_tbl)
  initial_tbl = initial_tbl or {}
  local hash = {}
  for _, value in pairs(initial_tbl) do
    hash[value] = true
  end
  return setmetatable(initial_tbl, {
    __newindex = function(tbl, key, value)
      if not hash[value] then
        hash[value] = true
        rawset(tbl, key, value)
      end
    end,
  })
end

function util.unique_obj_array(initial_tbl)
  local hash = {}
  return setmetatable(initial_tbl or {}, {
    __newindex = function(tbl, key, value)
      if not hash[value.name] then
        hash[value.name] = true
        rawset(tbl, key, value)
      end
    end,
  })
end

function util.frame_action_button(sprite, tooltip, ref, action)
  return {
    type = "sprite-button",
    style = "frame_action_button",
    sprite = sprite .. "_white",
    hovered_sprite = sprite .. "_black",
    clicked_sprite = sprite .. "_black",
    tooltip = tooltip,
    mouse_button_filter = { "left" },
    ref = ref,
    actions = {
      on_click = action,
    },
  }
end

function util.process_placed_by(prototype)
  local placed_by = prototype.items_to_place_this
  if placed_by then
    return table.map(placed_by, function(item_stack)
      return {
        class = "item",
        name = item_stack.name,
        amount_ident = util.build_amount_ident({ amount = item_stack.count }),
      }
    end)
  end
end

function util.convert_categories(source_tbl, class)
  local categories = {}
  for category in pairs(source_tbl) do
    categories[#categories + 1] = { class = class, name = category }
  end
  return categories
end

function util.convert_to_ident(class, source)
  if source then
    return { class = class, name = source }
  end
end

--- @param prototype LuaEntityPrototype
--- @return DisplayResolution?
function util.get_size(prototype)
  if prototype.selection_box then
    local box = prototype.selection_box
    return { height = math.ceil(bounding_box.height(box)), width = math.ceil(bounding_box.width(box)) }
  end
end

--- @param prototype LuaEntityPrototype
function util.process_energy_source(prototype)
  local burner = prototype.burner_prototype
  local fluid_energy_source = prototype.fluid_energy_source_prototype
  if burner then
    return util.convert_categories(burner.fuel_categories, "fuel_category")
  elseif fluid_energy_source then
    local filter = fluid_energy_source.fluid_box.filter
    if filter then
      return {}, { class = "fluid", name = filter.name }
    end
    return { { class = "fuel_category", name = "burnable-fluid" } }
  end
  return {}
end

--- Safely retrive the given GUI, checking for validity.
--- @param player_index number
--- @param gui_name string
--- @param gui_key number|string?
function util.get_gui(player_index, gui_name, gui_key)
  local player_table = global.players[player_index]
  if not player_table then
    return
  end
  local tbl = player_table.guis[gui_name]
  if not tbl then
    return
  end
  if gui_key then
    tbl = tbl[gui_key]
  end
  if tbl and tbl.refs.window and tbl.refs.window.valid then
    return tbl
  end
end

--- Dispatch the given action on all GUIs of the given name.
--- @param player_index number
--- @param gui_name string
--- @param msg string|table
function util.dispatch_all(player_index, gui_name, msg)
  local player_table = global.players[player_index]
  if not player_table then
    return
  end
  local ignored = gui_name == "info" and constants.ignored_info_ids or {}
  for key, Gui in pairs(player_table.guis[gui_name]) do
    if not ignored[key] then
      Gui:dispatch(msg)
    end
  end
end

--- Determine if the given prototype is blueprintable
--- @param prototype LuaEntityPrototype
--- @return boolean
function util.is_blueprintable(prototype)
  return prototype.has_flag("player-creation")
    and not prototype.has_flag("not-selectable-in-game")
    and not prototype.has_flag("not-blueprintable")
    and not prototype.has_flag("hidden")
end

--- Create a new dictionary only if not in on_load.
--- @param name string
--- @param initial_contents Dictionary?
function util.new_dictionary(name, initial_contents)
  if game then
    dictionary.new(name, initial_contents)
  end
end

--- Add to the dictionary only if not in on_load.
--- @param dict string
--- @param key string
--- @param localised LocalisedString
function util.add_to_dictionary(dict, key, localised)
  if game then
    -- Fall back to internal key in non-description dictionaries
    if not string.find(dict, "description") then
      localised = { "?", localised, key }
    end
    dictionary.add(dict, key, localised)
  end
end

return util
