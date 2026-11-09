local rro = Muluna.rro

local heat_assembling_machines = Muluna.constants.vacuum_roboports

local status_burner_roboport_refueling = {
    diode = defines.entity_status_diode.yellow,
    label = {"custom-status.muluna-burner-roboport-refueling"}
}

local status_burner_roboport_full = {
    diode = defines.entity_status_diode.green,
    label = {"custom-status.muluna-burner-roboport-full"} 
}

local status_burner_roboport_empty = {
    diode = defines.entity_status_diode.red,
    label = {"custom-status.muluna-burner-roboport-empty"}
}
   
local function move_entity_to_bottom_layer(entity)
    local direction = entity.direction
    local mirroring = entity.mirroring
    entity.rotate{reverse=false}
    entity.rotate{reverse=true}
    if entity.direction ~= direction then entity.direction = direction end
    if entity.mirroring ~= mirroring then entity.mirroring = mirroring end
end
local heat_assembler_filters = {}
for entity_name,machine in pairs(heat_assembling_machines or {}) do
    table.insert(heat_assembler_filters,{filter = "name", name =  machine["roboport"]})
    table.insert(heat_assembler_filters,{filter = "ghost_name", name =  machine["roboport"]})
    table.insert(heat_assembler_filters,{filter = "name", name = machine["refueler"]})
    table.insert(heat_assembler_filters,{filter = "ghost_name", name = machine["refueler"]})
