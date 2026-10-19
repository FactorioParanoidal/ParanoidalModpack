require("prototypes.board")({
	name = "ued-small-db",
	base = "medium-electric-pole",
	icon = "md-icon.png",
	pole = "md-pole.png",
	scale = 0.122,
	tiles = 1,
	half = 0.5,
	supply_area_distance = 3.5,
	maximum_wire_distance = 9,
	fast_replaceable_group = "electric-pole",
	order = "a[energy]-b[medium-electric-pole]-b[ued-small-db]",
	ingredients = {
		{"medium-electric-pole", 1},
		{"electronic-circuit", 2},
		{"copper-plate", 10},
		{"steel-plate", 5},
	},
})
