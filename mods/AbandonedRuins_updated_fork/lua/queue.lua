-- Load other libraries
local constants = require("constants")
local planets   = require("planets")
local surfaces  = require("surfaces")
local utils     = require("utilities")

---@type boolean
local debug_log = settings.global[constants.ENABLE_DEBUG_LOG_KEY].value
---@type boolean
local sanity = settings.startup[constants.ENABLE_EXPENSIVE_SANITY_CHECKS_KEY].value

--- "Class/library" for ruin FIFO queue
local queue = {}

-- Paranoidal: the queue lives in storage. The former module-local table was not saved, so
-- queued ruins were lost on save/load and a player joining between queueing and spawning
-- had a different state (desync). Its `queue.ruins[#queue.ruins] = item` also overwrote the
-- single slot 0, so at most one ruin per spawn tick survived.
-- Only call these functions from events where storage may be written (not from on_load).
---@return RuinQueueItem[]
local function get_queue()
  if storage.ruins_spawn_queue == nil then
    storage.ruins_spawn_queue = {}
  end
  return storage.ruins_spawn_queue
end

-- Adds given ruin to the queue. So next invocation of on_nth_tick() will spawn it
---@param item RuinQueueItem Must contain 'surface' (LuaSurface), 'size' (string) and 'center' (LuaPosition)
function queue.add_ruin(item)
  if debug_log then log(string.format("[add_ruin]: item[]='%s' - CALLED!", type(item))) end
  if type(item) ~= "table" then
    error(string.format("Parameter item[]='%s' is not of unexpected type 'table'", type(item)))
  elseif type(item.surface) ~= "userdata" then
    error(string.format("item.surface[]='%s' is not expected type 'userdata'", type(item.surface)))
  elseif not item.surface.valid then
    error("Invalid item.surface provided")
  elseif item.surface.name == constants.DEBUG_SURFACE_NAME then
    error(string.format("item.surface='%s' is a debug surface and has no random ruin spawning.", item.surface.name))
  elseif item.surface.generate_with_lab_tiles == true then
    error(string.format("item.surface.name='%s' is a lab, no spawning allowed", item.surface.name))
  elseif (sanity or debug_log) and item.surface.planet ~= nil and not planets.is_planet_allowed(item.surface.planet) then
    error(string.format("item.surface.name='%s' is associated with a planet not allowing spawning", item.surface.name))
  elseif (sanity or debug_log) and utils.str_contains_any_from_table(item.surface.name, surfaces.get_all_excluded()) then
    error(string.format("item.surface.name='%s' is excluded, cannot spawn ruins on", item.surface.name))
  elseif type(item.size) ~= "string" then
    error(string.format("Table item.size[]='%s' is not of unexpected type 'string'", type(item.size)))
  elseif #item.size == 0 then
    error("item.size is an empty string")
  elseif type(item.center) ~= "table" then
    error(string.format("Table item.center[]='%s' is not of unexpected type 'table'", type(item.center)))
  end

  if debug_log then log(string.format("[add_ruin]: Queueing item[]='%s' ...", type(item))) end
  local ruins = get_queue()
  ruins[#ruins + 1] = item

  if debug_log then log("[add_ruin]: EXIT!") end
end

--- Get all ruins
---@return RuinQueueItem[]
function queue.get_ruins()
  return get_queue()
end

--- Resets queue for ruins
function queue.reset_ruins()
  storage.ruins_spawn_queue = {}
end

return queue
