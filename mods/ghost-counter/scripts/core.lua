---Gets or makes playerdata table.
---@param player_index uint LuaPlayer index
---@return Playerdata playerdata
function get_make_playerdata(player_index)
    local playerdata = storage.playerdata[player_index]

    if not playerdata then
        playerdata = {
            luaplayer=game.players[player_index],
            index=player_index,
            is_active=false,
            job={
                area={},
                ghosts={},
                requests={},
                requests_sorted={}
            },
            logistic_requests={},
            gui={},
            options={}
        }
        storage.playerdata[player_index] = playerdata
    end

    return playerdata
end

---Gets the base quality name, which is typically "normal" though this may be modified by mods.
function get_base_quality()
    local base_quality_name
    local base_quality_level

    -- Iterate through each quality prototype to identify the one with the lowest level
    for name, quality_prototype in pairs(prototypes.quality) do
        if base_quality_name == nil or quality_prototype.level < base_quality_level then
            base_quality_name = name
            base_quality_level = quality_prototype.level
        end
    end

    return base_quality_name
end

---Returns GC Requests logistic section for a given player
---@param player_index uint Player index
---@return string
function get_logistic_section_name(player_index)
    return "Ghost Counter Requests [" .. player_index .. "]"
end

---Returns an empty request table for the given item.
---@param name string Item name
---@param quality string Quality name of item
---@return Request request
function make_empty_request(name, quality)
    return {name=name, quality=quality, count=0, inventory=0, requested=0}
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
            local quality = entity.quality.name
            local unit_number = entity.unit_number --[[@as uint]]

            -- Get item to place entity, from prototype if necessary
            if not cache[ghost_name] then
                local prototype = entity_type == "entity-ghost" and
                                    prototypes.entity[ghost_name] or
                                    prototypes.tile[ghost_name]
                cache[ghost_name] = {
                    item = prototype.items_to_place_this and prototype.items_to_place_this[1] or nil
                }
            end

            ghosts[unit_number] = {}

            -- If entity is associated with item, increment request for that item by `item.count`
            local item = cache[ghost_name].item

            if item then
                ---@cast item ItemStackDefinition
                local name_and_quality = item.name .. "+" .. quality

                requests[name_and_quality] = requests[name_and_quality] or make_empty_request(item.name, quality)
                requests[name_and_quality].count = requests[name_and_quality].count + item.count
                insert(ghosts[unit_number], {name=item.name, quality=quality, count=item.count})
            end

            -- If entity has module requests, increment request for each module type
            local item_requests = entity_type == "entity-ghost" and entity.item_requests or nil
            if item_requests and next(item_requests) then
                for _, item_request in pairs(item_requests) do
                    local item_request_quality = item_request.quality --[[@as string]]
                    local name_and_quality = item_request.name .. "+" .. item_request_quality

                    requests[name_and_quality] =
                        requests[name_and_quality] or make_empty_request(item_request.name, item_request_quality)
                    requests[name_and_quality].count = requests[name_and_quality].count + item_request.count

                    insert(ghosts[unit_number], {name=item_request.name, quality=item_request_quality, count=item_request.count})
                end
            end

            script.register_on_object_destroyed(entity)
        elseif entity_type == "item-request-proxy" then
            local unit_number = entity.unit_number --[[@as uint]]

            ghosts[unit_number] = {}

            for _, item_request in pairs(entity.item_requests) do
                local item_request_quality = item_request.quality --[[@as string]]
                local name_and_quality = item_request.name .. "+" .. item_request_quality

                requests[name_and_quality] =
                    requests[name_and_quality] or make_empty_request(item_request.name, item_request_quality)
                requests[name_and_quality].count = requests[name_and_quality].count + item_request.count

                insert(ghosts[unit_number], {name=item_request.name, quality=item_request_quality, count=item_request.count})
            end
            script.register_on_object_destroyed(entity)
        elseif entity.to_be_upgraded() then
            local unit_number = entity.unit_number --[[@as uint]]
            local prototype = entity.get_upgrade_target() --[[@as LuaEntityPrototype]]
            local quality = entity.quality.name
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
                local name_and_quality = item.name .. "+" .. quality

                requests[name_and_quality] = requests[name_and_quality] or make_empty_request(item.name, quality)
                requests[name_and_quality].count = requests[name_and_quality].count + item.count

                insert(ghosts[unit_number], {name=item.name, quality=quality, count= item.count})
            end

            script.register_on_object_destroyed(entity)
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
---@param entities BlueprintEntity[]? Array of blueprint entities
---@param tiles table array of blueprint tiles
---@return table requests
function get_blueprint_counts(entities, tiles)
    local requests = {}
    local cache = {}
    local base_quality = get_base_quality()

    -- Iterate over blueprint entities
    if entities then
        for _, entity in pairs(entities) do
            local entity_name = entity.name
            local entity_quality = entity.quality or base_quality

            if not cache[entity_name] then
                local prototype = prototypes.entity[entity_name]
                cache[entity_name] = {
                    item=prototype.items_to_place_this and prototype.items_to_place_this[1] or nil
                }
            end

            -- If entity is associated with item, increment request for that item by `item.count`
            local item = cache[entity_name].item
            if item then
                local name_and_quality = item.name .. "+" .. entity_quality

                requests[name_and_quality] = requests[name_and_quality] or make_empty_request(item.name, entity_quality)
                requests[name_and_quality].count = requests[name_and_quality].count + item.count
            end

            -- If entity has module requests, increment request for each module type
            local item_requests = entity.items
            if item_requests and next(item_requests) then
                for _, item_request in pairs(item_requests) do
                    local name = item_request.id.name --[[@as string]]
                    local quality = item_request.id.quality or base_quality--[[@as string]]
                    local name_and_quality = name .. "+" .. quality

                    requests[name_and_quality] = requests[name_and_quality] or make_empty_request(name, quality)
                    requests[name_and_quality].count = requests[name_and_quality].count + 1
                end
            end
        end
    end

    -- Iterate over blueprint tiles
    for _, tile in pairs(tiles) do
        if not cache[tile.name] then
            local prototype = prototypes.tile[tile.name]
            cache[tile.name] = {
                item=prototype.items_to_place_this and prototype.items_to_place_this[1] or nil
            }
        end

        -- If tile is associated with item, increment request for that item by `item.count`
        local item = cache[tile.name].item
        if item then
            local name_and_quality = item.name .. "+" .. base_quality

            requests[name_and_quality] = requests[name_and_quality] or make_empty_request(item.name, base_quality)
            requests[name_and_quality].count = requests[name_and_quality].count + item.count
        end
    end

    return requests
