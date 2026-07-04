-- Порт ReStack (Optera, 1.1-only) в zzz: увеличенные размеры пачек по категориям.
-- Логика идёт по entity-категориям (покрывает предметы всех модов автоматически),
-- значения — из фактического 1.1 mod-settings. SA-аналог TLib_ReStack требует
-- space-age/quality — несовместим с нашей сборкой, поэтому переносим алгоритм сюда.

-- Значения пачек (из 1.1 mod-settings.dat). 0 = не трогать.
local RS = {
  ores = 200, plates = 400, ["rocket-parts"] = 10, ["science-pack"] = 200,
  ["fuel-category-nuclear"] = 5, uranium = 100, wood = 200, ["solid-fuel"] = 100,
  ["nuclear-fuel"] = 10, tiles = 500,
  belt = 100, pipe = 100, container = 0, inserter = 50, ["electric-pole"] = 50,
  roboport = 20, robot = 0, rail = 200, ["rail-signal"] = 0, ["train-stop"] = 0,
  ["train-carriage"] = 0, car = 0, combinator = 50, wire = 400,
  reactor = 10, ["crafting-machine"] = 20, furnace = 20, beacon = 20,
  ["mining-drill"] = 20, boiler = 20, generator = 20, modules = 0,
  wall = 0, turret = 0,
  ["ammo-bullet"] = 200, ["ammo-shotgun"] = 200, ["ammo-flamethrower"] = 100,
  ["ammo-rocket"] = 200, ["ammo-cannon"] = 200, ["ammo-artillery"] = 10,
  ["barrel-stack"] = 5, ["barrel-fill"] = 100,
}

local ReStack_Items = {}
local Launch_Products = {}
local Tile_Whitelist = { ["stone-brick"] = true }

-- lib (Optera), адаптировано под 2.0: recipe.normal/expensive убраны.
local function add_from_item_array(items, stack_size, category, placed_entity)
  for _, item in pairs(items) do
    if item.name and (item.type == nil or item.type == "item") then
      if placed_entity == nil or placed_entity == item.place_result then
        ReStack_Items[item.name] = { stack_size = stack_size, type = category }
      end
    elseif item[1] and placed_entity == nil then
      ReStack_Items[item[1]] = { stack_size = stack_size, type = category }
    end
  end
end

local function SelectItemByEntity(ent_type, stack_size, category, reverse_check)
  category = category or ent_type
  if reverse_check == nil then reverse_check = true end
  for name, entity in pairs(data.raw[ent_type] or {}) do
    if entity.minable then
      if entity.minable.result then
        ReStack_Items[entity.minable.result] = { stack_size = stack_size, type = category }
      elseif entity.minable.results then
        add_from_item_array(entity.minable.results, stack_size, category, reverse_check and name or nil)
      end
    end
  end
end

local function SelectItemsByRecipeResult(recipe, stack_size, category)
  if recipe.result then
    ReStack_Items[recipe.result] = { stack_size = stack_size, type = category }
  end
  if recipe.results then
    add_from_item_array(recipe.results, stack_size, category)
  end
end

local function SelectItemsByRecipeInput(recipe, stack_size, category)
  if recipe.ingredients then
    add_from_item_array(recipe.ingredients, stack_size, category)
  end
end

-- INTERMEDIATE
SelectItemByEntity("resource", RS.ores, "ore", false)
for _, recipe in pairs(data.raw.recipe) do
  if recipe.category == "smelting" then
    SelectItemsByRecipeResult(recipe, RS.plates, "smelting")
  end
  if recipe.category == "rocket-building" then
    SelectItemsByRecipeInput(recipe, RS["rocket-parts"], "rocket-part")
  end
end
for _, tech in pairs(data.raw.technology) do
  if tech.unit and tech.unit.ingredients then
    add_from_item_array(tech.unit.ingredients, RS["science-pack"], "science-pack")
  end
end
for _, item in pairs(data.raw.item) do
  if item.fuel_category == "nuclear" then
    ReStack_Items[item.name] = { stack_size = RS["fuel-category-nuclear"], type = "fuel-category-nuclear" }
    if item.burnt_result then
      ReStack_Items[item.burnt_result] = { stack_size = RS["fuel-category-nuclear"], type = "fuel-category-nuclear" }
    end
  end
