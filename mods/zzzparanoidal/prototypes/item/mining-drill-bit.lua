local order = 15
local function createBIT(name)
	data:extend({
		{
			type = "item",
			name = "mining-drill-bit-" .. name,
			icon = "__zzzparanoidal__/graphics/mining-drill-bit-" .. name .. ".png",
			subgroup = "mining-drill-bit",
			order = "a-" .. string.char(order),
			stack_size = 50,
			icon_size = 128,
			icon_mipmaps = 4,
		},
	})
	order = order + 1
end
data:extend({
	{
		type = "item-subgroup",
		name = "mining-drill-bit",
		group = "intermediate-products",
		order = "z-z",
	},
})

createBIT("mk0")
createBIT("mk1")
createBIT("mk2")
createBIT("mk3")
createBIT("mk4")
createBIT("mk5")

