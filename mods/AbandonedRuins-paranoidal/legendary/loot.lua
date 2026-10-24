-- Rewards of legendary ruins: the ruin's relic plus stacks of positive-quality goods that the
-- Paranoidal defect economy cannot give this early (trials: tiers 4-7, citadels: tiers 6-10).
local C = require("legendary.config")

local L = {}

-- {item, min, max}; missing items are skipped at runtime.
L.pools = {
  trial = {
    { "burner-mining-drill", 3, 6 }, { "stone-furnace", 4, 8 }, { "burner-inserter", 12, 24 },
    { "inserter", 8, 16 }, { "assembling-machine-1", 2, 4 }, { "burner-assembling-machine", 2, 4 },
    { "electric-mining-drill", 2, 4 }, { "lab", 1, 2 }, { "burner-lab", 1, 2 },
    { "small-electric-pole", 10, 20 }, { "medium-electric-pole", 5, 10 }, { "steam-engine", 1, 2 },
    { "boiler", 1, 2 }, { "offshore-pump", 1, 1 }, { "solar-panel", 3, 6 }, { "light-armor", 1, 1 },
    { "heavy-armor", 1, 1 }, { "pistol", 1, 1 }, { "submachine-gun", 1, 1 }, { "shotgun", 1, 1 },
    { "firearm-magazine", 40, 100 }, { "piercing-rounds-magazine", 20, 50 }, { "shotgun-shell", 20, 40 },
    { "grenade", 10, 20 }, { "repair-pack", 20, 40 }, { "gun-turret", 2, 4 }, { "radar", 1, 1 },
    { "car", 1, 1 }, { "small-lamp", 10, 20 }, { "iron-chest", 8, 16 }, { "bi-dart-turret", 2, 4 },
  },
  citadel = {
    { "assembling-machine-2", 2, 4 }, { "steel-furnace", 4, 8 }, { "bob-area-mining-drill-1", 2, 3 },
    { "fast-inserter", 10, 20 }, { "long-handed-inserter", 10, 20 }, { "lab", 2, 4 },
    { "solar-panel", 6, 12 }, { "accumulator", 4, 8 }, { "medium-electric-pole", 10, 20 },
    { "big-electric-pole", 4, 8 }, { "chemical-plant", 1, 2 }, { "pumpjack", 1, 2 }, { "oil-refinery", 1, 1 },
    { "heavy-armor", 1, 1 }, { "modular-armor", 1, 1 }, { "solar-panel-equipment", 2, 4 },
    { "battery-equipment", 1, 2 }, { "energy-shield-equipment", 1, 2 }, { "night-vision-equipment", 1, 1 },
    { "exoskeleton-equipment", 1, 1 }, { "combat-shotgun", 1, 1 }, { "rocket-launcher", 1, 1 },
    { "piercing-rounds-magazine", 50, 100 }, { "piercing-shotgun-shell", 20, 40 }, { "rocket", 20, 40 },
    { "explosive-rocket", 10, 20 }, { "land-mine", 20, 40 }, { "defender-capsule", 10, 20 },
    { "poison-capsule", 5, 10 }, { "gun-turret", 4, 8 }, { "bob-gun-turret-2", 2, 4 },
    { "speed-module", 2, 4 }, { "efficiency-module", 2, 4 }, { "productivity-module", 2, 4 },
    { "tank", 1, 1 }, { "personal-roboport-equipment", 1, 1 }, { "construction-robot", 5, 10 },
  },
}

L.STACKS = { trial = 6, citadel = 8 }

local function range(kind)
  return kind.tier == "citadel" and C.CITADEL_QUALITY or C.TRIAL_QUALITY
end

---Quality tier in [lo, hi], lower tiers more likely.
function L.roll_tier(lo, hi, bonus)
  local r = math.random() ^ 1.7
  local t = lo + math.floor(r * (hi - lo + 1)) + (bonus or 0)
  return math.max(lo, math.min(hi, t))
end

local function insert(vault, name, count, quality)
  if not prototypes.item[name] or count <= 0 then return 0 end
  return vault.insert({ name = name, count = count, quality = quality })
end

---Fills a vault. kind.loot: extra guaranteed entries {item, min, max, tier?}; site.data.bonus:
---extra quality tiers earned in the ruin (Colosseum waves, untouched graves...).
function L.fill(site, kind, vault)
  local lo, hi = range(kind)[1], range(kind)[2]
  local bonus = site.data.bonus or 0
  local relics = kind.relic
  if type(relics) == "string" then relics = { relics } end
  if site.data.relic ~= false then
    for _, relic in ipairs(relics or {}) do insert(vault, relic, kind.relic_count or 1, "normal") end
  end
  for _, extra in ipairs(kind.loot or {}) do
    local tier = extra[4] or L.roll_tier(lo, hi, bonus)
    insert(vault, extra[1], math.random(extra[2], extra[3]), C.tier(tier))
  end
  local pool = L.pools[kind.tier] or L.pools.trial
  local picks, used = 0, {}
  local want = (L.STACKS[kind.tier] or 6) + (site.data.extra_stacks or 0)
  local guard = 0
  while picks < want and guard < 200 do
    guard = guard + 1
    local entry = pool[math.random(#pool)]
    if not used[entry[1]] and prototypes.item[entry[1]] then
      used[entry[1]] = true
      insert(vault, entry[1], math.random(entry[2], entry[3]), C.tier(L.roll_tier(lo, hi, bonus)))
      picks = picks + 1
    end
  end
end

return L
