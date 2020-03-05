--[[ Copyright (c) 2020 robot256 (MIT License)
 * Project: Robot256's Library
 * File: event_filters.lua
 * Description: Functions for creating different types of event filter structures.
 * Arguments:  Arbitrary list of strings or tables.
 --]]
 
 
local function generateNameFilter(...)
  local args = {...}
  local f = {}
  for _,arg in pairs(args) do
    if type(arg) == "table" then
      for _,entry in pairs(arg) do
        table.insert(f, {filter="name", name=entry, mode="or"})
      end
    else
      table.insert(f, {filter="name", name=arg, mode="or"})
    end
  end
  return f
end

local function generateGhostFilter(...)
  local args = {...}
  local f = {}
  for _,arg in pairs(args) do
    if type(arg) == "table" then
      for _,entry in pairs(arg) do
        table.insert(f, {filter="ghost_name", name=entry, mode="or"})
      end
    else
      table.insert(f, {filter="ghost_name", name=arg, mode="or"})
    end
  end
  return f
end

return {
  generateNameFilter = generateNameFilter,
  generateGhostFilter = generateGhostFilter
}
