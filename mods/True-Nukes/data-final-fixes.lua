
table.insert(water_tile_type_names, "nuclear-shallow")
table.insert(water_tile_type_names, "nuclear-crater")
table.insert(water_tile_type_names, "nuclear-deep")
table.insert(water_tile_type_names, "nuclear-crater-shallow-fill")
table.insert(water_tile_type_names, "nuclear-deep-shallow-fill")
table.insert(water_tile_type_names, "nuclear-deep-fill")

if mods["Krastorio2"] then
  require("compatibility.K2-final-fixes")
end

if mods["space-exploration"] then
  require("compatibility.SE-final-fixes")
end

if mods["apm_nuclear_ldinc"] then
  require("compatibility.APM-final-fixes")
end
