---Gets or makes playerdata table.
---@param player_index uint LuaPlayer index
---@return Playerdata playerdata
function get_make_playerdata(player_index)
    local playerdata = global.playerdata[player_index]

    if not playerdata then
        playerdata = {
            luaplayer=game.players[player_index],
            index=player_index,
            is_active=false,
            job={},
            logistic_requests={},
            gui={},
            options={}
        }
        global.playerdata[player_index] = playerdata
    end

    return playerdata
end

---Returns an empty request table for the given item.
---@param name string Item name
---@return Request request
function make_empty_request(name)
    return {name=name, count=0, inventory=0, logistic_request={}}
end

---Sorts a table of `Request` objects by count, in descending order.
---@param requests table<string, Request> Table of requests to be sorted
---@return Request[] requests_sorted
function sort_requests(requests)
    local requests_sorted = {}
    for _, request in pairs(requests) do table.insert(requests_sorted, request) end

    table.sort(requests_sorted, function(a, b)
        if a.count > b.count then
            return true
        elseif a.count < b.count then
            return false
        elseif a.name < b.name then
            return true
        else
            return false
        end
    end)

    return requests_sorted
end

---Iterates over passed entities and counts items needed to build all ghost entities and tiles.
---@param entities LuaEntity[] table of entities
---@param ignore_tiles boolean Determines whether ghost tiles are counted
---@return table<uint, LuaEntity> ghosts table of actual ghost entities/tiles
---@return table requests table of requests, indexed by request name
function get_selection_counts(entities, ignore_tiles)
    local ghosts, requests = {}, {}
    local cache = {}

    -- Iterate over entities and filter out anything that's not a ghost
    local insert = table.insert
    for _, entity in pairs(entities) do
        local entity_type = entity.type
        if entity_type == "entity-ghost" or (entity_type == "tile-ghost" and not ignore_tiles) then
            local ghost_name = entity.ghost_name
            local unit_number = entity.unit_number --[[@as uint]]

            -- Get item to place entity, from prototype if necessary
            if not cache[ghost_name] then
                local prototype = entity_type == "entity-ghost" and
                                    game.entity_prototypes[ghost_name] or
                                    game.tile_prototypes[ghost_name]
                cache[ghost_name] = {
                    item=prototype.items_to_place_this and prototype.items_to_place_this[1] or nil
                }
            end

            ghosts[unit_number] = {}

            -- If entity is associated with item, increment request for that item by `item.count`
            local item = cache[ghost_name].item
            if item then
                requests[item.name] = requests[item.name] or make_empty_request(item.name)
                requests[item.name].count = requests[item.name].count + item.count
                insert(ghosts[unit_number], item)
            end

            -- If entity has module requests, increment request for each module type
            local item_requests = entity_type == "entity-ghost" and entity.item_requests or nil
            if item_requests and table_size(item_requests) > 0 then
                for name, val in pairs(item_requests) do
                    requests[name] = requests[name] or make_empty_request(name)
                    requests[name].count = requests[name].count + val
                    insert(ghosts[unit_number], {name=name, count=val})
                end
            end

            script.register_on_entity_destroyed(entity)
        elseif entity_type == "item-request-proxy" then
            local unit_number = entity.unit_number --[[@as uint]]
            ghosts[unit_number] = {}
            for name, val in pairs(entity.item_requests) do
                requests[name] = requests[name] or make_empty_request(name)
                requests[name].count = requests[name].count + val
                insert(ghosts[unit_number], {name=name, count=val})
            end
            script.register_on_entity_destroyed(entity)
        elseif entity.to_be_upgraded() then
            local unit_number = entity.unit_number --[[@as uint]]
            local prototype = entity.get_upgrade_target() --[[@as LuaEntityPrototype]]
            local ghost_name = prototype.name

            -- Get item to place entity, from prototype if necessary
            if not cache[ghost_name] then
                cache[ghost_name] = {
                    item=prototype.items_to_place_this and prototype.items_to_place_this[1] or nil
                }
            end

            ghosts[unit_number] = {}

            -- If entity is associated with item, increment request for that item by `item.count`
            local item = cache[ghost_name].item
            if item then
                requests[item.name] = requests[item.name] or make_empty_request(item.name)
                requests[item.name].count = requests[item.name].count + item.count
                insert(ghosts[unit_number], item)
            end

            script.register_on_entity_destroyed(entity)
        end
    end

    return ghosts, requests
end

