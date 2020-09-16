if mods["Squeak Through"] then

	require("__Squeak Through__/config")	

	function addExcludedEntityToSqueakThrough(name, category)
		table.insert(exclusions, 
		{	
			{		   
				apply_when_object_exists = 
				{
					type = category,
					name = name,
				},
				excluded_prototype_names = 
				{
					name
				}
			}
		})
	end	
	
	local exclusions_to_add =
	{	
		-- medium storehouse	
		["storage-tank"] =
		{
			"duct-small", 
			"duct", 
			"duct-long", 
			"duct-t-junction", 
			"duct-curve", 
			"duct-cross"			
		},
		["pipe-to-ground"] =
		{
			"duct-underground"
		},
		["pump"] =
		{
			"duct-end-point-intake-south",
			"duct-end-point-intake-west",
			"duct-end-point-intake-north",
			"duct-end-point-intake-east",
			"duct-end-point-outtake-south",
			"duct-end-point-outtake-west",
			"duct-end-point-outtake-north",
			"duct-end-point-outtake-east",
			"non-return-duct"
		}
	}
	
	for category_name, items in pairs(exclusions_to_add) do
		for _, item_name in pairs(items) do
			addExcludedEntityToSqueakThrough(item_name, category_name)
			data.raw[category_name][item_name].squeak_behaviour = false
		end
	end	
	
end