end
Muluna.events.on_event(Muluna.events.events.on_built(), function(event)
    
    local entity = event.entity

    local is_heat_assembling_machine = false
    local heat_assembling_machine_data = {}
    for _,machine in pairs(heat_assembling_machines) do
        if entity.valid and entity.name == machine["refueler"] then
            is_heat_assembling_machine = true
            heat_assembling_machine_data = machine
            break
        end
    end
    local roboport = nil
    if is_heat_assembling_machine then
        local blueprint_direction, blueprint_mirroring
        if Muluna.compound_entities then
            blueprint_direction, blueprint_mirroring = Muluna.compound_entities.restore_blueprint_direction(entity, event.tags)
        end
        if not storage.active_burner_roboports then storage.active_burner_roboports = {} end
        storage.active_burner_roboports[entity.unit_number] = entity
        -- Assigning the fixed recipe resets the machine's flip, so remember the
        -- orientation the player (or the blueprint) actually placed.
        local saved_direction = blueprint_direction or entity.direction
        local saved_mirroring = blueprint_mirroring
        if saved_mirroring == nil then saved_mirroring = entity.mirroring end
        entity.set_recipe("burner-roboport-refuel-muluna","normal")
        if entity.direction ~= saved_direction then entity.direction = saved_direction end
        if entity.mirroring ~= saved_mirroring then entity.mirroring = saved_mirroring end
        roboport = entity.surface.create_entity{
            name = heat_assembling_machine_data["roboport"],
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
        if not roboport then return end
        --reactor.get_wire_connector(defines.wire_connector_id.circuit_red,true).connect_to(entity.get_wire_connector(defines.wire_connector_id.circuit_red,true))
        --reactor.get_wire_connector(defines.wire_connector_id.circuit_green,true).connect_to(entity.get_wire_connector(defines.wire_connector_id.circuit_green,true))
        move_entity_to_bottom_layer(entity) --Ensures that assembler entity, which has a smaller selection box, is always on top of the reactor entity, which unlike the assembler, can't be rotated.
        entity.add_fluid_box_linked_connection(1,entity,1) 
        entity.recipe_locked = true
        entity.custom_status= status_burner_roboport_empty
        roboport.custom_status = entity.custom_status
        --rendering.draw_sprite{sprite = "item.heat-pipe", target = {entity=reactor,offset = {0,-1}},surface = reactor.surface,only_in_alt_mode = true}
        if not storage.burner_roboports then storage.burner_roboports = {} end
        storage.burner_roboports[entity.unit_number] = {["roboport"]=roboport,["refueler"] = entity, roboport_unit_number = roboport.unit_number}
        -- Reverse index: a destroyed roboport finds its refueler in O(1)
        -- instead of scanning every registered roboport.
        if not storage.burner_roboport_children then storage.burner_roboport_children = {} end
        storage.burner_roboport_children[roboport.unit_number] = entity.unit_number
    end


end,
heat_assembler_filters
)



---Find the storage key of the refueler that owns `child`.
---
---The reverse index is populated when a pair is built. Entries registered
---before the index existed (an older save) fall back to the original scan.
---@param child LuaEntity
---@return uint|nil
local function find_burner_roboport_unit_number(child)
    local children = storage.burner_roboport_children
    local unit_number = children and children[child.unit_number]
    local entry = unit_number and storage.burner_roboports and storage.burner_roboports[unit_number]
    -- Verify the entry really owns this child: a unit number can be reassigned
    -- when a prototype changes type, which would leave a stale index entry.
    if entry and entry.roboport == child then
        return unit_number
    end
    for candidate_unit_number, entry in pairs(storage.burner_roboports or {}) do
        if entry.roboport == child then
            return candidate_unit_number
        end
    end
end

Muluna.events.on_event(Muluna.events.events.on_destroyed(), function(event)

    local entity = event.entity
    if not entity.valid then return end
    --game.print(entity.name)
    local is_heat_assembling_machine = false
    local heat_assembling_machine_data = {}
    for _,machine in pairs(heat_assembling_machines) do
        if entity.name == machine["refueler"] or entity.name == machine["roboport"] then
            
            is_heat_assembling_machine = true
            heat_assembling_machine_data = machine
            if entity.name == machine["roboport"] then
                --game.print("roboport!")
                local parent_unit_number = find_burner_roboport_unit_number(entity)
                local parent = parent_unit_number and storage.burner_roboports[parent_unit_number]
                if not parent then return end
                entity = parent.refueler
                if not entity.valid then
                    -- The refueler disappeared without a destroy event (for
                    -- example a deleted surface). Drop the pair without reading
                    -- a unit number from the invalid entity.
                    storage.burner_roboports[parent_unit_number] = nil
                    if storage.active_burner_roboports then
                        storage.active_burner_roboports[parent_unit_number] = nil
                    end
                    local children = storage.burner_roboport_children
                    if children and parent.roboport_unit_number then
                        children[parent.roboport_unit_number] = nil
                    end
                    return
                end
            end
            break
        end
    end
    --game.print(is_heat_assembling_machine)
    if is_heat_assembling_machine then
        local reactor = nil
        local parent = nil
        if storage.burner_roboports then
            local entry = storage.burner_roboports[entity.unit_number]
            if entry then
                reactor = entry["roboport"]
                parent = entry["refueler"]
                storage.burner_roboports[entity.unit_number] = nil
            else
                -- Entries are keyed by the refueler's unit number, so this only
                -- runs for an entry registered under another key.
                for i,registered_machine in pairs(storage.burner_roboports) do
                    if registered_machine["roboport"] == entity then
                        reactor = registered_machine["roboport"]
                        storage.burner_roboports[i] = nil
                        break
                    end
                end
            end
            local children = storage.burner_roboport_children
            if children and reactor then
                children[reactor.unit_number] = nil
                if entry and entry.roboport_unit_number then
                    children[entry.roboport_unit_number] = nil
                end
            end
        end
        --{entity.position[1]+0.5,entity.position[2]+0.5}
        --game.print(reactor)
        if reactor and reactor.valid then
            reactor.destroy()
        end
        
        
        -- entity.surface.create_entity{
        --     name = heat_assembling_machine_data["refueler"],
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
    if storage.active_burner_roboports then
        storage.active_burner_roboports[entity.unit_number] = nil
    end
    if entity.valid then
        entity.destroy()
    end

end,
heat_assembler_filters)

-- 5000 MJ / 2000 MW

local cutoff_energy_high = 0.8 --If energy % is greater/equal than this, stop updating
local cutoff_energy_low = 0.6 --If energy % is lower than this, start updating

local discharge_time_max = 1200 -- Shortest possible time to fully discharge a normal roboport (in ticks)
local dischange_time_threshold = discharge_time_max * (cutoff_energy_high-cutoff_energy_low)
local long_update_tolerance = 0.5 --Higher tolerance is less performant, but less likely to create UX complaints
local long_update_period = dischange_time_threshold / long_update_tolerance --During long update, roboport's energy value is checked to see if they need more energy.


local short_update_period = 60 --Arbitrary choice that should be less than the time to half-fill the energy fluid buffer

local burner_roboports = {}

for _,burner_roboport_table in pairs(Muluna.constants.vacuum_roboports) do
    local roboport= burner_roboport_table.roboport
    table.insert(burner_roboports,roboport)
end

local roboport_max_energy = {}
local roboport_cutoff_energy_low = {}
local roboport_cutoff_energy_high = {}

for _,roboport_name in pairs(burner_roboports) do
    local roboport = prototypes.entity[roboport_name]
    if roboport and roboport.electric_energy_source_prototype and roboport.electric_energy_source_prototype.buffer_capacity then
        roboport_max_energy[roboport.name] = roboport.electric_energy_source_prototype.buffer_capacity
        roboport_cutoff_energy_low[roboport.name]=roboport.electric_energy_source_prototype.buffer_capacity*cutoff_energy_low
        roboport_cutoff_energy_high[roboport.name]=roboport.electric_energy_source_prototype.buffer_capacity*cutoff_energy_high
    end
end

local function calc_energy_percent(roboport) 
    
    local energy = roboport.energy
    local max_energy = roboport_max_energy[roboport.name] --roboport.prototype.electric_energy_source_prototype.buffer_capacity
    return energy/max_energy
end

Muluna.events.on_nth_tick(long_update_period, function()

    for key,entity_table in pairs(storage.burner_roboports) do
        local roboport = entity_table["roboport"]
        local refueler = entity_table["refueler"]
        --local energy_percent = calc_energy_percent(roboport)
        if roboport.valid and refueler.valid then
           if roboport.energy <= roboport_cutoff_energy_low[roboport.name] and refueler.custom_status ~= status_burner_roboport_refueling then
                --storage.active_burner_roboports[key] = refueler
                refueler.disabled_by_script = false --Turns on refueler
                if refueler.get_fluid_count() > 0 then
                    refueler.custom_status = status_burner_roboport_refueling
                else
                    refueler.custom_status = status_burner_roboport_empty
                end
                roboport.custom_status = refueler.custom_status 
            end 
        else
            storage.burner_roboports[key] = nil
        end
        
        ::continue::
    end


end)

local fluid_per_craft = Muluna.constants.burner_roboport_fluid_per_craft
local fluid_removed_amount = fluid_per_craft
local energy_value = 0.1 * 1000000
local delta_energy = (fluid_removed_amount or 0) * energy_value

--Pre 2.1.12, this function was used in a loop on every refueler with low energy in a table to periodically convert proxy fluid into energy. Now, it's done on crafting of a recipe that consumes fuel.
local function short_update_roboport(refueler)
    --local roboport = entity_table["roboport"]
        if not refueler or not refueler.valid then return end
        local key = refueler.unit_number
        local entity_table = storage.burner_roboports and storage.burner_roboports[key]
        if not entity_table then return end
        local roboport = entity_table["roboport"]
        if not roboport or not roboport.valid then return end
        refueler.custom_status = status_burner_roboport_refueling
        roboport.custom_status = refueler.custom_status
        roboport.energy = (roboport.energy or 0) + delta_energy
        if roboport.energy >= roboport_cutoff_energy_high[roboport.name] then
            --storage.active_burner_roboports[key] = nil --Deactivates roboport
            refueler.disabled_by_script = true --Turns off refueler
            refueler.custom_status = status_burner_roboport_full
            roboport.custom_status = refueler.custom_status
            -- Add status
        end

end
script.on_event(prototypes.recipe["burner-roboport-refuel-muluna"].on_crafted_event, function(event)
    short_update_roboport(event.entity)
end)

if script.active_mods["funit"] then
    Muluna.funit.short_update_roboport = short_update_roboport
end


-- Muluna.events.on_nth_tick(short_update_period, function() 

--     for key,refueler in pairs(storage.active_burner_roboports) do
--         short_update_roboport(refueler)
--     end


-- end)
