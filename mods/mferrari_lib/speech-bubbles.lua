-- v 1.2  -- custom hs-speech-bubble using unit_number 10/12/2021, 
--v 2.0   10/2024

local function clear(id)
	local entry = storage.entity_speech[id]
	if not entry then return end
	storage.entity_speech[id] = nil
	if entry.bubble and entry.bubble.valid then entry.bubble.destroy() end
end

function Entity_Speak(entity, text, seconds)
	if not (entity and entity.valid) then return end
	local id = entity.unit_number
	local previous = storage.entity_speech[id]
	local expires = seconds and seconds > 0 and game.tick + seconds * 60 or nil
	if previous and previous.bubble and previous.bubble.valid and previous.text == text then
		previous.tick = expires
		return
	end
	clear(id)
	local bubble = entity.surface.create_entity{
		name = "mf_speech_bubble", text = {"", "[font=default-large-bold]", text, "[/font]"},
		position = {0, 0}, source = entity,
	}
	if bubble then storage.entity_speech[id] = {bubble = bubble, text = text, tick = expires, source = entity} end
end


script.on_nth_tick(61, function()
	for id, entry in pairs(storage.entity_speech) do
		if not (entry.bubble and entry.bubble.valid) or (entry.source and not entry.source.valid)
			or (entry.tick and game.tick >= entry.tick) then
			clear(id)
		end
	end
end)

function clear_speach_bubble(entity)
	if entity and entity.valid then clear(entity.unit_number) end
end