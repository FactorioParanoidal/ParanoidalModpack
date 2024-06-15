-- v 1.2  -- custom hs-speech-bubble using unit_number 10/12/2021, 

function Entity_Speak(entity,text,seconds)
if entity and entity.valid then 
	local id = entity.unit_number
	
	if global.entity_speech[entity] then  --- clears olf format
		global.entity_speech[entity].bubble.destroy()
		global.entity_speech[entity] = nil
		end	

	if global.entity_speech[id] then 
		global.entity_speech[id].bubble.destroy()
		global.entity_speech[id] = nil
		end

	  local bubble = entity.surface.create_entity({
		name="hs-speech-bubble",
		text=text,
		position={0,0},
		source=entity })
	  
		global.entity_speech[id] = {}
		global.entity_speech[id].bubble=bubble
		if seconds and seconds>0 then global.entity_speech[id].tick=game.tick+seconds*60 end
	end
end


script.on_nth_tick(61, function (event)
for k, entity_speech in pairs (global.entity_speech) do
	local bubble = entity_speech.bubble
	local tick   = entity_speech.tick
	if tick and game.tick >= tick then 
		bubble.destroy()
		entity_speech=nil
		end
	end
end)

function clear_speach_bubble(entity)
if entity and entity.valid then 
	local id = entity.unit_number
	if global.entity_speech[id] and global.entity_speech[id].bubble and global.entity_speech[id].bubble.valid then 
		global.entity_speech[id].bubble.destroy()
		global.entity_speech[id] = nil
		end
	end
end