local params = {
	science_packet_cost = { --evolution cost coefficients for specific science packs
		["planetary-data"] = 1400,
		["station-science"] = 3000,
	},
	-- Paranoidal: 0.12 / 0.15 instead of 0.15 / 0.35 (decision 2026-10-30): about 75% evolution after the
	-- whole tree up to chemical science instead of about 90%.
	constant_factor = 0.12, --percent of evolution per each researched technology
	linear_factor = 0.15, --percent of evolution per 1000 total researched science packs
	max_finite_levels = 10, --count_formula technology with more levels is infinite for the "ignore infinite" setting
	-- Paranoidal: share of constant_factor for technologies whose name starts with the prefix. The ten
	-- "Quality control" levels of ic-more-qualities count as one technology together (decision 2026-10-19).
	constant_scale = {
		["ic-defect-control-"] = 0.1,
	},
	-- Paranoidal: technologies whose name starts with one of these prefixes never raise evolution and get
	-- no tooltip, whatever the settings: the upgrade chains of paranoidal-upgrade-tech (decision 2026-10-30).
	-- Inserter, toolbelt and braking chains (decision 2026-10-30).
	ignored_prefixes = {
		"research-efficiency-",
		"worker-robot-battery-",
		"inserter-stack-size-bonus-",
		"inserter-capacity-bonus-",
		"toolbelt-",
		"braking-force-",
	},
	-- Paranoidal: same as ignored_prefixes, by the exact technology name (decision 2026-10-30).
	ignored_names = {
		["bnl-flight-recorder-decoding"] = true,
		["bob-long-inserters-1"] = true,
		["bob-long-inserters-2"] = true,
		["bob-near-inserters"] = true,
		["bob-more-inserters-1"] = true,
		["bob-more-inserters-2"] = true,
		["toolbelt"] = true,
		["aai-basic-loader"] = true,
		["aai-loader"] = true,
		["aai-fast-loader"] = true,
		["aai-express-loader"] = true,
		["aai-turbo-loader"] = true,
		["aai-ultimate-loader"] = true,
	},
	-- Raise by one after changing ignored_prefixes or ignored_names: a save with an older value gets the
	-- evolution already counted for newly ignored technologies taken back once (control.lua refund).
	ignore_revision = 1,
}

-- True when the technology name is in params.ignored_names or starts with one of params.ignored_prefixes.
function params.ignored_name(name)
	if type(name) == "string" then
		if params.ignored_names[name] then
			return true
		end
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
