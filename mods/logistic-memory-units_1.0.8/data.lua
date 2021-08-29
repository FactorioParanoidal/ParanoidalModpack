local function merge(prototype, new_data)
	prototype = table.deepcopy(prototype)
	for k, v in pairs(new_data) do
		if v == 'nil' then
			prototype[k] = nil
		else
			prototype[k] = v
		end
	end
	return prototype
end

data.raw.item['memory-unit'].subgroup = 'memory-unit'
data.raw.container['memory-unit'].fast_replaceable_group = 'memory-unit'

local ingredients = {
	{'logistic-chest-storage', 2},
	{'memory-unit', 1},
	{'advanced-circuit', 2}
}

data:extend{
	merge(data.raw.item['memory-unit'], {
		name = 'active-provider-memory-unit',
		icon = '__logistic-memory-units__/graphics/icon/active-provider-memory-unit.png',
		place_result = 'active-provider-memory-unit',
		order = 'c'
	}),
	merge(data.raw.item['memory-unit'], {
		name = 'passive-provider-memory-unit',
		icon = '__logistic-memory-units__/graphics/icon/passive-provider-memory-unit.png',
		place_result = 'passive-provider-memory-unit',
		order = 'd'
	}),
	merge(data.raw.item['memory-unit'], {
		name = 'storage-memory-unit',
		icon = '__logistic-memory-units__/graphics/icon/storage-memory-unit.png',
		place_result = 'storage-memory-unit',
		order = 'e'
	}),
	merge(data.raw.item['memory-unit'], {
		name = 'buffer-memory-unit',
		icon = '__logistic-memory-units__/graphics/icon/buffer-memory-unit.png',
		place_result = 'buffer-memory-unit',
		order = 'f'
	}),
	merge(data.raw.item['memory-unit'], {
		name = 'requester-memory-unit',
		icon = '__logistic-memory-units__/graphics/icon/requester-memory-unit.png',
		place_result = 'requester-memory-unit',
		order = 'g'
	}),
	merge(data.raw.container['memory-unit'], {
		type = 'logistic-container',
		logistic_mode = 'active-provider',
		icon = '__logistic-memory-units__/graphics/icon/active-provider-memory-unit.png',
		name = 'active-provider-memory-unit',
		minable = {mining_time = 1, result = 'active-provider-memory-unit'}
	}),
	merge(data.raw.container['memory-unit'], {
		type = 'logistic-container',
		logistic_mode = 'passive-provider',
		icon = '__logistic-memory-units__/graphics/icon/passive-provider-memory-unit.png',
		name = 'passive-provider-memory-unit',
		minable = {mining_time = 1, result = 'passive-provider-memory-unit'}
	}),
	merge(data.raw.container['memory-unit'], {
		type = 'logistic-container',
		logistic_mode = 'storage',
		icon = '__logistic-memory-units__/graphics/icon/storage-memory-unit.png',
		name = 'storage-memory-unit',
		minable = {mining_time = 1, result = 'storage-memory-unit'},
		max_logistic_slots = 1
	}),
	merge(data.raw.container['memory-unit'], {
		type = 'logistic-container',
		logistic_mode = 'requester',
		icon = '__logistic-memory-units__/graphics/icon/requester-memory-unit.png',
		name = 'requester-memory-unit',
		minable = {mining_time = 1, result = 'requester-memory-unit'},
		max_logistic_slots = 1
	}),
	merge(data.raw.container['memory-unit'], {
		type = 'logistic-container',
		logistic_mode = 'buffer',
		icon = '__logistic-memory-units__/graphics/icon/buffer-memory-unit.png',
		name = 'buffer-memory-unit',
		minable = {mining_time = 1, result = 'buffer-memory-unit'},
		max_logistic_slots = 1
	}),
	{
		type = 'recipe',
		name = 'active-provider-memory-unit',
		ingredients = {
	{'logistic-chest-active-provider', 2},
	{'memory-unit', 1},
	{'advanced-circuit', 2}
},
		result = 'active-provider-memory-unit',
		enabled = false
	},
	{
		type = 'recipe',
		name = 'passive-provider-memory-unit',
		ingredients = {
	{'logistic-chest-passive-provider', 2},
	{'memory-unit', 1},
	{'advanced-circuit', 2}
},
		result = 'passive-provider-memory-unit',
		enabled = false
	},
	{
		type = 'recipe',
		name = 'storage-memory-unit',
		ingredients = {
	{'logistic-chest-storage', 2},
	{'memory-unit', 1},
	{'advanced-circuit', 2}
},
		result = 'storage-memory-unit',
		enabled = false
	},
	{
		type = 'recipe',
		name = 'requester-memory-unit',
		ingredients = {
	{'logistic-chest-requester', 2},
	{'memory-unit', 1},
	{'advanced-circuit', 2}
},
		result = 'requester-memory-unit',
		enabled = false
	},
	{
		type = 'recipe',
		name = 'buffer-memory-unit',
		ingredients = {
	{'logistic-chest-buffer', 2},
	{'memory-unit', 1},
	{'advanced-circuit', 2}
},
		result = 'buffer-memory-unit',
		enabled = false
	},
	{
		type = 'technology',
		name = 'logistic-memory-storage',
		icon = '__deep-storage-unit__/graphics/technology/memory-unit.png',
		icon_size = 128,
		effects = {
			{
				recipe = 'active-provider-memory-unit',
				type = 'unlock-recipe'
			},
			{
				recipe = 'passive-provider-memory-unit',
				type = 'unlock-recipe'
			},
			{
				recipe = 'storage-memory-unit',
				type = 'unlock-recipe'
			},
			{
				recipe = 'requester-memory-unit',
				type = 'unlock-recipe'
			},
			{
				recipe = 'buffer-memory-unit',
				type = 'unlock-recipe'
			}
		},
		prerequisites = {
			'memory-unit',
			'logistic-system'
		},
		unit = {
			count = 500,
			ingredients = {
				{'automation-science-pack', 1},
				{'logistic-science-pack', 1},
				{'chemical-science-pack', 1},
				{'advanced-logistic-science-pack', 1}
			},
			time = 30
		}
	}
}

