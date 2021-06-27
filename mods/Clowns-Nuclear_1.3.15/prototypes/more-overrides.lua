if mods["IndustrialRevolution"] then
	--update train fuel
	clowns.functions.replace_ing("nuclear-fuel","uranium-235", {"55%-uranium", 1}, "ing")
	--update reactor fuel
	--clowns.functions.replace_ing("nuclear-fuel-cell","uranium-235", {"35%-uranium", 1}, "ing")
	clowns.functions.replace_ing("uranium-fuel-cell","uranium-235", {"35%-uranium", 1}, "ing")
	--update fuel reprocessing
	clowns.functions.add_to_table("nuclear-fuel-reprocessing",{"plutonium-239",2},"res")
	--log(serpent.block(data.raw.recipe["nuclear-fuel-reprocessing"]))
	data.raw.recipe["nuclear-fuel-reprocessing"].ingredients={{"used-up-uranium-fuel-cell",5}}--change it to 5
	--update kovarex
	--clowns.functions.replace_ing("kovarex-enrichment-process","uranium-235",{"35%-uranium",40},"ing")
	--clowns.functions.replace_ing("kovarex-enrichment-process","uranium-235",{"35%-uranium",41},"res")
	clowns.functions.remove_unlock("kovarex-enrichment-process","kovarex-enrichment-process")
	clowns.functions.add_unlock("military-4","atomic-bomb")
end