-- Explosions, deaths, heat damage and chemical accidents.
-- Upstream formulas are kept: radius = r_mult * (10E)^(1/r_pow), damage = d_mult * (10E)^(1/d_pow),
-- flames and explosions per entity size, linear damage falloff, fire spread for big fires.
local FO = require("scripts.registry")
local C = require("scripts.config")

local M = {}
FO.core = M

local processing = false -- true while our own explosion/fuse damages entities

---Run fn with chain reactions queued instead of recursing.
function M.guarded(fn, ...)
  local was = processing
  processing = true
  fn(...)
  processing = was
end

function M.settings()
  local s = settings.global
  return {
    r_mult = s["flo-radius-mult"].value * 1.0,   --default 0.1
    r_pow = 1.0 / s["flo-radius-power"].value,   --default 1/2.5
    d_mult = s["flo-damage-mult"].value * 1.0,   --default 5
    d_pow = 1.0 / s["flo-damage-power"].value,   --default 1/2.5
  }
end

---Per-entity cooldown for repeated damage events (fire damages every tick).
function M.check_cooldown(id)
  if not id then return true end
  local checked = storage.checked
  if not checked then
    checked = {}
    storage.checked = checked
  end
  local tick = game.tick
  local last = checked[id]
  if last and tick - last < C.CHECK_COOLDOWN then return false end
  checked[id] = tick
  return true
end

