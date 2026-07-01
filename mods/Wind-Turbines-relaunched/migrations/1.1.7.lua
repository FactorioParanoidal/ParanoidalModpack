for _, surface in pairs(game.surfaces) do
	for _, entity in pairs(surface.find_entities_filtered{
		name = {"twt-collision-rect", "twt-collision-rect2", "twt-collision-rect3", "twt-collision-rect4"}
	}) do
		entity.destructible = true
		if entity.name == "twt-collision-rect" then
			entity.health = 100
		end
		if entity.name == "twt-collision-rect2" then
			entity.health = 300
		end
		if entity.name == "twt-collision-rect3" then
			entity.health = 1200
		end
		if entity.name == "twt-collision-rect4" then
			entity.health = 5000
		end
	end
end