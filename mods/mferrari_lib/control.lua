require "cameras"


-- Paranoidal: no "nuke-explosion" (sight and sound only, no damage) when any reactor dies. Even a cold burner
-- reactor looked like a nuclear blast; a real meltdown comes from the reactor prototype (meltdown_action).




-- open cameras was crashing the game v. 2.0.17
script.on_event(defines.events.on_pre_surface_deleted , function(event)
local surface = event.surface_index
close_all_cameras_from_surface(surface)
end)



function init_mod_vars(event)
storage.mf_frame_cameras = storage.mf_frame_cameras or {}
end
script.on_init(init_mod_vars)
script.on_configuration_changed(init_mod_vars)






--INTERFACE
local interface={}
function interface.register_camera(camera)
	register_camera(camera)
end
function interface.close_cameras_from_surface(surface)
	close_all_cameras_from_surface(surface)
end
remote.add_interface( "mf_lib", interface)
