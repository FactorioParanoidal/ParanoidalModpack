local shared = require 'shared'
local update_rate = shared.update_rate

local floor = math.floor
local function compactify(n)
	local suffix = 1
	local new
	while n >= 1000 do
		new = floor(n / 100) / 10
		if n == new then
			return {'big-numbers.infinity'}
		else
			n = new
		end
		suffix = suffix + 1
	end
	return {'big-numbers.' .. suffix, n}
end

local combinator_shift_x = 2.25
local combinator_shift_y = 1.75

local unit_types = {
	['memory-unit'] = true,
	['active-provider-memory-unit'] = true,
	['passive-provider-memory-unit'] = true,
	['storage-memory-unit'] = true,
	['requester-memory-unit'] = true,
	['buffer-memory-unit'] = true
}

local function setup()
	global.units = global.units or {}
	global.smooth_ups = global.smooth_ups or 0
	
	if remote.interfaces['PickerDollies'] then
		for type, _ in pairs(unit_types) do
			remote.call('PickerDollies', 'add_blacklist_name', type, true)
		end
		remote.call('PickerDollies', 'add_blacklist_name', 'memory-unit-combinator', true)
	end
end

script.on_init(setup)
script.on_configuration_changed(setup)

local function on_created(event)
	local entity = event.created_entity or event.entity
	local position = entity.position
	local surface = entity.surface
	
	if entity.type == 'entity-ghost' and entity.ghost_name == 'memory-unit-combinator' then
		if surface.count_entities_filtered{name = 'memory-unit-combinator', position = entity.position} ~= 0 then
			entity.destroy()
			return
		end
		local x = position.x - combinator_shift_x
		local y = position.y - combinator_shift_y
		for _, unit in pairs(surface.find_entities_filtered{type = 'entity-ghost', position = {x, y}}) do
			if unit_types[unit.ghost_name] and unit.position.x == x and unit.position.y == y then
				_, entity = entity.revive()
				entity.operable = false
				entity.destructible = false
				return
			end
		end
		entity.destroy()
	elseif unit_types[entity.name] then
		local force = entity.force
		
		local combinator_position = {position.x + combinator_shift_x, position.y + combinator_shift_y}
		local combinator = surface.find_entity('memory-unit-combinator', combinator_position)
		if not combinator then
			combinator = surface.create_entity{
				name = 'memory-unit-combinator',
				position = combinator_position,
				force = force
			}
			combinator.operable = false
			combinator.destructible = false
		end
		
		local powersource = surface.create_entity{
			name = 'memory-unit-powersource',
			position = position,
			force = force
		}
		powersource.destructible = false
		
		global.units[entity.unit_number] = {
			entity = entity,
			count = 0,
			powersource = powersource,
			combinator = combinator,
			inventory = entity.get_inventory(defines.inventory.chest),
			can_accept_elements = true,
			communications_enabled = true,
			lag_id = math.random(0, update_rate)
		}
	end
end

script.on_event(defines.events.on_built_entity, on_created)
script.on_event(defines.events.on_robot_built_entity, on_created)
script.on_event(defines.events.script_raised_built, on_created)
script.on_event(defines.events.script_raised_revive, on_created)

script.on_event(defines.events.on_entity_cloned, function(event)
	local source = event.source
	if not unit_types[source.name] then return end
	
	local destination = event.destination
	local unit_data = global.units[source.unit_number]
	local position = destination.position
	local surface = destination.surface
	
	local combinator, powersource = unit_data.combinator, unit_data.powersource
	combinator_position = {position.x + combinator_shift_x, position.y + combinator_shift_y}
	if combinator.valid then
		combinator = combinator.clone{position = combinator_position, surface = surface}
	else
		combinator = surface.create_entity{
			name = 'memory-unit-combinator',
			position = combinator_position,
			force = force
		}
		combinator.operable = false
		combinator.destructible = false
	end
	
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
	
	global.units[destination.unit_number] = {
		inventory = destination.get_inventory(defines.inventory.chest),
		powersource = powersource,
		combinator = combinator,
		item = unit_data.item,
		count = unit_data.count,
		entity = destination,
		comfortable = unit_data.comfortable,
		stack_size = unit_data.stack_size,
		can_accept_elements = true,
		communications_enabled = true,
		lag_id = math.random(0, update_rate - 1)
	}
end)

local function on_destroyed(event)
	local entity = event.entity
	if entity.type == 'entity-ghost' and unit_types[entity.ghost_name] then
		local position = entity.position
		local combinator = entity.surface.find_entity('memory-unit-combinator', {position.x + combinator_shift_x, position.y + combinator_shift_y})
		if combinator then combinator.destroy() end
	elseif unit_types[entity.name] then
		local unit_data = global.units[entity.unit_number]
		global.units[entity.unit_number] = nil
		unit_data.powersource.destroy()
		unit_data.combinator.destroy()
		
		local buffer = event.buffer
		local item = unit_data.item
		local count = unit_data.count
		
		if buffer and item and count ~= 0 then
			buffer.insert{name = 'memory-element', count = 1}
			local stack = buffer.find_item_stack('memory-element')
			stack.tags = {name = item, count = count}
			stack.custom_description = {'item-description.memory-element-active', compactify(count), item}
		end
		
		shared.remove_map_tag(unit_data)
	end
end

script.on_event(defines.events.on_player_mined_entity, on_destroyed)
script.on_event(defines.events.on_robot_mined_entity, on_destroyed)
script.on_event(defines.events.on_entity_died, on_destroyed)
script.on_event(defines.events.script_raised_destroy, on_destroyed)

local function pre_mined(event)
	local entity = event.entity
	if not unit_types[entity.name] then return end
	
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

