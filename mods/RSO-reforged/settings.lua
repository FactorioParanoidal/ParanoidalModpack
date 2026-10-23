-- Generation settings are startup settings: the map generator reads them as noise expressions
-- (prototypes/noise.lua), resources and enemy bases alike. Runtime settings belong to the script
-- parts: mine ruins, new veins and charting.
local function setting(type, kind, name, default, order, minimum, maximum)
	return {type = type, name = name, setting_type = kind, default_value = default, order = order,
		minimum_value = minimum, maximum_value = maximum}
end

local function startup_bool(name, default, order) return setting("bool-setting", "startup", name, default, order) end
local function startup_double(name, default, minimum, maximum, order)
	return setting("double-setting", "startup", name, default, order, minimum, maximum)
end
local function runtime_bool(name, default, order) return setting("bool-setting", "runtime-global", name, default, order) end
local function runtime_double(name, default, minimum, maximum, order)
	return setting("double-setting", "runtime-global", name, default, order, minimum, maximum)
end

data:extend({
	setting("int-setting", "startup", "rso-region-size", 7, "a", 3, 100),
	startup_double("rso-starting-richness-mult", 1.0, 0.001, 100, "aa"),
	startup_double("rso-resource-chance", 0.5, 0.01, 1.0, "ba"),
	startup_double("rso-global-richness-mult", 1.0, 0.001, 100, "bb"),
	startup_double("rso-global-size-mult", 1.0, 0.01, 3, "bc"),
	startup_double("rso-distance-exponent", 1.1, 0.0, 3.0, "da"),
	startup_double("rso-fluid-distance-exponent", 0.6, 0.0, 3.0, "db"),
	startup_double("rso-size-exponent", 0.2, 0.0, 0.5, "dc"),
	startup_bool("rso-use-donuts", false, "ea"),
	startup_bool("rso-exotic-shapes", true, "eaa"),
	startup_bool("rso-remove-trees", false, "eb"),
	startup_bool("rso-oil-in-start-area", false, "ef"),
	startup_bool("rso-ore-in-start-area", true, "eg"),
	startup_bool("rso-infinite-ores-in-start-area", false, "fa"),
	startup_double("rso-infinite-ore-threshold", 0.7, 0.0, 1.0, "fb"),
	startup_bool("rso-multi-resource-active", true, "gb"),
	startup_double("rso-province-weight", 3, 1, 10, "ha"),
	startup_bool("rso-distance-composition", true, "hb"),
	startup_bool("rso-guaranteed-ring", true, "hc"),
	startup_double("rso-vein-chance", 0.25, 0, 1, "hd"),
	startup_double("rso-enemy-chance", 0.25, 0.01, 1.0, "cb"),
	startup_double("rso-enemy-base-size", 1.0, 1.0, 20.0, "cc"),
	startup_double("rso-guard-chance", 0.5, 0, 1, "he"),

	runtime_bool("rso-reveal-spawned-resources", false, "ga"),
	runtime_double("rso-mine-ruin-chance", 0.35, 0, 1, "hf"),
	runtime_double("rso-depletion-vein-chance", 0.003, 0, 0.05, "hg"),
})
