data:extend(
{
	{
    type = "item-subgroup",
    name = "techrow1",
    group = "intermediate-products",
    order = "z-z",
    },
	{
    type = "item-subgroup",
    name = "techrow2",
    group = "intermediate-products",
    order = "zz-z",
    },
    {
    type = "item-subgroup",
    name = "techrow3",
    group = "intermediate-products",
    order = "zzz-z",
    },
	{
    type = "item",
    name = "sci-component-1",
    icon = "__KaoExtended__/graphics/sci-component-1.png",
    icon_size = 32,

	subgroup = "techrow1",
    order = "a[tech]",
    stack_size = 100
    },
	{
    type = "item",
    name = "sci-component-2",
    icon = "__KaoExtended__/graphics/sci-component-2.png",
    icon_size = 32,
	subgroup = "techrow1",
    order = "b[tech]",
    stack_size = 100
    },
    	{
    type = "item",
    name = "condensator",
    icon = "__KaoExtended__/graphics/condensator.png",
    icon_size = 32,
	subgroup = "bob-electronic-components",
    order = "b[tech]",
    stack_size = 400
    },
    {
    type = "item",
    name = "condensator2",
    icon = "__KaoExtended__/graphics/condensator2.png",
    icon_size = 32,
	subgroup = "bob-electronic-components",
    order = "c[tech]",
    stack_size = 300
    },
    {
    type = "item",
    name = "condensator3",
    icon = "__KaoExtended__/graphics/condensator3.png",
    icon_size = 32,
	subgroup = "bob-electronic-components",
    order = "d[tech]",
    stack_size = 200
    },
	{
    type = "item",
    name = "sci-component-3",
    icon = "__KaoExtended__/graphics/sci-component-3.png",
    icon_size = 32,
	subgroup = "techrow1",
    order = "c[tech]",
    stack_size = 100
    },
	{
    type = "item",
    name = "advsci-component-3",
    icon = "__KaoExtended__/graphics/advsci-component-3.png",
    icon_size = 32,
	subgroup = "techrow2",
    order = "c1[tech]",
    stack_size = 100
    },
	{
    type = "item",
    name = "sci-component-4",
    icon = "__KaoExtended__/graphics/sci-component-4.png",
    icon_size = 32,
	subgroup = "techrow1",
    order = "d[tech]",
    stack_size = 100
    },
	{
    type = "item",
    name = "advsci-component-4",
    icon = "__KaoExtended__/graphics/advsci-component-4.png",
    icon_size = 32,
	subgroup = "techrow2",
    order = "e[tech]",
    stack_size = 100
    },
	{
    type = "item",
    name = "sci-component-5",
    icon = "__KaoExtended__/graphics/sci-component-5.png",
    icon_size = 32,
	subgroup = "techrow1",
    order = "g[tech]",
    stack_size = 100
    },
    {
    type = "item",
    name = "sci-component-l",
    icon = "__KaoExtended__/graphics/sci-component-L.png",
    icon_size = 32,
	subgroup = "techrow1",
    order = "f[tech]",
    stack_size = 100
    },
    {
    type = "item",
    name = "sci-component-m",
    icon = "__KaoExtended__/graphics/sci-component-M.png",
    icon_size = 32,
	subgroup = "techrow1",
    order = "e1[tech]",
    stack_size = 100
    },
    {
    type = "item",
    name = "sci-component-o",
    icon = "__KaoExtended__/graphics/sci-component-O.png",
    icon_size = 32,
	subgroup = "techrow1",
    order = "h[tech]",
    stack_size = 100
    },
    {
    type = "item",
    name = "simple-io",
    icon = "__KaoExtended__/graphics/simple-io.png",
    icon_size = 32,
	subgroup = "techrow3",
    order = "a[tech]",
    stack_size = 100
    },
    {
    type = "item",
    name = "standart-io",
    icon = "__KaoExtended__/graphics/standart-io.png",
    icon_size = 32,
	subgroup = "techrow3",
    order = "b[tech]",
    stack_size = 100
    },
    {
    type = "item",
    name = "advanced-io",
    icon = "__KaoExtended__/graphics/advanced-io.png",
    icon_size = 32,
	subgroup = "techrow3",
    order = "c[tech]",
    stack_size = 100
    },
    {
    type = "item",
    name = "predictive-io",
    icon = "__KaoExtended__/graphics/predictive-io.png",
    icon_size = 32,
	subgroup = "techrow3",
    order = "d[tech]",
    stack_size = 100
    },
    {
    type = "item",
    name = "intelligent-io",
    icon = "__KaoExtended__/graphics/intelligent-io-32.png",
    icon_size = 32,
	subgroup = "techrow3",
    order = "h[tech]",
    stack_size = 50
    },
	{
    type = "item",
    name = "angels-iron-gear-wheel-stack",
    icon = "__KaoExtended__/graphics/smelting/iron-gear-wheel-stack.png",
	icon_size = 32,
    subgroup = "angels-iron-casting",
    order = "s",
    stack_size = 200
	},
	{
    type = "item",
    name = "angels-steel-gear-wheel-stack",
    icon = "__KaoExtended__/graphics/smelting/steel-gear-wheel-stack.png",
	icon_size = 32,
    subgroup = "angels-steel-casting",
    order = "s",
    stack_size = 200
	},
	
})
if not kaoextended.module then kaoextended.module = {} end


function kaoextended.module.add_productivity_limitation(recipe)
  if data.raw.recipe[recipe] then
    for i, module in pairs(data.raw.module) do
      if module.limitation and module.effect.productivity then
        table.insert(module.limitation, recipe)
      end
    end
  else
    log("Recipe " .. recipe .. " does not exist.")
  end
end

-- Although this version in theory takes longer because it will check each module multiple times, instead of once
-- it does a recipe exist check only once, intead of multiple times, and allows a single error message, instead of once per module with a limitation.
function kaoextended.module.add_productivity_limitations(recipes)
  for j, recipe in pairs(recipes) do
    kaoextended.module.add_productivity_limitation(recipe)
  end
end

--[[
function kaoextended.module.add_productivity_limitations(intermediates)
  for i, module in pairs(data.raw.module) do
    if module.limitation and module.effect.productivity then
      for j, intermediate in pairs(intermediates) do
        table.insert(module.limitation, intermediate)
      end
    end
  end
end
]]--

--[[
local electronics = {
  "condensator",
  "condensator2",
  "condensator3"
}
kaoextended.module.add_productivity_limitations(electronics)
]]--