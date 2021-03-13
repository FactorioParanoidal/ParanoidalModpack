data:extend{
	{
		type = "custom-input",
		name = "inventory-cleanup",
		key_sequence = "SHIFT + C",
		consuming = "game-only"
	},

	
	-- game control hooks
	{
		type = "custom-input",
		name = "fast-entity-transfer-hook",
		key_sequence = "",
		linked_game_control = "fast-entity-transfer",
	},
	{
		type = "custom-input",
		name = "fast-entity-split-hook",
		key_sequence = "",
		linked_game_control = "fast-entity-split",
	},
}