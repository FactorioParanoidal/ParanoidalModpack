local util_scripts = require("scripts")


if(mods["cubium"]) then --doing it here should make order appear nicely

    table.insert(data.raw['technology']["science-pack-productivity"].effects,{type = "change-recipe-productivity",change = 0.01,recipe = "automation-science-pack-cubic"})
    table.insert(data.raw['technology']["science-pack-productivity"].effects,{type = "change-recipe-productivity",change = 0.01,recipe = "logistic-science-pack-cubic"})
    table.insert(data.raw['technology']["science-pack-productivity"].effects,{type = "change-recipe-productivity",change = 0.01,recipe = "chemical-science-pack-cubic"})
    table.insert(data.raw['technology']["science-pack-productivity"].effects,{type = "change-recipe-productivity",change = 0.01,recipe = "military-science-pack-cubic"})
    table.insert(data.raw['technology']["science-pack-productivity"].effects,{type = "change-recipe-productivity",change = 0.01,recipe = "production-science-pack-cubic"})
    table.insert(data.raw['technology']["science-pack-productivity"].effects,{type = "change-recipe-productivity",change = 0.01,recipe = "utility-science-pack-cubic"})
    table.insert(data.raw['technology']["science-pack-productivity"].effects,{type = "change-recipe-productivity",change = 0.01,recipe = "metallurgic-science-pack-cubic"})
    table.insert(data.raw['technology']["science-pack-productivity"].effects,{type = "change-recipe-productivity",change = 0.01,recipe = "electromagnetic-science-pack-cubic"})
    table.insert(data.raw['technology']["science-pack-productivity"].effects,{type = "change-recipe-productivity",change = 0.01,recipe = "agricultural-science-pack-cubic"})
    table.insert(data.raw['technology']["science-pack-productivity"].effects,{type = "change-recipe-productivity",change = 0.01,recipe = "cryogenic-science-pack-cubic"})
    table.insert(data.raw['technology']["science-pack-productivity"].effects,{type = "change-recipe-productivity",change = 0.01,recipe = "golden-science-pack-cubic"})
    table.insert(data.raw['technology']["science-pack-productivity"].effects,{type = "change-recipe-productivity",change = 0.01,recipe = "promethium-science-pack-cubic"})

end




--data.raw["inserter"]["stack-inserter"].max_belt_stack_size = 5 --thanks for Pthread-Create for bringing this up.

--local defaultmaxbelt = data.raw["inserter"]["stack-inserter"].max_belt_stack_size or 4
for i,v in pairs(data.raw["inserter"]) do -- this should also modify stack inserters, and any other inserter.
	local maxbelt = v.max_belt_stack_size or 1
	if maxbelt ~= 1 then
		v.max_belt_stack_size = maxbelt + 1
	end
end
-- Don't forget to modify loaders if mods use them with stack belt

if(settings.startup["modify-loaders-for-belt-stack-size-limit"].value) then
	for i,v in pairs(data.raw["loader"]) do
		local maxbelt = v.max_belt_stack_size or 1
		if (maxbelt ~= 1 and maxbelt < 255) then
			v.max_belt_stack_size = maxbelt + 1
		end
	end
	for i,v in pairs(data.raw["loader-1x1"]) do
		local maxbelt = v.max_belt_stack_size or 1
		if (maxbelt ~= 1 and maxbelt < 255) then
			v.max_belt_stack_size = maxbelt + 1
		end
	end
end


-- Paranoidal: Factorio 2.1 recipes list their categories (category was a single one in 2.0); a recycling recipe of a
-- science pack is not productivity research (the recycling rebuild of zzzparanoidal replaces such recipes later).
local function is_recycling(recipe)
	if recipe.category == "recycling" then return true end
	for _, category in pairs(recipe.categories or {}) do
		if category == "recycling" then return true end
	end
	return false
end

-- log("** before modification:")
-- log(serpent.block(data.raw['technology']["science-pack-productivity"].effects))
if(settings.startup["automatically-populate-science-pack-productivity-research"].value) then
	for _, science_pack in pairs(util_scripts.get_all_science_from_all_labs()) do
		--log("**testing science: " .. science_pack)
		if(not util_scripts.table_contains(data.raw['technology']["science-pack-productivity"].effects, science_pack, "recipe")) then
			for _, recipe in pairs(data.raw['recipe']) do
				if(recipe.results and util_scripts.table_contains(recipe.results, science_pack, "name") and not is_recycling(recipe) and not string.find(recipe.name, "vessel") and not string.find(recipe.name, "augmenting")) then
					local insert_science = {
						type = "change-recipe-productivity",
						recipe = recipe.name,
						change = 0.01
					}
					table.insert(data.raw['technology']["science-pack-productivity"].effects, insert_science)
				end
			end
		end
		if(not util_scripts.table_contains(data.raw['technology']["science-pack-productivity"].unit.ingredients, science_pack, 1)) then
				local insert_ingredients = {science_pack, 1}
				table.insert(data.raw['technology']["science-pack-productivity"].unit.ingredients,insert_ingredients)
		end
		if(not util_scripts.table_contains(data.raw['lab']['biolab'].inputs, science_pack)) then
			table.insert(data.raw['lab']['biolab'].inputs, science_pack)
		end
	end
end

-- log("**biolab inputs:")
-- log(serpent.block(data.raw['lab']['biolab'].inputs))

if(settings.startup["restrict-steam-recycler-crafting-to-frozeta"].value) then
	data.raw['recipe']['steam-recycler'].surface_conditions = 
	{
        {
          property = "pressure",
          min = 200,
          max = 280,
        }
    }

end

if(mods["no-quality"] or not mods["quality"] ) then
	data.raw.module["quality-module-4-S"] = nil

	data.raw.recipe["quality-module-4-S-recycling"] = nil
	data.raw.recipe["quality-module-4-S"] = nil
	data.raw["produce-achievement"]["crafting-with-hyper-quality"] = nil

	if(settings.startup["condense-level-4-modules-into-one-technology"].value) then
		data.raw.technology["module-finale"].effects = 
		{
			{
				type = "unlock-recipe",
				recipe = "productivity-module-4-S",
			},
			{
				type = "unlock-recipe",
				recipe = "efficiency-module-4-S",
			},
			{
				type = "unlock-recipe",
				recipe = "speed-module-4-S",
			},
			{
				type = "unlock-recipe",
				recipe = "golden-egg",
			},
		}
	else
		data.raw.technology["quality-module-4-S"] = nil
	end
end