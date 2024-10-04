require("prototypes.assemblers")
require("prototypes.nuclear")
require("prototypes.techfixes")
require("prototypes.change-background")
require("prototypes.warfare")
require("prototypes.recipefixes")
require("prototypes.pipes")
require("prototypes.map-gen-presets")
require("prototypes.boiler-effectivity")
require("prototypes.bobfix")

if mods["angelsindustries"] then
    require("prototypes.techfixes-angelsIndustries")
end -- при наличии angelsIndustries

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
require("graphics.ore_radar.ore_radar_reskin") -- рескин радара руды
-------------------------------------------------------------------------------------------------
require("prototypes.micro-final-fix") --доработка напильником всего подряд -- фиксы от Кирика
-------------------------------------------------------------------------------------------------
require("prototypes.entity.entity") --фиксы неправильных имён от SEO
-------------------------------------------------------------------------------------------------
--фиксы совместимости для модов
require("prototypes.mod_compatibility.Transport_Drones")
require("prototypes.mod_compatibility.JunkTrain")

-------------------------------------------------------------------------------------------------
require("prototypes.Angels_RBOS") --Angels_RBOS Angel's Re-enabled Basic Ore Smelting
-------------------------------------------------------------------------------------------------
require("prototypes.offshore-pump.animation") --анимация для новых насосов
require("prototypes.offshore-pump.offshore-final-fix") --финальные фиксы для новых насосов
-------------------------------------------------------------------------------------------------
require("prototypes.landfill-pump") --Установка насосов на отсыпку
-------------------------------------------------------------------------------------------------
require("recipes.poles") --Изменение рецептов ЛЭП
-------------------------------------------------------------------------------------------------
if mods["yuoki"] then
    require("prototypes.yuoki")
end -- при наличии yuoki

-- Uniform recipe mod
for _,r in pairs(data.raw["recipe"]) do
	r.always_show_products=true;
	r.show_amount_in_title=false;
	if r.normal ~= nil then
  		r.normal.always_show_products = true;
  		r.normal.show_amount_in_title = false;
	end
	if r.expensive ~= nil then
 	 	r.expensive.always_show_products = true;
  		r.expensive.show_amount_in_title = false;
	end
end
-- Uniform recipe end

--должно быть последним. После всех рецептов.
require("recipes.flowfix")