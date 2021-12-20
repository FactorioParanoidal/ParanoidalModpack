if not ASE then ASE = {} end
if not ASE.functions then ASE.functions = {} end
if not ASE.tables then ASE.tables = {} end
require("prototypes.alloys-category-extended")
require("prototypes.data-tables")

angelsmods.trigger.smelting_products["steel"].powder = true -- enforce steel powder on for molds
if mods["boblogistics"] and mods["bobplates"] then
    angelsmods.trigger.smelting_products["copper"].powder = true -- enforce copper powder on for pipe-casting
end

require("prototypes.items.compression-extended")
require("prototypes.items.ironworks")
require("prototypes.items.shielding")
require("prototypes.items.stacks")
require("prototypes.items.alloys-extended")

require("prototypes.recipes.compressing-extended")
require("prototypes.recipes.ironworks")
require("prototypes.recipes.shielding")
require("prototypes.recipes.stacks")
require("prototypes.recipes.smelting-alloys-extended")

require("prototypes.technology.smelting-extended")