end

---Converts a given player's `Request` table to signals out of a constant combinator.
---@param player_index uint Player index
function make_combinator_blueprint(player_index)
    local playerdata = get_make_playerdata(player_index)

    -- Make sure constant combinator prototype exists
    local prototype = prototypes.entity["constant-combinator"]
    if not prototype then
        playerdata.luaplayer.print({"ghost-counter-message.missing-constant-combinator-prototype"})
        return
    end

    local requests = playerdata.job.requests_sorted
    local combinator = {
        entity_number=1,
        name="constant-combinator",
        position={1 - 0.5, 0},
        direction=4,
        control_behavior={filters={}},
        connections={{}}
    }

    local filters = combinator.control_behavior.filters

    for i, request in pairs(requests) do
        filters[i] = {signal={type="item", name=request.name, quality=request.quality}, count=request.count, index=i}
    end

    -- Try to clear the cursor
    local is_successful = playerdata.luaplayer.clear_cursor()

    if is_successful then
        playerdata.luaplayer.cursor_stack.set_stack("blueprint")
        playerdata.luaplayer.cursor_stack.set_blueprint_entities({combinator})
        playerdata.luaplayer.cursor_stack_temporary = true
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
    local inventory = playerdata.luaplayer.character.get_main_inventory()
    local requests = playerdata.job.requests

    -- Iterate over each request and get the count in inventory
    if inventory then
        for _, request in pairs(requests) do
            request.inventory = inventory.get_item_count({name=request.name, quality=request.quality}) or 0
        end
    end

    -- Add cursor contents to request count
    if cursor_stack and cursor_stack.valid_for_read then
        local name_and_quality = cursor_stack.name .. "+" .. cursor_stack.quality.name
        if requests[name_and_quality] then
            local request = requests[name_and_quality]
            request.inventory = request.inventory + cursor_stack.count
        end
    end
