if BI.Settings.BI_Bio_Fuel then 

	data:extend(
	{
		

		---- Celluluse
		{
			type = "item",
			name = "bi-cellulose",
			icon = "__Bio_Industries__/graphics/icons/cellulose.png",
			icon_size = 32,
			--flags = {},
			subgroup = "intermediate-product",
			order = "b[cellulose]",
			stack_size = 200
		},

		--- BioReactor
		{
			type = "item",
			name = "bi-bioreactor",
			icon = "__Bio_Industries__/graphics/icons/bioreactor.png",
			icon_size = 32,
			--flags = {},
			subgroup = "production-machine",
			order = "z[bi]-a[bi-bioreactor]",
			place_result = "bi-bioreactor",
			stack_size = 10
		},
		--- Bio Boiler
		{
			type = "item",
			name = "bi-bio-boiler",
			icon = "__Bio_Industries__/graphics/icons/bio_boiler.png",
			icon_size = 32,
			--flags = {},
			subgroup = "energy",
			order = "b[steam-power]-b[boiler]",
			place_result = "bi-bio-boiler",
			stack_size = 50
		},
		
	})

end