-- Fixed generation constants (data and control stage). Player-facing values are mod settings and
-- the rows "RSO fields" / "Enemy bases" of the map generator. Distances in regions are measured
-- from the nearest starting position; a region is rso-region-size chunks.
return {
	debug_enabled = false, -- verbose log of the control stage (factorio-current.log)

	starting_area_size = 1, -- starting area radius in regions (scaled by the "starting area" slider)
	min_amount = 250,       -- minimum amount of an ore tile when a config has none

	multi_resource_richness_factor = 0.6, -- the partner part of a multi-resource field
	multi_resource_size_factor = 0.9,

	-- sites and fields of the noise generator (prototypes/noise.lua)
	site_jitter = 0.8,        -- share of a cell the site can move in; fields never reach past the 2x2 cells
	site_dry_elevation = 1,   -- a site lower than this (water, shore) moves to its second place in the cell
	field_extent = 2.1,       -- field reach in radii: lobe, edge noise
	field_radius = 0.72,      -- field radius per unit of the config "size"
	edge_noise = 0.3,         -- edge noise amplitude in radii
	square_chance = 0.5,      -- rotated square fields (RSO MetaSquare) ...
	square_chance_donuts = 0.33, -- ... when donuts are on
	donut_chance = 0.33,      -- rings with rso-use-donuts
	bite_chance = 0.5,        -- a bite out of the edge
	well_occupancy = 0.6,     -- share of the well grid cells with a well
	well_gap = 4,             -- jitter of a well in its grid cell, tiles
	starting_radius = 0.5,    -- starting field radius per unit of starting.size (as the RSO metaballs)
	starting_distance = {70, 105}, -- starting fields alternate between these distances (tiles)
	starting_amount_cap = 4000,    -- per tile in starting fields (as RSO)
	lake_clearance = 50,      -- degrees on both sides of the starting lake kept free of starting fields

	-- enemy bases (noise generator); sizes and chances come from resourceconfigs/vanilla_enemies.lua
	enemy_radius = 8.5,       -- base radius per sqrt(spawners): a spawner needs about 230 tiles
	enemy_radius_min = 10,
	enemy_radius_max = 48,
	enemy_spacing = 48,       -- minimal distance of candidate base sites (spot noise)
	enemy_candidates = 100,   -- candidate base sites per 512x512 tiles
	spawner_boost = 1.4,      -- placement attempts per expected spawner (some collide)
	worm_boost = 1.0,

	-- RSO Reforged
	province_size = 3,            -- a geological province is province_size x province_size cells
	province_mixed_chance = 0.2,  -- share of provinces without a dominant resource
	distance_near = 2,            -- distance_weight.near applies up to here ...
	distance_far = 12,            -- ... and distance_weight.far from here on
	infinite_distance_scale = 10, -- the infinite core grows by 1x per this many regions ...
	infinite_distance_max = 3,    -- ... up to this many times
	ring_width = 2.5,             -- guaranteed ring: regions beyond the starting area (mid at 1.5)
	vein_multiplier = {3, 5},     -- richness of a vein against the field around it
	vein_half_width = {0.8, 2},   -- tiles from the vein axis
	infinite_core = 0.7,          -- radius of the infinite core in field radii per sqrt(1 - threshold)
	infinite_core_tiles = 8,      -- a rich field: at least this many infinite tiles
	guard_min_distance = 2,       -- no guard nests closer than this (regions)
	guard_size_mult = 1.5,        -- a guard base is bigger than an ordinary one
	mine_min_distance = 4,        -- no mine ruins closer than this (regions)
	depletion_vein_size = {5, 9},
	depletion_vein_richness = 0.4, -- against a fresh field at the same place
	depletion_vein_distance = {0, 6}, -- tiles from the depleted tile: the vein fills the mined-out ground
	grade_poor = 0.85,            -- forecast grades: field amount against the average of its resource
	grade_rich = 1.15,            -- and distance (grade 1)
}
