-- slag processing
local order = 65
local function oreToSlag(ore, amount)
	if amount == nil then amount = 1 end
	data:extend({
		{ type = "recipe",
		name = ore.."-to-slag",
		icon = "__BobExtended__/graphics/slag-" .. ore .. ".png",
		icon_size = 32,
		category = "mixing-furnace",
		enabled = false,
		subgroup = "slag-processing",
		order = "z-".. string.char(order),
		ingredients ={{ore, amount}},
		result = "slag",
		}
	})
	order = order + 1
end

local function addRecipes()
  oreToSlag("stone", 5)
  oreToSlag("coal", 5)
  oreToSlag("iron-ore")
  oreToSlag("copper-ore")
  
  oreToSlag("lead-ore")
  oreToSlag("tin-ore")
  oreToSlag("zinc-ore")
  oreToSlag("quartz")
  oreToSlag("nickel-ore")
  
  oreToSlag("silver-ore")
  oreToSlag("gold-ore")
  oreToSlag("cobalt-ore")
  oreToSlag("bauxite-ore")
  
  oreToSlag("rutile-ore")
  oreToSlag("tungsten-ore")
  
  
  --stone-crushed-dissolution
  bobmods.lib.recipe.remove_ingredient("stone-crushed-dissolution", "stone-crushed")
  table.insert( data.raw["recipe"]["stone-crushed-dissolution"].ingredients, {"stone-crushed", 14})
 end
local function addTechnology()
  KaoExtended.NewTechnology("to-slag-1", {"ore-crushing"}, "a-a", 33)
  KaoExtended.getTech("to-slag-1").icon = "__KaoExtended__/graphics/technology/reverse-slag.png"
  KaoExtended.buildUnit("to-slag-1", 60, 15, {1, 1})
  KaoExtended.TechUnlockRecipe("to-slag-1", {"stone-to-slag","coal-to-slag","iron-ore-to-slag", "copper-ore-to-slag"})
  KaoExtended.changeUpgrade("to-slag-1")
  
  KaoExtended.NewTechnology("to-slag-2", {"to-slag-1"}, "a-a", 33)
  KaoExtended.getTech("to-slag-2").icon = "__KaoExtended__/graphics/technology/reverse-slag.png"
  KaoExtended.buildUnit("to-slag-2", 60, 20, {1, 1, 2, 1})
  KaoExtended.TechUnlockRecipe("to-slag-2", {"lead-ore-to-slag","tin-ore-to-slag","zinc-ore-to-slag", "nickel-ore-to-slag", "quartz-to-slag"})
  KaoExtended.changeUpgrade("to-slag-2")
  
  
  KaoExtended.NewTechnology("to-slag-3", {"to-slag-2"}, "a-a", 33)
  KaoExtended.getTech("to-slag-3").icon = "__KaoExtended__/graphics/technology/reverse-slag.png"
  KaoExtended.buildUnit("to-slag-3", 120, 30, {1, 1, 2, 1, 3, 1})
  KaoExtended.TechUnlockRecipe("to-slag-3", {"silver-ore-to-slag","gold-ore-to-slag","cobalt-ore-to-slag", "bauxite-ore-to-slag"})
  KaoExtended.changeUpgrade("to-slag-3")
  
  KaoExtended.NewTechnology("to-slag-4", {"to-slag-3"}, "a-a", 33)
  KaoExtended.getTech("to-slag-4").icon = "__KaoExtended__/graphics/technology/reverse-slag.png"
  KaoExtended.buildUnit("to-slag-4", 120, 45, {1, 2, 2, 2, 3, 2})
  KaoExtended.TechUnlockRecipe("to-slag-4", {"silver-ore-to-slag","gold-ore-to-slag"})
  KaoExtended.changeUpgrade("to-slag-4")
  
  --KaoExtended.TechUnlockRecipe("steel-procesing", {"basic-structure-components","intermediate-structure-components","advanced-structure-components", "anotherworld-structure-components"})
end

-- oparation
addRecipes()
addTechnology()
-- oparation

