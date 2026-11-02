-- Final data: fire markers and the mod-data read by control (fire classes, lightning targets).
-- Runs after the mods that define fires late (optional dependencies in info.json).

-- Fires rain does not put out: lit by lightning, or burning flammable fluids of paranoidal-flammable-fluids
-- (those are fought by fire safety turrets; rain only slows the hazard down, see the remote "hazard_slowdown").
local EXEMPT = {
  ["prain-lightning-fire"] = true,
  ["oil-fire-flame"] = true,
  ["flo-long-fire"] = true,
  ["flo-tank-fire"] = true,
}

local marker_effect = {
  type = "direct",
  action_delivery = {
    type = "instant",
    source_effects = {
      type = "create-entity",
      entity_name = "prain-fire-marker",
      ignore_collision_condition = true,
      trigger_created_entity = true,
    },
  },
}

local function has_marker(effect)
  if type(effect) ~= "table" then return false end
  if effect.type == "create-entity" and effect.entity_name == "prain-fire-marker" then return true end
  for _, value in pairs(effect) do
    if type(value) == "table" and has_marker(value) then return true end
  end
  return false
end

-- created_effect is a Trigger: one TriggerItem or an array of them. Append without touching other effects.
local function append_effect(existing, effect)
  if not existing then return effect end
  if existing.type then return { existing, effect } end
  local merged = {}
  for key, value in pairs(existing) do merged[key] = value end
  merged[#merged + 1] = effect
  return merged
end

local exempt, acid = {}, {}
for name, fire in pairs(data.raw.fire or {}) do
  if EXEMPT[name] then
    exempt[#exempt + 1] = name
  else
    local damage = fire.damage_per_tick
    if (damage and damage.type == "acid") or string.find(name, "acid", 1, true) then acid[#acid + 1] = name end
    if not has_marker(fire.created_effect) then
      fire.created_effect = append_effect(fire.created_effect, marker_effect)
    end
  end
end
table.sort(exempt)
table.sort(acid)

-- Lightning targets: priority bonus by entity name and type, like the planet lightning priority rules of
-- Dynamic Rain (tall buildings and poles attract strikes, then trees, pipes and creatures).
local lightning = require("prototypes.lightning-targets")

data:extend({
  {
    type = "mod-data",
    name = "paranoidal-rain",
    data = {
      fire_exempt = exempt,
      fire_acid = acid,
      lightning = lightning,
    },
  },
})

--[[ [2.1] Engine lightning of Dynamic Rain, for the move to 2.1 (scripts/lightning.lua has the matching runtime part).
-- LightningPrototype is a Space Age prototype ("space_travel" feature flag in 2.0), so this stays off in 2.0.
local function script_effect(effect_id)
  return { type = "direct", action_delivery = { type = "instant", target_effects = { type = "script", effect_id = effect_id } } }
end
local engine_lightning = table.deepcopy(data.raw.lightning.lightning)
engine_lightning.name = "prain-lightning"
engine_lightning.hidden = true
engine_lightning.damage = 0
engine_lightning.strike_effect = append_effect(engine_lightning.strike_effect, script_effect("prain-lightning-strike"))
engine_lightning.attractor_hit_effect = append_effect(engine_lightning.attractor_hit_effect,
  script_effect("prain-lightning-attractor"))
data:extend({ engine_lightning })
local priority_rules = {}
for name, bonus in pairs(lightning.ids) do
  priority_rules[#priority_rules + 1] = { type = "id", string = name, priority_bonus = bonus }
end
for type_name, bonus in pairs(lightning.types) do
  priority_rules[#priority_rules + 1] = { type = "prototype", string = type_name, priority_bonus = bonus }
end
for _, planet in pairs(data.raw.planet or {}) do
  if not planet.lightning_properties then
    planet.lightning_properties = {
      lightnings_per_chunk_per_tick = 0, lightning_multiplier_at_day = 0, lightning_multiplier_at_night = 0,
      search_radius = 18, lightning_types = { "prain-lightning" }, priority_rules = table.deepcopy(priority_rules),
      lightning_warning_icon = { filename = "__core__/graphics/empty.png", width = 1, height = 1 },
    }
  end
end
--]]
