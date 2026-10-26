-- Catalogue of the module types: what each one is for, its key buildings (a module whose key
-- buildings are all destroyed is ruined), when it may appear and how often.
--
--   cat      core | production | power | defense | support | recon | upgrade | shield
--   keys     names of the key buildings (from the plan in script/layout.lua)
--   foundry  production kind of its foundry (script/production.lua)
--   min      modules the citadel needs before this type can appear
--   cap      most modules of this type (number or function of the citadel)
--   weight   base weight of the random choice (lower for every module of the type already there)
--   demand   power the module draws in a fight, MW (the power plants are planned against it)
local S = require("lib.shared")
local U = require("script.util")
local E = S.entity

local M = {}

local TOWERS = {E.gun_tower, E.laser_tower, E.mortar_tower, E.tesla_tower}

M.types = {
  core = {cat = "core", keys = {E.core}, foundry = "core", demand = 3},
  ["power-plant"] = {cat = "power", keys = {E.reactor}, demand = 0.5},
  bastion = {cat = "defense", keys = {E.gun_tower, E.laser_tower}, weight = 3, demand = 5},
  ["turret-nest"] = {cat = "defense", keys = {E.laser_tower, E.tesla_tower}, min = 6, weight = 2, demand = 7},
  ["mortar-battery"] = {cat = "defense", keys = {E.mortar_tower}, min = 10, weight = 1.5, demand = 4},
  minefield = {cat = "defense", keys = {E.mine_control}, min = 4, weight = 1.2, demand = 0.5},
  ["repair-dock"] = {cat = "support", keys = {E.repair_bay}, min = 4, weight = 1.5, demand = 1,
    cap = function(c) return 1 + math.floor(c.count / 8) end},
  ["supply-depot"] = {cat = "support", keys = {E.depot}, min = 5, weight = 1.3, demand = 0.5},
  recycler = {cat = "support", keys = {E.recycler}, min = 7, weight = 1, demand = 0.5},
  radar = {cat = "recon", keys = {E.radar}, min = 3, cap = 3, weight = 1.5, demand = 1},
  jammer = {cat = "recon", keys = {E.jammer}, min = 9, cap = 2, weight = 1, demand = 0.5},
  relay = {cat = "recon", keys = {E.relay}, min = 12, cap = 3, weight = 1, demand = 0.5},
  armory = {cat = "upgrade", keys = {E.armory}, min = 4, cap = S.marks, weight = 1.6, demand = 0.5},
  arsenal = {cat = "upgrade", keys = {E.arsenal}, min = 6, weight = 1.4, demand = 0.5},
  targeting = {cat = "upgrade", keys = {E.targeting}, min = 9, weight = 1.2, demand = 0.5},
  ["ai-core"] = {cat = "upgrade", keys = {E.ai_core}, min = 5, cap = 6, weight = 1.6, demand = 1},
  ["shield-amplifier"] = {cat = "shield", keys = {E.shield_node}, shields = true, cap = 25, weight = 1.5, demand = 1},
  ["shield-regenerator"] = {cat = "shield", keys = {E.shield_node}, shields = true, cap = 25, weight = 1.5, demand = 1},
}

local FOUNDRY_MIN = {light = 0, assault = 3, fire = 5, sniper = 8, energy = 10, air = 14, terminator = 20}
local FOUNDRY_WEIGHT = {light = 3, assault = 3, fire = 2.5, sniper = 2, energy = 2, air = 1.5, terminator = 1}
for _, f in pairs(S.foundries) do
  M.types["foundry-" .. f] = {cat = "production", keys = {E["foundry_" .. f]}, foundry = f,
    min = FOUNDRY_MIN[f], weight = FOUNDRY_WEIGHT[f], demand = 1}
end

--- Every module has corner towers: their draw is added to the demand of each module.
M.TOWER_DEMAND = 0.5
--- Shield stage: the defence tower of a module draws about 0.9 MW at rest (repair idle 0.5 MW and
--- shield drain 0.4 MW at the first levels) and up to 10 MW while its shield recharges.
M.SHIELD_DEMAND = 1.5
--- Power of one reactor, MW (prototype "replicator-reactor").
M.REACTOR_MW = 20
--- The first modules after the core, in this order; the random choice starts after them.
M.OPENING = {"foundry-light", "power-plant", "bastion", "foundry-assault", "radar"}

local CATEGORY_WEIGHT = {production = 1, defense = 1, support = 0.8, recon = 0.8, upgrade = 0.9, shield = 1}

--- Names of all key buildings (death event filter) and a set of them.
M.key_names = {}
local seen = {}
for _, t in pairs(M.types) do
  for _, name in pairs(t.keys) do
    if not seen[name] then
      seen[name] = true
      M.key_names[#M.key_names + 1] = name
    end
  end
end
M.is_key = seen
M.towers = TOWERS

--- Power the citadel needs and has, MW.
function M.power(c)
  local demand, supply = 0, 0
  for name, n in pairs(c.alive) do
    local t = M.types[name]
    if t then demand = demand + n * ((t.demand or 0) + M.TOWER_DEMAND + (c.shields and M.SHIELD_DEMAND or 0)) end
  end
  supply = M.REACTOR_MW * (2 * (c.alive["power-plant"] or 0) + ((c.alive.core or 0) > 0 and 1 or 0))
  return demand, supply
end

local function cap_of(t, c)
  if type(t.cap) == "function" then return t.cap(c) end
  return t.cap
end

--- Type of the next new module.
function M.choose(c, shields_available)
  local opening = M.OPENING[c.count]
  if opening and M.types[opening] then return opening end

  local demand, supply = M.power(c)
  local production, all = 0, 0
  for name, n in pairs(c.alive) do
    all = all + n
    if M.types[name] and M.types[name].cat == "production" then production = production + n end
  end
  local list = {}
  for name, t in pairs(M.types) do
    if t.cat ~= "core" then
      local w
      if t.cat == "power" then
        w = supply < demand * 1.25 + 4 and 10 or 0.4
      elseif (t.min or 0) <= c.count and not (t.shields and not (c.shields and shields_available)) then
        local have = c.alive[name] or 0
        local cap = cap_of(t, c)
        if not cap or have < cap then
          w = (t.weight or 1) * (CATEGORY_WEIGHT[t.cat] or 1) / (1 + 0.35 * have)
          if t.cat == "production" and production < 0.3 * all then w = w * 2 end
        end
      end
      if w and w > 0 then list[#list + 1] = {name, w} end
    end
  end
  table.sort(list, function(a, b) return a[1] < b[1] end) -- pairs order is not part of the game state
  return U.pick(c, list) or "bastion"
end

return M
