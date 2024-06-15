
if data.raw.technology['optics'] then 
	table.insert (data.raw.technology['optics'].effects,{type = "unlock-recipe", recipe = "hs_holo_sign"})
	data.raw.recipe["hs_holo_sign"].enabled = false
	end

