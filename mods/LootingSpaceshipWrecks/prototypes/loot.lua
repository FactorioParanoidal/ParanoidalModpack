local function set_loot(entity, mining_time, products)
  local results = {}
  for _, product in ipairs(products) do
    if data.raw.item[product.name] or data.raw.tool[product.name] then
      results[#results + 1] = product
    else
      log("LootingSpaceshipWrecks: optional mining loot unavailable: " .. product.name)
    end
  end
  entity.minable = {mining_time = mining_time, results = results}
end

local containers = data.raw.container
local small_wrecks = data.raw["simple-entity-with-owner"]
for index, name in ipairs({"iron-plate", "copper-plate", "pipe", "steel-plate", "iron-plate", "copper-plate"}) do
  set_loot(small_wrecks["crash-site-spaceship-wreck-small-" .. index], 3, {
    {type = "item", name = name, amount_min = 2, amount_max = 30}
  })
end

set_loot(containers["crash-site-spaceship-wreck-big-1"], 5, {
  {type = "item", name = "steel-plate", amount_min = 2, amount_max = 8},
  {type = "item", name = "iron-plate", amount_min = 15, amount_max = 35},
  {type = "item", name = "bob-aluminium-plate", amount_min = 5, amount_max = 25},
  {type = "item", name = "bob-titanium-plate", amount_min = 5, amount_max = 10}
})
set_loot(containers["crash-site-spaceship-wreck-big-2"], 5, {
  {type = "item", name = "electronic-circuit", amount_min = 1, amount_max = 5},
  {type = "item", name = "rocket-fuel", amount_min = 2, amount_max = 10},
  {type = "item", name = "pipe", amount_min = 5, amount_max = 15},
  {type = "item", name = "bob-titanium-plate", amount_min = 5, amount_max = 10}
})
set_loot(containers["crash-site-spaceship-wreck-medium-2"], 4, {
  {type = "item", name = "electronic-circuit", amount_min = 1, amount_max = 2},
  {type = "item", name = "rocket-fuel", amount_min = 1, amount_max = 4},
  {type = "item", name = "pipe", amount_min = 2, amount_max = 5},
  {type = "item", name = "bob-titanium-plate", amount_min = 1, amount_max = 4}
})
set_loot(containers["crash-site-spaceship-wreck-medium-1"], 4, {
  {type = "item", name = "sci-component-1", amount_min = 1, amount_max = 10},
  {type = "item", name = "sci-component-2", amount_min = 1, amount_max = 4},
  {type = "item", name = "copper-cable", amount_min = 25, amount_max = 55},
  {type = "item", name = "CW-air-filter", amount_min = 5, amount_max = 15}
})
set_loot(containers["crash-site-spaceship-wreck-medium-3"], 4, {
  {type = "item", name = "steel-plate", amount_min = 2, amount_max = 6},
  {type = "item", name = "iron-plate", amount_min = 5, amount_max = 25},
  {type = "item", name = "bob-aluminium-plate", amount_min = 1, amount_max = 10},
  {type = "item", name = "bob-titanium-plate", amount_min = 1, amount_max = 5}
})

local ship = containers["crash-site-spaceship"]
ship.inventory_size = 80
set_loot(ship, 5, {
  {type = "item", name = "steel-plate", amount_min = 5, amount_max = 25},
  {type = "item", name = "iron-gear-wheel", amount_min = 5, amount_max = 20},
  {type = "item", name = "electronic-circuit", amount_min = 4, amount_max = 12},
  {type = "item", name = "concrete", amount_min = 25, amount_max = 85},
  {type = "item", name = "pipe", amount_min = 5, amount_max = 45},
  {type = "item", name = "bob-aluminium-plate", amount_min = 5, amount_max = 85},
  {type = "item", name = "bob-titanium-plate", amount_min = 5, amount_max = 85},
  {type = "item", name = "condensator3", amount_min = 5, amount_max = 35},
  {type = "item", name = "bob-processing-electronics", amount_min = 1, amount_max = 5},
  {type = "item", name = "bob-insulated-cable", amount_min = 11, amount_max = 39},
  {type = "item", name = "salvaged-generator", amount = 1}
})

-- Beta 8 zzzparanoidal added the working pump to hull mining loot, not its inventory.
if mods.zzzparanoidal and data.raw.item["offshore-mk0-pump"] then
  ship.minable.results[#ship.minable.results + 1] = {type = "item", name = "offshore-mk0-pump", amount = 1}
end
