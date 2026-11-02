data_final_fixes = true
if settings.startup["heroturrets-setting-run-in-updates"].value ~= "True" then
	log("Turrets via final fixes")
	--heroturrets = { util = get_liborio() }	
	heroturrets = { }	
	require ("prototypes.scripts.types")
end

-- Paranoidal: recipes stay out of the signal selection window (setting paranoidal-show-recipe-signals of zzzparanoidal).
local show_recipe_signals = settings.startup["paranoidal-show-recipe-signals"]
if show_recipe_signals and not show_recipe_signals.value then
	for _, recipe in pairs(data.raw.recipe) do
		recipe.hide_from_signal_gui = true
	end
end
