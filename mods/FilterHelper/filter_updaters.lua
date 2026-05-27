local fh_util = require("fh_util")

local function get_storage_inventory(entity)
    local inventory = entity.get_output_inventory()
    if inventory then
        return inventory
    end
    for _, inventory_type in pairs { "chest", "car_trunk", "cargo_wagon", "spider_trunk" } do
        inventory = entity.get_inventory(defines.inventory[inventory_type])
        if inventory then
            return inventory
        end
    end
end

local function update_filter_slot(entity, slot, clicked_item)
    local effective_type = fh_util.get_effective_type(entity)
    local filter_to_set = effective_type == "mining-drill" and clicked_item.name or clicked_item
    entity.set_filter(slot, filter_to_set)

    if effective_type == "inserter" and settings.global["fh-set-filter-on-inserter"].value then
        entity.use_filters = true
    end
end

local filtered_inventory_updater = {
    condition = function(entity)
        local inventory = get_storage_inventory(entity)
        return inventory and inventory.supports_filters()
    end,
    button_description = { "fh.tooltip-container-filters" },
    get_active_items = function(entity)
        local inventory = get_storage_inventory(entity)
        local active_items = {}
        for i = 1, #inventory do
            fh_util.add_item_to_table(active_items, inventory.get_filter(i))
        end
        return active_items
    end,
    add = function(entity, clicked_item, modifiers)
        local inventory = get_storage_inventory(entity)
        if modifiers.shift and not modifiers.control then
            for i = 1, #inventory do
                if not inventory.get_filter(i) and inventory[i].valid_for_read and fh_util.is_same_item({ name = inventory[i].name, quality = inventory[i].quality.name }, clicked_item) then
                    inventory.set_filter(i, clicked_item)
                end
            end
            return
        end
        if modifiers.control and not modifiers.shift then
            for i = 1, #inventory do
                if not inventory.get_filter(i) and (not inventory[i].valid_for_read or fh_util.is_same_item(inventory[i], clicked_item)) then
                    inventory.set_filter(i, clicked_item)
                end
            end
            return
        end
        if modifiers.control and modifiers.shift then
            for i = 1, #inventory do
                inventory.set_filter(i, clicked_item)
            end
            return
        end
        local found_index
        for i = 1, #inventory do
            if not inventory.get_filter(i) then
                if inventory[i].valid_for_read then
                    if fh_util.is_same_item(inventory[i], clicked_item) then
                        found_index = i
                        break
                    end
                elseif not found_index then
                    found_index = i
                end
            end
        end
        if found_index then
            inventory.set_filter(found_index, clicked_item)
            return
        end
        return { "fh.filters-full" }
    end,
    remove = function(entity, clicked_item, modifiers)
        local inventory = get_storage_inventory(entity)
        local found_index
        if modifiers.shift or modifiers.control then
            for i = 1, #inventory do
                if fh_util.is_same_item(inventory.get_filter(i), clicked_item) then
                    inventory.set_filter(i, nil)
                end
            end
            return
        end
        for i = #inventory, 1, -1 do
            if fh_util.is_same_item(inventory.get_filter(i), clicked_item) then
                if not inventory[i].valid_for_read then
                    found_index = i
                    break
                elseif not found_index then
                    found_index = i
                end
            end
        end
        if found_index then
            inventory.set_filter(found_index, nil)
            return
        end
        return { "fh.filters-empty" }
    end,
}

local function find_section(entity)
    for _, section in pairs(entity.get_logistic_point(defines.logistic_member_index.logistic_container).sections) do
        if section.is_manual then
            return section
        end
    end
end

local logistic_chest_updater = {
    condition = function(entity)
        if fh_util.get_effective_type(entity) ~= "logistic-container" then
            return false
        end
        local logistic_mode = fh_util.get_effective_prototype(entity).logistic_mode
        return logistic_mode == "buffer" or logistic_mode == "requester"
    end,
    button_description = { "fh.tooltip-requests" },
    get_active_items = function(entity)
        local active_items = {}
        local found_section = find_section(entity)
        if not found_section then
            return active_items
        end
        for _, filter in pairs(found_section.filters) do
            local value = filter.value
            if value and (value.type == "item" or not value.type) then
                fh_util.add_item_to_table(active_items, value)
            end
        end
        return active_items
    end,
    add = function(entity, clicked_item, modifiers)
        local found_section = find_section(entity)
        if not found_section then
            return
        end
        local found_filter
        local new_filters = found_section.filters
        for _, filter in pairs(new_filters) do
            local value = filter.value
            if value then
                if fh_util.is_same_item(value, clicked_item) then
                    found_filter = filter
                    break
                end
            elseif not found_filter then
                found_filter = filter
            end
        end
        local stack_size = prototypes.item[clicked_item.name].stack_size
        local found_count = (found_filter and found_filter.min) or 0
        local amount_to_set = found_count + stack_size
        if modifiers.shift then
            amount_to_set = found_count + 5 * stack_size
        end
        if modifiers.control then
            amount_to_set = stack_size * fh_util.get_effective_prototype(entity).get_inventory_size(defines.inventory.chest, entity.quality)
        end
        if found_filter then
            found_filter.min = amount_to_set
            found_filter.value = { name = clicked_item.name, quality = clicked_item.quality }
        else
            table.insert(new_filters, {
                value = { name = clicked_item.name, quality = clicked_item.quality },
                min = amount_to_set,
            })
        end
        found_section.filters = new_filters
        return
    end,
    remove = function(entity, clicked_item, modifiers)
        local found_section = find_section(entity)
        if not found_section then
            return
        end
        local stack_size = prototypes.item[clicked_item.name].stack_size
        local amount_to_remove = stack_size
        if modifiers.shift then
            amount_to_remove = 5 * stack_size
        end
        local new_filters = found_section.filters
        for _, filter in pairs(new_filters) do
            local value = filter.value
            if value and fh_util.is_same_item(value, clicked_item) then
                local new_count = filter.min - amount_to_remove
                if new_count > 0 and not modifiers.control then
                    filter.min = new_count
                else
                    for v in pairs(filter) do
                        filter[v] = nil
                    end
                end
                found_section.filters = new_filters
                return
            end
        end
        return { "fh.requests-empty" }
    end,
}

