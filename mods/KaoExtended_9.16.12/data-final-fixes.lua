if not kaoextended then kaoextended = {} end
if not kaoextended.settingoveride then kaoextended.settingoverride = {} end
kaoextended.settingsoveride = settings.startup["kaoextended-overide"].value

for _, bot in pairs(data.raw["construction-robot"]) do
	bot.resistances = bot.resistances or {}
	table.insert(bot.resistances, {type = "fire", percent = 100})
end

require("prototypes.alien-artifact")
require("prototypes.override_machine")
require("prototypes.override_item")
require("prototypes.morestack")

--require("library.technology")
--require("library.recipe")

require("prototypes.advtech.item")
require("prototypes.advtech.recipe")
require("prototypes.advtech.override_recipe")

require("prototypes.structurecomponents.item")
require("prototypes.structurecomponents.override")

require("prototypes.mining-drill-bit.item")
require("prototypes.mining-drill-bit.override")

require("prototypes.recipes.UsedCoolant")

--require("prototypes.angelextended.slag")
require("prototypes.angelextended.angelsbioprocessing")
require("prototypes.angelextended.angelssmelting")

require("prototypes.technology")

require("prototypes.projectiles")
require("prototypes.pyramid")

require("prototypes.Mining_fluids_903")
require("prototypes.Manganese_chrome_platinum_sorting")
--require("prototypes.Manganese_chrome_sorting_0172")
--require("prototypes.Platinum_sorting_172")
require("prototypes.LandmineGridlock_102")
require("prototypes.BlackTrainSmokeRevised010")
require("prototypes.BobLogisticZoneExpanderRadius010")
require("prototypes.custom_production_ui_100")


require("prototypes.item-fuelvalue")
require("prototypes.chest-gfx")
require("prototypes.labs-gfx")

