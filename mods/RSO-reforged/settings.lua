local function bool(name, default, order)
	return {type = "bool-setting", name = name, setting_type = "runtime-global", default_value = default, order = order}
end

local function double(name, default, minimum, maximum, order)
	return {type = "double-setting", name = name, setting_type = "runtime-global", default_value = default,
		minimum_value = minimum, maximum_value = maximum, order = order}
end

data:extend({
	{type = "int-setting", name = "rso-region-size", setting_type = "runtime-global", default_value = 7,
		minimum_value = 3, maximum_value = 100, order = "a"},
	double("rso-starting-richness-mult", 1.0, 0.001, 100, "aa"),
	double("rso-resource-chance", 0.5, 0.01, 1.0, "ba"),
	double("rso-global-richness-mult", 1.0, 0.001, 100, "bb"),
	double("rso-global-size-mult", 1.0, 0.01, 3, "bc"),
	double("rso-enemy-chance", 0.25, 0.01, 1.0, "cb"),
	double("rso-enemy-base-size", 1.0, 1.0, 20.0, "cc"),
	double("rso-distance-exponent", 1.1, 0.0, 3.0, "da"),
	double("rso-fluid-distance-exponent", 0.6, 0.0, 3.0, "db"),
	double("rso-size-exponent", 0.2, 0.0, 0.5, "dc"),
	bool("rso-use-donuts", false, "ea"),
	bool("rso-remove-trees", false, "eb"),
	bool("rso-oil-in-start-area", false, "ef"),
	bool("rso-ore-in-start-area", true, "eg"),
	bool("rso-infinite-ores-in-start-area", false, "fa"),
	double("rso-infinite-ore-threshold", 0.7, 0.0, 1.0, "fb"),
	bool("rso-reveal-spawned-resources", false, "ga"),
	bool("rso-multi-resource-active", true, "gb"),
	-- RSO Reforged
	double("rso-province-weight", 3, 1, 10, "ha"),
	bool("rso-distance-composition", true, "hb"),
	bool("rso-guaranteed-ring", true, "hc"),
	double("rso-vein-chance", 0.25, 0, 1, "hd"),
	double("rso-guard-chance", 0.5, 0, 1, "he"),
	double("rso-mine-ruin-chance", 0.35, 0, 1, "hf"),
	double("rso-depletion-vein-chance", 0.003, 0, 0.05, "hg"),
})
