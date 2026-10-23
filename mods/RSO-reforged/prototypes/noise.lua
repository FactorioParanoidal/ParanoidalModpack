--[[ RSO Reforged: resources and enemy bases are placed by the engine's map generator from the
noise expressions built here. The map preview shows the real map and chunk generation runs no Lua.

Per planet with an RSO config (expression prefix p = "rso_<planet>_"):

* Sites. The map is a grid of cells of about one RSO region (size chosen so that the density
  of fields matches the RSO rolls; the frequency of the map generator row "RSO fields" scales
  it). A cell holds at most one field site at a jittered position; its random numbers come from
  one voronoi cell id of the cell index (rso_rand; random_penalty is not usable, it also depends
  on the evaluated tile), spread by rso_frac. A site in water or on the shore (elevation at the
  site, prototypes/relocate.lua) moves to its second place in the cell. A field never reaches
  past the 2x2 cells around a tile, so every tile evaluates four sites; the owner is the nearest
  one relative to its size. Every expression runs for every tile: the code keeps the number of
  operations low (one cell id per site, lookups as short if-chains).
* Resource of a site: RSO weights (allotment and frequency slider) times the distance
  composition, the dominant resource of the province (3x3 cells) and the soil geology of
  Alien-biomes-Reforged (alien-biomes-geology-<resource>, evaluated at the site so that the whole
  field has one resource). Guaranteed ring: every cell of a band around the first start holds a
  field, the cells of the ring points get one field of every resource.
* Field: the coordinates are bent by noise, turned and stretched; the shape is one of
  config.shapes: classic blob, diamond or ring (donuts) with a second lobe and a bite, or an
  exotic crescent, seam, specks (many small spots), archipelago or star; exotic shapes are rarer
  near the start and resources have signature shapes (config.shape_preference). The partner ore of
  a multi-resource field lies in the lobe, in the core or in stripes. Amounts grow to the centre
  and are divided by the shape volume, a rich vein crosses some fields, infinite cores lie in the
  densest part. Liquids: wells on a jittered grid, as a cluster around the site or a chain along
  a fault line, spaced by their collision box.
* Starting fields: one field of every starting resource around every start, on an arc that
  leaves the starting lake free.
* Enemy bases (config entries of type "entity"): regular bases are spots of spot_noise (the
  engine picks candidate sites, preferring dry land, with the RSO chance per region growing with
  the distance); a field site may get a base along it (along_resource_probability) and a rich
  field (vein or infinite core) a bigger guard base. Spawner and worm kinds follow the RSO
  allotments by distance. They are placed before trees and rocks, so they never stand in a forest.
* rso_free = 0 on ore tiles and around wells: trees and rocks (rso-remove-trees) are not placed
  there; rso_free_decor = 0 also within 2 tiles of them (large decoratives reach that far), so
  no grass lies on the ore.

The control stage reads the same expressions with LuaSurface.calculate_tile_properties (sites,
forecasts, guards, grades) and the names from the mod-data prototype "rso-reforged".
]]
local C = require("config")
local loadConfig = require("resourceconfigs.mainconfig")
local relocate = require("prototypes.relocate")

local fmt, concat = string.format, table.concat
local function setting(name) return settings.startup[name].value end

local REGION = setting("rso-region-size") * 32 -- RSO region (distance unit), tiles
local SA = "(starting_area_radius / 150)"       -- starting area slider (150 at 100 %)
local FIELDS = "rso-fields"                     -- map generator row of all RSO fields (data.lua)

