--[[
    "name": "packing-tape",
    "title": "Packing Tape",
    "author": "calcwizard",
    "description": "Mining a chest or wagon allows players to pick it up with all the items inside
                    and carry it in their inventory. Now supports cars!"
--]] --
local Event = require('__stdlib__/stdlib/event/event')
local Inventory = require('__stdlib__/stdlib/entity/inventory')

local key = 'picker-moveable-chests'
if script.active_mods['packing-tape'] or not settings["startup"][key] and settings["startup"][key].value then return end

local chests = {['container'] = defines.inventory.chest, ['logistic-container'] = defines.inventory.chest}

local function clean_up_awaiting(ret_val)
    global.awaiting.data.main_inv.destroy()
    global.awaiting = nil
    return ret_val
end

do -- Loading code
    local function load_inventory(event)
        if not (event.stack and event.stack.valid_for_read) then return end

        local stack_id = event.stack.name:find('^picker%-moveable%-') and event.stack.item_number
        if not stack_id then return end

        local data = global.inventory_chest[stack_id]
        if not data then return end

        local chest = event.created_entity
        local source = event.stack.get_inventory(defines.inventory.item_main)
        local destination = chest.get_inventory(defines.inventory.chest)
        Inventory.transfer_inventory(source, destination)

        if data.bar then destination.set_bar(data.bar) end

        local prototype = chest.prototype
        if prototype.logistic_mode == 'storage' then
            chest.storage_filter = data.storage_filter
        elseif prototype.logistic_mode == 'requester' or prototype.logistic_mode == 'buffer' then
            for slot, filter in pairs(data.request_slots or {}) do chest.set_request_slot(filter, slot) end
            chest.request_from_buffers = data.request_from_buffers
        end

        global.inventory_chest[stack_id] = nil
    end

    Event.register(defines.events.on_built_entity, load_inventory)
end

do -- Saving Code
    -- Save item-with-inventory-data
    -- These are handled by replacing the normal item in the mined buffer
    local function save_inventory_data(event)
        local chest = event.entity

        if not chests[chest.type] then return end

        local player = game.get_player(event.player_index)
        if not player.get_main_inventory().find_empty_stack() then return end

        local item_name = 'picker-moveable-' .. chest.name
        if not game.item_prototypes[item_name] then return end

        local source = chest.get_inventory(defines.inventory.chest)
        if source.is_empty() and not source.is_filtered() then return end

        local data = {}
        data.main_inv = game.create_inventory(1)

        local stack = data.main_inv[1]
        stack.set_stack(item_name)
        stack.health = chest.get_health_ratio()

        local dest = stack.get_inventory(defines.inventory.item_main)
        Inventory.transfer_inventory(source, dest)
        local prototype = chest.prototype
        data.bar = source.supports_bar() and source.get_bar()
        data.storage_filter = prototype.logistic_mode == 'storage' and chest.storage_filter
        local requester = prototype.logistic_mode == 'requester' or prototype.logistic_mode == 'buffer'
        if requester then
            data.request_slots = {}
            for i = 1, chest.request_slot_count do data.request_slots[i] = chest.get_request_slot(i) end
            data.request_from_buffers = chest.request_from_buffers
        end
        global.awaiting = {entity = chest, data = data}
    end
    Event.register(defines.events.on_pre_player_mined_item, save_inventory_data)

    local function awaiting_mined_entity(event)
        if not global.awaiting then return end

        if not (event.entity == global.awaiting.entity) then return clean_up_awaiting(false) end

        -- First item in the buffer should be the chest item
        local stack = event.buffer[1]
        if not (stack and stack.valid_for_read) then return clean_up_awaiting(false) end

        -- First item in the script inventory will be the item-with-inventory-data
        stack.set_stack(global.awaiting.data.main_inv[1])

        global.inventory_chest[stack.item_number] = global.awaiting.data
        return clean_up_awaiting(true)
    end
    Event.register(defines.events.on_player_mined_entity, awaiting_mined_entity)
end

Event.on_init(function()
    global.inventory_chest = {}
end)

Event.on_configuration_changed(function()
    global.inventory_chest = global.inventory_chest or {}
end)