local function prism()
  data:extend({
    { type = "item-subgroup",
      name = "prism-slag",
      group = "resource-refining",
      order = "m-o2"
    },
    { type = "item",
    name = "KaoExtended-prism",
    icon = "__KaoExtended__/graphics/prism.png",
	icon_size = 32,
    subgroup = "prism-slag",
    order = "a-a",
    stack_size = 1
    },
    { type = "recipe",
      name = "KaoExtended-prism",
      category = "crafting-machine",
      enabled = false,
      order = "a",
      energy_required = 300,
      ingredients ={
        {"ruby-5", 315},
        {"sapphire-5", 88 * 3},
        {"emerald-5", 71 * 3},
        {"amethyst-5", 54 * 3},
        {"topaz-5", 37 * 3},
        {"diamond-5", 20 * 3}
      },
      result = "KaoExtended-prism",
      }
  })
end
order = 65
local function addPrismRecipe(name, Iresults, Iicon)
  data:extend({
    { type = "recipe",
      name = "prism-slag-" .. name,
      icon = "__KaoExtended__/graphics/prism.png", --Iicon,
	  icon_size = 32,
      enabled = false,
      category = "crystallizing",
      subgroup = "prism-slag",
      energy_required = 8,
      order = "a-".. string.char(order),
      ingredients = {
        {"bobExtended-prism", 1},
        {type="fluid", name="mineral-sludge", amount=5},
      },
      results = Iresults
    }
  })
  order = order + 1
end
local function addPrismrecipes()
  addPrismRecipe("iron-copper", {
    {type="item", name="iron-ore", amount=2, probability=0.9},
    {type="item", name="copper-ore", amount=2, probability=0.9},
	{type="item", name="bobExtended-prism", amount=1},
  }, data.raw["recipe"]["slag-processing-1"].icon) --data.raw["recipe"]["slag-processing-bob-1"].icon)
  
  addPrismRecipe("tin-lead", {
    {type="item", name="tin-ore", amount=2, probability=0.9},
    {type="item", name="lead-ore", amount=2, probability=0.9},
	{type="item", name="bobExtended-prism", amount=1},
  }, data.raw["recipe"]["slag-processing-2"].icon) --data.raw["recipe"]["slag-processing-bob-2"].icon)
  
  addPrismRecipe("quartz-nickel", {
    {type="item", name="quartz", amount=2, probability=0.9},
    {type="item", name="nickel-ore", amount=2, probability=0.9},
	{type="item", name="bobExtended-prism", amount=1},
  }, data.raw["recipe"]["slag-processing-3"].icon) --data.raw["recipe"]["slag-processing-bob-3"].icon)
  
  addPrismRecipe("aluminium-cobalt-zinc", {
    {type="item", name="bauxite-ore", amount=2, probability=0.9},
    {type="item", name="cobalt-ore", amount=2, probability=0.45},
    {type="item", name="zinc-ore", amount=2, probability=0.45},
	{type="item", name="bobExtended-prism", amount=1},
  }, data.raw["recipe"]["slag-processing-4"].icon) --data.raw["recipe"]["slag-processing-bob-4"].icon)
  
  addPrismRecipe("titanium-silver", {
    {type="item", name="rutile-ore", amount=2, probability=0.9},
    {type="item", name="silver-ore", amount=2, probability=0.9},
	{type="item", name="bobExtended-prism", amount=1},
  }, data.raw["recipe"]["slag-processing-5"].icon)
  
  addPrismRecipe("tungsten-gold", {
    {type="item", name="tungsten-ore", amount=2, probability=0.9},
    {type="item", name="gold-ore", amount=2, probability=0.9},
	{type="item", name="bobExtended-prism", amount=1},
  }, data.raw["recipe"]["slag-processing-6"].icon)
  
