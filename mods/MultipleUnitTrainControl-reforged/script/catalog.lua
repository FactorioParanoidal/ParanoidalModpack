-- Pairs of normal and MU locomotives, read once per session from the mod-data written in data-final-fixes.
-- The caches depend only on prototypes, so they are identical for every peer and are never stored.
local shared = require("shared")

local M = {}
local std_to_mu, mu_to_std, bonus_of, quality_cache

local function load()
  std_to_mu, mu_to_std, bonus_of, quality_cache = {}, {}, {}, {}
  local catalog = prototypes.mod_data[shared.catalog]
  for std, entry in pairs(catalog and catalog.data or {}) do
    if prototypes.entity[std] and prototypes.entity[entry.mu] then
      std_to_mu[std] = entry.mu
      mu_to_std[entry.mu] = std
      bonus_of[std] = entry.bonus
    end
  end
end

-- Normal name of a locomotive that has an MU twin (for both the normal and the twin name), else nil.
function M.base(name)
  if not std_to_mu then load() end
  if std_to_mu[name] then return name end
  return mu_to_std[name]
end

function M.mu(std)
  if not std_to_mu then load() end
  return std_to_mu[std]
end

-- Normal name of an MU twin, nil for anything else.
function M.std(mu)
  if not std_to_mu then load() end
  return mu_to_std[mu]
end

function M.bonus(std)
  if not std_to_mu then load() end
  return bonus_of[std] or 0
end

-- True when the quality of a locomotive changes its power: then only locomotives of the same quality
-- are paired, otherwise a pair of mixed quality would pull with the power of the stronger one twice.
function M.quality_matters(std)
  if not std_to_mu then load() end
  local known = quality_cache[std]
  if known == nil then
    known = false
    local prototype = prototypes.entity[std]
    local normal = prototype.get_max_energy_usage("normal")
    for name in pairs(prototypes.quality) do
      if prototype.get_max_energy_usage(name) ~= normal then
        known = true
        break
      end
    end
    quality_cache[std] = known
  end
  return known
end

return M
