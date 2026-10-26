-- Replicator droids (data-updates: after Robot Army Reforged has built its droid units).
-- Every droid kind of S.kinds is copied as "replicator-<kind>" (red, not minable, immune to poison
-- clouds as it does not breathe) and as armour marks 1..S.marks for each resistance focus. The loot
-- is added in data-final-fixes (prototypes/loot.lua), when every item of the build is final.
local S = require("lib.shared")
local G = require("prototypes.gfx")

local TINT = {r = 1.0, g = 0.42, b = 0.38}
local MAP = {r = 0.85, g = 0.15, b = 0.15}
local RESIST_TYPES = {"physical", "explosion", "fire", "laser", "electric", "acid", "poison"}
local MAX_RESIST = 85

local function in_focus(focus, damage_type)
  return focus ~= "balanced" and S.focus_of_damage[damage_type] == focus
end

local function resistances(base, mark, focus)
  local by_type, out = {}, {}
  for _, r in pairs(base or {}) do
    by_type[r.type] = {type = r.type, decrease = r.decrease or 0, percent = r.percent or 0}
  end
  if mark > 0 then
    for _, t in pairs(RESIST_TYPES) do
      local r = by_type[t] or {type = t, decrease = 0, percent = 0}
      local add = S.mark_resist * mark + (in_focus(focus, t) and S.focus_resist * mark or 0)
      r.percent = math.min(MAX_RESIST, r.percent + add)
      if t == "physical" or t == "explosion" then r.decrease = r.decrease + mark end
      by_type[t] = r
    end
  end
  for _, r in pairs(by_type) do out[#out + 1] = r end
  table.sort(out, function(a, b) return a.type < b.type end)
  return out
end

local function replicator(base, kind, mark, focus)
  local u = G.copy(base)
  u.name = S.unit_name(kind, mark, focus)
  local droid_name = base.localised_name or {"entity-name." .. kind}
  if mark == 0 then
    u.localised_name = {"entity-name.replicator-unit", droid_name}
  else
    u.localised_name = {"entity-name.replicator-unit-mark", droid_name, {"replicator.mark-" .. mark},
      {"replicator.focus-" .. focus}}
  end
  u.localised_description = {"entity-description.replicator-unit"}
  u.flags = {"placeable-enemy", "placeable-off-grid", "not-repairable"}
  u.minable = nil
  u.placeable_by = nil
  u.custom_tooltip_fields = nil
  u.factoriopedia_simulation = nil
  u.hidden_in_factoriopedia = mark > 0
  u.subgroup = "enemies"
  u.order = "z[replicators]-" .. u.name
  u.max_health = base.max_health * (1 + S.mark_health * mark)
  u.healing_per_tick = (base.healing_per_tick or 0) + mark * 0.5 / 60
  u.resistances = resistances(base.resistances, mark, focus)
  u.friendly_map_color = nil
  u.enemy_map_color = MAP
  u.map_color = MAP
  u.ai_settings = {destroy_when_commands_fail = false, allow_try_return_to_spawner = false, do_separation = true}
  u.absorptions_to_join_attack = {}
  u.can_open_gates = true
  u.radar_range = 0 -- the citadel force charts nothing
  u.icons = G.icons(base, TINT)
  u.icon = nil
  u.icon_size = nil
  local seen = {}
  G.tint_all(u.run_animation, TINT, seen)
  if u.attack_parameters then G.tint_all(u.attack_parameters.animation, TINT, seen) end
  return u
end

local list = {}
for _, kind in pairs(S.kinds) do
  local base = data.raw.unit[kind]
  if base then
    list[#list + 1] = replicator(base, kind, 0, "balanced")
    for mark = 1, S.marks do
      for _, focus in pairs(S.focuses) do
        list[#list + 1] = replicator(base, kind, mark, focus)
      end
    end
  else
    log("robotarmy-citadel: droid " .. kind .. " not found, no replicator copies")
  end
end
data:extend(list)
