-- Fixed generation constants (control stage). Player-facing values are mod settings.
return {
	debug_enabled = false,      -- verbose generation log (factorio-current.log)
	config_log_enabled = false, -- dump the built per-surface config to the log

	starting_area_size = 1, -- starting area radius in regions, safe from random nonsense

	multi_resource_richness_factor = 0.60, -- any additional resource is multiplied by this value times resources-1
	multi_resource_size_factor = 0.90,
	multi_resource_chance_diminish = 0.6,  -- diminishing effect factor on multi_resource_chance

	min_amount = 250, -- default minimum amount of resource in a single ore tile

	-- infinite resources (detected by the prototype) are spawned with their size multiplied by this
	endless_resource_mode_sizeModifier = 0.80,

	ignoreMapGenSettings = false, -- do not read the map generator sliders

	useResourceCollisionDetection = true,    -- shift ore fields to reduce overlaps with other resources
	resourceCollisionDetectionRatio = 0.999, -- placeable share that ends the search early
	resourceCollisionDetectionRatioFallback = 0.75, -- at least this share of a field must be placeable
	resourceCollisionFieldSkip = true,       -- skip the field completely if the best share is below the fallback

	-- RSO Reforged. Distances are in regions from the nearest starting area.
	province_size = 3,            -- a geological province is province_size x province_size regions
	province_mixed_chance = 0.2,  -- share of provinces without a dominant resource
	distance_near = 2,            -- distance_weight.near applies up to here ...
	distance_far = 12,            -- ... and distance_weight.far from here on
	infinite_distance_scale = 10, -- the infinite part of a field grows by 1x per this many regions ...
	infinite_distance_max = 3,    -- ... up to this many times
	ring_width = 2.5,             -- guaranteed ring: regions beyond the starting area
	vein_multiplier = {3, 5},     -- richness of a vein against the field around it
	vein_half_width = {0.8, 2},   -- tiles from the vein axis
	infinite_core_tiles = 8,      -- an infinite core: at least this many infinite tiles in a field
	guard_min_distance = 2,       -- no guard nests closer than this
	guard_size_mult = 1.5,        -- a guard base is bigger than an ordinary one
	mine_min_distance = 4,        -- no mine ruins closer than this
	depletion_vein_size = {5, 9},
	depletion_vein_richness = 0.4, -- against a fresh field at the same place
	depletion_vein_distance = {0, 6}, -- tiles from the depleted tile: the vein fills the mined-out ground
	depletion_vein_min_ratio = 0.1,   -- the rest of the field occupies most tiles around
}
