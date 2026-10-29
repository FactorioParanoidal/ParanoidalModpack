-- Researched level of the smog protection chain per force (storage.levels[force_index]).
local C = require("shared.config")

local R = {}

function R.compute(force)
	local technologies = force.technologies
	for level = C.TECH_LEVELS, 1, -1 do
		local technology = technologies[C.TECH .. "-" .. level]
		if technology and technology.researched then
			storage.levels[force.index] = level
			return level
		end
	end
	storage.levels[force.index] = 0
	return 0
end

function R.level(force)
	return storage.levels[force.index] or R.compute(force)
end

function R.compute_all()
	storage.levels = {}
	for _, force in pairs(game.forces) do
		R.compute(force)
	end
end

function R.is_ours(name)
	return string.sub(name, 1, #C.TECH + 1) == C.TECH .. "-"
end

return R
