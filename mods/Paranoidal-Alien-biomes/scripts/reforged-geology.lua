-- Geology by soil colour (Paranoidal ПР-062): ores tend to soils of a matching colour.
-- Resource placement itself belongs to the resource generator; RSO-reforged reads the noise
-- expressions of prototypes/reforged/geology.lua. This interface is kept for scripted generators:
--   remote.call("alien-biomes-reforged", "geology_bias", surface_name, tile_names)
--     tile_names: array of tile names sampled at the place
--     returns {[resource_name] = weight_multiplier} for the dominant soil, or nil when the
--     setting is off, the surface is not nauvis or no Alien Biomes soil was sampled.
-- Pure function of its arguments and a startup setting: deterministic, safe in multiplayer.
local map = require("scripts/geology-map")

local function category(tile_name)
  if tile_name:find("^volcanic%-") then return "volcanic" end
  local colour = tile_name:match("^mineral%-(%a+)%-") or tile_name:match("^vegetation%-(%a+)%-grass")
  if colour and map.BY_COLOUR[colour] then return colour end
  return nil -- snow, ice, water and foreign tiles do not bias anything
end

local function geology_bias(surface_name, tile_names)
  local setting = settings.startup["alien-biomes-reforged-geology"]
  if not (setting and setting.value) or surface_name ~= "nauvis" or type(tile_names) ~= "table" then
    return nil
  end
  local counts = {}
  for _, name in pairs(tile_names) do
    local c = type(name) == "string" and category(name)
    if c then counts[c] = (counts[c] or 0) + 1 end
  end
  local best, best_n = nil, 0
  for _, c in ipairs(map.ORDER) do
    if (counts[c] or 0) > best_n then best, best_n = c, counts[c] end
  end
  if not best then return nil end
  local out = {}
  if best == "volcanic" then
    for _, r in pairs(map.VOLCANIC) do out[r] = map.MULTIPLIER end
  else
    local ore = map.BY_COLOUR[best]
    out[ore] = map.MULTIPLIER
    out[map.INFINITE[ore]] = map.MULTIPLIER
  end
  return out
end

remote.add_interface("alien-biomes-reforged", {
  geology_bias = geology_bias,
})
