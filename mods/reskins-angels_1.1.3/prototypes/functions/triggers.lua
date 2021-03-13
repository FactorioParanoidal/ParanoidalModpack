-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

local triggers = {}

-- Angel's Bioprocessing
triggers.bioprocessing = {
    entities = reskins.lib.check_scope("entities", "angels", "angelsbioprocessing"),
    equipment = reskins.lib.check_scope("equipment", "angels", "angelsbioprocessing"),
    items = reskins.lib.check_scope("items-and-fluids", "angels", "angelsbioprocessing"),
    technologies = reskins.lib.check_scope("technologies", "angels", "angelsbioprocessing"),
}

-- Angel's Exploration
triggers.exploration = {
    entities = reskins.lib.check_scope("entities", "angels", "angelsexploration"),
    equipment = reskins.lib.check_scope("equipment", "angels", "angelsexploration"),
    items = reskins.lib.check_scope("items-and-fluids", "angels", "angelsexploration"),
    technologies = reskins.lib.check_scope("technologies", "angels", "angelsexploration"),
}

-- Angel's Industries
triggers.industries = {
    entities = reskins.lib.check_scope("entities", "angels", "angelsindustries"),
    equipment = reskins.lib.check_scope("equipment", "angels", "angelsindustries"),
    items = reskins.lib.check_scope("items-and-fluids", "angels", "angelsindustries"),
    technologies = reskins.lib.check_scope("technologies", "angels", "angelsindustries"),
}

-- Angel's Petrochem
triggers.petrochem = {
    entities = reskins.lib.check_scope("entities", "angels", "angelspetrochem"),
    equipment = reskins.lib.check_scope("equipment", "angels", "angelspetrochem"),
    items = reskins.lib.check_scope("items-and-fluids", "angels", "angelspetrochem"),
    technologies = reskins.lib.check_scope("technologies", "angels", "angelspetrochem"),
}

-- Angel's Refining
triggers.refining = {
    entities = reskins.lib.check_scope("entities", "angels", "angelsrefining"),
    equipment = reskins.lib.check_scope("equipment", "angels", "angelsrefining"),
    items = reskins.lib.check_scope("items-and-fluids", "angels", "angelsrefining"),
    technologies = reskins.lib.check_scope("technologies", "angels", "angelsrefining"),
}

-- Angel's Smelting
triggers.smelting = {
    entities = reskins.lib.check_scope("entities", "angels", "angelssmelting"),
    equipment = reskins.lib.check_scope("equipment", "angels", "angelssmelting"),
    items = reskins.lib.check_scope("items-and-fluids", "angels", "angelssmelting"),
    technologies = reskins.lib.check_scope("technologies", "angels", "angelssmelting"),
}

-- Angel's Addons - Mobility
triggers.mobility = {
    entities = reskins.lib.check_scope("entities", "angels", "angelsaddons-mobility"),
    equipment = reskins.lib.check_scope("equipment", "angels", "angelsaddons-mobility"),
    items = reskins.lib.check_scope("items-and-fluids", "angels", "angelsaddons-mobility"),
    technologies = reskins.lib.check_scope("technologies", "angels", "angelsaddons-mobility"),
}

-- Angel's Addons - Storage
triggers.storage = {
    entities = reskins.lib.check_scope("entities", "angels", "angelsaddons-storage"),
    equipment = reskins.lib.check_scope("equipment", "angels", "angelsaddons-storage"),
    items = reskins.lib.check_scope("items-and-fluids", "angels", "angelsaddons-storage"),
    technologies = reskins.lib.check_scope("technologies", "angels", "angelsaddons-storage"),
}

-- Mad Clown's Compatibility
triggers.mad_clowns = {
    is_active = mods["Clowns-AngelBob-Nuclear"] and true or mods["Clowns-Extended-Minerals"] and true or mods["Clowns-Nuclear"] and true or mods["Clowns-Processing"] and true or mods["Clowns-Science"] and true or false
}

return triggers