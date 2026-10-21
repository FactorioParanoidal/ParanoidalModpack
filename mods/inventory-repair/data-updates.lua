
local default_variations = {
	{
		filename = "__core__/sound/manual-repair-advanced-1.ogg",
		volume = 1,
	},
	{
		filename = "__core__/sound/manual-repair-advanced-2.ogg",
		volume = 1,
	},
}

data:extend({
	{
		name = "repair-pack",
		type = "sound",
		category = "game-effect",
		aggregation = {
			max_count = 1,
			count_already_playing = true,
			remove = true,
		},
		variations = data.raw["utility-sounds"]["default"]["default_manual_repair"].variations or default_variations
	}
})
