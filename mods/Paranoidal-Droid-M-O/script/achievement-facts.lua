-- Positive facts of a real useful sortie, not the contents somebody put in the bin.
local M = {}
local event = script.generate_event_name()
function M.get_event() return event end
function M.begin(data)
  data.achievement_cycle = {cleaned = 0, force = data.dock.force.index, surface = data.dock.surface.index}
end
function M.cleaned(data)
  local cycle = data.achievement_cycle
  if cycle then cycle.cleaned = cycle.cleaned + 1 end
end
function M.returned(data, success)
  local cycle = data.achievement_cycle
  if success and cycle then cycle.returned = true else data.achievement_cycle = nil end
end
function M.service(data, capacity, charging, distance)
  local cycle, dock, bot = data.achievement_cycle, data.dock, data.bot
  if not (cycle and cycle.returned and cycle.cleaned > 0 and data.state == charging
    and dock and dock.valid and bot and bot.valid and bot.surface == dock.surface
    and dock.force.index == cycle.force and dock.surface.index == cycle.surface
    and data.backpack and data.backpack.valid and data.backpack.is_empty() and data.battery >= capacity) then return end
  local pos, port = bot.position, data.port
  if (pos.x - port.x)^2 + (pos.y - port.y)^2 >= distance^2 then return end
  data.achievement_cycle = nil -- consume before callbacks
  script.raise_event(event, {force_index = cycle.force, surface_index = cycle.surface,
    entity_unit_number = dock.unit_number, success = true, cleaned_count = cycle.cleaned,
    unloaded = true, charged = true})
end
return M
