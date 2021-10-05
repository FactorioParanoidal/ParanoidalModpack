require("prototypes.assemblers")
require("prototypes.nuclear")
require("prototypes.techfixes")
require("prototypes.change-background")
require("prototypes.warfare")
require("prototypes.recipefixes")
require("prototypes.pipes")
require("prototypes.map-gen-presets")
require("prototypes.boiler-effectivity")

if mods["angelsindustries"] then
    require("prototypes.techfixes-angelsIndustries")
end -- при наличии angelsIndustries

if mods["angelsbioprocessing"] then
	require("prototypes.modules")
end -- при наличии angelsbioprocessing

require("prototypes.tile-concrete-brick-fix") --фикс tile для бетонного кирпича
require("prototypes.artillery-prototype.artillery-turret-prototype-final-fix") --фикс добавляющий прототип арты в обычную арту

require("recipes.gemfix")
require("recipes.warehousing")
require("recipes.module-contactfix")

require("prototypes.stone-pipe-fix") --фикс скрывающий каменные трубы (tnx KiRiK)
require("prototypes.walkable-beacons") -- по маякам можно ходить, код из walkable-beacons

require("prototypes.micro-final-fix") --доработка напильником всего подряд -- фиксы от Кирика


if mods["yuoki"] then
    require("prototypes.yuoki")
end -- при наличии yuoki

--должно быть последним. После всех рецептов.
require("recipes.flowfix")