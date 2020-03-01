data.raw.recipe["atomic-bomb"].icons =
{
	{
		icon = "__base__/graphics/icons/atomic-bomb.png",
	},
	{
		icon = "__base__/graphics/icons/uranium-235.png",
		--tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
		scale = 0.4,
		shift = {-10, 10},
	},
	
}
data.raw.recipe["atomic-bomb"].icon_size = 32
data.raw["assembling-machine"]["centrifuge"].ingredient_count = 3


data.raw.recipe["nuclear-fuel-reprocessing"].results =
{
	{type="item", name = "plutonium-239", amount = 2},
	{type="item", name = "uranium-238", amount = 3}
}

data.raw.recipe["nuclear-fuel-reprocessing"].icon = "__Clowns-Nuclear__/graphics/icons/nuclear-fuel-reprocessing.png"


--REBUILD NUCLEAR POWER TECHNOLOGY

data.raw.technology["nuclear-power"].effects =
{
	{
		type = "unlock-recipe",
		recipe = "nuclear-reactor"
	},
	{
		type = "unlock-recipe",
		recipe = "centrifuge"
	},
	{
		type = "unlock-recipe",
		recipe = "clowns-centrifuging-20%-ore"
	},
	{
		type = "unlock-recipe",
		recipe = "clowns-centrifuging-35%"
	},
	{
		type = "unlock-recipe",
		recipe = "uranium-fuel-cell"
	},
	{
		type = "unlock-recipe",
		recipe = "heat-exchanger"
	},
	{
		type = "unlock-recipe",
		recipe = "heat-pipe"
	},
	{
		type = "unlock-recipe",
		recipe = "steam-turbine"
	}
}

--CHANGE FEATURES OF URANIUM-238 AND URANIUM-235

data.raw.item["uranium-238"].subgroup = "clowns-uranium-centrifuging"
data.raw.item["uranium-235"].subgroup = "clowns-uranium-centrifuging"
data.raw.item["uranium-238"].localised_name = {"override-item-name.uranium-238"}
data.raw.item["uranium-235"].localised_name = {"override-item-name.uranium-235"}
data.raw.item["uranium-238"].order = "a"
data.raw.item["uranium-235"].order = "i"
data.raw.item["uranium-238"].icon = nil
data.raw.item["uranium-235"].icon = nil
data.raw.item["uranium-238"].icons =
{
	{
		icon = "__base__/graphics/icons/uranium-238.png",
	},
	{
		icon = "__Clowns-Nuclear__/graphics/icons/0%.png",
		scale = 0.8,
		shift = {-5, -12},
	},
}
data.raw.item["uranium-235"].icons =
{
	{
		icon = "__base__/graphics/icons/uranium-235.png",
	},
	{
		icon = "__Clowns-Nuclear__/graphics/icons/80%.png",
		scale = 0.8,
		shift = {-5, -12},
	},
}

data.raw.recipe["uranium-fuel-cell"].ingredients =
{
	{type="item", name="iron-plate", amount=10},
	{type="item", name="35%-uranium", amount=20}
}

--ADD ARTILLERY SHELL RECIPES TO APPROPRIATE TECHS

if settings.startup["artillery-shells"].value == true then
	table.insert(data.raw["technology"]["atomic-bomb"].effects, {type = "unlock-recipe", recipe = "artillery-shell-nuclear"})
	table.insert(data.raw["technology"]["thermonuclear-bomb"].effects, {type = "unlock-recipe", recipe = "artillery-shell-thermonuclear"})
end
table.insert(data.raw["technology"]["atomic-bomb"].effects, {type = "unlock-recipe", recipe = "plutonium-atomic-bomb"})

data.raw.item["used-up-uranium-fuel-cell"].subgroup = "clowns-nuclear-cells"
data.raw.item["used-up-uranium-fuel-cell"].order = "b-a"

data.raw.item["uranium-fuel-cell"].subgroup = "clowns-nuclear-cells"
data.raw.item["uranium-fuel-cell"].order = "a-a"

data.raw.recipe["nuclear-fuel-reprocessing"].subgroup = "clowns-nuclear-cells"
data.raw.recipe["nuclear-fuel-reprocessing"].order = "c-a-a"

data.raw.recipe["nuclear-fuel"].ingredients =
{
   {"rocket-fuel", 1},
   {"55%-uranium", 1},
}

data.raw.item["nuclear-fuel"].order = "a-a"
data.raw.item["nuclear-fuel"].subgroup = "clowns-nuclear-fuels"