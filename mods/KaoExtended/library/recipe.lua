require("__KaoExtended__/config")
if not KaoExtended then
	KaoExtended = {}
end
if not KaoExtended.item then
	KaoExtended.item = {}
end
if not KaoExtended.recipe then
	KaoExtended.recipe = {}
end
KaoExtended.getRecipe = function(recipe)
	return data.raw["recipe"][recipe]
end

function KaoExtended.table_merge(table1, table2)
	for index, value in pairs(table2) do
		if type(value) == "table" then
			KaoExtended.table_merge(table1[index], table2[index])
		else
			table1[index] = value
		end
	end
end

function KaoExtended.result_check(object)
	if object then
		if object.results == nil then
			object.results = {}
		end

		if object.result then
			local item = KaoExtended.item.basic_item({ name = object.result })
			if object.result_count then
				item.amount = object.result_count
				object.result_count = nil
			end
			KaoExtended.item.add_new(object.results, item)

			if object.ingredients then -- It's a recipe
				if not object.main_product then
					if object.icon or object.subgroup or object.order or item.type ~= "item" then -- if we already have one, add the rest
						if not object.icon and data.raw[item.type][object.result].icon then
							object.icon = data.raw[item.type][object.result].icon
						end
						if not object.subgroup and data.raw[item.type][object.result].subgroup then
							object.subgroup = data.raw[item.type][object.result].subgroup
						end
						if not object.order and data.raw[item.type][object.result].order then
							object.order = data.raw[item.type][object.result].order
						end
					else -- otherwise just use main_product as a cheap way to set them all.
						object.main_product = object.result
					end
				end
			end
			object.result = nil
		end
	else
		log(object .. " does not exist.")
	end
end

function KaoExtended.item.get_type(name)
	local item_types =
		{ "ammo", "armor", "capsule", "fluid", "gun", "item", "mining-tool", "module", "tool", "item-with-entity-data" }
	local item_type = nil
	for i, type_name in pairs(item_types) do
		if data.raw[type_name][name] then
			item_type = type_name
		end
	end
	return item_type
end
function KaoExtended.item.get_basic_type(name)
	local item_type = "item"
	if data.raw.fluid[name] then
		item_type = "fluid"
	end
	return item_type
end
function KaoExtended.item.basic_item(inputs)
	local item = {}

	if inputs.name then
		item.name = inputs.name
	else
		item.name = inputs[1]
	end

	if inputs.amount then
		item.amount = inputs.amount
	else
		if inputs[2] then
			item.amount = inputs[2]
		end
	end
	if not item.amount then
		item.amount = 1
	end

	if inputs.type then
		item.type = inputs.type
	else
		item.type = KaoExtended.item.get_basic_type(item.name)
	end

	if item.type == "item" then
		if item.amount > 0 and item.amount < 1 then
			item.amount = 1
		else
			item.amount = math.floor(item.amount)
		end
	end

	return item
end

function KaoExtended.item.item(inputs)
	local item = {}

	if inputs.name then
		item.name = inputs.name
	else
		item.name = inputs[1]
	end

	if inputs.amount then
		item.amount = inputs.amount
	else
		if inputs[2] then
			item.amount = inputs[2]
		end
	end
	if not item.amount then
		if inputs.amount_min and inputs.amount_max then
			item.amount_min = inputs.amount_min
			item.amount_max = inputs.amount_max
		else
			item.amount = 1
		end
	end
	if inputs.probability then
		item.probability = inputs.probability
	end

	if inputs.type then
		item.type = inputs.type
	else
		item.type = KaoExtended.item.get_basic_type(item.name)
	end

	return item
end
function KaoExtended.item.add_new(list, item_in) --ignores if exists
	local item = KaoExtended.item.item(item_in)
	local addit = true
	for i, object in pairs(list) do
		if item.name == KaoExtended.item.basic_item(object).name then
			addit = false
		end
	end
	if addit then
		table.insert(list, item)
	end
end

function KaoExtended.recipe.addtorecipe(recipe, item)
	if data.raw.recipe[recipe] and KaoExtended.item.get_type(KaoExtended.item.basic_item(item).name) then
		if data.raw.recipe[recipe].expensive then
			KaoExtended.item.add_new(data.raw.recipe[recipe].expensive.ingredients, KaoExtended.item.basic_item(item))
		end
		if data.raw.recipe[recipe].normal then
			KaoExtended.item.add_new(data.raw.recipe[recipe].normal.ingredients, KaoExtended.item.basic_item(item))
		end
		if data.raw.recipe[recipe].ingredients then
			KaoExtended.item.add_new(data.raw.recipe[recipe].ingredients, KaoExtended.item.basic_item(item))
		end
	else
		if not data.raw.recipe[recipe] then
			error("Recipe " .. recipe .. " does not exist.")
		end
		if not KaoExtended.item.get_type(item) then
			error("Ingredient " .. KaoExtended.item.basic_item(item).name .. " does not exist.")
		end
	end
end

KaoExtended.changeTime = function(recipe, time)
	data.raw["recipe"][recipe].energy_required = item
end
