if not (mods["angelsaddons-storage"] and angelsmods.addons.storage.warehouses) then return end

local logistic_warehouses = {
	"warehouse-passive-provider",
	"warehouse-active-provider",
	"warehouse-buffer",
	"warehouse-storage",
	"warehouse-requester",
}

local prerequisite_map = {
	["angels-warehouse-passive-provider"] = "angels-warehouse",
	["angels-warehouse-active-provider"] = "angels-warehouse",
	["angels-warehouse-buffer"] = "angels-warehouse",
	["angels-warehouse-storage"] = "angels-warehouse",
	["angels-warehouse-requester"] = "angels-warehouse",

	["warehouse-mk2"] = "angels-warehouse",
	["warehouse-passive-provider-mk2"] = "angels-warehouse-passive-provider",
	["warehouse-active-provider-mk2"] = "angels-warehouse-active-provider",
	["warehouse-buffer-mk2"] = "angels-warehouse-buffer",
	["warehouse-storage-mk2"] = "angels-warehouse-storage",
	["warehouse-requester-mk2"] = "angels-warehouse-requester",

	["warehouse-mk3"] = "warehouse-mk2",
	["warehouse-passive-provider-mk3"] = "warehouse-passive-provider-mk2",
	["warehouse-active-provider-mk3"] = "warehouse-active-provider-mk2",
	["warehouse-buffer-mk3"] = "warehouse-buffer-mk2",
	["warehouse-storage-mk3"] = "warehouse-storage-mk2",
	["warehouse-requester-mk3"] = "warehouse-requester-mk2",

	["warehouse-mk4"] = "warehouse-mk3",
	["warehouse-passive-provider-mk4"] = "warehouse-passive-provider-mk3",
	["warehouse-active-provider-mk4"] = "warehouse-active-provider-mk3",
	["warehouse-buffer-mk4"] = "warehouse-buffer-mk3",
	["warehouse-storage-mk4"] = "warehouse-storage-mk3",
	["warehouse-requester-mk4"] = "warehouse-requester-mk3",
}

local standard_ingredients = {
	[1] = {
		{type = "item", name = "iron-plate", amount = 500},
		{type = "item", name = "stone-brick", amount = 100},
	},
	[2] = {
		{type = "item", name = "invar-alloy", amount = 400},
		{type = "item", name = "brass-gear-wheel", amount = 150},
		{type = "item", name = "steel-bearing", amount = 100},
	},
	[3] = {
		{type = "item", name = "titanium-plate", amount = 800},
		{type = "item", name = "ceramic-bearing", amount = 200},
	},
	[4] = {
		{type = "item", name = "tungsten-plate", amount = 1000},
		{type = "item", name = "nitinol-bearing", amount = 250},
	}
}

local logistic_ingredients = {
	[1] = {
		{type = "item", name = "steel-plate", amount = 250},
		{type = "item", name = "electronic-circuit", amount = 100},
		{type = "item", name = "advanced-circuit", amount = 40},
	},
	[2] = {
		{type = "item", name = "invar-alloy", amount = 400},
		{type = "item", name = "brass-gear-wheel", amount = 150},
		{type = "item", name = "steel-bearing", amount = 100},
	},
	[3] = {
		{type = "item", name = "titanium-plate", amount = 800},
		{type = "item", name = "ceramic-bearing", amount = 200},
		{type = "item", name = "processing-unit", amount = 200},
	},
	[4] = {
		{type = "item", name = "tungsten-plate", amount = 1000},
		{type = "item", name = "nitinol-bearing", amount = 250},
		{type = "item", name = "advanced-processing-unit", amount = 200},
	}
}

-- Revise Angel's warehouses
data.raw.recipe["angels-warehouse"].energy_required = 20
data.raw.recipe["angels-warehouse"].ingredients = util.copy(standard_ingredients[1])

for _, warehouse in pairs(logistic_warehouses)do
	data.raw.recipe["angels-"..warehouse].energy_required = 20
	data.raw.recipe["angels-"..warehouse].ingredients = util.copy(logistic_ingredients[1])
end

-- Iterate through warehouse types and make all the requisite recipes
for n = 2, 4 do
	-- Setup standard warehouse subtype
	data:extend({
		util.merge{data.raw.recipe["angels-warehouse"], {
			name = "warehouse-mk"..n,
			result = "warehouse-mk"..n,
			subgroup = "angels-warehouses-"..n,
		}}
	})

	data.raw.recipe["warehouse-mk"..n].ingredients = util.copy(standard_ingredients[n])

	-- Setup logistics warehouse subtypes
	for _, prefix in pairs(logistic_warehouses) do
		data:extend({
			util.merge{data.raw.recipe["angels-"..prefix], {
				name = prefix.."-mk"..n,
				result = prefix.."-mk"..n,
				subgroup = "angels-warehouses-"..n,
			}}
		})

		data.raw.recipe[prefix.."-mk"..n].ingredients = util.copy(logistic_ingredients[n])
	end
end

-- Add all the prerequisites
for name, prerequisite in pairs(prerequisite_map) do
	bobmods.lib.recipe.add_ingredient(name, prerequisite)
end