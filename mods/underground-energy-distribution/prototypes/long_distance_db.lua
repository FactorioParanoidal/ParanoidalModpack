require("prototypes.board")({
	name = "ued-long-distance-db",
	base = "big-electric-pole",
	icon = "bg-icon.png",
	pole = "bg-pole.png",
	scale = 0.23,
	tiles = 2,
	half = 1,
	supply_area_distance = 2,
	maximum_wire_distance = 30,
	fast_replaceable_group = nil,
	order = "a[energy]-c[big-electric-pole]-b[ued-long-distance-db]",
	ingredients = {
		{"big-electric-pole", 1},
		{"electronic-circuit", 5},
		{"copper-plate", 15},
		{"steel-plate", 5},
	},
})