data.raw['logistic-container']['active-provider-memory-unit'].picture.filename = '__logistic-memory-units__/graphics/entity/active-provider-memory-unit.png'
data.raw['logistic-container']['active-provider-memory-unit'].picture.hr_version.filename = '__logistic-memory-units__/graphics/entity/hr-active-provider-memory-unit.png'
data.raw['logistic-container']['passive-provider-memory-unit'].picture.filename = '__logistic-memory-units__/graphics/entity/passive-provider-memory-unit.png'
data.raw['logistic-container']['passive-provider-memory-unit'].picture.hr_version.filename = '__logistic-memory-units__/graphics/entity/hr-passive-provider-memory-unit.png'
data.raw['logistic-container']['storage-memory-unit'].picture.filename = '__logistic-memory-units__/graphics/entity/storage-memory-unit.png'
data.raw['logistic-container']['storage-memory-unit'].picture.hr_version.filename = '__logistic-memory-units__/graphics/entity/hr-storage-memory-unit.png'
data.raw['logistic-container']['requester-memory-unit'].picture.filename = '__logistic-memory-units__/graphics/entity/requester-memory-unit.png'
data.raw['logistic-container']['requester-memory-unit'].picture.hr_version.filename = '__logistic-memory-units__/graphics/entity/hr-requester-memory-unit.png'
data.raw['logistic-container']['buffer-memory-unit'].picture.filename = '__logistic-memory-units__/graphics/entity/buffer-memory-unit.png'
data.raw['logistic-container']['buffer-memory-unit'].picture.hr_version.filename = '__logistic-memory-units__/graphics/entity/hr-buffer-memory-unit.png'
