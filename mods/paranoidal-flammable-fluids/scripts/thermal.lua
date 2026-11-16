-- Material failure, not fuel combustion: hot contents char wooden pipes even in a fire safety zone.
-- Only registered wooden pipes are sampled; no map scans during ordinary updates.
local FO = require("scripts.registry")
local C = require("scripts.config")
local M = {}
FO.thermal = M

local NAMES = { "bi-wood-pipe", "bi-wood-pipe-to-ground" }
local wooden = {}
for _, name in ipairs(NAMES) do wooden[name] = true end

function M.names()
  local out = {}
  for _, name in ipairs(NAMES) do
    if prototypes.entity[name] then out[#out + 1] = name end
  end
  return out
end

local function add(entity)
  if not (entity and entity.valid and wooden[entity.name] and entity.unit_number) then return end
  local s = storage.thermal
  if not s then s = { list = {}, by_id = {}, cursor = 1 }; storage.thermal = s end
  local id = entity.unit_number
  if s.by_id[id] then return end
  local rec = { entity = entity, id = id, last = game.tick, exposure = 0 }
  s.list[#s.list + 1] = rec
  s.by_id[id] = rec
end

function M.on_built(event)
  add(event.entity or event.destination)
end

-- Also discovers old pipes when this code is loaded into a save without a version change.
function M.sync()
  local s = storage.thermal
  if not s then s = { list = {}, by_id = {}, cursor = 1 }; storage.thermal = s end
  s.discovered = true
  local names = M.names()
  if #names == 0 then return end
  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered { name = names }) do add(entity) end
  end
end

local function hot_contents(entity)
  for i = 1, entity.fluids_count do
    local fluid = entity.get_fluid(i)
    if fluid and fluid.amount >= C.PIPE_MIN_AMOUNT and fluid.temperature > C.PIPE_SAFE_TEMPERATURE then
      return fluid, i
    end
  end
end

-- Full pipe failure time at constant temperature; trace amounts heat more slowly.
local function duration(fluid)
  local seconds = math.max(20, math.min(120, 120 * (200 / (fluid.temperature - C.PIPE_SAFE_TEMPERATURE)) ^ 1.2))
  return seconds * 60 / math.min(1, fluid.amount / C.PIPE_HEATING_AMOUNT)
end

local function clear_fire(entity)
  for _, fire in pairs(entity.surface.find_entities_filtered {
    name = "flo-pipe-fire", position = entity.position, radius = 0.4,
  }) do fire.destroy() end
end

local function sample(rec, tick)
  local entity = rec.entity
  local elapsed = math.max(0, tick - rec.last)
  rec.last = tick
  local fluid = hot_contents(entity)
  local before = rec.exposure
  if not fluid then
    rec.hot = nil
    rec.exposure = math.max(0, before - elapsed / C.PIPE_COOL_TIME)
    if before > 0 then clear_fire(entity) end
    if rec.exposure == 0 then rec.warned = nil end
    return
  end
  -- Bound only first detection; sustained backlog must not discard heating time forever.
  if not rec.hot then elapsed = math.min(C.PIPE_MAX_ELAPSED, elapsed) end
  rec.hot = true
  rec.exposure = math.min(1, before + elapsed / duration(fluid))
  if not rec.warned then
    rec.warned = true
    FO.alerts.pipe(entity, fluid)
  end
  if not rec.fx_tick or tick - rec.fx_tick >= C.PIPE_FX_INTERVAL then
    rec.fx_tick = tick
    local pos, surface = entity.position, entity.surface
    surface.create_trivial_smoke { name = "flo-black-smoke", position = pos }
    if rec.exposure >= 0.25 and tick >= (rec.quenched_until or 0) and not FO.protection.entity(entity) then
      surface.create_entity { name = "flo-pipe-fire", position = pos, force = "neutral" }
    end
  end
  if rec.exposure >= 1 then
    -- Repair bots and water cannot make wood a permanent conduit for molten metal.
    entity.damage(entity.health + entity.max_health, "neutral", "flo-thermal")
  elseif rec.exposure > 0.25 then
    local a = math.max(0.25, before)
    local damage = entity.max_health * (rec.exposure ^ 3 - a ^ 3) / (1 - 0.25 ^ 3)
    if damage > 0 then entity.damage(damage, "neutral", "flo-thermal") end
  end
end

function M.update(event)
  if not storage.thermal or not storage.thermal.discovered then M.sync() end
  local s = storage.thermal
  local list = s.list
  local count = math.min(#list, C.PIPE_CHECK_BUDGET, math.max(1, math.ceil(#list * FO.safety.STEP / C.PIPE_CHECK_PERIOD)))
  for _ = 1, count do
    if #list == 0 then break end
    if s.cursor > #list then s.cursor = 1 end
    local rec = list[s.cursor]
    if rec.entity.valid then
      sample(rec, event.tick)
      s.cursor = s.cursor + 1
    else
      s.by_id[rec.id] = nil
      list[s.cursor] = list[#list]
      list[#list] = nil
    end
  end
end

-- Called before the ordinary death handler measures the (now drained) contents.
-- Debit only this pipe's own share, never the entire connected fluid segment.
function M.on_died(entity)
  if not wooden[entity.name] then return end
  local fluid = hot_contents(entity)
  if not fluid then return end
  local content = FO.fluids.measure(entity)
  local amount = entity.extract_fluid { name = fluid.name, amount = math.min(fluid.amount, entity.get_fluid_capacity(1)) }
  if content then
    local fraction = math.min(1, amount / fluid.amount)
    content.energy = content.energy * fraction
    content.amount = content.amount * fraction
    content.toxic = content.toxic * fraction
    if fraction == 0 then content.volatile = false end
  end
  if amount >= C.PIPE_MIN_AMOUNT then
    FO.sched.schedule(1, { kind = "hot-spill", surface = entity.surface, position = entity.position,
      temperature = fluid.temperature, amount = amount })
  end
  return content
end

FO.sched.register("hot-spill", function(task)
  local surface, pos = task.surface, task.position
  if not surface.valid then return end
  -- Small local heat pulse, no oil explosion, fuel charge or pipe fuse for a metal melt.
  local scale = math.min(1, task.amount / 100) * math.min(2, (task.temperature - 200) / 800)
  FO.core.guarded(FO.fx.damage_area, surface, pos, 2, 20 * scale, "neutral", "flo-thermal")
  if not FO.protection.covers(surface, pos) then
    surface.create_entity { name = "flo-hot-spill", position = pos, force = "neutral" }
    surface.create_entity { name = "flo-pipe-fire", position = pos, force = "neutral" }
  end
end)

-- Water puts out the exterior fire; it neither changes the fluid nor erases thermal exposure.
function M.extinguish(entity)
  local s = storage.thermal
  local rec = s and s.by_id[entity.unit_number]
  if not rec or rec.exposure <= 0 then return false end
  rec.quenched_until = game.tick + C.PIPE_QUENCH_TIME
  clear_fire(entity)
  return true
end

function M.extinguish_area(surface_index, position, radius)
  local s = storage.thermal
  if not s then return 0 end
  local count = 0
  for _, rec in ipairs(s.list) do
    local entity = rec.entity
    if entity.valid and entity.surface_index == surface_index then
      local p = entity.position
      local dx, dy = p.x - position.x, p.y - position.y
      local reach = radius + entity.get_radius()
      if dx * dx + dy * dy <= reach * reach and M.extinguish(entity) then count = count + 1 end
    end
  end
  return count
end

return M
