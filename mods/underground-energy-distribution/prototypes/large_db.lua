require("prototypes.board")({
	name = "ued-large-db",
	base = "substation",
	icon = "sb-icon.png",
	pole = "sb-pole.png",
	scale = 0.3495,
	tiles = 3,
	half = 1.5,
	supply_area_distance = 7.5,
	maximum_wire_distance = 18,
	fast_replaceable_group = nil,
	order = "a[energy]-d[substation]-b[ued-large-db]",
	-- data-final-fixes.lua adds Paranoidal's intermediate-structure-components.
	ingredients = {
		{"substation", 1},
		{"copper-plate", 20},
		{"steel-plate", 5},
	},
})