---Returns the blueprint tiles contained within a given item stack.
---@param item_stack LuaItemStack Must be a blueprint or a blueprint-book
---@return Tile[] tiles
function get_blueprint_tiles(item_stack)
    if item_stack.is_blueprint_book then
        local inventory = item_stack.get_inventory(defines.inventory.item_main) --[[@as LuaInventory]]
        return get_blueprint_tiles(inventory[item_stack.active_index])
    else
        return (item_stack.get_blueprint_tiles() or {})
    end
end

---Processes blueprint entities and tiles to generate item request counts.
---@param entities table array of blueprint entities
---@param tiles table array of blueprint tiles
---@return table requests
function get_blueprint_counts(entities, tiles)
    local requests = {}
    local cache = {}

    -- Iterate over blueprint entities
    for _, entity in pairs(entities) do
        if not cache[entity.name] then
            local prototype = game.entity_prototypes[entity.name]
            cache[entity.name] = {
                item=prototype.items_to_place_this and prototype.items_to_place_this[1] or nil
            }
        end

        -- If entity is associated with item, increment request for that item by `item.count`
        local item = cache[entity.name].item
        if item then
            requests[item.name] = requests[item.name] or make_empty_request(item.name)
            requests[item.name].count = requests[item.name].count + item.count
        end

        -- If entity has module requests, increment request for each module type
        local item_requests = entity.items
        if item_requests and table_size(item_requests) > 0 then
            for name, val in pairs(item_requests) do
                requests[name] = requests[name] or make_empty_request(name)
                requests[name].count = requests[name].count + val
            end
        end
    end

    -- Iterate over blueprint tiles
    for _, tile in pairs(tiles) do
        if not cache[tile.name] then
            local prototype = game.tile_prototypes[tile.name]
            cache[tile.name] = {
                item=prototype.items_to_place_this and prototype.items_to_place_this[1] or nil
            }
        end

        -- If tile is associated with item, increment request for that item by `item.count`
        local item = cache[tile.name].item
        if item then
            requests[item.name] = requests[item.name] or make_empty_request(item.name)
            requests[item.name].count = requests[item.name].count + item.count
        end
    end

    return requests
end

