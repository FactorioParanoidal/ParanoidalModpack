-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["aai-loaders-bobs"] then return end

local loaders = {
    ["aai-boblogistics-basic-loader"] = { tier = 0 },
    ["aai-boblogistics-loader"] = { tier = 1 },
    ["aai-boblogistics-fast-loader"] = { tier = 2 },
    ["aai-boblogistics-express-loader"] = { tier = 3 },
    ["aai-boblogistics-turbo-loader"] = { tier = 4 },
    ["aai-boblogistics-ultimate-loader"] = { tier = 5 },
}

for name, map in pairs(loaders) do
    if reskins.bobs and (reskins.bobs.triggers.logistics.entities == true) then
        -- Remove the pips so that item-on-ground icon is properly generated.
        local loader = data.raw["loader-1x1"][name]
        if loader and loader.icons then
            loader.icons[4] = nil
            loader.icons[3] = nil
        end

        reskins.lib.add_tier_labels_to_entity(name, "loader-1x1", map.tier)
    end
end
