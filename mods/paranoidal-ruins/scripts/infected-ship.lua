-- Only the new colony has this lifecycle; existing wrecks and the expedition are untouched.
local M = {}
M.NAME = "pd-infected-ship-nest"
local WRECK = "pd-infected-ship-wreck"
local FORCE = "AbandonedRuins:enemy"

-- The ruins force is not the native enemy force. Mirror surface evolution without scanning nests.
-- Called by the existing 120-tick journal check, and before a new colony starts spawning.
function M.sync_evolution(surface)
  local force = game.forces[FORCE]
  if not force then return end
  local function sync(s)
    force.set_evolution_factor(game.forces.enemy.get_evolution_factor(s), s)
  end
  if surface then sync(surface) else
    for _, s in pairs(game.surfaces) do sync(s) end
  end
end

function M.on_entity_died(event)
  local entity = event.entity
  if not (entity and entity.valid and entity.name == M.NAME) then return end
  -- Death callbacks still see the original hull. Do not create an overlapping replacement here.
  local id = script.register_on_object_destroyed(entity)
  storage.infected_ship_deaths = storage.infected_ship_deaths or {}
  if storage.infected_ship_deaths[id] then return end
  storage.infected_ship_deaths[id] = {
    surface = entity.surface_index,
    position = {x = entity.position.x, y = entity.position.y},
    direction = entity.direction, quality = entity.quality.name,
  }
end

function M.on_object_destroyed(event)
  local pending = storage.infected_ship_deaths
  local death = pending and pending[event.registration_number]
  if not death then return end
  -- Consume first: a repeated notification, mining or destruction of the wreck cannot pay again.
  pending[event.registration_number] = nil
  if not next(pending) then storage.infected_ship_deaths = nil end
  local surface = game.get_surface(death.surface)
  if not surface then return end
  local wreck = surface.create_entity{
    name = WRECK, position = death.position, direction = death.direction, quality = death.quality,
    force = "neutral", snap_to_grid = false, create_build_effect_smoke = false,
  }
  if not wreck then
    log("[paranoidal-ruins] could not create freed infected hull on surface " .. death.surface)
    return
  end
  -- Materials only. Carry the source quality instead of silently dropping it on replacement.
  for _, stack in ipairs({{"iron-plate", 30}, {"copper-cable", 20}, {"steel-plate", 8}, {"pipe", 8}}) do
    wreck.insert{name = stack[1], count = stack[2], quality = death.quality}
  end
end

return M