local one_filter_updater = {
    condition = function(entity)
        return entity.filter_slot_count == 1 and fh_util.get_effective_type(entity) ~= "infinity-container"
    end,
    button_description = { "fh.tooltip-filters" },
    get_active_items = function(entity)
        local active_items = {}
        local filter = entity.get_filter(1)
        fh_util.add_item_to_table(active_items, filter)
        return active_items
    end,
    add = function(entity, clicked_item)
        update_filter_slot(entity, 1, clicked_item)
    end,
    remove = function(entity, clicked_item)
        entity.set_filter(1, nil)
    end,
}

local many_filters_updater = {
    condition = function(entity)
        return entity.filter_slot_count > 1 and fh_util.get_effective_type(entity) ~= "infinity-container"
    end,
    button_description = { "fh.tooltip-filters" },
    get_active_items = function(entity)
        local active_items = {}
        for i = 1, entity.filter_slot_count do
            fh_util.add_item_to_table(active_items, entity.get_filter(i))
        end
        return active_items
    end,
    add = function(entity, clicked_item)
        local found_slot
        for i = 1, entity.filter_slot_count do
            local found_filter = entity.get_filter(i)
            if found_filter then
                if fh_util.is_same_item(found_filter, clicked_item) then
                    return
                end
            elseif not found_slot then
                found_slot = i
            end
        end
        if found_slot then
            update_filter_slot(entity, found_slot, clicked_item)
            return
        end
        return { "fh.filters-full" }
    end,
    remove = function(entity, clicked_item)
        for i = 1, entity.filter_slot_count do
            local filter = entity.get_filter(i)
            if filter and fh_util.is_same_item(filter, clicked_item) then
                entity.set_filter(i, nil)
                return
            end
        end
        return { "fh.filters-empty" }
    end,
}

local splitter_filter_updater = {
    condition = function(entity)
        local effective_type = fh_util.get_effective_type(entity)
        return effective_type == "splitter" or effective_type == "lane-splitter"
    end,
    button_description = { "fh.tooltip-filters" },
    get_active_items = function(entity)
        local active_items = {}
        fh_util.add_item_to_table(active_items, entity.splitter_filter)
        return active_items
    end,
    add = function(entity, clicked_item)
        entity.splitter_filter = { name = clicked_item.name, quality = clicked_item.quality }
        if entity.splitter_output_priority == "none" then
            local outputs = entity.belt_neighbours.outputs
            if #outputs == 1 then
                local vec_x = outputs[1].position.x - entity.position.x
                local vec_y = outputs[1].position.y - entity.position.y
                local on_right = (
                    (entity.direction == defines.direction.north and vec_x > 0) or
                    (entity.direction == defines.direction.south and vec_x < 0) or
                    (entity.direction == defines.direction.east and vec_y > 0) or
                    (entity.direction == defines.direction.west and vec_y < 0)
                )
                entity.splitter_output_priority = on_right and "left" or "right"
            else
                entity.splitter_output_priority = "left"
            end
        end
    end,
    remove = function(entity, clicked_item)
        entity.splitter_filter = nil
    end,
}

return function(entity)
    for _, updater in pairs { logistic_chest_updater, filtered_inventory_updater, many_filters_updater, one_filter_updater, splitter_filter_updater } do
        if updater.condition(entity) then
            return {
                get_active_items = function()
                    return updater.get_active_items(entity)
                end,
                add = function(clicked_item, modifiers)
                    return updater.add(entity, clicked_item, modifiers)
                end,
                remove = function(clicked_item, modifiers)
                    return updater.remove(entity, clicked_item, modifiers)
                end,
                button_description = updater.button_description
            }
        end
    end
end