end

---Gets the logistic section for mod requests for a given player.
---@param logistic_point LuaLogisticPoint Character requester logistic point
---@param player_index uint Player index
---@return LuaLogisticSection? section Mod's logistic section, if it exists
function get_logistic_section(player_index, logistic_point)
    for i = 1, logistic_point.sections_count do
        local section = logistic_point.sections[i]

        if section.group == get_logistic_section_name(player_index) then
            return section
        end
    end
end

---Gets (or makes if necessary) a logistic section for mod requests
---@param logistic_point LuaLogisticPoint Character requester logistic point
---@param player_index uint Player index
---@return LuaLogisticSection?
function get_make_logistic_section(player_index, logistic_point)
    return get_logistic_section(player_index, logistic_point) or
        logistic_point.add_section(get_logistic_section_name(player_index))
end

---Updates table of `Request`s with the player's current logistic requests.
---@param player_index uint Player index
function update_logistics_info(player_index)
    local playerdata = get_make_playerdata(player_index)
    local requests = playerdata.job.requests
    local base_quality = get_base_quality()

    -- Get player character
    local character = playerdata.luaplayer.character
    if not character then return end

    local logistic_point = character.get_logistic_point(defines.logistic_member_index.character_requester)

    -- Iterate over each logistic slot and update request table with logistic request details
    local logistic_requests = {}
    if logistic_point and logistic_point.filters then
        for _, slot in pairs(logistic_point.filters) do
            local entity_quality = slot.quality or base_quality
            local name_and_quality = slot.name .. "+" .. entity_quality
            if requests[name_and_quality] then
                requests[name_and_quality].requested = slot.count
                logistic_requests[name_and_quality] = true
            end

            local temp_request = playerdata.logistic_requests[name_and_quality]
            if temp_request then
                temp_request.existing = slot.count - temp_request.new_min
            end
        end
    end

    -- Set a request's `requested` property to 0 if no matching request was found
    for name_and_quality, request in pairs(playerdata.job.requests) do
        if not logistic_requests[name_and_quality] then request.requested = 0 end
    end
end

---Iterates over one-time requests table and clears request slots if fulfilled.
---@param player_index uint Player index
function update_one_time_logistic_requests(player_index)
    local playerdata = get_make_playerdata(player_index)
    if not playerdata.luaplayer.character then return end

    local inventory = playerdata.luaplayer.get_main_inventory() --[[@as LuaInventory]]

    local logistic_point = playerdata.luaplayer.character.get_logistic_point(defines.logistic_member_index.character_requester)
    if not logistic_point then return end

    local logistic_section = get_logistic_section(player_index, logistic_point)
    if not logistic_section then return end

    for i, slot in pairs(logistic_section.filters) do
        if next(slot) then
            local name_and_quality = slot.value.name .. "+" .. slot.value.quality
            local logi_req = playerdata.logistic_requests[name_and_quality]

            if logi_req then
                local request = playerdata.job.requests[name_and_quality]
                if request then
                    if slot.min ~= request.count - logi_req.existing then
                        slot.min = request.count - logi_req.existing
                        logi_req.new_min = request.count - logi_req.existing
                        logi_req.is_new = true
                        logistic_section.set_slot(i, slot)
                    end
                end

                -- Clear slot if one-time request has been fulfilled
                if inventory and (inventory.get_item_count({name=slot.value.name, quality=slot.value.quality}) >= (logi_req.new_min + logi_req.existing)) then
                    logistic_section.clear_slot(i)
                end
            end
        end
    end
end

---Iterates over a logistic section's slots and returns the first empty slot.
---@param logistic_section LuaLogisticSection Logistic section to find empty slot in
---@return uint? slot_index First empty slot
function get_first_empty_slot(logistic_section)
    for slot_index = 1, logistic_section.filters_count + 1 do
        local slot = logistic_section.filters[slot_index]
        if not slot or next(slot) == nil then
            return slot_index
        end
    end
