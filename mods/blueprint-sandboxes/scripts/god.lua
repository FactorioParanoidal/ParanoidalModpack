-- Custom Extensions to the God-Controller
local God = {}

God.preventEntitiesByType = {
    ["lab"] = true,
}

God.onBuiltEntityFilters = {
    { filter = "type", type = "tile-ghost" },
    { filter = "type", type = "entity-ghost" },
    { filter = "type", type = "item-request-proxy" },
}

for type, _ in pairs(God.preventEntitiesByType) do
    table.insert(God.onBuiltEntityFilters, { filter = "type", type = type })
end

-- TODO: Perhaps this can be determined by flags?
God.skipHandlingEntities = {
    ["logistic-train-stop-input"] = true,
    ["logistic-train-stop-output"] = true,
    ["tl-dummy-entity"] = true,
    ["si-in-world-drop-entity"] = true,
    ["si-in-world-pickup-entity"] = true,
}

-- Immediately destroy an Entity (and perhaps related Entities)
---@param entity LuaEntity
function God.Destroy(entity)
    if entity.valid
            and entity.can_be_destroyed()
            and entity.to_be_deconstructed()
    then

        -- If the Entity has Transport Lines, also delete any Items on it
        if entity.prototype.belt_speed ~= nil then
            for i = 1, entity.get_max_transport_line_index() do
                entity.get_transport_line(i).clear()
            end
        end

        -- If the Entity represents a Hidden Tile underneath
        if entity.type == "deconstructible-tile-proxy" then
            local hiddenTile = entity.surface.get_hidden_tile(entity.position)
            entity.surface.set_tiles {
                {
                    name = hiddenTile,
                    position = entity.position,
                }
            }
        end

        entity.destroy({ raise_destroy = true })
    end
end

-- TODO: Insert Requests when pasting new Entity that generates new Requests
-- But... what is the Event?

-- Immediately Insert an Entity's Requests
---@param entity LuaEntity
function God.InsertRequests(entity)
    if entity.valid
        and entity.type == "item-request-proxy"
        and entity.proxy_target then
        -- Remove any Requested Items
        for _, plan in pairs(entity.removal_plan) do
            if plan.items.in_inventory then
                for _, position in pairs(plan.items.in_inventory) do
                    local inventory = entity.proxy_target.get_inventory(position.inventory)
                    local decrement = position.count or 1
                    if inventory and inventory.valid and inventory.index == position.inventory then
                        local stack = inventory[position.stack + 1]
                        if stack.count > 0 then
                            stack.count = math.max(0, stack.count - decrement)
                        end
                    end
                end
            end
        end
        -- Insert any Requested Items
        for _, plan in pairs(entity.insert_plan) do
            if plan.items.in_inventory then
                for _, position in pairs(plan.items.in_inventory) do
                    local inventory = entity.proxy_target.get_inventory(position.inventory)
                    local increment = position.count or 1
                    if inventory and inventory.valid
                    and inventory.index == position.inventory
                    and #inventory > position.stack
                    then
                        local stack = inventory[position.stack + 1]
                        if stack.count > 0 then
                            stack.count = stack.count + increment
                        else
                            stack.set_stack {
                                name = plan.id.name,
                                quality = plan.id.quality,
                                count = increment,
                            }
                        end
                    end
                end
            end
        end
        entity.destroy()
    end
end

-- Immediately Revive a Ghost Entity
---@param entity LuaEntity
function God.Create(entity)
    if entity.valid then
        if entity.type == "tile-ghost" then
            -- Tiles are simple Revives
            local _, revived, _ = entity.silent_revive({ raise_revive = true })
            if not revived and entity.valid then
                Queue.Push(storage.asyncCreateQueue, entity)
            end
        elseif entity.type == "item-request-proxy" then
            -- Requests are simple
            God.InsertRequests(entity)
        elseif entity.type == "entity-ghost" then
            -- Entities might also want Items after Reviving
            local _, revived, request = entity.silent_revive({
                raise_revive = true
            })

            if revived and request then
                God.InsertRequests(request)
            end

            if not revived and entity.valid then
                Queue.Push(storage.asyncCreateQueue, entity)
            end
        end
    end
end

-- Immediately turn one Entity into another
---@param entity LuaEntity
function God.Upgrade(entity)
    if entity.valid
            and entity.to_be_upgraded()
    then
        local targetEntity, targetQuality = entity.get_upgrade_target()

        local options = {
            name = targetEntity.name,
            position = entity.position,
            direction = entity.direction,
            quality = targetQuality,
            force = entity.force,
            fast_replace = true,
            spill = false,
            raise_built = true,
        }

        -- Otherwise it fails to place "output" sides (it defaults to "input")
        if entity.type == "underground-belt" then
            options.type = entity.belt_to_ground_type
        end

        local result = entity.surface.create_entity(options)

        if result == nil and entity.valid then
            log("Upgrade Failed, Cancelling: " .. entity.name)
            entity.cancel_upgrade(entity.force)
        else
            log("Upgrade Failed, Old Entity Gone too!")
        end
    end
