-- Load other libraries
local constants = require("constants")

-- Init ruin sets (empty for now)
---@type table<string, RuinSet>
local _ruin_sets = {}

---@type boolean
local debug_log = settings.global[constants.ENABLE_DEBUG_LOG_KEY].value
---@type boolean
local sanity = settings.startup[constants.ENABLE_EXPENSIVE_SANITY_CHECKS_KEY].value

-- "Class" for ruinsets
local ruinsets = {}

-- Get all ruin-sets
---@return table<string, RuinSet>
function ruinsets.all()
  if debug_log then log(string.format("[all]: _ruin_sets()=%d - EXIT!", #_ruin_sets)) end
  return _ruin_sets
end

-- Checks wether given ruinset name is found
function ruinsets.isset(name)
  if debug_log then log(string.format("[isset]: name[]='%s' - CALLED!", type(name))) end
  if type(name) ~= "string" then
    error(string.format("Parameter name[]='%s' is not expected type 'string'", type(name)))
  elseif #name == 0 then
    error("Parameter 'name' cannot be an empty string")
  end

  if debug_log then log(string.format("[isset]: Checking ruin-set name='%s' ...", name)) end
  local isset = (_ruin_sets[name] ~= nil)

  if debug_log then log(string.format("[isset]: isset=%s - EXIT!", isset)) end
  return isset
end

-- The ruins should have the sizes given in spawning.ruin_half_sizes, e.g. ruins in the small_ruins array should be 8x8 tiles.
-- See also: docs/ruin_sets.md
---@param name string
---@param ruin_sets table<string, Ruins[]>
function ruinsets.add(name, ruin_sets)
  if debug_log then log(string.format("[add]: name[]='%s',ruin_sets[]='%s' - CALLED!", type(name), type(ruin_sets))) end
  if type(name) ~= "string" then
    error(string.format("name[]='%s' is not expected type 'string'", type(name)))
  elseif #name == 0 then
    error("Parameter 'name' cannot be an empty string")
  elseif type(ruin_sets) ~= "table" then
    error(string.format("ruin_sets[]='%s' is not expected type 'table'", type(ruin_sets)))
  elseif (sanity or debug_log) and table_size(ruin_sets) == 0 then
    error(string.format("name='%s' has no ruin-sets included", name))
  end

  if debug_log then log(string.format("[add]: Setting name='%s' ruin-sets ...", name)) end
  _ruin_sets[name] = ruin_sets

  if debug_log then log("[add]: EXIT!") end
end

-- Returns the whole ruin-set table {small = {<array of ruins>}, medium = {<array of ruins>}, large = {<array of ruins>}}
---@param name string
---@return RuinSet
function ruinsets.get(name)
  if debug_log then log(string.format("[get]: name[]='%s' - CALLED!", type(name))) end
  if type(name) ~= "string" then
    error(string.format("name[]='%s' is not expected type 'string'", type(name)))
  elseif #name == 0 then
    error("Parameter 'name' cannot be an empty string")
  elseif _ruin_sets[name] == nil then
    error(string.format("ruin-set with name='%s' not found", name))
  elseif (sanity or debug_log) and table_size(_ruin_sets[name]) == 0 then
    error(string.format("name='%s' has no ruin-sets included", name))
  end

  if debug_log then log(string.format("[get]: _ruin_sets[%s][]='%s' - EXIT!", name, type(_ruin_sets[name]))) end
  return _ruin_sets[name]
end

return ruinsets
