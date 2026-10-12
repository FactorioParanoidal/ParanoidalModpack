-- Fluid classification (flammable / gas / toxic) and measuring of entity contents.
-- Tables are derived from prototypes (identical on every peer) plus saved remote overrides.
local FO = require("scripts.registry")

local M = {}
FO.fluids = M

local FLAMMABLE_OVERRIDE = {
  ["crude-oil"] = true,
  ["heavy-oil"] = true,
  ["light-oil"] = true,
  ["lubricant"] = false,
  ["gas-hydrogen"] = true,
  ["gas-methane"] = true,
  ["gas-ethane"] = true,
  ["gas-butane"] = true,
  ["gas-propene"] = true,
  ["liquid-naphtha"] = true,
  ["liquid-mineral-oil"] = true,
  ["liquid-fuel-oil"] = true,
  ["gas-methanol"] = true,
  ["gas-ethylene"] = true,
  ["gas-benzene"] = true,
  ["gas-synthesis"] = true,
  ["gas-butadiene"] = true,
  ["gas-phenol"] = true,
  ["gas-ethylbenzene"] = true,
  ["gas-styrene"] = true,
  ["gas-formaldehyde"] = true,
  ["gas-polyethylene"] = true,
  ["gas-glycerol"] = true,
  ["gas-natural-1"] = true,
  ["liquid-multi-phase-oil"] = true,
  ["gas-raw-1"] = true,
  ["liquid-condensates"] = true,
  ["liquid-ngl"] = true,
  ["gas-chlor-methane"] = true,
  ["hydrogen"] = true,
  ["liquid-fuel"] = true,
  ["diesel-fuel"] = true,
  ["petroleum-gas"] = true,
  ["water"] = false,
  ["sulfuric-acid"] = false,
  ["molten-tiberium"] = true,
  ["tiberium-waste"] = false,
  ["tiberium-sludge"] = false,
  ["tiberium-slurry"] = false,
  ["liquid-tiberium"] = true,
  ["tiberium-slurry-blue"] = false,
  ["cubeine-solution"] = false,
}

local GAS_OVERRIDE = {
  ["liquid-cubonium"] = true,
}

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

  for name, value in pairs(FLAMMABLE_OVERRIDE) do flammable[name] = value end
  for name, value in pairs(GAS_OVERRIDE) do gas[name] = value end
  for name, value in pairs(storage.remote_overrides or {}) do flammable[name] = value end
end

function M.reset()
  flammable, gas, toxic = nil, nil, nil
  recipe_cache = {}
end

function M.flammable_types()
  if not flammable then build() end
  return flammable
end

function M.set_override(name, value)
  storage.remote_overrides = storage.remote_overrides or {}
  storage.remote_overrides[name] = value
  M.flammable_types()[name] = value
end

---Flammable and toxic contents of an entity, or nil when there is nothing dangerous inside.
---@return {energy: number, amount: number, toxic: number, fluid: string?, fraction: number, damage_type: string}?
function M.measure(entity)
  local boxes = entity.fluidbox
  local n = #boxes
  if n == 0 then return nil end
  if not flammable then build() end

  local fluids = prototypes.fluid
  local energy, amount, toxic_amount = 0, 0, 0
  local best, best_energy, best_index, best_amount = nil, 0, 1, 0
  for k = 1, n do
    local pot = boxes[k]
    if pot then
      local name, a = pot.name, pot.amount
      if flammable[name] then
        local e = fluids[name].fuel_value * a / 1000000.0
        if e > 0 then
          energy = energy + e
          amount = amount + a
          if e > best_energy then best, best_energy, best_index, best_amount = name, e, k, a end
        end
      end
      if toxic[name] then toxic_amount = toxic_amount + a end
    end
  end
  if not best and toxic_amount == 0 then return nil end

  local fraction = 0
  if best then
    local capacity = boxes.get_capacity(best_index)
    if capacity > 0 then fraction = math.min(1, best_amount / capacity) end
  end
  return {
    energy = energy,
    amount = amount,
    toxic = toxic_amount,
    fluid = best,
    fraction = fraction,
    damage_type = best and gas[best] and "explosion" or "fire",
  }
end

---Capacity of the first fluid box (0 without fluid boxes).
function M.capacity(entity)
  local boxes = entity.fluidbox
  if #boxes == 0 then return 0 end
  return boxes.get_capacity(1)
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
          if flammable[f.name] and prototypes.fluid[f.name] and prototypes.fluid[f.name].fuel_value > 0 then flam = true end
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