end

---Gets a table with details of any existing logistic request for a given item within a given logistic section.
---@param logistic_section LuaLogisticSection Logistic section to search in
---@param name string Item name
---@param quality string Item quality
---@return table|nil logistic_request
function get_existing_logistic_request(logistic_section, name, quality)
    for i, slot in pairs(logistic_section.filters) do
        if next(slot) then
            if slot.value.name == name and slot.value.quality == quality then
                return {slot_index=i, min=slot.min}
            end
        end
    end
end

---Gets the count of a specific item of certain quality already requested by a logistic point
---@param logistic_point LuaLogisticPoint Logistic point to evaluate
---@param name string Item name
---@param quality string Item quality
---@return integer
function get_existing_combined_logistic_request_count(logistic_point, name, quality)
    if not logistic_point.filters then return 0 end

    for _, filter in pairs(logistic_point.filters) do
        if filter.name == name and filter.quality == quality and filter.comparator == "=" then
            return filter.count
        end
    end

    -- Return zero if no match was found in the player's combined logistic requests
    return 0
end

---Generates a logistic request or modifies an existing request to satisfy need. Registers the
---change in a `playerdata.logistic_requests` table.
---@param player_index uint Player index
---@param name_and_quality string `request` name concatenated with quality level
function make_one_time_logistic_request(player_index, name_and_quality)
    -- Abort if no player character
    local playerdata = get_make_playerdata(player_index)
    if not playerdata.luaplayer.character then return end

    -- Abort if player already has more of item in inventory than needed
    local request = playerdata.job.requests[name_and_quality]
    if not request or request.inventory >= request.count then return end

    local character = playerdata.luaplayer.character
    if not character then return end

    local logistic_point = character.get_logistic_point(defines.logistic_member_index.character_requester)
    if not logistic_point then return end

    local logistic_section = get_make_logistic_section(player_index, logistic_point)
    if not logistic_section then return end

    -- Get any existing request and abort if it would already meet need
    local existing_request = get_existing_logistic_request(logistic_section, request.name, request.quality) or {}
    if (existing_request.min or 0) >= request.count then return end

    local combined_request_count = get_existing_combined_logistic_request_count(logistic_point, request.name, request.quality)
    local new_slot_min = request.count - combined_request_count

    -- Prepare new logistic slot and get existing or first empty `slot_index`
    local new_slot = {
        value = {type="item", name=request.name, quality=request.quality},
        min = new_slot_min
    }

    local slot_index = existing_request.slot_index or get_first_empty_slot(logistic_section)
    if not slot_index then return end

    -- Save details of change in playerdata so that it can be reverted later
    -- This is set here in order for the event handler to be able to identify this change
    -- as originating from the mod and to ignore it.
    playerdata.logistic_requests[name_and_quality] = {
        slot_index=slot_index,
        name=request.name,
        quality=request.quality,
        existing=combined_request_count,
        new_min=new_slot_min,
        is_new=true
    }

    -- Actually modify logistic section slot
    logistic_section.set_slot(slot_index, new_slot)

    -- Update request with new requested value
    request.requested = request.count

    register_update(player_index, game.tick)
end

---Clear one-time logistic request for a given item+quality pair
---@param player_index uint Player index
---@param name_and_quality string Key to find request in `logistics_requests` table
function clear_one_time_request(player_index, name_and_quality)
    local playerdata = get_make_playerdata(player_index)
    local character = playerdata.luaplayer.character
    if not character then return end

    local logistic_point = character.get_logistic_point(defines.logistic_member_index.character_requester)
    if not logistic_point then return end

    local logistic_section = get_logistic_section(player_index, logistic_point)
    if not logistic_section then return end

    local logistic_request = playerdata.logistic_requests[name_and_quality]
    if not logistic_request then return end

    logistic_section.clear_slot(logistic_request.slot_index)
end

