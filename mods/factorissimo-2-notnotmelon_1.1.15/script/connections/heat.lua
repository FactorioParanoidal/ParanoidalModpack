local Heat = {}

Heat.color = {r = 228/255, g = 236/255, b = 0}
Heat.entity_types = {"heat-pipe"}
Heat.unlocked = function(force) return force.technologies["factory-connection-type-heat"].researched end

Heat.connect = function(factory, cid, cpos, outside_entity, inside_entity)
    local inside_link = inside_entity.surface.create_entity{
        name = 'factory-heat-dummy-connector',
        position = {factory.inside_x + cpos.inside_x + cpos.indicator_dx, factory.inside_y + cpos.inside_y + cpos.indicator_dy},
        create_build_effect_smoke = false,
        raise_built = false,
        force = inside_entity.force
    }
    inside_link.destructible = false
    inside_link.active = false
    
    local outside_link = outside_entity.surface.create_entity{
        name = 'factory-heat-dummy-connector',
        position = {outside_entity.position.x - cpos.indicator_dx, outside_entity.position.y - cpos.indicator_dy},
        create_build_effect_smoke = false,
        raise_built = false,
        force = outside_entity.force
    }
    outside_link.destructible = false
    outside_link.active = false
    
    return {
        outside = outside_entity,
        outside_link = outside_link,
        inside_link = inside_link,
        inside = inside_entity,
        do_tick_update = true
    }
end

Heat.recheck = function (conn)
	return conn.outside.valid and conn.inside.valid and conn.inside_link.valid and conn.outside_link.valid
end

local DELAYS = {5, 10, 30, 120}
local DEFAULT_DELAY = 30

Heat.indicator_settings = {"d0", "b0"}

for _, v in pairs(DELAYS) do
	table.insert(Heat.indicator_settings, "b" .. v)
end

local function make_valid_delay(delay)
	for _,v in pairs(DELAYS) do
		if v == delay then return v end
	end
	return 0 -- Catchall
end

Heat.direction = function (conn)
	return "b" .. make_valid_delay(conn._settings.delay or DEFAULT_DELAY), defines.direction.north
end

Heat.rotate = Connections.beep

Heat.adjust = function (conn, positive)
	local delay = conn._settings.delay or DEFAULT_DELAY
	if positive then
		for i = #DELAYS,1,-1 do
			if DELAYS[i] < delay then
				delay = DELAYS[i]
				break
			end
		end
		conn._settings.delay = delay
		return {"factory-connection-text.update-faster", delay}
	else
		for i = 1,#DELAYS do
			if DELAYS[i] > delay then
				delay = DELAYS[i]
				break
			end
		end
		conn._settings.delay = delay
		return {"factory-connection-text.update-slower", delay}
	end
end

Heat.tick = function(conn)
	local outside = conn.outside
	local inside = conn.inside
	if not outside.valid or not inside.valid then return false end
    
    local temp_1, temp_2 = outside.temperature, inside.temperature
    if temp_1 == temp_2 then return conn._settings.delay or DEFAULT_DELAY end
    
    local average_temp = (temp_1 + temp_2) / 2
    local max_temp_1 = outside.prototype.heat_buffer_prototype.max_temperature
    local max_temp_2 = inside.prototype.heat_buffer_prototype.max_temperature
    
    if max_temp_1 < average_temp then
        outside.temperature = max_temp_1
        inside.temperature = temp_2 - (max_temp_1 - temp_1)
    elseif max_temp_2 < average_temp then
        inside.temperature = max_temp_2
        outside.temperature = temp_1 - (max_temp_2 - temp_2)
    else
        outside.temperature = average_temp
        inside.temperature = average_temp
    end
    
    return conn._settings.delay or DEFAULT_DELAY
end

Heat.destroy = function(conn)
    if conn.outside_link.valid then conn.outside_link.destroy() end
    if conn.inside_link.valid then conn.inside_link.destroy() end
end

return Heat
