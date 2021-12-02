-- Fallbacks
require("prototypes.recipe-builder-fallbacks")

-- Recipes
require("prototypes.recipes.bioprocessing")
require("prototypes.recipes.petrochem")
require("prototypes.recipes.refining")
require("prototypes.recipes.warehouses")

-- Overrides
require("prototypes.overrides.bioprocessing")
require("prototypes.overrides.next-upgrades")
require("prototypes.overrides.petrochem")
require("prototypes.overrides.recipes")
require("prototypes.overrides.smelting")
require("prototypes.overrides.technology")
require("prototypes.overrides.warehouses")

-- Ore crusher 4
data.raw.item["ore-crusher-4"].icons = extangels.numeral_tier({icon = "__extendedangels__/graphics/icons/ore-crusher-4.png", icon_size = 32}, 4, angelsmods.refining.number_tint)
data.raw["assembling-machine"]["ore-crusher-4"].icons = extangels.numeral_tier({icon = "__extendedangels__/graphics/icons/ore-crusher-4.png", icon_size = 32}, 4, angelsmods.refining.number_tint)

-- Tungsten carbide powder
data.raw.item["powder-tungsten-carbide"].icon = "__extendedangels__/graphics/icons/powder-tungsten-carbide-hr.png"
data.raw.item["powder-tungsten-carbide"].icon_size = 64
data.raw.item["powder-tungsten-carbide"].icon_mipmaps = 4
data.raw.recipe["tungsten-carbide-smelting-1"].icons = extangels.numeral_tier({icon = "__extendedangels__/graphics/icons/powder-tungsten-carbide-hr.png", icon_size = 64, icon_mipmaps = 4}, 1, angelsmods.smelting.number_tint)
data.raw.recipe["tungsten-carbide-smelting-2"].icons = extangels.numeral_tier({icon = "__extendedangels__/graphics/icons/powder-tungsten-carbide-hr.png", icon_size = 64, icon_mipmaps = 4}, 2, angelsmods.smelting.number_tint)
data.raw.recipe["tungsten-carbide-smelting-3"].icons = extangels.numeral_tier({icon = "__extendedangels__/graphics/icons/powder-tungsten-carbide-hr.png", icon_size = 64, icon_mipmaps = 4}, 3, angelsmods.smelting.number_tint)
data.raw.technology["angels-tungsten-carbide-smelting-1"].icon = "__extendedangels__/graphics/technology/tungsten-carbide-smelting-and-casting.png"
data.raw.technology["angels-tungsten-carbide-smelting-1"].icon_size = 256
data.raw.technology["angels-tungsten-carbide-smelting-1"].icon_mipmaps = 4
data.raw.technology["angels-tungsten-carbide-smelting-2"].icon = "__extendedangels__/graphics/technology/tungsten-carbide-smelting-and-casting.png"
data.raw.technology["angels-tungsten-carbide-smelting-2"].icon_size = 256
data.raw.technology["angels-tungsten-carbide-smelting-2"].icon_mipmaps = 4
data.raw.technology["angels-tungsten-carbide-smelting-3"].icon = "__extendedangels__/graphics/technology/tungsten-carbide-smelting-and-casting.png"
data.raw.technology["angels-tungsten-carbide-smelting-3"].icon_size = 256
data.raw.technology["angels-tungsten-carbide-smelting-3"].icon_mipmaps = 4

-- Molten copper tungsten
data.raw.fluid["liquid-molten-copper-tungsten"].icon = "__extendedangels__/graphics/icons/liquid-molten-copper-tungsten.png"
data.raw.fluid["liquid-molten-copper-tungsten"].icon_size = 64
data.raw.fluid["liquid-molten-copper-tungsten"].icon_mipmaps = 4
data.raw.recipe["copper-tungsten-smelting-1"].icons = extangels.numeral_tier({icon = "__extendedangels__/graphics/icons/liquid-molten-copper-tungsten.png", icon_size = 64, icon_mipmaps = 4}, 1, angelsmods.smelting.number_tint)
data.raw.recipe["copper-tungsten-smelting-2"].icons = extangels.numeral_tier({icon = "__extendedangels__/graphics/icons/liquid-molten-copper-tungsten.png", icon_size = 64, icon_mipmaps = 4}, 2, angelsmods.smelting.number_tint)
data.raw.technology["angels-copper-tungsten-smelting-1"].icon = "__extendedangels__/graphics/technology/copper-tungsten-smelting-and-casting.png"
data.raw.technology["angels-copper-tungsten-smelting-1"].icon_size = 256
data.raw.technology["angels-copper-tungsten-smelting-1"].icon_mipmaps = 4
data.raw.technology["angels-copper-tungsten-smelting-2"].icon = "__extendedangels__/graphics/technology/copper-tungsten-smelting-and-casting.png"
data.raw.technology["angels-copper-tungsten-smelting-2"].icon_size = 256
data.raw.technology["angels-copper-tungsten-smelting-2"].icon_mipmaps = 4