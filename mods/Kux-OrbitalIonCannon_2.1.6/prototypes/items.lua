local modFolder="__Kux-OrbitalIonCannon__" -- Orbital Ion Cannon
data:extend({
	{
		type = "item",
		name = "orbital-ion-cannon",
		icon = modFolder.."/graphics/icon64.png",
		icon_size = 64,
		subgroup = "defensive-structure",
		order = "e[orbital-ion-cannon]",
		stack_size = 1
	},
	{
		type = "item",
		name = "ion-cannon-targeter",
		icon = modFolder.."/graphics/crosshairs64.png",
		icon_size = 64,
		place_result = "ion-cannon-targeter",
		subgroup = "capsule",
		order = "c[target]",
		stack_size = 1,
	}
})
