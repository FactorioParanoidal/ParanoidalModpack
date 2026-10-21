-- Delayed tasks: storage.sched[tick] = { {kind = ..., ...}, ... }.
-- on_tick is registered only while tasks are pending. Every task kind has a handler; tasks over
-- the per-tick budget move to the next tick, so a huge fire never runs in one tick.
local FO = require("scripts.registry")
local C = require("scripts.config")

local M = {}
FO.sched = M

local handlers = {}

function M.register(kind, handler)
  handlers[kind] = handler
end

-- Explosion budget, shared by queued and immediate explosions. Deterministic: every peer
-- runs the same events in the same order within a tick.
local budget_tick, budget_used = -1, 0

function M.take_explosion_budget()
  local tick = game.tick
  if budget_tick ~= tick then budget_tick, budget_used = tick, 0 end
  if budget_used >= C.MAX_EXPLOSIONS_PER_TICK then return false end
  budget_used = budget_used + 1
  return true
end

local on_tick

function M.sync()
  local sched = storage.sched
  if sched and next(sched) ~= nil then
    script.on_event(defines.events.on_tick, on_tick)
  else
    script.on_event(defines.events.on_tick, nil)
  end
end

function M.schedule(delay, task)
  local sched = storage.sched
  if not sched then
    sched = {}
    storage.sched = sched
  end
  local was_empty = next(sched) == nil
  local tick = game.tick + math.max(1, math.floor(delay))
  local bucket = sched[tick]
  if not bucket then
    bucket = {}
    sched[tick] = bucket
  end
  bucket[#bucket + 1] = task
  if was_empty then M.sync() end
end

function M.pending()
  return storage.sched ~= nil and next(storage.sched) ~= nil
end

-- Per-fire bookkeeping is dropped when nothing burns any more.
local function idle_cleanup()
  storage.sched = nil
  storage.fuse_seen = nil
  storage.checked = nil
end

on_tick = function(event)
  local sched = storage.sched
  local tick = event.tick
  if sched then
    local bucket = sched[tick]
    if bucket then
      sched[tick] = nil
      local done, deferred = 0, nil
      for i = 1, #bucket do
        local task = bucket[i]
        if done < C.MAX_TASKS_PER_TICK and (task.kind ~= "explode" or M.take_explosion_budget()) then
          done = done + 1
          local handler = handlers[task.kind]
          if handler then handler(task) end
        else
          deferred = deferred or {}
          deferred[#deferred + 1] = task
        end
      end
      if deferred then
        local nxt = sched[tick + 1]
        if nxt then
          for _, task in ipairs(nxt) do deferred[#deferred + 1] = task end
        end
        sched[tick + 1] = deferred
      end
    end

    -- Safety net: a bucket in the past (e.g. edited save) would block the handler forever.
    if tick % 600 == 0 then
      local stale = {}
      for t in pairs(sched) do
        if t <= tick then stale[#stale + 1] = t end
      end
      for _, t in ipairs(stale) do
        local old = sched[t]
        sched[t] = nil
        for _, task in ipairs(old) do M.schedule(1, task) end
      end
    end

    if next(sched) == nil then idle_cleanup() end
  else
    idle_cleanup()
  end
  M.sync()
end

-- The previous fork version kept chain explosions in storage.queue.
function M.migrate()
  local q = storage.queue
  if not q then return end
  storage.queue = nil
  for i = q.head or 1, q.tail or 0 do
    local e = q[i]
    if e and e.surface then
      M.schedule(1, { kind = "explode", rec = {
        surface = e.surface, position = e.position, radius = e.radius or 0.5, force = e.force,
        energy = e.energy or 0, amount = 0, fraction = e.fraction or 0,
        damage_type = e.damage_type or "fire", neighbours = e.neighbour and { e.neighbour } or nil,
      } })
    end
  end
end

return M
