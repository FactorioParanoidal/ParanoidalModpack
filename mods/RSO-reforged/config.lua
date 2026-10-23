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
	site_dry_elevation = 1,   -- a site lower than this (water, shore) moves to its second place in the cell;
	                          -- with both places that low the cell has no field
	field_extent = 2.1,       -- field reach in radii: lobe, edge noise
	field_radius = 0.72,      -- field radius per unit of the config "size"
	edge_noise = 0.3,         -- edge noise amplitude in radii
	bite_chance = 0.5,        -- a bite out of the edge (classic shapes)
	warp = 0.18,              -- the coordinates of a field are bent by noise by up to this share of its radius

	-- Shapes of ore fields. weight: base chance; edge: share of the edge noise; volume: amount of
	-- clamp(shape, 0, 1) against the blob, so every shape holds the same ore: integrated numerically,
	-- then corrected by the sums of real fields (seed 20261022: edge noise, bites, lobes);
	-- classic: may get the second lobe, the bite and a partner lobe; exotic: rarer near the start;
	-- setting: startup setting that switches the shape on; donuts: only with rso-use-donuts.
	shapes = {
		{name = "blob", weight = 5, edge = 1, volume = 0.95, classic = true},
		{name = "diamond", weight = 1.5, edge = 1, volume = 0.88, classic = true},
		{name = "ring", weight = 1.5, edge = 0.8, volume = 1.3, classic = true, donuts = true},
		{name = "crescent", setting = "rso-shape-crescent", weight = 1.2, edge = 0.7, volume = 0.83, exotic = true},
		{name = "seam", setting = "rso-shape-seam", weight = 1.2, edge = 0.6, volume = 0.7, exotic = true},
		{name = "specks", setting = "rso-shape-specks", weight = 1, edge = 0.25, volume = 0.45, exotic = true},
		{name = "archipelago", setting = "rso-shape-archipelago", weight = 1, edge = 0.5, volume = 0.5, exotic = true},
		{name = "star", setting = "rso-shape-star", weight = 0.4, edge = 0.6, volume = 0.47, exotic = true},
	},
	shape_near = 0.35, -- weight of exotic shapes up to distance_near (full from distance_far on)
	-- without the experimental settings: weight multipliers of rare shapes (no signature resources,
	-- none up to distance_near)
	rare_shapes = {star = 0.25, specks = 0.25},
	-- signature shapes of resources: weight multipliers
	shape_preference = {
		coal = {seam = 4},
		["angels-ore1"] = {star = 3, diamond = 2},  -- sapphirite: crystals
		["angels-ore2"] = {crescent = 3},           -- jivolite
		["angels-ore3"] = {archipelago = 2, blob = 1.5}, -- stiratite
		["angels-ore4"] = {diamond = 3},            -- crotinnium
		["angels-ore5"] = {specks = 4},             -- rubyte
		["angels-ore6"] = {archipelago = 3},        -- bobmonium
		["iron-ore"] = {blob = 2},
		["copper-ore"] = {crescent = 2},
		stone = {archipelago = 3},
		["uranium-ore"] = {specks = 3},
	},
	-- where the partner ore of a multi-resource field lies: a lobe (classic shapes), the core, else stripes
	partner_lobe = 0.4,
	partner_core = 0.3,
	-- wells of a liquid field: a chain along a fault line with this chance, else a cluster
	liquid_chain = {default = 0.3, ["angels-fissure"] = 0.7}, -- setting rso-shape-chain
	well_occupancy = 0.6,     -- share of the well grid cells with a well
	well_gap = 4,             -- jitter of a well in its grid cell, tiles
	starting_radius = 0.5,    -- starting field radius per unit of starting.size (as the RSO metaballs)
	starting_distance = {70, 105}, -- starting fields alternate between these distances (tiles)
	starting_distance_random = {40, 100}, -- without the experimental settings: random distance (tiles)
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
	infinite_distance_max_fixed = 1.5, -- the same without the experimental settings
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