end
ReStack_Items["uranium-235"] = { stack_size = RS.uranium, type = "uranium" }
ReStack_Items["uranium-238"] = { stack_size = RS.uranium, type = "uranium" }
ReStack_Items["wood"] = { stack_size = RS.wood, type = "wood" }
ReStack_Items["solid-fuel"] = { stack_size = RS["solid-fuel"], type = "solid-fuel" }
ReStack_Items["nuclear-fuel"] = { stack_size = RS["nuclear-fuel"], type = "nuclear-fuel" }
-- tiles — последними, перезатирают руду/дерево, если те используются как плитка
for _, item in pairs(data.raw.item) do
  if item.place_as_tile and (Tile_Whitelist[item.name] or not ReStack_Items[item.name]) then
    ReStack_Items[item.name] = { stack_size = RS.tiles, type = "tile" }
  end
end

-- LOGISTIC
for _, t in ipairs({ "transport-belt", "underground-belt", "splitter", "loader", "loader-1x1" }) do
  SelectItemByEntity(t, RS.belt, "belt")
end
SelectItemByEntity("pipe", RS.pipe, "pipe")
SelectItemByEntity("pipe-to-ground", RS.pipe, "pipe")
SelectItemByEntity("container", RS.container, "container")
SelectItemByEntity("logistic-container", RS.container, "container")
SelectItemByEntity("inserter", RS.inserter, "inserter")
SelectItemByEntity("electric-pole", RS["electric-pole"], "electric-pole")
SelectItemByEntity("roboport", RS.roboport, "roboport")
SelectItemByEntity("logistic-robot", RS.robot, "robot")
SelectItemByEntity("construction-robot", RS.robot, "robot")
for _, item in pairs(data.raw["rail-planner"] or {}) do
  ReStack_Items[item.name] = { stack_size = RS.rail, type = "rail" }
end
SelectItemByEntity("rail-signal", RS["rail-signal"], "rail-signal")
SelectItemByEntity("rail-chain-signal", RS["rail-signal"], "rail-signal")
SelectItemByEntity("train-stop", RS["train-stop"], "train-stop")
for _, t in ipairs({ "locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon" }) do
  SelectItemByEntity(t, RS["train-carriage"], "train-carriage")
end
SelectItemByEntity("car", RS.car, "car")
for _, t in ipairs({ "arithmetic-combinator", "decider-combinator", "constant-combinator" }) do
  SelectItemByEntity(t, RS.combinator, "combinator")
end
ReStack_Items["red-wire"] = { stack_size = RS.wire, type = "wire" }
ReStack_Items["green-wire"] = { stack_size = RS.wire, type = "wire" }
ReStack_Items["copper-cable"] = { stack_size = RS.wire, type = "wire" }

-- PRODUCTION
SelectItemByEntity("reactor", RS.reactor, "reactor")
SelectItemByEntity("assembling-machine", RS["crafting-machine"], "crafting-machine")
SelectItemByEntity("furnace", RS.furnace, "furnace")
SelectItemByEntity("beacon", RS.beacon, "beacon")
SelectItemByEntity("mining-drill", RS["mining-drill"], "mining-drill")
SelectItemByEntity("boiler", RS.boiler, "boiler")
SelectItemByEntity("generator", RS.generator, "generator")
for _, item in pairs(data.raw["module"] or {}) do
  ReStack_Items[item.name] = { stack_size = RS.modules, type = "module" }
end

-- MILITARY
SelectItemByEntity("wall", RS.wall, "wall")
SelectItemByEntity("gate", RS.wall, "wall")
for _, t in ipairs({ "turret", "ammo-turret", "electric-turret", "artillery-turret" }) do
  SelectItemByEntity(t, RS.turret, "turret")
end

-- AMMO (по ammo_type.category; в 2.0 ammo_type может быть одиночным или массивом)
local function set_by_ammo_category(cat, ss)
  for _, ammo in pairs(data.raw.ammo or {}) do
    local at, match = ammo.ammo_type, false
    if at then
      if at.category == cat then
        match = true
      elseif at[1] then
        for _, a in pairs(at) do if type(a) == "table" and a.category == cat then match = true end end
      end
    end
    if match and ammo.name then ReStack_Items[ammo.name] = { stack_size = ss, type = "ammo" } end
  end
end
set_by_ammo_category("bullet", RS["ammo-bullet"])
set_by_ammo_category("shotgun-shell", RS["ammo-shotgun"])
set_by_ammo_category("flamethrower", RS["ammo-flamethrower"])
set_by_ammo_category("rocket", RS["ammo-rocket"])
set_by_ammo_category("cannon-shell", RS["ammo-cannon"])
set_by_ammo_category("artillery-shell", RS["ammo-artillery"])

