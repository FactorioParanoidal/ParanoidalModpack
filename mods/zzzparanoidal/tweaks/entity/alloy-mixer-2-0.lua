-- Здания смесителя сплавов из angelsextended-remelting 2.0.0 (issue #401, решение пользователя
-- 2026-10-20) поверх форка angelsextended-remelting-fixed: загрязнение по тирам как у индукционной
-- печи, цепочка улучшений, буфер жидкости 1000, графика и звук автора 2.0.0 (MIT, Vitaly Mikhailov;
-- файлы скопированы в graphics/alloy-mixer без изменений). Порты, тиры, слоты и цены не меняются.
-- Тир виден по цвету (решение пользователя 2026-10-20): здание, иконки предмета/здания/рецепта
-- и технологии remelting-alloy-mixer-N целиком тонируются цветом маски индукционной печи Angels
-- того же тира (жёлтый, красный, голубой, фиолетовый). tint — умножение при отрисовке, без
-- новых текстур. Цифры тира на иконках не тонируются.
-- После меню литья (иконки рецептов), до approved-icons/icon-markers и graphics-atlas.

local tiers = {
	{ name = "alloy-mixer", pollution = 1.8, next = "alloy-mixer-2", tint = { r = 1, g = 0.718, b = 0.149, a = 1 } },
	{ name = "alloy-mixer-2", pollution = 2.4, next = "alloy-mixer-3", tint = { r = 0.949, g = 0.137, b = 0.094, a = 1 } },
	{ name = "alloy-mixer-3", pollution = 3, next = "alloy-mixer-4", tint = { r = 0.2, g = 0.706, b = 1, a = 1 } },
	{ name = "alloy-mixer-4", pollution = 3.6, tint = { r = 0.706, g = 0.349, b = 1, a = 1 } },
}

local graphics_set = {
	animation = {
		layers = {
			{
				filename = "__zzzparanoidal__/graphics/alloy-mixer/alloy-mixer.png",
				priority = "high",
				width = 224,
				height = 256,
				frame_count = 36,
				line_length = 6,
				animation_speed = 0.5,
				shift = { 0, -0.5 },
			},
		},
	},
}

local working_sound = {
	sound = { filename = "__angelssmeltinggraphics__/sound/casting-machine.ogg" },
	idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
}

local function icons(tier)
	return angelsmods.functions.add_number_icon_layer(
		{ { icon = "__zzzparanoidal__/graphics/alloy-mixer/alloy-mixer-icon.png", icon_size = 64, tint = tiers[tier].tint } },
		tier,
		angelsmods.smelting.number_tint
	)
end

local function set_icons(prototype, tier)
	if not prototype then return end
	prototype.icons = icons(tier)
	prototype.icon = nil
	prototype.icon_size = nil
	prototype.icon_mipmaps = nil
end

for tier, spec in ipairs(tiers) do
	local machine = data.raw["assembling-machine"][spec.name]
	if machine then
		machine.energy_source = machine.energy_source or { type = "electric", usage_priority = "secondary-input" }
		machine.energy_source.emissions = nil
		machine.energy_source.emissions_per_minute = { pollution = spec.pollution }
		machine.next_upgrade = spec.next and data.raw["assembling-machine"][spec.next] and spec.next or nil
		for _, box in pairs(machine.fluid_boxes or {}) do
			box.volume = 1000
			box.base_area = nil
			box.base_level = nil
		end
		machine.graphics_set = table.deepcopy(graphics_set)
		for _, layer in ipairs(machine.graphics_set.animation.layers) do
			layer.tint = spec.tint
		end
		machine.animation = nil
		machine.drawing_box = nil
		machine.working_sound = table.deepcopy(working_sound)
		machine.vehicle_impact_sound = nil
		machine.impact_category = "metal"
		set_icons(machine, tier)
		set_icons(data.raw.item[spec.name], tier)
		set_icons(data.raw.recipe[spec.name], tier)
		-- Технология: та же картинка (индукционная печь), только цвет; маркер уровня добавит icon-markers.
		local technology = data.raw.technology["remelting-alloy-mixer-" .. tier]
		if technology then
			if not technology.icons then
				technology.icons = { { icon = technology.icon, icon_size = technology.icon_size or 256 } }
				technology.icon = nil
				technology.icon_size = nil
				technology.icon_mipmaps = nil
			end
			technology.icons[1].tint = spec.tint
		end
	else
		log("[alloy-mixer-2-0] missing " .. spec.name)
	end
end
