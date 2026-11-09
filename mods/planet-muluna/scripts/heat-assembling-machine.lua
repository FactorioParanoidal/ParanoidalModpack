local rro = Muluna.rro

local heat_assembling_machines = Muluna.constants.heat_assembling_machines

local function move_entity_to_bottom_layer(entity)
    local direction = entity.direction
    local mirroring = entity.mirroring
    entity.rotate{reverse=false}
    entity.rotate{reverse=true}
    if entity.direction ~= direction then entity.direction = direction end
    if entity.mirroring ~= mirroring then entity.mirroring = mirroring end
end
local heat_assembler_filters = {}
for entity_name,machine in pairs(heat_assembling_machines) do
    table.insert(heat_assembler_filters,{filter = "name", name =  machine["assembling-machine"]})
    table.insert(heat_assembler_filters,{filter = "ghost_name", name =  machine["assembling-machine"]})
    table.insert(heat_assembler_filters,{filter = "name", name = machine["reactor"]})
    table.insert(heat_assembler_filters,{filter = "ghost_name", name = machine["reactor"]})
end
Muluna.events.on_event(Muluna.events.events.on_built(), function(event)
    
    local entity = event.entity

    local is_heat_assembling_machine = false
    local heat_assembling_machine_data = {}
    for _,machine in pairs(heat_assembling_machines) do
        if entity.valid and entity.name == machine["assembling-machine"] then
            is_heat_assembling_machine = true
            heat_assembling_machine_data = machine
            break
        end
    end
    local reactor = nil
    if is_heat_assembling_machine then
        local blueprint_direction, blueprint_mirroring
        if Muluna.compound_entities then
            blueprint_direction, blueprint_mirroring = Muluna.compound_entities.restore_blueprint_direction(entity, event.tags)
        end
        if blueprint_direction ~= nil then entity.direction = blueprint_direction end
        if blueprint_mirroring ~= nil then entity.mirroring = blueprint_mirroring end
        reactor = entity.surface.create_entity{
            name = heat_assembling_machine_data["reactor"],
            position = entity.position,
            direction = entity.direction,
            mirror = entity.mirroring,
            quality = entity.quality,
            force = entity.force,
            source = entity,
            target= entity,
            cause = entity,
            --snap_to_grid = true,
        }
        if not reactor then return end
        --reactor.get_wire_connector(defines.wire_connector_id.circuit_red,true).connect_to(entity.get_wire_connector(defines.wire_connector_id.circuit_red,true))
        --reactor.get_wire_connector(defines.wire_connector_id.circuit_green,true).connect_to(entity.get_wire_connector(defines.wire_connector_id.circuit_green,true))
        move_entity_to_bottom_layer(entity) --Ensures that assembler entity, which has a smaller selection box, is always on top of the reactor entity, which unlike the assembler, can't be rotated.
        reactor.add_fluid_box_linked_connection(1,entity,1) 
        --rendering.draw_sprite{sprite = "item.heat-pipe", target = {entity=reactor,offset = {0,-1}},surface = reactor.surface,only_in_alt_mode = true}
        if not storage.heat_assembling_machines then storage.heat_assembling_machines = {} end
        storage.heat_assembling_machines[entity.unit_number] = {["assembling-machine"]=entity,["reactor"] = reactor, reactor_unit_number = reactor.unit_number}
        -- Reverse index: a destroyed reactor finds its machine in O(1) instead
        -- of scanning every registered machine.
        if not storage.heat_assembling_machine_children then storage.heat_assembling_machine_children = {} end
        storage.heat_assembling_machine_children[reactor.unit_number] = entity.unit_number
    end


end,
heat_assembler_filters
)



---Find the storage key of the machine that owns `child`.
---
---The reverse index is populated when a machine is built. Entries registered
---before the index existed (an older save) fall back to the original scan.
---@param child LuaEntity
---@return uint|nil
local function find_heat_machine_unit_number(child)
    local children = storage.heat_assembling_machine_children
    local unit_number = children and children[child.unit_number]
    local entry = unit_number and storage.heat_assembling_machines and storage.heat_assembling_machines[unit_number]
    -- Verify the entry really owns this child: a unit number can be reassigned
    -- when a prototype changes type, which would leave a stale index entry.
    if entry and entry.reactor == child then
        return unit_number
    end
    for candidate_unit_number, entry in pairs(storage.heat_assembling_machines or {}) do
        if entry.reactor == child then
            return candidate_unit_number
        end
    end
end

Muluna.events.on_event(Muluna.events.events.on_destroyed(), function(event)

    local entity = event.entity
    --game.print(entity.name)
    if not entity.valid then return end
    local is_heat_assembling_machine = false
    local heat_assembling_machine_data = {}
    for _,machine in pairs(heat_assembling_machines) do
        if entity.name == machine["assembling-machine"] or entity.name == machine["reactor"] then
            
            is_heat_assembling_machine = true
            heat_assembling_machine_data = machine
            if entity.name == machine["reactor"] then
                        --game.print("roboport!")
                        local parent_unit_number = find_heat_machine_unit_number(entity)
                        local parent = parent_unit_number and storage.heat_assembling_machines[parent_unit_number]
                        if not parent then return end
                        entity = parent["assembling-machine"]
                        if not entity.valid then
                            -- The machine disappeared without a destroy event (for
                            -- example a deleted surface). Drop the pair without
                            -- reading a unit number from the invalid entity.
                            storage.heat_assembling_machines[parent_unit_number] = nil
                            local children = storage.heat_assembling_machine_children
                            if children and parent.reactor_unit_number then
                                children[parent.reactor_unit_number] = nil
                            end
                            return
                        end
            end
            break
        end
    end

    if is_heat_assembling_machine then
        local reactor = nil
        if storage.heat_assembling_machines then
            local entry = storage.heat_assembling_machines[entity.unit_number]
            if entry then
                reactor = entry["reactor"]
                storage.heat_assembling_machines[entity.unit_number] = nil
            else
                -- Entries are keyed by the assembling machine's unit number, so
                -- this only runs for an entry registered under another key.
                for i,registered_machine in pairs(storage.heat_assembling_machines) do
                    if registered_machine["assembling-machine"] == entity then
                        reactor = registered_machine["reactor"]
                        storage.heat_assembling_machines[i] = nil
                        break
                    end
                end
            end
            local children = storage.heat_assembling_machine_children
            if children and reactor then
                children[reactor.unit_number] = nil
                if entry and entry.reactor_unit_number then
                    children[entry.reactor_unit_number] = nil
                end
            end
        end
        --{entity.position[1]+0.5,entity.position[2]+0.5}
        --game.print(reactor)
        if reactor and reactor.valid then
            reactor.destroy()
        end
        if entity.valid then
            entity.destroy()
        end
        -- entity.surface.create_entity{
        --     name = heat_assembling_machine_data["reactor"],
        --     position = entity.position,
        --     direction = entity.direction,
        --     quality = entity.quality,
        --     force = entity.force,
        --     source = entity,
        --     target= entity,
        --     cause = entity,
        --     snap_to_grid = true,
        -- }
    end

end,
heat_assembler_filters)

-- for _,entity in pairs(heat_assembling_machines) do
--     register_for_deconstruction_events(entity["assembling-machine"],storage.heat_assembling_machines)
-- end


-- Muluna.events.on_event(defines.events.on_player_toggled_alt_mode, function()
--     if storage.heat_assembling_machines then
--         for _,player in pairs(game.players) do
--             for _,machine in pairs(storage.heat_assembling_machines) do
                

--             end
--         end
--     end
    



-- end)