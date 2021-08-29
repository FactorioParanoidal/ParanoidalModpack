local shared = require 'shared'
local update_rate = shared.update_rate

local min = math.min
local floor, ceil = math.ceil, math.floor
local function compactify(n)
	n = ceil(n)
	
	local suffix = 1
	local new
	while n >= 1000000 do
		new = n / 1000
		if n == new then
			return {'big-numbers.infinity'}
		else
			n = new
		end
		suffix = suffix + 1
	end
	
	if n >= 1000 then
		n = floor(n / 100) / 10
		suffix = suffix + 1
	end
	
	return {'big-numbers.' .. suffix, n}
end

local function setup()
	global.units = global.units or {}
	global.smooth_ups = global.smooth_ups or 0
	
	if remote.interfaces['PickerDollies'] then
		remote.call('PickerDollies', 'add_blacklist_name', 'fluid-memory-unit-container', true)
		remote.call('PickerDollies', 'add_blacklist_name', 'fluid-memory-unit-combinator', true)
	end
end

script.on_init(setup)
script.on_configuration_changed(setup)

local function combine_tempatures(first_count, first_tempature, second_count, second_tempature)
	local total_count = first_count + second_count
	return (first_tempature * first_count / total_count) + (second_tempature * second_count / total_count)
end

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

local function on_created(event)
	local container = event.created_entity or event.entity
	local position = container.position
	local surface = container.surface
	if container.type == 'entity-ghost'	and container.ghost_name == 'fluid-memory-unit-combinator' then
		local entity = container
		if surface.count_entities_filtered{name = 'fluid-memory-unit-combinator', position = entity.position} ~= 0 then
			entity.destroy()
			return
		end
		local x = position.x
		local y = position.y + 1.25
		for _, unit in pairs(surface.find_entities_filtered{ghost_name = 'fluid-memory-unit-container', position = {x, y}}) do
			if unit.position.x == x and unit.position.y == y then 
				_, entity = entity.revive()
				entity.operable = false
				entity.destructible = false
				return
			end
		end
		entity.destroy()
	elseif container.name == 'fluid-memory-unit-container' then
		local force = container.force
		
		local entity = surface.create_entity{
			name = 'fluid-memory-unit',
			position = position,
			force = force
		}
		entity.destructible = false
		
		local combinator_position = {position.x, position.y - 1.25}
		local combinator = surface.find_entity('fluid-memory-unit-combinator', combinator_position)
		if not combinator then
			combinator = surface.create_entity{
				name = 'fluid-memory-unit-combinator',
				position = combinator_position,
				force = force
			}
			combinator.operable = false
			combinator.destructible = false
		end
		
		local powersource = surface.create_entity{
			name = 'fluid-memory-unit-powersource',
			position = position,
			force = force
		}
		powersource.destructible = false
		
		global.units[container.unit_number] = {
			entity = entity,
			comfortable = 0.5 * entity.fluidbox.get_capacity(1),
			powersource = powersource,
			combinator = combinator,
			container = container,
			inventory = container.get_inventory(defines.inventory.chest),
			count = 0,
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
	if source.name ~= 'fluid-memory-unit-container' then return end
	local destination = event.destination
	
	local unit_data = global.units[source.unit_number]
	local position = destination.position
	local surface = destination.surface
	
	local powersource, combinator, entity = unit_data.powersource, unit_data.combinator, unit_data.entity
	
	if entity.valid then
		entity = entity.clone{position = position, surface = surface}
	else
		entity = surface.create_entity{
			name = 'fluid-memory-unit',
			position = position,
			force = force
		}
		entity.destructible = false
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
	local count = unit_data.count
	
	if item and count ~= 0 then
		render_fluid_animation(item, destination)
	end
	
	global.units[destination.unit_number] = {
		container = destination,
		inventory = destination.get_inventory(defines.inventory.chest),
		powersource = powersource,
		combinator = combinator,
		item = item,
		count = count,
		entity = entity,
		temperature = unit_data.temperature,
		comfortable = unit_data.comfortable,
		can_accept_elements = true,
		communications_enabled = true,
		lag_id = math.random(0, update_rate)
	}
end)

