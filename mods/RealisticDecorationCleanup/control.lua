--[[get dir of decorations under entities]]
script.on_event(defines.events.on_built_entity, function(event)
	if event.created_entity.type ~= "entity-ghost" and event.created_entity.type ~= "tile-ghost" and event.created_entity.prototype.selectable_in_game then
		game.surfaces[1].destroy_decoratives{area=event.created_entity.selection_box}
	end
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
	if event.created_entity.type ~= "entity-ghost" and event.created_entity.type ~= "tile-ghost" and event.created_entity.prototype.selectable_in_game then
		game.surfaces[1].destroy_decoratives{area=event.created_entity.selection_box}
	end
end)

script.on_event(defines.events.script_raised_built, function(event)
	if event.entity.type ~= "entity-ghost" and event.entity.type ~= "tile-ghost" and event.entity.prototype.selectable_in_game then
		game.surfaces[1].destroy_decoratives{area=event.entity.selection_box}
	end
end)

script.on_event(defines.events.script_raised_revive, function(event)
	if event.entity.type ~= "entity-ghost" and event.entity.type ~= "tile-ghost" and event.entity.prototype.selectable_in_game then
		game.surfaces[1].destroy_decoratives{area=event.entity.selection_box}
	end
end)
