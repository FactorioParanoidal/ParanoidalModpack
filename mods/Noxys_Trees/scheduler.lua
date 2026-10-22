-- Account in game ticks, not service calls: rounding must not slow 61 ticks to 90.
local scheduler = {}

function scheduler.initialize(state, tick)
  state.tick = 1 -- The original on_tick performs its first operation on the next tick.
  state.scheduler_tick = tick
  state.pending_operations = 0
end

function scheduler.advance(state, tick, interval, enabled)
  local elapsed = tick - state.scheduler_tick
  state.scheduler_tick = tick
  if not enabled or elapsed <= 0 then return end

  local remaining = state.tick - elapsed
  if remaining <= 0 then
    local due = math.floor(-remaining / interval) + 1
    state.pending_operations = state.pending_operations + due
    remaining = remaining + due * interval
  end
  state.tick = remaining
end

function scheduler.change_interval(state, interval)
  state.tick = math.min(state.tick, interval)
end

return scheduler
