-- 2.0-порт CW-carbon-capture-reforged (только фильтры).
-- Рантайм оставлен минимальным: авто-отключение фильтра, когда локальное
-- загрязнение ушло (не жжёт фильтры/энергию по чистому воздуху).
-- Вырезано из оригинала: require("gui") (файла нет → краш) + мёртвый код
-- fusion-reactor / pyrolyser / fuel-cell / hydrogen-furnace (сущностей нет).
-- 2.0-API: global → storage, event.created_entity → event.entity.

local FILTERS = {
	["CW-air-filter-machine-1"] = true,
	["CW-air-filter-machine-2"] = true,
	["CW-air-filter-machine-3"] = true,
	["CW-air-filter-machine-4"] = true,
	["CW-air-filter-machine-5"] = true,
	["CW-air-filter-machine-6"] = true,
}

local name_filter = {}
for name in pairs(FILTERS) do
	name_filter[#name_filter + 1] = { filter = "name", name = name }
end

local function on_built(event)
	local e = event.entity
	if e and e.valid then
		storage.CW_AirFilterTable = storage.CW_AirFilterTable or {}
		storage.CW_AirFilterTable[e.unit_number] = e
	end
end

local function on_remove(event)
	local e = event.entity
	if e and storage.CW_AirFilterTable then
		storage.CW_AirFilterTable[e.unit_number] = nil
	end
end

local function on_tick(event)
	if event.tick % 60 == 0 and storage.CW_AirFilterTable then
		for unit, filter in pairs(storage.CW_AirFilterTable) do
			if filter.valid then
				filter.active = filter.surface.get_pollution(filter.position) > 1
			else
				storage.CW_AirFilterTable[unit] = nil
			end
		end
	end
end

-- 2.0: event-фильтр допустим только при регистрации ОДНОГО события → регистрируем каждое отдельно.
for _, ev in ipairs({
	defines.events.on_built_entity,
	defines.events.on_robot_built_entity,
	defines.events.script_raised_built,
	defines.events.script_raised_revive,
}) do
	script.on_event(ev, on_built, name_filter)
end

for _, ev in ipairs({
	defines.events.on_player_mined_entity,
	defines.events.on_robot_mined_entity,
	defines.events.on_entity_died,
	defines.events.script_raised_destroy,
}) do
	script.on_event(ev, on_remove, name_filter)
end

script.on_event(defines.events.on_tick, on_tick)
