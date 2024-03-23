-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

local triggers = {}

-- Bob's Assembling Machines
triggers.assembly = {
    burner_assembling_machine_is_small = reskins.lib.setting("bobmods-assembly-burner"),
    entities = reskins.lib.check_scope("entities", "bobs", "bobassembly"),
    equipment = reskins.lib.check_scope("equipment", "bobs", "bobassembly"),
    items = reskins.lib.check_scope("items-and-fluids", "bobs", "bobassembly"),
    technologies = reskins.lib.check_scope("technologies", "bobs", "bobassembly"),
}

-- Bob's Greenhouse
triggers.greenhouse = {
    entities = reskins.lib.check_scope("entities", "bobs", "bobgreenhouse"),
    equipment = reskins.lib.check_scope("equipment", "bobs", "bobgreenhouse"),
    items = reskins.lib.check_scope("items-and-fluids", "bobs", "bobgreenhouse"),
    technologies = reskins.lib.check_scope("technologies", "bobs", "bobgreenhouse"),
}

-- Bob's Electronics
triggers.electronics = {
    entities = reskins.lib.check_scope("entities", "bobs", "bobelectronics"),
    equipment = reskins.lib.check_scope("equipment", "bobs", "bobelectronics"),
    items = reskins.lib.check_scope("items-and-fluids", "bobs", "bobelectronics"),
    technologies = reskins.lib.check_scope("technologies", "bobs", "bobelectronics"),
}

-- Bob's Enemies
triggers.enemies = {
    entities = reskins.lib.check_scope("entities", "bobs", "bobenemies"),
    equipment = reskins.lib.check_scope("equipment", "bobs", "bobenemies"),
    items = reskins.lib.check_scope("items-and-fluids", "bobs", "bobenemies"),
    technologies = reskins.lib.check_scope("technologies", "bobs", "bobenemies"),
}

-- Bob's Equipment
triggers.equipment = {
    entities = reskins.lib.check_scope("entities", "bobs", "bobequipment"),
    equipment = reskins.lib.check_scope("equipment", "bobs", "bobequipment"),
    items = reskins.lib.check_scope("items-and-fluids", "bobs", "bobequipment"),
    technologies = reskins.lib.check_scope("technologies", "bobs", "bobequipment"),
}

-- Bob's Logistics
triggers.logistics = {
    entities = reskins.lib.check_scope("entities", "bobs", "boblogistics"),
    equipment = reskins.lib.check_scope("equipment", "bobs", "boblogistics"),
    items = reskins.lib.check_scope("items-and-fluids", "bobs", "boblogistics"),
    technologies = reskins.lib.check_scope("technologies", "bobs", "boblogistics"),
}

-- Bob's Mining
triggers.mining = {
    entities = reskins.lib.check_scope("entities", "bobs", "bobmining"),
    equipment = reskins.lib.check_scope("equipment", "bobs", "bobmining"),
    items = reskins.lib.check_scope("items-and-fluids", "bobs", "bobmining"),
    technologies = reskins.lib.check_scope("technologies", "bobs", "bobmining"),
}

-- Bob's Modules
triggers.modules = {
    entities = reskins.lib.check_scope("entities", "bobs", "bobmodules"),
    equipment = reskins.lib.check_scope("equipment", "bobs", "bobmodules"),
    items = reskins.lib.check_scope("items-and-fluids", "bobs", "bobmodules"),
    technologies = reskins.lib.check_scope("technologies", "bobs", "bobmodules"),
}

-- Bob's Metals, Chemicals, and Intermediates
triggers.plates = {
    entities = reskins.lib.check_scope("entities", "bobs", "bobplates"),
    equipment = reskins.lib.check_scope("equipment", "bobs", "bobplates"),
    items = reskins.lib.check_scope("items-and-fluids", "bobs", "bobplates"),
    technologies = reskins.lib.check_scope("technologies", "bobs", "bobplates"),
}

-- Bob's Ores
triggers.ores = {
    entities = reskins.lib.check_scope("entities", "bobs", "bobores"),
    equipment = reskins.lib.check_scope("equipment", "bobs", "bobores"),
    items = reskins.lib.check_scope("items-and-fluids", "bobs", "bobores"),
    technologies = reskins.lib.check_scope("technologies", "bobs", "bobores"),
}

-- Bob's Power
triggers.power = {
    entities = reskins.lib.check_scope("entities", "bobs", "bobpower"),
    equipment = reskins.lib.check_scope("equipment", "bobs", "bobpower"),
    items = reskins.lib.check_scope("items-and-fluids", "bobs", "bobpower"),
    technologies = reskins.lib.check_scope("technologies", "bobs", "bobpower"),

    -- Fetch bobpower settings
    accumulators = reskins.lib.setting("bobmods-power-accumulators"),
    poles = reskins.lib.setting("bobmods-power-poles"),
    steam = reskins.lib.setting("bobmods-power-steam"),
    fluidgenerator = reskins.lib.setting("bobmods-power-fluidgenerator"),
    heatsources = reskins.lib.setting("bobmods-power-heatsources"),
    nuclear = reskins.lib.setting("bobmods-power-nuclear"),
    solar = reskins.lib.setting("bobmods-power-solar"),
}

-- Bob's Revamp
triggers.revamp = {
    entities = reskins.lib.check_scope("entities", "bobs", "bobrevamp"),
    equipment = reskins.lib.check_scope("equipment", "bobs", "bobrevamp"),
    items = reskins.lib.check_scope("items-and-fluids", "bobs", "bobrevamp"),
    technologies = reskins.lib.check_scope("technologies", "bobs", "bobrevamp"),
}

-- Bob's Technology
triggers.technology = {
    entities = reskins.lib.check_scope("entities", "bobs", "bobtech"),
    equipment = reskins.lib.check_scope("equipment", "bobs", "bobtech"),
    items = reskins.lib.check_scope("items-and-fluids", "bobs", "bobtech"),
    technologies = reskins.lib.check_scope("technologies", "bobs", "bobtech"),
}

-- Bob's Vehicle Equipment
triggers.vehicle_equipment = {
    entities = reskins.lib.check_scope("entities", "bobs", "bobvehicleequipment"),
    equipment = reskins.lib.check_scope("equipment", "bobs", "bobvehicleequipment"),
    items = reskins.lib.check_scope("items-and-fluids", "bobs", "bobvehicleequipment"),
    technologies = reskins.lib.check_scope("technologies", "bobs", "bobvehicleequipment"),
}

-- Bob's Warfare
triggers.warfare = {
    entities = reskins.lib.check_scope("entities", "bobs", "bobwarfare"),
    equipment = reskins.lib.check_scope("equipment", "bobs", "bobwarfare"),
    items = reskins.lib.check_scope("items-and-fluids", "bobs", "bobwarfare"),
    technologies = reskins.lib.check_scope("technologies", "bobs", "bobwarfare"),
}

-- aai-industry is optionally dependent on angelsrefining and will perform final edits to the burner assembling machine
if mods["aai-industry"] and mods["angelsrefining"] then
    triggers.assembly.burner_assembling_machine_is_small = false
end

return triggers