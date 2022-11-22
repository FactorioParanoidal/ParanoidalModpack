require 'gui'

local shared = require 'shared'
local update_rate = shared.update_rate
local update_slots = shared.update_slots
local compactify = shared.compactify
local validity_check = shared.validity_check

local function setup()
	global.units = global.units or {}
	
	if remote.interfaces['PickerDollies'] then
		remote.call('PickerDollies', 'add_blacklist_name', 'memory-unit', true)
		remote.call('PickerDollies', 'add_blacklist_name', 'memory-unit-combinator', true)
	end
end

script.on_init(setup)
script.on_configuration_changed(function()
	setup()
                               
	for unit_number, unit_data in pairs(global.units) do
		if unit_data.item and not validity_check(unit_number, unit_data) then
			local prototype = game.item_prototypes[unit_data.item]
			if prototype then
				unit_data.stack_size = prototype.stack_size
				unit_data.comfortable = unit_data.stack_size * #unit_data.inventory / 2
			else
				shared.memory_unit_corruption(unit_number, unit_data)
			end
		end
	end
end)

local function update_unit_exterior(unit_data, inventory_count)
	local entity = unit_data.entity
	unit_data.previous_inventory_count = inventory_count
	local total_count = unit_data.count + inventory_count

	shared.update_combinator(unit_data.combinator, {type = 'item', name = unit_data.item}, total_count)
	shared.update_display_text(unit_data, entity, compactify(total_count))
	shared.update_power_usage(unit_data, total_count)
end

function set_filter(unit_data)
	local inventory = unit_data.inventory
	local item = unit_data.item
	local entity = unit_data.entity
	for i = 1, #inventory do
		local stack = inventory[i]
		if not inventory.set_filter(i, item) or (stack.valid_for_read and stack.name ~= item) then
			entity.surface.spill_item_stack(entity.position, stack)
			stack.clear()
			inventory.set_filter(i, item)
		end
	end
end

local function detect_item(unit_data)
	local inventory = unit_data.inventory
	for name, count in pairs(inventory.get_contents()) do
		if shared.check_for_basic_item(name) then
			unit_data.item = name
			unit_data.stack_size = game.item_prototypes[name].stack_size
			unit_data.comfortable = unit_data.stack_size * #inventory / 2
			set_filter(unit_data)
			return true
		end
	end
	return false
end

function update_unit(unit_data, unit_number, force)
	local entity = unit_data.entity
	local powersource = unit_data.powersource
	local combinator = unit_data.combinator
	local container = unit_data.container
	local inventory = unit_data.inventory
	
	if validity_check(unit_number, unit_data, force) then return end
	
	local changed = false
	
	if unit_data.item == nil then changed = detect_item(unit_data) end
	local item = unit_data.item
	if item == nil then return end
	local comfortable = unit_data.comfortable
	
	local inventory_count = inventory.get_item_count(item)
	if inventory_count > comfortable then
		local amount_removed = inventory.remove{name = item, count = inventory_count - comfortable}
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
			local amount_added = entity.insert{name = item, count = to_add}
			unit_data.count = unit_data.count - amount_added
			inventory_count = inventory_count + amount_added
		end
	end
	
	if force or changed then
		inventory.sort_and_merge()
		update_unit_exterior(unit_data, inventory_count)
	end
end

script.on_nth_tick(update_rate, function(event)
	local smooth_ups = event.tick % update_slots
	
	for unit_number, unit_data in pairs(global.units) do
		if unit_data.lag_id == smooth_ups then
			update_unit(unit_data, unit_number)
		end
	end
end)

local combinator_shift_x = 2.25
local combinator_shift_y = 1.75

local function on_created(event)
	local entity = event.created_entity or event.entity
	if entity.name ~= 'memory-unit' then return end
	local position = entity.position
	local surface = entity.surface
	local force = entity.force

	local combinator = surface.create_entity{
		name = 'memory-unit-combinator',
		position = {position.x + combinator_shift_x, position.y + combinator_shift_y},
		force = force
	}
	combinator.operable = false
	combinator.destructible = false
	
	local powersource = surface.create_entity{
		name = 'memory-unit-powersource',
		position = position,
		force = force
	}
	powersource.destructible = false
	
	local unit_data = {
		entity = entity,
		count = 0,
		powersource = powersource,
		combinator = combinator,
		inventory = entity.get_inventory(defines.inventory.chest),
		lag_id = math.random(0, update_slots - 1)
	}
	global.units[entity.unit_number] = unit_data

	local stack = event.stack
	local tags = stack and stack.valid_for_read and stack.type == 'item-with-tags' and stack.tags
	if tags and tags.name then
		unit_data.count = tags.count
		unit_data.item = tags.name
		unit_data.stack_size = game.item_prototypes[tags.name].stack_size
		unit_data.comfortable = unit_data.stack_size * #unit_data.inventory / 2
		set_filter(unit_data)
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
	if entity.name ~= 'memory-unit' then return end
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
		combinator = combinator.clone{position = {position.x + combinator_shift_x, position.y + combinator_shift_y}, surface = surface}
	else
		combinator = surface.create_entity{
			name = 'memory-unit-combinator',
			position = {position.x + combinator_shift_x, position.y + combinator_shift_y},
			force = force
		}
		combinator.destructible = false
		combinator.operable = false
	end
	
	local item = unit_data.item
	unit_data = {
		powersource = powersource,
		combinator = combinator,
		item = item,
		count = unit_data.count,
		entity = destination,
		comfortable = unit_data.comfortable,
		stack_size = unit_data.stack_size,
		inventory = destination.get_inventory(defines.inventory.chest),
		lag_id = math.random(0, update_slots - 1)
	}
	global.units[destination.unit_number] = unit_data
               
	if item then
		set_filter(unit_data)
		update_unit(global.units[destination.unit_number], destination.unit_number, true)
	end
end)

local function on_destroyed(event)
	local entity = event.entity
	if entity.name ~= 'memory-unit' then return end
	
	local unit_data = global.units[entity.unit_number]
	global.units[entity.unit_number] = nil
	unit_data.powersource.destroy()
	unit_data.combinator.destroy()
	
	local item = unit_data.item
	local count = unit_data.count
	local buffer = event.buffer
	
	if buffer and item and count ~= 0 then
		buffer.clear()
		buffer.insert('memory-unit-with-tags')
		local stack = buffer.find_item_stack('memory-unit-with-tags')
		stack.tags = {name = item, count = count}
		stack.custom_description = {
			'item-description.memory-unit-with-tags',
			compactify(count),
			item
		}
	end
end

script.on_event(defines.events.on_player_mined_entity, on_destroyed)
script.on_event(defines.events.on_robot_mined_entity, on_destroyed)
script.on_event(defines.events.on_entity_died, on_destroyed)
script.on_event(defines.events.script_raised_destroy, on_destroyed)

local function pre_mined(event)
	local entity = event.entity
	if entity.name ~= 'memory-unit' then return end
	
	local unit_data = global.units[entity.unit_number]
	local item = unit_data.item
	
	if item then
		local inventory = unit_data.inventory
		local in_inventory = inventory.get_item_count(item)
		
		if in_inventory > 0 then
			unit_data.count = unit_data.count + inventory.remove{name = item, count = in_inventory}
		end
	end
end

script.on_event(defines.events.on_pre_player_mined_item, pre_mined)
script.on_event(defines.events.on_robot_pre_mined, pre_mined)
script.on_event(defines.events.on_marked_for_deconstruction, pre_mined)
