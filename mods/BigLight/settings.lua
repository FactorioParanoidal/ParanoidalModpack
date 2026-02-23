data:extend {
	{
		-- Taille de la lampe foreuse électrique
		type = "int-setting",
		name = "ritnmods-bl-01",
		setting_type = "startup",
		default_value = 3,
		minimum_value = 1,
		maximum_value = 5,
		order = "ritnmods-bl-01"
	},
	{
		-- lampe de l'arret de train en vert
		type = "bool-setting",
		name = "ritnmods-bl-02",
		setting_type = "startup",
		default_value = false,
		order = "ritnmods-bl-02"
	},
	{
		-- Taille de la lampe de l'arret de train
		type = "int-setting",
		name = "ritnmods-bl-03",
		setting_type = "startup",
		default_value = 4,
		minimum_value = 0,
		maximum_value = 5,
		order = "ritnmods-bl-03"
	},
	{
		-- Taille de la lampe du commutateur
		type = "int-setting",
		name = "ritnmods-bl-04",
		setting_type = "startup",
		default_value = 3,
		minimum_value = 0,
		maximum_value = 5,
		order = "ritnmods-bl-04"
	},
	{
		-- Taille de la lampe du signaux ferroviaires
		type = "int-setting",
		name = "ritnmods-bl-05",
		setting_type = "startup",
		default_value = 2,
		minimum_value = 0,
		maximum_value = 3,
		order = "ritnmods-bl-05"
	},
}