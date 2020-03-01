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

require("prototypes.recipes.UsedCoolant")

--require("prototypes.angelextended.slag")
--require("prototypes.angelextended.bio")

require("prototypes.technology")

require("prototypes.projectiles")