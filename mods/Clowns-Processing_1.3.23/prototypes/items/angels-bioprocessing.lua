if mods["angelsbioprocessing"] then --this path is currently incomplete.
  data:extend(
{
	--[[{
		type = "item",
		name = "algae-orange",
		icon = "__angelsbioprocessing__/graphics/icons/algae-brown.png",
		icon_size = 32,
		subgroup = "bio-processing-brown",
		order = "a",
		stack_size = 200
	},]]
	{
		type = "item",
		name = "algae-violet",
		icons = {{icon="__angelsbioprocessing__/graphics/icons/algae-brown.png",tint={127,0,255}, icon_size = 32}},
		subgroup = "bio-processing-violet",
		order = "a",
		stack_size = 200
	},
}
)
end