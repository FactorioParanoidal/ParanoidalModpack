--[[get dir of decorations under entities]]
script.on_event(defines.events.on_built_entity, function(event)
	if event.created_entity.type ~= "entity-ghost" and event.created_entity.type ~= "tile-ghost" then
		game.surfaces[1].destroy_decoratives{area=event.created_entity.selection_box}
	end
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
	if event.created_entity.type ~= "entity-ghost" and event.created_entity.type ~= "tile-ghost" then
		game.surfaces[1].destroy_decoratives{area=event.created_entity.selection_box}
	end
end)
