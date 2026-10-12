-- Ruin traps for the "paranoidal" ruin set (AbandonedRuins-paranoidal, ruins "pd-flo-trap-*").
-- When a player comes close, the far end of the oil pipeline starts smoking, then ignites:
-- the fire crawls along the pipes to the tank, which overheats and blows up - a time bomb.
local FO = require("scripts.registry")
local C = require("scripts.config")

local M = {}
FO.traps = M

local CORE = "AbandonedRuins"

function M.on_ruin_spawned(event)
  local name = event.ruin_name
  if type(name) ~= "string" or name:sub(1, #C.TRAP_PREFIX) ~= C.TRAP_PREFIX then return end
  local surface = event.surface
  if not (surface and surface.valid and event.center) then return end
  storage.traps = storage.traps or {}
  table.insert(storage.traps, { surface = surface, x = event.center.x, y = event.center.y, half = event.half_size or 8 })
  M.sync()
end

---Ruin events are not saved by the core: subscribe in on_init and on_load.
function M.subscribe()
  local interface = remote.interfaces[CORE]
  if interface and interface["get_on_ruin_spawned_event"] then
    local event = remote.call(CORE, "get_on_ruin_spawned_event")
    if event then script.on_event(event, M.on_ruin_spawned) end
  end
end

local function distance2(a, b)
  local dx, dy = a.x - b.x, a.y - b.y
  return dx * dx + dy * dy
end

local function trigger(trap, player)
  local surface = trap.surface
  local area = { { trap.x - trap.half, trap.y - trap.half }, { trap.x + trap.half, trap.y + trap.half } }

  local tanks = {}
  for _, tank in pairs(surface.find_entities_filtered { area = area, type = "storage-tank" }) do
    local content = FO.fluids.measure(tank)
    if content and content.energy >= C.TANK_MIN_ENERGY and FO.tanks.is_tank(tank) then tanks[#tanks + 1] = tank end
  end
  if #tanks == 0 then return end -- already drained or destroyed: the trap is disarmed

  -- the fuse starts at the oil pipe farthest from every tank
  local start, start_distance
  for _, pipe in pairs(surface.find_entities_filtered { area = area, type = { "pipe", "pipe-to-ground" } }) do
    local content = FO.fluids.measure(pipe)
    if content and content.energy >= C.FUSE_MIN_ENERGY then
      local nearest = math.huge
      for _, tank in ipairs(tanks) do nearest = math.min(nearest, distance2(pipe.position, tank.position)) end
      if not start_distance or nearest > start_distance then start, start_distance = pipe, nearest end
    end
  end

  FO.ach.player("flo-trap", player)
  if not start then
    FO.tanks.ignite(tanks[1], { "flo-cause.trap" })
    return
  end
  -- smouldering before it catches fire
  local pos = start.position
  for _ = 1, 6 do
    surface.create_trivial_smoke { name = "flo-black-smoke", position = { pos.x + math.random() - 0.5, pos.y + math.random() - 0.5 } }
  end
  FO.sched.schedule(C.TRAP_DELAY, { kind = "trap", entity = start })
end

FO.sched.register("trap", function(task)
  local entity = task.entity
  if not (entity and entity.valid) then return end
  if entity.unit_number then
    storage.fuse_seen = storage.fuse_seen or {}
    storage.fuse_seen[entity.unit_number] = game.tick
  end
  FO.sched.schedule(1, { kind = "fuse", entity = entity, chain = 0, cause = { "flo-cause.trap" }, alert = true })
end)

local function check()
  local traps = storage.traps
  if traps then
    for i = #traps, 1, -1 do
      local trap = traps[i]
      if not trap.surface.valid then
        table.remove(traps, i)
      else
        local reach = trap.half + C.TRAP_MARGIN
        local index = trap.surface.index
        for _, player in pairs(game.connected_players) do
          local character = player.character
          if character and character.valid and character.surface.index == index then
            local pos = character.position
            if math.abs(pos.x - trap.x) <= reach and math.abs(pos.y - trap.y) <= reach then
              table.remove(traps, i)
              trigger(trap, player)
              break
            end
          end
        end
      end
    end
    if #traps == 0 then storage.traps = nil end
  end
  M.sync()
end

function M.sync()
  if storage.traps and next(storage.traps) ~= nil then
    script.on_nth_tick(C.TRAP_INTERVAL, check)
  else
    script.on_nth_tick(C.TRAP_INTERVAL, nil)
  end
end

return M
