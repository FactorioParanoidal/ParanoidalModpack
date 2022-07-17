local type = 'fluid'

local min = math.min

local function remove_map_tag(unit_data)
	local map_tag = unit_data.map_tag
	if map_tag and map_tag.valid then
		map_tag.destroy()
	end
	unit_data.map_tag = nil
end

local function remove_alert(unit_data, entity)
	if unit_data.alert then
		for _, player in pairs(game.players) do
			if player.force == entity.force then
				player.remove_alert{entity = entity}
			end
		end
	end
	unit_data.alert = nil
end

local function create_map_tag(unit_data, entity, icon)
	if not unit_data.map_tag then
		unit_data.map_tag = entity.force.add_chart_tag(entity.surface, {
			position = entity.position,
			icon = icon
		})
	end
end

local alert_category = {type = 'item', name = (type == 'item' and 'memory-unit' or 'fluid-memory-unit')}
local alert_localisation = type == 'item' and 'memory-unit-empty' or 'fluid-memory-unit-empty'
local function create_alert(unit_data, entity)
	for _, player in pairs(game.players) do
		if player.force == entity.force then
			player.add_custom_alert(entity, alert_category, {alert_localisation, entity.localised_name, unit_data.item}, true)
		end
	end
	unit_data.alert = true
end

local function toggle_communications(unit_data, entity, stack, icon)
	stack.clear()
	local enabled = not unit_data.communications_enabled
	unit_data.communications_enabled = enabled

	if enabled then
		create_map_tag(unit_data, entity, icon)
		create_alert(unit_data, entity)
	else
		remove_map_tag(unit_data)
		remove_alert(unit_data, entity)
	end
	
	entity.surface.create_entity{
		name = 'flying-text',
		text = {enabled and 'memory-communications-enabled' or 'memory-communications-disabled'},
		position = entity.position
	}
end

local function update_display_text(unit_data, entity, localised_string)
	if unit_data.text then
		rendering.set_text(unit_data.text, localised_string)
	else
		unit_data.text = rendering.draw_text{
			surface = entity.surface,
			target = entity,
			text = localised_string,
			alignment = 'center',
			scale = 1.5,
			only_in_alt_mode = true,
			color = {r = 1, g = 1, b = 1}
		}
	end
end

local function update_combinator(combinator, signal, count)
	combinator.get_or_create_control_behavior().set_signal(1, {
		signal = signal,
		count = min(2147483647, count)
	})
end

local power_usages = {
	['0W'] = 0,
	['60kW'] = 1000,
	['180kW'] = 3000,
	['300kW'] = 5000,
	['480kW'] = 8000,
	['600kW'] = 10000,
	['1.2MW'] = 20000,
	['2.4MW'] = 40000
}

local base_usage = 1000000 / 60
local function update_power_usage(unit_data, powersource, count)
	local power_usage = (math.ceil(count / (unit_data.stack_size or 1000)) ^ 0.4) * power_usages[settings.global['memory-unit-power-usage'].value]
	power_usage = power_usage + base_usage
	powersource.power_usage = power_usage
	powersource.electric_buffer_size = power_usage
end

local update_rate = 15
local update_slots = 4

local function has_power(powersource, entity)
	if powersource.energy < powersource.electric_buffer_size * 0.9 then
		if powersource.energy ~= 0 then
			rendering.draw_sprite{
				sprite = 'utility.electricity_icon', 
				x_scale = 0.5,
				y_scale = 0.5,
				target = entity, 
				surface = entity.surface,
				time_to_live = update_rate / 2
			}
		end
		return false
	end
	return not entity.to_be_deconstructed()
end

return {
	create_map_tag = create_map_tag,
	remove_map_tag = remove_map_tag,
	create_alert = create_alert,
	remove_alert = remove_alert,
	toggle_communications = toggle_communications,
	update_display_text = update_display_text,
	update_combinator = update_combinator,
	has_power = has_power,
	update_power_usage = update_power_usage,
	update_rate = update_rate,
	update_slots = update_slots
}
