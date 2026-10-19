-- Geology by soil colour (Paranoidal ПР-062): ores tend to soils of a matching colour.
-- Resource placement itself belongs to the resource generator (RSO in Paranoidal); this file
-- only answers which resources suit the soil of a place. Interface:
--   remote.call("alien-biomes-reforged", "geology_bias", surface_name, tile_names)
--     tile_names: array of tile names sampled at the place
--     returns {[resource_name] = weight_multiplier} for the dominant soil, or nil when the
--     setting is off, the surface is not nauvis or no Alien Biomes soil was sampled.
-- Pure function of its arguments and a startup setting: deterministic, safe in multiplayer.

local MULTIPLIER = 2

-- soil colour -> resources (infinite variants follow their ore)
local BY_COLOUR = {
  -- sapphirite
  blue = "angels-ore1", purple = "angels-ore1", aubergine = "angels-ore1", violet = "angels-ore1", mauve = "angels-ore1",
  -- jivolite
  cream = "angels-ore2", yellow = "angels-ore2", tan = "angels-ore2",
  -- stiratite
  green = "angels-ore3", olive = "angels-ore3", turquoise = "angels-ore3",
  -- crotinnium
  grey = "angels-ore4", white = "angels-ore4",
  -- rubyte
  red = "angels-ore5", dustyrose = "angels-ore5", orange = "angels-ore5",
  -- bobmonium
  brown = "angels-ore6", beige = "angels-ore6",
  black = "coal",
}
local INFINITE = {
  ["angels-ore1"] = "infinite-angels-ore1", ["angels-ore2"] = "infinite-angels-ore2",
  ["angels-ore3"] = "infinite-angels-ore3", ["angels-ore4"] = "infinite-angels-ore4",
  ["angels-ore5"] = "infinite-angels-ore5", ["angels-ore6"] = "infinite-angels-ore6",
  coal = "infinite-coal",
}
local VOLCANIC = {"crude-oil", "angels-natural-gas", "angels-fissure"}
-- tie-break order of soil categories (most specific first)
local ORDER = {"volcanic", "black", "red", "dustyrose", "orange", "cream", "yellow", "tan", "blue", "purple",
               "aubergine", "violet", "mauve", "green", "olive", "turquoise", "grey", "white", "brown", "beige"}

local function category(tile_name)
  if tile_name:find("^volcanic%-") then return "volcanic" end
  local colour = tile_name:match("^mineral%-(%a+)%-") or tile_name:match("^vegetation%-(%a+)%-grass")
  if colour and BY_COLOUR[colour] then return colour end
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
  for _, c in ipairs(ORDER) do
    if (counts[c] or 0) > best_n then best, best_n = c, counts[c] end
  end
  if not best then return nil end
  local out = {}
  if best == "volcanic" then
    for _, r in pairs(VOLCANIC) do out[r] = MULTIPLIER end
  else
    local ore = BY_COLOUR[best]
    out[ore] = MULTIPLIER
    out[INFINITE[ore]] = MULTIPLIER
  end
  return out
end

remote.add_interface("alien-biomes-reforged", {
  geology_bias = geology_bias,
})
