-- remove lamp control signals from the red wire of the lamp

for _, station in pairs(storage.LogisticTrainStops) do
    local lampctrl_wire_connectors = station.lamp_control.get_wire_connectors(true)
    local connector = lampctrl_wire_connectors[defines.wire_connector_id.circuit_red]
    connector.disconnect_all(defines.wire_origin.script)
    connector.disconnect_all(defines.wire_origin.player)
    local total_count = connector.connection_count
end
