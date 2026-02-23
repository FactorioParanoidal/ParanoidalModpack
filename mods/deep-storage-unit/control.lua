require "gui"

local shared = require "shared"
local update_rate = shared.update_rate
local update_slots = shared.update_slots
local compactify = shared.compactify
local validity_check = shared.validity_check

local function setup()
	storage.units = storage.units or {}

	if remote.interfaces["PickerDollies"] then
		remote.call("PickerDollies", "add_blacklist_name", "memory-unit", true)
		remote.call("PickerDollies", "add_blacklist_name", "memory-unit-combinator", true)
	end
end

script.on_init(setup)
script.on_configuration_changed(function()
	storage.items_with_metadata = nil
	setup()

	for unit_number, unit_data in pairs(storage.units) do
		if unit_data.item and not validity_check(unit_number, unit_data) then
			local prototype = prototypes.item[unit_data.item]
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

	local signal = {type = "item", name = unit_data.item, quality = unit_data.quality or "normal"}
	shared.update_combinator(unit_data.combinator, signal, total_count)
	shared.update_display_text(unit_data, entity, compactify(total_count))
	shared.update_power_usage(unit_data, total_count)
end

function set_filter(unit_data)
	local inventory = unit_data.inventory
	local item = unit_data.item
	local entity = unit_data.entity
	local quality = unit_data.quality

	for i = 1, #inventory do
		local stack = inventory[i]
		local filter = {
			name = item,
			quality = quality
		}
		
		if not inventory.set_filter(i, filter) or (stack.valid_for_read and (stack.name ~= item or stack.quality.name ~= quality)) then
			entity.surface.spill_item_stack{
				position = entity.position,
				stack = stack,
				enable_looted = true,
				force = entity.force_index,
				allow_belts = false,
				use_start_position_on_failure = true,
			}
			stack.clear()
			inventory.set_filter(i, filter)
		end
	end
end

local function detect_item(unit_data)
	local inventory = unit_data.inventory
	for _, itemstack in pairs(inventory.get_contents()) do
		local name, quality = itemstack.name, itemstack.quality
		if not shared.is_spoilable(name) then
			unit_data.item = name
			unit_data.quality = quality
			unit_data.stack_size = prototypes.item[name].stack_size
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
	local quality = unit_data.quality

	local inventory_count = inventory.get_item_count{
		name = item,
		quality = quality
	}
	if inventory_count > comfortable then
		local amount_removed = inventory.remove {name = item, count = inventory_count - comfortable, quality = quality}
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
			local amount_added = entity.insert {name = item, count = to_add, quality = quality}
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

	for unit_number, unit_data in pairs(storage.units) do
		if unit_data.lag_id == smooth_ups then
			update_unit(unit_data, unit_number)
		end
	end
end)

local combinator_shift_x = 2.25
local combinator_shift_y = 1.75

local function on_created(event)
	local entity = event.entity
	if entity.name ~= "memory-unit" then return end
	local position = entity.position
	local surface = entity.surface
	local force = entity.force

	local combinator = surface.create_entity {
		name = "memory-unit-combinator",
		position = {position.x + combinator_shift_x, position.y + combinator_shift_y},
		force = force,
		quality = entity.quality
	}
	combinator.operable = false
	combinator.destructible = false

	local powersource = surface.create_entity {
		name = "memory-unit-powersource",
		position = position,
		force = force,
		quality = entity.quality
	}
	powersource.destructible = false

	local unit_data = {
		entity = entity,
		count = 0,
		powersource = powersource,
		combinator = combinator,
		quality = "normal",
		inventory = entity.get_inventory(defines.inventory.chest),
		lag_id = math.random(0, update_slots - 1)
	}
	storage.units[entity.unit_number] = unit_data

	local inventory = event.consumed_items
	local tags = event.tags or (inventory and not inventory.is_empty() and inventory[1].valid_for_read and inventory[1].is_item_with_tags and inventory[1].tags) or nil
	if tags and tags.name and prototypes.item[tags.name] then
		unit_data.count = tags.count
		unit_data.item = tags.name
		unit_data.quality = tags.quality or "normal"
		unit_data.stack_size = prototypes.item[tags.name].stack_size
		unit_data.comfortable = unit_data.stack_size * #unit_data.inventory / 2
		set_filter(unit_data)
		update_unit(unit_data, entity.unit_number, true)
	elseif tags and tags.name and not prototypes.item[tags.name] then
		shared.update_power_usage(unit_data, 0)
		game.print{"mod-gui.migrated-item", tags.count, tags.name, tags.quality or "normal"}
	else
		shared.update_power_usage(unit_data, 0)
	end
