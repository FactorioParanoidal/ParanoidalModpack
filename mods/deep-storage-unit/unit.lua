-- State and behaviour of one memory unit: storage.units[unit_number] = unit_data.
--
-- unit_data fields:
--   entity, powersource, combinator, inventory  - the chest and its hidden parts
--   item, quality       - locked item (nil while the unit is empty)
--   count               - items in the counter, outside the chest
--   stack_size, comfortable - stack size of the item and the amount kept in the chest
--   output_only         - the locked item can no longer be stored (old saves): only given out
--   previous_total      - last total shown on the combinator/text
--   storage_unit        - logistic storage variant (cached on first use; the entity name never changes)
--   text, icon, icon_quality - render object ids
--   lag_id              - update slot

local shared = require "shared"
local variants = require "variants"

local M = {}

local chest = defines.inventory.chest
local combinator_shift_x = 2.25
local combinator_shift_y = 1.75

local function item_exists(name) return prototypes.item[name] ~= nil end
local function quality_exists(name) return prototypes.quality[name] ~= nil end

function M.combinator_position(position)
	return {position.x + combinator_shift_x, position.y + combinator_shift_y}
end

function M.create_powersource(entity)
	local powersource = entity.surface.create_entity {
		name = "memory-unit-powersource",
		position = entity.position,
		force = entity.force,
		quality = entity.quality
	}
	powersource.destructible = false
	return powersource
end

function M.create_combinator(entity)
	local combinator = entity.surface.create_entity {
		name = "memory-unit-combinator",
		position = M.combinator_position(entity.position),
		force = entity.force,
		quality = entity.quality
	}
	combinator.operable = false
	combinator.destructible = false
	return combinator
end

local function comfortable_slots(entity)
	local variant = variants.variants[entity.name]
	return variant and variant.comfortable_slots or shared.comfortable_slots
end

-- Only the storage variant has a storage filter. Cached in unit_data so the update does not read the
-- entity name of every unit.
local function is_storage_unit(unit_data)
	local flag = unit_data.storage_unit
	if flag == nil then
		local variant = variants.variants[unit_data.entity.name]
		flag = variant ~= nil and variant.logistic_mode == "storage"
		unit_data.storage_unit = flag
	end
	return flag
end

-- Storage filter as names (the API reads it back as prototypes); nil without a filter.
local function read_storage_filter(entity)
	local filter = entity.storage_filter
	if not filter then return nil end
	local name, quality = filter.name, filter.quality or "normal"
	if type(name) ~= "string" then name = name.name end
	if type(quality) ~= "string" then quality = quality.name end
	return name, quality
end

-- Storage memory units: robots bring only the locked item. Reapplied when a player changes it.
local function sync_storage_filter(unit_data)
	if not is_storage_unit(unit_data) then return end
	local entity = unit_data.entity
	local name, quality = read_storage_filter(entity)
	local item = unit_data.item
	if item then
		if name ~= item or quality ~= unit_data.quality then
			entity.storage_filter = {name = item, quality = unit_data.quality}
		end
	elseif name then
		entity.storage_filter = nil
	end
end

function M.inventory_count(unit_data)
	if not unit_data.item then return 0 end
	return unit_data.inventory.get_item_count {name = unit_data.item, quality = unit_data.quality}
end

-- First item in the chest that the unit refuses to store, if any.
function M.unsafe_item(unit_data)
	for _, content in pairs(unit_data.inventory.get_contents()) do
		if not shared.is_storable(content.name) then return content.name end
	end
	return nil
end

local function spill(entity, stack)
	entity.surface.spill_item_stack {
		position = entity.position,
		stack = stack,
		enable_looted = true,
		force = entity.force_index,
		allow_belts = false,
		use_start_position_on_failure = true,
	}
	stack.clear()
end

function M.set_filter(unit_data)
	local inventory = unit_data.inventory
	local entity = unit_data.entity
	local item, quality = unit_data.item, unit_data.quality
	local filter = {name = item, quality = quality}
	for i = 1, #inventory do
		local stack = inventory[i]
		if stack.valid_for_read and (stack.name ~= item or stack.quality.name ~= quality) then
			spill(entity, stack)
		end
		inventory.set_filter(i, filter)
	end
end

