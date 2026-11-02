-- Delayed jobs by tick: storage.jobs[tick] = { {kind = ..., ...}, ... }. Handlers register by kind.
local R = require("scripts.registry")

local M = {}
R.jobs = M

local handlers = {}

function M.handler(kind, fn)
  handlers[kind] = fn
end

function M.after(delay, job)
  local jobs = storage.jobs
  if not jobs then
    jobs = {}
    storage.jobs = jobs
  end
  local tick = game.tick + math.max(1, math.floor(delay))
  local list = jobs[tick]
  if not list then
    list = {}
    jobs[tick] = list
  end
  list[#list + 1] = job
end

function M.run(tick)
  local jobs = storage.jobs
  local list = jobs and jobs[tick]
  if not list then return end
  jobs[tick] = nil
  for i = 1, #list do
    local job = list[i]
    local fn = handlers[job.kind]
    if fn then fn(job) end
  end
end

-- Drop jobs of a deleted surface and jobs left in the past (older saves, settings changes).
function M.purge(surface_index)
  local jobs = storage.jobs
  if not jobs then return end
  local now = game.tick
  for tick, list in pairs(jobs) do
    if tick < now then
      jobs[tick] = nil
    elseif surface_index then
      for i = #list, 1, -1 do
        if list[i].surface_index == surface_index then table.remove(list, i) end
      end
      if #list == 0 then jobs[tick] = nil end
    end
  end
end

return M
