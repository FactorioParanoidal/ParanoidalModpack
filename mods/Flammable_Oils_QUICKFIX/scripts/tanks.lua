-- Overheating storage tanks. A tank with flammable fluid caught by fire burns for
-- flo-tank-burn-time seconds; from the half on it pours thick black smoke. Unless it is drained
-- (or removed) in time, it explodes and throws long fires over the whole perimeter.
local FO = require("scripts.registry")
local C = require("scripts.config")

local M = {}
FO.tanks = M

function M.is_tank(entity)
  return entity.type == "storage-tank" and FO.fluids.capacity(entity) >= C.TANK_MIN_CAPACITY
end

function M.is_burning(entity)
  local id = entity.unit_number
  return id ~= nil and storage.tanks ~= nil and storage.tanks[id] ~= nil
end

function M.ignite(entity, cause)
  if not entity.valid then return end
  local id = entity.unit_number
  if not id then return end
  local tanks = storage.tanks
  if tanks and tanks[id] then return end
  if not M.is_tank(entity) then return end
  local content = FO.fluids.measure(entity)
  if not content or content.energy < C.TANK_MIN_ENERGY then return end
  if FO.protection.entity(entity) then return end

  if not tanks then
    tanks = {}
    storage.tanks = tanks
  end
  local duration = settings.global["flo-tank-burn-time"].value * 60
  local tick = game.tick
  tanks[id] = { entity = entity, start = tick, finish = tick + duration, initial = content.energy, updates = 0 }
  FO.alerts.tank(entity, duration, cause)
  FO.sched.schedule(1, { kind = "tank", id = id })
end

local function catastrophe(id, st, content)
  local entity = st.entity
  storage.tanks[id] = nil
  if next(storage.tanks) == nil then storage.tanks = nil end
  local rec = FO.core.record(entity, content, true)
  rec.cause = { "flo-cause.overheat" }
  FO.core.run(rec, entity)
  if entity.valid then entity.die() end -- no damage type: our death handler ignores it
end

---Killed while burning: the catastrophe happens right now.
function M.burning_tank_died(entity, event)
  storage.tanks[entity.unit_number] = nil
  if next(storage.tanks) == nil then storage.tanks = nil end
  if FO.protection.entity(entity) then return end
  local content = FO.fluids.measure(entity)
  if not content or content.energy <= C.MIN_ENERGY then return end
  local rec = FO.core.record(entity, content, true)
  rec.cause = FO.core.cause_of(event)
  FO.core.dispatch(rec, entity)
end

local function update(task)
  local tanks = storage.tanks
  local st = tanks and tanks[task.id]
  if not st then return end
  local entity = st.entity
  if not entity.valid then -- mined or removed by a script
    tanks[task.id] = nil
    if next(tanks) == nil then storage.tanks = nil end
    return
  end

  local content = FO.fluids.measure(entity)
  local energy = content and content.energy or 0
  if energy < math.max(C.TANK_MIN_ENERGY, st.initial * C.TANK_SAVED_FRACTION) or FO.protection.entity(entity) then
    tanks[task.id] = nil
    if next(tanks) == nil then storage.tanks = nil end
    FO.alerts.tank_saved(entity)
    FO.ach.near("flo-tank-saved", entity.surface, entity.position, 100)
    return
  end

  local tick = game.tick
  if tick >= st.finish then
    catastrophe(task.id, st, content)
    return
  end

  local surface, box = entity.surface, entity.bounding_box
  for _ = 1, 2 do
    surface.create_entity { name = "flo-tank-fire", position = FO.fx.random_point(box, 0.6), force = "neutral" }
  end

  local half = st.start + (st.finish - st.start) / 2
  if tick >= half then
    local progress = (tick - half) / math.max(1, st.finish - half)
    for _ = 1, 3 + math.floor(6 * progress) do
      surface.create_trivial_smoke { name = "flo-black-smoke", position = FO.fx.random_point(box, 0.2) }
    end
    if not st.smoke then
      st.smoke = true
      FO.alerts.tank_smoke(entity, st.finish - tick)
    end
  end

  st.updates = st.updates + 1
  if st.updates % 4 == 0 then
    local pos = entity.position
    local radius = math.max(box.right_bottom.x - pos.x, box.right_bottom.y - pos.y)
    FO.fx.scan_hazards(surface, pos, radius + 6, entity, true)
  end
  FO.sched.schedule(C.TANK_UPDATE, task)
end

FO.sched.register("tank", update)

return M
