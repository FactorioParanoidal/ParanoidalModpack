-- Geology by soil colour for resource generators (Paranoidal ПР-062). Named noise expressions
--   alien-biomes-geology-<resource> = weight multiplier: MULTIPLIER where the soil colour suits
--   the resource, 1 elsewhere (RSO-reforged multiplies its resource weights by them).
-- The colour comes from the climate (temperature, moisture, aux) through the volumes of
-- biome-spec.lua, without the per-tile noise of the tiles: borders follow the climate. Grass
-- colours apply where grass prevails (moisture of the vegetation group), dirt and sand colours
-- elsewhere, volcanic ground by temperature; snow and ice favour nothing.
-- geology.boxes/geology.expressions are pure: tools/test_geology.lua checks them outside the game.
local map = require("scripts/geology-map")

local geology = {}

-- volume of a group/axis: {temperature_min = .., temperature_max = .., aux_min = .., ...}
local function constrain(volume, axes, dimensions)
  for axis_name, points in pairs(dimensions or {}) do
    local axis = axes[axis_name]
    local dim = axis.dimension
    local a, b = axis.low + (axis.high - axis.low) * points[1], axis.low + (axis.high - axis.low) * points[2]
    local lo, hi = math.min(a, b), math.max(a, b)
    volume[dim .. "_min"] = math.max(volume[dim .. "_min"] or lo, lo)
    volume[dim .. "_max"] = math.min(volume[dim .. "_max"] or hi, hi)
  end
  return volume
end

-- list of {category = colour | "volcanic", volume = ...}
function geology.boxes(spec, axes)
  local boxes = {}
  for _, group_name in ipairs({"mineral", "vegetation"}) do
    local group = spec[group_name]
    for colour, axis in pairs(group.axes) do
      if map.BY_COLOUR[colour] then
        local volume = constrain(constrain({}, axes, group.dimensions), axes, axis.dimensions)
        boxes[#boxes + 1] = {category = colour, group = group_name, volume = volume}
      end
    end
  end
  boxes[#boxes + 1] = {category = "volcanic", group = "volcanic", volume = constrain({}, axes, spec.volcanic.dimensions)}
  table.sort(boxes, function(a, b) return a.group .. a.category < b.group .. b.category end)
  return boxes
end

-- full range of every climate dimension: no condition at its ends
local function ends(axes)
  local e = {}
  for _, axis in pairs(axes) do
    local d = e[axis.dimension] or {math.huge, -math.huge}
    e[axis.dimension] = {math.min(d[1], axis.low), math.max(d[2], axis.high)}
  end
  return e
end

-- moisture from which grass prevails over dirt (lower edge of the vegetation group)
local function grass_moisture(spec, axes)
  return constrain({}, axes, spec.vegetation.dimensions).moisture_min
end

-- condition of a box as a noise expression (product of comparisons)
local function condition(box, e, grass)
  local parts = {}
  for _, dim in ipairs({"temperature", "moisture", "aux"}) do
    local lo, hi = box.volume[dim .. "_min"], box.volume[dim .. "_max"]
    if lo and lo > e[dim][1] then parts[#parts + 1] = string.format("(%s >= %g)", dim, lo) end
    if hi and hi < e[dim][2] then parts[#parts + 1] = string.format("(%s < %g)", dim, hi) end
  end
  if box.group == "mineral" then parts[#parts + 1] = string.format("(moisture < %g)", grass) end
  return #parts > 0 and table.concat(parts, " * ") or "1"
end

-- {[resource] = expression}
function geology.expressions(spec, axes)
  local e, grass = ends(axes), grass_moisture(spec, axes)
  local terms = {}
  for _, box in ipairs(geology.boxes(spec, axes)) do
    local resources = box.category == "volcanic" and map.VOLCANIC or {map.BY_COLOUR[box.category]}
    for _, resource in ipairs(resources) do
      terms[resource] = terms[resource] or {}
      table.insert(terms[resource], condition(box, e, grass))
    end
  end
  local out = {}
  for resource, list in pairs(terms) do
    out[resource] = string.format("1 + %g * (%s)", map.MULTIPLIER - 1, table.concat(list, " + "))
  end
  return out
end

-- category of a climate point (for the test): the colour or "volcanic" of the first matching box
function geology.classify(spec, axes, temperature, moisture, aux)
  local point = {temperature = temperature, moisture = moisture, aux = aux}
  local grass = grass_moisture(spec, axes)
  for _, box in ipairs(geology.boxes(spec, axes)) do
    local inside = true
    for _, dim in ipairs({"temperature", "moisture", "aux"}) do
      local lo, hi = box.volume[dim .. "_min"], box.volume[dim .. "_max"]
      if (lo and point[dim] < lo) or (hi and point[dim] >= hi and hi < ends(axes)[dim][2]) then inside = false end
    end
    if box.group == "mineral" and moisture >= grass then inside = false end
    if inside then return box.category end
  end
  return nil
end

if data and data.extend then
  if settings.startup["alien-biomes-reforged-geology"].value then
    local expressions = geology.expressions(alien_biomes.spec, alien_biomes.axes)
    local names = {}
    for resource in pairs(expressions) do names[#names + 1] = resource end
    table.sort(names)
    for _, resource in ipairs(names) do
      data:extend({{type = "noise-expression", name = "alien-biomes-geology-" .. resource, expression = expressions[resource]}})
    end
  end
end

return geology
