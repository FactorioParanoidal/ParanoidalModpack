-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check if reskinning needs to be done

local triggers = {}

-- Angel's Industries
triggers.industries = {
    big_chests = reskins.lib.setting("reskins-angels-do-angelsindustries"),
}

-- Angel's Petrochem

-- Angel's Smelting

-- Angel's Addons - Mobility and related deprecated mods
triggers.mobility = {
    crawler_train = reskins.lib.setting("reskins-angels-do-angelsaddons-mobility"),
    petro_train = reskins.lib.setting("reskins-angels-do-angelsaddons-mobility"),
    smelting_train = reskins.lib.setting("reskins-angels-do-angelsaddons-mobility"),
}

-- Angel's Addons - Storage and related deprecated mods
triggers.storage = {
    warehouses = reskins.lib.setting("reskins-angels-do-angelsaddons-storage"),
    silos = reskins.lib.setting("reskins-angels-do-angelsaddons-storage"),
    pressure_tanks = reskins.lib.setting("reskins-angels-do-angelsaddons-storage"),
}

-- Mad Clown's Compatibility
triggers.mad_clowns = {
    is_active = mods["Clowns-AngelBob-Nuclear"] and true or mods["Clowns-Extended-Minerals"] and true or mods["Clowns-Nuclear"] and true or mods["Clowns-Processing"] and true or mods["Clowns-Science"] and true or false
}

return triggers