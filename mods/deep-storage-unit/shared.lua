-- shared code between memory units and fluid memory units

local min = math.min
local floor = math.floor

local function compactify(n)
	n = floor(n)

	local suffix = 1
	local new
	while n >= 1000 do
		new = floor(n / 100) / 10
		if n == new then
			return {"big-numbers.infinity"}
		else
			n = new
		end
		suffix = suffix + 1
	end

	if suffix ~= 1 and floor(n) == n then n = tostring(n) .. ".0" end

	return {"big-numbers." .. suffix, n}
end

local function open_inventory(player)
	if not storage.blank_gui_item then
		local inventory = game.create_inventory(1)
		inventory[1].set_stack("blank-gui-item")
		inventory[1].allow_manual_label_change = false
		storage.empty_gui_item = inventory[1]
	end
	player.opened = nil
	player.opened = storage.empty_gui_item
	return player.opened
end

local function update_display_text(unit_data, entity, localised_string)
	if unit_data.text then
		local render_object = rendering.get_object_by_id(unit_data.text)
		if render_object then
			render_object.text = localised_string
			return
		end
	end
		
	unit_data.text = rendering.draw_text {
		surface = entity.surface,
		target = entity,
		text = localised_string,
		alignment = "center",
		scale = 1.5,
		only_in_alt_mode = true,
		color = {r = 1, g = 1, b = 1}
	}.id
end

local function update_combinator(combinator, signal, count)
	local control = combinator.get_or_create_control_behavior()
	count = min(2147483647, count)

	control.get_section(1).set_slot(1, {
		value = signal,
		min = count,
		max = count,
		count = count
	})
end

local power_usages = {
	["0W"] = 0,
	["60kW"] = 1000,
	["180kW"] = 3000,
	["300kW"] = 5000,
	["480kW"] = 8000,
	["600kW"] = 10000,
	["1.2MW"] = 20000,
	["2.4MW"] = 40000,
	["3.6MW"] = 40000 / 2.4 * 3.6,
	["5MW"] = 40000 / 2.4 * 5,
	["10MW"] = 40000 / 2.4 * 10,
	["20MW"] = 40000 / 2.4 * 20,
	["50MW"] = 40000 / 2.4 * 50,
}

local base_usage = 1000000 / 60
local function update_power_usage(unit_data, count)
	local powersource = unit_data.powersource
	local power_usage = (math.ceil(count / (unit_data.stack_size or 1000)) ^ 0.35) * power_usages[settings.global["memory-unit-power-usage"].value]
	power_usage = power_usage + base_usage
	powersource.power_usage = power_usage
	powersource.electric_buffer_size = power_usage
end

local update_rate = 15
local update_slots = 4

local function has_power(powersource, entity)
	if powersource.energy < powersource.electric_buffer_size * 0.9 then
		if powersource.energy ~= 0 then
			rendering.draw_sprite {
				sprite = "utility.electricity_icon",
				x_scale = 0.5,
				y_scale = 0.5,
				target = entity,
				surface = entity.surface,
				time_to_live = 30
			}
		end
		return false
	end

	return not entity.to_be_deconstructed()
end

local function is_spoilable(item)
	return prototypes.item[item].get_spoil_ticks() ~= 0
end

local function memory_unit_corruption(unit_number, unit_data)
	local entity = unit_data.entity
	local powersource = unit_data.powersource
	local combinator = unit_data.combinator

	if entity.valid then entity.destroy() end
	if powersource.valid then powersource.destroy() end
	if combinator.valid then combinator.destroy() end

	game.print {"memory-unit-corruption", unit_data.count, unit_data.item or "nothing"}
	storage.units[unit_number] = nil
end

local function validity_check(unit_number, unit_data, force)
	if not unit_data.entity.valid or not unit_data.powersource.valid or not unit_data.combinator.valid then
		memory_unit_corruption(unit_number, unit_data)
		return true
	end

	if not force and not has_power(unit_data.powersource, unit_data.entity) then return true end
	return false
end

local function combine_tempatures(first_count, first_tempature, second_count, second_tempature)
	if first_tempature == second_tempature then return first_tempature end
	local total_count = first_count + second_count
	return (first_tempature * first_count / total_count) + (second_tempature * second_count / total_count)
end

return {
	update_display_text = update_display_text,
	update_combinator = update_combinator,
	has_power = has_power,
	update_power_usage = update_power_usage,
	update_rate = update_rate,
	update_slots = update_slots,
	compactify = compactify,
	open_inventory = open_inventory,
	is_spoilable = is_spoilable,
	memory_unit_corruption = memory_unit_corruption,
	validity_check = validity_check,
	combine_tempatures = combine_tempatures
}
