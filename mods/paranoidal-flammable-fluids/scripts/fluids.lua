-- Fluid classification (flammable / gas / toxic) and measuring of entity contents.
-- Tables are derived from prototypes only (identical on every peer): flammable = fuel value above zero
-- (the explosion energy is computed from the fuel value, so nothing else can burn).
local FO = require("scripts.registry")
local C = require("scripts.config")

local M = {}
FO.fluids = M

-- Toxic gases and vapours of the build (Angels, Bob, Clowns, petrochem): released as a poison cloud.
local TOXIC_PATTERNS = {
  "chlor", "sulfide", "ammonia", "cyan", "nitrogen-dioxide", "nitrogen-monoxide", "nitric-oxide",
  "tetroxide", "sulfur-dioxide", "fluor", "phosgene", "carbon-monoxide", "mercury", "alien-poison",
  "hydrazine",
}
local TOXIC_EXCLUDE = { "solution", "brine" }

local flammable, gas, toxic
local recipe_cache = {}

local function has_any(name, patterns)
  for _, p in ipairs(patterns) do
    if string.find(name, p, 1, true) then return true end
  end
  return false
end

local function build()
  flammable, gas, toxic = {}, {}, {}
  for name, fluid in pairs(prototypes.fluid) do
    flammable[name] = fluid.fuel_value > 0

    -- Gas if the default temperature is above the gas temperature, or by name (upstream rule)
    if fluid.default_temperature > fluid.gas_temperature then
      gas[name] = true
    else
      gas[name] = string.find(name, "gasoline", 1, true) == nil and
          (string.find(name, "-gas", 1, true) ~= nil or string.find(name, "gas-", 1, true) ~= nil)
    end

    toxic[name] = has_any(name, TOXIC_PATTERNS) and not has_any(name, TOXIC_EXCLUDE)
  end
end

function M.reset()
  flammable, gas, toxic = nil, nil, nil
  recipe_cache = {}
end

function M.flammable_types()
  if not flammable then build() end
  return flammable
end

---Flammable and toxic contents of an entity, or nil when there is nothing dangerous inside.
---Energy of volatile gases is multiplied by C.VOLATILE; volatile = such a gas fills a box above
---C.VOLATILE_MIN_FRACTION.
---@return {energy: number, amount: number, toxic: number, fluid: string?, fraction: number, damage_type: string, volatile: boolean}?
-- Factorio 2.1: LuaEntity::fluidbox was removed; fluid storages are read by index (get_fluid, get_fluid_capacity).
-- fluids_count also covers storages without a fluid box (a fluid turret's buffer, a fluid wagon); like 2.0, only the
-- storages of fluid boxes are counted.
local function box_indices(entity)
  local list = {}
  for k = 1, entity.fluids_count do
    if entity.get_fluid_box_prototype(k) then list[#list + 1] = k end
  end
  return list
end

function M.measure(entity)
  local indices = box_indices(entity)
  if #indices == 0 then return nil end
  if not flammable then build() end

  local fluids = prototypes.fluid
  local energy, amount, toxic_amount = 0, 0, 0
  local volatile = false
  local best, best_energy, best_index, best_amount = nil, 0, 1, 0
  for _, k in ipairs(indices) do
    local pot = entity.get_fluid(k)
    if pot then
      local name, a = pot.name, pot.amount
      if flammable[name] then
        local mult = C.VOLATILE[name]
        local e = fluids[name].fuel_value * a / 1000000.0 * (mult or 1)
        if e > 0 then
          energy = energy + e
          amount = amount + a
          if e > best_energy then best, best_energy, best_index, best_amount = name, e, k, a end
          if mult and not volatile then
            local capacity = entity.get_fluid_capacity(k)
            volatile = capacity > 0 and a / capacity > C.VOLATILE_MIN_FRACTION
          end
        end
      end
      if toxic[name] then toxic_amount = toxic_amount + a end
    end
  end
  if not best and toxic_amount == 0 then return nil end

  local fraction = 0
  if best then
    local capacity = entity.get_fluid_capacity(best_index)
    if capacity > 0 then fraction = math.min(1, best_amount / capacity) end
  end
  return {
    energy = energy,
    amount = amount,
    toxic = toxic_amount,
    fluid = best,
    fraction = fraction,
    damage_type = best and gas[best] and "explosion" or "fire",
    volatile = volatile,
  }
end

---Capacity of the first fluid box (0 without fluid boxes).
function M.capacity(entity)
  local indices = box_indices(entity)
  if #indices == 0 then return 0 end
  return entity.get_fluid_capacity(indices[1])
end

---Does a recipe (LuaRecipe or LuaRecipePrototype) handle flammable / toxic fluids?
function M.recipe_hazards(recipe)
  local cached = recipe_cache[recipe.name]
  if not cached then
    if not flammable then build() end
    local flam, tox = false, false
    local function scan(list)
      for _, f in pairs(list or {}) do
        if f.type == "fluid" then
          if flammable[f.name] then flam = true end
          if toxic[f.name] then tox = true end
        end
      end
    end
    scan(recipe.ingredients)
    scan(recipe.products)
    cached = { flam, tox }
    recipe_cache[recipe.name] = cached
  end
  return cached[1], cached[2]
end

return M
