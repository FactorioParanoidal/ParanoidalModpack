
function marathon.update_recipe(name, values)
	local recipe = data.raw.recipe[name]
	if recipe then
		for key, value in pairs(values) do
			-- special ingredient error checking for debugging purposes
			if key == 'ingredients' then
				for _, item in pairs(value) do
					if #item == 0 then
						if not data.raw['item'][item.name] then
							log("Unable to find item: " .. item.name .. ", failed to update recipe " .. name)
						end
					else
						if not data.raw['item'][item[1]] then
							log("Unable to find item: " .. item[1] .. ", failed to update recipe " .. name)
						end
					end
				end
			end
			recipe[key] = value
		end
	end
end

function marathon.replace_recipe_item(recipe, prev_name, new_name)
	local doit = false
	local amount = 0
	if data.raw.recipe[recipe] and data.raw.item[new_name] then
		local ingredients = data.raw.recipe[recipe].ingredients
		for i = 1, #ingredients do
			local ingredient_item = ingredients[i]
			if ingredient_item[1] == prev_name then
				if not data.raw['item'][ingredient_item[1]] then
					log("Unable to find item: " .. ingredient_item[1] .. ", failed to update recipe " .. recipe)
				end
				ingredient_item[1] = new_name
			elseif ingredient_item.name == prev_name then
				if not data.raw['item'][ingredient_item.name] then
					log("Unable to find item: " .. ingredient_item.name .. ", failed to update recipe " .. recipe)
				end
				ingredient_item.name = new_name
			end
		end
	end
end

function marathon.add_new_recipe_item(recipe, item)
	local item_name
	if item.name then
		item_name = item.name
	else
		item_name = item[1]
	end

	if data.raw.recipe[recipe] and data.raw.item[item_name] then
		for _, ingredient_item in pairs(data.raw.recipe[recipe].ingredients) do
			if ingredient_item[1] == item_name then
				return
			elseif ingredient_item.name == item_name then
				return
			end
		end
		if not data.raw['item'][item_name] then
			log("Unable to find item: " .. item_name .. ", failed to update recipe " .. recipe)
		end
		table.insert(data.raw.recipe[recipe].ingredients, item)
	end
end

function marathon.add_recipe_item(recipe, item)
	local addit = true
	local item_name
	if item.name then
		item_name = item.name
	else
		item_name = item[1]
	end
	local item_amount
	if item.amount then
		item_amount = item.amount
	else
		item_amount = item[2]
	end
	if data.raw.recipe[recipe] and data.raw.item[item_name] then
		for _, ingredient_item in pairs(data.raw.recipe[recipe].ingredients) do
			if ingredient_item[1] == item_name then
				ingredient_item[2] = ingredient_item[2] + item_amount
				return
			elseif ingredient_item.name == item_name then
				ingredient_item.amount = ingredient_item.amount + item_amount
				return
			end
		end
		if not data.raw['item'][item_name] then
			log("Unable to find item: " .. item_name .. ", failed to update recipe " .. recipe)
		end
		table.insert(data.raw.recipe[recipe].ingredients, item)
	end
end

	--require("prototypes.new") -- DrD
--[[
	require("prototypes.bobsmods.item")
	require("prototypes.bobsmods.recipe-chemistry")
	--require("prototypes.bobsmods.recipe-circuit")
	require("prototypes.bobsmods.recipe-intermediate")
	require("prototypes.bobsmods.recipe-logistics")
	require("prototypes.bobsmods.recipe-power")
	require("prototypes.bobsmods.recipe-production")
	require("prototypes.bobsmods.recipe-resource")
	require("prototypes.bobsmods.recipe-smelting")
	require("prototypes.bobsmods.recipe-turret")

]]