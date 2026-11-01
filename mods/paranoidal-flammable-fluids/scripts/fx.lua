-- Spectacle and area effects: pollution, blast tiers (camera shake, distant sound, shock wave,
-- scorch marks), fire rings, area damage, reactions of nearby tanks and ammunition stores.
local FO = require("scripts.registry")
local C = require("scripts.config")

local M = {}
FO.fx = M

local HAZARD_TYPES = { "storage-tank" }
for entity_type in pairs(C.CONTAINER_INVENTORIES) do HAZARD_TYPES[#HAZARD_TYPES + 1] = entity_type end
table.sort(HAZARD_TYPES)

local TIERS = {
  { blast = "flo-blast-small", scorch = "medium-scorchmark-tintable" },
  { blast = "flo-blast-medium", scorch = "big-scorchmark-tintable" },
  { blast = "flo-blast-huge", scorch = "huge-scorchmark-tintable" },
}

function M.create(surface, name, position, force)
  if prototypes.entity[name] then
    return surface.create_entity { name = name, position = position, force = force }
  end
end

function M.random_point(box, margin)
  local lt, rb = box.left_top, box.right_bottom
  return {
    x = lt.x - margin + math.random() * (rb.x - lt.x + 2 * margin),
    y = lt.y - margin + math.random() * (rb.y - lt.y + 2 * margin),
  }
end

---Pollution into the chunk: one unit per unit of burnt fluid (times the setting).
function M.pollute(surface, position, amount)
  local pollution = amount * settings.global["flo-pollution-mult"].value
  if pollution > 0 then surface.pollute(position, pollution) end
  return pollution
end

---Blast effects by energy. Returns the tier (0 = none).
function M.blast(surface, position, energy, catastrophe)
  local tier
  if catastrophe or energy >= C.HUGE_ENERGY then
    tier = 3
  elseif energy >= C.MEDIUM_ENERGY then
    tier = 2
  elseif energy >= C.SMALL_ENERGY then
    tier = 1
  else
    return 0
  end
  local spec = TIERS[tier]
  M.create(surface, spec.blast, position)
  M.create(surface, spec.scorch, position)
  if tier == 3 then
    for _ = 1, 4 do
      M.create(surface, "massive-explosion", { x = position.x + math.random(-6, 6), y = position.y + math.random(-6, 6) })
    end
  end
  return tier
end

---Many long fires scattered in a ring around a position.
function M.fire_ring(surface, position, inner, outer, count, name)
  for _ = 1, count do
    local angle = math.pi * 2 * math.random()
    local range = inner + math.random() * (outer - inner)
    surface.create_entity {
      name = name,
      position = { position.x + math.cos(angle) * range, position.y + math.sin(angle) * range },
      force = "neutral",
    }
  end
end

---Linear-falloff damage in a circle; entities without health are not even fetched.
function M.damage_area(surface, position, radius, damage, force, damage_type, exclude)
  if radius <= 0 or damage <= 0 then return end
  local px, py = position.x, position.y
  local found = surface.find_entities_filtered {
    position = position, radius = radius, type = C.NO_HEALTH_TYPES, invert = true,
  }
  for _, nearby in pairs(found) do
    if nearby.valid and nearby ~= exclude and nearby.health then
      local npos = nearby.position
      local dx, dy = npos.x - px, npos.y - py
      local amount = damage * (1 - math.sqrt(dx * dx + dy * dy) / radius)
      if amount > 0 then
        nearby.damage(amount, force, damage_type)
      end
    end
  end
end

---Tanks catch fire and ammunition starts cooking off near a fire or explosion.
---ammo_only: burning tanks heat ammunition, not the neighbouring tanks.
function M.scan_hazards(surface, position, radius, exclude, ammo_only)
  local found = surface.find_entities_filtered { position = position, radius = radius, type = HAZARD_TYPES }
  for _, entity in pairs(found) do
    if entity.valid and entity ~= exclude then
      if entity.type == "storage-tank" then
        if not ammo_only then FO.tanks.ignite(entity, { "flo-cause.heat" }) end
      else
        FO.cook.start(entity)
      end
    end
  end
end

return M
