local function update_pollution(factory)
	local inside_surface = factory.inside_surface
	local chunk
	local pollution, cp = 0, 0
	local inside_x, inside_y = factory.inside_x, factory.inside_y

	chunk = {inside_x - 16,inside_y - 16}
	cp = inside_surface.get_pollution(chunk)
	if cp ~= 0 then inside_surface.pollute(chunk, -cp) end
	pollution = pollution + cp
	
	chunk = {inside_x + 16,inside_y - 16}
	cp = inside_surface.get_pollution(chunk)
	if cp ~= 0 then inside_surface.pollute(chunk, -cp) end
	pollution = pollution + cp
	
	chunk = {inside_x - 16,inside_y + 16}
	cp = inside_surface.get_pollution(chunk)
	if cp ~= 0 then inside_surface.pollute(chunk, -cp) end
	pollution = pollution + cp
	
	chunk = {inside_x + 16,inside_y + 16}
	cp = inside_surface.get_pollution(chunk)
	if cp ~= 0 then inside_surface.pollute(chunk, -cp) end
	pollution = pollution + cp
	
	if pollution == 0 then return end
	
	if factory.built then
		factory.outside_surface.pollute({factory.outside_x, factory.outside_y}, pollution + factory.stored_pollution)
		factory.stored_pollution = 0
	else
		factory.stored_pollution = factory.stored_pollution + pollution
	end
end

script.on_nth_tick(15, function(event)
	local factories = global.factories
	for i = (event.tick%4+1), #factories, 4 do
		local factory = factories[i]
		if factory ~= nil then update_pollution(factory) end
	end
end) 
