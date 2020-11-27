local Event = require "Event"

local M = {}

local on_tick
on_tick = function()
  local tasks = global.end_of_tick_tasks
  if tasks then
    for _, task in ipairs(tasks) do
      task()
    end
    global.end_of_tick_tasks = nil
    Event.unregister_nth_tick(1, on_tick)
  end
end

function M.register(task)
  if not global.end_of_tick_tasks then
    global.end_of_tick_tasks = {}
    Event.register_nth_tick(1, on_tick)
  end
  table.insert(global.end_of_tick_tasks, task)
end

function M.unregister(task)
  local tasks = global.end_of_tick_tasks
  if tasks then
    for k, queued_task in ipairs(tasks) do
      if queued_task == task then
        table.remove(tasks, k)
        if not next(tasks) then
          Event.unregister_nth_tick(1, on_tick)
        end
        return
      end
    end
  end
end

function M.on_load()
  local tasks = global.end_of_tick_tasks
  if tasks and next(tasks) then
    Event.register_nth_tick(1, on_tick)
  end
end

return M
