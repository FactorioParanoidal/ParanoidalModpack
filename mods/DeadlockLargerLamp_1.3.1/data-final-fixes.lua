local DLL = require("prototypes.globals")

-- look for any item with a fuel value and make a copper lamp recipe

local day = 416.666666667

for _,item in pairs(data.raw.item) do
	if item.fuel_value and item.fuel_category == "chemical" then
		local craft_time = day * (util.parse_energy(item.fuel_value)/4000000)
		if craft_time >= 1/60 then
			local results = item.burnt_result and {{name = item.burnt_result, type = "item", amount = 1}} or {}
			data:extend({{
				name = "deadlock-lamp-burning-"..item.name,
				type = "recipe",
				category = "deadlock-lamp-burning",
				results = results,
				subgroup = "other",
				icon = string.format("%s/deadlock-large-lamp-64.png", DLL.icon_path),
				icon_size = 64,
				emissions_multiplier = item.fuel_emissions_multiplier,
				ingredients = {{item.name,1}},
				hidden = true,
				enabled = true,
				hide_from_stats = true,
				allow_decomposition = false,
				allow_as_intermediate = false,
				allow_intermediates = false,
				energy_required = craft_time,
			}})
			--log("Created lamp fuel for "..item.name.." with burn time of "..days.." days")
		else
			--log("Skipped creating lamp fuel for "..item.name..", couldn't read a sane fuel value.")
		end
	end
end

-- re-apply signal colours from vanilla lamp in case any other mod has added more

local signal_colours = data.raw.lamp["small-lamp"].signal_to_color_mapping
if signal_colours then
	data.raw.lamp[DLL.name].signal_to_color_mapping = signal_colours
end
