-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

local item_groups = {
    ["bob-logistics"] = {related_item_group = "logistics"},
    ["bob-fluid-products"] = {},
    ["bob-resource-products"] = {},
    ["bob-intermediate-products"] = {related_item_group = "intermediate-products"},
    ["bob-gems"] = {},
}

local function assign_item_group_icon(name)
    local item_group = data.raw["item-group"][name]

    -- Validate the item_group
    if item_group then else return end

    -- Assign the revised UI icons
    item_group.icon = reskins.bobs.directory.."/graphics/item-group/"..name..".png"
    item_group.icon_size = 128
    item_group.icon_mipmaps = 0
end

for name, params in pairs(item_groups) do
    -- Check if the group(s) exist(s), if not, skip this iteration
    if params.related_item_group then
        if (data.raw["item-group"][name] and data.raw["item-group"][params.related_item_group]) then
            assign_item_group_icon(name)
            assign_item_group_icon(params.related_item_group)
        end
    else
        if data.raw["item-group"][name] then
            assign_item_group_icon(name)
        end
    end
end