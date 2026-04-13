local order = 65
local function createSC(name)
	data:extend({
		{
			type = "item",
			name = name .. "-structure-components",
			icon = "__zzzparanoidal__/graphics/" .. name .. "SC.png",
			subgroup = "structurecomponents",
			order = "a-" .. string.char(order),
			stack_size = 50,
			icon_size = 32,
		},
	})
	order = order + 1
end
data:extend({
	{
		type = "item-subgroup",
		name = "structurecomponents",
		group = "intermediate-products",
		order = "z-z",
	},
})
createSC("basic")
createSC("intermediate")
createSC("advanced")
createSC("anotherworld")

