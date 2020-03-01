--- EVENTS ---

script.on_event({defines.events.on_entity_settings_pasted},
    function(e)
        local player = game.players[e.player_index]
        local playerInventory = player.get_main_inventory()
        
        -- check if functionality is enabled
        if not player.mod_settings["kajacx_copy-paste-modules_enable"].value then
            return -- do nothing
        end
    
        local source = e.source
        local target = e.destination
        if not source or not target then
            return
        end
    
        local sourceInventory = source.get_module_inventory()
        local targetInventory = target.get_module_inventory()
        if not sourceInventory or not targetInventory then
            return
        end
        
        local messagePosition = {x = target.position.x, y = target.position.y}
        local soundPlayed = false
        
        -- before start, remove existing logistic request
        local targetRequests = target.surface.find_entities_filtered({
            area = {{target.position.x - 0.01, target.position.y - 0.01}, {target.position.x + 0.01, target.position.y + 0.01}},
            name = "item-request-proxy",
            force = player.force
        })
        for _,request in pairs(targetRequests) do
            if request.proxy_target == target then
                request.destroy()
            end
        end
        
        -- first, precompute the "diff", positive number indicates direction from player to target
        local diff = {}
        for name,count in pairs(sourceInventory.get_contents()) do
            diff[name] = count
        end
        for name,count in pairs(targetInventory.get_contents()) do
            if diff[name] then
                diff[name] = diff[name] - count
            else
                diff[name] = -count
            end
        end
        
        -- then, only move items from target to player so that space is avaliable later
        for name,count in pairs(diff) do
            if count < 0 then
                local moved = playerInventory.insert({name = name, count = -count}) -- first insert items to player in case their inventory is full
                if moved > 0 then
                    targetInventory.remove({name = name, count = moved}) -- target will always be able to remove the items
                    target.surface.create_entity({ -- show floating text message
                        name = "flying-text",
                        position = messagePosition,
                        text = {"message.kajacx_copy-paste-modules_items-added", moved, game.item_prototypes[name].localised_name, playerInventory.get_item_count(name)}
                    })
                    messagePosition.y = messagePosition.y - 0.5
                    if not soundPlayed then
                        player.play_sound({path = "utility/inventory_move"})
                        soundPlayed = true
                    end
                end
                if moved < -count then
                    player.print({"message.kajacx_copy-paste-modules_no-inventory-space", game.item_prototypes[name].localised_name})
                    -- TODO: localized message
                end
            end
        end
        
        -- next, move items from player to target
        local missing = {}
        for name,count in pairs(diff) do
            if count > 0 then
                local taken = playerInventory.remove({name = name, count = count}) -- take items from player
                if taken > 0 then
                    local given = targetInventory.insert({name = name, count = taken}) -- put items to target
                    if given > 0 then
                        target.surface.create_entity({ -- show floating text message
                            name = "flying-text",
                            position = messagePosition,
                            text = {"message.kajacx_copy-paste-modules_items-removed", given, game.item_prototypes[name].localised_name, playerInventory.get_item_count(name)}
                        })
                        messagePosition.y = messagePosition.y - 0.5
                        if not soundPlayed then
                            player.play_sound({path = "utility/inventory_move"})
                            soundPlayed = true
                        end
                    end
                    if given < taken then -- target inventory too full
                        playerInventory.insert({name = name, count = (taken - given)}) -- return items to player if target inventory is full
                    end
                end
                if taken < count then -- player is missing items in their inventory
                    missing[name] = count - taken
                end
            end
        end
        
        -- finally, create logistic request in the target entity
        if next(missing) ~= nil and player.mod_settings["kajacx_copy-paste-modules_enable-request"].value then
            local freeSlots = 0
            for i = 1,#targetInventory,1 do
                if not targetInventory[i].valid_for_read then
                    freeSlots = freeSlots + 1
                end
            end
            if freeSlots > 0 then
                local request = {} -- fill from missing to request as long as there are free slots avaliable
                for name,count in pairs(missing) do
                    if count < freeSlots then
                        request[name] = count
                        freeSlots = freeSlots - count
                    else
                        request[name] = freeSlots
                        break
                    end
                end
                target.surface.create_entity
                {
                    name = "item-request-proxy",
                    position = target.position,
                    force = player.force,
                    target = target,
                    modules = request,
                    raise_built = true
                }
            end
        end
    end
)


--- UPDATE LOOP ---

