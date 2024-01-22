

local trafos_item_subgroup = {
	{
		type = "item-subgroup",
		name = "transformators",
		group = "production",
		order = "b-b",
	},
}


local function trafos_mkitem(f) return {
	type = "item",
	name = "trafo-"..f,
	icons = {
		{ icon = TRAFOS_GRAPHICS_BASE.."/icons/trafo.png",  tint = TRAFOS_TINT[f], },
		{ icon = TRAFOS_GRAPHICS_BASE.."/icons/tier-"..f..".png", },
	},
	icon_size = 32,
	subgroup = "transformators",
	order = "a"..f,
	place_result = "trafo-"..f.."-displayer",
	stack_size = 4,
} end


local trafos_items = {}
for i = 1, 5 do
	table.insert(trafos_items, trafos_mkitem(i))
end


data:extend(trafos_item_subgroup)
data:extend(trafos_items)

