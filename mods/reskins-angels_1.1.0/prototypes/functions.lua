-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Add this mod to the reskins function host.
if not reskins.angels then reskins.angels = {} end
reskins.angels.triggers = require("triggers")
reskins.angels.directory = "__reskins-angels__"
reskins.angels.constants = {
    recipe_corner_shift = {-10, -10},
    recipe_corner_scale = 0.4375,
}

-- Maybe we'll use this one day?...
local function copy_icon(destination_name, destination_type, source_name, source_type)
    -- Fetch source and desination pointers
    local source = data.raw[source_type]
    local destination = data.raw[destination_type]

    -- Validate pointers
    if not (source and destination) then return end

    -- Duplicate the icon
    if source.icons then
        destination.icons = util.copy(source.icons)
    elseif source.icon then
        destination.icon = util.copy(source.icon)
    else
        return -- Fundamentally broken source definitions
    end

    -- Copy root-level properties
    destination.icon_size = source.icon_size
    destination.icon_mipmaps = source.icon_mipmaps
end

-- Fetch angels numerical tier icons, return an icon_extras table
local number_tints = {
    ["petrochem"] = util.color("ffffff1a"),
    ["smelting"] = util.color("ffcc0080"),
}

function reskins.angels.num_tier(tier, mod)
    return
    {
        {
            icon = "__angelsrefining__/graphics/icons/num_"..tier..".png",
            icon_size = 32,
            icon_mipmaps = 1,
            tint = angelsmods[mod].number_tint,
            scale = 0.32,
            shift = {-12, -12},
        }
    }
end

-- Connecting north/south oriented pipe shadow overlay
function reskins.angels.vertical_pipe_shadow(shift)
    return
    {
        filename = reskins.angels.directory.."/graphics/entity/common/pipe-patches/vertical-pipe-shadow-patch.png",
        priority = "high",
        width = 64,
        height = 64,
        repeat_count = 36,
        draw_as_shadow = true,
        shift = shift,
        hr_version = {
            filename = reskins.angels.directory.."/graphics/entity/common/pipe-patches/hr-vertical-pipe-shadow-patch.png",
            priority = "high",
            width = 128,
            height = 128,
            repeat_count = 36,
            draw_as_shadow = true,
            shift = shift,
            scale = 0.5,
        }
    }
end