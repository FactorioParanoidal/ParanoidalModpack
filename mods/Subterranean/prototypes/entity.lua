-- Beta 8 entities, using the native 2.0 graphics and fluid connection format.
local belts = {
  {"subterranean-belt", "underground-belt", 100, 1 / 32, {r = 1, g = 0.3, b = 0.1, a = 1}},
  {"fast-subterranean-belt", "fast-underground-belt", 150, 2 / 32, {r = 1, g = 0.1, b = 1, a = 1}},
  {"express-subterranean-belt", "express-underground-belt", 200, 4 / 32, {r = 0, g = 1, b = 1, a = 1}},
}

for _, spec in ipairs(belts) do
  local belt = table.deepcopy(data.raw["underground-belt"][spec[2]])
  belt.name = spec[1]
  belt.minable = {mining_time = 2, result = spec[1]}
  belt.max_distance = 250
  belt.max_health = spec[3]
  belt.speed = spec[4]
  belt.structure.direction_in.sheet.tint = spec[5]
  belt.structure.direction_out.sheet.tint = spec[5]
  -- Preserve Beta 8's inherited upgrade targets; do not redesign its upgrade chain.
  data:extend({belt})
end

local pipe = table.deepcopy(data.raw["pipe-to-ground"]["pipe-to-ground"])
pipe.name = "subterranean-pipe"
pipe.minable = {mining_time = 2, result = pipe.name}
pipe.max_health = 200
for _, connection in pairs(pipe.fluid_box.pipe_connections) do
  if connection.connection_type == "underground" then
    connection.max_underground_distance = 250
  end
end
for _, direction in ipairs({"north", "west", "east", "south"}) do
  pipe.pictures[direction].tint = {r = 0.3, g = 0, b = 0, a = 1}
end
data:extend({pipe})
