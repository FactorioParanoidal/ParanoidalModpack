-- Copyright (c) 2021 Kirazy
-- Part of Prismatic Belts
--
-- See LICENSE.md in the project directory for license information.

-- Setup belt animation sets for vanilla entities
local belt_animation_sets = {
    ["transport-belt"] = {
        animation_set = {
            filename = "__prismatic-belts__/graphics/entity/base/transport-belt/transport-belt.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            frame_count = 16,
            direction_count = 20,
            hr_version = {
                filename = "__prismatic-belts__/graphics/entity/base/transport-belt/hr-transport-belt.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5,
                frame_count = 16,
                direction_count = 20
            }
        }
    },
    ["fast-transport-belt"] = {
        animation_set = {
            filename = "__prismatic-belts__/graphics/entity/base/fast-transport-belt/fast-transport-belt.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            frame_count = 32,
            direction_count = 20,
            hr_version = {
                filename = "__prismatic-belts__/graphics/entity/base/fast-transport-belt/hr-fast-transport-belt.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5,
                frame_count = 32,
                direction_count = 20
            }
        }
    },
    ["express-transport-belt"] = {
        animation_set = {
            filename = "__prismatic-belts__/graphics/entity/base/express-transport-belt/express-transport-belt.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            frame_count = 32,
            direction_count = 20,
            hr_version = {
                filename = "__prismatic-belts__/graphics/entity/base/express-transport-belt/hr-express-transport-belt.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5,
                frame_count = 32,
                direction_count = 20
            }
        }
    },
}

local tiers = {
    [""] = {},
    ["fast-"] = {},
    ["express-"] = {},
}

if mods["reskins-library"] then
    tiers[""].tier = 1
    tiers["fast-"].tier = 2
    tiers["express-"].tier = 3
end

if mods["miniloader"] then
    local chute = data.raw["loader-1x1"]["chute-miniloader-loader"]

    if chute then
        chute.belt_animation_set = belt_animation_sets["transport-belt"]
    end
end

for prefix, properties in pairs(tiers) do
    -- Fetch entities
    local entities = {
        belt = data.raw["transport-belt"][prefix.."transport-belt"],
        splitter = data.raw["splitter"][prefix.."splitter"],
        underground = data.raw["underground-belt"][prefix.."underground-belt"],
        loader = data.raw["loader"][prefix.."loader"],

        -- Miniloader
        miniloader = data.raw["loader-1x1"][prefix.."miniloader-loader"],
        filter_miniloader = data.raw["loader-1x1"][prefix.."filter-miniloader-loader"],

        -- Deadlock Stacking Beltboxes and Compact loaders
        deadlock_loader = data.raw["loader-1x1"][prefix.."transport-belt-loader"],

        -- Krastorio
        krastorio_loader = data.raw["loader-1x1"]["kr-"..prefix.."loader"],
    }

    -- Reskin the belt item
    local belt_item = data.raw["item"][prefix.."transport-belt"]
    if belt_item then
        local icons = {
            {
                icon = "__prismatic-belts__/graphics/icons/base/"..prefix.."transport-belt.png",
                icon_size = 64,
                icon_mipmaps = 4,
            }
        }

        -- Append tier labels for reskins-library
        if mods["reskins-library"] then
            reskins.lib.append_tier_labels(properties.tier, {icon = icons, tier_labels = reskins.lib.setting("reskins-bobs-do-belt-entity-tier-labeling") and true or false})

            local icon_picture = {
                filename = "__prismatic-belts__/graphics/icons/base/"..prefix.."transport-belt.png",
                size = 64,
                mipmaps = 4,
                scale = 0.25,
            }

            reskins.lib.assign_icons(prefix.."transport-belt", {icon = icons, icon_picture = icon_picture, make_icon_pictures = true})
        else
            belt_item.icons = icons
        end

        -- Update entity icon to match
        if entities.belt then
            entities.belt.icons = belt_item.icons
        end
    end

    -- Reskin all related entity types
    for _, entity in pairs(entities) do
        if entity then
            entity.belt_animation_set = belt_animation_sets[prefix.."transport-belt"]
        end
    end

    -- Setup remnants
    local remnants = data.raw["corpse"][prefix.."transport-belt-remnants"]

    if remnants then
        if entities.belt then
            remnants.icons = entities.belt.icons
            remnants.icon = entities.belt.icon
            remnants.icon_size = entities.belt.icon_size
        end
        remnants.animation = make_rotated_animation_variations_from_sheet (2, {
            filename = "__prismatic-belts__/graphics/entity/base/"..prefix.."transport-belt/remnants/"..prefix.."transport-belt-remnants.png",
            line_length = 1,
            width = 54,
            height = 52,
            frame_count = 1,
            variation_count = 1,
            axially_symmetrical = false,
            direction_count = 4,
            shift = util.by_pixel(1, 0),
            hr_version = {
                filename = "__prismatic-belts__/graphics/entity/base/"..prefix.."transport-belt/remnants/hr-"..prefix.."transport-belt-remnants.png",
                line_length = 1,
                width = 106,
                height = 102,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 4,
                shift = util.by_pixel(1, -0.5),
                scale = 0.5
            }
        })
    end
end