-- Check for post-process

local function pp_check()
	if not game.active_mods["osm-lib-postprocess"] then
		error('\n\n-----------------------------------------------------------\nLibrary extension "OSM-Lib PostProcess" missing or disabled!\nENABLE MOD OR DOWNLOAD AT:\nhttps://mods.factorio.com/mod/osm-lib-postprocess\n-----------------------------------------------------------\n')
	else
		script.on_event(defines.events.on_tick, nil)
	end
end

script.on_init(pp_check)
script.on_configuration_changed(pp_check)
script.on_event(defines.events.on_tick, pp_check)