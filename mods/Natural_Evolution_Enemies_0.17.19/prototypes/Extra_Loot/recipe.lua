if settings.startup["NE_Alien_Artifacts"].value == true then

	if not NE_Enemies then NE_Enemies = {} end
	if not NE_Enemies.Settings then NE_Enemies.Settings = {} end

	NE_Enemies.Settings.NE_Difficulty = settings.startup["NE_Difficulty"].value


	data:extend({
	{
		type = "recipe",
		name = "alien-artifact-from-small",
		--category= "crafting",
		normal =
			{
			enabled = true,
			energy_required = 2,
			ingredients= { {"small-alien-artifact", 50 * NE_Enemies.Settings.NE_Difficulty} },
			result = "alien-artifact",
			result_count = 1,
			},
		expensive =
			{
			enabled = true,
			energy_required = 3,
			ingredients= { {"small-alien-artifact", 75 * NE_Enemies.Settings.NE_Difficulty} },
			result = "alien-artifact",
			result_count = 1,
			},
		
	  },
	})

end