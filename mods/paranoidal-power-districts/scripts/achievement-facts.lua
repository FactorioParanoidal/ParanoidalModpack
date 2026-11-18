-- Consecutive controller measurements; no assertion that every underlying tick was sampled.
local M = {}
local event = script.generate_event_name()
function M.get_event() return event end
function M.reset(record) if record then record.achievement_interval = nil end end
function M.sample(lead, members, group, tick, status, enabled, nominal, fraction, draw, saving, period)
  local dt = lead._dt
  local valid = enabled and not group.bypass and not group.loop and not group.conv and status == "zone"
    and nominal > 0 and fraction > 0 and draw > 0 and lead._achievement_lt ~= nil
    and dt > 0 and dt <= period * 2 and tick - lead._achievement_lt == dt
  local supplied = 0
  if valid then
    for _, member in ipairs(members) do
      if member._achievement_lt == nil or member._dt ~= dt or tick - member._achievement_lt ~= dt
        or member.e.force.index ~= lead.force then valid = false;break end
      supplied = supplied + member._dr * fraction
    end
  end
  if not valid or supplied <= 0 then M.reset(lead);return end
  local signature = table.concat(group.units, ",")
  local interval = lead.achievement_interval
  if not interval or interval.force ~= lead.force or interval.district ~= lead.did
    or interval.signature ~= signature or interval.last_tick ~= lead._achievement_lt then
    interval = {force = lead.force, district = lead.did, signature = signature, ticks = 0, saved = 0, supplied = 0}
    lead.achievement_interval = interval
  end
  interval.ticks = interval.ticks + dt
  interval.saved = interval.saved + saving
  interval.supplied = interval.supplied + supplied
  interval.last_tick = tick
  if interval.ticks >= 3600 then
    lead.achievement_interval = nil
    if interval.saved > 0 then
      script.raise_event(event, {force_index = interval.force, surface_index = lead.e.surface.index,
        entity_unit_number = lead.unit, district_id = interval.district, district_status = status,
        controller_measured_ticks = interval.ticks, saved_energy_j = interval.saved,
        non_transit_output_energy_j = interval.supplied})
    end
  end
end
return M
