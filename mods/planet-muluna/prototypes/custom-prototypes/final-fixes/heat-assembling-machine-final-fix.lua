local flib_bounding_box = require("__flib__/bounding-box")

local function move_field(from,to,field)
    to[field] = from[field]
    from[field] = nil


end

local transferred_fields = {
    "heat_buffer",
    "heating_radius",
    "connection_patches_connected",
    "connection_patches_disconnected",
    "heat_connection_patches_connected",
    "heat_connection_patches_disconnected",
    "meltdown_action",
    "neighbour_bonus",
    "picture",
    "working-light-picture",
    --"consumption",
}

local copied_fields = {
    "collision_box",
    "selection_box",
    "circuit_wire_max_distance",
}

for _,machine in pairs(data.raw["assembling-machine"]) do
    if machine.is_heat_assembling_machine then
        local assembler = machine
        local reactor = {
            type = "reactor",
            name = "heat-assembling-machine-" .. machine.name .. "-reactor",
        }
        PlanetsLib.constants.pipette_result[reactor.name] = machine.name

        for _,field in pairs(transferred_fields) do
            move_field(assembler,reactor,field)

        end
        if not assembler.graphics_set then
             local graphics = table.deepcopy(reactor.picture)
             graphics.frame_count = 1
             for _,frame in pairs(graphics.layers) do
                frame.line_length = 1
                frame.frame_count = 1
             end
             assembler.graphics_set =  {animation = {north = graphics}}
        end
        for _,field in pairs(copied_fields) do
            reactor[field] = assembler[field]

        end
        reactor.neighbour_bonus = 0 or reactor.neighbour_bonus
        reactor.selection_box = flib_bounding_box.resize(assembler.selection_box,0.0)
        reactor.selection_priority=49 --Default is 50
        assembler.selection_box = flib_bounding_box.resize(assembler.selection_box,-0.4)
        reactor.circuit_connector = table.deepcopy(assembler.circuit_connector)
        reactor.default_temperature_signal = data.raw["reactor"]["heating-tower"].default_temperature_signal
        reactor.minable = assembler.minable
        for _,connector in pairs(reactor.circuit_connector) do
            for _,wire in pairs(connector) do
                for _,color in pairs(wire) do
                    if color.x then color.x=color.x*1.05 end
                    if color.y then color.y=color.y*1.05 end
                end
            end
        end
        assembler.quality_indicator_shift = {-0.4,0.4}
        reactor.energy_source = {
            type = "void",
            -- fluid_box = {
            --     volume = 10,
            --     pipe_connections = {}
            -- }
        }
        for _,fluid_box in pairs(assembler.fluid_boxes) do
            if fluid_box.production_type == "heat-output" then
                fluid_box.production_type = "output"
                reactor.energy_source = {
                    type = "fluid",
                    fluid_box = table.deepcopy(fluid_box),
                    scale_fluid_usage = true,
                    render_no_power_icon = false,
                    render_no_network_icon = false,
                    hide_from_stats = true
                }
                local new_fluid_box =  reactor.energy_source.fluid_box
                new_fluid_box.production_type = "input"
                --new_fluid_box.linked_connection_id = 1
                new_fluid_box.pipe_connections[1].flow_direction = "input"
                new_fluid_box.pipe_connections[1].position[2] = reactor.energy_source.fluid_box.pipe_connections[1].position[2] - 1
                new_fluid_box.pipe_connections[1].direction = defines.direction.south
                
            end
        end
        reactor.localised_name = {"entity-name.heat-assembling-machine-x-reactor",{"entity-name."..assembler.name}}
        reactor.consumption = Muluna.multiply_energy(machine.energy_usage,machine.effectivity)
        if mods["even-pickier-dollies"] then
            -- Even Pickier Dollies refuses to move an entity when another entity sits
            -- in the destination box. The reactor shares the assembler's collision
            -- box, so make it non-colliding; the assembler keeps the real collision.
            -- scripts/even-pickier-dollies.lua then moves the reactor along with the
            -- assembler.
            reactor.collision_mask = {layers = {}}
        end
        
        Muluna:extend{assembler,reactor}
        data.raw["mod-data"]["bplib"].data.extract_entity_names[assembler.name] = true
        data.raw["mod-data"]["bplib"].data.position_entity_names[assembler.name] = true
        data.raw["mod-data"]["bplib"].data.overlap_entity_names[assembler.name] = true
        table.insert(Muluna.constants.heat_assembling_machines,
            {
                name = machine.name,
                ["assembling-machine"] = assembler.name,
                ["reactor"] = reactor.name
            }
        )
    end
end



data.raw["heat-assembling-machine"] = nil