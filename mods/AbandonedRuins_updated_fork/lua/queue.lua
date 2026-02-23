local constants = require("constants")
local utils = require("utilities")

--- "Class/library" for ruin queue
local queue = {}

-- Ruin queue
---@type RuinQueueItem[]
queue.ruins = {}

-- Adds given ruin to the queue. So next invocation of on_nth_tick() will spawn it
---@param queue_item RuinQueueItem Must contain 'surface' (LuaSurface), 'size' (string) and 'center' (LuaPosition)
function queue.add_ruin(queue_item)
  if debug_log then log(string.format("[add_ruin]: queue_item[]='%s' - CALLED!", type(queue_item))) end
  if type(queue_item) ~= "table" then
    error(string.format("Parameter queue_item[]='%s' is not of unexpected type 'table'", type(queue_item)))
  elseif type(queue_item.surface) ~= "userdata" then
    error(string.format("Table queue_item.surface[]='%s' is not of unexpected type 'userdata'", type(queue_item.surface)))
  elseif queue_item.surface.name == constants.DEBUG_SURFACE_NAME then
    error(string.format("Debug surface '%s' has no random ruin spawning.", queue_item.surface.name))
  elseif type(queue_item.size) ~= "string" then
    error(string.format("Table queue_item.size[]='%s' is not of unexpected type 'string'", type(queue_item.size)))
  elseif type(queue_item.center) ~= "table" then
    error(string.format("Table queue_item.center[]='%s' is not of unexpected type 'table'", type(queue_item.center)))
  end

  if debug_log then log(string.format("[add_ruin]: Queueing queue_item[]='%s' ...", type(queue_item))) end
  queue.ruins[#queue.ruins] = queue_item

  if debug_log then log("[add_ruin]: EXIT!") end
end

--- Get all ruins
---@return RuinQueueItem[]
function queue.get_ruins()
  return queue.ruins
end

--- Resets queue for ruins
function queue.reset_ruins()
  queue.ruins = {}
end

return queue
