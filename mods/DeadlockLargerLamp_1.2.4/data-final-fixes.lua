require("prototypes.globals")

-- look for any item with a fuel value and make a copper lamp recipe

local day = 416.667

data:extend({{
	type = "item",
	name = "deadlock-lamp-emptiness",
	order = "omega",
	stack_size = 666,
	icon = "__base__/graphics/icons/list-dot.png",
	icon_size = 32,
	flags = {"hidden"},
}})

for _,item in pairs(data.raw.item) do
	if item.fuel_value and item.fuel_category == "chemical" then
		local days = read_fuel_value(item.fuel_value)/4000000
		if days > 0 then
			local result = item.burnt_result or "deadlock-lamp-emptiness"
			local result_count = item.burnt_result and 1 or 0
			data:extend({{
				name = "deadlock-lamp-burning-"..item.name,
				type = "recipe",
				category = "deadlock-lamp-burning",
				result = result,
				result_count = result_count,
				emissions_multiplier = item.fuel_emissions_multiplier,
				ingredients = {{item.name,1}},
				hidden = true,
				enabled = true,
				hide_from_stats = true,
				allow_decomposition = false,
				allow_as_intermediate = false,
				allow_intermediates = false,
				energy_required = days * day,
			}})
			log("Created lamp fuel for "..item.name.." with burn time of "..days.." days")
		else
			log("Skipped creating lamp fuel for "..item.name..", couldn't read a sane fuel value.")
		end
	end
end

-- undo Squeak Through's bullshit and any other mod that messes with collision boxes unasked
data.raw.lamp[DLL.name].collision_box = { {-0.6,-0.6}, {0.6,0.6} }
data.raw.furnace[DLL.copper_name].collision_box = { {-0.6,-0.6}, {0.6,0.6} }

