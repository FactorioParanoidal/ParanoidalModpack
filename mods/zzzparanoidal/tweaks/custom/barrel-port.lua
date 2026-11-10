-- Barrel capacity, recipes and fuel only. Item stack sizes belong to paranoidal-stack-sizes.
local C = require("__paranoidal-stack-sizes__/config")
local barrel_cap = C.categories["barrel-fill"]
local empty_barrels = C.empty_barrels
local energy_per_recipe, mult = 2, 10
if barrel_cap <= 500 then mult = math.ceil(500 / barrel_cap) else energy_per_recipe = math.floor(barrel_cap / 250) end


local ENERGY_UNITS = { J = 1, kJ = 1e3, MJ = 1e6, GJ = 1e9, TJ = 1e12, PJ = 1e15 }
local function energy_to_j(s)
  local n, u = tostring(s):match("([%d%.]+)%s*([kMGTP]?J)")
  return n and tonumber(n) * (ENERGY_UNITS[u] or 1) or nil
end

-- Recipe-driven: в 2.0 имя бочки != имени жидкости (angels-gas-ammonia -> ammonia-barrel),
-- поэтому наполнение/опустошение определяем по структуре рецепта, а не по имени.
-- Нормализация ингредиентов/результатов: long-form ({name=,amount=,type=}) и short-form ({name, count}).
local function rn(x) return x.name or x[1] end
local function ra(x) return x.amount or x[2] or 1 end
local function ra_set(x, v) if x.name then x.amount = v else x[2] = v end end
local function is_filled_barrel(name)
  return name and tostring(name):match("%-barrel$") and not empty_barrels[name]
end

for _, r in pairs(data.raw.recipe) do
  if barrel_cap > 0 and r.ingredients and r.results then
    local in_c, in_f, in_b, out_c, out_f, out_b
    for _, ing in pairs(r.ingredients) do
      local nm = rn(ing)
      if empty_barrels[nm] then in_c = ing
      elseif ing.type == "fluid" then in_f = ing
      elseif is_filled_barrel(nm) then in_b = ing end
    end
    for _, res in pairs(r.results) do
      local nm = rn(res)
      if empty_barrels[nm] then out_c = res
      elseif res.type == "fluid" then out_f = res
      elseif is_filled_barrel(nm) then out_b = res end
    end

    if in_c and in_f and out_b then          -- НАПОЛНЕНИЕ: контейнер + жидкость -> бочка
      r.energy_required = energy_per_recipe
      ra_set(in_c, ra(in_c) * mult)
      ra_set(in_f, barrel_cap * mult)
      ra_set(out_b, ra(out_b) * mult)
      local bi = data.raw.item[rn(out_b)]
      if bi then
        local fl = data.raw.fluid[rn(in_f)]
        if fl and fl.fuel_value then
          local ev = energy_to_j(fl.fuel_value)
          if ev and ev > 0 then
            bi.fuel_categories = bi.fuel_categories or {"chemical"} -- Factorio 2.1
            bi.fuel_value = (ev * ra(in_f) / ra(out_b)) .. "J"
          end
        end
      end
    elseif in_b and out_c and out_f then     -- ОПУСТОШЕНИЕ: бочка -> контейнер + жидкость
      r.energy_required = energy_per_recipe
      ra_set(in_b, ra(in_b) * mult)
      ra_set(out_c, ra(out_c) * mult)
      ra_set(out_f, barrel_cap * mult)
    end
  end
end
