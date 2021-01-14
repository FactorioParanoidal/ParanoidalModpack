function countIonCannonsReady(force, surface) -- TODO check all callers
	local surfaceName = nil
	if type(surface) == "string" then surfaceName = surface else surfaceName = surface.name end
	local ionCannonsReady = 0
	if global.forces_ion_cannon_table[force.name] then
		for i, cooldown in pairs(global.forces_ion_cannon_table[force.name]) do
			if cooldown[2] == 1 and cooldown[3] == surfaceName then
				ionCannonsReady = ionCannonsReady + 1
			end
		end
	end
	return ionCannonsReady
end

function timeUntilNextReady(force, surface) -- TODO check all callers
	local surfaceName = nil
	if type(surface) == "string" then surfaceName = surface else surfaceName = surface.name end
	local shortestCooldown = settings.global["ion-cannon-cooldown-seconds"].value
	for i, cooldown in pairs(global.forces_ion_cannon_table[force.name]) do
		if cooldown[1] < shortestCooldown and cooldown[2] == 0 and cooldown[3] == surfaceName then
			shortestCooldown = cooldown[1]
		end
	end
	return shortestCooldown
end