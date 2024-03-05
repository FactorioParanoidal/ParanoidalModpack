local constants = {}

constants.default_color = { r = 0.3, g = 0.3, b = 0.3 }

-- In the source code, 200 is defined as the maximum viewable distance, but in reality it's around 220
-- Map editor is 3x that, but we will ignore that for now
-- Add five for a comfortable margin
constants.max_viewable_radius = 110 + 5

constants.entity_types = {
  "assembling-machine",
  "boiler",
  "fluid-turret",
  "furnace",
  "generator",
  "infinity-pipe",
  "inserter",
  "mining-drill",
  "offshore-pump",
  "pipe",
  "pipe-to-ground",
  "pump",
  "reactor",
  "rocket-silo",
  "storage-tank",
}

--- @class constants.modes
constants.modes = {
  fluid = 1,
  system = 2,
}

-- Source: https://sashamaps.net/docs/resources/20-colors/
constants.system_colors = {
  { r = 60, g = 180, b = 75 },
  { r = 230, g = 25, b = 75 },
  { r = 255, g = 255, b = 25 },
  { r = 0, g = 130, b = 200 },
  { r = 245, g = 130, b = 48 },
  { r = 145, g = 30, b = 180 },
  { r = 70, g = 240, b = 240 },
  { r = 240, g = 50, b = 230 },
  { r = 210, g = 245, b = 60 },
  { r = 250, g = 190, b = 212 },
  { r = 0, g = 128, b = 128 },
  { r = 220, g = 190, b = 255 },
  { r = 170, g = 110, b = 40 },
  { r = 255, g = 250, b = 200 },
  { r = 128, g = 0, b = 0 },
  { r = 170, g = 255, b = 195 },
  { r = 128, g = 128, b = 0 },
  { r = 255, g = 215, b = 180 },
  { r = 0, g = 0, b = 128 },
  { r = 255, g = 255, b = 255 },
}

constants.type_to_shape = {
  ["assembling-machine"] = "square",
  ["boiler"] = "square",
  ["fluid-turret"] = "square",
  ["furnace"] = "square",
  ["generator"] = "square",
  ["infinity-pipe"] = "circle",
  ["inserter"] = "square",
  ["mining-drill"] = "square",
  ["offshore-pump"] = "square",
  ["pipe"] = "circle",
  ["pipe-to-ground"] = "circle",
  ["pump"] = "circle",
  ["reactor"] = "square",
  ["rocket-silo"] = "circle",
  ["storage-tank"] = "diamond",
}

return constants
