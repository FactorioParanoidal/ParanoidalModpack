-- Paranoidal: a map whose Nauvis was generated without enemy bases (enemy-base size "none", e.g. the preset
-- "Paranoidal: no enemies") is a peaceful map. Rampant has nothing to command there and says nothing about the
-- truce, flyers or juggernauts.
local peacefulMap = {}

function peacefulMap.active()
	local surface = game.surfaces["nauvis"] or game.get_surface(1)
	local controls = surface and surface.map_gen_settings.autoplace_controls
	local enemyBase = controls and controls["enemy-base"]
	return (enemyBase ~= nil) and (enemyBase.size == 0)
end

return peacefulMap
