-- State and behaviour of one fluid memory unit: storage.fluid_units[unit_number] = unit_data.
--
-- unit_data fields:
--   entity, powersource, combinator - the tank and its hidden parts
--   item         - locked fluid (nil while the unit is empty)
--   temperature  - temperature of everything stored in the unit
--   count        - fluid in the counter, outside the tank
--   comfortable  - amount kept in the tank
--   previous_total - last total shown on the combinator/text
--   power, power_factor - power usage written to the power source, quality factor of the unit (caches)
--   text, shown, animation - render object ids, the rounded amount shown by `text`
--   lag_id       - update slot

local shared = require "scripts.shared"

local M = {}

M.name = "fluid-memory-unit"
M.names = {M.name}
M.packed_name = "fluid-memory-unit-with-tags"
M.powersource_name = "fluid-memory-unit-powersource"
M.combinator_name = "fluid-memory-unit-combinator"

local EPSILON = shared.epsilon
-- Temperature differences below this are float noise of the game's own mixing.
local TEMPERATURE_EPSILON = 0.01
local combinator_offset_y = -1.25

local function fluid_exists(name) return prototypes.fluid[name] ~= nil end

function M.combinator_position(position)
	return {position.x, position.y + combinator_offset_y}
end

local function attach_parts(unit_data)
	shared.attach_powersource(unit_data, M.powersource_name)
	shared.attach_combinator(unit_data, M.combinator_name, M.combinator_position(unit_data.entity.position))
end

-- Half of the tank's own volume (get_capacity alone may report a whole connected segment).
function M.comfortable(entity)
	local fluidbox = entity.fluidbox
	local volume = fluidbox.get_prototype(1).volume
	return 0.5 * math.min(volume, fluidbox.get_capacity(1))
end

-- Amount and temperature of the locked fluid in the tank.
function M.buffer(unit_data)
	local fluid = unit_data.entity.fluidbox[1]
	if fluid and fluid.name == unit_data.item then return fluid.amount, fluid.temperature end
	return 0, nil
end

-- Everything stored, tank included.
function M.total(unit_data)
	return unit_data.count + M.buffer(unit_data)
end

-- One temperature for everything stored: mixing keeps the lower one, no weighted average.
-- Fluid that enters an empty unit keeps its own temperature.
function M.mix_temperature(unit_data, buffer_temperature)
	if not buffer_temperature then return end
	local stored = unit_data.temperature
	local had_content = unit_data.count > EPSILON or (unit_data.previous_total or 0) > EPSILON
	if not stored or not had_content or buffer_temperature < stored - TEMPERATURE_EPSILON then
		unit_data.temperature = buffer_temperature
	end
end

function M.render_animation(unit_data)
	shared.destroy_render(unit_data.animation)
	unit_data.animation = nil
	local item = unit_data.item
	if not item then return end
	local entity = unit_data.entity
	local color = prototypes.fluid[item].base_color
	unit_data.animation = rendering.draw_animation {
		animation = "fluid-memory-unit-animation",
		tint = {
			math.min(0.9, color.r + 0.2),
			math.min(0.9, color.g + 0.2),
			math.min(0.9, color.b + 0.2)
		},
		render_layer = "higher-object-above",
		target = entity,
		surface = entity.surface_index
	}.id
end

function M.lock(unit_data, fluid, temperature)
	unit_data.item = fluid
	unit_data.temperature = temperature or prototypes.fluid[fluid].default_temperature
	unit_data.previous_total = nil
	unit_data.entity.fluidbox.set_filter(1, {name = fluid, force = true})
	M.render_animation(unit_data)
end

-- Back to an empty unit without a filter. The counter is dropped: callers make sure it is empty
-- or that its fluid no longer exists.
function M.reset(unit_data)
	unit_data.item = nil
	unit_data.temperature = nil
	unit_data.count = 0
	unit_data.previous_total = nil
	unit_data.entity.fluidbox.set_filter(1, nil)
	M.render_animation(unit_data)
	shared.clear_display_text(unit_data)
	shared.clear_combinator(unit_data.combinator)
	shared.update_power_usage(unit_data, 0)
end

