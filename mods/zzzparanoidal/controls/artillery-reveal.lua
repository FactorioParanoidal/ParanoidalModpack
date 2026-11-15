-- Цель, уничтоженная артиллерией (гнездо, червь, турель), открывает карту вокруг себя для силы стрелка.
-- Механика перенесена из AtomicArtillery2 (удалён 2026-11-15, решение пользователя): обычный артснаряд
-- в сборке не открывает карту при попадании (tweaks/item/ammo-stats-1_1), без этого результат стрельбы
-- не виден. AtomicArtillery2 проверял два имени; здесь — любая артиллерийская турель или вагон сборки
-- (Bob 2–3, турели-герои, пусковая MIRV).
local M = {}

local TARGETS = { ["unit-spawner"] = true, turret = true, ["ammo-turret"] = true, ["electric-turret"] = true,
	["fluid-turret"] = true, ["artillery-turret"] = true }
-- Эти типы исключены из прочих обработчиков смерти zzz (фильтр в control.lua): им их не передаём.
local ONLY_HERE = { ["unit-spawner"] = true, turret = true }
local ARTILLERY = { ["artillery-turret"] = true, ["artillery-wagon"] = true }
local RADIUS = 16

local function reveal(event)
	local cause, entity = event.cause, event.entity
	if not (cause and cause.valid and ARTILLERY[cause.type]) then return end
	local p = entity.position
	cause.force.chart(entity.surface, { { p.x - RADIUS, p.y - RADIUS }, { p.x + RADIUS, p.y + RADIUS } })
end

function M.install()
	local event_id = defines.events.on_entity_died
	local previous = script.get_event_handler(event_id)
	script.on_event(event_id, function(event)
		local entity = event.entity
		local entity_type = entity and entity.valid and entity.type
		if entity_type and TARGETS[entity_type] then reveal(event) end
		if previous and not ONLY_HERE[entity_type] then previous(event) end
	end)
end

M.only_here = ONLY_HERE
return M
