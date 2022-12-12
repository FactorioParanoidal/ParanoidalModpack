for _, factory in pairs(global.factories) do
	if type(factory.radar) == 'table' and not factory.radar.name then
		factory.radar = factory.radar[1]
	end
end
