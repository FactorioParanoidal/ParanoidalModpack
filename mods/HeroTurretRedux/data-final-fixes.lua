data_final_fixes = true
if settings.startup["heroturrets-setting-run-in-updates"].value ~= "True" then
	log("Turrets via final fixes")
	--heroturrets = { util = get_liborio() }	
	heroturrets = { }	
	require ("prototypes.scripts.types")
end 