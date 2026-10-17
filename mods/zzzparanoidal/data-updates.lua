
require("tweaks.custom.bobtech-prerequisite-guards").restore(paralib.bobtech_original_remove_prerequisite)
paralib.bobtech_original_remove_prerequisite = nil

require("tweaks.recipe.clowns-thermonuclear-bomb")

require("tweaks.recipe.angels-components") -- Сюда складывать все рецепты из группы (item-group) = angels-components
require("tweaks.recipe.angels-power") -- Сюда складывать все рецепты из группы (item-group) = angels-power
require("tweaks.recipe.production") -- Сюда складывать все рецепты из группы (item-group) = production

-- Агрегатор точки росы: восемь выходов Beta 8 вместо двух проходных assembler-pipe-passthrough.
if appmod and appmod.blacklist then
	appmod.blacklist["dpa"] = true
end

-- Длины подземных лент и труб: на data-updates, чтобы show-max-underground-distance (data-final-fixes) читал финал
require("tweaks.entity.underground-belt-distance")
require("tweaks.entity.underground-pipe-distance")
require("tweaks.entity.reskins-beta8-assembler-tiers")
-- Зарядники BET: свой graphics_set у каждого, до лампочек BottleneckLite в data-final-fixes.
require("tweaks.entity.battery-electric-train-chargers")
-- T5 после оформления Reskins и до генерации рангов Hero.
require("prototypes.entity.plasma-turret-5")
require("prototypes.item.plasma-turret-5")
require("prototypes.recipe.plasma-turret-5")
require("prototypes.technology.plasma-turret-5")
require("tweaks.entity.turret-stats-1_1")
