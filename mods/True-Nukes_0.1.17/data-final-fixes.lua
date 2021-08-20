if mods["bobwarfare"] then 
	data.raw.technology["bob-atomic-artillery-shell"] = nil
end
table.insert(water_tile_type_names, "nuclear-shallow")
table.insert(water_tile_type_names, "nuclear-crater")
table.insert(water_tile_type_names, "nuclear-deep")
table.insert(water_tile_type_names, "nuclear-crater-shallow-fill")
table.insert(water_tile_type_names, "nuclear-deep-shallow-fill")
table.insert(water_tile_type_names, "nuclear-deep-fill")
