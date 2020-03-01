if mods.angelsrefining then
if mods.seablock then
else
-- Washing plant sulfur byproduct

local washing_fluid_box = {
 
production_type = 'output',
  
pipe_covers = pipecoverspictures(),
  
base_level = 1,
  pipe_connections = {{ position = {-3, 0} }}

}

table.insert(data.raw['assembling-machine']['washing-plant'].fluid_boxes, washing_fluid_box)

table.insert(data.raw['assembling-machine']['washing-plant-2'].fluid_boxes, washing_fluid_box)

table.insert(data.raw.recipe['washing-1'].results,
  {type = "fluid", name = "gas-hydrogen-sulfide", amount = 20}
)
--Add productivity to special angels processing
angelsmods.functions.allow_productivity("angelsore8-crushed-processing")
angelsmods.functions.allow_productivity("angelsore8-powder-processing")
angelsmods.functions.allow_productivity("angelsore8-dust-processing")
angelsmods.functions.allow_productivity("angelsore8-crystal-processing")

angelsmods.functions.allow_productivity("angelsore9-crushed-processing")
angelsmods.functions.allow_productivity("angelsore9-powder-processing")
angelsmods.functions.allow_productivity("angelsore9-dust-processing")
angelsmods.functions.allow_productivity("angelsore9-crystal-processing")

for i = 1,6 do
  local recipe = data.raw.recipe["slag-processing-" .. i]
  recipe.icon = "__angelsrefining__/graphics/icons/angels-ore" .. i .. ".png"
  recipe.localised_name = {"recipe-name.slag-processing-1", {"item-name.angels-ore" .. i}, "", ""}
  recipe.order = "a-a [angels-ore-" .. i .. "]"

  recipe.ingredients = nil
  recipe.results = nil
  recipe.energy_required = nil

  recipe.normal = {
    energy_required = 2,
    ingredients = {{ type="fluid", name = 'mineral-sludge', amount = 50 }},
    results = {{type = "item", name = "angels-ore" .. i, amount = 3, probability=0.9}},
    enabled = false
  }

  recipe.expensive = {
    energy_required = 4,
    ingredients = {{ type="fluid", name = 'mineral-sludge', amount = 50 }},
    results = {{type = "item", name = "angels-ore" .. i, amount = 3, probability=0.8}},
    enabled = false
  }
end
bobmods.lib.tech.remove_recipe_unlock('slag-processing-1','slag-processing-1')
bobmods.lib.tech.remove_recipe_unlock('slag-processing-1','slag-processing-2')
bobmods.lib.tech.remove_recipe_unlock('slag-processing-1','slag-processing-3')
bobmods.lib.tech.remove_recipe_unlock('slag-processing-2','slag-processing-4')
bobmods.lib.tech.remove_recipe_unlock('slag-processing-2','slag-processing-5')
bobmods.lib.tech.remove_recipe_unlock('slag-processing-2','slag-processing-6')

bobmods.lib.tech.add_recipe_unlock('slag-processing-1','slag-processing-1')
bobmods.lib.tech.add_recipe_unlock('slag-processing-1','slag-processing-3')
bobmods.lib.tech.add_recipe_unlock('slag-processing-1','slag-processing-5')
bobmods.lib.tech.add_recipe_unlock('slag-processing-1','slag-processing-6')
bobmods.lib.tech.add_recipe_unlock('slag-processing-2','slag-processing-2')
bobmods.lib.tech.add_recipe_unlock('slag-processing-2','slag-processing-4')

data:extend({
{
    type = "recipe",
    name = "sb-wood-bricks-charcoal",
    category = "smelting",
    enabled = false,
    energy_required = 3.5,
    ingredients = {{"wood-bricks", 1}},
    result = "solid-coke",
    result_count = 6,
    subgroup = "petrochem-coal"
},
})

end
end
if mods.angelssmelting then
--Cooling Tower
data.raw.recipe["coolant-used-filtration-1"].ingredients =
{
    {type="fluid", name="liquid-coolant-used", amount=100, maximum_temperature = 200},
    {type="item", name="filter-coal", amount=1},
}
data.raw.recipe["coolant-used-filtration-1"].results =
{	  
    {type="fluid", name="liquid-coolant", amount=97, temperature = 25}, --DrD 99
    {type="item", name="filter-frame", amount=1},
}
data.raw.recipe["coolant-used-filtration-2"].ingredients =
{
    {type="fluid", name="liquid-coolant-used", amount=100, maximum_temperature = 200},
    {type="item", name="filter-ceramic", amount=1},
}
data.raw.recipe["coolant-used-filtration-2"].results =
{
    {type="fluid", name="liquid-coolant", amount=99, temperature = 25}, --DrD 100
    {type="item", name="filter-ceramic-used", amount=1},
}
data.raw.recipe["coolant-cool-200"].hidden = true
data.raw.recipe["coolant-cool-100"].hidden = true

data.raw.technology["angels-coolant-1"].effects =
{
    {
        type = "unlock-recipe",
        recipe = "cooling-tower"
    },
    {
        type = "unlock-recipe",
        recipe = "coolant"
    },
    {
        type = "unlock-recipe",
        recipe = "coolant-used-filtration-1"
    },
    {
        type = "unlock-recipe",
        recipe = "coolant-cool-300"
    },
    {
        type = "unlock-recipe",
        recipe = "coolant-cool-steam"
    }
}
end