local function on_pre_player_crafted_item(e)
    -- prevent stack overflow
    if storage.busy_queueing then return nil end

    local player      = game.players[e.player_index]
    local save_queue  = {}
    local front_craft = nil

    if #player.crafting_queue == 1 then return nil end

    if not storage.queue_to_front then
        storage.queue_to_front = {}
    end
    if storage.queue_to_front[e.player_index] then
        -- temporarily increase inventory size to prevent dumping
        local old_size = player.character_inventory_slots_bonus
        player.character_inventory_slots_bonus = 10 * old_size + 5000 -- pretty arbitrary expansion but will work 99% of the time

        local crafting_queue_progress = 0
        local first_item_in_queue = player.crafting_queue[1]
        local last_item_in_queue = player.crafting_queue[#player.crafting_queue]
        if first_item_in_queue.recipe == last_item_in_queue.recipe then
            crafting_queue_progress = player.crafting_queue_progress
        end

        -- remove everything from queue
        local first = true
        while player.crafting_queue do
            local queue_length = #player.crafting_queue
            local ind = player.crafting_queue[queue_length].index
            local rec = player.crafting_queue[queue_length].recipe
            local cou = player.crafting_queue[queue_length].count

            if queue_length > settings.global["qtfl_queue_limit"].value then
                player.print({ 'qtf-message.queue-too-large' }, { r = 0.8, g = 0.1, b = 0.1 })
                player.cancel_crafting({ index = ind, count = cou })
                player.character_inventory_slots_bonus = old_size
                return
            end

            -- errout if queue is too large (we have to do this because the API restricts index to 65535)
            if ind > 65535 or cou > 65535 then
                player.print({ 'qtf-message.queue-too-large' }, { r = 1.0, g = 0.1, b = 0.1 })
                player.character_inventory_slots_bonus = old_size
                return
            end

            if first then
                first = false
                front_craft = { recipe = rec, count = cou }
            else
                table.insert(save_queue, { recipe = rec, count = cou })
            end
            player.cancel_crafting({ index = ind, count = cou })
        end

        storage.busy_queueing = true

        -- add new item
        player.begin_crafting { count = front_craft.count, recipe = front_craft.recipe, silent = true }
        if crafting_queue_progress > 0 then
            if crafting_queue_progress > 1 then crafting_queue_progress = 0.999999999999999999999 end
            player.crafting_queue_progress = crafting_queue_progress
        end

        -- add rest of queue
        for i = #save_queue, 1, -1 do
            v = save_queue[i]
            player.begin_crafting { count = v.count, recipe = v.recipe }
        end

        -- revert inventory size
        player.character_inventory_slots_bonus = old_size

        storage.busy_queueing = false
    end

    -- if queue to front not enabled, do nothing
end

local function queue_to_front(e)
    local plr = game.players[e.player_index]
    if not storage.queue_to_front then
        storage.queue_to_front = {}
    end
    if not storage.queue_to_front[e.player_index] then
        storage.queue_to_front[e.player_index] = true
        plr.print({ 'qtf-message.queue-to-front' })
    else
        storage.queue_to_front[e.player_index] = not storage.queue_to_front[e.player_index]
        plr.print({ 'qtf-message.queue-to-back' })
    end
end

local function crafting_queue_list(e)
    for _, player in pairs(game.connected_players) do
        local count = 0
        local mode = "default"
        local color = "[color=0.0,1.0,0.1]"

        if player.crafting_queue then
            count = #player.crafting_queue
        end
        if storage.queue_to_front[player.index] then
            mode = "front"
            color = "[color=1.0,0.1,0.1]"
        end

        game.print("" .. player.name .. " count=" .. count .. " mode=" .. color .. mode .. "[/color]", player.chat_color)
    end
end

local function on_init()
    storage.queue_to_front = {}
end

script.on_init(on_init)
script.on_event('queue-to-front', queue_to_front)
script.on_event(defines.events.on_pre_player_crafted_item, on_pre_player_crafted_item)

commands.add_command("crafting_queue_list", nil, crafting_queue_list)