function M.clear_filter(unit_data)
	local inventory = unit_data.inventory
	for i = 1, #inventory do
		inventory.set_filter(i, nil)
	end
end

-- Alt-mode icon of the stored item (and its quality) above the amount.
function M.update_icon(unit_data)
	shared.destroy_render(unit_data.icon)
	shared.destroy_render(unit_data.icon_quality)
	unit_data.icon, unit_data.icon_quality = nil, nil

	local item = unit_data.item
	if not item then return end
	local entity = unit_data.entity
	unit_data.icon = rendering.draw_sprite {
		sprite = "item/" .. item,
		target = {entity = entity, offset = {0, -0.9}},
		surface = entity.surface,
		x_scale = 1.25,
		y_scale = 1.25,
		only_in_alt_mode = true
	}.id
	local quality = unit_data.quality
	if quality and quality ~= "normal" and prototypes.quality[quality] then
		unit_data.icon_quality = rendering.draw_sprite {
			sprite = "quality/" .. quality,
			target = {entity = entity, offset = {-0.55, -0.35}},
			surface = entity.surface,
			x_scale = 0.6,
			y_scale = 0.6,
			only_in_alt_mode = true
		}.id
	end
end

function M.lock(unit_data, item, quality)
	local prototype = prototypes.item[item]
	unit_data.item = item
	unit_data.quality = quality or "normal"
	unit_data.stack_size = prototype.stack_size
	unit_data.comfortable = prototype.stack_size * comfortable_slots(unit_data.entity)
	unit_data.output_only = (not shared.is_storable(item)) or nil
	unit_data.previous_total = nil
	M.set_filter(unit_data)
	M.update_icon(unit_data)
	sync_storage_filter(unit_data)
end

-- Back to an empty unit without a filter. The counter is dropped: callers make sure it is empty
-- or that its item no longer exists.
function M.reset(unit_data)
	unit_data.item = nil
	unit_data.quality = nil
	unit_data.stack_size = nil
	unit_data.comfortable = nil
	unit_data.output_only = nil
	unit_data.count = 0
	unit_data.previous_total = nil
	M.clear_filter(unit_data)
	M.update_icon(unit_data)
	sync_storage_filter(unit_data)
	shared.destroy_render(unit_data.text)
	unit_data.text = nil
	shared.clear_combinator(unit_data.combinator)
	shared.update_power_usage(unit_data, 0)
end

-- Locks an empty unit to the first item put into it. Waits while the chest holds anything
-- that cannot be stored: locking would spill it.
function M.detect_item(unit_data)
	local candidate
	for _, content in pairs(unit_data.inventory.get_contents()) do
		if not shared.is_storable(content.name) then return false end
		candidate = candidate or content
	end
	if not candidate then
		-- An empty storage unit takes the item of a storage filter set by the player.
		if not is_storage_unit(unit_data) then return false end
		local name, quality = read_storage_filter(unit_data.entity)
		if not (name and shared.is_storable(name) and prototypes.quality[quality]) then return false end
		M.lock(unit_data, name, quality)
		return true
	end
	M.lock(unit_data, candidate.name, candidate.quality)
	return true
end

-- Drops the record and the hidden parts. `lost`: the unit vanished without an event (logged).
function M.forget(unit_number, unit_data, lost)
	storage.units[unit_number] = nil
	if unit_data.powersource and unit_data.powersource.valid then unit_data.powersource.destroy() end
	if unit_data.combinator and unit_data.combinator.valid then unit_data.combinator.destroy() end
	shared.destroy_render(unit_data.text)
	shared.destroy_render(unit_data.icon)
	shared.destroy_render(unit_data.icon_quality)
	if lost and unit_data.item and (unit_data.count or 0) > 0 then
		log(string.format("memory unit %s disappeared without an event: lost %s x %s (%s)",
			unit_number, unit_data.count, unit_data.item, unit_data.quality or "normal"))
	end
end

-- False if the unit is gone. Lost hidden parts are recreated instead of deleting the unit.
function M.ensure_valid(unit_data, unit_number)
	local entity = unit_data.entity
	if not (entity and entity.valid) then
		M.forget(unit_number, unit_data, true)
		return false
	end
	local repaired = false
	if not (unit_data.powersource and unit_data.powersource.valid) then
		unit_data.powersource = M.create_powersource(entity)
		repaired = true
	end
	if not (unit_data.combinator and unit_data.combinator.valid) then
		unit_data.combinator = M.create_combinator(entity)
		repaired = true
	end
	if repaired then
		unit_data.previous_total = nil
		shared.update_power_usage(unit_data, unit_data.count + M.inventory_count(unit_data))
	end
	return true
