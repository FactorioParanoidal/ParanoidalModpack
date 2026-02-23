data.raw["beacon"]["beacon"].collision_mask =
	{ layers = { item = true, object = true, floor = true, water_tile = true } }

if mods["bobmodules"] then
	data.raw["beacon"]["bob-beacon-2"].collision_mask =
		{ layers = { item = true, object = true, floor = true, water_tile = true } }
	data.raw["beacon"]["bob-beacon-3"].collision_mask =
		{ layers = { item = true, object = true, floor = true, water_tile = true } }
end
