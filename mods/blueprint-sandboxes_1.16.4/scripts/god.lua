-- Custom Extensions to the God-Controller
local God = {}

God.onBuiltEntityFilters = {
    { filter = "type", type = "tile-ghost" },
    { filter = "type", type = "entity-ghost" },
    { filter = "type", type = "item-request-proxy" },
}

for realEntityName, illusionName in pairs(Illusion.realToIllusionMap) do
    table.insert(
        God.onBuiltEntityFilters,
        { filter = "name", name = realEntityName }
    )
end

-- TODO: Perhaps this can be determined by flags?
God.skipHandlingEntities = {
    ["logistic-train-stop-input"] = true,
    ["logistic-train-stop-output"] = true,
    ["tl-dummy-entity"] = true,
}

-- Immediately destroy an Entity (and perhaps related Entities)
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

-- Immediately Insert an Entity's Requests
function God.InsertRequests(entity)
    if entity.valid
            and entity.type == "item-request-proxy"
            and entity.proxy_target then
        -- Insert any Requested Items (like Modules, Fuel)
        for name, count in pairs(entity.item_requests) do
            entity.proxy_target.insert({
                name = name,
                count = count,
            })
        end
        entity.destroy()
    end
end

-- Immediately Revive a Ghost Entity
function God.Create(entity)
    Illusion.ReplaceIfNecessary(entity)
    if entity.valid then
        if entity.type == "tile-ghost" then
            -- Tiles are simple Revives
            entity.silent_revive({ raise_revive = true })
        elseif entity.type == "item-request-proxy" then
            -- Requests are simple
            God.InsertRequests(entity)
        elseif entity.type == "entity-ghost" then
            -- Entities might also want Items after Reviving
            local _, revived, request = entity.silent_revive({
                return_item_request_proxy = true,
                raise_revive = true
            })

            if revived and request then
                God.InsertRequests(request)
            end
        end
    end
end

-- Immediately turn one Entity into another
function God.Upgrade(entity)
    if entity.valid
            and entity.to_be_upgraded()
    then
        local target = entity.get_upgrade_target()
        local direction = entity.get_upgrade_direction()

        if Illusion.IsIllusion(entity.name) and
            Illusion.GetActualName(entity.name) == target.name
         then
            log("Cancelling an Upgrade from an Illusion to its Real Entity: " .. entity.name)
            entity.cancel_upgrade(entity.force)
            return
        end

        local options = {
            name = target.name,
            position = entity.position,
            direction = direction or entity.direction,
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
function God.OnInventoryChanged(event)
    local player = game.players[event.player_index]
    local playerData = global.players[event.player_index]
    if Sandbox.IsPlayerInsideSandbox(player) then
        Inventory.Prune(player)
        playerData.sandboxInventory = Inventory.Persist(
                player.get_main_inventory(),
                playerData.sandboxInventory
        )
    end
end

-- Ensure newly-crafted Items are put into the Cursor for use
function God.OnPlayerCraftedItem(event)
    local player = game.players[event.player_index]
    if Sandbox.IsPlayerInsideSandbox(player)
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

function God.AsyncWrapper(setting, queue, handler, entity)
    if settings.global[setting].value == 0 then
        handler(entity)
    else
        Queue.Push(queue, entity)
    end
end

function God.ShouldHandleEntity(entity)
    if not Sandbox.IsSandboxForce(entity.force) then
        return false
    end

    local name = Illusion.GhostOrRealName(entity)
    if God.skipHandlingEntities[name] then
        return false
    end

    return Lab.IsLab(entity.surface)
            or SpaceExploration.IsSandbox(entity.surface)
            or (Factorissimo.IsFactory(entity.surface)
            and Factorissimo.IsFactoryInsideSandbox(entity.surface, entity.position))
end

-- Ensure new Orders are handled
function God.OnMarkedForDeconstruct(event)
    -- log("Entity Deconstructing: " .. event.entity.unit_number .. " " .. event.entity.type)
    if God.ShouldHandleEntity(event.entity) then
        God.AsyncWrapper(
                Settings.godAsyncDeleteRequestsPerTick,
                global.asyncDestroyQueue,
                God.Destroy,
                event.entity
        )
    end
end

-- Ensure new Orders are handled
function God.OnMarkedForUpgrade(event)
    -- log("Entity Upgrading: " .. event.entity.unit_number .. " " .. event.entity.type)
    if God.ShouldHandleEntity(event.entity) then
        God.AsyncWrapper(
                Settings.godAsyncUpgradeRequestsPerTick,
                global.asyncUpgradeQueue,
                God.Upgrade,
                event.entity
        )
    end
end

-- Ensure new Ghosts are handled
function God.OnBuiltEntity(entity)
    -- log("Entity Creating: " .. entity.unit_number .. " " .. entity.type)
    if God.ShouldHandleEntity(entity) then
        God.AsyncWrapper(
                Settings.godAsyncCreateRequestsPerTick,
                global.asyncCreateQueue,
                God.Create,
                entity
        )
    end
end

-- For each known Sandbox Surface, handle any async God functionality
function God.HandleAllSandboxRequests(event)
    local createRequestsPerTick = settings.global[Settings.godAsyncCreateRequestsPerTick].value
    local upgradeRequestsPerTick = settings.global[Settings.godAsyncUpgradeRequestsPerTick].value
    local deleteRequestsPerTick = settings.global[Settings.godAsyncDeleteRequestsPerTick].value

    local destroyRequestsHandled = 0
    while Queue.Size(global.asyncDestroyQueue) > 0
            and deleteRequestsPerTick > 0
    do
        God.Destroy(Queue.Pop(global.asyncDestroyQueue))
        destroyRequestsHandled = destroyRequestsHandled + 1
        deleteRequestsPerTick = deleteRequestsPerTick - 1
    end
    if Queue.Size(global.asyncDestroyQueue) == 0
            and destroyRequestsHandled > 0
    then
        global.asyncDestroyQueue = Queue.New()
    end

    local upgradeRequestsHandled = 0
    while Queue.Size(global.asyncUpgradeQueue) > 0
            and upgradeRequestsPerTick > 0
    do
        God.Upgrade(Queue.Pop(global.asyncUpgradeQueue))
        upgradeRequestsHandled = upgradeRequestsHandled + 1
        upgradeRequestsPerTick = upgradeRequestsPerTick - 1
    end
    if Queue.Size(global.asyncUpgradeQueue) == 0
            and upgradeRequestsHandled > 0
    then
        global.asyncUpgradeQueue = Queue.New()
    end

    local createRequestsHandled = 0
    while Queue.Size(global.asyncCreateQueue) > 0
            and createRequestsPerTick > 0
    do
        God.Create(Queue.Pop(global.asyncCreateQueue))
        createRequestsHandled = createRequestsHandled + 1
        createRequestsPerTick = createRequestsPerTick - 1
    end
    if Queue.Size(global.asyncCreateQueue) == 0
            and createRequestsHandled > 0
    then
        global.asyncCreateQueue = Queue.New()
    end
end

-- Charts each Sandbox that a Player is currently inside of
function God.ChartAllOccupiedSandboxes()
    if settings.global[Settings.scanSandboxes].value then
        local charted = {}
        for _, player in pairs(game.players) do
            local hash = player.force.name .. player.surface.name
            if Sandbox.IsSandbox(player.surface) and not charted[hash] then
                player.force.chart_all(player.surface)
                charted[hash] = true
            end
        end
    end
end

return God
