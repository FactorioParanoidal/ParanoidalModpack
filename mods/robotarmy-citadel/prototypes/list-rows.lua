-- Rows of the citadel in the "Enemies" tab of the entity lists (turret priority targets, Factoriopedia): the robots
-- category of the Paranoidal layout (zzzparanoidal tweaks/custom/enemies-tab.lua runs before this mod; subgroup orders
-- "c-<category>-<row>", robots = "g"). Every droid kind takes two rows: the droid and armour mark 1 (5 icons), marks 2
-- and 3 (8 icons), the focuses in the order of S.focuses. Then the towers and the other military buildings, by their
-- order, in rows of at most 10.
local S = require("lib.shared")

local subgroups, rows = {}, 0

local function new_row()
  rows = rows + 1
  local name = string.format("paranoidal-enemies-g-%03d", rows)
  subgroups[#subgroups + 1] = {type = "item-subgroup", name = name, group = "enemies",
    order = string.format("c-g-%03d", rows)}
  return name
end

for _, kind in ipairs(S.kinds) do
  local low, high
  for mark = 0, S.marks do
    for index, focus in ipairs(S.focuses) do
      local unit = (mark > 0 or index == 1) and data.raw.unit[S.unit_name(kind, mark, focus)]
      if unit then
        if mark <= 1 then
          low = low or new_row()
          unit.subgroup = low
        else
          high = high or new_row()
          unit.subgroup = high
        end
        unit.order = string.format("%d-%d", mark, index)
      end
    end
  end
end

local TOWER_TYPES = {["ammo-turret"] = true, ["electric-turret"] = true, ["fluid-turret"] = true, ["turret"] = true,
  ["artillery-turret"] = true}
-- Types that are military targets unless set otherwise (EntityWithOwnerPrototype::is_military_target defaults); only
-- military targets are listed as priority targets, the other buildings (walls, gates, lamps) keep their subgroup.
local MILITARY_BY_DEFAULT = {radar = true, ["land-mine"] = true, ["simple-entity-with-force"] = true}
for t in pairs(TOWER_TYPES) do MILITARY_BY_DEFAULT[t] = true end
-- (the data mock of tests/ has no defines: there the buildings keep their subgroup)
local entity_types = defines and defines.prototypes and defines.prototypes.entity or {}
local towers, buildings = {}, {}
for entity_type in pairs(entity_types) do
  if entity_type ~= "unit" then
    for name, proto in pairs(data.raw[entity_type] or {}) do
      local military = proto.is_military_target
      if military == nil then military = MILITARY_BY_DEFAULT[entity_type] or false end
      if name:sub(1, #S.prefix) == S.prefix and proto.subgroup == "enemies" and military then
        local list = TOWER_TYPES[entity_type] and towers or buildings
        list[#list + 1] = proto
      end
    end
  end
end
local function sort_key(proto) return proto.order or proto.name end
for _, list in ipairs({towers, buildings}) do
  table.sort(list, function(a, b) return sort_key(a) < sort_key(b) end)
  local row
  for i, proto in ipairs(list) do
    if i % 10 == 1 then row = new_row() end
    proto.subgroup = row
  end
end

if #subgroups > 0 then data:extend(subgroups) end
