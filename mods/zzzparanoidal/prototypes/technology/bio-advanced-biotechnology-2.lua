-- Фиолетовый тир Bio Industries: в 1.1 эти рецепты держали bi-tech-cellulose-2
-- (целлюлоза 2, батарея) и bi-tech-biomass-reprocessing-2 (биомасса 3, биореактор MK3).
-- Анлоки с bi-tech-advanced-biotechnology снимаются в tweaks/entity/bio-mod.lua.

data:extend({
	{
		type = "technology",
		name = "bi-tech-advanced-biotechnology-2",
		icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/technology/bi-tech-biomass-reprocessing-2.png",
		icon_size = 256,
		icon_mipmaps = 4,
		prerequisites = { "bi-tech-advanced-biotechnology", "production-science-pack" },
		effects = {
			{ type = "unlock-recipe", recipe = "bi-cellulose-2" },
			{ type = "unlock-recipe", recipe = "bi-battery" },
			{ type = "unlock-recipe", recipe = "bi-biomass-3" },
			{ type = "unlock-recipe", recipe = "bi-bio-reactor-3" },
		},
		unit = {
			count = 250,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "production-science-pack", 1 },
			},
			time = 30,
		},
	},
})