---Iterates over `playerdata.logistic_requests` to get rid of them.
---@param player_index uint Player index
function cancel_all_one_time_requests(player_index)
    local playerdata = get_make_playerdata(player_index)

    local character = playerdata.luaplayer.character
    if not character then return end

    local logistic_point = character.get_logistic_point(defines.logistic_member_index.character_requester)
    if not logistic_point then return end

    local logistic_section = get_logistic_section(player_index, logistic_point)
    if not logistic_section then return end

    if logistic_section.filters_count == 0 then return end

    for slot_index, _ in pairs(logistic_section.filters) do
        logistic_section.clear_slot(slot_index)
    end

    playerdata.logistic_requests = {}
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
            yield = yield + (product.extra_count_fraction or 0)
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

    local relevant_recipes = prototypes.get_recipe_filtered{
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
---@return "no-character"|"cannot-craft-quality"|"no-crafts-needed"|"attempted" result
---@return uint? items_crafted Number of items crafted
function craft_request(player_index, request)
    -- Abort if no player character
    local playerdata = get_make_playerdata(player_index)
    local character = playerdata.luaplayer.character
    if not character then return "no-character" end

    -- Abort if player already has more of item in inventory than needed
    if request.inventory >= request.count then return "no-crafts-needed" end

    -- Abort if quality of item is higher than a player can craft
    if prototypes.quality[request.quality].level ~= 0 then return "cannot-craft-quality" end

    -- Calculate item need; abort if 0 (or less)
    local crafting_yield = get_item_count_from_character_crafting_queue(character, request.name)
    local item_need = request.count - request.inventory - crafting_yield
    local original_need = item_need
    if item_need <= 0 then return "no-crafts-needed" end

    local crafting_recipes = prototypes.get_recipe_filtered{
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
    storage.last_event = tick

    -- Register nth_tick handler if needed
    register_nth_tick_handler(true)
end

---Registers/unregisters on_nth_tick event handler.
---@param state any
function register_nth_tick_handler(state)
    if state and not storage.events.nth_tick then
        storage.events.nth_tick = true
        script.on_nth_tick(storage.settings.min_update_interval, on_nth_tick)
    elseif state == false and storage.events.nth_tick then
        storage.events.nth_tick = false
        ---@diagnostic disable-next-line
        script.on_nth_tick(nil)
    end
end

---Registers/unregisters event handlers for inventory or player cursor stack changes.
---@param state boolean Determines whether to register or unregister event handlers
function register_inventory_monitoring(state)
    if state and not storage.events.inventory then
        storage.events.inventory = true

        script.on_event(defines.events.on_player_main_inventory_changed,
            on_player_main_inventory_changed)
        script.on_event(defines.events.on_player_cursor_stack_changed,
            on_player_main_inventory_changed)
        script.on_event(defines.events.on_object_destroyed, on_ghost_destroyed)
    elseif state == false and storage.events.inventory then
        storage.events.inventory = false

        script.on_event(defines.events.on_player_main_inventory_changed, nil)
        script.on_event(defines.events.on_player_cursor_stack_changed, nil)
        script.on_event(defines.events.on_object_destroyed, nil)
    end
end

---Registers/unregisters event handlers for player logistic slot changes.
---@param state boolean Determines whether to register or unregister event handlers
function register_logistics_monitoring(state)
    if state and not storage.events.logistics then
        storage.events.logistics = true
        script.on_event(defines.events.on_entity_logistic_slot_changed,
            on_entity_logistic_slot_changed)
    elseif state == false and storage.events.logistics then
        storage.events.logistics = false
        script.on_event(defines.events.on_entity_logistic_slot_changed, nil)
    end
end

---Iterates over global playerdata table and determines whether any connected players have their
---mod GUI open.
---@return boolean
function is_inventory_monitoring_needed()
    for _, playerdata in pairs(storage.playerdata) do
        if (playerdata.is_active or next(playerdata.logistic_requests)) and
            playerdata.luaplayer.connected then return true end
    end
    return false
end

---Iterates over the global playerdata table and checks to see if any one-time logistic requests
---are still unfulfilled.
---@return boolean
function is_logistics_monitoring_needed()
    for _, playerdata in pairs(storage.playerdata) do
        if (playerdata.is_active or next(playerdata.logistic_requests)) and
            playerdata.luaplayer.connected then return true end
    end
    return false
end
