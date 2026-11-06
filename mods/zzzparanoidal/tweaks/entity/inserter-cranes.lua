-- Loading cranes of nco-InserterCranes (user decision 2026-11-06): every crane swings like the bulk
-- inserter of its colour (rotation, extension, idle drain). Own hand 50 (2x2) / 200 (6x2) before research;
-- bulk = false, so only the ordinary inserter hand research adds to it. Energy per moved item equals the
-- bulk inserter with its researched hand. Prices: tweaks/recipe/inserter-cranes-port.lua; geometry: the mod.
if not mods["nco-InserterCranes"] then
  return
end
local util = require("util")

local BULK_HAND = 12 -- bulk inserter hand after the ordinary research (1 + 11)
local cranes = {
  ["nco-red-crane"] = {bulk = "bob-red-bulk-inserter", hand = 50},
  ["nco-red-wide-crane"] = {bulk = "bob-red-bulk-inserter", hand = 200},
  ["nco-crane"] = {bulk = "bulk-inserter", hand = 50},
  ["nco-wide-crane"] = {bulk = "bulk-inserter", hand = 200},
  ["nco-turbo-crane"] = {bulk = "bob-turbo-bulk-inserter", hand = 50},
  ["nco-wide-turbo-crane"] = {bulk = "bob-turbo-bulk-inserter", hand = 200},
  ["nco-express-crane"] = {bulk = "bob-express-bulk-inserter", hand = 50},
  ["nco-wide-express-crane"] = {bulk = "bob-express-bulk-inserter", hand = 200},
}

local function reach(position)
  local x, y = position.x or position[1], position.y or position[2]
  return math.sqrt(x * x + y * y)
end

-- Hand extension travelled in one chest-to-chest cycle (there and back).
local function travel(inserter)
  return 2 * math.abs(reach(inserter.insert_position) - reach(inserter.pickup_position))
end

for name, spec in pairs(cranes) do
  local crane = assert(data.raw.inserter[name], name)
  local bulk = assert(data.raw.inserter[spec.bulk], spec.bulk)
  -- A cycle turns half a circle there and half back; assumed engine model: energy_per_rotation per full
  -- turn, energy_per_movement per tile of extension. The crane uses one value for both fields.
  local cycle = util.parse_energy(bulk.energy_per_rotation) + util.parse_energy(bulk.energy_per_movement) * travel(bulk)
  local energy = cycle / BULK_HAND * spec.hand / (1 + travel(crane))
  crane.bulk = false
  crane.stack_size_bonus = spec.hand - 1
  crane.rotation_speed = bulk.rotation_speed
  crane.extension_speed = bulk.extension_speed
  crane.energy_per_rotation = string.format("%dJ", math.floor(energy / 5 + 0.5) * 5)
  crane.energy_per_movement = crane.energy_per_rotation
  crane.energy_source.drain = bulk.energy_source.drain
end
