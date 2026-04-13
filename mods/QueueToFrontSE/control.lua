script.on_init(function()
    if not storage.queue_to_front then
        storage.queue_to_front = {}
    end
end)

script.on_event('queue-to-front', function(event)
    local plr = game.players[event.player_index]
    if not storage.queue_to_front then
        storage.queue_to_front = {}
    end
    if not storage.queue_to_front[event.player_index] then
        storage.queue_to_front[event.player_index] = true
        plr.print({'qtf-message.queue-to-front'})
    else
        storage.queue_to_front[event.player_index] = not storage.queue_to_front[event.player_index]
        plr.print({'qtf-message.queue-to-back'})
    end
end)

script.on_event(defines.events.on_pre_player_crafted_item, function(event)
    if storage.busy_queueing then return end
    local plr = game.players[event.player_index]
    local save_queue = {}
    local front_craft = nil
    if not storage.queue_to_front then
        storage.queue_to_front = {}
    end
    if storage.queue_to_front[event.player_index] then
        local old_size = plr.character_inventory_slots_bonus
        plr.character_inventory_slots_bonus = 10 * old_size + 5000
        local first = true
        while plr.crafting_queue do
            local ind = plr.crafting_queue[#plr.crafting_queue].index
            local rec = plr.crafting_queue[#plr.crafting_queue].recipe
            local cou = plr.crafting_queue[#plr.crafting_queue].count
            if ind > 65535 or cou > 65535 then
                plr.print({'qtf-message.queue-too-large'}, {r = 1, g = 0.1, b = 0.1})
                plr.character_inventory_slots_bonus = old_size
                return
            end
            if first then
                first = false
                front_craft = {recipe = rec, count = cou}
            else
                table.insert(save_queue, {recipe = rec, count = cou})
            end
            plr.cancel_crafting({index = ind, count = cou})
        end
        storage.busy_queueing = true
        plr.begin_crafting{count = front_craft.count, recipe = front_craft.recipe, silent = true}
        for i = #save_queue, 1, -1 do
            local v = save_queue[i]
            plr.begin_crafting{count = v.count, recipe = v.recipe}
        end
        plr.character_inventory_slots_bonus = old_size
        storage.busy_queueing = false
    end
end)
