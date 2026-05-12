local F = "__factorissimo-2-notnotmelon__"

-- Circuit connectors

data:extend {{
    type = "item",
    name = "factory-circuit-connector",
    icon = F .. "/graphics/icon/factory-circuit-connector.png",
    icon_size = 64,
    flags = {},
    subgroup = "factorissimo2",
    order = "c-b",
    place_result = "factory-circuit-connector",
    stack_size = 50,
}}

data:extend {{
    type = "electric-pole",
    name = "factory-circuit-connector",
    icon = F .. "/graphics/icon/factory-circuit-connector.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "factory-circuit-connector"},
    max_health = 50,
    corpse = "small-remnants",
    supply_area_distance = 0,
    draw_copper_wires = false,
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    auto_connect_up_to_n_wires = 0,
    pictures = {
        layers = {
            {
                direction_count = 1,
                filename = F .. "/graphics/entity/factory-circuit-connector.png",
                width = 64,
                height = 64,
                scale = 0.51,
            },
            {
                direction_count = 1,
                filename = F .. "/graphics/entity/factory-circuit-connector-sh.png",
                width = 85,
                height = 85,
                scale = 0.51,
                draw_as_shadow = true,
            },
        }
    },
    connection_points = {{
        shadow = {
            red = {0.75, 0.5625},
            green = {0.21875, 0.5625}
        },
        wire = {
            red = {0.28125, 0.15625},
            green = {-0.21875, 0.15625}
        }
    }},
    maximum_wire_distance = 14,
}}

local factory_circuit_connector_invisible = table.deepcopy(data.raw["electric-pole"]["factory-circuit-connector"])
factory_circuit_connector_invisible.name = "factory-circuit-connector-invisible"
factory_circuit_connector_invisible.localised_name = {"entity-name.factory-circuit-connector"}
factory_circuit_connector_invisible.localised_description = {"entity-description.factory-circuit-connector"}
factory_circuit_connector_invisible.pictures = nil
factory_circuit_connector_invisible.selection_box = nil
factory_circuit_connector_invisible.minable = nil
factory_circuit_connector_invisible.corpse = nil
factory_circuit_connector_invisible.hidden = true
factory_circuit_connector_invisible.draw_circuit_wires = false
factory_circuit_connector_invisible.draw_copper_wires = false
factory_circuit_connector_invisible.factoriopedia_alternative = "factory-circuit-connector"
data:extend {factory_circuit_connector_invisible}