KaoExtended.getRecipe("slag-processing-1").results = {
      {type="item", name="copper-ore", amount=1, probability=0.6},
      {type="item", name="iron-ore", amount=1, probability=0.6},
    }
  KaoExtended.getRecipe("slag-processing-2").results = {
      {type="item", name="lead-ore", amount=1, probability=0.6},
      {type="item", name="tin-ore", amount=1, probability=0.6},
    }
  KaoExtended.getRecipe("slag-processing-3").results = {
      {type="item", name="nickel-ore", amount=1, probability=0.6},
      {type="item", name="quartz", amount=1, probability=0.6},
    }
  KaoExtended.getRecipe("slag-processing-4").results=
    {
      {type="item", name="bauxite-ore", amount=1, probability=0.6},
      {type="item", name="cobalt-ore", amount=1, probability=0.3},
      {type="item", name="zinc-ore", amount=1, probability=0.3},
    }
  KaoExtended.getRecipe("slag-processing-5").results={
      {type="item", name="silver-ore", amount=1, probability=0.6},
      {type="item", name="rutile-ore", amount=1, probability=0.6},
    }
  KaoExtended.getRecipe("slag-processing-6").results={
      {type="item", name="gold-ore", amount=1, probability=0.6},
      {type="item", name="tungsten-ore", amount=1, probability=0.6},
    }
 
end
local function addPrismTechnology()
  KaoExtended.NewTechnology("prism-slag-processing", {"slag-processing-2","polishing" }, "d-b")
  KaoExtended.getTech("prism-slag-processing").icon = "__KaoExtended__/graphics/technology/prism.png"
  KaoExtended.buildUnit("prism-slag-processing", 300, 60, {1, 5, 2, 4, 3, 2, 4, 1})
  KaoExtended.TechUnlockRecipe("prism-slag-processing", 
  { "bobExtended-prism",
    "prism-slag-iron-copper",
    "prism-slag-tin-lead",
    "prism-slag-quartz-nickel",
    "prism-slag-aluminium-cobalt-zinc",
    "prism-slag-titanium-silver",
    "prism-slag-tungsten-gold"
  })
  KaoExtended.getTech("prism-slag-processing").icon_size = 128
end

-- oparation
prism()
addPrismrecipes()
addPrismTechnology()
-- oparation

data.raw["item-subgroup"]["ore-sorter"].order = "a-a"
data.raw["item-subgroup"]["ore-crusher"].order = "a-b"
data.raw["item-subgroup"]["ore-floatation"].order = "a-c"
data.raw["item-subgroup"]["ore-leaching"].order = "a-d"
data.raw["item-subgroup"]["ore-refining"].order = "a-e"
data.raw["item-subgroup"]["refining-buildings"].order = "a-f"
if data.raw["item-subgroup"]["angels-warehouses"] then
  data.raw["item-subgroup"]["angels-warehouses"].order = "a-g"
end

local function basicturnback()
  data:extend({
    { type = "recipe",
    name = "slagIron",
    icon = data.raw["item"]["iron-ore"].icon,
	icon_size = 32,
    category = "chemical-furnace",
    enabled = false,
    subgroup = "prism-slag",
    order = "a0",
    ingredients ={{"slag", 8}, {type="fluid", name="water", amount=10}},
    results = {{ "stone-crushed", 3},{type="item", name="iron-ore", amount=1, probability = 0.7}} 
    },
    { type = "recipe",
    name = "slagCopper",
    icon = data.raw["item"]["copper-ore"].icon,
	icon_size = 32,
    category = "chemical-furnace",
    enabled = false,
    subgroup = "prism-slag",
    order = "a1",
    ingredients ={{"slag", 8}, {type="fluid", name="water", amount=10}},
    results = {{ "stone-crushed", 3},{type="item", name="copper-ore", amount=1, probability = 0.7}} 
    }
  })
  KaoExtended.NewTechnology("basic-slag-processing", {"ore-crushing"}, "d-b")
  KaoExtended.getTech("basic-slag-processing").icon = data.raw["item"]["slag"].icon
  KaoExtended.buildUnit("basic-slag-processing", 40, 15, {1, 1})
  KaoExtended.TechUnlockRecipe("basic-slag-processing", { "slagIron","slagCopper" })
  table.insert(KaoExtended.getTech("slag-processing-1").prerequisites, "basic-slag-processing")
end

basicturnback()