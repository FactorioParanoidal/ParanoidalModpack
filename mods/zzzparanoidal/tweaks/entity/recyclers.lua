-- Переработчики: энергопотребление x10, у первого уровня 1 слот модуля

local ENERGY_MULTIPLIER = 10

local units = {[""] = 1, k = 1e3, M = 1e6, G = 1e9, T = 1e12}

local function multiply_power(value, mult)
  local num, prefix = string.match(value or "", "^([%d%.]+)%s*([kMGT]?)W$")
  if not num then return value end
  return (tonumber(num) * units[prefix] * mult) .. "W"
end

for _, name in pairs({"recycler-1", "recycler-2", "recycler-3", "recycler"}) do
  local entity = data.raw.furnace[name]
  if entity then
    entity.energy_usage = multiply_power(entity.energy_usage, ENERGY_MULTIPLIER)
  end
end

local recycler1 = data.raw.furnace["recycler-1"]
if recycler1 then
  recycler1.module_slots = 1
  recycler1.allowed_effects = recycler1.allowed_effects or {"consumption", "speed", "pollution", "quality"}
  recycler1.icons_positioning = recycler1.icons_positioning or {
    {inventory_index = defines.inventory.furnace_modules, shift = {0, 0.2}}
  }
end
