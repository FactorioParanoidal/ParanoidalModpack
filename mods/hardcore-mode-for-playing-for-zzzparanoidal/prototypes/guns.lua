_table.each(data.raw["gun"], function(gun, gun_name)
	cleanup_fuel_category_for_gun(gun_name)
end)
