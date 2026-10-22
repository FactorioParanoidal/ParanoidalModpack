-- Здания смесителя сплавов (issue #401, решения пользователя 2026-10-20) поверх форка
-- angelsextended-remelting-fixed: загрязнение по тирам как у индукционной печи, цепочка улучшений
-- и буфер жидкости 1000 (как в angelsextended-remelting 2.0.0), звук автора 2.0.0.
-- Графика: зеркальная индукционная печь своего тира вместе с маской/бликами Reskins (смеситель
-- по умолчанию = отражённая печь, при отражении F — обычная) + значок R цвета тира на здании.
-- Файлы общие с печами, своей графики здания нет. Иконки: иконка печи своего тира + значок R.
-- Технология remelting-alloy-mixer-N: картинка печи + маска медных деталей цвета тира.
-- Порты, тиры, слоты и цены не меняются.
-- После меню литья (иконки печей и рецептов), до approved-icons/icon-markers и graphics-atlas.

local R_ICON = "__angelsextended-remelting-fixed__/graphics/icons/remelting.png"

local tiers = {
	{ name = "alloy-mixer", furnace = "angels-induction-furnace", pollution = 1.8, next = "alloy-mixer-2", tint = { r = 1, g = 0.718, b = 0.149, a = 1 } },
	{ name = "alloy-mixer-2", furnace = "angels-induction-furnace-2", pollution = 2.4, next = "alloy-mixer-3", tint = { r = 0.949, g = 0.137, b = 0.094, a = 1 } },
	{ name = "alloy-mixer-3", furnace = "angels-induction-furnace-3", pollution = 3, next = "alloy-mixer-4", tint = { r = 0.2, g = 0.706, b = 1, a = 1 } },
	{ name = "alloy-mixer-4", furnace = "angels-induction-furnace-4", pollution = 3.6, tint = { r = 0.706, g = 0.349, b = 1, a = 1 } },
}

local working_sound = {
	sound = { filename = "__angelssmeltinggraphics__/sound/casting-machine.ogg" },
	idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
}

-- Значок R на переднем сером листе корпуса (слева у отражённой печи, справа у обычной).
local function add_badge(set, x, tint)
	if not set then return end
	set.working_visualisations = set.working_visualisations or {}
	table.insert(set.working_visualisations, {
		always_draw = true,
		animation = { filename = R_ICON, priority = "high", size = 64, scale = 0.5, shift = { x, 1.95 }, tint = tint },
	})
end

local function source_icons(prototype)
	if prototype.icons then return table.deepcopy(prototype.icons) end
	if prototype.icon then return { { icon = prototype.icon, icon_size = prototype.icon_size or 64 } } end
end

local function set_icons(prototype, furnace_icons, tint)
	if not (prototype and furnace_icons) then return end
	local icons = table.deepcopy(furnace_icons)
	-- Метка тира Reskins сверху, R — в левом нижнем углу.
	table.insert(icons, { icon = R_ICON, icon_size = 64, scale = 0.32, shift = { -10, 10 }, tint = tint })
	prototype.icons = icons
	prototype.icon = nil
	prototype.icon_size = nil
	prototype.icon_mipmaps = nil
end

for tier, spec in ipairs(tiers) do
	local machine = data.raw["assembling-machine"][spec.name]
	local furnace = data.raw["assembling-machine"][spec.furnace]
	if machine and furnace then
		machine.energy_source = machine.energy_source or { type = "electric", usage_priority = "secondary-input" }
		machine.energy_source.emissions = nil
		machine.energy_source.emissions_per_minute = { pollution = spec.pollution }
		machine.next_upgrade = spec.next and data.raw["assembling-machine"][spec.next] and spec.next or nil
		for _, box in pairs(machine.fluid_boxes or {}) do
			box.volume = 1000
			box.base_area = nil
			box.base_level = nil
		end

		machine.animation = nil
		machine.drawing_box = nil
		if furnace.graphics_set_flipped then
			machine.graphics_set = table.deepcopy(furnace.graphics_set_flipped)
			machine.graphics_set_flipped = table.deepcopy(furnace.graphics_set)
			add_badge(machine.graphics_set, -1.15, spec.tint)
			add_badge(machine.graphics_set_flipped, 1.15, spec.tint)
		else
			machine.graphics_set = table.deepcopy(furnace.graphics_set)
			machine.graphics_set_flipped = nil
			add_badge(machine.graphics_set, 1.15, spec.tint)
		end
		machine.working_sound = table.deepcopy(working_sound)
		machine.vehicle_impact_sound = nil
		machine.impact_category = "metal"

		local furnace_item = data.raw.item[spec.furnace]
		local furnace_icons = source_icons(furnace_item or furnace)
		set_icons(machine, furnace_icons, spec.tint)
		set_icons(data.raw.item[spec.name], furnace_icons, spec.tint)
		set_icons(data.raw.recipe[spec.name], furnace_icons, spec.tint)

		-- Технология: та же картинка (индукционная печь) + маска медных деталей; маркер уровня добавит icon-markers.
		local technology = data.raw.technology["remelting-alloy-mixer-" .. tier]
		if technology then
			if not technology.icons then
				technology.icons = { { icon = technology.icon, icon_size = technology.icon_size or 256 } }
				technology.icon = nil
				technology.icon_size = nil
				technology.icon_mipmaps = nil
			end
			table.insert(technology.icons, 2, {
				icon = "__zzzparanoidal__/graphics/alloy-mixer/alloy-mixer-tech-mask.png",
				icon_size = technology.icons[1].icon_size or 256,
				scale = technology.icons[1].scale,
				shift = technology.icons[1].shift,
				tint = spec.tint,
			})
		end
	else
		log("[alloy-mixer-2-0] missing " .. spec.name .. " or " .. spec.furnace)
	end
end
