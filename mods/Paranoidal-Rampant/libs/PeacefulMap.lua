-- Paranoidal: suppress truce information and enemy warnings on a map with native No Enemies or without enemy
-- bases (enemy-base size "none", e.g. the preset "Paranoidal: no enemies"). Peaceful mode alone is different.
local peacefulMap = {}

function peacefulMap.active()
	local surface = game.surfaces["nauvis"] or game.get_surface(1)
	if surface and surface.no_enemies_mode then return true end
	local controls = surface and surface.map_gen_settings.autoplace_controls
	local enemyBase = controls and controls["enemy-base"]
	return (enemyBase ~= nil) and (enemyBase.size == 0)
end

return peacefulMap
