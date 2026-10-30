local params = {
	science_packet_cost = { --evolution cost coefficients for specific science packs
		["planetary-data"] = 1400,
		["station-science"] = 3000,
	},
	constant_factor = 0.15, --percent of evolution per each researched technology
	linear_factor = 0.35, --percent of evolution per 1000 total researched science packs
	max_finite_levels = 10, --count_formula technology with more levels is infinite for the "ignore infinite" setting
	-- Paranoidal: share of constant_factor for technologies whose name starts with the prefix. The ten
	-- "Quality control" levels of ic-more-qualities count as one technology together (decision 2026-10-19).
	constant_scale = {
		["ic-defect-control-"] = 0.1,
	},
	-- Paranoidal: technologies whose name starts with one of these prefixes never raise evolution and get
	-- no tooltip, whatever the settings: the upgrade chains of paranoidal-upgrade-tech (decision 2026-10-30).
	ignored_prefixes = {
		"research-efficiency-",
		"worker-robot-battery-",
	},
}

-- True when the technology name starts with one of params.ignored_prefixes.
function params.ignored_name(name)
	if type(name) == "string" then
		for _, prefix in ipairs(params.ignored_prefixes) do
			if string.sub(name, 1, #prefix) == prefix then
				return true
			end
		end
	end
	return false
end

-- Share of constant_factor for a technology name (1 when no prefix matches).
function params.constant_share(name)
	if type(name) == "string" then
		for prefix, share in pairs(params.constant_scale) do
			if string.sub(name, 1, #prefix) == prefix then
				return share
			end
		end
	end
	return 1
end

return params
