-- Init ruin sets (empty for now)
---@type table<string, RuinSet>
local _ruin_sets = {}

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
    error(string.format("name[]='%s' is not expected type 'string'", type(name)))
  end

  if debug_log then log(string.format("[isset]: Checking ruin-set name='%s' ...", name)) end
  local isset = (_ruin_sets[name] ~= nil)

  if debug_log then log(string.format("[isset]: isset=%s - EXIT!", isset)) end
  return isset
end

-- The ruins should have the sizes given in utils.ruin_half_sizes, e.g. ruins in the small_ruins array should be 8x8 tiles.
-- See also: docs/ruin_sets.md
---@param name string
---@param ruin_sets table<string, Ruins[]>
function ruinsets.add(name, ruin_sets)
  if debug_log then log(string.format("[add]: name[]='%s',ruin_sets[]='%s' - CALLED!", type(name), type(ruin_sets))) end
  if type(name) ~= "string" then
    error(string.format("name[]='%s' is not expected type 'string'", type(name)))
  elseif type(ruin_sets) ~= "table" then
    error(string.format("ruin_sets[]='%s' is not expected type 'table'", type(ruin_sets)))
  elseif table_size(ruin_sets) == 0 then
    error(string.format("name='%s' has no ruin-sets included", name))
  end

  if debug_log then log(string.format("[add]: Setting name='%s' ruin-sets ...", name)) end
  _ruin_sets[name] = ruin_sets

  if debug_log then log("[add]: EXIT!") end
end

-- returns {small = {<array of ruins>}, medium = {<array of ruins>}, large = {<array of ruins>}}
---@param name string
---@return RuinSet
function ruinsets.get(name)
  if debug_log then log(string.format("[get]: name[]='%s' - CALLED!", type(name))) end
  if type(name) ~= "string" then
    error(string.format("name[]='%s' is not expected type 'string'", type(name)))
  elseif _ruin_sets[name] == nil then
    error(string.format("ruin-set with name='%s' not found", name))
  elseif table_size(_ruin_sets[name]) == 0 then
    error(string.format("name='%s' has no ruin-sets included", name))
  end

  if debug_log then log(string.format("[get]: _ruin_sets[%s][]='%s' - EXIT!", name, type(_ruin_sets[name]))) end
  return _ruin_sets[name]
end

return ruinsets
