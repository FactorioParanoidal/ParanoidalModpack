Circuit = {}

Circuit.color = {r = 255/255, g = 61/255, b = 61/255}
Circuit.entity_types = {'factory-circuit-connector'}
Circuit.unlocked = function(force) return true end

Circuit.connect = function(factory, cid, cpos, outside_entity, inside_entity)
    if outside_entity.name ~= 'factory-circuit-connector' or inside_entity.name ~= 'factory-circuit-connector' then return nil end
    outside_entity.connect_neighbour{wire = defines.wire_type.red, target_entity = inside_entity}
    outside_entity.connect_neighbour{wire = defines.wire_type.green, target_entity = inside_entity}
    return {inside_entity = inside_entity, outside_entity = outside_entity, do_tick_update = false}
end

Circuit.recheck = function(conn)
	if not conn.outside_entity.valid or not conn.inside_entity.valid then return false end
    local red, green = false, false
    for _, neighbour in pairs(conn.outside_entity.neighbours.red) do
        if neighbour == conn.inside_entity then red = true break end
    end
    for _, neighbour in pairs(conn.outside_entity.neighbours.green) do
        if neighbour == conn.inside_entity then green = true break end
    end
    return red and green
end

Circuit.indicator_settings = {'b0'}

Circuit.direction = function(conn)
	return 'b0', defines.direction.north
end

Circuit.rotate = ConnectionLib.beep

Circuit.adjust = ConnectionLib.beep

Circuit.destroy = function(conn)
    if not Circuit.recheck(conn) then return end
    conn.inside_entity.disconnect_neighbour{
        wire = defines.wire_type.red,
        target_entity = conn.outside_entity
    }
    conn.inside_entity.disconnect_neighbour{
        wire = defines.wire_type.green,
        target_entity = conn.outside_entity
    }
end

script.on_event(defines.events.on_gui_opened, function(event)
	if event.gui_type ~= defines.gui_type.entity then return end
	local entity = event.entity
	if entity == nil or not entity.valid then return end
	if entity.name ~= 'factory-circuit-connector' then return end
	
	local player = game.get_player(event.player_index)
	player.opened = nil
end)
