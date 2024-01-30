local Circuit = {}

Circuit.color = {r = 255/255, g = 61/255, b = 61/255}
Circuit.entity_types = {'factory-circuit-connector'}
Circuit.unlocked = function(force) return force.technologies['factory-connection-type-circuit'].researched end

Circuit.connect = function(factory, cid, cpos, outside_entity, inside_entity)
    if outside_entity.name ~= 'factory-circuit-connector' or inside_entity.name ~= 'factory-circuit-connector' then return nil end
	
	local n
	if outside_entity.surface == inside_entity.surface then
		global.middleman_circuit_connectors = global.middleman_circuit_connectors or {}
		local middle = global.middleman_circuit_connectors
		n = #middle + 1
		for i, pole in ipairs(middle) do if pole == 0 then n = i end end
		
		local surface = remote_api.power_middleman_surface()
		local middleman = surface.create_entity{name = 'factory-power-connection', position = {-2*(n%32)-2, 2*math.floor(n/32)}, force = 'neutral'}
		middleman.destructible = false
		middle[n] = middleman
		
		middleman.connect_neighbour{wire = defines.wire_type.red, target_entity = inside_entity}
		middleman.connect_neighbour{wire = defines.wire_type.green, target_entity = inside_entity}
		middleman.connect_neighbour{wire = defines.wire_type.red, target_entity = outside_entity}
		middleman.connect_neighbour{wire = defines.wire_type.green, target_entity = outside_entity}
	else
		outside_entity.connect_neighbour{wire = defines.wire_type.red, target_entity = inside_entity}
		outside_entity.connect_neighbour{wire = defines.wire_type.green, target_entity = inside_entity}
	end
	
    return {inside_entity = inside_entity, outside_entity = outside_entity, do_tick_update = false, middleman_id = n}
end

local function are_connected(pole_1, pole_2)
	local red, green = false, false
	for _, neighbour in pairs(pole_1.neighbours.red) do
		if neighbour == pole_2 then red = true break end
	end
	for _, neighbour in pairs(pole_1.neighbours.green) do
		if neighbour == pole_2 then green = true break end
	end
	return red and green
end

Circuit.recheck = function(conn)
	if not conn.outside_entity.valid or not conn.inside_entity.valid then return false end
	
	if conn.middleman_id then
		local middleman = global.middleman_circuit_connectors[conn.middleman_id]
		if not middleman or middleman == 0 or not middleman.valid then return false end
		return are_connected(conn.outside_entity, middleman) and are_connected(conn.inside_entity, middleman)
	else
		return are_connected(conn.outside_entity, conn.inside_entity)
	end
end

Circuit.indicator_settings = {'b0'}

Circuit.direction = function(conn)
	return 'b0', defines.direction.north
end

Circuit.rotate = Connections.beep

Circuit.adjust = Connections.beep

Circuit.destroy = function(conn)
	local id = conn.middleman_id
	if id then
		local middle = global.middleman_circuit_connectors
		local middleman = middle[id]
		if #middle == id then middle[id] = nil else middle[id] = 0 end
		if middleman and middleman ~= 0 and middleman.valid then middleman.destroy() return end
	else
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
end

return Circuit
