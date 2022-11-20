-- Copyright (c) 2021 Kirazy
-- Part of Prismatic Belts
--
-- See LICENSE.md in the project directory for license information.

if not mods["UltimateBelts"] then return end

local tiers = {
    ["ultra-fast-"] = {tint = util.color("00b30cff")},
    ["extreme-fast-"] = {tint = util.color("e00000ff")},
    ["ultra-express-"] = {tint = util.color("3604b5e8")},
    ["extreme-express-"] = {tint = util.color("002bffff")},
    ["ultimate-"] = {tint = util.color("00ffddd1")},
    ["original-ultimate-"] = {tint = util.color("00ffddd1")},
}

-- Setup all the entities to use the updated belt animation sets
for prefix, properties in pairs(tiers)do
    -- Fetch entities
    local entities = {
        belt = data.raw["transport-belt"][prefix.."belt"],
        splitter = data.raw["splitter"][prefix.."splitter"],
        underground = data.raw["underground-belt"][prefix.."underground-belt"],

        -- Miniloader
        miniloader = data.raw["loader-1x1"]["ub-"..prefix.."miniloader-loader"],
        filter_miniloader = data.raw["loader-1x1"]["ub-"..prefix.."filter-miniloader-loader"],

        -- Deadlock Stacking Beltboxes and Compact loaders
        deadlock_loader = data.raw["loader-1x1"][prefix.."belt-loader"]
    }

    -- Reskin the belt item
    local belt_item = data.raw["item"][prefix.."belt"]
    if belt_item then
        belt_item.icons = {
            {
                icon = "__prismatic-belts__/graphics/icons/standard/ultimate-transport-belt-icon.png",
                icon_size = 64,
                icon_mipmaps = 4,
                tint = prismatic_belts.adjust_alpha(properties.tint, 1),
            },
        }

        -- Update entity icon to match
        if entities.belt then
            entities.belt.icons = belt_item.icons
        end
    end

    -- Reskin all related entity types
    for _, entity in pairs(entities) do
        if entity then
            entity.belt_animation_set = prismatic_belts.transport_belt_animation_set({base_tint = util.color("404040"), mask_tint = properties.tint, variant = 2, brighten_arrows = true})
        end
    end

    -- Setup remnants
    if entities.belt then
        prismatic_belts.create_remnant(prefix.."belt", {base_tint = util.color("404040"), mask_tint = properties.tint, brighten_arrows = true})
    end

    -- Setup logistics technologies
    local technology = data.raw["technology"][prefix.."logistics"]

    if technology then
        technology.icons = prismatic_belts.logistics_technology_icon({base_tint = util.color("404040"), mask_tint = properties.tint})
    end
end