local EntitySwap = {}
local name_suffix_grounded = "-grounded"

---@param inv_a LuaInventory inventory to transfer FROM
---@param inv_b LuaInventory inventory to transfer TO
function move_inventory_items(inv_a, inv_b)
    -- move all items from inv_a to inv_b
    -- preserves item data but inv_b MUST be able to accept the items or they are dropped on the ground.
    -- inventory A is cleared.
    if inv_a and inv_b then
        local inv_b_len = #inv_b
        for i = 1, #inv_a do
            if inv_a[i].valid_for_read then
                if inv_b_len >= i then
                    if not inv_b[i].transfer_stack(inv_a[i]) then
                        inv_b.insert(inv_a[i])
                    end
                else
                    inv_b.insert(inv_a[i])
                end
            end
        end
        if not inv_a.is_empty() then
            local entity = inv_b.entity_owner
            if entity then
                for i = 1, #inv_a do
                    if inv_a[i].valid_for_read then
                        entity.surface.spill_item_stack {
                            position = entity.position,
                            stack = inv_a[i],
                            enable_looted = true,
                            force = entity.force,
                            allow_belts = false
                        }
                    end
                end
            end
        end
        inv_a.clear()
    end
end

---@param entity LuaEntity
---@param prototype_name string
---@return LuaEntity?
function EntitySwap.swap_structure(entity, prototype_name)
    if storage.remove_placement_restrictions then return end
    local surface = entity.surface
    local recipe
    if entity.type == "assembling-machine" then
        recipe = entity.get_recipe()
    end
    local clone = surface.create_entity {
        name = prototype_name,
        position = entity.position,
        force = entity.force,
        direction = entity.direction,
        recipe = recipe and recipe.name,
        quality = entity.quality,
    }
    ---@cast clone -?
    local crafting_progress
    if recipe then
        --pause crafting so it doesn't attempt to finish a craft during inventory swap
        crafting_progress = entity.crafting_progress
        entity.crafting_progress = 0
    end
    clone.operable = entity.operable
    clone.active = entity.active
    clone.destructible = entity.destructible
    clone.rotatable = entity.rotatable
    local inventories = {}
    for _, inv_type in pairs {
        defines.inventory.fuel,
        defines.inventory.burnt_result,
        defines.inventory.furnace_source,
        defines.inventory.furnace_result,
        defines.inventory.furnace_modules,
        defines.inventory.assembling_machine_input,
        defines.inventory.assembling_machine_output,
        defines.inventory.assembling_machine_modules
    } do
        inventories[inv_type] = inv_type -- no duplicate indexes
    end
    for _, inv_type in pairs(inventories) do
        local inv_a = entity.get_inventory(inv_type)
        local inv_b = clone.get_inventory(inv_type)
        if inv_a and inv_b then
            move_inventory_items(inv_a, inv_b)
        end
    end
    if #entity.fluidbox > 0 then
        local entity_fluidbox = entity.fluidbox
        local clone_fluidbox = clone.fluidbox
        for i = 1, math.min(#entity_fluidbox, #clone_fluidbox) do
            clone_fluidbox[i] = entity_fluidbox[i]
        end
    end
    if crafting_progress then
        clone.crafting_progress = crafting_progress
    end
    local proxy = surface.find_entity("item-request-proxy", entity.position)
    if proxy and next(proxy.item_requests) then
        surface.create_entity {
            name = "item-request-proxy",
            position = entity.position,
            force = entity.force,
            target = clone,
            --modules = util.deep_copy(proxy.item_requests)
            modules = util.deep_copy(proxy.insert_plan),
            removal_plan = util.deep_copy(proxy.removal_plan)
        }
    end
    entity.destroy()
    clone.teleport(clone.position) -- reconnect pipes
    return clone
end

local banned_entities = table.invert {
    "container",
    "logistic-container",
    "infinity-container",
    "linked-container",
    "proxy-container",
    "storage-tank",
    "cargo-wagon",
    "locomotive",
    "fluid-wagon",
    "artillery-wagon",
    "car",
    "spider-vehicle"
}

factorissimo.on_event(factorissimo.events.on_built(), function(event)
    if not script.active_mods["space-exploration"] then
        return
    end

    local entity = event.entity
    if not entity.valid or has_layout(entity.name) then return end

    local surface = entity.surface
    if surface.name ~= "se-spaceship-factory-floor" then
        return
    end

    local entity_type = entity.type == "entity-ghost" and entity.ghost_type or entity.type
    if banned_entities[entity_type] then
        factorissimo.cancel_creation(entity, event.player_index, {"factory-connection-text.se-cannot-build-in-spaceship-factory-building"})
        return
    end

    local grounded_name = entity.name .. name_suffix_grounded
    if not prototypes.entity[grounded_name] then return end
    -- replace with grounded
    EntitySwap.swap_structure(entity, grounded_name)
end)
