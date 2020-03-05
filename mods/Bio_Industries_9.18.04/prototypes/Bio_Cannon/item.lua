if BI.Settings.Bio_Cannon then

	data:extend({

		
		-- Hive Buster Turret
		
			{
		type = "item",
		name = "bi-bio-cannon-area",
		icon = "__Bio_Industries__/graphics/icons/biocannon_icon.png",
		icon_size = 32,
		subgroup = "defensive-structure",
		order = "x[turret]-x[gun-turret]",
		place_result = "bi-bio-cannon-area",
		stack_size = 1,
		},
		
	})

end