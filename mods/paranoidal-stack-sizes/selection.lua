-- Pure category snapshot at the historical ReStack boundary. No prototype writes.
local C = require("__paranoidal-stack-sizes__/config")
local M = {}
local snapshot
function M.capture(raw)
    assert(not snapshot, "Размеры стопок: снимок категорий уже создан")
    local data = {raw = raw}
    local RS = C.categories
local ReStack_Items = {}
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
  if bobmods.lib.recipe.get_category(recipe) == "smelting" then -- Factorio 2.1: categories[1]
    SelectItemsByRecipeResult(recipe, RS.plates, "smelting")
  end
  if bobmods.lib.recipe.get_category(recipe) == "rocket-building" then
    SelectItemsByRecipeInput(recipe, RS["rocket-parts"], "rocket-part")
  end
end
for _, tech in pairs(data.raw.technology) do
  if tech.unit and tech.unit.ingredients then
    add_from_item_array(tech.unit.ingredients, RS["science-pack"], "science-pack")
  end
end
-- Factorio 2.1: ItemPrototype::fuel_category -> fuel_categories (list)
local function has_fuel_category(item, category)
  for _, c in pairs(item.fuel_categories or {}) do
    if c == category then return true end
  end
  return false
end
for _, item in pairs(data.raw.item) do
  if has_fuel_category(item, "nuclear") then
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


    -- Filled barrel detection uses the same recipe shapes as the barrel conversion pass.
    local barrels = {}
    for name in pairs(C.empty_barrels) do barrels[name] = true end
    local function name(entry) return entry.name or entry[1] end
    local function filled(n) return n and n:match("%-barrel$") and not C.empty_barrels[n] end
    for _, recipe in pairs(raw.recipe) do
        if recipe.ingredients and recipe.results then
            local inc, inf, inb, outc, outf, outb
            for _, entry in pairs(recipe.ingredients) do
                local n = name(entry)
                if C.empty_barrels[n] then inc = n
                elseif entry.type == "fluid" then inf = n
                elseif filled(n) then inb = n end
            end
            for _, entry in pairs(recipe.results) do
                local n = name(entry)
                if C.empty_barrels[n] then outc = n
                elseif entry.type == "fluid" then outf = n
                elseif filled(n) then outb = n end
            end
            if inc and inf and outb then barrels[outb] = true
            elseif inb and outc and outf then barrels[inb] = true end
        end
    end
    local products = {}
    for _, group in pairs(raw) do
        for _, item in pairs(group) do
            if type(item) == "table" then
                local p = item.rocket_launch_product
                if p then products[p.name or p[1]] = p.amount or p[2] or 1 end
                for _, p2 in pairs(item.rocket_launch_products or {}) do
                    products[p2.name or p2[1]] = p2.amount or p2[2] or 1
                end
            end
        end
    end
    snapshot = {categories = ReStack_Items, barrels = barrels, launch_products = products}
    return snapshot
end
function M.get()
    return assert(snapshot, "Размеры стопок: zzzparanoidal не зафиксировал границу категорий")
end
return M
