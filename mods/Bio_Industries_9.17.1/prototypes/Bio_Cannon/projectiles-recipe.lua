if BI.Settings.Bio_Cannon then

	data:extend({

	  -- Hive Buster Ammo
	 {
		type= "recipe",
		name= "bi_recipe_bio_cannon_basic_ammo",
		enabled = false,
		energy_required = 4,
		ingredients = {{"iron-plate", 10}, {"rocket", 10}},
		result = "bi-bio-cannon-basic-ammo",
		result_count = 1,
	 },
	 {
		type= "recipe",
		name= "bi_recipe_bio_cannon_poison_ammo",
		enabled = false,
		energy_required = 8,
		ingredients = {{"bi-bio-cannon-basic-ammo", 1},{"poison-capsule", 5}, {"explosive-rocket", 5}},
		result = "bi-bio-cannon-poison-ammo",
		result_count = 1,
	 },

	 })
 
 end