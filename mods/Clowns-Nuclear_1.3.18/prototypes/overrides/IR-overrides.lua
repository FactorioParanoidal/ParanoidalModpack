if mods["IndustrialRevolution3"] then
	--update train fuel
	clowns.functions.replace_ing("nuclear-fuel","uranium-235", {"55%-uranium", 1}, "ing")
	--update reactor fuel
	clowns.functions.replace_ing("uranium-fuel-cell","uranium-235", {"35%-uranium", 20}, "ing")
	clowns.functions.remove_res("uranium-fuel-cell","uranium-238","ing")
	--update fuel reprocessing
	clowns.functions.add_to_table("nuclear-fuel-reprocessing",{type="item",name="plutonium-239",amount=1,probability=0.5},"res")
	clowns.functions.replace_ing("mixed-oxide","iron-plate",{"lead-plate-special",2},"ing")
	--data.raw.recipe["nuclear-fuel-reprocessing"].ingredients={{"used-up-uranium-fuel-cell",1}}--change it to 5
	--update kovarex
	clowns.functions.remove_unlock("kovarex-enrichment-process","kovarex-enrichment-process")
	clowns.functions.add_unlock("military-4","atomic-bomb")
end