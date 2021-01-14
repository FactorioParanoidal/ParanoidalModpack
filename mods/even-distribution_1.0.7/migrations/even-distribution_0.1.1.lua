-- remove all blue markers
for __,surface in pairs(game.surfaces) do
	for __,marker in pairs(surface.find_entities_filtered{ name = "distribution-marker" }) do
		if marker and marker.valid then marker.destroy() end
	end
end

log("Even Distribution: All distribution markers have been removed")