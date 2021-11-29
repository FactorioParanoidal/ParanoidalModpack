data.raw["item-with-entity-data"]["cargo-plane"].order = "b[personal-transport]-e-a"
data.raw["item-with-entity-data"]["gunship"].order = "b[personal-transport]-f[gunship]",

data:extend({
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	{ -- Better Cargo Plane
		type = "item-with-entity-data",
		name = "better-cargo-plane",
		icon = "__betterCargoPlanes__/graphics/icons/better_cargo_plane_icon.png", -- Temporary visual
		icon_size = 64,
		flags = {},
		subgroup = "transport",
		order = "b[personal-transport]-e-b",
		place_result = "better-cargo-plane",
		stack_size = 1,
	},
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	{ -- Even Better Cargo Plane
		type = "item-with-entity-data",
		name = "even-better-cargo-plane",
		icon = "__betterCargoPlanes__/graphics/icons/even_better_cargo_plane_icon.png", -- Temporary visual
		icon_size = 64,
		flags = {},
		subgroup = "transport",
		order = "b[personal-transport]-e-c",
		place_result = "even-better-cargo-plane",
		stack_size = 1,
	}
})