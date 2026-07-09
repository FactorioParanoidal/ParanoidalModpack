require "util"

-- 2.0-порт: 6 тиров машин-фильтров (deepcopy assembling-machine-1 + свои спрайты).
-- Миграции 2.0: графика через graphics_set (top-level animation игнорируется),
-- emissions_per_minute = {pollution = N} (dict, не скаляр), module_slots (не module_specification),
-- minable.results, у последнего тира next_upgrade не задаётся.

local base = data.raw["assembling-machine"]["assembling-machine-1"]

local tiers = {
	{ n = 1, speed = 1,   energy = "250kW", emissions = -50,  slots = 0, next = "CW-air-filter-machine-2" },
	{ n = 2, speed = 1.5, energy = "500kW", emissions = -80,  slots = 1, next = "CW-air-filter-machine-3" },
	{ n = 3, speed = 2,   energy = "1200kW", emissions = -125, slots = 1, next = "CW-air-filter-machine-4" },
	{ n = 4, speed = 4,   energy = "2500kW", emissions = -300, slots = 2, next = "CW-air-filter-machine-5" },
	{ n = 5, speed = 6,   energy = "4500kW", emissions = -550, slots = 2, next = "CW-air-filter-machine-6" },
	{ n = 6, speed = 9,   energy = "6900kW", emissions = -900, slots = 3, next = nil },
}

local machines = {}
for _, t in ipairs(tiers) do
	local name = "CW-air-filter-machine-" .. t.n
	local m = table.deepcopy(base)
	m.name = name
	m.icon = "__carbon-capture2__/graphics/icons/air-filter-machine-" .. t.n .. ".png"
	m.icon_size = 64
	m.max_health = 300
	m.corpse = "small-remnants"
	m.collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } }
	m.selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } }
	m.fast_replaceable_group = "CW-air-filter-machine"
	m.minable = { mining_time = 0.2, results = { { type = "item", name = name, amount = 1 } } }
	m.crafting_categories = { "CW-air-filter" }
	m.fixed_recipe = "CW-filter-air"
	m.source_inventory_size = 1
	m.result_inventory_size = 1
	m.crafting_speed = t.speed
	m.energy_usage = t.energy
	m.energy_source.emissions_per_minute = { pollution = t.emissions }
	m.energy_source.drain = "5kW"
	m.next_upgrade = t.next
	m.module_slots = t.slots
	m.allowed_effects = { "consumption", "speed" }
	m.animation = nil
	m.graphics_set = {
		animation = {
			filename = "__carbon-capture2__/graphics/entity/air-filter-machine-" .. t.n .. ".png",
			priority = "high",
			width = 99,
			height = 112,
			frame_count = 8,
			line_length = 4,
			animation_speed = 0.15,
			shift = util.by_pixel(8, -13),
			repeat_count = 4,
		},
	}
	machines[#machines + 1] = m
end

data:extend(machines)