local defs, defined = {}, {}
local function define(prototype)
	assert(not defined[prototype.name], "RSO: noise name defined twice: " .. prototype.name)
	defined[prototype.name] = true
	defs[#defs + 1] = prototype
end
local function expression(name, text) define{type = "noise-expression", name = name, expression = text} end
local function noise_function(name, parameters, text)
	define{type = "noise-function", name = name, parameters = parameters, expression = text}
end

local function num(v)
	if type(v) ~= "number" then return v end
	if v == math.floor(v) and math.abs(v) < 2^31 then return fmt("%d", v) end
	return fmt("%.10g", v)
end

-- value of a per-resource list for the resource index `index` (an expression): a sum over the
-- non-zero entries when they are few, an if-chain otherwise
local function lookup(index, values)
	local first, same, terms = num(values[1]), true, {}
	for k, v in ipairs(values) do
		v = num(v)
		if v ~= first then same = false end
		if v ~= "0" then terms[#terms + 1] = fmt("(%s == %d) * %s", index, k, v) end
	end
	if same then return first end
	if #terms == 0 then return "0" end
	if 2 * #terms <= #values then return "(" .. concat(terms, " + ") .. ")" end
	local chain = num(values[#values])
	for k = #values - 1, 1, -1 do
		chain = fmt("if(%s == %d, %s, %s)", index, k, num(values[k]), chain)
	end
	return chain
end

-- map generator slider of an autoplace control; "1" without such control
local function slider(control, field)
	return data.raw["autoplace-control"][control] and fmt("var('control:%s:%s')", control, field) or "1"
end
local function size_mod(control) -- RSO halves enlargements
	local s = slider(control, "size")
	return s == "1" and "1" or fmt("if(%s > 1, 1 + (%s - 1) / 2, %s)", s, s, s)
end
local function enabled(control)
	local s = slider(control, "size")
	return s == "1" and "1" or fmt("(%s > 0)", s)
end

-- random number in [0, 1) of the integer cell (ci, cj), stream k: depends only on the cell, the
-- stream and the map seed (24 bits)
noise_function("rso_rand", {"k", "ci", "cj"},
	"voronoi_cell_id{x = ci + 0.5, y = cj + 0.5, seed0 = map_seed, seed1 = k, grid_size = 1, distance_type = 'chebyshev', jitter = 0}")
-- more numbers from one: fractional part of v * a (a of a few thousand keeps 12+ bits)
noise_function("rso_frac", {"v", "a"}, "v * a - floor(v * a)")
local SPREAD = {1013.7, 2711.3, 1531.9, 3299.1, 2083.3, 1777.7, 3919.3, 1201.1, 2459.7, 3607.9, 1399.3,
	2903.9, 1867.1, 3203.3, 2237.9, 1657.3, 3511.7, 2591.3, 2851.7, 3797.3, 1129.9}
-- edge noise of the fields
expression("rso_wobble", "basis_noise{x = x, y = y, seed0 = map_seed, seed1 = 'rso-wobble', input_scale = 1/9}"
	.. " + basis_noise{x = x, y = y, seed0 = map_seed, seed1 = 'rso-wobble-fine', input_scale = 1/3.5, output_scale = 0.5}")

-- Dry land at a point for the sites (evaluated at four sites for every tile, so it must be cheap):
-- the elevation of Nauvis without its small-scale detail and the starting lake, which only
-- shape coasts and the starting area. Built from the named parts of the game's elevation; without
-- them the full elevation is used.
local function dry_land_expressions()
	local parts = {"nauvis_hills_plateaus", "nauvis_bridges", "nauvis_macro", "nauvis_segmentation_multiplier", "water_level"}
	for _, name in ipairs(parts) do
		if not data.raw["noise-expression"][name] then return nil end
	end
	-- in data.raw at once: relocate.at() reads it
	data:extend({{type = "noise-expression", name = "rso_dry_land",
		local_expressions = {main = "20 * (lerp(0.5 * nauvis_hills_plateaus - 0.6, 1.9 * nauvis_hills_plateaus + 1.6, "
			.. "0.1 + 0.5 * nauvis_bridges) + 3 * nauvis_macro * clamp(distance * nauvis_segmentation_multiplier / 2000, 0, 1))"},
		expression = "max(main - 2 * water_level, main + 20 * (2.5 - distance * segmentation_multiplier / 200))"}})
	defined.rso_dry_land = true
	return "rso_dry_land"
end
-- Measured on seed 20261022: agrees with the elevation on 94 % of the map; 31 % of the sites were
-- in water and move, about 20 % have both places wet (large lakes) and are not placed.
local DRY_LAND = dry_land_expressions() or "elevation"

local env = {
	has = function(name)
		local resource = data.raw.resource[name]
		return resource ~= nil and resource.autoplace ~= nil
	end,
	mods = mods,
	setting = setting,
}

local function collision_size(resource)
	local box = resource.collision_box
	if not box then return 1 end
	local lt, rb = box[1] or box.left_top, box[2] or box.right_bottom
	local w = (rb[1] or rb.x) - (lt[1] or lt.x)
	local h = (rb[2] or rb.y) - (lt[2] or lt.y)
	return math.max(1, math.ceil(math.max(w, h)))
end

-- the enemy config of a planet: the first entity entry (by name) with bases
local function enemy_config(config)
	local names = {}
	for name, cfg in pairs(config) do
		if type(cfg) == "table" and cfg.type == "entity" and cfg.bases then names[#names + 1] = name end
	end
	table.sort(names)
	return names[1] and config[names[1]]
end

-- weights of allotment entries at the distance d (regions beyond the starting area, an
-- expression): allotment * min(d ^ allotment_distance_factor, max_allotment_distance_factor) when
-- d > min_distance. RSO computeAllotments never applied the cap of the configs (it read a field of
-- another name), so far from the start the biggest worms pushed out all others.
local function allotments(entries, d, prototype_types)
	local list = {}
	for name, v in pairs(entries or {}) do
		local kind
		for _, t in ipairs(prototype_types) do
			if data.raw[t][name] then kind = t break end
		end
		if kind then
			local w = num(v.allotment)
			if v.allotment_distance_factor then
				local growth = fmt("%s ^ %s", d, num(v.allotment_distance_factor))
				if v.max_allotment_distance_factor then
					growth = fmt("min(%s, %s)", growth, num(v.max_allotment_distance_factor))
				end
				w = fmt("%s * %s", w, growth)
			end
			if v.min_distance then w = fmt("%s * (%s > %s)", w, d, num(v.min_distance)) end
			list[#list + 1] = {name = name, type = kind, weight = w}
		end
	end
	table.sort(list, function(a, b) return a.name < b.name end)
	return list
end

-- Enemy bases of a planet. f: names of the field expressions. Returns {{name, type, probability}}.
local function build_enemies(planet_name, e, P, f)
	local EON = fmt("%s * (1 - no_enemies_mode)", enabled("enemy-base"))
	local ESM = size_mod("enemy-base")
	expression(P("e_d"), fmt("distance / %s", num(REGION)))
	expression(P("e_dp"), fmt("max(%s - %s * %s, 0.5)", P("e_d"), num(C.starting_area_size), SA))
	expression(P("e_mult"), e.size_per_region_factor and fmt("min(%s ^ %s, 5)", P("e_dp"), num(e.size_per_region_factor)) or "1")
	-- spawners of a base and its radius (a spawner needs about 230 tiles of the map generator box)
	expression(P("e_n"), fmt("%s * %s * %s * %s", num((e.size.min + e.size.max) / 2), P("e_mult"),
		num(setting("rso-enemy-base-size")), ESM))
	local function radius(n)
		return fmt("clamp(%s * sqrt(%s), %s, %s)", num(C.enemy_radius), n, num(C.enemy_radius_min), num(C.enemy_radius_max))
	end
	expression(P("e_r"), radius(P("e_n")))
	local excl = fmt("(%s * %s)", num(REGION * C.starting_area_size), SA)

	-- regular bases: RSO rolls absolute_probability per region (growing with the distance), then
	-- spawns_per_region bases
	local base = "0"
	if e.absolute_probability then
		local chance = num(e.absolute_probability)
		if e.probability_distance_factor then
			chance = fmt("%s * min(%s, %s ^ %s)", chance, num(e.max_probability_distance_factor or 1e9),
				num(e.probability_distance_factor), P("e_d"))
		end
		expression(P("e_rate"), fmt("%s * %s * %s * %s / %s", chance, slider("enemy-base", "frequency"),
			num((e.spawns_per_region.min + e.spawns_per_region.max) / 2), ESM, num(REGION * REGION)))
		expression(P("e_spot"), fmt("spot_noise{x = x, y = y, density_expression = %s * %s, spot_quantity_expression = %s, "
			.. "spot_radius_expression = %s, spot_favorability_expression = %s, seed0 = map_seed, seed1 = noise_layer_id('rso-enemy-%s'), "
			.. "region_size = 512, candidate_point_count = %d, suggested_minimum_candidate_point_spacing = %s, "
			.. "hard_region_target_quantity = 0, basement_value = -1, maximum_spot_basement_radius = %s}",
			P("e_rate"), P("e_n"), P("e_n"), P("e_r"),
			-- dry land first, in random order; candidates of the starting area last
			fmt("(elevation > %s) + random_penalty{x = x, y = y, seed = 31, source = 1, amplitude = 1} - 4 * (distance < %s + %s)",
				num(C.site_dry_elevation), excl, num(C.enemy_radius_max)),
			planet_name, C.enemy_candidates, num(C.enemy_spacing), num(C.enemy_radius_max)))
		base = fmt("max(0, %s) * (distance > %s)", P("e_spot"), excl)
	end

	-- a base along a field, a bigger guard base by a rich field (vein or infinite core)
	local along = e.along_resource_probability and fmt("(%s < %s)", f.r_along, num(e.along_resource_probability)) or "0"
	local guard_chance = setting("rso-guard-chance")
	expression(P("e_guard"), guard_chance > 0 and fmt("(1 - %s) * max(%s, %s >= %s) * (%s >= %s) * (%s < %s)", f.liq,
		f.veinon, f.coretiles, num(C.infinite_core_tiles), f.d, num(C.guard_min_distance), f.r_guard, num(guard_chance)) or "0")
	expression(P("e_fn"), fmt("%s * if(%s, %s, 1)", P("e_n"), P("e_guard"), num(C.guard_size_mult)))
	expression(P("e_fr"), radius(P("e_fn")))
	local field = fmt("%s * max(%s, %s) * 3 * %s / (pi * %s ^ 2) * max(0, 1 - sqrt(%s ^ 2 + %s ^ 2) / %s)", f.active, along,
		P("e_guard"), P("e_fn"), P("e_fr"), f.dx, f.dy, P("e_fr"))
	-- expected spawners per tile (the cones of all bases)
	expression(P("e_h"), fmt("%s * max(%s, %s)", EON, base, field))

	-- one kind per tile, picked by a random number of the tile: otherwise the kind placed first
	-- would win every collision
	local out = {}
	local function shares(list, scale, seed)
		if #list == 0 then return end
		local sum = {}
		for _, v in ipairs(list) do sum[#sum + 1] = v.weight end
		expression(scale .. "_pick", fmt("(1 - random_penalty{x = x, y = y, seed = %d, source = 1, amplitude = 1}) * (%s)",
			seed, concat(sum, " + ")))
		local low = "0"
		for _, v in ipairs(list) do
			local high = low .. " + " .. v.weight
			out[#out + 1] = {name = v.name, type = v.type,
				probability = fmt("%s * (%s_pick >= %s) * (%s_pick < %s)", scale, scale, low, scale, high)}
			low = "(" .. high .. ")"
		end
	end
	expression(P("e_spawners"), fmt("%s * %s", P("e_h"), num(C.spawner_boost)))
	shares(allotments(e.bases, P("e_dp"), {"unit-spawner"}), P("e_spawners"), 41)
	if e.sub_spawns and e.sub_spawn_probability then
		-- worms per spawner: RSO sub_spawn_probability (growing with the distance) times the
		-- sub_spawn_size, scaled as the base size
		local chance = num(e.sub_spawn_probability)
		if e.sub_spawn_distance_factor then
			chance = fmt("%s * min(%s, %s ^ %s)", chance, num(e.sub_spawn_max_distance_factor or 1e9),
				num(e.sub_spawn_distance_factor), P("e_dp"))
		end
		local size = e.sub_spawn_size and (e.sub_spawn_size.min + e.sub_spawn_size.max) / 2 or 1
		expression(P("e_worms"), fmt("%s * %s * %s * %s * %s * %s", P("e_h"), chance, num(size), ESM, P("e_mult"),
			num(C.worm_boost)))
		shares(allotments(e.sub_spawns, P("e_dp"), {"turret"}), P("e_worms"), 43)
	end
	return out
end

-- builds the expressions of a planet; returns names {entity -> {probability, richness}}, enemies
-- {{name, type, probability}}, info
local function build_planet(planet_name, config, ignored)
	local p = "rso_" .. planet_name:gsub("[^%w]", "_") .. "_"
	local function P(name) return p .. name end

	-- resources of the planet, sorted: their index is the "kind"
	local list = {}
	for name, cfg in pairs(config) do
		if type(cfg) == "table" and (cfg.type == "resource-ore" or cfg.type == "resource-liquid") and env.has(name)
			and not ignored[name] and (cfg.allotment or 0) > 0 then
			list[#list + 1] = name
		end
	end
	if #list == 0 then return nil end
	table.sort(list)
	local index = {}
	for k, name in ipairs(list) do index[name] = k end
	local n = #list
	local enemy = enemy_config(config)

	-- density: the RSO rolls of a region (resourceChanceMultiplier per planet); the enemy entry
	-- counts as in RSO
	local count = n + (enemy and 1 or 0)
	local rolls = math.min(math.ceil(count / 10) - 1, 3)
	local chance = setting("rso-resource-chance") * (config.resourceChanceMultiplier or 1)
	local none, expected = 1, 0
	for roll = 0, rolls do
		local c = math.max(0, math.min(1, chance - roll * 0.1))
		none, expected = none * (1 - c), expected + c
	end
	local site_chance = 1 - none
	local J = C.site_jitter
	-- cell size: one site per cell; the frequency of "RSO fields" makes cells smaller
	local G0 = expected > 0 and REGION * math.sqrt(site_chance / expected) or REGION
	expression(P("G"), fmt("%s / sqrt(%s)", num(G0), slider(FIELDS, "frequency")))
	local G = P("G")
	expression(P("rcap"), fmt("min(64, %s * %s)", num((1 - J / 2) / C.field_extent), G))
	local GS = fmt("(%s * %s)", num(setting("rso-global-size-mult")), size_mod(FIELDS))
	local GR = fmt("(%s * %s)", num(setting("rso-global-richness-mult")), slider(FIELDS, "richness"))
	local donuts = setting("rso-use-donuts")
	local multi_active = setting("rso-multi-resource-active")
	local vein_chance = setting("rso-vein-chance")
	local threshold = setting("rso-infinite-ore-threshold")

	-- per-resource values (index order)
	local V = {a = {}, liq = {}, smin = {}, sspan = {}, smean = {}, R = {}, Rspan = {}, minA = {}, multiC = {},
		partner = {}, infC = {}, infMin = {}, infR = {}, spacing = {}, geo = {}, dw = {}}
	local radius_sum, ore_count = 0, 0
	for k, name in ipairs(list) do
		local cfg = config[name]
		local control = cfg.autoplace_name or name
		local liquid = cfg.type == "resource-liquid"
		local on = enabled(control)
		V.a[k] = fmt("(%s * %s * %s)", num(cfg.allotment), slider(control, "frequency"), on)
		V.liq[k] = liquid and 1 or 0
		local sm = size_mod(control)
		V.smin[k] = fmt("(%s * %s)", num(cfg.size.min), sm)
		V.sspan[k] = fmt("(%s * %s)", num(cfg.size.max - cfg.size.min), sm)
		V.smean[k] = fmt("(%s * %s)", num((cfg.size.min + cfg.size.max) / 2), sm)
		local rich = slider(control, "richness")
		if liquid then
			V.R[k] = fmt("(%s * %s * %s)", num(cfg.richness.min), rich, GR)
			V.Rspan[k] = fmt("(%s * %s * %s)", num(cfg.richness.max - cfg.richness.min), rich, GR)
			V.minA[k] = cfg.minimum_amount or 1
			V.spacing[k] = collision_size(data.raw.resource[name]) + C.well_gap
		else
			V.R[k] = fmt("(%s * %s * %s)", num(cfg.richness), rich, GR)
			V.Rspan[k] = 0
			V.minA[k] = cfg.min_amount or C.min_amount
			V.spacing[k] = 0
			radius_sum, ore_count = radius_sum + (cfg.size.min + cfg.size.max) / 2, ore_count + 1
		end
		-- multi-resource partner, picked with the random p_r13
		local partners, total = {}, {}
		if multi_active and cfg.multi_resource and (cfg.multi_resource_chance or 0) > 0 then
			local names = {}
			for partner in pairs(cfg.multi_resource) do
				if index[partner] and partner ~= name then names[#names + 1] = partner end
			end
			table.sort(names)
			for _, partner in ipairs(names) do
				local c = config[partner]
				partners[#partners + 1] = {k = index[partner],
					w = fmt("(%s * %s)", num(cfg.multi_resource[partner]), enabled(c.autoplace_name or partner))}
				total[#total + 1] = partners[#partners].w
			end
		end
		if #partners == 0 then
			V.multiC[k], V.partner[k] = 0, 0
		else
			V.multiC[k] = cfg.multi_resource_chance
			if #partners == 1 then
				V.partner[k] = fmt("(%d * (%s > 0))", partners[1].k, partners[1].w)
			else
				local sum, terms = "0", {}
				local pick = fmt("(%s * (%s))", P("r13"), concat(total, " + "))
				for _, partner in ipairs(partners) do
					local upper = sum .. " + " .. partner.w
					terms[#terms + 1] = fmt("%d * (%s >= %s) * (%s < %s)", partner.k, pick, sum, pick, upper)
					sum = "(" .. upper .. ")"
				end
				V.partner[k] = "(" .. concat(terms, " + ") .. ")"
			end
		end
		-- infinite variant in the core
		local infinite = "infinite-" .. name
		local inf = not liquid and env.has(infinite) and data.raw.resource[infinite]
		if inf then
			-- core radius in field radii; RSO: metaball force above the threshold
			V.infC[k] = fmt("(%s * %s * %s)", num(C.infinite_core * math.sqrt(1 - threshold)), slider(infinite, "size"), enabled(infinite))
			V.infMin[k] = inf.minimum or 1
			V.infR[k] = slider(infinite, "richness")
		else
			V.infC[k], V.infMin[k], V.infR[k] = 0, 0, 1
		end
		-- soil geology at the site: the whole field gets the same resource
		local geo = "alien-biomes-geology-" .. name
		V.geo[k] = planet_name == "nauvis" and data.raw["noise-expression"][geo] and relocate.at(geo, P("sx"), P("sy")) or nil
		V.dw[k] = setting("rso-distance-composition") and cfg.distance_weight or nil
	end
	expression(P("RP0"), fmt("%s * %s", num((ore_count > 0 and radius_sum / ore_count or 10) * C.field_radius), GS))
	local excl = fmt("(%s * %s + %s * %s)", num(REGION * C.starting_area_size), SA, P("RP0"), num(C.field_extent))
	local start_x = "(-distance_from_nearest_point_x{x = 0, y = 0, points = starting_positions})"
	local start_y = "(-distance_from_nearest_point_y{x = 0, y = 0, points = starting_positions})"

	-- guaranteed ring: every site of a band around the starts is on; the cell holding ring point k
	-- (around the start nearest to the origin) gets resource k
	local ring = fmt("(%s * %s)", num(REGION * (C.starting_area_size + 1.5)), SA)
	local band = "0"
	local ring_terms = {}
	if setting("rso-guaranteed-ring") then
		band = fmt("abs(%%s - %s) < 1.3 * %s", ring, G) -- holds the sites of the ring point cells
		for k, name in ipairs(list) do
			local angle = fmt("(2 * pi * (map_seed_normalized + %s))", num((k - 1) / n))
			expression(P("ring" .. k), fmt("floor((%s + %s * cos(%s)) / %s) * 4096 + floor((%s + %s * sin(%s)) / %s)",
				start_x, ring, angle, G, start_y, ring, angle, G))
			ring_terms[#ring_terms + 1] = fmt("%d * %s * (%s == %s)", k, enabled(config[name].autoplace_name or name),
				P("key"), P("ring" .. k))
		end
	end

	-- one site per cell (ci, cj); a site in water moves to the second place of its cell, a site
	-- whose both places are in water is not placed: the density per land area stays as configured
	local cell = "(ci, cj)"
	noise_function(P("fv"), {"ci", "cj"}, "rso_rand(0, ci, cj)")
	-- first place: anywhere in the inner part of the cell; second place: on the other side of the
	-- cell centre, far from the first one (lakes are large)
	local function first(axis, spread)
		return fmt("(%s + 0.5 + %s * (rso_frac(%s, %s) - 0.5)) * %s", axis, num(J), P("fv") .. cell, num(spread), G)
	end
	local function second(axis, spread, other)
		return fmt("(%s + 0.5 + if(rso_frac(%s, %s) > 0.5, -1, 1) * (0.15 + 0.25 * rso_frac(%s, %s))) * %s", axis,
			P("fv") .. cell, num(spread), P("fv") .. cell, num(other), G)
	end
	noise_function(P("fxa"), {"ci", "cj"}, first("ci", SPREAD[1]))
	noise_function(P("fya"), {"ci", "cj"}, first("cj", SPREAD[2]))
	noise_function(P("fxb"), {"ci", "cj"}, second("ci", SPREAD[1], SPREAD[3]))
	noise_function(P("fyb"), {"ci", "cj"}, second("cj", SPREAD[2], SPREAD[4]))
	local elevation = planet_name == "nauvis" and relocate.at(DRY_LAND, P("fxa") .. cell, P("fya") .. cell)
	if elevation then
		noise_function(P("fwet"), {"ci", "cj"}, fmt("%s < %s", elevation, num(C.site_dry_elevation)))
		noise_function(P("fdrown"), {"ci", "cj"}, fmt("%s * (%s < %s)", P("fwet") .. cell,
			relocate.at(DRY_LAND, P("fxb") .. cell, P("fyb") .. cell), num(C.site_dry_elevation)))
		-- both places wet: a site of the guaranteed ring moves from the first place towards the
		-- nearest start (the elevation keeps the land around a start dry), within the inner part of
		-- its cell; other such sites are not placed (fon)
		local function inland(axis, f, dfn)
			return fmt("clamp(%s - 0.4 * %s * %s{x = %s, y = %s, points = starting_positions} / max(1, %s), (%s + 0.1) * %s, (%s + 0.9) * %s)",
				P(f) .. cell, G, dfn, P("fxa") .. cell, P("fya") .. cell, P("fda") .. cell, axis, G, axis, G)
		end
		noise_function(P("fda"), {"ci", "cj"}, fmt("distance_from_nearest_point{x = %s, y = %s, points = starting_positions}",
			P("fxa") .. cell, P("fya") .. cell))
		noise_function(P("fx"), {"ci", "cj"}, fmt("if(%s, if(%s, %s, %s), %s)", P("fwet") .. cell, P("fdrown") .. cell,
			inland("ci", "fxa", "distance_from_nearest_point_x"), P("fxb") .. cell, P("fxa") .. cell))
		noise_function(P("fy"), {"ci", "cj"}, fmt("if(%s, if(%s, %s, %s), %s)", P("fwet") .. cell, P("fdrown") .. cell,
			inland("cj", "fya", "distance_from_nearest_point_y"), P("fyb") .. cell, P("fya") .. cell))
	else
		noise_function(P("fx"), {"ci", "cj"}, P("fxa") .. cell)
		noise_function(P("fy"), {"ci", "cj"}, P("fya") .. cell)
	end
	noise_function(P("fd"), {"ci", "cj"}, fmt("distance_from_nearest_point{x = %s, y = %s, points = starting_positions}",
		P("fx") .. cell, P("fy") .. cell))
	local d_site = P("fd") .. cell
	-- sites of the guaranteed ring stay even in water: they hold the resources of the ring
	local dry = elevation and fmt(" * (1 - %s)", P("fdrown") .. cell) or ""
	noise_function(P("fon"), {"ci", "cj"}, fmt("max((%s < %s)%s, %s) * (%s > %s)",
		P("fv") .. cell, num(site_chance), dry, band == "0" and "0" or fmt(band, d_site), d_site, excl))
	noise_function(P("fq"), {"ci", "cj"}, fmt("if(%s, ((x - %s) ^ 2 + (y - %s) ^ 2) / (%s * max(1, %s / %s) ^ %s) ^ 2, 1e9)",
		P("fon") .. cell, P("fx") .. cell, P("fy") .. cell, P("RP0"), P("fd") .. cell, num(REGION), num(setting("rso-size-exponent"))))

	-- the four cells around the tile and their owner
	local i0, j0 = P("i0"), P("j0")
	expression(i0, fmt("floor(x / %s - 0.5)", G))
	expression(j0, fmt("floor(y / %s - 0.5)", G))
	local cells = {{i0, j0}, {i0 .. " + 1", j0}, {i0, j0 .. " + 1"}, {i0 .. " + 1", j0 .. " + 1"}}
	local function at(fn, c) return fmt("%s(%s, %s)", P(fn), c[1], c[2]) end
	for q, c in ipairs(cells) do expression(P("q" .. q), at("fq", c)) end
	expression(P("c1"), fmt("%s <= min(%s, %s, %s)", P("q1"), P("q2"), P("q3"), P("q4")))
	expression(P("c2"), fmt("%s <= min(%s, %s)", P("q2"), P("q3"), P("q4")))
	expression(P("c3"), fmt("%s <= %s", P("q3"), P("q4")))
	local function owner(a, b, c, d)
		return fmt("if(%s, %s, if(%s, %s, if(%s, %s, %s)))", P("c1"), a, P("c2"), b, P("c3"), c, d)
	end
	local function owner_of(fn) return owner(at(fn, cells[1]), at(fn, cells[2]), at(fn, cells[3]), at(fn, cells[4])) end
	expression(P("ci"), i0 .. " + " .. owner(0, 1, 0, 1))
	expression(P("cj"), j0 .. " + " .. owner(0, 0, 1, 1))
	expression(P("on"), fmt("min(%s, %s, %s, %s) < 1e8", P("q1"), P("q2"), P("q3"), P("q4")))
	expression(P("sx"), owner_of("fx"))
	expression(P("sy"), owner_of("fy"))
	expression(P("sd"), owner_of("fd"))
	expression(P("key"), fmt("%s * 4096 + %s", P("ci"), P("cj")))
	expression(P("forced"), #ring_terms > 0 and "max(0, " .. concat(ring_terms, ", ") .. ")" or "0")
	-- random numbers of the owner site: r3 .. r19 from one cell id
	expression(P("rnd"), fmt("rso_rand(3, %s, %s)", P("ci"), P("cj")))
	for r = 3, 22 do expression(P("r" .. r), fmt("rso_frac(%s, %s)", P("rnd"), num(SPREAD[r - 2]))) end
	expression(P("d"), fmt("%s / %s", P("sd"), num(REGION)))

	-- resource of the site
	expression(P("t"), fmt("clamp((%s - %s) / %s, 0, 1)", P("d"), num(C.distance_near), num(C.distance_far - C.distance_near)))
	local weight = setting("rso-province-weight")
	for k = 1, n do
		expression(P("a" .. k), V.a[k])
		expression(P("acum" .. k), k == 1 and P("a1") or fmt("%s + %s", P("acum" .. (k - 1)), P("a" .. k)))
	end
	if weight ~= 1 and n > 1 then
		local pi_, pj_ = fmt("floor(%s / %d)", P("ci"), C.province_size), fmt("floor(%s / %d)", P("cj"), C.province_size)
		expression(P("pv"), fmt("rso_rand(20, %s, %s)", pi_, pj_))
		local pick = fmt("rso_frac(%s, %s) * %s", P("pv"), num(SPREAD[16]), P("acum" .. n))
		local passed = {}
		for k = 1, n - 1 do passed[k] = fmt("(%s >= %s)", pick, P("acum" .. k)) end
		expression(P("dom"), fmt("(%s >= %s) * (%s > 0) * (1 + %s)", P("pv"),
			num(C.province_mixed_chance), P("acum" .. n), concat(passed, " + ")))
	end
	for k = 1, n do
		local w = {P("a" .. k)}
		local dw = V.dw[k]
		if dw then w[#w + 1] = fmt("(%s + %s * %s)", num(dw.near), num(dw.far - dw.near), P("t")) end
		if weight ~= 1 and n > 1 then w[#w + 1] = fmt("(1 + %s * (%s == %d))", num(weight - 1), P("dom"), k) end
		if V.geo[k] then w[#w + 1] = V.geo[k] end
		expression(P("cum" .. k), (k > 1 and P("cum" .. (k - 1)) .. " + " or "") .. concat(w, " * "))
	end
	local passed = {}
	local pick = fmt("%s * 0.999999 * %s", P("r3"), P("cum" .. n))
	for k = 1, n - 1 do passed[k] = fmt("(%s >= %s)", pick, P("cum" .. k)) end
	expression(P("kind"), fmt("if(%s > 0, %s, 1%s)", P("forced"), P("forced"), n > 1 and " + " .. concat(passed, " + ") or ""))
	expression(P("valid"), fmt("max(%s > 0, %s > 0) * %s", P("forced"), P("cum" .. n), enabled(FIELDS)))
	local K = P("kind")
	expression(P("liq"), lookup(K, V.liq))
	expression(P("size"), fmt("%s + %s * %s", lookup(K, V.smin), lookup(K, V.sspan), P("r4")))
	expression(P("sizef"), fmt("max(%s, 1) ^ %s", P("d"), num(setting("rso-size-exponent"))))
	local FR = fmt("%s * %s", num(C.field_radius), GS)
	expression(P("rad"), fmt("clamp(%s * %s * %s, 2, %s)", P("size"), P("sizef"), FR, P("rcap")))
	expression(P("partner"), lookup(K, V.partner))
	expression(P("multi"), fmt("(%s < %s) * (%s > 0)", P("r12"), lookup(K, V.multiC), P("partner")))

	-- shape of an ore field: the coordinates are bent by noise (no straight edges), turned by the
	-- angle of the field and stretched; the shape is picked by the weights of config.shapes
	expression(P("dx"), "x - " .. P("sx"))
	expression(P("dy"), "y - " .. P("sy"))
	local rad = P("rad")
	local warp = fmt("%s * %s", num(C.warp), rad)
	expression(P("wx"), fmt("%s + %s * basis_noise{x = x, y = y, seed0 = map_seed, seed1 = 7201, input_scale = 1/24}", P("dx"), warp))
	expression(P("wy"), fmt("%s + %s * basis_noise{x = x, y = y, seed0 = map_seed, seed1 = 7202, input_scale = 1/24}", P("dy"), warp))
	local ang = P("r5") .. " * 2 * pi"
	expression(P("pr"), fmt("%s * cos(%s) + %s * sin(%s)", P("wx"), ang, P("wy"), ang)) -- along the field
	expression(P("qr"), fmt("%s * cos(%s) - %s * sin(%s)", P("wy"), ang, P("wx"), ang)) -- across it
	expression(P("u"), fmt("%s / (0.7 + 0.6 * %s)", P("pr"), P("r6")))
	expression(P("v"), fmt("%s * (0.7 + 0.6 * %s)", P("qr"), P("r6")))
	local u, v, de = P("u"), P("v"), P("de")
	expression(de, fmt("sqrt(%s ^ 2 + %s ^ 2)", u, v))

	local exotic_on = setting("rso-exotic-shapes")
	local shapes = {}
	for _, s in ipairs(C.shapes) do
		if (not s.donuts or donuts) and (not s.exotic or exotic_on) then shapes[#shapes + 1] = s end
	end
	local classic_count = 0
	for i, s in ipairs(shapes) do
		if s.classic then classic_count = i end
		local prefs, special = {}, false
		for k, name in ipairs(list) do
			local p = C.shape_preference[name]
			prefs[k] = p and p[s.name] or 1
			special = special or prefs[k] ~= 1
		end
		local w = num(s.weight)
		if special then w = fmt("%s * %s", w, lookup(K, prefs)) end
		if s.exotic then w = fmt("%s * (%s + %s * %s)", w, num(C.shape_near), num(1 - C.shape_near), P("t")) end
		expression(P("sw" .. i), i == 1 and w or fmt("%s + %s", P("sw" .. (i - 1)), w))
	end
	local passed = {}
	for i = 1, #shapes - 1 do passed[i] = fmt("(%s * %s >= %s)", P("r7"), P("sw" .. #shapes), P("sw" .. i)) end
	expression(P("shape"), #passed > 0 and "1 + " .. concat(passed, " + ") or "1")
	local SH = P("shape")
	local cos_tip = math.cos(math.rad(110)) -- the crescent covers 220 degrees
	local function spots(grid, seed, r0, r1, envelope)
		return fmt("min(1 - %d * voronoi_spot_noise{x = x, y = y, seed0 = map_seed, seed1 = %d, grid_size = %d, "
			.. "distance_type = 'euclidean', jitter = 1} / (%s + %s * %s), 2.5 * (1 - %s / (%s * %s)))",
			grid, seed, grid, num(r0), num(r1 - r0), P("r20"), de, num(envelope), rad)
	end
	local F = {
		blob = fmt("1 - %s / %s", de, rad),
		diamond = fmt("1 - (abs(%s) + abs(%s)) * 0.8 / %s", u, v, rad),
		ring = fmt("1 - abs(%s - 0.6 * %s) / (0.4 * %s)", de, rad, rad),
		crescent = fmt("min(1 - abs(%s - 0.7 * %s) / (0.3 * %s), (%s / max(%s, 0.01) - %s) * %s)", de, rad, rad, u, de,
			num(cos_tip), num(3 / (1 - cos_tip))),
		-- a long narrow band, bent to a side
		seam = fmt("min(1 - abs(%s - (%s - 0.5) * 0.8 * %s ^ 2 / (1.6 * %s)) / (0.3 * %s), 1 - abs(%s) / (1.6 * %s))",
			P("qr"), P("r10"), P("pr"), rad, rad, P("pr"), rad),
		-- many small spots (1.3 - 2.2 tiles) on a 6 tile grid, or islands (3.5 - 5.5 tiles) on a 14 tile grid
		specks = spots(6, 7203, 1.3, 2.2, 1.3),
		archipelago = spots(14, 7204, 3.5, 5.5, 1.35),
		-- 4 - 6 rays
		star = fmt("1 - %s / (%s * (0.45 + 0.6 * max(0, cos((4 + floor(%s * 3)) * atan2(%s, %s))) ^ 2))", de, rad, P("r10"), v, u),
	}
	local chain, edges, volumes = F[shapes[#shapes].name], {}, {}
	for i = #shapes - 1, 1, -1 do chain = fmt("if(%s == %d, %s, %s)", SH, i, F[shapes[i].name], chain) end
	for i, s in ipairs(shapes) do edges[i], volumes[i] = s.edge, s.volume end
	expression(P("f1"), chain)
	expression(P("classic"), fmt("%s <= %d", SH, classic_count))
	local lobe_angle = P("r9") .. " * 2 * pi"
	local lobe_dist = fmt("%s * if(%s, 0.95, 0.55)", rad, P("multi"))
	expression(P("f2"), fmt("(%s * (0.45 + 0.3 * %s) * if(%s, %s, 1) - sqrt((%s - %s * cos(%s)) ^ 2 + (%s - %s * sin(%s)) ^ 2)) / %s",
		rad, P("r10"), P("multi"), num(C.multi_resource_size_factor), P("dx"), lobe_dist, lobe_angle, P("dy"), lobe_dist, lobe_angle, rad))
	local bite_angle = fmt("(%s + pi + %s - 0.5)", lobe_angle, P("r11"))
	expression(P("fb"), fmt("if(%s < %s, (sqrt((%s - 0.9 * %s * cos(%s)) ^ 2 + (%s - 0.9 * %s * sin(%s)) ^ 2) - %s * (0.25 + 0.25 * %s)) / %s, 1)",
		P("r11"), num(C.bite_chance), P("dx"), rad, bite_angle, P("dy"), rad, bite_angle, rad, P("r11"), rad))
	expression(P("f"), fmt("if(%s, min(max(%s, %s), %s), %s)", P("classic"), P("f1"), P("f2"), P("fb"), P("f1")))
	expression(P("inside"), fmt("%s + %s * %s * rso_wobble > 0", P("f"), num(C.edge_noise), lookup(SH, edges)))
	-- the partner ore of a multi-resource field: in the lobe (classic shapes), in the core or in
	-- stripes across the field
	expression(P("p_lobe"), fmt("%s * (%s < %s)", P("classic"), P("r21"), num(C.partner_lobe)))
	expression(P("p_core"), fmt("(%s < %s) * (1 - %s)", P("r21"), num(C.partner_lobe + C.partner_core), P("p_lobe")))
	expression(P("ptile"), fmt("%s * max(%s * (%s > %s), %s * (%s > 0.55), (1 - %s - %s) * (sin(2 * pi * %s / (6 + 5 * %s)) > 0.2))",
		P("multi"), P("p_lobe"), P("f2"), P("f1"), P("p_core"), P("f"), P("p_lobe"), P("p_core"), P("pr"), P("r22")))
	expression(P("kt"), fmt("if(%s, %s, %s)", P("ptile"), P("partner"), K))
	local KT = P("kt")

	-- amounts of an ore field
	local dist_exp, fluid_exp = num(setting("rso-distance-exponent")), num(setting("rso-fluid-distance-exponent"))
	local common = fmt("max(%s, 0.1) ^ %s * (5 + 5 * %s) * (2 * %s) ^ 0.6", P("d"), dist_exp, P("r14"), rad)
	expression(P("total"), fmt("%s * %s", lookup(K, V.R), common))
	local vein = "1"
	if vein_chance > 0 then
		local va = P("r16") .. " * pi"
		expression(P("vein"), fmt("(%s < %s) * (abs(%s * cos(%s) - %s * sin(%s)) <= %s + %s * %s)", P("r15"), num(vein_chance),
			P("wy"), va, P("wx"), va, num(C.vein_half_width[1]), num(C.vein_half_width[2] - C.vein_half_width[1]), P("r17")))
		vein = fmt("if(%s, %s + %s * %s, 1)", P("vein"), num(C.vein_multiplier[1]),
			num((C.vein_multiplier[2] - C.vein_multiplier[1]) / vein_chance), P("r15"))
	end
	-- the shape volume keeps the amount of a field the same for every shape
	expression(P("amount"), fmt("(%s + %s * %s * 3 / (pi * %s ^ 2 * %s) * if(%s, %s, 1) * clamp(%s, 0, 1)) * %s",
		lookup(K, V.minA), lookup(K, V.R), common, rad, lookup(SH, volumes), P("ptile"), num(C.multi_resource_richness_factor),
		P("f"), vein))
	local growth = fmt("sqrt(min(%s, 1 + %s / %s))", num(C.infinite_distance_max), P("d"), num(C.infinite_distance_scale))
	expression(P("ccore"), fmt("%s * %s * (1 - %s)", lookup(K, V.infC), growth, P("ptile")))
	expression(P("core"), fmt("(%s > 0) * (%s > 1 - %s)", P("ccore"), P("f"), P("ccore")))
	expression(P("coretiles"), fmt("pi * (%s * %s * %s) ^ 2", lookup(K, V.infC), growth, rad))
	expression(P("infamount"), fmt("max(%s, %s) * %s", P("amount"), lookup(K, V.infMin), lookup(K, V.infR)))

	-- wells of a liquid field on a jittered grid around the site
	local sp, gap, occ = P("sp"), num(C.well_gap), num(C.well_occupancy)
	expression(sp, lookup(K, V.spacing) .. " + (1 - " .. P("liq") .. ")") -- never 0
	expression(P("wells"), fmt("clamp(floor(%s * %s + 0.5), 1, 30)", P("size"), P("sizef")))
	expression(P("wa"), fmt("floor(%s / %s)", P("dx"), sp))
	expression(P("wb"), fmt("floor(%s / %s)", P("dy"), sp))
	local wcell = fmt("%s * 64 + %s, %s * 64 + %s", P("ci"), P("wa"), P("cj"), P("wb"))
	expression(P("w0"), fmt("rso_rand(30, %s)", wcell))
	for w = 1, 4 do expression(P("w" .. w), fmt("rso_frac(%s, %s)", P("w0"), num(SPREAD[w + 2]))) end
	expression(P("ox"), fmt("%s * %s + (%s - %s) / 2 + %s * %s", P("wa"), sp, sp, gap, gap, P("w1")))
	expression(P("oy"), fmt("%s * %s + (%s - %s) / 2 + %s * %s", P("wb"), sp, sp, gap, gap, P("w2")))
	-- a cluster around the site or a chain along a fault line through it
	local chain_probs = {}
	for k, name in ipairs(list) do chain_probs[k] = C.liquid_chain[name] or C.liquid_chain.default end
	expression(P("chain"), fmt("%s * (%s < %s)", P("liq"), P("r22"), lookup(K, chain_probs)))
	local along = fmt("(%s * cos(%s) + %s * sin(%s))", P("ox"), ang, P("oy"), ang)
	local across = fmt("(%s * cos(%s) - %s * sin(%s))", P("oy"), ang, P("ox"), ang)
	expression(P("wexists"), fmt("max((%s == 0) * (%s == 0), if(%s, (%s < 0.85) * (abs(%s) < 0.75 * %s) * (abs(%s) <= %s * %s / 2.55), "
		.. "(%s < %s) * (%s ^ 2 + %s ^ 2 <= %s ^ 2 * %s / (pi * %s))))",
		P("wa"), P("wb"), P("chain"), P("w0"), across, sp, along, sp, P("wells"),
		P("w0"), occ, P("ox"), P("oy"), sp, P("wells"), occ))
	expression(P("here"), fmt("%s * (floor(x) == floor(%s + %s)) * (floor(y) == floor(%s + %s))",
		P("wexists"), P("sx"), P("ox"), P("sy"), P("oy")))
	expression(P("near"), fmt("%s * (abs(x - %s - %s) < 2.5) * (abs(y - %s - %s) < 2.5)",
		P("wexists"), P("sx"), P("ox"), P("sy"), P("oy")))
	expression(P("wkind"), fmt("if(%s * (%s < 0.5), %s, %s)", P("multi"), P("w3"), P("partner"), K))
	local WK = P("wkind")
	expression(P("wamount"), fmt("max(%s, (%s + %s * %s) * max(%s, 0.1) ^ %s * (0.75 + 0.5 * %s) * if(%s != %s, %s, 1))",
		lookup(WK, V.minA), lookup(WK, V.R), lookup(WK, V.Rspan), P("r14"), P("d"), fluid_exp, P("w4"), WK, K,
		num(C.multi_resource_richness_factor)))
	expression(P("estimate"), fmt("if(%s, %s * (%s + %s * %s) * max(%s, 0.1) ^ %s, %s)", P("liq"), P("wells"),
		lookup(K, V.R), lookup(K, V.Rspan), P("r14"), P("d"), fluid_exp, P("total")))

	-- grade of the field against the average one of its resource at its distance (forecasts)
	local smean = lookup(K, V.smean)
	expression(P("grade"), fmt("if(%s, (%s + %s * %s) / (%s + 0.5 * %s) * %s / clamp(floor(%s * %s + 0.5), 1, 30), "
		.. "(5 + 5 * %s) / 7.5 * (%s / clamp(%s * %s * %s, 2, %s)) ^ 0.6)",
		P("liq"), lookup(K, V.R), lookup(K, V.Rspan), P("r14"), lookup(K, V.R), lookup(K, V.Rspan), P("wells"), smean, P("sizef"),
		P("r14"), rad, smean, P("sizef"), FR, P("rcap")))

	-- what the owner site places on this tile
	expression(P("active"), fmt("%s * %s", P("on"), P("valid")))
	expression(P("ore"), fmt("%s * (1 - %s) * %s", P("active"), P("liq"), P("inside")))
	expression(P("well"), fmt("%s * %s * %s", P("active"), P("liq"), P("here")))

	-- form of the field for the forecasts: a shape, a cluster of wells or a chain of wells
	expression(P("form"), fmt("if(%s, %d + %s, %s)", P("liq"), #shapes + 1, P("chain"), SH))
	local forms = {}
	for i, s in ipairs(shapes) do forms[i] = s.name end
	forms[#forms + 1], forms[#forms + 2] = "wells", "chain"

	-- queries of the control stage: the site of the cell holding the tile
	local own = "(floor(x / " .. G .. "), floor(y / " .. G .. "))"
	expression(P("cell_on"), P("fon") .. own)
	expression(P("cell_x"), P("fx") .. own)
	expression(P("cell_y"), P("fy") .. own)
	expression(P("veinon"), vein_chance > 0 and fmt("%s < %s", P("r15"), num(vein_chance)) or "0")

	-- enemy bases
	local enemies = enemy and build_enemies(planet_name, enemy, P, {active = P("active"), liq = P("liq"),
		veinon = P("veinon"), coretiles = P("coretiles"), d = P("d"), dx = P("dx"), dy = P("dy"),
		r_along = P("r18"), r_guard = P("r19")}) or {}

	-- starting fields: around every start, on an arc away from the starting lake
	local starting = {}
	local ore_in_start, oil_in_start = setting("rso-ore-in-start-area"), setting("rso-oil-in-start-area")
	for _, name in ipairs(list) do
		local cfg = config[name]
		local s = cfg.starting
		if s and (s.probability or 0) > 0 and (cfg.type == "resource-liquid" or ore_in_start)
			and not (name == "crude-oil" and planet_name == "nauvis" and not oil_in_start) then
			starting[#starting + 1] = name
		end
	end
	local start = {} -- resource -> {inside, amount, core}
	local free = {P("ore"), fmt("%s * %s * %s", P("active"), P("liq"), P("near"))}
	if #starting > 0 then
		local lake = fmt("atan2(-distance_from_nearest_point_y{x = %s, y = %s, points = starting_lake_positions}, "
			.. "-distance_from_nearest_point_x{x = %s, y = %s, points = starting_lake_positions})", start_x, start_y, start_x, start_y)
		local clear = math.rad(C.lake_clearance)
		local arc = 2 * math.pi - 2 * clear
		local start_mult = setting("rso-starting-richness-mult")
		local sx, sy = "(x - x_from_start)", "(y - y_from_start)"
		for i, name in ipairs(starting) do
			local k, cfg = index[name], config[name]
			local control, s = cfg.autoplace_name or name, cfg.starting
			local angle = fmt("(%s + %s + %s * (map_seed_normalized - 0.5))", lake, num(clear + arc * (i - 0.5) / #starting),
				num(0.8 * arc / #starting))
			local dist = fmt("(%s * sqrt(%s))", num(C.starting_distance[(i - 1) % 2 + 1]), SA)
			local cx, cy = fmt("(%s * cos(%s))", dist, angle), fmt("(%s * sin(%s))", dist, angle)
			local rich = fmt("%s * %s * %s", num(s.richness * start_mult), slider(control, "richness"), slider(FIELDS, "richness"))
			local on = fmt("%s * %s", enabled(control), enabled(FIELDS))
			if cfg.type == "resource-liquid" then
				local wells, near = {}, {}
				local spacing = V.spacing[k]
				for j = 1, math.max(1, s.size) do
					local wx = fmt("(%s + %s)", cx, num(spacing * math.sqrt(j - 1) * math.cos(2.4 * j)))
					local wy = fmt("(%s + %s)", cy, num(spacing * math.sqrt(j - 1) * math.sin(2.4 * j)))
					wells[#wells + 1] = fmt("(floor(x) == floor(%s + %s)) * (floor(y) == floor(%s + %s))", sx, wx, sy, wy)
					near[#near + 1] = fmt("(abs(x_from_start - %s) < 2.5) * (abs(y_from_start - %s) < 2.5)", wx, wy)
				end
				expression(P("s" .. i), fmt("%s * (%s)", on, concat(wells, " + ")))
				free[#free + 1] = fmt("%s * (%s)", on, concat(near, " + "))
				start[name] = {inside = P("s" .. i), amount = fmt("max(%s, %s)", num(V.minA[k]), rich)}
			else
				local r = fmt("(%s * %s * %s)", num(s.size * C.starting_radius), size_mod(control), size_mod(FIELDS))
				expression(P("sf" .. i), fmt("1 - sqrt((x_from_start - %s) ^ 2 + (y_from_start - %s) ^ 2) / %s", cx, cy, r))
				expression(P("s" .. i), fmt("%s * (%s + %s * rso_wobble > 0)", on, P("sf" .. i), num(C.edge_noise)))
				free[#free + 1] = P("s" .. i)
				local density = fmt("min(%s, %s * 7.5 * (2 * %s) ^ 0.6 * 3 / (pi * %s ^ 2))", num(C.starting_amount_cap), rich, r, r)
				local entry = {inside = P("s" .. i), amount = fmt("%s + %s * clamp(%s, 0, 1)", num(V.minA[k]), density, P("sf" .. i))}
				if setting("rso-infinite-ores-in-start-area") and V.infC[k] ~= 0 then
					entry.core = fmt("%s * (%s > 1 - %s)", P("s" .. i), P("sf" .. i), V.infC[k])
				end
				start[name] = entry
			end
		end
	end
	expression(P("free"), "1 - max(" .. concat(free, ", ") .. ")")

	-- probability and richness of every resource (and of the infinite variants)
	local names = {}
	for k, name in ipairs(list) do
		local s = start[name]
		local prob, rich
		if V.liq[k] == 1 then
			prob = fmt("%s * (%s == %d)", P("well"), WK, k)
			rich = P("wamount")
		else
			prob = fmt("%s * (%s == %d) * (1 - %s)", P("ore"), KT, k, P("core"))
			rich = P("amount")
		end
		if s then
			prob = fmt("max(%s, %s%s)", prob, s.inside, s.core and " * (1 - " .. s.core .. ")" or "")
			rich = fmt("if(%s, %s, %s)", s.inside, s.amount, rich)
		end
		expression(P("prob" .. k), prob)
		expression(P("rich" .. k), rich)
		names[name] = {P("prob" .. k), P("rich" .. k)}
		if V.infC[k] ~= 0 then
			local iprob = fmt("%s * %s * (%s == %d)", P("ore"), P("core"), K, k)
			local irich = P("infamount")
			if s and s.core then
				iprob = fmt("max(%s, %s)", iprob, s.core)
				irich = fmt("if(%s, max(%s, %s) * %s, %s)", s.core, s.amount, num(V.infMin[k]), V.infR[k], irich)
			end
			expression(P("iprob" .. k), iprob)
			expression(P("irich" .. k), irich)
			names["infinite-" .. name] = {P("iprob" .. k), P("irich" .. k)}
		end
	end

	local enemy_names = {}
	for _, e in ipairs(enemies) do enemy_names[#enemy_names + 1] = e.name end
	return names, enemies, {prefix = p, region = REGION, resources = list, enemies = enemy_names, forms = forms}
end

-- autoplace of an enemy prototype placed by RSO: before trees and rocks ("a[tree]", "a[doodad]")
local function enemy_autoplace(prototype, probability)
	local autoplace = prototype.autoplace or {}
	prototype.autoplace = autoplace
	autoplace.control = autoplace.control or "enemy-base"
	autoplace.force = "enemy"
	-- own order per prototype: of entities with an equal order only the most probable one is tried
	autoplace.order = (prototype.type == "unit-spawner" and "a-a[rso-enemy]-a[spawner]-" or "a-a[rso-enemy]-b[worm]-") .. prototype.name
	autoplace.probability_expression = probability
	autoplace.richness_expression = 1
	autoplace.local_expressions, autoplace.local_functions = nil, nil
end

-- applies everything; called from data-final-fixes.lua after the vanilla autoplace is switched off
return function(ignored_resources, ignored_planets)
	local config = loadConfig(env)
	local planets, free = {}, nil
	local planet_names = {}
	for name in pairs(config) do planet_names[#planet_names + 1] = name end
	table.sort(planet_names)
	local managed = {}
	for _, planet_name in ipairs(planet_names) do
		local planet = data.raw.planet[planet_name]
		if planet and not ignored_planets[planet_name] then
			local names, enemies, info = build_planet(planet_name, config[planet_name], ignored_resources)
			if names then
				planets[planet_name] = info
				planet.map_gen_settings = planet.map_gen_settings or {}
				local mgs = planet.map_gen_settings
				mgs.autoplace_controls = mgs.autoplace_controls or {}
				mgs.autoplace_controls[FIELDS] = mgs.autoplace_controls[FIELDS] or {}
				if planet_name == "nauvis" then
					for resource, pair in pairs(names) do
						local autoplace = data.raw.resource[resource].autoplace
						autoplace.probability_expression = pair[1]
						autoplace.richness_expression = pair[2]
						autoplace.local_expressions, autoplace.local_functions = nil, nil
					end
					for _, e in ipairs(enemies) do enemy_autoplace(data.raw[e.type][e.name], e.probability) end
					free = info.prefix .. "free"
				else
					local overrides = mgs.property_expression_names or {}
					mgs.property_expression_names = overrides
					for resource, pair in pairs(names) do
						overrides["entity:" .. resource .. ":probability"] = pair[1]
						overrides["entity:" .. resource .. ":richness"] = pair[2]
					end
					for _, e in ipairs(enemies) do
						local prototype = data.raw[e.type][e.name]
						if not prototype.autoplace then enemy_autoplace(prototype, "0") end
						overrides["entity:" .. e.name .. ":probability"] = e.probability
					end
					overrides.rso_free = info.prefix .. "free"
				end
				for resource in pairs(names) do managed[resource] = true end
				for _, e in ipairs(enemies) do managed[e.name] = true end
			end
		end
	end
	-- other planets do not get the nauvis fields and bases of the managed prototypes
	for planet_name, planet in pairs(data.raw.planet) do
		if planet_name ~= "nauvis" and not planets[planet_name] and not ignored_planets[planet_name] then
			planet.map_gen_settings = planet.map_gen_settings or {}
			local overrides = planet.map_gen_settings.property_expression_names or {}
			planet.map_gen_settings.property_expression_names = overrides
			for name in pairs(managed) do
				overrides["entity:" .. name .. ":probability"] = "0"
			end
			overrides.rso_free = "1"
		end
	end
	expression("rso_free", free or "1")
	-- no decorative within 2 tiles of the ore (large grass reaches that far): the neighbours come
	-- from one larger grid (multisample)
	expression("rso_busy", "1 - rso_free")
	local around = {}
	for dx = -2, 2 do
		for dy = -2, 2 do around[#around + 1] = fmt("multisample(rso_busy, %d, %d)", dx, dy) end
	end
	expression("rso_free_decor", "1 - max(" .. concat(around, ", ") .. ")")
	for _, prototype in ipairs(relocate.prototypes()) do define(prototype) end
	data:extend(defs)
	data:extend({{type = "mod-data", name = "rso-reforged", data = {planets = planets}}})
end
