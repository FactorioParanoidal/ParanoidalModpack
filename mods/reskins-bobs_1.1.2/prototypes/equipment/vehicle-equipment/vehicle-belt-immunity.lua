-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobvehicleequipment"] then return end

local inputs = {
    mod = "bobs",
    group = "vehicle-equipment",
    equipment_category = "utility",
    technology_icon_size = 256,
    technology_icon_mipmaps = 4,
    technology_icon_layers = 1,
    icon_name = "vehicle-belt-immunity",
    icon_filename = "__base__/graphics/icons/belt-immunity-equipment.png",
    icon_size = 64,
    icon_mipmaps = 4,
    technology_icon_extras = { reskins.lib.technology_equipment_overlay{scale = 1, is_vehicle = true} },
}

local name = "vehicle-belt-immunity-equipment"

-- Check that the technology exists, and then reskin it if so
if data.raw.technology[name] then
    reskins.lib.construct_technology_icon(name, inputs)
    reskins.lib.construct_icon(name, 0, inputs)
end
