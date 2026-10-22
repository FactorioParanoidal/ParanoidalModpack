local guards = {}

local guarded_pairs = {
	["bob-fluid-generator-1"] = { electronics = true, ["logistic-science-pack"] = true },
	["bob-electrolyser-2"] = { ["logistic-science-pack"] = true },
}

-- Bob's Tech 2.1.0 removes these prerequisites even when the optional technologies are absent.
function guards.install()
	local original_remove_prerequisite = bobmods.lib.tech.remove_prerequisite
	bobmods.lib.tech.remove_prerequisite = function(technology, prerequisite)
		local prerequisites = guarded_pairs[technology]
		if prerequisites and prerequisites[prerequisite] and not data.raw.technology[technology] then
			return
		end
		return original_remove_prerequisite(technology, prerequisite)
	end
	return original_remove_prerequisite
end

function guards.restore(original_remove_prerequisite)
	bobmods.lib.tech.remove_prerequisite = original_remove_prerequisite
end

return guards
