require("prototypes.tips-and-tricks.tips-and-tricks") -- подсказки

-- Register early so research/evolution and compatibility mods see both labs.
data:extend(table.deepcopy(require("prototypes.super-labs-beta8")))

-- new entities
require("prototypes.entity.bio-content")
require("prototypes.entity.offshore-pumps")
require("prototypes.pumpjacks-1_1") -- Недостающая нефтяная вышка MK4, до фильтруемых копий.
require("prototypes.seafloor-pumps.data") -- донные насосы I–III Beta 8, электрические
require("prototypes.entity.battery-electric-train")
require("prototypes.entity.flame-car")
require("prototypes.entity.concrete-brick")
require("prototypes.entity.artillery-prototype")

-- new items
require("prototypes.item.storage-migration")
require("prototypes.item.mining-drill-bit")
require("prototypes.item.structured-components")
require("prototypes.item.electronics")
require("prototypes.item.bio-content")
require("prototypes.item.offshore-pumps")
require("prototypes.item.battery-electric-train")
require("prototypes.item.flame-car")
require("prototypes.item.artillery-prototype")
require("prototypes.item.concrete-brick")
require("prototypes.item.gear-dies")

-- new recipies
require("prototypes.recipe.warehouses")
require("prototypes.recipe.chemistry")
require("prototypes.recipe.manganese-chrome-platinum-sorting")
require("prototypes.recipe.mining-drill-bit")
require("prototypes.recipe.electronics")
require("prototypes.recipe.structured-components")
require("prototypes.recipe.science-packs")
require("prototypes.recipe.bio-content")
require("prototypes.recipe.offshore-pumps")
require("prototypes.recipe.battery-electric-train")
require("prototypes.recipe.flame-car")
require("prototypes.recipe.artillery-prototype")
require("prototypes.recipe.glass")
require("prototypes.recipe.concrete-brick")
require("prototypes.recipe.stone")
require("prototypes.recipe.ammo-pistol")
require("prototypes.recipe.metallurgy")

-- new technologies
require("prototypes.technology.offshore-pumps")
require("prototypes.technology.battery-electric-train")
require("prototypes.technology.flame-car")
require("prototypes.technology.artillery-prototype")
require("prototypes.technology.alien-artifacts")
require("prototypes.technology.angels-alloys-smelting")
require("prototypes.technology.angels-ironworks")
require("prototypes.technology.bio-advanced-biotechnology-2")

-- new selection-tools
require("prototypes.selection-tool.heroturrets")

-- new subgroups
require("prototypes.subgroups.angels-subgroups")

-- new recipe categories
require("prototypes.recipe-category.alloy-mixing-tiers")

-- tweaks
require("tweaks.custom.angelsmods")

-- Normalize retired fluid IDs before Quality generates recycling recipes.
require("tweaks.recipe.sulfuric-acid-early")
