-- Own ammo categories of the citadel (data-updates, after the droid copies of prototypes/units.lua;
-- the towers of prototypes/turrets.lua are made in data.lua). Every attack of a citadel prototype
-- fires "replicator-<category>" (S.own_ammo) instead of the category of its source weapon (Robot
-- Army Reforged droids, "capsule" of the chemical droid). The tooltip of an ammo research lists
-- every entity that fires its category, so with the shared categories the research of the players
-- listed the replicators as if it boosted them (it never did: the bonuses belong to a force).
-- The citadel force gets its damage / rate bonuses on these categories (script/upgrades.lua).
local S = require("lib.shared")

local P = S.prefix
local made = {}
local list = {}

local function own(category)
  local name = S.own_ammo(category)
  if name == category or made[name] or data.raw["ammo-category"][name] then return name end
  made[name] = true
  local from = data.raw["ammo-category"][category]
  if not from then log("robotarmy-citadel: ammo category " .. category .. " not found, made without an icon") end
  from = from or {}
  list[#list + 1] = {
    type = "ammo-category",
    name = name,
    icons = from.icons,
    icon = from.icon,
    icon_size = from.icon_size,
    bonus_gui_order = "z[replicators]-" .. name,
    hidden = true,
    hidden_in_factoriopedia = true,
  }
  return name
end

local function remap(attack)
  if type(attack) ~= "table" then return end
  if attack.ammo_category then attack.ammo_category = own(attack.ammo_category) end
  if attack.ammo_categories then
    for i, c in pairs(attack.ammo_categories) do attack.ammo_categories[i] = own(c) end
  end
end

for _, protos in pairs(data.raw) do
  for name, proto in pairs(protos) do
    if type(name) == "string" and name:sub(1, #P) == P and type(proto) == "table" then
      remap(proto.attack_parameters)
    end
  end
end

-- the categories the citadel gives bonuses on exist even if no attack fires them now
for _, c in pairs(S.ammo_categories) do own(c) end

if #list > 0 then data:extend(list) end
