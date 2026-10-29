-- Creates "<name>-mu" for every placeable locomotive and records the pairs in mod-data.
-- A twin is a deep copy with max_power x shared.power_multiplier. It has no item or recipe of its own:
-- it is placed (ghosts, pipette) and mined as the normal locomotive.
local shared = require("shared")
local util = require("util")

-- Locomotives that must keep working alone (dummy or scripted entities of other mods).
local EXCLUDED = {}

local function placing_item(name, locomotive)
  local by = locomotive.placeable_by
  if by then
    local first = by.item and by or by[1]
    if first and first.item then return first.item end
  end
  local fallback
  for _, item_type in ipairs({"item-with-entity-data", "item"}) do
    for item_name, item in pairs(data.raw[item_type] or {}) do
      if item.place_result == name then
        if not item.hidden then return item_name end
        fallback = fallback or item_name
      end
    end
  end
  return fallback
end

local function watts(power)
  -- util.parse_energy returns joules per tick for a power value.
  return util.parse_energy(power) * 60
end

local locomotives = data.raw.locomotive
local sources = {}
for name, locomotive in pairs(locomotives) do
  local is_twin = name:sub(-#shared.suffix) == shared.suffix and locomotives[name:sub(1, -#shared.suffix - 1)]
  if not (is_twin or locomotive.hidden or EXCLUDED[name] or locomotives[name .. shared.suffix]) then
    local item = placing_item(name, locomotive)
    if item then
      sources[#sources + 1] = {name = name, item = item}
    else
      log("MUTC: no item places locomotive " .. name .. ", no MU twin")
    end
  end
end
table.sort(sources, function(a, b) return a.name < b.name end)

local catalog, created = {}, {}
for _, source in ipairs(sources) do
  local base = locomotives[source.name]
  local twin = table.deepcopy(base)
  twin.name = source.name .. shared.suffix
  twin.hidden = true
  twin.factoriopedia_alternative = source.name
  twin.placeable_by = base.placeable_by or {item = source.item, count = 1}
  local power = watts(base.max_power) * shared.power_multiplier
  twin.max_power = string.format("%.0fW", power)
  twin.localised_name = {"mutc.mu-name", base.localised_name or {"entity-name." .. source.name}}
  local description = base.localised_description or {"entity-description." .. source.name}
  twin.localised_description = {"?", {"", description, "\n", {"mutc.mu-description"}}, {"mutc.mu-description"}}
  data:extend({twin})
  catalog[source.name] = {
    mu = twin.name,
    bonus = math.floor((power / watts(base.max_power) - 1) * 100 + 0.5),
  }
  created[#created + 1] = twin.name
end

data:extend({{type = "mod-data", name = shared.catalog, data = catalog}})
log("MUTC: " .. #created .. " MU twins: " .. table.concat(created, ", "))