end

-- Ensure the God's Inventory is kept in-sync
---@param event EventData.on_player_main_inventory_changed
function God.OnInventoryChanged(event)
    if Isolation.IsNone() then return end
    local player = game.players[event.player_index]
    if Sandbox.IsPlayerInsideSandbox(player) and Inventory.ShouldPersist(player.controller_type) then
        Inventory.Prune(player)
        local playerData = storage.players[event.player_index]
        playerData.sandboxInventory = Inventory.Persist(
                player.get_main_inventory(),
                playerData.sandboxInventory
        )
    end
end

-- Ensure newly-crafted Items are put into the Cursor for use
---@param event EventData.on_player_crafted_item
function God.OnPlayerCraftedItem(event)
    local player = game.players[event.player_index]
    if Sandbox.IsPlayerInsideSandbox(player)
            and Controllers.IsGod(player)
            and Isolation.IsFull()
            and player.cursor_stack
            and player.cursor_stack.valid
            and event.item_stack.valid
            and event.item_stack.valid_for_read
            and event.recipe.valid
            and (
            #event.recipe.products == 1
                    or (
                    event.recipe.prototype.main_product
                            and event.recipe.prototype.main_product.name == event.item_stack.name
            )
    )
            and player.mod_settings[Settings.craftToCursor].value
    then
        event.item_stack.count = event.item_stack.prototype.stack_size
        player.cursor_stack.clear()
        player.cursor_stack.transfer_stack(event.item_stack)
    end
end

---@param entity LuaEntity
function God.AsyncWrapper(setting, queue, handler, entity)
    if settings.global[setting].value == 0 then
        handler(entity)
    else
        Queue.Push(queue, entity)
    end
end

---@param entity LuaEntity
function God.ShouldHandleEntity(entity)
    if not entity.valid then return false end

    if not (Lab.IsLab(entity.surface)
            or (Factorissimo.IsFactory(entity.surface)
                and Factorissimo.IsFactoryInsideSandbox(entity.surface, entity.position)))
    then
        return false
    end

    local isEntityGhost = entity.type == "entity-ghost"
    if God.preventEntitiesByType[entity.type] or (isEntityGhost and God.preventEntitiesByType[entity.ghost_type]) then
        local player = entity.last_user --[[@as LuaPlayer | nil]]
        if player then
            player.create_local_flying_text({
                text = {"messages.cannot-build-in-sandbox"},
                position = player.position,
            })
        end
        entity.destroy({ raise_destroy = true })
        return false
    end

    if not settings.global[Settings.godBuilding].value then
        return false
    end

    local name = entity.name
    if isEntityGhost then name = entity.ghost_name end

    if God.skipHandlingEntities[name] then
        return false
    end

    return true
end

-- Ensure new Orders are handled
---@param event EventData.on_marked_for_deconstruction
function God.OnMarkedForDeconstruct(event)
    if God.ShouldHandleEntity(event.entity) then
        God.AsyncWrapper(
                Settings.godAsyncDeleteRequestsPerTick,
                storage.asyncDestroyQueue,
                God.Destroy,
                event.entity
        )
    end
end

-- Ensure new Orders are handled
---@param event EventData.on_marked_for_upgrade
function God.OnMarkedForUpgrade(event)
    if God.ShouldHandleEntity(event.entity) then
        God.AsyncWrapper(
                Settings.godAsyncUpgradeRequestsPerTick,
                storage.asyncUpgradeQueue,
                God.Upgrade,
                event.entity
        )
    end
end

-- Ensure new Ghosts are handled
---@param event EventData.on_built_entity | EventData.script_raised_built
function God.OnBuiltEntity(event)
    if God.ShouldHandleEntity(event.entity) then
        God.AsyncWrapper(
                Settings.godAsyncCreateRequestsPerTick,
                storage.asyncCreateQueue,
                God.Create,
                event.entity
        )
    end
end

