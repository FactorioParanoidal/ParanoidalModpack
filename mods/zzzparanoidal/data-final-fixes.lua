require("prototypes.techfixes")
require("prototypes.change-background")
require("prototypes.warfare")
require("prototypes.recipefixes")
require("prototypes.pipes")
require("prototypes.map-gen-presets")
require("prototypes.boiler-effectivity")
require("prototypes.bobfix")

-- Здесь большинство вещей исчезло, так что коментирую до переработки
-- if mods["angelsindustries"] then
--     require("prototypes.techfixes-angelsIndustries")
-- end -- при наличии angelsIndustries

if mods["angelsbioprocessing"] then
	require("prototypes.modules")
end -- при наличии angelsbioprocessing

require("prototypes.artillery-prototype.artillery-turret-prototype-final-fix") --фикс добавляющий прототип арты в обычную арту

require("recipes.gemfix")
require("recipes.warehousing")
require("recipes.module-contactfix")

require("prototypes.walkable-beacons") -- по маякам можно ходить, код из walkable-beacons
-------------------------------------------------------------------------------------------------
require("graphics.train.train_reskin") -- рескин поездов
-- require("graphics.ore_radar.ore_radar_reskin") -- рескин радара руды -- mod not enabled yet
-------------------------------------------------------------------------------------------------
-- require("prototypes.micro-final-fix") --доработка напильником всего подряд -- фиксы от Кирика -- not reviewed
require("final-fixes.concrete-brick")
require("final-fixes.concrete")
require("final-fixes.pipes")
require("final-fixes.technologies")
require("final-fixes.recipies")
require("final-fixes.icons")
require("final-fixes.tweaks")
require("final-fixes.ore-nerfs")
require("final-fixes.ore-buffs")
require("final-fixes.recipe-group-tweaks")
require("final-fixes.battery-trains")
require("final-fixes.graphics")
require("final-fixes.fishes")
require("final-fixes.weapon-tweaks")
require("final-fixes.bio-mod")
require("final-fixes.metal-rolls")
-------------------------------------------------------------------------------------------------
require("prototypes.entity.entity") --фиксы неправильных имён от SEO
-------------------------------------------------------------------------------------------------
--фиксы совместимости для модов
require("prototypes.mod_compatibility.Transport_Drones")
require("prototypes.mod_compatibility.JunkTrain")

-------------------------------------------------------------------------------------------------
require("prototypes.offshore-pump.animation") --анимация для новых насосов
-------------------------------------------------------------------------------------------------
require("prototypes.landfill-pump") --Установка насосов на отсыпку
-------------------------------------------------------------------------------------------------
require("recipes.poles") --Изменение рецептов ЛЭП
-------------------------------------------------------------------------------------------------
if mods["yuoki"] then
	require("prototypes.yuoki")
end -- при наличии yuoki

-- Uniform recipe mod
for _, r in pairs(data.raw["recipe"]) do
	r.always_show_products = true
	r.show_amount_in_title = false
end
-- Uniform recipe end

-- modern factorio accept only ingredients like {type = "...", name = "...", amount=...}
-- there i convert {"...", ...} to {type = "...", name = "...", amount=...}
require("recipes.fix-ingredients-style")
--должно быть последним. После всех рецептов.
require("recipes.flowfix")

-- фикс части косяков с префиксами в рецептах angels-/bob-
require("__zzzcompability__/fixes/prefixes")
-- finall aplying of override functions
angelsmods.functions.OV.execute()
