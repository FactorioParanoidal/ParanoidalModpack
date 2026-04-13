require("config" )

function update_lights( lights, add_omni_full )
	local has_omni_light = false
	
	if lights ~= nil then
		for _, light in pairs(lights) do
			if type(light) == "table" then
				if light.minimum_darkness ~= nil then light.minimum_darkness = my_light_minimum_darkness end
				--if light.type and light.type == "oriented" then
				if light.type == "oriented" then
					-- cone light of player or vehicule
					if light.intensity then light.intensity = my_light_cone_intensity end
				elseif light.add_perspective ~= nil then
					-- stand and back lights of train
				else
					-- omnidirectional light
					if light.intensity then light.intensity = my_light_intensity end
					if light.size then light.size = my_light_size end
					has_omni_light = true
				end
			else
				has_omni_light = true
			end
		end
	
		-- if no omnidirectional light, then add one
		if not has_omni_light then
			table.insert(lights,
				{
					minimum_darkness = my_light_minimum_darkness,  
					intensity = my_light_intensity * iif(add_omni_full,1,0.5), 
					size = iif(add_omni_full,my_light_size,20), 
				}
			)
		end
	end
end

if my_light_custom then
	-- update_lights(data.raw.player.player.light, true )
	
	for _, v in pairs(data.raw.character) do
		if v.light == nil then v.light = {} end
		update_lights(v.light, true )
	end

	for _, v in pairs(data.raw.car) do
		update_lights(v.light, true)
	end
	
	for _, v in pairs(data.raw.locomotive) do
		update_lights(v.front_light, true)
		update_lights(v.stand_by_light, my_light_locomotive_still )
	end
end

if data.raw.lamp["balloon-light"] ~= nil then
   data.raw.lamp["balloon-light"].signal_to_color_mapping = data.raw.lamp["small-lamp"].signal_to_color_mapping
end

if data.raw.lamp["short-balloon-light"] ~= nil then
   data.raw.lamp["short-balloon-light"].signal_to_color_mapping = data.raw.lamp["small-lamp"].signal_to_color_mapping
end
