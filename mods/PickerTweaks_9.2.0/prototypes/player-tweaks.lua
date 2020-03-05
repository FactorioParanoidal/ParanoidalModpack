local Data = require('__stdlib__/stdlib/data/data')
local player = Data('character', 'character')

--(( Starting inventory size ))--
local inv_size = settings.startup['picker-inventory-size'].value
--Modify player inventory size
if player.inventory_size < inv_size then
    player.inventory_size = inv_size
end

--(( Reacher ))--
player.build_distance = settings.startup['picker-reacher-build-distance'].value
player.reach_distance = settings.startup['picker-reacher-reach-distance'].value
player.reach_resource_distance = settings.startup['picker-reacher-reach-resource-distance'].value
player.drop_item_distance = settings.startup['picker-reacher-drop-item-distance'].value
player.loot_pickup_distance = settings.startup['picker-reacher-loot-pickup-distance'].value
player.item_pickup_distance = settings.startup['picker-reacher-item-pickup-distance'].value
