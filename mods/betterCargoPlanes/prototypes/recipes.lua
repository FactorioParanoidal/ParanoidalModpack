data:extend({
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	{ -- Better Cargo Plane
		type = "recipe",
		name = "better-cargo-plane",
		normal = {
			enabled = false,
			energy_required = 10,
			ingredients = {
				{ "steel-plate", 500 },
				{ "low-density-structure", 50 },
				{ "electric-engine-unit", 100 },
				{ "advanced-circuit", 100 },
				{ "steel-chest", 50 },
				{ "submachine-gun", 1 },
				{ "cargo-plane", 1 }
			},
			result = "better-cargo-plane"
		},
		expensive = {
			enabled = false,
			energy_required = 10,
			ingredients = {
				{ "steel-plate", 1000 },
				{ "low-density-structure", 100 },
				{ "electric-engine-unit", 200 },
				{ "advanced-circuit", 200 },
				{ "steel-chest", 50 },
				{ "submachine-gun", 1 },
				{ "cargo-plane", 1 }
			},
			result = "better-cargo-plane"
		},
	},
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	{ -- Even Better Cargo Plane
		type = "recipe",
		name = "even-better-cargo-plane",
		normal = {
			enabled = false,
			energy_required = 10,
			ingredients = {
				{ "low-density-structure", 200 },
				{ "electric-engine-unit", 100 },
				{ "processing-unit", 100 },
				{ "steel-chest", 50 },
				{ "submachine-gun", 1 },
				{ "better-cargo-plane", 1 }
			},
			result = "even-better-cargo-plane"
		},
		expensive = {
			enabled = false,
			energy_required = 10,
			ingredients = {
				{ "low-density-structure", 400 },
				{ "electric-engine-unit", 200 },
				{ "processing-unit", 200 },
				{ "steel-chest", 50 },
				{ "submachine-gun", 1 },
				{ "better-cargo-plane", 1 }
			},
			result = "even-better-cargo-plane"
		},
	}
})