-- Ensure remaining Ghosts are handled
---@param player LuaPlayer
---@param deleteRequests number
---@param upgradeRequests number
---@param createRequests number
function God.QueueUnhandledEntities(player, deleteRequests, upgradeRequests, createRequests)
    local surface = player.surface
    local radius = 32 * 6 -- 6 chunk radius

    if deleteRequests > 0 then
        local deconstructs = surface.find_entities_filtered({
            position = player.position,
            radius = radius,
            force = player.force,
            to_be_deconstructed = true,
            to_be_upgraded = false,
            limit = 100,
        })
        for _, entity in pairs(deconstructs) do
            if God.ShouldHandleEntity(entity) then
                God.AsyncWrapper(
                    Settings.godAsyncDeleteRequestsPerTick,
                    storage.asyncDestroyQueue,
                    God.Destroy,
                    entity
                )
            end
        end
    end

    if upgradeRequests > 0 then
        local upgrades = surface.find_entities_filtered({
            position = player.position,
            radius = radius,
            force = player.force,
            to_be_deconstructed = false,
            to_be_upgraded = true,
            limit = 100,
        })
        for _, entity in pairs(upgrades) do
            if God.ShouldHandleEntity(entity) then
                God.AsyncWrapper(
                    Settings.godAsyncUpgradeRequestsPerTick,
                    storage.asyncUpgradeQueue,
                    God.Upgrade,
                    entity
                )
            end
        end
    end

    if createRequests > 0 then
        local ghosts = surface.find_entities_filtered({
            position = player.position,
            radius = radius,
            force = player.force,
            type = {
                "tile-ghost",
                "entity-ghost",
                "item-request-proxy",
            },
            to_be_deconstructed = false,
            to_be_upgraded = false,
            limit = 100,
        })
        for _, entity in pairs(ghosts) do
            if God.ShouldHandleEntity(entity) then
                God.AsyncWrapper(
                    Settings.godAsyncCreateRequestsPerTick,
                    storage.asyncCreateQueue,
                    God.Create,
                    entity
                )
            end
        end
    end
end

-- TODO: This is basically only necessary because of missing item-request-proxy and super-force-building events
-- Ensure remaining Ghosts are handled
---@param deleteRequests number
---@param upgradeRequests number
---@param createRequests number
function God.QueueUnhandledEntitiesInOccupiedSandboxes(deleteRequests, upgradeRequests, createRequests)
    for _, player in pairs(game.players) do
        if player.connected and Sandbox.IsSandbox(player.surface) then
            God.QueueUnhandledEntities(player, deleteRequests, upgradeRequests, createRequests)
        end
    end
end

-- For each known Sandbox Surface, handle any async God functionality
---@param event EventData.on_tick
function God.HandleAllSandboxRequests(event)
    local createRequestsPerTick = math.max(1, settings.global[Settings.godAsyncCreateRequestsPerTick].value)
    local upgradeRequestsPerTick = math.max(1, settings.global[Settings.godAsyncUpgradeRequestsPerTick].value)
    local deleteRequestsPerTick = math.max(1, settings.global[Settings.godAsyncDeleteRequestsPerTick].value)

    local destroyRequestsHandled = 0
    while Queue.Size(storage.asyncDestroyQueue) > 0
            and deleteRequestsPerTick > 0
    do
        God.Destroy(Queue.Pop(storage.asyncDestroyQueue))
        destroyRequestsHandled = destroyRequestsHandled + 1
        deleteRequestsPerTick = deleteRequestsPerTick - 1
    end
    if Queue.Size(storage.asyncDestroyQueue) == 0
            and destroyRequestsHandled > 0
    then
        storage.asyncDestroyQueue = Queue.New()
    end

    local upgradeRequestsHandled = 0
    while Queue.Size(storage.asyncUpgradeQueue) > 0
            and upgradeRequestsPerTick > 0
    do
        God.Upgrade(Queue.Pop(storage.asyncUpgradeQueue))
        upgradeRequestsHandled = upgradeRequestsHandled + 1
        upgradeRequestsPerTick = upgradeRequestsPerTick - 1
    end
    if Queue.Size(storage.asyncUpgradeQueue) == 0
            and upgradeRequestsHandled > 0
    then
        storage.asyncUpgradeQueue = Queue.New()
    end

    local createRequestsHandled = 0
    while Queue.Size(storage.asyncCreateQueue) > 0
            and createRequestsPerTick > 0
    do
        God.Create(Queue.Pop(storage.asyncCreateQueue))
        createRequestsHandled = createRequestsHandled + 1
        createRequestsPerTick = createRequestsPerTick - 1
    end
    if Queue.Size(storage.asyncCreateQueue) == 0
            and createRequestsHandled > 0
    then
        storage.asyncCreateQueue = Queue.New()
    end

    if (deleteRequestsPerTick + upgradeRequestsPerTick + createRequestsPerTick) > 0 then
        God.QueueUnhandledEntitiesInOccupiedSandboxes(deleteRequestsPerTick, upgradeRequestsPerTick, createRequestsPerTick)
    end
end

return God
