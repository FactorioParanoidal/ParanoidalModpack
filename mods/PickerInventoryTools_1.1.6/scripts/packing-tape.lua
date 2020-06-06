--[[
    "name": "packing-tape",
    "title": "Packing Tape",
    "author": "calcwizard",
    "description": "Mining a chest or wagon allows players to pick it up with all the items inside and carry it in their inventory. Now supports cars!"
--]]
local Event = require('__stdlib__/stdlib/event/event')
local Inventory = require('__stdlib__/stdlib/entity/inventory')

if script.active_mods['packing-tape'] then
    return
end

local setting = settings.get_startup('picker-moveable-chests')

local chest_types = {
    ['container'] = defines.inventory.chest,
    ['logistic-container'] = defines.inventory.chest,
    ['cargo-wagon'] = defines.inventory.cargo_wagon
}

local function inventory_to_container(event)
    local stack = event.stack
    local chest = event.created_entity
    if chest_types[chest.type] and stack and stack.valid_for_read and stack.name:find('^picker%-moveable%-') then
        local source = event.stack.get_inventory(defines.inventory.item_main)
        local destination = chest.get_inventory(chest_types[chest.type])

        Inventory.transfer_inventory(source, destination)
        local data = global.inventory_chest[stack.item_number]
        if data then
            if data.bar then
                destination.set_bar(data.bar)
            end
            local proto = chest.prototype
            if proto.logistic_mode == 'storage' then
                chest.storage_filter = data.storage_filter
            elseif proto.logistic_mode == 'requester' or proto.logistic_mode == 'buffer' then
                for slot, filter in pairs(data.request_slots or {}) do
                    chest.set_request_slot(filter, slot)
                end
                chest.request_from_buffers = data.request_from_buffers
            end
        end
        global.inventory_chest[stack.item_number] = nil
    end
end

-- Move the contents from the chest into an item in our inventory
local function container_to_inventory(event)
    local chest = event.entity
    local item_name = 'picker-moveable-' .. chest.name
    if chest_types[chest.type] and game.item_prototypes[item_name] then
        if chest.has_items_inside() then
            local player = game.get_player(event.player_index)
            local p_inv = player.get_main_inventory()

            -- Is there an empty inventory spot?
            local stack = p_inv.find_empty_stack(item_name)

            -- Should have stack since we can insert but check anyway.
            if stack and stack.set_stack(item_name) then
                stack.health = chest.get_health_ratio()
                local proto = chest.prototype

                local source = chest.get_inventory(defines.inventory.chest)
                local dest = stack.get_inventory(defines.inventory.item_main)
                Inventory.transfer_inventory(source, dest)

                global.inventory_chest = global.inventory_chest or {}
                global.inventory_chest[stack.item_number] = {}
                local data = global.inventory_chest[stack.item_number]

                data.bar = source.supports_bar() and source.get_bar()
                data.storage_filter = proto.logistic_mode == 'storage' and chest.storage_filter
                local requester = proto.logistic_mode == 'requester' or proto.logistic_mode == 'buffer'
                if requester then
                    data.request_slots = {}
                    for i = 1, chest.request_slot_count do
                        data.request_slots[i] = chest.get_request_slot(i)
                    end
                    data.request_from_buffers = chest.request_from_buffers
                end

                chest.destroy({raise_destroy = true})
            end
        end
    end
end

Event.register_if(setting, defines.events.on_built_entity, inventory_to_container)
Event.register_if(setting, defines.events.on_pre_player_mined_item, container_to_inventory)