end

function M.update_exterior(unit_data, total)
	unit_data.previous_total = total
	shared.update_combinator(unit_data.combinator, {type = "item", name = unit_data.item, quality = unit_data.quality}, total)
	shared.update_display_text(unit_data, unit_data.entity, shared.compactify(total))
	shared.update_power_usage(unit_data, total)
end

function M.update(unit_data, unit_number, force)
	if not M.ensure_valid(unit_data, unit_number) then return end
	if not force and not shared.has_power(unit_data.powersource, unit_data.entity) then return end
	if not unit_data.item and not M.detect_item(unit_data) then return end
	sync_storage_filter(unit_data)

	local inventory = unit_data.inventory
	local item, quality = unit_data.item, unit_data.quality
	local comfortable = unit_data.comfortable
	local inventory_count = inventory.get_item_count {name = item, quality = quality}
	local moved = false

	if inventory_count > comfortable then
		if not unit_data.output_only then
			local removed = inventory.remove {name = item, count = inventory_count - comfortable, quality = quality}
			unit_data.count = unit_data.count + removed
			inventory_count = inventory_count - removed
			moved = removed > 0
		end
	elseif inventory_count < comfortable and unit_data.count > 0 then
		local to_add = math.min(comfortable - inventory_count, unit_data.count)
		local added = inventory.insert {name = item, count = to_add, quality = quality}
		unit_data.count = unit_data.count - added
		inventory_count = inventory_count + added
		moved = added > 0
	end

	-- An item that can no longer be stored is released once everything was taken out.
	if unit_data.output_only and unit_data.count == 0 and inventory_count == 0 then
		M.reset(unit_data)
		return
	end

	if moved then inventory.sort_and_merge() end
	local total = unit_data.count + inventory_count
	if force or total ~= unit_data.previous_total then
		M.update_exterior(unit_data, total)
	end
end

-- Keeps the chest at 300 slots whatever the unit quality. Items that do not fit go to the
-- counter (the locked item) or are spilled (anything else); nothing is deleted.
function M.fix_buffer_size(unit_data)
	local entity = unit_data.entity
	local inventory = unit_data.inventory
	local size = #inventory
	if size == shared.buffer_slots then return end

	local item, quality = unit_data.item, unit_data.quality
	local to_counter = item and not unit_data.output_only
	if to_counter then
		local excess = inventory.get_item_count {name = item, quality = quality} - unit_data.comfortable
		if excess > 0 then
			unit_data.count = unit_data.count + inventory.remove {name = item, count = excess, quality = quality}
		end
	end
	inventory.sort_and_merge()

	local overflow = game.create_inventory(size)
	local ok, err = pcall(function()
		entity.set_inventory_size_override(chest, shared.buffer_slots, overflow)
	end)
	if not ok then log("memory unit: chest size override failed: " .. tostring(err)) end
	unit_data.inventory = entity.get_inventory(chest)

	for i = 1, #overflow do
		local stack = overflow[i]
		if stack.valid_for_read then
			if to_counter and stack.name == item and stack.quality.name == quality then
				unit_data.count = unit_data.count + stack.count
				stack.clear()
			else
				spill(entity, stack)
			end
		end
	end
	overflow.destroy()
end

-- Contents of a packed unit. Renamed items follow recorded migrations.
function M.restore_from_tags(unit_data, tags)
	local count = math.floor(tonumber(tags.count) or 0)
	local item = shared.resolve("item", tags.name, item_exists)
	if not item then
		game.print {"mod-gui.migrated-item", shared.compactify(count), tags.name}
		return
	end
	local quality = shared.resolve("quality", tags.quality or "normal", quality_exists) or "normal"
	M.lock(unit_data, item, quality)
	unit_data.count = count
end

-- Brings the unit up to date: power, exterior, item detection.
function M.refresh(unit_data, unit_number)
	if unit_data.item or M.detect_item(unit_data) then
		M.update(unit_data, unit_number, true)
	else
		shared.update_power_usage(unit_data, 0)
	end
