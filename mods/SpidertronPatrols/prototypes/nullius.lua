if not mods["nullius"] then return end

local spiderling_enabled = settings.startup["sp-enable-spiderling"].value
local dock_enabled = settings.startup["sp-enable-dock"].value

local patrol_remote = data.raw["spidertron-remote"]["sp-spidertron-patrol-remote"]
patrol_remote.localised_name = {"item-name.nullius-sp-spidertron-patrol-remote"}

if not (spiderling_enabled or dock_enabled) then return end

if sp_data_stage == "data" then
  local tech = table.deepcopy(data.raw.technology["nullius-personal-transportation-2"])
  tech.name = "nullius-sp-spidertron-automation"
  tech.icon = "__SpidertronPatrols__/graphics/technology/spiderling.png"
  tech.icon_size = 256

  tech.prerequisites = {"nullius-cybernetics-4"}
  tech.effects = {{
    type = "unlock-recipe",
    recipe = "nullius-mecha-remote"
  }}
  data:extend{tech}

  local remote_recipe = data.raw.recipe["nullius-mecha-remote"]

  remote_recipe.ingredients = {
    {type="item", name="nullius-processor-1", amount=2},
    {type="item", name="nullius-scout-remote", amount=1}
  }
end

local tech = data.raw.technology["nullius-sp-spidertron-automation"]

if spiderling_enabled then
  local item = data.raw["item-with-entity-data"]["sp-spiderling"]
  item.group = "equipment"
  item.subgroup = "vehicle"
  item.order = "nullius-da"

  local recipe = data.raw.recipe["sp-spiderling"]
  recipe.group = "equipment"
  recipe.subgroup = "vehicle"
  recipe.order = "nullius-da"
  recipe.categories = {"medium-crafting"}
  recipe.energy_required = 60
  recipe.ingredients = {
    {type="item", name="nullius-car-2", amount=1},
    {type="item", name="nullius-solar-panel-1", amount=8},
    {type="item", name="nullius-grid-battery-1", amount=4},
    {type="item", name="nullius-quadrupedal-adaptation-1", amount=4},
    {type="item", name="nullius-efficiency-module-2", amount=2},
  }

  local entity = data.raw["spider-vehicle"]["sp-spiderling"]
  entity.localised_name = {"entity-name.nullius-sp-spiderling"}
  entity.order = "nullius-da"
  entity.guns = nil

  local grid = data.raw["equipment-grid"]["sp-spiderling-equipment-grid"]
  grid.height = 6
  grid.equipment_categories = {"cybernetic"}

  if sp_data_stage == "data-updates" then
    --local tech = data.raw.technology["nullius-personal-transportation-4"]
    table.insert(tech.effects, 1, {
      type = "unlock-recipe",
      recipe = "sp-spiderling"
    })
  end
end

if dock_enabled and sp_data_stage ~= "data" then
  local item = data.raw.item["sp-spidertron-dock"]
  item.group = "equipment"
  item.subgroup = "vehicle"
  item.order = "nullius-dh"

  local recipe = data.raw.recipe["sp-spidertron-dock"]
  recipe.group = "equipment"
  recipe.subgroup = "vehicle"
  recipe.order = "nullius-dh"
  recipe.categories = {"medium-crafting"}
  recipe.energy_required = 60
  recipe.ingredients = {
    {type="item", name="nullius-large-chest-2", amount=2},
    {type="item", name="nullius-sensor-2", amount=1}
  }

  for name, entity in pairs(data.raw["container"]) do
    if name:sub(1, 18) == "sp-spidertron-dock" then
      entity.localised_name = {"entity-name.nullius-sp-spidertron-dock"}
      entity.order = "nullius-dh"
    end
  end

  if sp_data_stage == "data-updates" then
    --local tech = data.raw.technology["nullius-personal-transportation-4"]
    table.insert(tech.effects, 2, {
      type = "unlock-recipe",
      recipe = "sp-spidertron-dock"
    })
  end
end
