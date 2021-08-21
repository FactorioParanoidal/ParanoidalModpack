------------------------------------------------
---- here is where all functions are stored ----
------------------------------------------------

-- Setup function host
local functions = {}

-- Hide entity
function functions.hide_entity(entity_name, tech_name)
	if data.raw.technology[tech_name] then
		for i, effect in pairs(data.raw.technology[tech_name].effects) do
			if effect.type == "unlock-recipe" and effect.recipe == entity_name then
				table.remove(data.raw.technology[tech_name].effects,i)
				data.raw.recipe[entity_name] = nil
				data.raw.item[entity_name].flags = {"hidden"}
				data.raw.item[entity_name].subgroup = "other"
			end
		end
	elseif data.raw.item[entity_name] then
		data.raw.recipe[entity_name] = nil
		data.raw.item[entity_name].flags = {"hidden"}
		data.raw.item[entity_name].subgroup = "other"
	end
end

-- Remove entity
function functions.remove_entity(entity_name, entity_type, tech_name)
	if tech_name ~= nil and data.raw.technology[tech_name] then
		for i, effect in pairs(data.raw.technology[tech_name].effects) do
			if effect.type == "unlock-recipe" and effect.recipe == entity_name then
				table.remove(data.raw.technology[tech_name].effects,i)
				data.raw.recipe[entity_name] = nil
				data.raw.item[entity_name] = nil
				data.raw[entity_type][entity_name] = nil
			end
		end
	else
		data.raw.recipe[entity_name] = nil
		data.raw.item[entity_name] = nil
		data.raw[entity_type][entity_name] = nil
	end
end

-- Fix collision mask
function functions.fix_collision_mask(entity_name)
	if data.raw["assembling-machine"][entity_name] then
		data.raw["assembling-machine"][entity_name].collision_mask = {"object-layer", "train-layer"}
		data.raw["offshore-pump"][entity_name .. "-placeholder"].collision_mask = {"object-layer", "train-layer"}
	else
		data.raw["offshore-pump"][entity_name].collision_mask = {"object-layer", "train-layer"}
	end
end

-- Add recipe to tech
function functions.add_tech_recipe(tech_name, recipe)
	if data.raw.technology[tech_name] and data.raw.recipe[recipe] then
		table.insert(data.raw.technology[tech_name].effects,{type = "unlock-recipe", recipe = recipe})
	end
end

-- Add result to recipe
function functions.add_recipe_result(recipe_name, type, new_result, amount)
	if data.raw.recipe[recipe_name] and data.raw.recipe[recipe_name].results then
		table.insert(data.raw.recipe[recipe_name].results,{type = type, name = new_result, amount = amount})
	end
end

-- Remove recipe from tech
function functions.remove_tech_recipe(tech_name, recipe)
	if data.raw.technology[tech_name] and data.raw.recipe[recipe] then
		for i, effect in pairs(data.raw.technology[tech_name].effects) do
			if effect.type == "unlock-recipe" and effect.recipe == recipe then
				table.remove(data.raw.technology[tech_name].effects,i)
			end
		end
	end
end

-- Replace tech recipe
function functions.replace_tech_recipe(tech_name, old_recipe, new_recipe)
	if data.raw.technology[tech_name] and data.raw.recipe[old_recipe] and data.raw.recipe[new_recipe] then
		for i, effect in pairs(data.raw.technology[tech_name].effects) do
			if effect.type == "unlock-recipe" and effect.recipe == old_recipe then
				table.remove(data.raw.technology[tech_name].effects,i)
				table.insert(data.raw.technology[tech_name].effects,{type = "unlock-recipe", recipe = new_recipe})
			end
		end
	end
end

-- Assign tiers to icons
function functions.assign_icon_tier(name, type, map, mask, highlights)
	
	-- Parse map
	local tier = map[1]

	-- Make icon inputs
	local icon_input
	if mask ~= nil and highlights ~= nil then
		icon_input =
		{
			{
				icon = data.raw.item[name].icon,
				icon_size = 64,
				icon_mipmaps = 4
			},
			{
				icon = mask,
				icon_size = 64,
				icon_mipmaps = 4,
				tint = inputs.tint
			},
			{
				icon = highlights,
				icon_size = 64,
				icon_mipmaps = 4,
				tint = {1, 1, 1, 0}
			}
		}
	else
		icon_input =
		{
			{
				icon = data.raw.item[name].icon,
				icon_size = 64,
				icon_mipmaps = 4
			}
		}
	end

	inputs =
	{
		tint = reskins.lib.tint_index[tier],
		tier_labels = reskins.lib.setting("reskins-bobs-do-pipe-tier-labeling"),
		icon = icon_input
	}

	-- Insert tier label
	reskins.lib.append_tier_labels(tier, inputs)

	-- Apply icon reskin
	data.raw.item[name].icons = inputs.icon
	if data.raw[type][name] then
		data.raw[type][name].icons = inputs.icon
	elseif data.raw[type][name .. "-placeholder"] then
		data.raw[type][name .. "-placeholder"].icons = inputs.icon
	end
end

-- Ingredient swap function [DOES NOT CHECK FOR DUPLICATES]
function functions.replace_ingredient_all_recipes(old_item, new_item)
    -- Search the recipe table
    for _, recipe in pairs(data.raw.recipe) do
        -- Fetch the ingredients list
        local normal_ingredients = recipe.normal and recipe.normal.ingredients or recipe.ingredients
        local expensive_ingredients = recipe.expensive and recipe.expensive.ingredients

        local function update_ingredient(ingredient)
            -- Fetch the current ingredient's name
            local name = ingredient.name or ingredient[1]

            -- Check if its a candidate for replacement
            if name == old_item then
                if ingredient.name then
                    ingredient.name = new_item
                else
                    ingredient[1] = new_item
                end
            end
        end

        -- Iterate through the normal ingredients, check for our old_item, and replace it if found
        if normal_ingredients then
            for _, ingredient in pairs(normal_ingredients) do
                update_ingredient(ingredient)
            end
        end

        -- Iterate through the expensive ingredients, check for our old_item, and replace it if found
        if expensive_ingredients then
            for _, ingredient in pairs(expensive_ingredients) do
                update_ingredient(ingredient)
            end
        end
    end
end

return functions