function M.detect_item(unit_data)
	local fluid = unit_data.entity.fluidbox[1]
	if not fluid then return false end
	M.lock(unit_data, fluid.name, fluid.temperature)
	return true
end

-- Drops the record and the hidden parts. `lost`: the unit vanished without an event (logged).
function M.forget(unit_number, unit_data, lost)
	storage.fluid_units[unit_number] = nil
	if unit_data.powersource and unit_data.powersource.valid then unit_data.powersource.destroy() end
	if unit_data.combinator and unit_data.combinator.valid then unit_data.combinator.destroy() end
	shared.destroy_render(unit_data.text)
	shared.destroy_render(unit_data.animation)
	if lost and unit_data.item and (unit_data.count or 0) > EPSILON then
		log(string.format("fluid memory unit %s disappeared without an event: lost %s x %s",
			unit_number, unit_data.count, unit_data.item))
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
		shared.attach_powersource(unit_data, M.powersource_name)
		repaired = true
	end
	if not (unit_data.combinator and unit_data.combinator.valid) then
		shared.attach_combinator(unit_data, M.combinator_name, M.combinator_position(entity.position))
		repaired = true
	end
	if repaired then
		unit_data.previous_total = nil
		shared.update_power_usage(unit_data, M.total(unit_data))
	end
	return true
end

function M.update_exterior(unit_data, total)
	unit_data.previous_total = total
	shared.update_combinator(unit_data.combinator, {type = "fluid", name = unit_data.item, quality = "normal"}, total)
	shared.update_display_text(unit_data, total)
	shared.update_power_usage(unit_data, total)
end

function M.update(unit_data, unit_number, force)
	if not M.ensure_valid(unit_data, unit_number) then return end
	if not force and not shared.has_power(unit_data) then return end
	if not unit_data.item and not M.detect_item(unit_data) then return end

	local entity = unit_data.entity
	local item = unit_data.item
	local comfortable = unit_data.comfortable
	local amount, buffer_temperature = M.buffer(unit_data)
	if amount > EPSILON then M.mix_temperature(unit_data, buffer_temperature) end

	if amount > comfortable then
		local removed = entity.remove_fluid {name = item, amount = amount - comfortable}
		unit_data.count = unit_data.count + removed
		amount = amount - removed
	elseif amount < comfortable and unit_data.count > EPSILON then
		local to_add = math.min(comfortable - amount, unit_data.count)
		if to_add > EPSILON then
			local added = entity.insert_fluid {name = item, amount = to_add, temperature = unit_data.temperature}
			unit_data.count = unit_data.count - added
			amount = amount + added
		end
	end
	if unit_data.count < EPSILON then unit_data.count = 0 end

	local total = unit_data.count + amount
	if force or not unit_data.previous_total or math.abs(total - unit_data.previous_total) > EPSILON then
		M.update_exterior(unit_data, total)
	end
end

-- Moves the tank contents into the counter (before mining/deconstruction).
function M.pre_mined(unit_data)
	if not unit_data.item then return end
	local amount, temperature = M.buffer(unit_data)
	if amount <= 0 then return end
	M.mix_temperature(unit_data, temperature)
	unit_data.count = unit_data.count + unit_data.entity.remove_fluid {name = unit_data.item, amount = amount}
end

-- Contents of a packed unit. Renamed fluids follow recorded migrations.
function M.restore_from_tags(unit_data, tags)
	local count = tonumber(tags.count) or 0
	local fluid = shared.resolve("fluid", tags.name, fluid_exists)
	if not fluid then
		game.print {"mod-gui.migrated-fluid", shared.compactify(count), tags.name}
		return
	end
	M.lock(unit_data, fluid, tonumber(tags.temperature))
	unit_data.count = count
end

-- Brings the unit up to date: power, exterior, fluid detection.
function M.refresh(unit_data, unit_number)
	if unit_data.item or M.detect_item(unit_data) then
		M.update(unit_data, unit_number, true)
	else
		shared.update_power_usage(unit_data, 0)
	end
end

