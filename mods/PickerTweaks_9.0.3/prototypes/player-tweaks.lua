local Data = require('__stdlib__/stdlib/data/data')
local character = Data('character', 'character')

--(( Starting inventory size ))--
local inv_size = settings.startup['picker-inventory-size'].value
--Modify character inventory size
if character.inventory_size < inv_size then
    character.inventory_size = inv_size
end

--(( Reacher ))--
character.build_distance = settings.startup['picker-reacher-build-distance'].value
character.reach_distance = settings.startup['picker-reacher-reach-distance'].value
character.reach_resource_distance = settings.startup['picker-reacher-reach-resource-distance'].value
character.drop_item_distance = settings.startup['picker-reacher-drop-item-distance'].value
character.loot_pickup_distance = settings.startup['picker-reacher-loot-pickup-distance'].value
character.item_pickup_distance = settings.startup['picker-reacher-item-pickup-distance'].value
