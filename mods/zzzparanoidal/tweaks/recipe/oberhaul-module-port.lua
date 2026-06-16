-- Порт Oberhaul moduleeffects.lua + moduleslots.lua (1.1): эффекты + слоты модулей.
-- effect правим точечно (quality/pollution 2.0 сохраняются).
-- Имена 1.1→2.0: effectivity→efficiency; тиры 4/5 → bob-*; машины → bob-/angels-.

-- ── Эффекты модулей (1.1-формула на 5 тиров) ──────────────────
local function set_effect(name, fields)
	local m = data.raw.module[name]
	if not (m and m.effect) then return end
	for k, v in pairs(fields) do
		m.effect[k] = v
	end
end

local speed = { "speed-module", "speed-module-2", "speed-module-3", "bob-speed-module-4", "bob-speed-module-5" }
for i, n in ipairs(speed) do
	set_effect(n, { speed = i * 0.1, consumption = i * 0.175 })
end

local prod = { "productivity-module", "productivity-module-2", "productivity-module-3", "bob-productivity-module-4", "bob-productivity-module-5" }
for i, n in ipairs(prod) do
	set_effect(n, { productivity = i * 0.0375, consumption = i * 0.3, speed = -i * 0.15 })
end

-- efficiency (значения 1.1; T4/5 за капом -80% намеренно)
local effi = { "efficiency-module", "efficiency-module-2", "efficiency-module-3", "bob-efficiency-module-4", "bob-efficiency-module-5" }
local effi_consumption = { -0.3, -0.6, -1.2, -4, -5 }
for i, n in ipairs(effi) do
	set_effect(n, { consumption = effi_consumption[i] })
end

-- ── Слоты модулей на машинах (формат 2.0: module_slots напрямую) ──
local function set_slots(name, n)
	local e = data.raw["assembling-machine"][name] or data.raw["furnace"][name]
	if e then e.module_slots = n end
end

local slot_nerf = {
	["assembling-machine-3"] = 2,
	["bob-assembling-machine-4"] = 3,
	["bob-assembling-machine-5"] = 3,
	["bob-assembling-machine-6"] = 4,
	["chemical-plant"] = 1,
	["angels-chemical-plant-2"] = 2,
	["angels-chemical-plant-3"] = 3,
	["angels-chemical-plant-4"] = 4,
	["oil-refinery"] = 1,
	["angels-oil-refinery-2"] = 2,
	["angels-oil-refinery-3"] = 3,
	["angels-oil-refinery-4"] = 4,
	["electric-furnace"] = 1,
	["bob-electric-furnace-2"] = 2,
	["bob-electric-furnace-3"] = 3,
	["bob-electric-mixing-furnace"] = 1,
	["bob-electric-chemical-mixing-furnace"] = 2,
	["bob-electric-chemical-mixing-furnace-2"] = 3,
	["bob-electric-chemical-furnace"] = 1,
	["bob-electronics-machine-1"] = 0,
	["bob-electronics-machine-2"] = 2,
	["bob-electronics-machine-3"] = 4,
}
for name, n in pairs(slot_nerf) do
	set_slots(name, n)
end
