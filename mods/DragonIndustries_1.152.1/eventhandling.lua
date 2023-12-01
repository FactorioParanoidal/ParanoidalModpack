

function onCommand(event)

end

function onEntityRotated(event)

end

function onEntityAdded(event)
	trackEntityAddition(event.created_entity, global.asfdsgdfg)
end

function onEntityRemoved(event)
	trackEntityRemoval(event.entity, global.asfdsgdfg)
end

function onEntityDied(event)
	onEntityRemoved(event)
end

function onGameTick(event)	
	local tick = event.tick
	--[[	
	for id,tickGroup in pairs(tickGroups) do
		local glbl = tickGroup.getGlobal()
		for _,func in pairs(tickGroup.calls) do
			func(glbl, tick)
		end
	end
	]]
	runTickHooks(global.asfdsgdfg, event.tick)
end