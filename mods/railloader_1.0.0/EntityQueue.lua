local Event = require "Event"

-- Entity Queue
-- executes a task periodically for a set of entities,
-- inspecting only one entity per tick
local M = {}

function M:register(entity)
  global[self.name][entity.unit_number] = entity
  Event.register_nth_tick(self.interval, self.on_tick)
end

local function unregister_helper(self, key)
  local queue = global[self.name]
  if queue[key] then
    -- ensure iter always holds a valid key
    if key == global[self.iter_name] then
      global[self.iter_name] = next(queue, key)
    end
    queue[key] = nil
    if not next(queue) then
      Event.unregister_nth_tick(self.interval, self.on_tick)
    end
  end
end

function M:unregister(entity)
  unregister_helper(self, entity.unit_number)
end

function M:on_init()
  global[self.name] = {}
end

function M:on_load()
  local queue = global[self.name]
  local iter_name = self.iter_name
  if queue and next(queue) then
    if global[iter_name] and not queue[global[iter_name]] then
      global[iter_name] = nil
    end
    Event.register_nth_tick(self.interval, self.on_tick)
  end
end

local function create_on_tick(self)
  self.on_tick = function()
    local queue = global[self.name]
    local iter_name = self.iter_name
    if not queue[global[iter_name]] then
      global[iter_name] = nil
    end
    local k, v
    repeat
      k, v = next(queue, global[iter_name])
      global[iter_name] = k
      if not k and not next(queue) then
        -- table is empty
        Event.unregister_nth_tick(self.interval, self.on_tick)
        return
      end
      if v and not v.valid then
        unregister_helper(self, k)
      end
    until k and v and v.valid
    local should_unregister = self.task(v)
    if should_unregister then
      unregister_helper(self, k)
    end
  end
end

function M.new(name, interval, task)
  local self = {
    name = name,
    iter_name = name .. "_iter",
    interval = interval,
    task = task,
  }
  create_on_tick(self)

  local meta = {
    __index = M,
    __call = M.new,
  }
  return setmetatable(self, meta)
end

return M