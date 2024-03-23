function change_fuel_category_fuel_item(item_name, fuel_category_name)
	local item_prototype = data.raw["item"][item_name]
	if not item_prototype then
		error("item with name" .. item_name .. " not found ")
	end
	if not data.raw["fuel-category"][fuel_category_name] then
		error("fuel-category with name" .. fuel_category_name .. " not found ")
	end
	item_prototype.fuel_category = fuel_category_name
end
local function cleanup_fuel_category_for_prototype(prototype)
	if not prototype then
		error("prototype with name" .. prototype.name .. " and type " .. prototype.type .. " not found ")
	end
	prototype.fuel_category = nil
	prototype.fuel_value = nil
	prototype.fuel_acceleration_multiplier = nil
	prototype.fuel_top_speed_multiplier = nil
	prototype.fuel_emissions_multiplier = nil
	prototype.fuel_glow_color = nil
end
function cleanup_fuel_category_for_gun(gun_name)
	cleanup_fuel_category_for_prototype(data.raw["gun"][gun_name])
end
function cleanup_fuel_category_for_Item(item_name)
	cleanup_fuel_category_for_prototype(data.raw["item"][item_name])
end

function get_fuel_category_name_for_prototype(prototype)
	return prototype.type .. "-" .. prototype.name
end
