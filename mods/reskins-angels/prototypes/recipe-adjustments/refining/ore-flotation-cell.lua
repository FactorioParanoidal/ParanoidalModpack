-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Setup ore flotation cell recipes
for _, recipe_data in pairs(data.raw.recipe) do
	if (recipe_data.categories or {})[1] == "ore-refining-t2" then -- Factorio 2.1: main category = categories[1]
		local primary, secondary = util.color("0"), util.color("0")

		-- Extract the ingredient fluid color
		for _, ingredient in pairs(recipe_data.ingredients) do
			if ingredient.type == "fluid" then
				local fluid = data.raw.fluid[ingredient.name]
				primary = fluid and fluid.base_color

				goto next
			end
		end

		::next::

		-- Extract the result fluid color
		for _, result in pairs(recipe_data.results) do
			if result.type == "fluid" then
				local fluid = data.raw.fluid[result.name]
				secondary = fluid and fluid.base_color

				goto finish
			end
		end

		::finish::

		-- Assign colors
		recipe_data.crafting_machine_tint = { primary = primary, secondary = secondary }
	end
end
