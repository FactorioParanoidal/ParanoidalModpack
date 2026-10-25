-- Droid names at runtime: the droid kinds and rank prototypes that exist in this game (Bob's
-- drones only with Bob's Warfare). Built once from the prototypes, the same on every peer.
local shared = require("lib.shared")

local droids = {
  names = {},     -- every droid entity name (kinds and ranks)
  is_droid = {},  -- entity name -> true
  kind = {},      -- entity name -> droid kind (base name, also the item name)
  rank = {},      -- entity name -> rank (0 for the kind itself)
  kinds = {},     -- array of the existing shared.droids entries, display order
  role = {},      -- entity name -> "repair" / "miner" / nil
  external = {},  -- entity name -> true for Bob's drones
}

for _, d in pairs(shared.droids) do
  if prototypes.entity[d.unit] then
    droids.kinds[#droids.kinds + 1] = d
    for r = 0, #shared.rank_kills do
      local name = shared.rank_name(d.unit, r)
      if prototypes.entity[name] then
        droids.names[#droids.names + 1] = name
        droids.is_droid[name] = true
        droids.kind[name] = d.unit
        droids.rank[name] = r
        droids.role[name] = d.role
        droids.external[name] = d.external
      end
    end
  end
end

--- Name of a droid kind at a rank, or nil if that prototype does not exist.
function droids.rank_name(kind, rank)
  local name = shared.rank_name(kind, rank)
  return droids.is_droid[name] and name or nil
end

--- Entity names of one kind (all ranks), for counting.
droids.names_of_kind = {}
for _, name in pairs(droids.names) do
  local kind = droids.kind[name]
  local list = droids.names_of_kind[kind]
  if not list then
    list = {}
    droids.names_of_kind[kind] = list
  end
  list[#list + 1] = name
end

--- Whether a droid of another mod may join squads: Bob's drones after "Bob's drones in the army".
function droids.allowed(entity)
  if not droids.external[entity.name] then return true end
  local tech = entity.force.technologies["robotarmy-tech-bob-drones"]
  return tech ~= nil and tech.researched
end

return droids
