local Fluid = {}

Fluid.color = {r = 167/255, g = 229/255, b = 255/255}
Fluid.entity_types = {'pipe', 'pipe-to-ground', 'pump', 'storage-tank', 'infinity-pipe', 'offshore-pump'}
Fluid.unlocked = function(force) return force.technologies['factory-connection-type-fluid'].researched end

local blacklist = {
	['factory-fluid-dummy-connector-' .. defines.direction.north] = true,
    ['factory-fluid-dummy-connector-' .. defines.direction.east] = true,
    ['factory-fluid-dummy-connector-' .. defines.direction.south] = true,
    ['factory-fluid-dummy-connector-' .. defines.direction.west] = true
}

local function is_connected(dummy_connector, entity)
	if blacklist[entity.name] then return false end
	for _, e in pairs(dummy_connector.neighbours[1]) do
		if e.unit_number == entity.unit_number then return true end
	end
end

Fluid.replace_entity = function(original, new_name)
	if original.name == new_name then return original end
	
	local surface, position, force, direction, player
	surface = original.surface
	position = original.position
	force = original.force
	direction = original.direction
	player = original.last_user
	local boxes = original.fluidbox
	local box = boxes[1]

	original.destroy()
	local new = surface.create_entity{
		name = new_name,
		position = position,
		force = force,
		direction = direction,
		player = player,
		raise_built = false,
		create_build_effect_smoke = false
	}

	if box ~= nil then
		local new_boxes = new.fluidbox
		new_boxes[1] = box
	end

	return new
end
remote_api.replace_entity = Fluid.replace_entity

Fluid.connect = function(factory, cid, cpos, outside_entity, inside_entity, settings)
	if inside_entity == outside_entity then return nil end
	if not (outside_entity.fluidbox.get_capacity(1) > 0 and inside_entity.fluidbox.get_capacity(1) > 0) then return nil end
	
	local inside_connector = factory.inside_surface.create_entity{
		name = 'factory-fluid-dummy-connector-' .. cpos.direction_in,
		position = {factory.inside_x + cpos.inside_x + cpos.indicator_dx, factory.inside_y + cpos.inside_y + cpos.indicator_dy}
	}
	inside_connector.destructible = false
	inside_connector.operable = false
	inside_connector.rotatable = false
		
	local outside_connector = factory.outside_surface.create_entity{
		name = 'factory-fluid-dummy-connector-' .. cpos.direction_out,
		position = {factory.outside_x + cpos.outside_x - cpos.indicator_dx, factory.outside_y + cpos.outside_y - cpos.indicator_dy}
	}
	outside_connector.destructible = false
	outside_connector.operable = false
	outside_connector.rotatable = false

	if not is_connected(inside_connector, inside_entity) or not is_connected(outside_connector, outside_entity) then 
		inside_connector.destroy()
		outside_connector.destroy()
		return nil
	end

	local p = game.entity_prototypes
	local names = {
		original_inside = inside_entity.name,
		original_outside = outside_entity.name,
		inside_input = p['factory-' .. inside_entity.name .. '-input'] and ('factory-' .. inside_entity.name .. '-input') or inside_entity.name,
		outside_input = p['factory-' .. outside_entity.name .. '-input'] and ('factory-' .. outside_entity.name .. '-input') or outside_entity.name,
		inside_output = p['factory-' .. inside_entity.name .. '-output'] and ('factory-' .. inside_entity.name .. '-output') or inside_entity.name,
		outside_output = p['factory-' .. outside_entity.name .. '-output'] and ('factory-' .. outside_entity.name .. '-output') or outside_entity.name
	}

	if settings.input_mode then
		outside_entity = Fluid.replace_entity(outside_entity, names.outside_input)
		inside_entity = Fluid.replace_entity(inside_entity, names.inside_output)
	else
		outside_entity = Fluid.replace_entity(outside_entity, names.outside_output)
		inside_entity = Fluid.replace_entity(inside_entity, names.inside_input)
	end

	return {
		names = names,
		outside = outside_entity,
		inside = inside_entity,
		inside_connector = inside_connector,
		outside_connector = outside_connector,
		outside_capacity = outside_entity.fluidbox.get_capacity(1),
		inside_capacity = inside_entity.fluidbox.get_capacity(1),
		do_tick_update = true
	}
end