---Converts a given player's `Request` table to signals out of a series of constant combinators.
---@param player_index uint Player index
function make_combinators_blueprint(player_index)
    local playerdata = get_make_playerdata(player_index)

    -- Make sure constant combinator prototype exists
    local prototype = game.entity_prototypes["constant-combinator"]
    if not prototype then
        playerdata.luaplayer.print({"ghost-counter-message.missing-constant-combinator-prototype"})
        return
    end

    local n_slots = prototype.item_slot_count
    local requests = playerdata.job.requests_sorted
    local request_index = 1
    local combinators = {}

    -- Iterate over the number of constant combinators we will need
    for i = 1, math.ceil(#requests / n_slots) do
        combinators[i] = {
            entity_number=i,
            name="constant-combinator",
            position={i - 0.5, 0},
            direction=4,
            control_behavior={filters={}},
            connections={{}}
        }

        local filters = combinators[i].control_behavior.filters

        -- Set the combinator slots to the ghost request counts
        for j = 1, n_slots do
            local request = requests[request_index]
            filters[j] = {signal={type="item", name=request.name}, count=request.count, index=j}

            -- Increment request index; break if no more requests are left
            request_index = request_index + 1
            if request_index > #requests then break end
        end
    end

    -- Wire up the combinators to one another
    if #combinators > 1 then
        for i = 1, (#combinators - 1) do
            local connections = combinators[i].connections[1]

            connections["green"] = {{entity_id=i + 1}}
            connections["red"] = {{entity_id=i + 1}}
        end
    end

    -- Try to clear the cursor
    local is_successful = playerdata.luaplayer.clear_cursor()

    if is_successful then
        playerdata.luaplayer.cursor_stack.set_stack("blueprint")
        playerdata.luaplayer.cursor_stack.set_blueprint_entities(combinators)
    else
        playerdata.luaplayer.print({"ghost-counter-message.failed-to-clear-cursor"})
    end
end

---Deletes requests with zero ghosts from the `job.requests` table.
---@param player_index uint Player index
function remove_empty_requests(player_index)
    local playerdata = get_make_playerdata(player_index)
    for name, request in pairs(playerdata.job.requests) do
        if request.count <= 0 then playerdata.job.requests[name] = nil end
    end
end

---Updates table of `Request`s with inventory and cursor stack contents.
---@param player_index uint Player index
function update_inventory_info(player_index)
    local playerdata = get_make_playerdata(player_index)
    local cursor_stack = playerdata.luaplayer.cursor_stack
    local inventory = playerdata.luaplayer.get_main_inventory()
    local contents = inventory and inventory.get_contents() or {}
    local requests = playerdata.job.requests

    -- Iterate over each request and get the count in inventory
    for name, request in pairs(requests) do request.inventory = contents[name] or 0 end

    -- Add cursor contents to request count
    if cursor_stack and cursor_stack.valid_for_read and requests[cursor_stack.name] then
        local request = requests[cursor_stack.name]
        request.inventory = request.inventory + cursor_stack.count
    end
end

---Updates table of `Request`s with the player's current logistic requests.
---@param player_index uint Player index
function update_logistics_info(player_index)
    local playerdata = get_make_playerdata(player_index)
    local requests = playerdata.job.requests

    -- Get player character
    local character = playerdata.luaplayer.character
    if not character then return end

    -- Iterate over each logistic slot and update request table with logistic request details
    local logistic_requests = {}
    for i = 1, character.request_slot_count do
        local slot = playerdata.luaplayer.get_personal_logistic_slot(i --[[@as uint]])
        if requests[slot.name] then
            requests[slot.name].logistic_request = {slot_index=i, min=slot.min, max=slot.max}
            logistic_requests[slot.name] = true
        end
    end

    -- Clear the `logistic_request` table of the request if one was not found
    for _, request in pairs(playerdata.job.requests) do
        if not logistic_requests[request.name] then request.logistic_request = {} end
    end
end

---Iterates over one-time requests table and restores old requests if they have been fulfilled.
---@param player_index uint Player index
function update_one_time_logistic_requests(player_index)
    local playerdata = get_make_playerdata(player_index)
    if not playerdata.luaplayer.character then return end

    local inventory = playerdata.luaplayer.get_main_inventory() --[[@as LuaInventory]]

    -- Iterate over one-time requests table and restore old requests if they have been fulfilled
    for name, logi_req in pairs(playerdata.logistic_requests) do
        local request = playerdata.job.requests[name]
        local slot = playerdata.luaplayer.get_personal_logistic_slot(logi_req.slot_index)

        if request then
            -- Update logistic request to reflect new ghost count
            if slot.min ~= request.count then
                local new_slot = {name=name, min=request.count}
                logi_req.new_min = request.count
                logi_req.is_new = true
                playerdata.luaplayer.set_personal_logistic_slot(logi_req.slot_index, new_slot)
            end

            -- Restore prior request (if any) if one-time request has been fulfilled
            if (inventory.get_item_count(name) >= logi_req.new_min) or
                (logi_req.new_min <= (logi_req.old_min or 0)) then
                restore_prior_logistic_request(player_index, name)
            end
        end
    end
end

---Iterates over player's logistic slots and returns the first empty slot. Player _must_ have a
---character entity.
---@param player_index uint Player index
---@return uint? slot_index First empty slot
function get_first_empty_slot(player_index)
    local playerdata = get_make_playerdata(player_index)
    local character = playerdata.luaplayer.character --[[@as LuaEntity]]

    for slot_index = 1, character.request_slot_count + 1 do
        ---@cast slot_index uint
        local slot = playerdata.luaplayer.get_personal_logistic_slot(slot_index)
        if slot.name == nil then return slot_index end
    end
end

---Gets a table with details of any existing logistic request for a given item.
---@param player_index uint Player index
---@param name string Item name
---@return table|nil logistic_request
function get_existing_logistic_request(player_index, name)
    local playerdata = get_make_playerdata(player_index)
    local character = playerdata.luaplayer.character
    if not character then return nil end

    for i = 1, character.request_slot_count do
        ---@cast i uint
        local slot = playerdata.luaplayer.get_personal_logistic_slot(i)
        if slot and slot.name == name then
            return {slot_index=i, name=slot.name, min=slot.min, max=slot.max}
        end
    end
end

---Generates a logistic request or modifies an existing request to satisfy need. Registers the
---change in a `playerdata.logistic_requests` table so that it can be reverted later on.
---@param player_index uint Player index
---@param name string `request` name
function make_one_time_logistic_request(player_index, name)
    -- Abort if no player character
    local playerdata = get_make_playerdata(player_index)
    if not playerdata.luaplayer.character then return end

    -- Abort if player already has more of item in inventory than needed
    local request = playerdata.job.requests[name]
    if not request or request.inventory >= request.count then return end

    -- Get any existing request and abort if it would already meet need
    local existing_request = get_existing_logistic_request(player_index, request.name) or {}
    if (existing_request.min or 0) >= request.count then return end

    -- Prepare new logistic slot and get existing or first empty `slot_index`
    local new_slot = {name=request.name, min=request.count}
    local slot_index = existing_request.slot_index or get_first_empty_slot(player_index)
    if not slot_index then return end

    -- Save details of change in playerdata so that it can be reverted later
    -- This is set here in order for the event handler to be able to identify this change
    -- as originating from the mod and to ignore it.
    playerdata.logistic_requests[request.name] = {
        slot_index=slot_index,
        old_min=existing_request.min,
        old_max=existing_request.max,
        new_min=request.count,
        is_new=true
    }

    -- Actually modify personal logistic slot
    local is_successful = playerdata.luaplayer.set_personal_logistic_slot(slot_index, new_slot)

    if is_successful then
        -- Update request's `logistic_request` table
        request.logistic_request.slot_index = slot_index
        request.logistic_request.min = request.count
        request.logistic_request.max = nil

        playerdata.has_updates = true
        register_update(player_index, game.tick)
    else
        -- Delete record of temporary request as it didn't go through
        playerdata.logistic_requests[request.name] = nil
    end
end

---Restores the prior logistic request (if any) that was in place before the one-time request was
---made.
---@param player_index uint Player index
---@param name string Item name
function restore_prior_logistic_request(player_index, name)
    local playerdata = get_make_playerdata(player_index)
    if not playerdata.luaplayer.character then return end

    local request = playerdata.logistic_requests[name]
    local slot

    -- Either clear or reset slot using old request values
    if request.old_min or request.old_max then
        slot = {name=name, min=request.old_min, max=request.old_max}
        playerdata.luaplayer.set_personal_logistic_slot(request.slot_index, slot)
    else
        playerdata.luaplayer.clear_personal_logistic_slot(request.slot_index)
    end

    if playerdata.job.requests[name] then
        if slot then
            playerdata.job.requests[name].logistic_request = {
                slot_index=request.slot_index,
                min=slot.min,
                max=slot.max
            }
        else
            playerdata.job.requests[name].logistic_request = {}
        end
    end
end

---Iterates over `playerdata.logistic_requests` to get rid of them.
---@param player_index uint Player index
function cancel_all_one_time_requests(player_index)
    local playerdata = get_make_playerdata(player_index)
    for name, _ in pairs(playerdata.logistic_requests) do
        restore_prior_logistic_request(player_index, name)
    end
end

---Returns the yield of a given item from a single craft of a given recipe.
---@param item_name string Item name
---@param recipe LuaRecipePrototype Recipe prototype
---@return number
function get_yield_per_craft(item_name, recipe)
    local yield = 0

    for _, product in pairs(recipe.products) do
        if product.name == item_name then
            local probability = product.probability or 1
            yield = (product.amount) and (product.amount * probability) or
                ((product.amount_min + product.amount_max) * 0.5 * probability)
            break
        end
    end

    return yield
end

---Returns the number of times an item is set to be produced by a given character, taking into
---account their crafting queue contents.
---@param character LuaEntity Character entity
---@param item_name string Name of item to craft
---@return uint item_count
function get_item_count_from_character_crafting_queue(character, item_name)
    if character.crafting_queue_size == 0 then return 0 end

    local relevant_recipes = game.get_filtered_recipe_prototypes{
        {filter="has-product-item", elem_filters={{filter="name", name=item_name}}},
        {filter="hidden-from-player-crafting", invert=true, mode="and"}
    }
    local unique_recipes = {} --[[@as table<string, uint>]]
    local item_count = 0

    -- Create a list of unique and relevant recipes in the crafting queue
    for _, queue_item in pairs(character.crafting_queue) do
        local recipe_name = queue_item.recipe
        if not queue_item.prerequisite and (unique_recipes[recipe_name] or relevant_recipes[recipe_name]) then
            unique_recipes[recipe_name] = (unique_recipes[recipe_name] or 0) + queue_item.count
        end
    end

    -- Count number of `name` items that will ultimately be produced by recipes in crafting queue
    for recipe_name, n_crafts in pairs(unique_recipes) do
        local yield_per_craft = get_yield_per_craft(item_name, relevant_recipes[recipe_name])
        item_count = item_count + math.floor(yield_per_craft * n_crafts)
    end

    return item_count --[[@as uint]]
end

---Crafts a given item; amount to craft based on the corresponding request for that item.
---@param player_index uint Player index
---@param request Request Request data
---@return "no-character"|"no-crafts-needed"|"attempted" result
---@return uint? items_crafted Number of items crafted
function craft_request(player_index, request)
    -- Abort if no player character
    local playerdata = get_make_playerdata(player_index)
    local character = playerdata.luaplayer.character
    if not character then return "no-character" end

    -- Abort if player already has more of item in inventory than needed
    if request.inventory >= request.count then return "no-crafts-needed" end

    -- Calculate item need; abort if 0 (or less)
    local crafting_yield = get_item_count_from_character_crafting_queue(character, request.name)
    local item_need = request.count - request.inventory - crafting_yield
    local original_need = item_need
    if item_need <= 0 then return "no-crafts-needed" end

    local crafting_recipes = game.get_filtered_recipe_prototypes{
        {filter="has-product-item", elem_filters={{filter="name", name=request.name}}},
        {filter="hidden-from-player-crafting", invert=true, mode="and"}
    }

    for recipe_name, recipe in pairs(crafting_recipes) do
        local yield_per_craft = get_yield_per_craft(request.name, recipe)
        local needed_crafts = math.ceil(item_need / yield_per_craft) --[[@as uint]]
        local actual_crafts = character.begin_crafting{recipe=recipe_name, count=needed_crafts, silent=true}

        item_need = item_need - math.floor(actual_crafts * yield_per_craft)
        if item_need <= 0 then break end
    end

    return "attempted", original_need - item_need
end

---Registers that a change in data tables has occured and marks the responsible player as having
---data updates to process.
---@param player_index uint Player index
---@param tick number Tick during which the data update occurred
function register_update(player_index, tick)
    local playerdata = get_make_playerdata(player_index)

    -- Mark player as having a data update, in order for it to get reprocessed
    playerdata.has_updates = true

    -- Record the tick in which the update was registered
    global.last_event = tick

    -- Register nth_tick handler if needed
    register_nth_tick_handler(true)
end

---Registers/unregisters on_nth_tick event handler.
---@param state any
function register_nth_tick_handler(state)
    if state and not global.events.nth_tick then
        global.events.nth_tick = true
        script.on_nth_tick(global.settings.min_update_interval, on_nth_tick)
    elseif state == false and global.events.nth_tick then
        global.events.nth_tick = false
        ---@diagnostic disable-next-line
        script.on_nth_tick(nil)
    end
end

---Registers/unregisters event handlers for inventory or player cursor stack changes.
---@param state boolean Determines whether to register or unregister event handlers
function register_inventory_monitoring(state)
    if state and not global.events.inventory then
        global.events.inventory = true

        script.on_event(defines.events.on_player_main_inventory_changed,
            on_player_main_inventory_changed)
        script.on_event(defines.events.on_player_cursor_stack_changed,
            on_player_main_inventory_changed)
        script.on_event(defines.events.on_entity_destroyed, on_ghost_destroyed)
    elseif state == false and global.events.inventory then
        global.events.inventory = false

        script.on_event(defines.events.on_player_main_inventory_changed, nil)
        script.on_event(defines.events.on_player_cursor_stack_changed, nil)
        script.on_event(defines.events.on_entity_destroyed, nil)
    end
end

---Registers/unregisters event handlers for player logistic slot changes.
---@param state boolean Determines whether to register or unregister event handlers
function register_logistics_monitoring(state)
    if state and not global.events.logistics then
        global.events.logistics = true
        script.on_event(defines.events.on_entity_logistic_slot_changed,
            on_entity_logistic_slot_changed)
    elseif state == false and global.events.logistics then
        global.events.logistics = false
        script.on_event(defines.events.on_entity_logistic_slot_changed, nil)
    end
end

---Iterates over global playerdata table and determines whether any connected players have their
---mod GUI open.
---@return boolean
function is_inventory_monitoring_needed()
    for _, playerdata in pairs(global.playerdata) do
        if playerdata.is_active and playerdata.luaplayer.connected then return true end
    end
    return false
end

---Iterates over the global playerdata table and checks to see if any one-time logistic requests
---are still unfulfilled.
---@return boolean
function is_logistics_monitoring_needed()
    for _, playerdata in pairs(global.playerdata) do
        if (playerdata.is_active or table_size(playerdata.logistic_requests) > 0) and
            playerdata.luaplayer.connected then return true end
    end
    return false
end
