-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobelectronics"] then return end

-- Setup inputs
local inputs = {
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "electronics",
}

-- Setup input defaults
reskins.lib.parse_inputs(inputs)

-- Circuits

-- Bob's circuits respect "color updates", done in data updates

-- if settings.startup["bobmods-colorupdate"].value == true then
--     data.raw.item["basic-circuit-board"].icon = "__bobelectronics__/graphics/icons/colour-coded/basic-circuit-board.png"
--     data.raw.item["circuit-board"].icon = "__bobelectronics__/graphics/icons/colour-coded/circuit-board.png"
--     data.raw.item["superior-circuit-board"].icon = "__bobelectronics__/graphics/icons/colour-coded/superior-circuit-board.png"
--     data.raw.item["multi-layer-circuit-board"].icon = "__bobelectronics__/graphics/icons/colour-coded/multi-layer-circuit-board.png"
--     data.raw.item["electronic-circuit"].icon = "__bobelectronics__/graphics/icons/colour-coded/basic-electronic-circuit-board.png"
--     data.raw.item["advanced-circuit"].icon = "__bobelectronics__/graphics/icons/colour-coded/electronic-circuit-board.png"
--     data.raw.item["processing-unit"].icon = "__bobelectronics__/graphics/icons/colour-coded/electronic-logic-board.png"
--     data.raw.item["advanced-processing-unit"].icon = "__bobelectronics__/graphics/icons/colour-coded/electronic-processing-board.png"
  
--     data.raw.item["basic-circuit-board"].icon_size = 128
--     data.raw.item["circuit-board"].icon_size = 128
--     data.raw.item["superior-circuit-board"].icon_size = 128
--     data.raw.item["multi-layer-circuit-board"].icon_size = 128
--     data.raw.item["electronic-circuit"].icon_size = 128
--     data.raw.item["advanced-circuit"].icon_size = 128
--     data.raw.item["processing-unit"].icon_size = 128
--     data.raw.item["advanced-processing-unit"].icon_size = 128
--   end