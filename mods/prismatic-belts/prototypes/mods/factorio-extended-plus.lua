-- Copyright (c) 2021 Kirazy
-- Part of Prismatic Belts
--
-- See LICENSE.md in the project directory for license information.

if not mods["FactorioExtended-Plus-Transport"] then return end

local tiers = {
    ["mk1"] = {tint = util.color("2cd529d1"), technology = "logistics-4"},
    ["mk2"] = {tint = util.color("9a2cc9d1"), technology = "logistics-5"},
}

-- Setup all the entities to use the updated belt animation sets
for tier, properties in pairs(tiers) do
    -- Fetch entities
    local entities = {
        belt = data.raw["transport-belt"]["rapid-transport-belt-"..tier],
        splitter = data.raw["splitter"]["rapid-splitter-"..tier],
        underground = data.raw["underground-belt"]["rapid-transport-belt-to-ground-"..tier],
        loader = data.raw["loader"]["rapid-"..tier.."-loader"],

        -- Miniloader
        miniloader = data.raw["loader-1x1"]["rapid-"..tier.."-miniloader-loader"],
        filter_miniloader = data.raw["loader-1x1"]["rapid-"..tier.."-filter-miniloader-loader"],

        -- Deadlock Stacking Beltboxes and Compact loaders
        deadlock_loader = data.raw["loader-1x1"]["rapid-transport-belt-"..tier.."-loader"]
    }

    -- Reskin the belt item
    local belt_item = data.raw["item"]["rapid-transport-belt-"..tier]
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
            entity.belt_animation_set = prismatic_belts.transport_belt_animation_set({mask_tint = properties.tint, 2})
        end
    end

    -- Setup remnants
    if entities.belt then
        prismatic_belts.create_remnant("rapid-transport-belt-"..tier, {mask_tint = properties.tint})
    end

    -- Setup logistics technologies
    local technology = data.raw["technology"][properties.technology]

    if technology then
        technology.icons = prismatic_belts.logistics_technology_icon({mask_tint = properties.tint})
    end
end