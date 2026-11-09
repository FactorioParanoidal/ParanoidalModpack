-- Researched level of the smog protection chain per force (storage.levels[force_index]).
local C = require("shared.config")

local R = {}

local function researched_level(force)
	for level = C.TECH_LEVELS, 1, -1 do
		local technology = force.technologies[C.TECH .. "-" .. level]
		if technology and technology.researched then return level end
	end
	return 0
end

function R.compute(force)
	local level = researched_level(force)
	storage.levels[force.index] = level
	return level
end

function R.level(force)
	-- A status read before the force cache is populated must not write storage.
	return storage.levels[force.index] or researched_level(force)
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
