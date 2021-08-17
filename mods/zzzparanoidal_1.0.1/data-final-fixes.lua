require("prototypes.assemblers")
require("prototypes.nuclear")
require("prototypes.techfixes")
require("prototypes.change-background")
require("prototypes.warfare")
require("prototypes.recipefixes")
require("prototypes.pipes")
require("prototypes.map-gen-presets")
require("prototypes.boiler-effectivity")

if mods="angelsindustries" then
require("prototypes.techfixes-angelsIndustries")
end -- при наличии angelsIndustries

require("prototypes.tile-concrete-brick-fix") --фикс tile для бетонного кирпича
require("prototypes.artillery-prototype.artillery-turret-prototype-final-fix") --фикс добавляющий прототип арты в обычную арту

require("recipes.gemfix")

if mods="yuoki" then
require("prototypes.yuoki")
end -- при наличии yuoki

--должно быть последним. После всех рецептов.
require("recipes.flowfix")