-- BARREL (stack + ёмкость + fuel_value). Меняет fill/empty рецепты.
local barrel_stack = RS["barrel-stack"]
local barrel_cap = RS["barrel-fill"]
local empty_barrels = {
  ["barrel"] = true,              -- base 2.0 (жидкости)
  ["bob-gas-canister"] = true,    -- Bob's (газы)
  ["bob-empty-canister"] = true,  -- Bob's (газы)
}
local energy_per_recipe, mult = 2, 10
if barrel_cap <= 500 then mult = math.ceil(500 / barrel_cap) else energy_per_recipe = math.floor(barrel_cap / 250) end

if barrel_stack > 0 then
  for k in pairs(empty_barrels) do
    if data.raw.item[k] then data.raw.item[k].stack_size = barrel_stack end
  end
end

local ENERGY_UNITS = { J = 1, kJ = 1e3, MJ = 1e6, GJ = 1e9, TJ = 1e12, PJ = 1e15 }
local function energy_to_j(s)
  local n, u = tostring(s):match("([%d%.]+)%s*([kMGTP]?J)")
  return n and tonumber(n) * (ENERGY_UNITS[u] or 1) or nil
end

-- Recipe-driven: в 2.0 имя бочки != имени жидкости (angels-gas-ammonia -> ammonia-barrel),
-- поэтому наполнение/опустошение определяем по структуре рецепта, а не по имени.
local function is_filled_barrel(name)
  return name and tostring(name):match("%-barrel$") and not empty_barrels[name]
end

for _, r in pairs(data.raw.recipe) do
  if barrel_cap > 0 and r.ingredients and r.results then
    local in_c, in_f, in_b, out_c, out_f, out_b
    for _, ing in pairs(r.ingredients) do
      if empty_barrels[ing.name] then in_c = ing
      elseif ing.type == "fluid" then in_f = ing
      elseif is_filled_barrel(ing.name) then in_b = ing end
    end
    for _, res in pairs(r.results) do
      if empty_barrels[res.name] then out_c = res
      elseif res.type == "fluid" then out_f = res
      elseif is_filled_barrel(res.name) then out_b = res end
    end

    if in_c and in_f and out_b then          -- НАПОЛНЕНИЕ: контейнер + жидкость -> бочка
      r.energy_required = energy_per_recipe
      in_c.amount = (in_c.amount or 1) * mult
      in_f.amount = barrel_cap * mult
      out_b.amount = (out_b.amount or 1) * mult
      local bi = data.raw.item[out_b.name]
      if bi then
        if barrel_stack > 0 then bi.stack_size = barrel_stack end
        local fl = data.raw.fluid[in_f.name]
        if fl and fl.fuel_value then
          local ev = energy_to_j(fl.fuel_value)
          if ev and ev > 0 then
            bi.fuel_category = bi.fuel_category or "chemical"
            bi.fuel_value = (ev * in_f.amount / out_b.amount) .. "J"
          end
        end
      end
    elseif in_b and out_c and out_f then     -- ОПУСТОШЕНИЕ: бочка -> контейнер + жидкость
      r.energy_required = energy_per_recipe
      in_b.amount = (in_b.amount or 1) * mult
      out_c.amount = (out_c.amount or 1) * mult
      out_f.amount = barrel_cap * mult
      local bi = data.raw.item[in_b.name]
      if bi and barrel_stack > 0 then bi.stack_size = barrel_stack end
    end
  end
end

-- rocket launch products (для корректировки silo output)
for _, group in pairs(data.raw) do
  for _, item in pairs(group) do
    if type(item) == "table" then
      if item.rocket_launch_product then
        local p = item.rocket_launch_product
        Launch_Products[p.name or p[1]] = p.amount or p[2] or 1
      end
      if item.rocket_launch_products then
        for _, p in pairs(item.rocket_launch_products) do
          Launch_Products[p.name or p[1]] = p.amount or p[2] or 1
        end
      end
    end
  end
end

-- ПРИМЕНЕНИЕ: предмет может лежать в любой группе data.raw (item/ammo/module/capsule/tool/…)
for _, group in pairs(data.raw) do
  for item_name, sd in pairs(ReStack_Items) do
    local item = group[item_name]
    if item and item.stack_size and sd.stack_size > 0 then
      local nostack = false
      if item.flags then
        for _, f in pairs(item.flags) do if f == "not-stackable" then nostack = true break end end
      end
      if not nostack then
        item.stack_size = sd.stack_size
        local lp = Launch_Products[item_name]
        if lp and lp > item.stack_size then
          local stacks = math.ceil(lp / item.stack_size)
          local silo = data.raw["rocket-silo"] and data.raw["rocket-silo"]["rocket-silo"]
          if silo and silo.rocket_result_inventory_size and stacks > silo.rocket_result_inventory_size then
            silo.rocket_result_inventory_size = stacks
          end
        end
      end
    end
  end
end
