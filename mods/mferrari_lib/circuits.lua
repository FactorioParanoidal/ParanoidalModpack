
function mf_connect_neighbours(entity,target)
local wire_connectors_1 = entity.get_wire_connectors(true)
local wire_connectors_2 = target.get_wire_connectors(true)
wire_connectors_1[defines.wire_connector_id.circuit_red].connect_to(wire_connectors_2[defines.wire_connector_id.circuit_red], false)
wire_connectors_1[defines.wire_connector_id.circuit_green].connect_to(wire_connectors_2[defines.wire_connector_id.circuit_green], false)
end

function mf_connect_power_poles(entity,target)
if entity and target and entity.valid and target.valid then
    local connector1 = entity.get_wire_connector(defines.wire_connector_id.pole_copper,true)
    local connector2 = target.get_wire_connector(defines.wire_connector_id.pole_copper,true)
    connector1.connect_to(connector2,false)
    end
end



function get_circuit_connected_entities(entity)
local circuit_connected_entities = {
    [defines.wire_connector_id.circuit_red] = {},
    [defines.wire_connector_id.circuit_green] = {}}
for _, connector in pairs(entity.get_wire_connectors()) do
    for _, connection in pairs(connector.connections) do
        if connection.target.valid and connection.target.owner.valid then
            table.insert (circuit_connected_entities[connector.wire_connector_id], connection.target.owner)
            --entities_by_wire_type[#entities_by_wire_type+1] = connection.target.owner
        end
    end
end
return circuit_connected_entities
end

--[[
for connection_type, connected_entities in pairs(circuit_connected_entities) do
    for _, connection_target in pairs(connected_entities) do
        log(string.format("Inserter %s is connected via %i to entity %s", inserter, connection_type, connection_target))
    end
end]]

