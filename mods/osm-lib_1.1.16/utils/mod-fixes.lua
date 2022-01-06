-------------------------
---- ALL DATA STAGES ----
-------------------------

-- Apply mod fixes
function OSM.lib.mod_fixes(prototype_name, prototype_type, mod_name)

	-- Excludes recipe from omni compression
	if mods ["omnimatter_compression"] then
		if data.raw.recipe[prototype_name] and data.raw.recipe[prototype_name].OSM_removed == true then
			omni.compression.exclude_recipe(prototype_name)
		end
	end

end