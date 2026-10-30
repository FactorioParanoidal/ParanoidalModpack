local C = require("shared.config")

local SIZE = {
	[C.FILTER_MODULE] = { width = 2, height = 2, order = "a" },
	[C.CLOSED_MODULE] = { width = 2, height = 3, order = "b" },
}

local function watts(value)
	return tostring(math.floor(value / 1000)) .. "kW"
end

local function joules(value)
	return tostring(math.floor(value / 1000)) .. "kJ"
end

-- A grid module is a battery that only takes energy (output 0): the script spends its charge on
-- filtering while the air reaching it is harmful, so the grid shows how much is left.
for _, module in ipairs(C.MODULES) do
	local size = SIZE[module.name]
	local percent = tostring(math.floor(module.filtration * 100 + 0.5))
	local fields = {
		{ name = { "tpr-tooltip.filtration" }, value = { "tpr-tooltip.percent", percent }, order = 1 },
		{ name = { "tpr-tooltip.module-power" }, value = { "tpr-tooltip.kilowatts", tostring(module.power / 1000) }, order = 2 },
	}
	data:extend({
		{
			type = "battery-equipment",
			name = module.name,
			sprite = {
				filename = C.PATH .. "/graphics/equipment/" .. module.name .. ".png",
				width = size.width * 64,
				height = size.height * 64,
				priority = "medium",
				scale = 0.5,
			},
			shape = { width = size.width, height = size.height, type = "full" },
			energy_source = {
				type = "electric",
				buffer_capacity = joules(module.buffer),
				input_flow_limit = watts(module.input),
				output_flow_limit = "0kW",
				usage_priority = "tertiary",
			},
			categories = { "armor" },
			-- No custom_tooltip_fields here: the item tooltip already shows the fields of
			-- place_as_equipment_result, so a second copy printed every line several times.
		},
		{
			type = "item",
			name = module.name,
			icon = C.PATH .. "/graphics/icons/" .. module.name .. ".png",
			icon_size = 64,
			place_as_equipment_result = module.name,
			subgroup = "utility-equipment",
			order = "z[tpr]-" .. size.order,
			stack_size = 20,
			custom_tooltip_fields = fields,
		},
	})
end
