-- Rain surfaces: allowed by the setting prain-allowed-surfaces (surface or planet names), never space platforms.
-- Cached in storage.surfaces (Dynamic Rain surface-cache); rebuilt on configuration/setting/surface changes only.
local R = require("scripts.registry")

local M = {}
R.surfaces = M

local function allowed(surface, added_by_api)
  if surface.platform then return false end
  if added_by_api then return true end
  local list = storage.cfg.allowed
  if list[surface.name] then return true end
  local planet = surface.planet
  return planet ~= nil and list[planet.name] == true
end

function M.rebuild()
  local previous = storage.surfaces and storage.surfaces.by_index or {}
  local by_index, rain = {}, {}
  for _, surface in pairs(game.surfaces) do
    if surface.valid then
      local index = surface.index
      local old = previous[index]
      local api = old and old.added_by_api or nil
      local ok = allowed(surface, api)
      by_index[index] = { surface = surface, name = surface.name, rain = ok, added_by_api = api }
      if ok then rain[#rain + 1] = index end
    end
  end
  table.sort(rain)
  storage.surfaces = { by_index = by_index, rain = rain }
end

local function cache()
  if not storage.surfaces then M.rebuild() end
  return storage.surfaces
end

-- A surface enabled by another mod (remote start_phase) keeps rain whatever the setting says.
function M.add(index)
  local c = cache()
  local entry = c.by_index[index]
  if not entry then
    local surface = game.surfaces[index]
    if not surface then return false end
    entry = { surface = surface, name = surface.name }
    c.by_index[index] = entry
  end
  entry.added_by_api = true
  if not entry.rain then
    entry.rain = true
    c.rain[#c.rain + 1] = index
    table.sort(c.rain)
  end
  return true
end

function M.rain_indices()
  return cache().rain
end

function M.is_rain(index)
  local entry = index and cache().by_index[index]
  return entry ~= nil and entry.rain == true
end

function M.get(index)
  local entry = cache().by_index[index]
  local surface = entry and entry.surface
  if surface and surface.valid then return surface end
  return nil
end

function M.name(index)
  local entry = cache().by_index[index]
  return entry and entry.name or nil
end

return M