end

script.on_event(defines.events.on_built_entity, on_created)
script.on_event(defines.events.on_robot_built_entity, on_created)
script.on_event(defines.events.script_raised_built, on_created)
script.on_event(defines.events.script_raised_revive, on_created)
script.on_event(defines.events.on_space_platform_built_entity, on_created)

script.on_event(defines.events.on_entity_cloned, function(event)
	local entity = event.source
	if entity.name ~= "memory-unit" then return end
	local destination = event.destination

	local unit_data = storage.units[entity.unit_number]
	local position = destination.position
	local surface = destination.surface

	local powersource, combinator = unit_data.powersource, unit_data.combinator

	if powersource.valid then
		powersource = powersource.clone {position = position, surface = surface}
	else
		powersource = surface.create_entity {
			name = "memory-unit-powersource",
			position = position,
			force = force
		}
		powersource.destructible = false
	end

	if combinator.valid then
		combinator = combinator.clone {position = {position.x + combinator_shift_x, position.y + combinator_shift_y}, surface = surface}
	else
		combinator = surface.create_entity {
			name = "memory-unit-combinator",
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
	storage.units[destination.unit_number] = unit_data

	if item then
		set_filter(unit_data)
		update_unit(storage.units[destination.unit_number], destination.unit_number, true)
	end
end)

local function on_destroyed(event)
	local entity = event.entity
	if entity.name ~= "memory-unit" then return end

	local unit_data = storage.units[entity.unit_number]
	storage.units[entity.unit_number] = nil
	unit_data.powersource.destroy()
	unit_data.combinator.destroy()

	local item = unit_data.item
	local count = unit_data.count
	local quality = unit_data.quality
	local buffer = event.buffer

	if buffer and item and count ~= 0 then
		buffer.clear()
		buffer.insert{
			name = "memory-unit-with-tags",
			count = 1,
			quality = entity.quality.name,
			tags = {name = item, count = count, quality = quality},
			custom_description = {
				"item-description.memory-unit-with-tags",
				compactify(count),
				item,
				quality
			}
		}
	end
end

script.on_event(defines.events.on_player_mined_entity, on_destroyed)
script.on_event(defines.events.on_robot_mined_entity, on_destroyed)
script.on_event(defines.events.on_entity_died, on_destroyed)
script.on_event(defines.events.script_raised_destroy, on_destroyed)
script.on_event(defines.events.on_space_platform_mined_entity, on_destroyed)

local function pre_mined(event)
	local entity = event.entity
	if entity.name ~= "memory-unit" then return end

	local unit_data = storage.units[entity.unit_number]
	local item = unit_data.item

	if item then
		local inventory = unit_data.inventory
		local in_inventory = inventory.get_item_count{
			name = item,
			quality = unit_data.quality
		}

		if in_inventory > 0 then
			unit_data.count = unit_data.count + inventory.remove {name = item, count = in_inventory, quality = unit_data.quality}
		end
	end
end

script.on_event(defines.events.on_pre_player_mined_item, pre_mined)
script.on_event(defines.events.on_robot_pre_mined, pre_mined)
script.on_event(defines.events.on_marked_for_deconstruction, pre_mined)
script.on_event(defines.events.on_space_platform_pre_mined, pre_mined)
