require 'gui'

local shared = require 'shared'
local update_rate = shared.update_rate
local update_slots = shared.update_slots
local compactify = shared.compactify
local validity_check = shared.validity_check
local combine_tempatures = shared.combine_tempatures

local function setup()
	global.units = global.units or {}
	
	if remote.interfaces['PickerDollies'] then
		remote.call('PickerDollies', 'add_blacklist_name', 'fluid-memory-unit', true)
		remote.call('PickerDollies', 'add_blacklist_name', 'fluid-memory-unit-combinator', true)
	end
end

script.on_init(setup)
script.on_configuration_changed(function()
	setup()
                               
	for unit_number, unit_data in pairs(global.units) do
		if unit_data.item and not validity_check(unit_number, unit_data) then
			if not game.fluid_prototypes[unit_data.item] then shared.memory_unit_corruption(unit_number, unit_data) end
		end
	end
end)

local min = math.min
local function render_fluid_animation(item, entity)
	local color = game.fluid_prototypes[item].base_color
	rendering.draw_animation{
		animation = 'fluid-memory-unit-animation',
		tint = {
			min(0.9, color.r + 0.2),
			min(0.9, color.g + 0.2),
			min(0.9, color.b + 0.2)
		},
		render_layer = 'higher-object-above',
		target = entity,
		surface = entity.surface
	}
end

local function update_unit_exterior(unit_data, inventory_count)
	local entity = unit_data.entity
	unit_data.previous_inventory_count = inventory_count
	local total_count = unit_data.count + inventory_count

	if inventory_count > 0 then
		local temperature = combine_tempatures(unit_data.count, unit_data.temperature, inventory_count, entity.fluidbox[1].temperature)
		entity.fluidbox[1].temperature = temperature
		unit_data.temperature = temperature
	end

	shared.update_combinator(unit_data.combinator, {type = 'fluid', name = unit_data.item}, total_count)
	shared.update_display_text(unit_data, entity, compactify(total_count))
	shared.update_power_usage(unit_data, total_count)
end

local function detect_item(unit_data)
	local fluidbox = unit_data.entity.fluidbox
	local fluid = fluidbox[1]
	if fluid then
		fluidbox.set_filter(1, {name = fluid.name, force = true})
		render_fluid_animation(fluid.name, unit_data.entity)
		unit_data.item = fluid.name
		unit_data.temperature = fluid.temperature
		return true
	end
	return false
end

local function update_unit(unit_data, unit_number, force)
	local entity = unit_data.entity
	local powersource = unit_data.powersource
	local combinator = unit_data.combinator
	local container = unit_data.container
	
	if validity_check(unit_number, unit_data, force) then return end
	
	local changed = false
	
	if unit_data.item == nil then changed = detect_item(unit_data) end
	local item = unit_data.item
	if item == nil then return end
	local comfortable = unit_data.comfortable
	
	local inventory_count = entity.get_fluid_count(item)
	if inventory_count > comfortable then
		local amount_removed = entity.remove_fluid{name = item, amount = inventory_count - comfortable}
		unit_data.temperature = combine_tempatures(unit_data.count, unit_data.temperature, amount_removed, entity.fluidbox[1].temperature)
		unit_data.count = unit_data.count + amount_removed
		inventory_count = inventory_count - amount_removed
		changed = true
	elseif inventory_count < comfortable then
		if unit_data.previous_inventory_count ~= inventory_count then
			changed = true
		end
		local to_add = comfortable - inventory_count
		if unit_data.count < to_add then
			to_add = unit_data.count
		end
		if to_add ~= 0 then
			local amount_added = entity.insert_fluid{name = item, amount = to_add, temperature = unit_data.temperature}
			unit_data.count = unit_data.count - amount_added
			inventory_count = inventory_count + amount_added
		end
	end
	
	if force or changed then update_unit_exterior(unit_data, inventory_count) end
end

script.on_nth_tick(update_rate, function(event)
	local smooth_ups = event.tick % update_slots
	
	for unit_number, unit_data in pairs(global.units) do
		if unit_data.lag_id == smooth_ups then
			update_unit(unit_data, unit_number)
		end
	end
end)

