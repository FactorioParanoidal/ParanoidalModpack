local intermediatemulti = angelsmods.marathon.intermediatemulti

data:extend(
{
	-- Steel Plate
	{
		type = "recipe",
		name = "molten-steel-remelting",
		category = "induction-smelting",
		subgroup = "angels-steel-casting",
		normal =
		{
			enabled = "false",
			energy_required = 6,
			ingredients ={{type="item", name="angels-plate-steel", amount=4}},
			results={{type="fluid",name="liquid-molten-steel", amount=15}},
		},
		expensive =
		{
			enabled = "false",
			energy_required = 6,
			ingredients ={{type="item", name="angels-plate-steel", amount=5 * intermediatemulti}},
			results={{type="fluid",name="liquid-molten-steel", amount=20}},
		},
		icons = {
			{
				icon = "__angelssmelting__/graphics/icons/molten-steel.png",
			},
			{
				icon = "__angelsextended-remelting-fixed__/graphics/icons/remelting.png",
				tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
				scale = 0.32,
				shift = {-12, -12},
			}
		},
		icon_size = 64,
		order = "a]",
	},
	
	-- Molten Steel
	{
		type = "recipe",
		name = "molten-steel-alloy-mixing",
		category = "molten-alloy-mixing",
		subgroup = "aragas-steel-alloy-mixing",
		enabled = "false",
		energy_required = 4,
		ingredients ={
			{type="fluid", name="liquid-molten-iron", amount=240},
			{type="fluid", name="gas-oxygen", amount=60},
		},
		results={{type="fluid", name="liquid-molten-steel", amount=60}},
		icons = {
			{
				icon = "__angelssmelting__/graphics/icons/molten-steel.png",
			},
			{
				icon = "__angelsextended-remelting-fixed__/graphics/icons/remelting.png",
				tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
				scale = 0.32,
				shift = {-12, -12},
			}
		},
		icon_size = 64,
		order = "aa",
	},
}
)