Fluid.recheck = function(conn)
	return conn.outside.valid and conn.inside.valid and conn.inside_connector.valid and conn.outside_connector.valid
	and is_connected(conn.inside_connector, conn.inside) and is_connected(conn.outside_connector, conn.outside)
end

local DELAYS = {5, 10, 30, 120}
local DEFAULT_DELAY = 30

Fluid.indicator_settings = {'d0'}
for _,v in pairs(DELAYS) do
	table.insert(Fluid.indicator_settings, 'd' .. v)
end

local function make_valid_delay(delay)
	for _,v in pairs(DELAYS) do
		if v == delay then return v end
	end
	return 0 -- Catchall
end

Fluid.direction = function(conn)
	if conn._settings.input_mode then
		return 'd' .. make_valid_delay(conn._settings.delay or DEFAULT_DELAY), conn._factory.layout.connections[conn._id].direction_in
	else
		return 'd' .. make_valid_delay(conn._settings.delay or DEFAULT_DELAY), conn._factory.layout.connections[conn._id].direction_out
	end
	
end

Fluid.rotate = function(conn)
	conn._settings.input_mode = not conn._settings.input_mode
	if conn._settings.input_mode then
		conn.outside = Fluid.replace_entity(conn.outside, conn.names.outside_input)
		conn.inside = Fluid.replace_entity(conn.inside, conn.names.inside_output)
		return {'factory-connection-text.input-mode'}
	else
		conn.outside = Fluid.replace_entity(conn.outside, conn.names.outside_output)
		conn.inside = Fluid.replace_entity(conn.inside, conn.names.inside_input)
		return {'factory-connection-text.output-mode'}
	end
	conn.outside_capacity, conn.inside_capacity = conn.inside_capacity, conn.outside_capacity
end

Fluid.adjust = function(conn, positive)
	local delay = conn._settings.delay or DEFAULT_DELAY
	if positive then
		for i = #DELAYS,1,-1 do
			if DELAYS[i] < delay then
				delay = DELAYS[i]
				break
			end
		end
		conn._settings.delay = delay
		return {'factory-connection-text.update-faster', delay}
	else
		for i = 1,#DELAYS do
			if DELAYS[i] > delay then
				delay = DELAYS[i]
				break
			end
		end
		conn._settings.delay = delay
		return {'factory-connection-text.update-slower', delay}
	end
end

local function transfer(from, to, from_cap, to_cap)
	local from_boxes = from.fluidbox
	local from_box = from_boxes[1]
	local to_boxes = to.fluidbox
	local to_box = to_boxes[1]
	if from_box ~= nil then
		if to_box == nil then 
			if from_box.amount <= to_cap then
				from_boxes[1] = nil
				to_boxes[1] = from_box
			else
				from_box.amount = from_box.amount - to_cap
				from_boxes[1] = from_box
				from_box.amount = to_cap
				to_boxes[1] = from_box
			end
		elseif to_box.name == from_box.name then
			local total = from_box.amount + to_box.amount
			if total <= to_cap then
				from_boxes[1] = nil
				to_box.temperature = (from_box.amount*from_box.temperature + to_box.amount*to_box.temperature)/total
				to_box.amount = total
				to_boxes[1] = to_box
			else
				to_box.temperature = (to_box.amount*to_box.temperature + (to_cap-to_box.amount)*from_box.temperature)/to_cap
				to_box.amount = to_cap
				to_boxes[1] = to_box
				from_box.amount = total - to_cap
				from_boxes[1] = from_box
			end
		end
	end
end

Fluid.tick = function(conn)
	local outside = conn.outside
	local inside = conn.inside
	local outside_cap = conn.outside_capacity
	local inside_cap = conn.inside_capacity
	if outside.valid and inside.valid then
		local input_mode = conn._settings.input_mode or false
		if input_mode then -- Input
			transfer(outside, inside, outside_cap, inside_cap)
		else -- Output
			transfer(inside, outside, inside_cap, outside_cap)
		end
		return conn._settings.delay or DEFAULT_DELAY
	else
		return false
	end
end

Fluid.destroy = function(conn)
	if conn.outside_connector.valid then conn.outside_connector.destroy() end
	if conn.inside_connector.valid then conn.inside_connector.destroy() end
	if conn.outside.valid then Fluid.replace_entity(conn.outside, conn.names.original_outside) end
	if conn.inside.valid then Fluid.replace_entity(conn.inside, conn.names.original_inside) end
end

return Fluid
