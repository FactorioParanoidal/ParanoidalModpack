-- Helpers for content catalogs: families of similar entries.
local lib = {}

-- One entry per value: make(value) returns the entry.
function lib.each(values, make)
  local result = {}
  for _, value in ipairs(values) do table.insert(result, make(value)) end
  return result
end

-- Flattens lists of entries (single entries and lists from lib.each) into one list.
function lib.list(...)
  local result = {}
  for _, part in ipairs({...}) do
    if part.id or part.kind then
      table.insert(result, part)
    else
      for _, entry in ipairs(part) do table.insert(result, entry) end
    end
  end
  return result
end

-- Turret entity types; ranked HeroTurretRedux copies are "hero-turret-<rank>-for-<base>".
lib.TURRET_TYPES = {"ammo-turret", "electric-turret", "fluid-turret", "artillery-turret", "turret"}

function lib.turrets(base_patterns)
  local patterns = {}
  for _, pattern in ipairs(base_patterns) do
    table.insert(patterns, "^" .. pattern .. "$")
    table.insert(patterns, "^hero%-turret%-%d+%-for%-" .. pattern .. "$")
  end
  return {patterns = patterns, types = lib.TURRET_TYPES}
end

return lib