script.on_event(defines.events.on_tick, function(event)
	local smooth_ups = event.tick % update_rate
	global.smooth_ups = smooth_ups
	
	for unit_number, unit_data in pairs(global.units) do
		if unit_data.lag_id ~= smooth_ups then
			goto next
		end
		
		local entity = unit_data.entity
		local powersource = unit_data.powersource
		local combinator = unit_data.combinator
		
		if entity.valid == false or powersource.valid == false or combinator.valid == false then
			if powersource.valid then
				powersource.destroy()
			end
			if combinator.valid then
				combinator.destroy()
			end
			game.print{'memory-unit-corruption', unit_data.count, unit_data.item or 'nothing'}
			global.units[unit_number] = nil
			goto next
		end
		
		if not shared.has_power(powersource, entity) then goto next end
		
		local item = unit_data.item
		local inventory = unit_data.inventory
		local changed = false
		local sort = true
		
		if item == nil then
			for i = 1, #inventory do
				local stack = inventory[i]
				if stack.valid_for_read then
					local name = stack.name
					if name == 'memory-element' then
						local name = stack.tags.name
						if name and game.item_prototypes[name] then
							local tags = stack.tags
							item = tags.name
							unit_data.count = tags.count
							stack.clear()
						else
							goto bad
						end
					elseif name == 'empty-memory-element' or name == 'memory-communicator' then
						goto bad
					else
						item = name
						unit_data.count = 0
					end
					unit_data.item = item
					unit_data.stack_size = game.item_prototypes[item].stack_size
					unit_data.comfortable = unit_data.stack_size * entity.prototype.get_inventory_size(defines.inventory.chest) / 2
					changed = true
					
					shared.create_map_tag(unit_data, entity, {type = 'item', name = item})
					
					break
					::bad::
				end
			end
		end
		
		if item == nil then goto next end
	
		if not game.item_prototypes[item] then
			local position, force, name, surface = entity.position, entity.force, entity.name, entity.surface
			entity.destroy{raise_destroy = true}
			surface.create_entity{
				name = name,
				position = position,
				force = force,
				raise_built = true
			}
			return
		end
	
		local comfortable = unit_data.comfortable
		local inventory_count = inventory.get_item_count(item)
		
		local communicator_found = false
		local element_found, empty_element_found = false, false
		for i = 1, #inventory do
			local stack = inventory[i]
			if stack.valid_for_read then
				local name = stack.name
				if name == 'memory-element' then
					local tags = stack.tags
					if unit_data.can_accept_elements and tags.name == item then
						unit_data.count = unit_data.count + tags.count
						stack.clear()
						changed = true
					end
					
					element_found = true
				elseif communicator_found == false and name == 'memory-communicator' then
					communicator_found = true
					shared.toggle_communications(unit_data, entity, stack, {type = 'item', name = item})
				else
					local total_count = inventory_count + unit_data.count
					if total_count ~= 0 and name == 'empty-memory-element' then
						stack.set_stack{name = 'memory-element', count = 1}
						stack.tags = {name = item, count = total_count}
						stack.custom_description = {'item-description.memory-element-active', compactify(total_count), item}
						
						inventory.remove{name = item, count = inventory_count}
						inventory_count = 0
						unit_data.count = 0
						
						sort = false
						changed = true
						
						empty_element_found = true
						unit_data.can_accept_elements = false
					end
				end
			end
		end
		
		if not element_found and not empty_element_found then
			unit_data.can_accept_elements = true
		end
		
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
				local amount_added = entity.insert{name = item, count = to_add, temperature = unit_data.temperature}
				unit_data.count = unit_data.count - amount_added
				inventory_count = inventory_count + amount_added
			end
		end
		
		if unit_data.communications_enabled then
			if inventory_count == 0 then
				shared.create_alert(unit_data, entity)
			else
				shared.remove_alert(unit_data, entity)
			end
		end
		
		if changed == false then goto next end
		
		unit_data.previous_inventory_count = inventory_count
		local total_count = unit_data.count + inventory_count
		
		if sort then
			inventory.sort_and_merge()
		end
		
		shared.update_combinator(combinator, {type = 'item', name = item}, total_count)
		shared.update_display_text(unit_data, entity, compactify(total_count))
		shared.update_power_usage(unit_data, powersource, total_count)
		
		::next::
	end
end)

if not remote.interfaces['memory-storage'] then
	remote.add_interface('memory-storage', {
		['give-memory-element'] = function(item, count, player)
			player = player or game.player
			if player == nil then error('You need to pass a player since you are not using this from the console') end
			
			if item == nil then player.print{'command-output.bad-args'} return end
			local type
			if game.item_prototypes[item] then
				type = 'item'
			elseif game.fluid_prototypes[item] then
				type = 'fluid'
			else
				player.print{'command-output.bad-item', item}
				return
			end
			
			if count == nil then player.print{'command-output.bad-args'} return end
			if count <= 0 then player.print{'command-output.bad-count'} return end
			
			local inventory = player.get_main_inventory()
			inventory.insert{name = 'memory-element', count = 1}
			for i = 1, #inventory do
				local stack = inventory[i]
				if stack.valid_for_read and stack.name == 'memory-element' then
					local tags = stack.tags
					if next(tags) == nil then
						if type == 'item' then
							stack.tags = {name = item, count = count}
							stack.custom_description = {
								'item-description.memory-element-active',
								compactify(count),
								item
							}
						else
							local temperature = game.fluid_prototypes[item].default_temperature
							stack.tags = {name = item, count = count, temperature = temperature}
							stack.custom_description = {
								'item-description.fluid-memory-element-active',
								compactify(count),
								item,
								temperature
							}
						end
						break
					end
				end
			end
		end
	})
end
