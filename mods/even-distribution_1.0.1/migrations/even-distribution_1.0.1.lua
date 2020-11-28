
-- remove existing guis
for __,player in pairs(game.players) do
	for __,gui in pairs(player.gui.relative.children) do
		if gui and gui.valid and gui.get_mod() == script.mod_name then gui.destroy() end
	end
end

log("Even Distribution: Migrated to version 1.0.1")