---Entities connected through pipes (pipe-connectable entities only).
function M.fluid_neighbours(entity)
  local out = {}
  local ok, neighbours = pcall(function() return entity.neighbours end)
  if ok and type(neighbours) == "table" then
    for _, list in pairs(neighbours) do
      if type(list) == "table" then
        for _, n in pairs(list) do out[#out + 1] = n end
      end
    end
  end
  return out
end

function M.cause_of(event)
  if processing then return { "flo-cause.chain" } end
  local cause = event.cause
  if cause and cause.valid then return cause.localised_name end
  local damage_type = event.damage_type
  if damage_type then
    local name = damage_type.name
    return { "?", { "flo-cause." .. name }, { "damage-type-name." .. name }, name }
  end
  return { "flo-cause.unknown" }
end

---Explosion record of an entity (all fields are storable).
function M.record(entity, content, catastrophe)
  local pos = entity.position
  local box = entity.bounding_box
  return {
    surface = entity.surface,
    position = { x = pos.x, y = pos.y },
    radius = 0.5 * ((box.right_bottom.x - pos.x) + (box.right_bottom.y - pos.y)),
    force = entity.force,
    energy = content.energy,
    amount = content.amount or 0,
    fraction = content.fraction or 0,
    damage_type = content.damage_type or "fire",
    neighbours = M.fluid_neighbours(entity),
    catastrophe = catastrophe or nil,
    what = entity.localised_name,
  }
end

local function explode(rec, cfg, source)
  local surface = rec.surface
  if not (surface and surface.valid) then return end
  local force = rec.force
  if force and not force.valid then force = nil end
  local damage_force = force or "neutral"

  local energy, fraction, damage_type = rec.energy, rec.fraction, rec.damage_type
  local explosion_radius = cfg.r_mult * (energy * 10) ^ cfg.r_pow
  local explosion_damage = cfg.d_mult * (energy * 10) ^ cfg.d_pow

  local pos = rec.position
  local px, py = pos.x, pos.y
  local radius = rec.radius
  local width = radius * 2

  local pollution = FO.fx.pollute(surface, pos, rec.amount or 0)

  -- upstream explosions and flames
  local first_flame
  if width <= 1 then
    surface.create_entity { name = "explosion", position = pos }
    first_flame = surface.create_entity { name = "oil-fire-flame", position = pos }
  else
    surface.create_entity { name = "medium-explosion", position = { px + math.random(-radius, radius), py + math.random(-radius, radius) } }
    if energy > 10000 then
      surface.create_entity { name = "big-explosion", position = { px + math.random(-radius, radius), py + math.random(-radius, radius) } }
    end
    if energy > 100000 then
      surface.create_entity { name = "massive-explosion", position = { px + math.random(-radius, radius), py + math.random(-radius, radius) } }
    end

    local bursts = math.ceil(4 * fraction)
    local burst_radius = width + (2 * fraction)
    for _ = 1, math.ceil(width) do
      local flame = surface.create_entity { name = "oil-fire-flame", position = { px + math.random(-radius, radius), py + math.random(-radius, radius) } }
      first_flame = first_flame or flame
      for _ = 1, bursts do
        surface.create_entity { name = "oil-fire-flame", position = { px + math.random(-burst_radius, burst_radius), py + math.random(-burst_radius, burst_radius) } }
      end
    end
  end

  FO.fx.blast(surface, pos, energy, rec.catastrophe)

  if explosion_radius > 0 and explosion_damage > 0 then
    FO.fx.damage_area(surface, pos, explosion_radius, explosion_damage, damage_force, damage_type, source)
  end
  FO.fx.scan_hazards(surface, pos, math.max(explosion_radius, radius) + C.HAZARD_MARGIN, source)

  -- spread fires around if the explosion is big enough (upstream)
  if explosion_radius > 2 and damage_type == "fire" then
    local danger = math.min(explosion_radius * math.sqrt(explosion_radius), 400)
    for _ = 1, danger do
      local angle = math.pi * 2 * math.random()
      local range = math.random() * math.random() * explosion_radius
      surface.create_entity {
        name = "oil-fire-flame",
        position = { px + math.cos(angle) * range, py + math.sin(angle) * range },
        force = "neutral",
      }
    end
  end

  -- a tank catastrophe throws long fires over the whole perimeter
  if rec.catastrophe then
    local outer = math.max(radius + 6, math.min(40, explosion_radius * 1.5))
    local count = math.floor(math.max(C.LONG_FIRES_MIN, math.min(C.LONG_FIRES_MAX, energy / 250)))
    FO.fx.fire_ring(surface, pos, radius + 0.5, outer, count, "flo-long-fire")
  end

  -- the fire runs on through connected pipes
  for _, neighbour in pairs(rec.neighbours or {}) do
    FO.fuse.ignite(neighbour, (rec.chain or 0) + 1)
  end

  FO.alerts.explosion(rec, first_flame)
  if pollution >= C.SMOG_ACHIEVEMENT then FO.ach.near("flo-smog", surface, pos, 200) end
  if rec.catastrophe then FO.ach.near("flo-catastrophe", surface, pos, 150) end
end

---Explode now (inside the guard), ignoring the budget.
function M.run(rec, source)
  M.guarded(explode, rec, M.settings(), source)
end

---Explode now if possible, otherwise on a later tick (chain reaction or busy tick).
function M.dispatch(rec, source)
  if processing or not FO.sched.take_explosion_budget() then
    FO.sched.schedule(1, { kind = "explode", rec = rec })
  else
    M.run(rec, source)
  end
end

FO.sched.register("explode", function(task)
  M.run(task.rec)
end)

---Fire or toxic leak from a destroyed machine whose recipe handles dangerous fluids.
local function accident(entity, content, exploded, event)
  local recipe = entity.get_recipe()
  if not recipe and entity.type == "furnace" then
    local previous = entity.previous_recipe
    recipe = previous and previous.name
  end
  if not recipe then return end
  local flam, tox = FO.fluids.recipe_hazards(recipe)
  if not (flam or tox) then return end

  local box = entity.bounding_box
  local size = math.max(1, (box.right_bottom.x - box.left_top.x) * (box.right_bottom.y - box.left_top.y) / 9)

  if flam and not exploded then
    local rec = M.record(entity, {
      energy = C.ACCIDENT_ENERGY * size + (content and content.energy or 0),
      amount = C.ACCIDENT_AMOUNT * size + (content and content.amount or 0),
      fraction = 1,
      damage_type = content and content.fluid and content.damage_type or "fire",
    })
    rec.cause = M.cause_of(event)
    M.dispatch(rec, entity)
  end

  if tox then
    local surface, pos = entity.surface, entity.position
    local cloud
    for _ = 1, math.max(1, math.min(4, math.floor(size + 0.5))) do
      cloud = FO.fx.create(surface, "poison-cloud", { x = pos.x + math.random() * 4 - 2, y = pos.y + math.random() * 4 - 2 }, "neutral") or cloud
    end
    FO.fx.pollute(surface, pos, (content and content.toxic or 0) + C.TOXIC_POLLUTION * size)
    FO.alerts.toxic(entity, cloud)
  end
end

function M.on_entity_died(event)
  local entity = event.entity
  local entity_type = entity.type

  -- a burning tank always ends in a catastrophe, whatever killed it
  if entity_type == "storage-tank" and FO.tanks.is_burning(entity) then
    FO.tanks.burning_tank_died(entity, event)
    return
  end

  local damage_type = event.damage_type
  if not damage_type then return end
  local chance = C.CHANCES[damage_type.name]
  if not chance or chance < math.random() then return end

  if C.CONTAINER_INVENTORIES[entity_type] then
    FO.cook.on_died(entity, event)
    return
  end
  if entity_type == "pump" then return end

  local content = FO.fluids.measure(entity)
  local exploded = false
  if content and content.energy > C.MIN_ENERGY then
    local catastrophe = entity_type == "storage-tank" and content.energy >= C.CATASTROPHE_ENERGY
        and FO.tanks.is_tank(entity)
    local rec = M.record(entity, content, catastrophe)
    rec.cause = M.cause_of(event)
    M.dispatch(rec, entity)
    exploded = true
  end
  if entity_type == "assembling-machine" or entity_type == "furnace" then
    accident(entity, content, exploded, event)
  end
end

function M.on_entity_damaged(event)
  if not C.HEAT_DAMAGE[event.damage_type.name] or event.final_health <= 0 then return end
  local entity = event.entity
  if entity.type == "storage-tank" then
    if FO.tanks.is_burning(entity) or not M.check_cooldown(entity.unit_number) then return end
    FO.tanks.ignite(entity, M.cause_of(event))
  else
    FO.cook.start(entity)
  end
end

return M
