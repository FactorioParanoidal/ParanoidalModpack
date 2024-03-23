-- Copyright (c) 2021 Kirazy
-- Part of Prismatic Belts
--
-- See LICENSE.md in the project directory for license information.

if not mods["boblogistics"] then return end

local tiers = {
    ["basic-"] = {tint = util.color("7d7d7dd1") , variant = 1, loader = "basic-", technology = "logistics-0"},
    ["turbo-"] = {tint = util.color("a510e5d1"), variant = 2, loader = "purple-", technology = "logistics-4"},
    ["ultimate-"] = {tint = util.color("16f263d1"), variant = 2, loader = "green-", technology = "logistics-5"},
}

-- Compatibility with Bob's Logistics Belt Reskin
if mods["boblogistics-belt-reskin"] then
    tiers["basic-"].tint = util.color("e7e7e7d1")
    tiers["turbo-"].tint = util.color("df1ee5d1")
end

-- Compatibility with Artisanal Reskins 1.1.3+
if mods["reskins-library"] and not (reskins.bobs and (reskins.bobs.triggers.logistics.entities == false)) then
    -- Setup standard properties
    tiers["basic-"].tier = 0
    tiers["turbo-"].tier = 4
    tiers["ultimate-"].tier = 5

    tiers["basic-"].tint = reskins.lib.belt_tint_index[0]
    tiers["turbo-"].tint = reskins.lib.belt_tint_index[4]
    tiers["ultimate-"].tint = reskins.lib.belt_tint_index[5]

    -- Check for custom colors, update tint and tier information if so
    if reskins.lib.setting("reskins-lib-customize-tier-colors") then
        tiers[""] = {tint = reskins.lib.belt_tint_index[1], variant = 1, loader = "", tier = 1, technology = "logistics"}
        tiers["fast-"] = {tint = reskins.lib.belt_tint_index[2], variant = 2, loader = "fast-", tier = 2, technology = "logistics-2"}
        tiers["express-"] = {tint = reskins.lib.belt_tint_index[3], variant = 2, loader = "express-", tier = 3, technology = "logistics-3"}
    end

    -- Compatibility with Artisanal Reskins 2.0.0+
    if prismatic_belts.migration.is_version_or_newer(mods["reskins-library"], "2.0.0") then
        for _, properties in pairs(tiers) do
            properties.use_reskin_process = true
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
        local icons = prismatic_belts.transport_belt_icon(properties.tint, properties.use_reskin_process)

        -- Append tier labels for reskins-library
        if mods["reskins-library"] and not (reskins.bobs and (reskins.bobs.triggers.logistics.entities == false)) then
                reskins.lib.append_tier_labels(properties.tier, {icon = icons, tier_labels = reskins.lib.setting("reskins-bobs-do-belt-entity-tier-labeling") and true or false})

                reskins.lib.assign_icons(prefix.."transport-belt", {icon = icons, icon_picture = prismatic_belts.transport_belt_picture(properties.tint, properties.use_reskin_process), make_icon_pictures = true})
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
            entity.belt_animation_set = prismatic_belts.transport_belt_animation_set({mask_tint = properties.tint, variant = properties.variant, use_reskin_process = properties.use_reskin_process})
        end
    end

    -- Setup remnants
    if entities.belt then
        prismatic_belts.create_remnant(prefix.."transport-belt", {mask_tint = properties.tint})
    end

    -- Setup logistics technologies
    local technology = data.raw["technology"][properties.technology]

    if technology then
        technology.icons = prismatic_belts.logistics_technology_icon({mask_tint = properties.tint, use_reskin_process = properties.use_reskin_process})
    end
end