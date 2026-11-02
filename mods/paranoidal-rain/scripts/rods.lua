-- Lightning attractors (rods) of other mods: the connection point, no rods of our own yet.
-- A mod registers its entity at the data stage in mod-data "paranoidal-rain-attractors" (see README.md):
--   data.raw["mod-data"]["paranoidal-rain-attractors"].data.attractors["my-rod"] = {
--     range = 12,         -- tiles: strikes whose point is this close go to the rod
--     priority = 1000,    -- the best rod wins: priority - 2 per tile of distance
--     mode = "absorb",    -- "attract": takes the hit, gets self_damage, a short discharge goes on from it;
--                         -- "absorb": the strike is put out completely (no damage, no discharge, no fire)
--     self_damage = 0,    -- share of max health the rod loses per strike
--     energy_share = 0,   -- share of the strike energy (STRIKE_ENERGY) put into the rod's electric buffer
--   }
-- Planned tiers of the build: 1 attract + self_damage, 2 absorb, 3 absorb + energy_share, 4 larger range and share.
-- data-final-fixes.lua checks and normalizes the entries into mod-data "paranoidal-rain".attractors.
-- Runtime: rods are tracked by build events filtered by their names (no handlers while no rod is registered) and
-- found at a strike among the rods of the surface (storage.rods[surface_index][unit_number] = entity).
local R = require("scripts.registry")

local M = {}
R.rods = M

M.STRIKE_ENERGY = 1000000000 -- J; Space Age "lightning" prototype: energy = "1000MJ"

local specs, names
local function load_specs()
  if specs then return end
  local proto = prototypes.mod_data["paranoidal-rain"]
  specs = proto and proto.data.attractors or {}
  names = {}
  for name in pairs(specs) do
    if prototypes.entity[name] then names[#names + 1] = name end
  end
  table.sort(names)
end

function M.names()
  load_specs()
  return names
end

function M.spec(name)
  load_specs()
  return specs[name]
end

local function add(entity)
  if not (entity and entity.valid and entity.unit_number) then return end
  if not M.spec(entity.name) then return end
  storage.rods = storage.rods or {}
  local list = storage.rods[entity.surface_index]
  if not list then
    list = {}
    storage.rods[entity.surface_index] = list
  end
  list[entity.unit_number] = entity
end

function M.on_built(event)
  add(event.entity or event.destination)
end

-- Configuration change: find every registered rod again.
function M.rescan()
  storage.rods = nil
  local list = M.names()
  if #list == 0 then return end
  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered { name = list }) do add(entity) end
  end
end

function M.forget(surface_index)
  if storage.rods then storage.rods[surface_index] = nil end
end

-- The rod that takes a strike at position, or nil.
function M.find(surface, position)
  local rods = storage.rods and storage.rods[surface.index]
  if not rods then return nil end
  local best, best_score
  for id, rod in pairs(rods) do
    if not rod.valid then
      rods[id] = nil
    else
      local spec = M.spec(rod.name)
      local p = rod.position
      local dx, dy = p.x - position.x, p.y - position.y
      local d2 = dx * dx + dy * dy
      if spec and d2 <= spec.range * spec.range then
        local score = spec.priority - 2 * math.sqrt(d2)
        if not best_score or score > best_score then best, best_score = rod, score end
      end
    end
  end
  return best, best and M.spec(best.name)
end

-- Effects on the rod itself; returns the energy put into it.
function M.hit(rod, spec)
  local energy = 0
  if spec.energy_share > 0 then
    local buffer = rod.electric_buffer_size
    if buffer and buffer > 0 then
      local before = rod.energy
      rod.energy = math.min(buffer, before + M.STRIKE_ENERGY * spec.energy_share)
      energy = rod.energy - before
    end
  end
  if spec.self_damage > 0 and rod.valid and rod.health then
    rod.damage(rod.max_health * spec.self_damage, "neutral", "electric")
  end
  return energy
end

return M