local function on_created(event)
	local entity = event.created_entity or event.entity
	if entity.name ~= 'fluid-memory-unit' then return end
	local position = entity.position
	local surface = entity.surface
	local force = entity.force
	
	local combinator = surface.create_entity{
		name = 'fluid-memory-unit-combinator',
		position = {position.x, position.y - 1.25},
		force = force
	}
	combinator.operable = false
	combinator.destructible = false
	
	local powersource = surface.create_entity{
		name = 'fluid-memory-unit-powersource',
		position = position,
		force = force
	}
	powersource.destructible = false
	
	local unit_data = {
		entity = entity,
		comfortable = 0.5 * entity.fluidbox.get_capacity(1),
		powersource = powersource,
		combinator = combinator,
		count = 0,
		lag_id = math.random(0, update_slots - 1)
	}
	global.units[entity.unit_number] = unit_data

	local stack = event.stack
	local tags = stack and stack.valid_for_read and stack.type == 'item-with-tags' and stack.tags
	if tags and tags.name then
		unit_data.count = tags.count
		unit_data.temperature = tags.temperature
		unit_data.item = tags.name
		entity.fluidbox.set_filter(1, {name = tags.name, force = true})
		render_fluid_animation(tags.name, entity)
		update_unit(unit_data, entity.unit_number, true)
	else
		shared.update_power_usage(unit_data, 0)
	end
end

script.on_event(defines.events.on_built_entity, on_created)
script.on_event(defines.events.on_robot_built_entity, on_created)
script.on_event(defines.events.script_raised_built, on_created)
script.on_event(defines.events.script_raised_revive, on_created)

script.on_event(defines.events.on_entity_cloned, function(event)
	local entity = event.source
	if entity.name ~= 'fluid-memory-unit' then return end
	local destination = event.destination
	
	local unit_data = global.units[entity.unit_number]
	local position = destination.position
	local surface = destination.surface
	
	local powersource, combinator = unit_data.powersource, unit_data.combinator
               
	if powersource.valid then
		powersource = powersource.clone{position = position, surface = surface}
	else
		powersource = surface.create_entity{
			name = 'memory-unit-powersource',
			position = position,
			force = force
		}
		powersource.destructible = false
	end
	
	if combinator.valid then
		combinator = combinator.clone{position = {position.x, position.y - 1.25}, surface = surface}
	else
		combinator = surface.create_entity{
			name = 'fluid-memory-unit-combinator',
			position = {position.x, position.y - 1.25},
			force = force
		}
		combinator.destructible = false
		combinator.operable = false
	end
	
	local item = unit_data.item
	global.units[destination.unit_number] = {
		powersource = powersource,
		combinator = combinator,
		item = item,
		count = unit_data.count,
		entity = destination,
		temperature = unit_data.temperature,
		comfortable = unit_data.comfortable,
		lag_id = math.random(0, update_slots - 1)
	}
               
	if item then
		render_fluid_animation(item, destination)
		destination.fluidbox.set_filter(1, {name = item, force = true})
		update_unit(global.units[destination.unit_number], destination.unit_number, true)
	end
end)

local function on_destroyed(event)
	local entity = event.entity
	if entity.name ~= 'fluid-memory-unit' then return end
	
	local unit_data = global.units[entity.unit_number]
	global.units[entity.unit_number] = nil
	unit_data.powersource.destroy()
	unit_data.combinator.destroy()
	
	local item = unit_data.item
	local count = unit_data.count
	local buffer = event.buffer
	
	if buffer and item and count ~= 0 then
		buffer.clear()
		buffer.insert('fluid-memory-unit-with-tags')
		local stack = buffer.find_item_stack('fluid-memory-unit-with-tags')
		local temperature = unit_data.temperature
		stack.tags = {name = item, count = count, temperature = temperature}
		stack.custom_description = {
			'item-description.fluid-memory-unit-with-tags',
			compactify(count),
			item,
			string.format('%.2f', temperature)
		}
	end
end

script.on_event(defines.events.on_player_mined_entity, on_destroyed)
script.on_event(defines.events.on_robot_mined_entity, on_destroyed)
script.on_event(defines.events.on_entity_died, on_destroyed)
script.on_event(defines.events.script_raised_destroy, on_destroyed)

local function pre_mined(event)
	local entity = event.entity
	if entity.name ~= 'fluid-memory-unit' then return end
	
	local unit_data = global.units[entity.unit_number]
	local item = unit_data.item
	
	if item then
		local in_inventory = entity.get_fluid_count(item)
		
		if in_inventory > 0 then
			local temperature = entity.fluidbox[1].temperature
			local new_count = unit_data.count + entity.remove_fluid{name = item, amount = in_inventory}
			unit_data.temperature = combine_tempatures(unit_data.count, unit_data.temperature, in_inventory, temperature)
			unit_data.count = new_count
		end
	end
end

script.on_event(defines.events.on_pre_player_mined_item, pre_mined)
script.on_event(defines.events.on_robot_pre_mined, pre_mined)
script.on_event(defines.events.on_marked_for_deconstruction, pre_mined)
