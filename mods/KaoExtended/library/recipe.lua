local Assert = require("__zzzcompability__/utils/assert")
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
	Assert(type(recipe) == "string", "Expected string recipe name but given: " .. type(recipe))
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
			KaoExtended.item.add_to_ingredients_if_new(object.results, item)

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
	for _, type_name in pairs(item_types) do
		if data.raw[type_name][name] then
			return type_name
		end
	end
	return nil
end

function KaoExtended.item.get_basic_type(name)
	local item_type = "item"
	if data.raw.fluid[name] then
		item_type = "fluid"
	end
	return item_type
end

local function get_item_name(inputs)
	if inputs.name then
		return inputs.name
	end
	return inputs[1]
end

-- Create basic item struct
-- @param name [string] -- item name
-- @param amount [number | nil] -- item amount
-- @param _type [string | nil] -- item type
--
-- @return {name [string], amount [number], type [string]}
local function basic_item_impl(name, amount, _type)
	Assert.Expected(type(name) == "string", "string", name, "item name ")
	Assert.Expected(type(amount) == "number" or type(amount) == "nil", "number or nil", amount, "item amount")
	Assert.Expected(type(_type) == "string" or type(_type) == "nil", "string or nil", _type, "item type")

	if type(amount) ~= "number" then
		amount = 1
	end

	if type(_type) == "nil" then
		_type = KaoExtended.item.get_basic_type(name)
	end

	return {
		name = name,
		amount = amount,
		type = _type,
	}
end

function KaoExtended.item.basic_item(inputs)
	local item = basic_item_impl(get_item_name(inputs), inputs.amount or inputs[2], inputs.type)

	if item.type == "item" and  item.amount > 0 and item.amount < 1 then
			item.amount = 1
		else
			item.amount = math.floor(item.amount)
	end

	return item
end

function KaoExtended.item.item(inputs)
	local item = KaoExtended.item.basic_item(inputs)

	if inputs.amount_min and inputs.amount_max then
		item.amount_min = inputs.amount_min
		item.amount_max = inputs.amount_max
		item.amount = nil
	else
		item.amount = item.amount or 1
	end
	if inputs.probability then
		item.probability = inputs.probability
	end
	return item
end

function KaoExtended.item.add_to_ingredients_if_new(ingredients, item_in)
	local item = KaoExtended.item.item(item_in)
	for _, object in pairs(ingredients) do
		if item.name == get_item_name(object) then
			return
		end
	end
	table.insert(ingredients, item)
end

-- Adds item to recipe
-- @param recipeName [string] -- recipe add item to
-- @param itemInputs [{type = string, name = string, amount = number}] -- item name and item amount
function KaoExtended.recipe.add_to_recipe(recipeName, itemInputs)
	Assert.Expected(type(recipeName) == "string", "recipe name as string ", recipeName, "recipeName")
	Assert.Expected(type(itemInputs) == "table" and itemInputs.name and itemInputs.amount and itemInputs.type, "correct recipe ingredient", itemInputs)

	local recipe = data.raw.recipe[recipeName]
	local item = KaoExtended.item.basic_item(itemInputs)
	Assert(recipe, "Recipe " .. recipeName .. " does not exist.")

	KaoExtended.item.add_to_ingredients_if_new(recipe.ingredients, item)
end

KaoExtended.changeTime = function(recipe, time)
	data.raw["recipe"][recipe].energy_required = time
end