-- New record for a unit entity. Hidden parts already standing at their places are taken over.
function M.register(entity, tags)
	local unit_number = entity.unit_number
	local unit_data = {
		entity = entity,
		count = 0,
		comfortable = M.comfortable(entity),
		lag_id = math.random(0, shared.update_slots - 1)
	}
	attach_parts(unit_data)
	storage.fluid_units[unit_number] = unit_data
	script.register_on_object_destroyed(entity)
	if tags and tags.name then M.restore_from_tags(unit_data, tags) end
	M.refresh(unit_data, unit_number)
	return unit_data
end

-- Revalidates a stored unit after a configuration change (mod update, prototype migrations).
function M.migrate(unit_number, unit_data)
	unit_data.count = unit_data.count or 0
	-- Caches: the quality chain, the setting or the power source may have changed.
	unit_data.power, unit_data.power_factor = nil, nil
	if not M.ensure_valid(unit_data, unit_number) then return end
	local entity = unit_data.entity
	script.register_on_object_destroyed(entity)
	unit_data.comfortable = M.comfortable(entity)
	if not unit_data.lag_id or unit_data.lag_id >= shared.update_slots then
		unit_data.lag_id = math.random(0, shared.update_slots - 1)
	end
	-- Render objects were cleared by the caller.
	unit_data.text, unit_data.shown, unit_data.animation = nil, nil, nil

	if unit_data.item then
		local fluid = shared.resolve("fluid", unit_data.item, fluid_exists)
		if fluid then
			M.lock(unit_data, fluid, unit_data.temperature)
		else
			game.print {"mod-gui.migrated-fluid", shared.compactify(unit_data.count), unit_data.item}
			M.reset(unit_data)
		end
	end
	M.refresh(unit_data, unit_number)
end

-- Cloned unit or one of its hidden parts (clone_area clones all of them, in any order).
function M.on_cloned(source, destination)
	local name = source.name
	local surface = destination.surface
	if name == M.name then
		local source_data = storage.fluid_units[source.unit_number]
		local unit_data = {
			entity = destination,
			count = 0,
			comfortable = M.comfortable(destination),
			lag_id = math.random(0, shared.update_slots - 1),
		}
		attach_parts(unit_data)
		storage.fluid_units[destination.unit_number] = unit_data
		script.register_on_object_destroyed(destination)
		if source_data then
			unit_data.count = source_data.count
			if source_data.item then M.lock(unit_data, source_data.item, source_data.temperature) end
		end
		M.refresh(unit_data, destination.unit_number)
		return
	end

	local position = destination.position
	if name == M.combinator_name then
		position = {position.x, position.y - combinator_offset_y}
	end
	local tank = surface.find_entity(M.name, position)
	local unit_data = tank and storage.fluid_units[tank.unit_number]
	if not unit_data then return end -- the unit itself is cloned later and adopts this part

	if name == M.powersource_name then
		if unit_data.powersource ~= destination then
			if unit_data.powersource and unit_data.powersource.valid then
				destination.destroy()
			else
				destination.destructible = false
				unit_data.powersource = destination
				unit_data.power = nil
			end
		end
	elseif unit_data.combinator ~= destination then
		-- Keep the cloned combinator: it keeps the circuit wires of the cloned area.
		if unit_data.combinator and unit_data.combinator.valid then unit_data.combinator.destroy() end
		destination.operable = false
		destination.destructible = false
		unit_data.combinator = destination
		unit_data.previous_total = nil
		M.refresh(unit_data, tank.unit_number)
	end
end

-- Mined unit: the unit item in the buffer is replaced by a packed unit with the contents.
function M.pack(unit_number, unit_data, entity, buffer)
	local item = unit_data.item
	local count = unit_data.count or 0
	if not (buffer and item and count > EPSILON) then return end

	local quality = entity.quality.name
	if buffer.remove {name = M.name, count = 1, quality = quality} == 0 then
		log("fluid memory unit " .. unit_number .. ": mined unit item not found in the buffer")
	end
	local temperature = unit_data.temperature or prototypes.fluid[item].default_temperature
	buffer.insert {
		name = M.packed_name,
		count = 1,
		quality = quality,
		health = entity.health / entity.max_health,
		tags = {name = item, count = count, temperature = temperature},
		custom_description = {
			"item-description.fluid-memory-unit-with-tags",
			shared.compactify(count),
			item,
			string.format("%.1f", temperature)
		}
	}
end

return M
