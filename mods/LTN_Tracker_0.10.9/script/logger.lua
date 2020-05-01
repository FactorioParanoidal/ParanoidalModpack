local class_dict = {}
local settings = {
  max_depth = 4, -- maximum depth up to which nested objects are converted
  class_dictionary = class_dict,
  }
--[[
define factorio objects and properties logger should convert to tables
Syntax:
- property_name = true
  converts Class.property_name to string and lists it under its own name
- display_name = {"property_name"}
  converts Class.property_name to string and lists it under display_name
- display_name = {"property_name", "sub_property_name"}
  converts Class.property_name.sub_property_name to string and lists it under display_name
- display_name = "method_name"
  calls Class.method_name() and converts return value to string, listed under display_name
--]]

class_dict.LuaGuiElement = {
  name = true,
  type = true,
  parent_name = {"parent", "name"},
  children_names = true,
  visible = true,
  style_name = {"style", "name"},
}
class_dict.LuaTrain = {
  id = true,
  state = true,
  contents = "get_contents",
  fluid_contents = "get_fluid_contents",
}
class_dict.LuaPlayer = {
  name = true,
  index = true,
  opened = true,
}
class_dict.LuaEntity = {
  backer_name = true,
  name = true,
  type = true,
  position = true,
}
class_dict.LuaCircuitNetwork = {
  entity = true,
  wire_type = true,
  signals = true,
  network_id = true,
}
class_dict.LuaStyle = {
  name = true,
  minimal_height = true,
  maximal_height = true,
  minimal_width = true,
  maximal_width = true,
}

-- cache functions
local match = string.match
local format = string.format
local getinfo = debug.getinfo
local log = log
local select = select
local block = serpent.block
-- custom formatting for serpent.block output when handling factorio classes
local function serpb(arg)
   return block(
    arg, {
      sortkeys = false,
      custom = (function(tag,head,body,tail)
        if tag:find('^FOBJ_') then
          --body = body:gsub("\n%s+", "")
          tag = tag:gsub("^FOBJ_", "")
          tag = tag:gsub("[%s=]", "")
          return tag..head..body..tail
        else
          return tag..head..body..tail
        end
      end)
    }
  )
end

-- read class name of a Factorio lua object from string returned by its .help() method
local function help2name(str)
  return match(str, "Help for%s([^:]*)")
end

-- Factorio lua objects are tables with key "__self" and a userdata value; most of them have a .help() method
local function is_object(tb)
  if tb["__self"] and type(tb["__self"]) == "userdata" then
    local b1, b2 = pcall(function() return tb.valid and tb.help end)
    return b1 and b2
  end
  return false
end

local function function_to_string(func)
  local info = getinfo(func, "S")
  return format("[%s]:%d", info.short_src, info.linedefined)
end

local function get_class_property(obj, property_name, property)
  local value
  if property == true then
    value = obj[property_name]
  elseif type(property) == "table" then
    value = obj
    for _,v in pairs(property) do
      value = value[v]
      if type(value) ~= "table" then
        break
      end
    end
  elseif type(property) == "string" then
    value = obj[property]()
  end
  return value
end


local function factorio_obj_to_table(obj)
  local class_name = help2name(obj.help())
  local tb = nil
  if class_dict[class_name] then
    tb = {}
    for property_name, property in pairs(class_dict[class_name]) do
      local status, value = pcall(get_class_property, obj, property_name, property)
      tb[property_name] = status and value or nil
    end
  end
  return {["FOBJ_"..class_name] = tb} -- prefix for formatting with serpent.block
end

local function table_to_string(tb, level)
  level = (level or 0) + 1
  -- check for stuff that serpent does not convert to my liking and do the conversion here
  local log_tb = {} -- copy table, otherwise logger would modify the original input table
  for k,v in pairs(tb) do
    if type(v) == "table" and is_object(v) then
      log_tb[k] = table_to_string(factorio_obj_to_table(v), level) -- yay, recursion
    elseif type(v) == "table" and level < settings.max_depth then --regular table
      log_tb[k] = table_to_string(v, level) -- more recursion
    elseif type(v) == "function" then
      v = function_to_string(v)
    else
      log_tb[k] = v
    end
  end
  if level == 1 then
    return serpb(log_tb) -- format converted table with serpent
  else
    return log_tb
  end
end

-- convert any type of argument into a human-readable string
local function _tostring(arg)
  if arg == nil then
    return "<nil>" -- otherwise the argument is just ommited
  end
  local t = type(arg)
  if t == "string" then return arg
  elseif t == "number" or t == "boolean" then return tostring(arg)
  elseif t == "function" then
    return function_to_string(arg)
  elseif t == "table" then
    if is_object(arg) then
      return table_to_string(factorio_obj_to_table(arg))
    else
      return table_to_string(arg)
    end
  elseif t == "userdata" then
    return serpb(arg)
  else
    log("Unknown data type: " .. t)
  end
end

-- main function to generate output
local function _log(...)
  local info = getinfo(2, "Sl")
  local msg_tag = format("%s:%d", info.short_src, info.currentline)

  -- build prefix
  local message = "<" .. msg_tag .. ">\n"

  -- convert all arguments to strings and concatenate
  local string_tb = {}
  for i = 1, select("#", ...) do
    string_tb[i] = _tostring(select(i, ...))
  end
  message = message .. table.concat(string_tb, " ")

  log(message)
  return message
end

return _log, settings