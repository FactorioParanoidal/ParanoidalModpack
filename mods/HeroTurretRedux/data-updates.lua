data_updates = true
if settings.startup["heroturrets-setting-run-in-updates"].value == "True" then
	log("Turrets via updates")
	--heroturrets = { util = get_liborio() }	
	heroturrets = { }	
	require ("prototypes.scripts.types")
end 