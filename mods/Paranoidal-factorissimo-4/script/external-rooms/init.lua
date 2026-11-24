local Registry = require("script.external-rooms.registry")
local Visits = require("script.external-rooms.visits")
require("script.external-rooms.api")

factorissimo.external_rooms = Visits

factorissimo.on_event(factorissimo.events.on_init(), function()
    Registry.init()
    Visits.init()
end)

-- No on_load work: saved work sets persist and the local door index is lazy.
factorissimo.on_event({defines.events.on_player_rotated_entity, defines.events.on_player_flipped_entity,
    defines.events.script_raised_teleported}, function(event) Registry.host_changed(event.entity) end)

factorissimo.on_event(defines.events.on_object_destroyed, Registry.destroyed)
factorissimo.on_event(defines.events.on_forces_merged, function(event)
    Registry.force_merged(event)
    Visits.force_merged(event)
end)
factorissimo.on_event({defines.events.on_pre_surface_cleared, defines.events.on_pre_surface_deleted}, function(event)
    Visits.pre_surface(event.surface_index)
end)
factorissimo.on_event({defines.events.on_surface_cleared, defines.events.on_surface_deleted}, function(event)
    Visits.surface_finished(event.surface_index)
end)
factorissimo.on_event({defines.events.on_player_changed_surface, defines.events.on_player_changed_force,
    defines.events.on_player_controller_changed, defines.events.on_player_driving_changed_state, defines.events.on_player_respawned}, function(event)
    Visits.player_changed(event.player_index)
end)
factorissimo.on_event(defines.events.on_pre_player_left_game, function(event) Visits.before_logout(event.player_index) end)
factorissimo.on_event(defines.events.on_player_left_game, function(event) Visits.player_left(event.player_index) end)
factorissimo.on_event(defines.events.on_player_joined_game, function(event) Visits.player_joined(event.player_index) end)
factorissimo.on_event(defines.events.on_pre_player_removed, function(event) Visits.player_removed(event.player_index) end)
factorissimo.on_event(defines.events.on_player_died, function(event) Visits.player_lost(event.player_index) end)
factorissimo.on_event(defines.events.on_pre_permission_group_deleted, Visits.before_group_deleted)
factorissimo.on_event({defines.events.on_permission_group_edited, defines.events.on_permission_group_deleted,
    defines.events.on_permission_string_imported}, Visits.permissions_changed)

factorissimo.on_event(defines.events.on_gui_click, function(event)
    local element = event.element
    if not (element and element.valid and element.name == Visits.return_button) then return end
    local player = game.get_player(event.player_index)
    if not player or player.gui.top[Visits.return_button] ~= element or element.get_mod() ~= script.mod_name then return end
    local visit = Visits.get_visit {player_index = event.player_index}
    if visit then Visits.request_leave {player_index = event.player_index, visit_id = visit.visit_id} end
end)

return Visits
