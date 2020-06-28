-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Settings to disable select Reskins by mod
if mods["bobassembly"] then
    data:extend(
    {
        {
            type = "bool-setting",
            name = "reskins-bobs-do-bobassembly",
            setting_type = "startup",
            default_value = true,
        },
        {
            type = "bool-setting",
            name = "reskins-bobs-do-furnace-tier-labeling",
            setting_type = "startup",
            order = "x",
            default_value = true,
        },
    })
end

if mods["bobgreenhouse"] then
    data:extend(
    {
        {
            type = "bool-setting",
            name = "reskins-bobs-do-bobgreenhouse",
            setting_type = "startup",
            default_value = true,
        }
    })
end

if mods["boblogistics"] or mods["bobpower"] then
    data:extend(
    {
        {
            type = "bool-setting",
            name = "reskins-bobs-do-pipe-tier-labeling",
            setting_type = "startup",
            order = "x",
            default_value = true,
        }
    })
end

if mods["boblogistics"] then
    data:extend(
    {
        {
            type = "bool-setting",
            name = "reskins-bobs-do-boblogistics",
            setting_type = "startup",
            default_value = true,
        },
        {
            type = "bool-setting",
            name = "reskins-bobs-do-belt-entity-tier-labeling",
            setting_type = "startup",
            order = "x",
            default_value = true,
        },
        {
            type = "bool-setting",
            name = "reskins-bobs-do-inserter-tier-labeling",
            setting_type = "startup",
            order = "xx",
            default_value = true,
        },
        {
            type = "bool-setting",
            name = "reskins-bobs-do-inserter-filter-symbol",
            setting_type = "startup",
            order = "xx",
            default_value = true,
        },
        {
            type = "bool-setting",
            name = "reskins-bobs-flip-stack-inserter-icons",
            setting_type = "startup",
            order = "xx",
            default_value = false,
        },
        {
            type = "bool-setting",
            name = "reskins-bobs-do-basic-belts-separately",
            setting_type = "startup",
            order = "y",
            default_value = true,
        },
        {
            type = "string-setting",
            name = "reskins-bobs-basic-belts-color",
            setting_type ="startup",
            order = "yy",
            default_value = "bfbfbf",
        }
    })
end

if mods["bobmining"] then
    data:extend(
    {
        {
            type = "bool-setting",
            name = "reskins-bobs-do-bobmining",
            setting_type = "startup",
            default_value = true,
        }
    })
end

if mods["bobmodules"] then
    data:extend(
    {
        {
            type = "bool-setting",
            name = "reskins-bobs-do-bobmodules",
            setting_type = "startup",
            default_value = true,
        }
    })
end

if mods["bobplates"] then
    data:extend(
    {
        {
            type = "bool-setting",
            name = "reskins-bobs-do-bobplates",
            setting_type = "startup",
            default_value = true,
        }
    })
end

if mods["bobpower"] then
    data:extend(
    {
        {
            type = "bool-setting",
            name = "reskins-bobs-do-bobpower",
            setting_type = "startup",
            default_value = true,
        },
        {
            type = "bool-setting",
            name = "reskins-bobs-hydrazine-is-blue",
            setting_type = "startup",
            default_value = true,
        }
    })
end

if mods["bobrevamp"] then
    data:extend(
    {
        {
            type = "bool-setting",
            name = "reskins-bobs-do-bobrevamp",
            setting_type = "startup",
            default_value = true,
        }
    })
end

if mods["bobtech"] then
    data:extend(
    {
        {
            type = "bool-setting",
            name = "reskins-bobs-do-bobtech",
            setting_type = "startup",
            default_value = true,
        }
    })
end

if mods["bobwarfare"] then
    data:extend(
    {
        {
            type = "bool-setting",
            name = "reskins-bobs-do-bobwarfare",
            setting_type = "startup",
            default_value = true,
        }
    })
end