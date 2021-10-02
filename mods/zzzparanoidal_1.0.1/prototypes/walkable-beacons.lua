	data.raw["beacon"]["beacon"].collision_mask = {"item-layer", "object-layer", "floor-layer", "water-tile"}

	if mods["bobmodules"] then
		data.raw["beacon"]["beacon-2"].collision_mask = {"item-layer", "object-layer", "floor-layer", "water-tile"}
		data.raw["beacon"]["beacon-3"].collision_mask = {"item-layer", "object-layer", "floor-layer", "water-tile"}
	end