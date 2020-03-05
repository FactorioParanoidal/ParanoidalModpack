--[Helper Functions]--
-- Currently mostly picker specific with plans to flesh out and add to appropriate places

local lib = {}
local Area = require('__stdlib__/stdlib/area/area')
local Position = require('__stdlib__/stdlib/area/position')

function lib.get_or_create_main_left_flow(player, flow_name)
    local main_flow = player.gui.left[flow_name .. '_main_flow']
    if not main_flow then
        main_flow =
            player.gui.left.add {
            type = 'flow',
            name = flow_name .. '_main_flow',
            direction = 'vertical',
            style = 'slot_table_spacing_vertical_flow'
        }
        main_flow.style.top_padding = 4
        main_flow.style.right_padding = 0
        main_flow.style.left_padding = 0
        main_flow.style.bottom_padding = 0
    end
    return main_flow
end

lib.ghosts = {
    ['entity-ghost'] = true,
    ['tile-ghost'] = true
}

--Return localised name, entity_prototype, and item_prototype
function lib.get_placeable_item(entity)
    local locname, ep
    if entity.name == 'entity-ghost' or entity.name == 'tile-ghost' then
        locname = entity.ghost_localised_name
        ep = entity.ghost_prototype
    else
        locname = entity.localised_name
        ep = entity.prototype
    end
    if ep and ep.mineable_properties and ep.mineable_properties.minable and ep.mineable_properties.products and ep.mineable_properties.products[1].type == 'item' then -- If the entity has mineable products.
        local ip = game.item_prototypes[ep.mineable_properties.products[1].name] -- Retrieve first available item prototype
        if ip and (ip.place_result or ip.place_as_tile_result) then -- If the entity has an item with a placeable prototype,
            return (ip.localised_name or locname), ep, ip
        end
        return locname, ep
    end
end

function lib.stack_is_ghost(stack, ghost)
    if ghost.name == 'entity-ghost' then
        return stack.prototype.place_result and stack.prototype.place_result.name == ghost.ghost_name
    elseif ghost.name == 'tile-ghost' then
        return stack.prototype.place_as_tile_result and stack.prototype.place_as_tile_result.result.name == ghost.ghost_name
    end
end

function lib.find_resources(entity)
    if entity.type == 'mining-drill' then
        local area = Position.expand_to_area(entity.position, game.entity_prototypes[entity.name].mining_drill_radius)
        local name = entity.mining_target and entity.mining_target.name or nil
        return entity.surface.count_entities_filtered {area = area, type = 'resource', name = name}
    end
    return 0
end

function lib.get_item_stack(e, name, give_free)
    local stack = e.get_main_inventory().find_item_stack(name)
    if stack then
        return stack
    end
    if e.vehicle then
        local trunk = e.vehicle.get_inventory(defines.inventory.car_trunk)
        stack = trunk and trunk.find_item_stack(name)
        if stack then
            return stack
        end
    end
    if e.is_player() and (e.cheat_mode or give_free) then
        local inv = lib.create_buffer_corpse(e).get_inventory(defines.inventory.character_corpse)
        if inv[1].set_stack(name) then
            return inv[1]
        end
    end
end

function lib.create_buffer_corpse(player, inf)
    return player.surface.create_entity {
        name = 'picker-buffer-corpse-' .. (inf and 'inf' or 'instant'),
        position = {0, 0},
        force = player.force,
        inventory_size = 1,
        player_index = player.index
    }
end

-- Attempt to insert an item_stack or array of item_stacks into the entity
-- Spill to the ground at the entity/player anything that doesn't get inserted
-- @param entity: the entity or player object
-- @param item_stacks: a SimpleItemStack or array of SimpleItemStacks to insert
-- @return bool : there was some items inserted or spilled
function lib.insert_or_spill_items(entity, item_stacks)
    local new_stacks = {}
    if item_stacks then
        if item_stacks[1] and item_stacks[1].name then
            new_stacks = item_stacks
        elseif item_stacks and item_stacks.name then
            new_stacks = {item_stacks}
        end
        for _, stack in pairs(new_stacks) do
            local name, count, health = stack.name, stack.count, stack.health or 1
            if game.item_prototypes[name] and not game.item_prototypes[name].has_flag('hidden') and stack.count > 0 then
                local inserted = entity.insert {name = name, count = count, health = health}
                if inserted ~= count then
                    entity.surface.spill_item_stack(entity.position, {name = name, count = count - inserted, health = health}, true)
                end
            end
        end
        return new_stacks[1] and new_stacks[1].name and true
    end
