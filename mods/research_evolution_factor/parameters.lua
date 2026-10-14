local params = {
	science_packet_cost = { --evolution cost coefficients for specific science packs
		["planetary-data"] = 1400,
		["station-science"] = 3000,
	},
	constant_factor = 0.15, --percent of evolution per each researched technology
	linear_factor = 0.35, --percent of evolution per 1000 total researched science packs
	max_finite_levels = 10, --count_formula technology with more levels is infinite for the "ignore infinite" setting
}

return params
