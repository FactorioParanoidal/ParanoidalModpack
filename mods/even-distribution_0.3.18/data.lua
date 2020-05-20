-- Input --

data:extend{
	{
		type = "custom-input",
		name = "inventory-cleanup",
		key_sequence = "SHIFT + C",
		consuming = "game-only"
	}
}


-- Entities --

data:extend{
	{
		type = "flying-text",
		name = "distribution-text",
		flags = {"not-on-map", "placeable-off-grid"},
		time_to_live = 150,
		speed = 0.05
	}
}
