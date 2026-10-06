-- Донные насосы: электрический Angels I и тиры II–III — копии его прототипа.
-- Обычный offshore-pump 2.0 с электросетью: без скрытых столбов, выходов и control.lua.
local tiers = require("prototypes.seafloor-pumps.tiers")

local base_name = tiers[1].name
local base_pump = data.raw["offshore-pump"][base_name]
local base_item = data.raw.item[base_name]
if not (base_pump and base_item) then return end

local GRAPHICS = "__zzzparanoidal__/graphics/entity/seafloor-pump/"
local base_sprite = base_pump.graphics_set.base_pictures.north.filename

local function tier_icons(spec, tier)
	local icons = { { icon = GRAPHICS .. spec.sprite .. "-ico.png", icon_size = 32 } }
	local functions = angelsmods and angelsmods.functions
	if functions and functions.add_number_icon_layer then
		icons = functions.add_number_icon_layer(icons, tier, angelsmods.refining.number_tint)
	end
	return icons
end

-- Заменяет только спрайт насоса Angels, сохраняя кадры, сдвиги и прочие слои.
local function retexture(node, filename)
	for key, value in pairs(node) do
		if key == "filename" and value == base_sprite then
			node[key] = filename
		elseif type(value) == "table" then
			retexture(value, filename)
		end
	end
end

local function apply_stats(pump, item, spec, next_spec)
	pump.energy_source = {
		type = "electric",
		usage_priority = "secondary-input",
		emissions_per_minute = { pollution = spec.pollution },
	}
	pump.energy_usage = spec.energy_usage
	pump.pumping_speed = spec.pumping_speed
	pump.max_health = tiers.max_health
	pump.fast_replaceable_group = base_name
	pump.next_upgrade = next_spec and next_spec.name or nil
	item.stack_size = tiers.stack_size
end

local prototypes = {}
for tier, spec in ipairs(tiers) do
	local pump, item = base_pump, base_item
	if tier > 1 then
		local icons = tier_icons(spec, tier)

		pump = table.deepcopy(base_pump)
		pump.name = spec.name
		pump.icon, pump.icons = nil, icons
		pump.minable.result = spec.name
		pump.localised_description = { "entity-description." .. base_name }
		retexture(pump.graphics_set, GRAPHICS .. spec.sprite .. ".png")

		item = table.deepcopy(base_item)
		item.name = spec.name
		item.icon, item.icons = nil, icons
		item.place_result = spec.name
		item.order = (base_item.order or "") .. "-" .. tier

		prototypes[#prototypes + 1] = pump
		prototypes[#prototypes + 1] = item
		prototypes[#prototypes + 1] = {
			type = "recipe",
			name = spec.name,
			enabled = false,
			energy_required = spec.energy_required,
			ingredients = table.deepcopy(spec.ingredients),
			results = { { type = "item", name = spec.name, amount = 1 } },
		}
	end
	apply_stats(pump, item, spec, tiers[tier + 1])
end
data:extend(prototypes)
