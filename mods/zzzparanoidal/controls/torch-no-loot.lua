-- Разобранный факел пропадает целиком: ни дерева, ни оставшегося в нём угля.
-- Иначе бракованный факел (ручной крафт) в 2.0 отдавал бракованное дерево.
-- Сохраняет ранние обработчики zzz, как остальные модули controls/.
local function on(event, callback)
	local previous = script.get_event_handler(event)
	script.on_event(event, function(e)
		if previous then previous(e) end
		callback(e)
	end)
end

local function clear(event)
	local entity, buffer = event.entity, event.buffer
	if entity and entity.valid and entity.name == "torch" and buffer and buffer.valid then buffer.clear() end
end

for _, event in ipairs({ defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity }) do
	on(event, clear)
end
