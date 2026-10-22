--[[ RSO Reforged: resources are placed by the engine's map generator from the noise expressions
built here. The map preview shows the real map and chunk generation runs no Lua for resources.

Per planet with an RSO config (expression prefix p = "rso_<planet>_"):

* Sites. The map is a grid of cells of about one RSO region (size chosen so that the density
  of fields matches the RSO rolls). A cell holds at most one field site at a jittered position;
  its random numbers come from one voronoi cell id of the cell index (rso_rand; random_penalty
  is not usable, it also depends on the evaluated tile), spread by rso_frac. A field never
  reaches past the 2x2 cells around a tile, so every tile evaluates four sites; the owner is the
  nearest one relative to its size. Every expression runs for every tile: the code keeps the
  number of operations low (one cell id per site, lookups as short if-chains).
* Resource of a site: RSO weights (allotment and frequency slider) times the distance
  composition, the dominant resource of the province (3x3 cells) and the soil geology of
  Alien-biomes-Reforged (alien-biomes-geology-<resource>). Guaranteed ring: every cell of a
  band around the first start holds a field, the cells of the ring points get one field of
  every resource.
* Field: rotated ellipse or square, or a ring (donuts), a second lobe (with a multi-resource
  roll the partner ore lies in it), a bite and noisy edges; amounts grow to the centre, a
  rich vein crosses some fields, infinite cores lie in the densest part. Liquids: wells on a
  jittered grid around the site, spaced by their collision box.
* Starting fields: one field of every starting resource around every start, on an arc that
  leaves the starting lake free.
* rso_free = 0 on ore tiles and around wells: trees and rocks (rso-remove-trees) are not placed
  there; rso_free_decor = 0 also within 2 tiles of them (large decoratives reach that far), so
  no grass lies on the ore.

The control stage reads the same expressions with LuaSurface.calculate_tile_properties (sites,
forecasts, guards) and the constants from the mod-data prototype "rso-reforged".
]]
local C = require("config")
local loadConfig = require("resourceconfigs.mainconfig")

local fmt, concat = string.format, table.concat
local function setting(name) return settings.startup[name].value end

local REGION = setting("rso-region-size") * 32 -- RSO region (distance unit), tiles
local SA = "(starting_area_radius / 150)"       -- starting area slider (150 at 100 %)

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
	2903.9, 1867.1, 3203.3, 2237.9, 1657.3}
-- edge noise of the fields
expression("rso_wobble", "basis_noise{x = x, y = y, seed0 = map_seed, seed1 = 'rso-wobble', input_scale = 1/9}"
	.. " + basis_noise{x = x, y = y, seed0 = map_seed, seed1 = 'rso-wobble-fine', input_scale = 1/3.5, output_scale = 0.5}")

local env = {
	has = function(name)
		local resource = data.raw.resource[name]
		return resource ~= nil and resource.autoplace ~= nil
	end,
	mods = mods,
}

local ENEMY_PLANETS = {nauvis = true, gleba = true} -- resourceconfigs/vanilla_enemies.lua

local function collision_size(resource)
	local box = resource.collision_box
	if not box then return 1 end
	local lt, rb = box[1] or box.left_top, box[2] or box.right_bottom
	local w = (rb[1] or rb.x) - (lt[1] or lt.x)
	local h = (rb[2] or rb.y) - (lt[2] or lt.y)
	return math.max(1, math.ceil(math.max(w, h)))
end

