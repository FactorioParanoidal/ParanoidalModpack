require("prototypes.fuel")
require("prototypes.washers")
require("prototypes.seed-extractor")
angelsmods.trigger.smelting_products["cobalt"].plate = true
--новые насосы
require("prototypes/offshore-pump/item")
require("prototypes/offshore-pump/recipe")
require("prototypes/offshore-pump/technology")
require("prototypes/offshore-pump/more-offshore-pumps")
--
require("prototypes.artillery-prototype.artillery-turret-prototype") --фикс убирающий био-арту и добовляющий новую на базе обычной

require("prototypes.beltentities") --переехало из paranoidal-tweaks_0.18.34 (sbelyakov)

-- require("prototypes.micro-fix") --доработка напильником всего подряд -- фиксы от Кирика -- not reviewed
require("prototypes.recipe.glass")
require("prototypes.recipe.alien-artifacts")
require("fixes.subgroups")
require("fixes.concrete-brick")
require("standalone-extends.battery-train")
require("standalone-extends.flame-car")


require("prototypes.entity.entity") --фиксы неправильных имён от SEO
require("prototypes.recipe-new") --новые рецепты

require("prototypes.BetterAlertArrows_100") --мод BetterAlertArrows

require("prototypes.mod_compatibility.heroturrets")
-------------------------------------------------------------------------------------------------
require("prototypes.bio-content.bio-content-list") --Новый Биоконтент
-- Uniform recipe mod
for _, r in pairs(data.raw["recipe"]) do
	r.always_show_products = true
	r.show_amount_in_title = false
	if r.normal ~= nil then
		r.normal.always_show_products = true
		r.normal.show_amount_in_title = false
	end
	if r.expensive ~= nil then
		r.expensive.always_show_products = true
		r.expensive.show_amount_in_title = false
	end
end
-- Uniform recipe end
