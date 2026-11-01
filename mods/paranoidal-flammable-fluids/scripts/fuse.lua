-- Fuse: fire crawls pipe by pipe through connected fluid boxes while they hold flammable fluid.
-- Every step lights a flame on the pipe, scorches it and passes on after C.FUSE_DELAY ticks.
-- Empty pipes, pumps and valves stop it; a storage tank on the way starts overheating.
local FO = require("scripts.registry")
local C = require("scripts.config")

local M = {}
FO.fuse = M

---Light the fuse on an entity (each entity burns once per fire).
function M.ignite(entity, chain, cause)
  if not (entity and entity.valid) then return end
  local id = entity.unit_number
  if id then
    local seen = storage.fuse_seen
    if not seen then
      seen = {}
      storage.fuse_seen = seen
    end
    if seen[id] then return end
    seen[id] = game.tick
  end
  FO.sched.schedule(C.FUSE_DELAY, { kind = "fuse", entity = entity, chain = chain or 0, cause = cause })
end

local function scorch(entity, damage, damage_type)
  entity.damage(damage, "neutral", damage_type)
end

local function step(task)
  local entity = task.entity
  if not (entity and entity.valid) then return end
  local entity_type = entity.type
  if C.FUSE_STOP_TYPES[entity_type] then return end
  if FO.protection.entity(entity) then return end
  if entity_type == "storage-tank" and FO.tanks.is_tank(entity) then
    FO.tanks.ignite(entity, task.cause or { "flo-cause.fuse" })
    return
  end

  local content = FO.fluids.measure(entity)
  if not content or content.energy < C.FUSE_MIN_ENERGY then return end

  local surface, pos = entity.surface, entity.position
  local chain = task.chain or 0
  local flame = surface.create_entity { name = "oil-fire-flame", position = pos, force = "neutral" }
  if chain % 4 == 0 then surface.create_entity { name = "explosion", position = pos } end
  if task.alert and flame then FO.alerts.trap(flame) end

  local neighbours = FO.core.fluid_neighbours(entity) -- read first: the pipe may die below
  local cfg = FO.core.settings()
  local damage = cfg.d_mult * (content.energy * 10) ^ cfg.d_pow
  if damage > 0 then FO.core.guarded(scorch, entity, damage, "fire") end

  for _, neighbour in ipairs(neighbours) do
    if neighbour.valid then M.ignite(neighbour, chain + 1, task.cause) end
  end
  if chain + 1 == C.FUSE_ACHIEVEMENT then FO.ach.near("flo-fuse", surface, pos, 150) end
end

FO.sched.register("fuse", step)

return M
