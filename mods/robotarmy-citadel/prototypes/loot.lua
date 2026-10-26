-- Loot (data-final-fixes, when every item of the build is final): destroyed replicator droids drop
-- parts of their bodies (gears, plates, bearing balls and bearings, rods, cables, circuits and
-- electronic components) through the engine loot of the unit - no script runs on a death for it.
-- Only items that exist and are not hidden are used. The key buildings drop replicator cores, and
-- the core decryption recipe gets the parts of the build.
local S = require("lib.shared")
local raw = data.raw

local function usable(name)
  for _, t in pairs({"item", "tool", "capsule", "repair-tool", "ammo", "module"}) do
    local item = raw[t] and raw[t][name]
    if item then return not item.hidden and not item.parameter end
  end
  return false
end

-- {item, probability, min, max}. Plates of Bob's metals where they exist, vanilla fallbacks always.
local CLASSES = {
  light = {
    {"iron-gear-wheel", 0.5, 1, 2}, {"iron-plate", 0.4, 1, 3}, {"iron-stick", 0.35, 1, 3},
    {"copper-cable", 0.3, 1, 4}, {"bob-steel-bearing-ball", 0.25, 2, 6}, {"bob-basic-circuit-board", 0.15, 1, 1},
    {"electronic-circuit", 0.1, 1, 1},
  },
  assault = {
    {"steel-plate", 0.4, 1, 2}, {"bob-steel-gear-wheel", 0.4, 1, 2}, {"iron-gear-wheel", 0.3, 1, 2},
    {"bob-steel-bearing", 0.25, 1, 2}, {"bob-steel-bearing-ball", 0.3, 2, 6}, {"bob-brass-gear-wheel", 0.2, 1, 2},
    {"bob-brass-bearing-ball", 0.2, 2, 5}, {"bob-basic-electronic-components", 0.25, 1, 3},
    {"electronic-circuit", 0.2, 1, 2}, {"pipe", 0.2, 1, 2},
  },
  energy = {
    {"copper-plate", 0.4, 1, 3}, {"bob-tin-plate", 0.3, 1, 2}, {"bob-tinned-copper-cable", 0.3, 1, 3},
    {"copper-cable", 0.3, 2, 5}, {"bob-electronic-components", 0.3, 1, 3}, {"bob-circuit-board", 0.2, 1, 1},
    {"electronic-circuit", 0.2, 1, 2}, {"advanced-circuit", 0.1, 1, 1}, {"battery", 0.15, 1, 1},
    {"bob-silver-plate", 0.15, 1, 1},
  },
  heavy = {
    {"bob-titanium-plate", 0.4, 1, 2}, {"steel-plate", 0.4, 2, 4}, {"bob-titanium-gear-wheel", 0.3, 1, 2},
    {"bob-titanium-bearing", 0.25, 1, 1}, {"bob-titanium-bearing-ball", 0.3, 2, 5},
    {"bob-integrated-electronics", 0.2, 1, 2}, {"advanced-circuit", 0.2, 1, 1},
    {"processing-unit", 0.06, 1, 1}, {"electric-engine-unit", 0.1, 1, 1}, {"bob-gold-plate", 0.1, 1, 1},
  },
  air = {
    {"bob-aluminium-plate", 0.4, 1, 2}, {"bob-nickel-plate", 0.25, 1, 2}, {"bob-zinc-plate", 0.2, 1, 2},
    {"bob-lead-plate", 0.2, 1, 2}, {"copper-cable", 0.3, 1, 3}, {"bob-electronic-components", 0.25, 1, 2},
    {"electronic-circuit", 0.2, 1, 1}, {"flying-robot-frame", 0.04, 1, 1},
  },
}

local function loot_of(class, mark)
  local out = {}
  local k = 1 + 0.25 * mark
  for _, e in pairs(CLASSES[class] or {}) do
    if usable(e[1]) then
      out[#out + 1] = {item = e[1], probability = math.min(1, e[2]), count_min = e[3], count_max = math.ceil(e[4] * k)}
    end
  end
  return out
end

for _, kind in pairs(S.kinds) do
  local class = S.loot_class[kind]
  for mark = 0, S.marks do
    for _, focus in pairs(mark == 0 and {"balanced"} or S.focuses) do
      local unit = raw.unit[S.unit_name(kind, mark, focus)]
      if unit then unit.loot = loot_of(class, mark) end
    end
  end
end

-- Replicator cores from the key buildings.
local E = S.entity
local CORES = {
  [E.core] = {6, 10},
  [E.depot] = {1, 2}, [E.ai_core] = {2, 3}, [E.armory] = {1, 2}, [E.arsenal] = {1, 2},
  [E.targeting] = {1, 1}, [E.jammer] = {1, 2}, [E.relay] = {1, 1}, [E.shield_node] = {1, 2},
  [E.repair_bay] = {1, 1}, [E.recycler] = {1, 2}, [E.mine_control] = {1, 1}, [E.radar] = {1, 1},
  [E.reactor] = {1, 2},
}
for _, f in pairs(S.foundries) do CORES[E["foundry_" .. f]] = {1, 3} end
for name, n in pairs(CORES) do
  for _, t in pairs({"simple-entity-with-owner", "electric-energy-interface", "radar"}) do
    local p = raw[t][name]
    if p then p.loot = {{item = S.core_item, probability = 1, count_min = n[1], count_max = n[2]}} end
  end
end

-- Parts of a decrypted core: the best parts of the build that exist.
local recipe = raw.recipe[S.decrypt_recipe]
if recipe then
  for _, e in pairs({
    {"bob-titanium-bearing", 2, 1}, {"bob-integrated-electronics", 2, 1}, {"bob-superior-circuit-board", 1, 0.5},
    {"bob-titanium-gear-wheel", 2, 1}, {"electric-engine-unit", 1, 0.5},
  }) do
    if usable(e[1]) then
      recipe.results[#recipe.results + 1] = {type = "item", name = e[1], amount = e[2], probability = e[3] < 1 and e[3] or nil}
    end
  end
end