end

function M.register(entity, tags)
	local unit_number = entity.unit_number
	local unit_data = {
		entity = entity,
		count = 0,
		powersource = M.create_powersource(entity),
		combinator = M.create_combinator(entity),
		inventory = entity.get_inventory(chest),
		lag_id = math.random(0, shared.update_slots - 1)
	}
	storage.units[unit_number] = unit_data
	script.register_on_object_destroyed(entity)
	M.fix_buffer_size(unit_data)
	if tags and tags.name then M.restore_from_tags(unit_data, tags) end
	M.refresh(unit_data, unit_number)
	return unit_data
end

-- Revalidates a stored unit after a configuration change (mod update, prototype migrations).
function M.migrate(unit_number, unit_data)
	unit_data.count = unit_data.count or 0
	if not M.ensure_valid(unit_data, unit_number) then return end
	local entity = unit_data.entity
	script.register_on_object_destroyed(entity)
	unit_data.inventory = entity.get_inventory(chest)
	if not unit_data.lag_id or unit_data.lag_id >= shared.update_slots then
		unit_data.lag_id = math.random(0, shared.update_slots - 1)
	end
	unit_data.previous_inventory_count = nil
	-- Render objects were cleared by the caller.
	unit_data.text, unit_data.icon, unit_data.icon_quality = nil, nil, nil

	if unit_data.item then
		local item = shared.resolve("item", unit_data.item, item_exists)
		if item then
			local quality = shared.resolve("quality", unit_data.quality or "normal", quality_exists)
			if not quality then
				log("memory unit " .. unit_number .. ": quality " .. tostring(unit_data.quality) .. " removed, contents kept as normal")
				quality = "normal"
			end
			M.lock(unit_data, item, quality)
		else
			game.print {"mod-gui.migrated-item", shared.compactify(unit_data.count), unit_data.item}
			M.reset(unit_data)
		end
	end
	M.fix_buffer_size(unit_data)
	M.refresh(unit_data, unit_number)
end

-- Cloned unit or one of its hidden parts (clone_area clones all of them, in any order).
function M.on_cloned(source, destination)
	local name = source.name
	local surface = destination.surface
	if variants.variants[name] then
		local source_data = storage.units[source.unit_number]
		local position = destination.position
		local unit_data = {
			entity = destination,
			count = 0,
			inventory = destination.get_inventory(chest),
			lag_id = math.random(0, shared.update_slots - 1),
			powersource = surface.find_entity("memory-unit-powersource", position) or M.create_powersource(destination),
			combinator = surface.find_entity("memory-unit-combinator", M.combinator_position(position)) or M.create_combinator(destination)
		}
		unit_data.combinator.operable = false
		unit_data.combinator.destructible = false
		unit_data.powersource.destructible = false
		storage.units[destination.unit_number] = unit_data
		script.register_on_object_destroyed(destination)
		if source_data then
			unit_data.count = source_data.count
			if source_data.item then M.lock(unit_data, source_data.item, source_data.quality) end
		end
		M.fix_buffer_size(unit_data)
		M.refresh(unit_data, destination.unit_number)
		return
	end

	local position = destination.position
	if name == "memory-unit-combinator" then
		position = {position.x - combinator_shift_x, position.y - combinator_shift_y}
	end
	local unit
	for _, unit_name in ipairs(variants.names) do
		unit = surface.find_entity(unit_name, position)
		if unit then break end
	end
	local unit_data = unit and storage.units[unit.unit_number]
	if not unit_data then return end -- the unit itself is cloned later and adopts this part

	if name == "memory-unit-powersource" then
		if unit_data.powersource ~= destination then
			if unit_data.powersource and unit_data.powersource.valid then
				destination.destroy()
			else
				unit_data.powersource = destination
			end
		end
	elseif unit_data.combinator ~= destination then
		-- Keep the cloned combinator: it keeps the circuit wires of the cloned area.
		if unit_data.combinator and unit_data.combinator.valid then unit_data.combinator.destroy() end
		destination.operable = false
		destination.destructible = false
		unit_data.combinator = destination
		unit_data.previous_total = nil
		M.refresh(unit_data, unit.unit_number)
	end
end

return M
