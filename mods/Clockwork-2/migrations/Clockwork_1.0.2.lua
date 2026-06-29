if not storage.surfaces then
	storage.surfaces = {}
	for index, surface in pairs(game.surfaces) do
		storage.surfaces[surface.index] = {ticks_per_day = surface.ticks_per_day, frozen = false}
		storage.surfaces[1].ticks_per_day = 25000
	end
end
storage.permanight_surfaces = storage.permanight_surfaces or {}