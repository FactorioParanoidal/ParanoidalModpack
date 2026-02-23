--[[get rid of decorations under entities]]
script.on_event(defines.events.on_built_entity, function(event)
    if event.entity.type ~= "entity-ghost" and event.entity.type ~= "tile-ghost" and event.entity.prototype.selectable_in_game then
        game.surfaces[event.entity.surface_index].destroy_decoratives{area={{event.entity.selection_box.left_top.x-0.6, event.entity.selection_box.left_top.y-0.6}, {event.entity.selection_box.right_bottom.x+0.6, event.entity.selection_box.right_bottom.y+0.6}}}
    end
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
    if event.entity.type ~= "entity-ghost" and event.entity.type ~= "tile-ghost" and event.entity.prototype.selectable_in_game then
        game.surfaces[event.entity.surface_index].destroy_decoratives{area={{event.entity.selection_box.left_top.x-0.6, event.entity.selection_box.left_top.y-0.6}, {event.entity.selection_box.right_bottom.x+0.6, event.entity.selection_box.right_bottom.y+0.6}}}
    end
end)

script.on_event(defines.events.script_raised_built, function(event)
    if event.entity.type ~= "entity-ghost" and event.entity.type ~= "tile-ghost" and event.entity.prototype.selectable_in_game then
        game.surfaces[event.entity.surface_index].destroy_decoratives{area={{event.entity.selection_box.left_top.x-0.6, event.entity.selection_box.left_top.y-0.6}, {event.entity.selection_box.right_bottom.x+0.6, event.entity.selection_box.right_bottom.y+0.6}}}
    end
end)

script.on_event(defines.events.script_raised_revive, function(event)
    if event.entity.type ~= "entity-ghost" and event.entity.type ~= "tile-ghost" and event.entity.prototype.selectable_in_game then
        game.surfaces[event.entity.surface_index].destroy_decoratives{area={{event.entity.selection_box.left_top.x-0.6, event.entity.selection_box.left_top.y-0.6}, {event.entity.selection_box.right_bottom.x+0.6, event.entity.selection_box.right_bottom.y+0.6}}}
    end
end)
