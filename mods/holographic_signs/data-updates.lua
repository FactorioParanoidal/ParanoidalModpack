
if data.raw.technology['lamp'] then 
	table.insert (data.raw.technology['lamp'].effects,{type = "unlock-recipe", recipe = "hs_holo_sign"})
	data.raw.recipe["hs_holo_sign"].enabled = false
	end

