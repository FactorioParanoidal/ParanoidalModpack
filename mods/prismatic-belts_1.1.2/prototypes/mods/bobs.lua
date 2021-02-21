-- Copyright (c) 2021 Kirazy
-- Part of Prismatic Belts
--
-- See LICENSE.md in the project directory for license information.

if not mods["boblogistics"] then return end

local tiers = {
    ["basic-"] = {tint = util.color("7d7d7dd1") , variant = 1, loader = "basic-"},
    ["turbo-"] = {tint = util.color("a510e5d1"), variant = 2, loader = "purple-"},
    ["ultimate-"] = {tint = util.color("16f263d1"), variant = 2, loader = "green-"},
}

-- Compatibility with Bob's Logistics Belt Reskin
if mods["boblogistics-belt-reskin"] then
    tiers["basic-"].tint = util.color("e7e7e7d1")
    tiers["turbo-"].tint = util.color("df1ee5d1")
end

-- Compatibility with Artisanal Reskins 1.1.3+
if mods["reskins-library"] then
    tiers["basic-"].tier = 0
    tiers["turbo-"].tier = 4
    tiers["ultimate-"].tier = 5

    -- Fetch tints from Artisanal Reskins 1.1.3+
    if prismatic_belts.migration.is_newer_version("1.1.2", mods["reskins-library"]) then
        tiers["basic-"].tint = reskins.lib.belt_tint_index[0]

        -- Check for custom colors, update tint and tier information if so
        if reskins.lib.setting("reskins-lib-customize-tier-colors") then
            tiers[""] = {tint = reskins.lib.belt_tint_index[1], variant = 1, loader = "", tier = 1}
            tiers["fast-"] = {tint = reskins.lib.belt_tint_index[2], variant = 2, loader = "fast-", tier = 2}
            tiers["express-"] = {tint = reskins.lib.belt_tint_index[3], variant = 2, loader = "express-", tier = 3}
            tiers["basic-"].tint = reskins.lib.belt_tint_index[0]
            tiers["turbo-"].tint = reskins.lib.belt_tint_index[4]
            tiers["ultimate-"].tint = reskins.lib.belt_tint_index[5]
        end

    -- Compatibility with Artisanal Reskins 1.1.2
    elseif mods["reskins-bobs"] then
        tiers["basic-"].tint = reskins.lib.belt_mask_tint(reskins.bobs.basic_belt_tint)

        -- Check for custom colors, update tint and tier information if so
        if reskins.lib.setting("reskins-lib-customize-tier-colors") then
            tiers[""] = {tint = reskins.lib.belt_mask_tint(reskins.lib.tint_index["tier-"..1]), variant = 1, loader = "", tier = 1}
            tiers["fast-"] = {tint = reskins.lib.belt_mask_tint(reskins.lib.tint_index["tier-"..2]), variant = 2, loader = "fast-", tier = 2}
            tiers["express-"] = {tint = reskins.lib.belt_mask_tint(reskins.lib.tint_index["tier-"..3]), variant = 2, loader = "express-", tier = 3}
            tiers["basic-"].tint = reskins.lib.belt_mask_tint(reskins.bobs.basic_belt_tint)
            tiers["turbo-"].tint = reskins.lib.belt_mask_tint(reskins.lib.tint_index["tier-"..4])
            tiers["ultimate-"].tint = reskins.lib.belt_mask_tint(reskins.lib.tint_index["tier-"..5])
        end
    end
end

-- Setup all the entities to use the updated belt animation sets
for prefix, properties in pairs(tiers) do
    -- Fetch entities
    local entities = {
        belt = data.raw["transport-belt"][prefix.."transport-belt"],
        splitter = data.raw["splitter"][prefix.."splitter"],
        underground = data.raw["underground-belt"][prefix.."underground-belt"],
        loader = data.raw["loader"][properties.loader.."loader"],

        -- Miniloader
        miniloader = data.raw["loader-1x1"][prefix.."miniloader-loader"],
        filter_miniloader = data.raw["loader-1x1"][prefix.."filter-miniloader-loader"],

        -- Deadlock Stacking Beltboxes and Compact loaders
        deadlock_loader = data.raw["loader-1x1"][prefix.."transport-belt-loader"]
    }

    -- Reskin the belt item
    local belt_item = data.raw["item"][prefix.."transport-belt"]
    if belt_item then
        local icons = prismatic_belts.transport_belt_icon(properties.tint)

        -- Append tier labels for reskins-library
        if mods["reskins-library"] then
            reskins.lib.append_tier_labels(properties.tier, {icon = icons, tier_labels = reskins.lib.setting("reskins-bobs-do-belt-entity-tier-labeling") and true or false})

            reskins.lib.assign_icons(prefix.."transport-belt", {icon = icons, icon_picture = prismatic_belts.transport_belt_picture(properties.tint), make_icon_pictures = true})
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
            entity.belt_animation_set = prismatic_belts.transport_belt_animation_set({mask_tint = properties.tint, variant = properties.variant})
        end
    end

    -- Setup remnants
    if entities.belt then
        prismatic_belts.create_remnant(prefix.."transport-belt", {mask_tint = properties.tint})
    end
end