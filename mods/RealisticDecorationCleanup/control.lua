--[[get rid of decorations under entities]]
-- One handler for the four build events; ghosts and non-selectable entities are skipped.
local function clear_under(event)
    local entity = event.entity
    if not (entity and entity.valid) then return end
    local kind = entity.type
    if kind == "entity-ghost" or kind == "tile-ghost" or not entity.prototype.selectable_in_game then return end
    local box = entity.selection_box
    entity.surface.destroy_decoratives{area={{box.left_top.x-0.6, box.left_top.y-0.6}, {box.right_bottom.x+0.6, box.right_bottom.y+0.6}}}
end

script.on_event(defines.events.on_built_entity, clear_under)
script.on_event(defines.events.on_robot_built_entity, clear_under)
script.on_event(defines.events.script_raised_built, clear_under)
script.on_event(defines.events.script_raised_revive, clear_under)
