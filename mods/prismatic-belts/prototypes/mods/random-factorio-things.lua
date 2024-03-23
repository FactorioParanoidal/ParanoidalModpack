-- Copyright (c) 2021 Kirazy
-- Part of Prismatic Belts
--
-- See LICENSE.md in the project directory for license information.

if not mods["RandomFactorioThings"] then return end

local tiers = {
    ["nuclear-"] = {tint = util.color("00ff00")},
    ["plutonium-"] = {tint = util.color("00e1ffde")},
}

-- Setup all the entities to use the updated belt animation sets
for prefix, properties in pairs(tiers) do
    -- Fetch entities
    local entities = {
        belt = data.raw["transport-belt"][prefix.."transport-belt"],
        splitter = data.raw["splitter"][prefix.."splitter"],
        underground = data.raw["underground-belt"][prefix.."underground-belt"],
        loader = data.raw["loader-1x1"][prefix.."loader"],

        -- Miniloader
        miniloader = data.raw["loader-1x1"][prefix.."miniloader-loader"],
        filter_miniloader = data.raw["loader-1x1"][prefix.."filter-miniloader-loader"],

        -- Deadlock Stacking Beltboxes and Compact loaders
        deadlock_loader = data.raw["loader-1x1"][prefix.."transport-belt-loader"]
    }

    -- Reskin the belt item
    local belt_item = data.raw["item"][prefix.."transport-belt"]
    if belt_item then
        belt_item.icons = prismatic_belts.transport_belt_icon(properties.tint)

        -- Update entity icon to match
        if entities.belt then
            entities.belt.icons = belt_item.icons
        end
    end

    -- Reskin all related entity types
    for _, entity in pairs(entities) do
        if entity then
            entity.belt_animation_set = prismatic_belts.transport_belt_animation_set({mask_tint = properties.tint, variant = 2})
        end
    end

    -- Setup remnants
    if entities.belt then
        prismatic_belts.create_remnant(prefix.."transport-belt", {mask_tint = properties.tint})
    end

    -- Setup logistics technologies
    local technology = data.raw["technology"][prefix.."logistics"]

    if technology then
        technology.icons = prismatic_belts.logistics_technology_icon({mask_tint = properties.tint})
    end
end