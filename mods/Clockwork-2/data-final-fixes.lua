
-- Moved to final fixes as Krastorio2 affects accumulators during its data-updates stage
-- (And this proofs it again other mods that may do likewise)

if settings.startup["Clockwork-mod-accumulators"].value then
	for _,accumulator in pairs(data.raw.accumulator) do
		if accumulator.energy_source
			and accumulator.energy_source.buffer_capacity
		then
			local capacity,unit = string.match(accumulator.energy_source.buffer_capacity, "([%d%.]+)(%a+)")
			accumulator.energy_source.buffer_capacity = settings.startup["Clockwork-mod-accumulators-capacity"].value * capacity .. unit
		end
	end
end

if settings.startup["Clockwork-disable-nv"].value then
	data.raw.technology["night-vision-equipment"] = nil
	data.raw.recipe["night-vision-equipment"] = nil
	-- data.raw.item["night-vision-equipment"] = nil
	-- Factorio will crash if there are no entries in this category.
	-- Since there is only one nightvision in vanilla, it cannot be nil
	-- data.raw["night-vision-equipment"]["night-vision-equipment"] = nil
	-- doesn't work with surface color weights.
	-- data.raw["night-vision-equipment"]["night-vision-equipment"].color_lookup = {{0.45, "__core__/graphics/color_luts/lut-night.png"}}
	-- This actually works!
	data.raw["night-vision-equipment"]["night-vision-equipment"].energy_source.input_flow_limit = "0kW"
end

