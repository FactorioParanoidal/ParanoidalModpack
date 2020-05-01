function graphic(name)
	return '__chromatic-belts__/graphics/' .. name .. '.png'
end

-- Mark down the remaps we want, graphic to graphic
remaps = {}

for _, belt_type in pairs{'transport-belt', 'fast-transport-belt', 'express-transport-belt'}
do
	remaps['__base__/graphics/entity/' .. belt_type .. '/' .. belt_type .. '.png'] = graphic(belt_type)
	remaps['__base__/graphics/entity/' .. belt_type .. '/hr-' .. belt_type .. '.png'] = graphic('hr-' .. belt_type)
end

-- Mod Support

-- Bob's Logistics Support
if mods["boblogistics"] then
	require("mods.boblogistics")
end
-- DeadlockLoaders Support
--if mods["DeadlockLoaders"] then
	--require("mods.DeadlockLoaders")
--end

-- The belt graphics are being referred to all over the place. So we search & replace them.
function sweep(data)
	for key, value in pairs(data)
	do
		for remap_key, remap_value in pairs(remaps)
		do
			if value == remap_key
			then
				data[key] = remap_value
				break
			end
		end
		if type(value) == 'table'
		then
			sweep(value)
		end
	end
end

function sweep_all_types(typename)
	for _, prototype in pairs(data.raw[typename])
	do
		sweep(prototype)
	end
end

sweep_all_types('transport-belt')
sweep_all_types('underground-belt')
sweep_all_types('splitter')
sweep_all_types('loader')
