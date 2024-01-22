_table.each(data.raw, function(prototype_table)
	_table.each(prototype_table, function(prototype)
		if prototype.fuel_value then
			local prototype_type = prototype.type
			local prototype_name = prototype.name
			log("found prototype as fuel with type " .. prototype_type .. " called " .. prototype_name)
			if prototype_type == "item" then
				local fuel_category_name = get_fuel_category_name_for_prototype(prototype)
				data:extend({ { type = "fuel-category", name = fuel_category_name } })
				changeFuelCategoryItem(prototype_name, fuel_category_name)
			end
		end
	end)
end)