-- builds the expressions of a planet; returns {names = {resource -> {probability, richness}}, info}
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

	-- density: the RSO rolls of a region (resourceChanceMultiplier per planet)
	local count = n + (ENEMY_PLANETS[planet_name] and 1 or 0)
	local rolls = math.min(math.ceil(count / 10) - 1, 3)
	local chance = setting("rso-resource-chance") * (config.resourceChanceMultiplier or 1)
	local none, expected = 1, 0
	for roll = 0, rolls do
		local c = math.max(0, math.min(1, chance - roll * 0.1))
		none, expected = none * (1 - c), expected + c
	end
	local site_chance = 1 - none
	local G = expected > 0 and REGION * math.sqrt(site_chance / expected) or REGION
	local J = C.site_jitter
	local rcap = math.min(64, (1 - J / 2) * G / C.field_extent)
	local global_size = setting("rso-global-size-mult")
	local global_rich = setting("rso-global-richness-mult")
	local donuts = setting("rso-use-donuts")
	local multi_active = setting("rso-multi-resource-active")
	local vein_chance = setting("rso-vein-chance")
	local threshold = setting("rso-infinite-ore-threshold")

	-- per-resource values (index order)
	local V = {a = {}, liq = {}, smin = {}, sspan = {}, R = {}, Rspan = {}, minA = {}, multiC = {}, partner = {},
		infC = {}, infMin = {}, infR = {}, spacing = {}, geo = {}, dw = {}}
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
		local rich = slider(control, "richness")
		if liquid then
			V.R[k] = fmt("(%s * %s)", num(cfg.richness.min * global_rich), rich)
			V.Rspan[k] = fmt("(%s * %s)", num((cfg.richness.max - cfg.richness.min) * global_rich), rich)
			V.minA[k] = cfg.minimum_amount or 1
			V.spacing[k] = collision_size(data.raw.resource[name]) + C.well_gap
		else
			V.R[k] = fmt("(%s * %s)", num(cfg.richness * global_rich), rich)
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
		local geo = "alien-biomes-geology-" .. name
		V.geo[k] = planet_name == "nauvis" and data.raw["noise-expression"][geo] and fmt("var('%s')", geo) or nil
		V.dw[k] = setting("rso-distance-composition") and cfg.distance_weight or nil
	end
	local RP0 = (ore_count > 0 and radius_sum / ore_count or 10) * C.field_radius * global_size
	local excl = fmt("(%s * %s + %s)", num(REGION * C.starting_area_size), SA, num(RP0 * C.field_extent))
	local start_x = "(-distance_from_nearest_point_x{x = 0, y = 0, points = starting_positions})"
	local start_y = "(-distance_from_nearest_point_y{x = 0, y = 0, points = starting_positions})"

	-- guaranteed ring: every site of a band around the starts is on; the cell holding ring point k
	-- (around the start nearest to the origin) gets resource k
	local ring = fmt("(%s * %s)", num(REGION * (C.starting_area_size + 1.5)), SA)
	local band = "0"
	local ring_terms = {}
	if setting("rso-guaranteed-ring") then
		band = fmt("abs(%%s - %s) < %s", ring, num(1.3 * G)) -- holds the sites of the ring point cells
		for k, name in ipairs(list) do
			local angle = fmt("(2 * pi * (map_seed_normalized + %s))", num((k - 1) / n))
			expression(P("ring" .. k), fmt("floor((%s + %s * cos(%s)) / %s) * 4096 + floor((%s + %s * sin(%s)) / %s)",
				start_x, ring, angle, num(G), start_y, ring, angle, num(G)))
			ring_terms[#ring_terms + 1] = fmt("%d * %s * (%s == %s)", k, enabled(config[name].autoplace_name or name),
				P("key"), P("ring" .. k))
		end
	end

	-- one site per cell (ci, cj)
	local cell = "(ci, cj)"
	noise_function(P("fv"), {"ci", "cj"}, "rso_rand(0, ci, cj)")
	noise_function(P("fx"), {"ci", "cj"}, fmt("(ci + 0.5 + %s * (rso_frac(%s, %s) - 0.5)) * %s", num(J), P("fv") .. cell, num(SPREAD[1]), num(G)))
	noise_function(P("fy"), {"ci", "cj"}, fmt("(cj + 0.5 + %s * (rso_frac(%s, %s) - 0.5)) * %s", num(J), P("fv") .. cell, num(SPREAD[2]), num(G)))
	noise_function(P("fd"), {"ci", "cj"}, fmt("distance_from_nearest_point{x = %s, y = %s, points = starting_positions}",
		P("fx") .. cell, P("fy") .. cell))
	local d_site = P("fd") .. cell
	noise_function(P("fon"), {"ci", "cj"}, fmt("max(%s < %s, %s) * (%s > %s)",
		P("fv") .. cell, num(site_chance), band == "0" and "0" or fmt(band, d_site), d_site, excl))
	noise_function(P("fq"), {"ci", "cj"}, fmt("if(%s, ((x - %s) ^ 2 + (y - %s) ^ 2) / (%s * max(1, %s / %s) ^ %s) ^ 2, 1e9)",
		P("fon") .. cell, P("fx") .. cell, P("fy") .. cell, num(RP0), P("fd") .. cell, num(REGION), num(setting("rso-size-exponent"))))

	-- the four cells around the tile and their owner
	local i0, j0 = P("i0"), P("j0")
	expression(i0, fmt("floor(x / %s - 0.5)", num(G)))
	expression(j0, fmt("floor(y / %s - 0.5)", num(G)))
	local cells = {{i0, j0}, {i0 .. " + 1", j0}, {i0, j0 .. " + 1"}, {i0 .. " + 1", j0 .. " + 1"}}
	local function at(f, c) return fmt("%s(%s, %s)", P(f), c[1], c[2]) end
	for q, c in ipairs(cells) do expression(P("q" .. q), at("fq", c)) end
	expression(P("c1"), fmt("%s <= min(%s, %s, %s)", P("q1"), P("q2"), P("q3"), P("q4")))
	expression(P("c2"), fmt("%s <= min(%s, %s)", P("q2"), P("q3"), P("q4")))
	expression(P("c3"), fmt("%s <= %s", P("q3"), P("q4")))
	local function owner(a, b, c, d)
		return fmt("if(%s, %s, if(%s, %s, if(%s, %s, %s)))", P("c1"), a, P("c2"), b, P("c3"), c, d)
	end
	local function owner_of(f) return owner(at(f, cells[1]), at(f, cells[2]), at(f, cells[3]), at(f, cells[4])) end
	expression(P("ci"), i0 .. " + " .. owner(0, 1, 0, 1))
	expression(P("cj"), j0 .. " + " .. owner(0, 0, 1, 1))
	expression(P("on"), fmt("min(%s, %s, %s, %s) < 1e8", P("q1"), P("q2"), P("q3"), P("q4")))
	expression(P("sx"), owner_of("fx"))
	expression(P("sy"), owner_of("fy"))
	expression(P("sd"), owner_of("fd"))
	expression(P("key"), fmt("%s * 4096 + %s", P("ci"), P("cj")))
	expression(P("forced"), #ring_terms > 0 and "max(0, " .. concat(ring_terms, ", ") .. ")" or "0")
	-- random numbers of the owner site: r3 .. r17 from one cell id
	expression(P("rnd"), fmt("rso_rand(3, %s, %s)", P("ci"), P("cj")))
	for r = 3, 17 do expression(P("r" .. r), fmt("rso_frac(%s, %s)", P("rnd"), num(SPREAD[r - 2]))) end
	expression(P("d"), fmt("%s / %s", P("sd"), num(REGION)))

	-- resource of the site
	expression(P("t"), fmt("clamp((%s - %s) / %s, 0, 1)", P("d"), num(C.distance_near), num(C.distance_far - C.distance_near)))
	local weight = setting("rso-province-weight")
	local acum = {}
	for k = 1, n do
		expression(P("a" .. k), V.a[k])
		acum[k] = k == 1 and P("a1") or fmt("%s + %s", P("acum" .. (k - 1)), P("a" .. k))
		expression(P("acum" .. k), acum[k])
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
	expression(P("valid"), fmt("max(%s > 0, %s > 0)", P("forced"), P("cum" .. n)))
	local K = P("kind")
	expression(P("liq"), lookup(K, V.liq))
	expression(P("size"), fmt("%s + %s * %s", lookup(K, V.smin), lookup(K, V.sspan), P("r4")))
	expression(P("sizef"), fmt("max(%s, 1) ^ %s", P("d"), num(setting("rso-size-exponent"))))
	expression(P("rad"), fmt("clamp(%s * %s * %s, 2, %s)", P("size"), P("sizef"), num(C.field_radius * global_size), num(rcap)))
	expression(P("partner"), lookup(K, V.partner))
	expression(P("multi"), fmt("(%s < %s) * (%s > 0)", P("r12"), lookup(K, V.multiC), P("partner")))

	-- shape of an ore field
	expression(P("dx"), "x - " .. P("sx"))
	expression(P("dy"), "y - " .. P("sy"))
	local ang, rad = P("r5") .. " * 2 * pi", P("rad")
	expression(P("u"), fmt("(%s * cos(%s) + %s * sin(%s)) / (0.7 + 0.6 * %s)", P("dx"), ang, P("dy"), ang, P("r6")))
	expression(P("v"), fmt("(%s * cos(%s) - %s * sin(%s)) * (0.7 + 0.6 * %s)", P("dy"), ang, P("dx"), ang, P("r6")))
	expression(P("de"), fmt("sqrt(%s ^ 2 + %s ^ 2)", P("u"), P("v")))
	local square = fmt("if(%s < %s, (abs(%s) + abs(%s)) * 0.8, %s)", P("r7"),
		num(donuts and C.square_chance_donuts or C.square_chance), P("u"), P("v"), P("de"))
	local plain = fmt("1 - %s / %s", square, rad)
	expression(P("f1"), donuts and fmt("if(%s < %s, 1 - abs(%s - 0.6 * %s) / (0.4 * %s), %s)", P("r8"), num(C.donut_chance),
		P("de"), rad, rad, plain) or plain)
	local lobe_angle = P("r9") .. " * 2 * pi"
	local lobe_dist = fmt("%s * if(%s, 0.95, 0.55)", rad, P("multi"))
	expression(P("f2"), fmt("(%s * (0.45 + 0.3 * %s) * if(%s, %s, 1) - sqrt((%s - %s * cos(%s)) ^ 2 + (%s - %s * sin(%s)) ^ 2)) / %s",
		rad, P("r10"), P("multi"), num(C.multi_resource_size_factor), P("dx"), lobe_dist, lobe_angle, P("dy"), lobe_dist, lobe_angle, rad))
	local bite_angle = fmt("(%s + pi + %s - 0.5)", lobe_angle, P("r11"))
	expression(P("fb"), fmt("if(%s < %s, (sqrt((%s - 0.9 * %s * cos(%s)) ^ 2 + (%s - 0.9 * %s * sin(%s)) ^ 2) - %s * (0.25 + 0.25 * %s)) / %s, 1)",
		P("r11"), num(C.bite_chance), P("dx"), rad, bite_angle, P("dy"), rad, bite_angle, rad, P("r11"), rad))
	expression(P("f"), fmt("min(max(%s, %s), %s)", P("f1"), P("f2"), P("fb")))
	expression(P("inside"), fmt("%s + %s * rso_wobble > 0", P("f"), num(C.edge_noise)))
	expression(P("ptile"), fmt("%s * (%s > %s)", P("multi"), P("f2"), P("f1")))
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
			P("dy"), va, P("dx"), va, num(C.vein_half_width[1]), num(C.vein_half_width[2] - C.vein_half_width[1]), P("r17")))
		vein = fmt("if(%s, %s + %s * %s, 1)", P("vein"), num(C.vein_multiplier[1]),
			num((C.vein_multiplier[2] - C.vein_multiplier[1]) / vein_chance), P("r15"))
	end
	expression(P("amount"), fmt("(%s + %s * %s * 3 / (pi * %s ^ 2) * if(%s, %s, 1) * clamp(%s, 0, 1)) * %s",
		lookup(K, V.minA), lookup(K, V.R), common, rad, P("ptile"), num(C.multi_resource_richness_factor), P("f"), vein))
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
	expression(P("wexists"), fmt("max((%s == 0) * (%s == 0), (%s < %s) * (%s ^ 2 + %s ^ 2 <= %s ^ 2 * %s / (pi * %s)))",
		P("wa"), P("wb"), P("w0"), occ, P("ox"), P("oy"), sp, P("wells"), occ))
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

	-- what the owner site places on this tile
	expression(P("active"), fmt("%s * %s", P("on"), P("valid")))
	expression(P("ore"), fmt("%s * (1 - %s) * %s", P("active"), P("liq"), P("inside")))
	expression(P("well"), fmt("%s * %s * %s", P("active"), P("liq"), P("here")))

	-- queries of the control stage: the site of the cell holding the tile
	local own = "(floor(x / " .. num(G) .. "), floor(y / " .. num(G) .. "))"
	expression(P("cell_on"), P("fon") .. own)
	expression(P("cell_x"), P("fx") .. own)
	expression(P("cell_y"), P("fy") .. own)
	expression(P("veinon"), vein_chance > 0 and fmt("%s < %s", P("r15"), num(vein_chance)) or "0")

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
			local rich = fmt("%s * %s", num(s.richness * start_mult), slider(control, "richness"))
			local on = enabled(control)
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
				local r = fmt("(%s * %s)", num(s.size * C.starting_radius), size_mod(control))
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

	return names, {prefix = p, cell = G, region = REGION, resources = list}
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
			local names, info = build_planet(planet_name, config[planet_name], ignored_resources)
			if names then
				planets[planet_name] = info
				if planet_name == "nauvis" then
					for resource, pair in pairs(names) do
						local autoplace = data.raw.resource[resource].autoplace
						autoplace.probability_expression = pair[1]
						autoplace.richness_expression = pair[2]
						autoplace.local_expressions, autoplace.local_functions = nil, nil
					end
					free = info.prefix .. "free"
				else
					planet.map_gen_settings = planet.map_gen_settings or {}
					local overrides = planet.map_gen_settings.property_expression_names or {}
					planet.map_gen_settings.property_expression_names = overrides
					for resource, pair in pairs(names) do
						overrides["entity:" .. resource .. ":probability"] = pair[1]
						overrides["entity:" .. resource .. ":richness"] = pair[2]
					end
					overrides.rso_free = info.prefix .. "free"
				end
				for resource in pairs(names) do managed[resource] = true end
			end
		end
	end
	-- other planets do not get the nauvis fields of the managed resources
	for planet_name, planet in pairs(data.raw.planet) do
		if planet_name ~= "nauvis" and not planets[planet_name] and not ignored_planets[planet_name] then
			planet.map_gen_settings = planet.map_gen_settings or {}
			local overrides = planet.map_gen_settings.property_expression_names or {}
			planet.map_gen_settings.property_expression_names = overrides
			for resource in pairs(managed) do
				overrides["entity:" .. resource .. ":probability"] = "0"
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
	data:extend(defs)
	data:extend({{type = "mod-data", name = "rso-reforged", data = {planets = planets}}})
end