local function on_destroyed(event)
	local entity = event.entity
	if entity.type == 'entity-ghost' and entity.ghost_name == 'fluid-memory-unit-container' then
		local position = entity.position
		local combinator = entity.surface.find_entity('fluid-memory-unit-combinator', {position.x, position.y - 1.25})
		if combinator then combinator.destroy() end
	elseif entity.name == 'fluid-memory-unit-container' then
		local unit_data = global.units[entity.unit_number]
		global.units[entity.unit_number] = nil
		unit_data.powersource.destroy()
		unit_data.combinator.destroy()
		unit_data.entity.destroy()
		
		local stack = unit_data.inventory[1]
		if stack.valid_for_read then
			buffer.insert(stack)
		end
		
		local buffer = event.buffer
		local item = unit_data.item
		local count = unit_data.count
		
		if buffer and item and count ~= 0 then
			buffer.insert{name = 'memory-element', count = 1}
			local stack = buffer.find_item_stack('memory-element')
			local temperature = unit_data.temperature
			stack.tags = {name = item, count = count, temperature = temperature}
			stack.custom_description = {
				'item-description.fluid-memory-element-active',
				compactify(count),
				item,
				floor(temperature * 10) / 10
			}
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
	if entity.name ~= 'fluid-memory-unit-container' then return end
	
	local unit_data = global.units[entity.unit_number]
	local item = unit_data.item
	
	entity = unit_data.entity
	
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
		
		if entity.valid == false or powersource.valid == false or combinator.valid == false or unit_data.container.valid == false then
			if entity.valid then
				entity.destroy()
			end
			if powersource.valid then
				powersource.destroy()
			end
			if combinator.valid then
				combinator.destroy()
			end
			game.print{'fluid-unit-corruption', unit_data.count, unit_data.item or 'nothing'}
			global.units[unit_number] = nil
			goto next
		end
		
		if not shared.has_power(powersource, entity) then goto next end
		
		local item = unit_data.item
		local stack = unit_data.inventory[1]
		local changed = false
		
		if item == nil then
			if stack.valid_for_read and stack.name == 'memory-element' and stack.tags.name and game.fluid_prototypes[stack.tags.name] then
				local tags = stack.tags
				unit_data.count = tags.count
				stack.clear()
				changed = true
				item = tags.name
				unit_data.temperature = tags.temperature
			else
				for name, count in pairs(entity.get_fluid_contents()) do
					local fluidbox = entity.fluidbox
					fluidbox.set_filter(1, {name = name, force = true})
					item = name
					unit_data.temperature = fluidbox[1].temperature
					changed = true
					break
				end
			end
			if changed then
				local position = entity.position
				unit_data.item = item
				
				render_fluid_animation(item, entity)
				shared.create_map_tag(unit_data, entity, {type = 'fluid', name = item})
			end
		end
		
		if item == nil then goto next end
		
		if not game.fluid_prototypes[item] then
			local position, force = entity.position, entity.force
			unit_data.container.destroy{raise_destroy = true}
			surface.create_entity{
				name = 'fluid-memory-unit-container',
				position = position,
				force = force,
				raise_built = true
			}
			return
		end
		
		local comfortable = unit_data.comfortable
		local inventory_count = entity.get_fluid_count(item)
		
		if stack.valid_for_read then
			local name = stack.name
			if name == 'memory-element' then
				local tags = stack.tags
				if unit_data.can_accept_elements and tags.name == item then
					local total = unit_data.count + tags.count
					unit_data.temperature = combine_tempatures(unit_data.count, unit_data.temperature, tags.count, tags.temperature)
					unit_data.count = total
					stack.clear()
					changed = true
				end
			elseif name == 'empty-memory-element' then
				if inventory_count ~= 0 then
					local total_count = inventory_count + unit_data.count
					local temperature = combine_tempatures(unit_data.count, unit_data.temperature, inventory_count, entity.fluidbox[1].temperature)
					
					stack.set_stack{name = 'memory-element', count = 1}
					stack.tags = {name = item, count = total_count, temperature = temperature}
					stack.custom_description = {
						'item-description.fluid-memory-element-active',
						compactify(total_count),
						item,
						floor(temperature * 10) / 10
					}
					
					entity.remove_fluid{name = item, amount = inventory_count}
					inventory_count = 0
					unit_data.count = 0
					
					changed = true
					unit_data.can_accept_elements = false
				end
			else
				unit_data.can_accept_elements = true
				if name == 'memory-communicator' then
					shared.toggle_communications(unit_data, entity, stack, {type = 'fluid', name = item})
				end
			end
		else
			unit_data.can_accept_elements = true
		end
		
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
	
		if inventory_count > 0 then
			local temperature = combine_tempatures(unit_data.count, unit_data.temperature, inventory_count, entity.fluidbox[1].temperature)
			entity.fluidbox[1].temperature = temperature
			unit_data.temperature = temperature
		end
	
		shared.update_combinator(combinator, {type = 'fluid', name = item}, total_count)
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