end

function lib.satisfy_requests(player, proxy)
    local entity

    if proxy.name == 'item-request-proxy' then
        entity = proxy.proxy_target
    elseif Area(proxy.selection_box):size() > 0 then
        proxy =
            proxy.surface.find_entities_filtered {
            name = 'item-request-proxy',
            area = proxy.selection_box
        }[1]
        entity = proxy and proxy.proxy_target
    end

    if proxy and entity then
        local pinv = player.get_main_inventory()
        local new_requests = {}
        local pos = Position.increment(entity.position, 0, -0.35)
        for name, count in pairs(proxy.item_requests) do
            local removed = player.cheat_mode and count or (entity and entity.can_insert(name) and pinv.remove({name = name, count = count})) or 0
            if removed > 0 then
                entity.insert({name = name, count = removed})
                local txt = {'', -removed, ' ', {'item-name.' .. name}, ' (' .. player.get_item_count(name) .. ')'}
                player.create_local_flying_text {
                    text = txt,
                    position = pos(),
                    color = defines.color.white
                }
            end
            local balance = count - removed
            new_requests[name] = balance > 0 and balance or nil
        end
        proxy.item_requests = new_requests
    end
end

function lib.get_planner(player, planner, label)
    local found
    local inventory = player.get_main_inventory()
    for i = 1, #inventory do
        local slot = inventory[i]
        if slot.valid_for_read then
            if slot.name == planner then
                if slot.is_blueprint then
                    if not slot.is_blueprint_setup() then
                        found = slot
                    elseif (label and slot.is_blueprint_setup() and slot.label and slot.label:find(label)) then
                        if player.cursor_stack.swap_stack(slot) then
                            return player.cursor_stack
                        end
                    end
                elseif game.item_prototypes[planner] then
                    if player.cursor_stack.swap_stack(slot) then
                        return player.cursor_stack
                    end
                end
            elseif planner == 'repair-tool' and slot.type == 'repair-tool' then
                if player.cursor_stack.swap_stack(slot) then
                    return player.cursor_stack
                end
            end
        end
    end
    if found and player.cursor_stack.swap_stack(found) then
        return player.cursor_stack
    else
        return planner and game.item_prototypes[planner] and player.cursor_stack.set_stack(planner) and player.cursor_stack
    end
end

local function _matches_options(slot, options)
    local matches = false
    if options.is_blueprint_setup then
        matches = slot.is_blueprint and slot.is_blueprint_setup()
    end
    if options.is_blueprint_not_setup then
        matches = slot.is_blueprint and not slot.is_blueprint_setup()
    end
    if options.label then
        matches = slot.is_item_with_label and slot.label and slot.label:find(options.label)
    end
    if options.is_deconstruction_setup then
        matches = slot.is_deconstruction_item and (#slot.entity_filters > 0 or #slot.tile_filters > 0)
    end
    if options.is_deconstruction_not_setup then
        matches = slot.is_deconstruction_item and (#slot.entity_filters == 0 and #slot.tile_filters == 0)
    end
    return matches
end

-- Return the "inventory slot" where the item is found
function lib.find_item_in_inventory(item_name, inventory, options)
    options = options or {}
    local found

    for i = 1, #inventory, 1 do
        local slot = inventory[i]
        if slot.valid_for_read and slot.name == item_name and (not options or _matches_options(slot, options)) then
            found = slot
            break
        end
    end
    if found then
        return found
    end

end

function lib.set_or_swap_item(player, slot, item, set)
    if type(item) == "string" then
        return (set and slot.set_stack(item)) or (player.clean_cursor() and slot.set_stack(item))
    end
    return item and ((set and slot.set_stack(item)) or (player.clean_cursor() and slot.swap_stack(item) or slot.set_stack(item)))
end


return lib
