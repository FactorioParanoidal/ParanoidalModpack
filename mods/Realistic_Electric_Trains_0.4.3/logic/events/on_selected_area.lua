--on_selected_area.lua
--Event handler for the area selection of a debugger tool

function on_selected_area(event)
	if event.item == "ret-pole-debugger" then
		for _, entity in pairs(event.entities) do
			if entity.type == "straight-rail" or entity.type == "curved-rail" then
				local power_provider = global.power_for_rail[entity.unit_number]
				local powered = power_provider and power_provider.valid
				display_powered_state(entity, powered)
			end
		end 
	end
end

return on_selected_area
