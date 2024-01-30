-- The only thing we're doing is auto-join, so don't even bother if it's not enabled
if not settings.startup["fmf-enable-duct-auto-join"].value then
  return
end

-- The entire file below this point is copied in src/prototypes/tips-and-tricks.lua for the drag building simulation

--- Calculates the midpoint between two positions.
--- @param pos_1 MapPosition
--- @param pos_2 MapPosition
--- @return MapPosition
local function get_midpoint(pos_1, pos_2)
  return {
    x = (pos_1.x + pos_2.x) / 2,
    y = (pos_1.y + pos_2.y) / 2,
  }
end

--- @param e EventData.on_built_entity|EventData.on_robot_built_entity|EventData.script_raised_built|EventData.script_raised_revive
local function join_ducts(e)
  --- @type LuaEntity
  local entity = e.entity or e.created_entity
  if not entity or not entity.valid then
    return
  end

  -- Straight ducts only have one fluidbox
  for _, neighbour in pairs(entity.neighbours[1]) do
    if entity.name == neighbour.name then
      local direction = entity.direction
      local force = entity.force
      local last_user = entity.last_user
      local name = entity.name == "duct-small" and "duct" or "duct-long"
      local position = get_midpoint(entity.position, neighbour.position)
      local surface = entity.surface

      entity.destroy({ raise_destroy = true })
      neighbour.destroy({ raise_destroy = true })

      surface.create_entity({
        name = name,
        position = position,
        direction = direction,
        force = force,
        player = last_user,
        raise_built = true,
        create_build_effect_smoke = false,
      })

      -- Only do one join per build
      break
    end
  end
end

local event_filter = { { filter = "name", name = "duct-small" }, { filter = "name", name = "duct" } }

script.on_event(defines.events.on_built_entity, join_ducts, event_filter)
script.on_event(defines.events.on_robot_built_entity, join_ducts, event_filter)
script.on_event(defines.events.script_raised_built, join_ducts, event_filter)
script.on_event(defines.events.script_raised_revive, join_ducts, event_filter)
