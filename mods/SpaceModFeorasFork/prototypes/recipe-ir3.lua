local productionCost = settings.startup["SpaceX-production"].value or 1
local classicMode = settings.startup["SpaceX-classic-mode"].value or false
local replaceNuclear = settings.startup["SpaceX-no-nuclear"].value or false

local function replace_ingredient(ingredients, old, new, new_amount)
	local amount = 0
	if ingredients then
		for i, ingredient in pairs(ingredients) do
			if ingredient then
				if ingredient[1] == old or ingredient.name == old then
					amount = ingredient[2] or ingredient.amount
					table.remove(ingredients, i)
					break
				end
			end
		end
		if new_amount then
			table.insert(ingredients, { type = "item", name = new, amount = new_amount })
		elseif amount ~= 0 then
			table.insert(ingredients, { type = "item", name = new, amount = amount })
		end
	end
end

local function replace(recipe_name, old, new, new_amount)
	local recipe = data.raw["recipe"][recipe_name]
	if recipe then
		for _, diff in pairs({ recipe }) do
			if diff then
				if diff.ingredients then
					replace_ingredient(diff.ingredients, old, new, new_amount)
				end
			end
		end
	end
end

if not classicMode then
	local recipe = data.raw["recipe"]["space-oxygen-barrel"]
	if recipe then
		recipe.category = "crafting-with-fluid"
		for _, diff in pairs({ recipe }) do
			if diff then
				if diff.ingredients then
					table.insert(
						diff.ingredients,
						{ type = "fluid", name = "oxygen-gas", amount = 200 * productionCost }
					)
				end
			end
		end
	end

	if not replaceNuclear then
		local spaceship_fuel = table.deepcopy(data.raw["item"]["nuclear-fuel"])
		spaceship_fuel.name = "spaceship-fuel"
		spaceship_fuel.subgroup = "spacex-stage-4"
		spaceship_fuel.order = "l[spaceship-fuel]"
		spaceship_fuel.stack_size = 10
		spaceship_fuel.fuel_value = "0J"
		spaceship_fuel.fuel_acceleration_multiplier = 1.0
		spaceship_fuel.fuel_top_speed_multiplier = 1.0
		spaceship_fuel.fuel_emissions_multiplier = 1.0
		spaceship_fuel.fuel_glow_color = nil
		spaceship_fuel.flags = {}

		data:extend({
			spaceship_fuel,
			{
				type = "recipe",
				name = "spaceship-fuel",
				enabled = false,
				energy_required = 90,
				ingredients = {
					{ type = "item", name = "rocket-fuel", amount = math.ceil(1 * productionCost) },
					{ type = "item", name = "uranium-235", amount = math.ceil(1 * productionCost) },
				},
				results = {
					{ type = "item", name = "spaceship-fuel", amount = 1 }
				},
				main_product = "spaceship-fuel",
			},
		})

		replace("space-fuel-tank", "nuclear-fuel", "spaceship-fuel")
		replace("exploration-satellite", "nuclear-fuel", "spaceship-fuel")
	end
end
