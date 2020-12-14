--[[
    "name": "packing-tape",
    "title": "Packing Tape",
    "author": "calcwizard",
    "description": "Mining a chest or wagon allows players to pick it up with all the items inside and carry it in their inventory. Now supports cars!"
--]] --
-- Create item-with-inventory for container types
-- If other mods do not want their chest to be packable just add
-- not_inventory_moveable = true
-- to the prototype definition.
local Data = require('__stdlib__/stdlib/data/data')
local Entity = require('__stdlib__/stdlib/data/entity')
local Item = require('__stdlib__/stdlib/data/item')
local Table = require('__stdlib__/stdlib/utils/table')

if mods['packing-tape'] or not settings.get_startup('picker-moveable-chests') then return end

local chest_types = {'container', 'logistic-container'}

local skip_chests = Data.Unique_Array.dictionary{
    'bait-chest', 'compilatron-chest', 'crash-site-chest-1', 'crash-site-chest-2', 'big-ship-wreck-1',
    'big-ship-wreck-2', 'big-ship-wreck-3', 'red-chest', 'blue-chest', 'compi-logistics-chest', 'infinity-cargo-wagon',
    'railloader-chest', 'railunloader-chest'
}

Data{name = 'picker-moveable', type = 'item-subgroup', group = 'other'}

local default = Item('wooden-chest', 'item')
local count = 0

for _, container_type in pairs(chest_types) do
    for _, container in Entity:pairs(container_type, {silent = true}) do
        if not (skip_chests[container.name] or container.not_inventory_moveable) then
            local item = container:is_player_placeable() and container:get_minable_item()
            if item and item:is_valid() then
                Item{
                    name = 'picker-moveable-' .. container.name,
                    type = 'item-with-inventory',
                    place_result = container.name,
                    subgroup = 'picker-moveable',
                    icon = item.icon or (not item.icons and default.icon) or nil,
                    icons = Table.deep_copy(item.icons or default.icons or nil) or nil,
                    icon_size = item.icon_size or default.icon_size,
                    icon_mipmaps = item.icon_mipmaps or default.icon_mipmaps,
                    localised_name = {'item-name.picker-moveable', {'entity-name.' .. container.name}},
                    stack_size = 1,
                    flags = {'hidden', 'not-stackable'},
                    inventory_size = container.inventory_size,
                    order = 'z[picker-moveable]-' .. (container.order or ''),
                    insertion_priority_mode = 'never'
                }
                count = count + 1
            end
        end
    end
end
__DebugAdapter.print('Created ' .. count .. ' moveable chests.')
