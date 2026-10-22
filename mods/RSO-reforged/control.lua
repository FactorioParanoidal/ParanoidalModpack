--[[ RSO Reforged (Resource Spawner Overhaul, Paranoidal fork) — control stage.

The map is split into regions of rso-region-size chunks. When the first chunk of a region is
generated, the region is "rolled": a region RNG seeded from the region position and the map seed
picks which resources (and enemy bases) go to which chunks of the region. When such a chunk is
generated, its entries are spawned with a chunk RNG seeded from the chunk centre.

Determinism matters: every rng() call is part of the map. Keep the order and number of RNG calls
when changing the generation code, otherwise existing maps change in regions not yet generated.

Reforged additions: geological provinces, distance-dependent composition, a guaranteed first ring,
rich veins, nests guarding rich fields, old mine ruins near them, new veins under depleted fields
and geological survey forecasts (Ore Radar). They draw from their own RNGs where the main sequence
must not shift, and only regions rolled after the change are affected.
]]--

local util = require("util")
local C = require("config")
local MB = require("libs.metaball")
local loadResourceConfig = require("resourceconfigs.mainconfig")

local floor = math.floor
local ceil = math.ceil
local abs = math.abs
local cos = math.cos
local sin = math.sin
local pi = math.pi
local max = math.max
local min = math.min
local distance = util.distance

local DEBUG = C.debug_enabled

local CHUNK_SIZE = 32
local MIN_BALL_DISTANCE = CHUNK_SIZE / 6
local NEGATIVE_MODIFICATOR = 9973
local MAX_AMOUNT = 1e9

-- region size is a runtime setting; it is re-read on change (same value on every peer)
local region_size = settings.global["rso-region-size"].value
local REGION_TILE_SIZE = CHUNK_SIZE * region_size

local SHAPES = {MB.MetaEllipse, MB.MetaSquare}
local SHAPES_WITH_DONUTS = {MB.MetaEllipse, MB.MetaSquare, MB.MetaDonut}

local function debug(str)
	log(str)
end

local function round(value)
	return floor(value + 0.5)
end

local function setting(name)
	return settings.global[name].value
end

--[[ HELPERS ]]--

local function normalize(n) -- keep numbers at 32 bits
	return floor(n) % 0xffffffff
end

local function bearing(origin, dest)
	return math.atan2(dest.x - origin.x, dest.y - origin.y)
end

local function rng_for_reg_pos(surfaceIndex, pos)
	local x = pos.x
	local y = pos.y
	local rng = game.create_random_generator()

	if x == 0 then x = 0.5 end
	if y == 0 then y = 0.5 end
	if x < 0 then x = abs(x) + NEGATIVE_MODIFICATOR end
	if y < 0 then y = abs(y) + NEGATIVE_MODIFICATOR end

	rng.re_seed(normalize(x * 65536))
	local valX = rng(65536)
	rng.re_seed(normalize(y * 32768))
	local valY = rng(32768)

	local mapSeed = storage.mapSeedOverride or storage.surfaces[surfaceIndex].seed
	rng.re_seed(normalize(valX * valY * mapSeed))
	return rng
end

local function rng_restricted_angle(restrictions, rng)
	local value = rng()
	local deformX = rng() * 2 - 1
	local deformY = rng() * 2 - 1

	if restrictions == 'xy' then
		return value*pi*2, 1.0 + deformX*0.5, 1.0 + deformY*0.5
	elseif restrictions == 'x' then
		return value*pi/2 - pi/4, 1.0 + deformX*0.6, 1.0 + deformY*0.6
	elseif restrictions == 'y' then
		return value*pi/2 + pi/2, 1.0 + deformX*0.6, 1.0 + deformY*0.6
	end
	return value*pi*2, 1.0 + deformX*0.3, 1.0 + deformY*0.3
end

local function vary_by_percentage(x, p, rng)
	return x + (0.5 - rng())*2*x*p
end

local TREE_TYPES = {"tree", "simple-entity"}

local function remove_trees(surface, x, y, x_size, y_size)
	for _, entity in pairs(surface.find_entities_filtered{area = {{x - x_size, y - y_size}, {x + x_size, y + y_size}}, type = TREE_TYPES}) do
		if entity.valid then
			entity.destroy()
		end
	end
end

local function remove_trees_based_on_bb(surface, x, y, boundingBox)
	local bb = {{x + boundingBox.left_top.x, y + boundingBox.left_top.y}, {x + boundingBox.right_bottom.x, y + boundingBox.right_bottom.y}}
	for _, entity in pairs(surface.find_entities_filtered{area = bb, type = TREE_TYPES}) do
		if entity.valid then
			entity.destroy()
		end
	end
end

-- Flat key of an integer tile position (|x|, |y| < 2^21).
local function tile_key(x, y)
	return (x + 2097152) * 4194304 + (y + 2097152)
end

-- Trees and rocks touching the ore tiles: one search instead of one per tile. Same rule as a
-- per-tile search of the area {{x-1, y-1}, {x+1, y+1}} around every placed tile (x, y).
local function remove_trees_on_tiles(surface, placed, minX, minY, maxX, maxY)
	local area = {{minX - 1, minY - 1}, {maxX + 1, maxY + 1}}
	for _, entity in pairs(surface.find_entities_filtered{area = area, type = TREE_TYPES}) do
		if entity.valid then
			local box = entity.bounding_box
			local lt, rb = box.left_top, box.right_bottom
			local hit = false
			-- boxes that only touch the area count, as in the engine search
			for tx = ceil(lt.x - 1), floor(rb.x + 1) do
				if tx - 1 <= rb.x and tx + 1 >= lt.x then
					for ty = ceil(lt.y - 1), floor(rb.y + 1) do
						if ty - 1 <= rb.y and ty + 1 >= lt.y and placed[tile_key(tx, ty)] then
							hit = true
							break
						end
					end
				end
				if hit then break end
			end
			if hit then entity.destroy() end
		end
	end
end

-- decoratives (grass, small stones) on the ore tiles; one search per field
local function remove_decoratives_on_tiles(surface, placed, minX, minY, maxX, maxY)
	local destroy = surface.destroy_decoratives
	for _, found in pairs(surface.find_decoratives_filtered{area = {{minX, minY}, {maxX + 1, maxY + 1}}}) do
		local p = found.position
		if placed[tile_key(p.x, p.y)] then
			destroy{position = p}
		end
	end
end

local function find_intersection(surface, x, y)
	-- try to get position in between of valid chunks by probing map
	local gt = surface.get_tile
	local d = CHUNK_SIZE*2
	local h = CHUNK_SIZE/2
	if gt(x + d, y + d).valid and gt(x - d, y - d).valid and gt(x + d, y - d).valid and gt(x - d, y + d).valid then
		return x, y, 'xy'
	elseif gt(x + d, y + d).valid and gt(x + d, y).valid and gt(x, y + d).valid then
		return x + h, y + h, 'xy'
	elseif gt(x + d, y - d).valid and gt(x + d, y).valid and gt(x, y - d).valid then
		return x + h, y - h, 'xy'
	elseif gt(x - d, y + d).valid and gt(x - d, y).valid and gt(x, y + d).valid then
		return x - h, y + h, 'xy'
	elseif gt(x - d, y - d).valid and gt(x - d, y).valid and gt(x, y - d).valid then
		return x - h, y - h, 'xy'
	elseif gt(x + d, y).valid then
		return x + h, y, 'x'
	elseif gt(x - d, y).valid then
		return x - h, y, 'x'
	elseif gt(x, y + d).valid then
		return x, y + h, 'y'
	elseif gt(x, y - d).valid then
		return x, y - h, 'y'
	end
	return x, y, ''
end

local function find_random_chunk(r_x, r_y, rng)
	local offset_x = rng(region_size) - 1
	local offset_y = rng(region_size) - 1
	return r_x*REGION_TILE_SIZE + offset_x*CHUNK_SIZE, r_y*REGION_TILE_SIZE + offset_y*CHUNK_SIZE
end

local function is_same_region(c_x1, c_y1, c_x2, c_y2)
	return floor(c_x1/REGION_TILE_SIZE) == floor(c_x2/REGION_TILE_SIZE)
		and floor(c_y1/REGION_TILE_SIZE) == floor(c_y2/REGION_TILE_SIZE)
end

local function find_random_neighbour_chunk(ocx, ocy, rng)
	local dx = rng(-2, 2) * CHUNK_SIZE
	local dy = rng(-2, 2) * CHUNK_SIZE
	if is_same_region(ocx + dx, ocy + dy, ocx, ocy) then return ocx + dx, ocy + dy end
	if is_same_region(ocx - dx, ocy - dy, ocx, ocy) then return ocx - dx, ocy - dy end
	if is_same_region(ocx - dx, ocy + dy, ocx, ocy) then return ocx - dx, ocy + dy end
	if is_same_region(ocx + dx, ocy - dy, ocx, ocy) then return ocx + dx, ocy - dy end
	return ocx, ocy
end

local function isInStartingArea(surfaceIndex, tileX, tileY)
	local surfaceData = storage.surfaces[surfaceIndex]
	if surfaceData and surfaceData.startingAreas then
		local size = surfaceData.starting_area_size
		for _, data in pairs(surfaceData.startingAreas) do
			local adjustedX = (tileX - data.x) / REGION_TILE_SIZE
			local adjustedY = (tileY - data.y) / REGION_TILE_SIZE
			if (adjustedX * adjustedX + adjustedY * adjustedY) <= size * size then
				return true
			end
		end
	end
	return false
end

local function distanceFromStartingAreas(surfaceData, regionX, regionY)
	local minDistance = nil
	local region = {x = regionX, y = regionY}
	for _, data in pairs(surfaceData.startingAreas) do
		local dist = distance({x = data.x / REGION_TILE_SIZE, y = data.y / REGION_TILE_SIZE}, region)
		minDistance = minDistance and min(minDistance, dist) or dist
	end
	return minDistance or distance({x = 0, y = 0}, region)
end

-- global size multiplier outside the starting area; infinite resources are made smaller
local function modify_resource_size(resourceName, resourceSize, startingArea)
	if not startingArea then
		resourceSize = ceil(resourceSize * setting("rso-global-size-mult"))
	end
	local resourceEntity = prototypes.entity[resourceName]
	if resourceEntity and resourceEntity.infinite_resource then
		local newResourceSize = ceil(resourceSize * C.endless_resource_mode_sizeModifier)
		if newResourceSize == 0 then newResourceSize = 1 end
		return newResourceSize
	end
	return resourceSize
end

--[[ SPAWN METHODS ]]--

-- offsets (in chunks) tried when an ore field collides with other resources
local locationOrder =
{
	{x = 0, y = 0},
	{x = -1, y = 0},
	{x = 1, y = 0},
	{x = 0, y = -1},
	{x = 0, y = 1},
	{x = -1, y = -1},
	{x = 1, y = -1},
	{x = -1, y = 1},
	{x = 1, y = 1},
}

local function newRect()
	return {xmin = 1e10, xmax = -1e10, ymin = 1e10, ymax = -1e10}
end

local function updateRect(rect, x, y, radius)
	rect.xmin = min(rect.xmin, x - radius)
	rect.xmax = max(rect.xmax, x + radius)
	rect.ymin = min(rect.ymin, y - radius)
	rect.ymax = max(rect.ymax, y + radius)
end

-- Options of the spawn functions (all optional):
--   quiet     {x1, y1, x2, y2}: tiles inside are created without script_raised_built. Used for the
--             chunk being generated: like vanilla ore, its tiles are found by the chunk scans of
--             other mods; only the tiles that spill into neighbouring chunks are announced
--   veins     roll a rich vein through the field
--   distance  regions from the start: scales the infinite core of the field
--   no_shift  do not move the field by a chunk to avoid other resources
--   min_ratio placeable share needed to spawn (default resourceCollisionDetectionRatioFallback)
local NO_OPTIONS = {}

local function is_quiet(quiet, x, y)
	return quiet ~= nil and x >= quiet[1] and y >= quiet[2] and x < quiet[3] and y < quiet[4]
end

--[[ entity-field ]]--
-- returns the total amount and, if anything was placed, info {infinite = tiles, veined = tiles,
-- box = {minX, minY, maxX, maxY}}
local function spawn_resource_ore(surface, rname, pos, size, richness, startingArea, restrictions, rng, opts)
	-- blob generator, centered at pos, size controls blob diameter
	restrictions = restrictions or ''
	opts = opts or NO_OPTIONS
	if DEBUG then debug("spawn_resource_ore "..rname.." at "..pos.x..","..pos.y.." size "..size.." richness "..richness.." start "..tostring(startingArea).." restrictions "..restrictions) end

	size = modify_resource_size(rname, size, startingArea)
	local radius = size / 2
	local minBallDistance = min(MIN_BALL_DISTANCE, radius/2)
	local shapes = setting("rso-use-donuts") and SHAPES_WITH_DONUTS or SHAPES

	local p_balls = {}
	local n_balls = {}
	local outside = newRect() -- every tile that can get ore
	local inside = newRect()  -- extent of the positive balls

	local function add_ball(list, x, y, b_radius, angle, x_scale, y_scale, goo)
		local shape = shapes[rng(1, #shapes)]
		if shape == MB.MetaDonut then
			local inRadius = b_radius / 4 + b_radius / 2 * rng()
			list[#list + 1] = shape:new(x, y, b_radius, inRadius, angle, x_scale, y_scale, goo)
		else
			list[#list + 1] = shape:new(x, y, b_radius, angle, x_scale, y_scale, goo)
		end
	end

	local function generate_p_ball()
		local angle, x_scale, y_scale = rng_restricted_angle(restrictions, rng)
		local dev = radius / 2 + rng() * radius / 4
		local x = rng(-dev, dev) + pos.x
		local y = rng(-dev, dev) + pos.y
		local count = #p_balls
		local last = p_balls[count]
		if last and distance(last, {x = x, y = y}) < minBallDistance then
			local new_angle = bearing(last, {x = x, y = y})
			x = (cos(new_angle)*minBallDistance) + x
			y = (sin(new_angle)*minBallDistance) + y
		end

		local b_radius
		if count == 0 then
			b_radius = 3 * radius / 4 + rng() * radius / 4
		else
			b_radius = radius / 4 + rng() * radius / 2
			-- keep the field within 1.25 of its size
			local tempRect = {xmin = inside.xmin, xmax = inside.xmax, ymin = inside.ymin, ymax = inside.ymax}
			updateRect(tempRect, x, y, b_radius)
			local targetSize = size * 1.25
			if max(tempRect.xmax - tempRect.xmin, tempRect.ymax - tempRect.ymin) > targetSize then
				local widthLeft = targetSize - (inside.xmax - inside.xmin)
				local heightLeft = targetSize - (inside.ymax - inside.ymin)
				local widthMod = min(x - inside.xmin, inside.xmax - x)
				local heightMod = min(y - inside.ymin, inside.ymax - y)
				b_radius = min(widthLeft + widthMod, heightLeft + heightMod)
			end
		end

		if b_radius < 2 and count == 0 then
			b_radius = 2
		end

		if b_radius > 0 then
			add_ball(p_balls, x, y, b_radius, angle, x_scale, y_scale, 1.1)
			updateRect(outside, x, y, b_radius * 2.5) -- big enough to not cut any metaball
			updateRect(inside, x, y, b_radius)
		end
	end

	local function generate_n_ball(i)
		local angle, x_scale, y_scale = rng_restricted_angle('xy', rng)
		local x, y, b_radius
		local p = p_balls[i]
		if p then
			local new_angle = p.angle + pi*rng(0, 2) + (rng() - 0.5)*pi/2
			local dist = p.radius
			x = (cos(new_angle)*dist) + p.x
			y = (sin(new_angle)*dist) + p.y
			angle = p.angle + pi/2 + (rng() - 0.5)*pi*2/3
			b_radius = p.radius / 4 + rng() * p.radius / 2
		else
			x = rng(-radius, radius) + pos.x
			y = rng(-radius, radius) + pos.y
			b_radius = radius / 4 + rng() * radius / 2
		end
		if b_radius < 1 then
			b_radius = 1
		end
		add_ball(n_balls, x, y, b_radius, angle, x_scale, y_scale, 1.15)
	end

	local surfaceConfig = storage.surfaces[surface.index].config
	local min_amount = surfaceConfig[rname].min_amount or C.min_amount
	local max_p_balls = restrictions == 'xy' and 3 or 2 -- 'xy': the field has 4 full chunks

	radius = min(radius, 2*CHUNK_SIZE)

	for _ = 1, max_p_balls do
		generate_p_ball()
	end
	for i = 1, rng(1, #p_balls) do
		generate_n_ball(i)
	end

	-- metaball field: positive balls minus negative balls, ore where p - n > 1
	local np, nn = #p_balls, #n_balls
	local locX, locY, locForce = {}, {}, {}
	local count = 0
	local forceTotal = 0
	local xmin, xmax = round(outside.xmin), round(outside.xmax)
	for y = round(outside.ymin), round(outside.ymax) do
		for x = xmin, xmax do
			local p_force = 0
			for b = 1, np do
				p_force = p_force + p_balls[b]:force(x, y)
			end
			-- n >= 0, so p <= 1 cannot give a positive force: skip the negative balls
			if p_force > 1 then
				local n_force = 0
				for b = 1, nn do
					n_force = n_force + n_balls[b]:force(x, y)
				end
				if p_force > n_force then
					local force = 1 - 1/(p_force - n_force)
					if force > 0 then
						count = count + 1
						locX[count], locY[count], locForce[count] = x, y, force
						forceTotal = forceTotal + force
					end
				end
			end
		end
	end

	-- choose the offset with the largest placeable share
	local can_place = surface.can_place_entity
	local placeCheck = {name = rname, position = {0, 0}, build_check_type = defines.build_check_type.manual, forced = false}
	local placeable = {}
	local bestRatio = 0
	local bestRatioIndex = -1
	for index, locationOffset in ipairs(locationOrder) do
		local validCount = 0
		local offX = locationOffset.x * CHUNK_SIZE
		local offY = locationOffset.y * CHUNK_SIZE
		for i = 1, count do
			local key = tile_key(locX[i] + offX, locY[i] + offY)
			local ok = placeable[key]
			if ok == nil then
				placeCheck.position = {x = locX[i] + offX, y = locY[i] + offY}
				ok = can_place(placeCheck)
				placeable[key] = ok
			end
			if ok then
				validCount = validCount + 1
			end
		end

		local ratio = 0
		if validCount > 0 then
			ratio = validCount / count
		end
		if not C.useResourceCollisionDetection then
			break
		end
		if ratio > bestRatio then
			bestRatio = ratio
			bestRatioIndex = index
		end
		if ratio > C.resourceCollisionDetectionRatio or opts.no_shift then
			break
		end
	end

	local _total = 0
	local info = nil
	local validCount, resOffsetX, resOffsetY
	if C.resourceCollisionFieldSkip and bestRatio < (opts.min_ratio or C.resourceCollisionDetectionRatioFallback) then
		validCount = 0
		if DEBUG then debug("Cancelled with best ratio "..bestRatio) end
	else
		resOffsetX = locationOrder[bestRatioIndex].x * CHUNK_SIZE
		resOffsetY = locationOrder[bestRatioIndex].y * CHUNK_SIZE
		validCount = floor(bestRatio * count)
	end

	if validCount > 0 then
		local removeTrees = setting("rso-remove-trees")
		local inSize = ((inside.xmax - inside.xmin) + (inside.ymax - inside.ymin)) / 2
		local sizeMultiplier = inSize ^ 0.6
		local minSize = richness * 5 * sizeMultiplier
		local maxSize = richness * 10 * sizeMultiplier
		local approxDepositSize = rng(minSize, maxSize) - validCount * min_amount
		if approxDepositSize < 0 then
			approxDepositSize = 100 * validCount
		end

		local forceFactor = approxDepositSize / forceTotal
		-- don't create very dense resources in starting area - another field will be generated
		if startingArea and forceFactor > 4000 then
			forceFactor = rng(3000, 4000)
		end

		local richnessMultiplier = startingArea and setting("rso-starting-richness-mult") or setting("rso-global-richness-mult")

		-- infinite variants (Angel's infinite ores) in the densest part of the field
		local infiniteOreName = "infinite-" .. rname
		local infinitePrototype = prototypes.entity[infiniteOreName]
		if startingArea and not setting("rso-infinite-ores-in-start-area") then
			infinitePrototype = nil
		end
		local minimumInfiniteOreAmount = infinitePrototype and infinitePrototype.minimum_resource_amount
		local infiniteThreshold = setting("rso-infinite-ore-threshold")
		if opts.distance then
			-- the infinite core grows with the distance
			infiniteThreshold = 1 - (1 - infiniteThreshold) * min(C.infinite_distance_max, 1 + opts.distance / C.infinite_distance_scale)
		end

		-- a rich vein: a narrow strip across the field
		local vein = nil
		if opts.veins then
			local chance = setting("rso-vein-chance")
			if chance > 0 and rng() < chance then
				local angle = rng() * pi
				local spread = inSize * 0.15
				vein = {
					x = (inside.xmin + inside.xmax) / 2 + resOffsetX + (rng() - 0.5) * spread,
					y = (inside.ymin + inside.ymax) / 2 + resOffsetY + (rng() - 0.5) * spread,
					s = sin(angle), c = cos(angle),
					half = C.vein_half_width[1] + rng() * (C.vein_half_width[2] - C.vein_half_width[1]),
					mult = C.vein_multiplier[1] + rng() * (C.vein_multiplier[2] - C.vein_multiplier[1]),
				}
			end
		end
		local quiet = opts.quiet
		local infiniteCount, veinCount = 0, 0

		local neutral = game.forces.neutral
		local create = surface.create_entity
		local spec = {name = rname, position = {0, 0}, force = neutral, amount = 0, raise_built = true}
		local placed = {}
		local minX, minY, maxX, maxY = 1e9, 1e9, -1e9, -1e9

		for i = 1, count do
			local spawnX = locX[i] + resOffsetX
			local spawnY = locY[i] + resOffsetY
			local key = tile_key(spawnX, spawnY)
			if placeable[key] then
				local force = locForce[i]
				local amount = floor((forceFactor * force + min_amount) * richnessMultiplier)
				if vein and abs((spawnX - vein.x) * vein.s - (spawnY - vein.y) * vein.c) <= vein.half then
					amount = floor(amount * vein.mult)
					veinCount = veinCount + 1
				end
				if amount > MAX_AMOUNT then
					amount = MAX_AMOUNT
				end
				_total = _total + amount

				local spawnName = rname
				if infinitePrototype and force > infiniteThreshold then
					spawnName = infiniteOreName
					infiniteCount = infiniteCount + 1
					if minimumInfiniteOreAmount and amount < minimumInfiniteOreAmount then
						amount = minimumInfiniteOreAmount
					end
				end

				if amount > 0 then
					spec.name = spawnName
					spec.position = {spawnX, spawnY}
					spec.amount = amount
					spec.raise_built = not is_quiet(quiet, spawnX, spawnY)
					create(spec)
					placed[key] = true
					if spawnX < minX then minX = spawnX end
					if spawnY < minY then minY = spawnY end
					if spawnX > maxX then maxX = spawnX end
					if spawnY > maxY then maxY = spawnY end
				end
			end
		end

		if minX <= maxX then
			info = {infinite = infiniteCount, veined = veinCount, box = {minX, minY, maxX, maxY}}
			if removeTrees then
				remove_trees_on_tiles(surface, placed, minX, minY, maxX, maxY)
			end
			remove_decoratives_on_tiles(surface, placed, minX, minY, maxX, maxY)
			if setting("rso-reveal-spawned-resources") then
				for _, force in pairs(game.forces) do
					force.chart(surface, {{x = minX, y = minY}, {x = maxX, y = maxY}})
				end
			end
		end
	end

	if DEBUG then debug("spawn_resource_ore total amount: ".._total) end
	return _total, info
end

--[[ entity-liquid ]]--
local function spawn_resource_liquid(surface, rname, pos, size, richness, startingArea, restrictions, rng, opts)
	if DEBUG then debug("spawn_resource_liquid "..rname.." "..pos.x..","..pos.y.." "..size.." "..richness.." "..tostring(startingArea)) end
	local _total = 0
	local max_radius = rng() * CHUNK_SIZE / 2 + CHUNK_SIZE
	-- liquids are not reduced by the size multiplier: they are already infinite
	richness = (0.75 + rng() / 2) * richness * size

	local total_share = 0
	local avg_share = 1/size
	local angle = rng()*pi*2
	local saved = 0
	local removeTrees = setting("rso-remove-trees")
	local richnessMultiplier = startingArea and setting("rso-starting-richness-mult") or setting("rso-global-richness-mult")
	local minimum_amount = storage.surfaces[surface.index].config[rname].minimum_amount
	local spawnCount = 0

	while total_share < 1 do
		local new_share = vary_by_percentage(avg_share, 0.25, rng)
		if size == 1 then
			new_share = 1
		end
		if new_share + total_share > 1 then
			new_share = 1 - total_share
		end
		total_share = new_share + total_share
		if new_share < avg_share/10 then
			break -- too small
		end
		local amount = floor(richness*new_share) + saved

		if amount >= minimum_amount then
			saved = 0
			local spawned = false
			local x, y

			for try = 1, 15 do
				local dist = rng()*(max_radius - max_radius*0.1) * try / 15
				angle = angle + pi/4 + rng()*pi/2
				x = floor(pos.x + cos(angle)*dist) + 0.5
				y = floor(pos.y + sin(angle)*dist) + 0.5
				if surface.can_place_entity{name = rname, position = {x, y}} then
					amount = min(floor(amount * richnessMultiplier), MAX_AMOUNT)
					_total = _total + amount
					if amount > 0 then
						-- direction only picks a sprite variation; rng(4) is part of the map
						surface.create_entity{name = rname, position = {x, y}, force = game.forces.neutral,
							amount = amount, direction = rng(4), raise_built = not (opts and is_quiet(opts.quiet, x, y))}
						if removeTrees then
							remove_trees(surface, x, y, 4, 4)
						end
						surface.destroy_decoratives{area = {{x - 1.5, y - 1.5}, {x + 1.5, y + 1.5}}}
					end
					if spawnCount == 0 then
						pos.x = x
						pos.y = y
					end
					spawnCount = spawnCount + 1
					spawned = true
					break
				end
			end

			-- outside the starting area a share that found no place is added to the wells nearby
			-- (in the starting area a failure makes another field instead of ultra rich wells)
			if not startingArea and not spawned then
				local entities = surface.find_entities_filtered{area = {{x - 5, y - 5}, {x + 5, y + 5}}, name = rname}
				if #entities > 0 then
					local share = floor(amount/#entities)
					for _, ent in pairs(entities) do
						local newAmount = min(ent.amount + share, MAX_AMOUNT)
						_total = _total + newAmount - ent.amount
						ent.amount = newAmount
					end
					break
				end
			end
		else
			saved = amount
		end
	end
	if DEBUG then debug("spawn_resource_liquid total amount: ".._total.." in "..spawnCount.." wells") end
	return _total
end

--[[ enemies ]]--
local spawnerTable = nil

local function initSpawnerTable()
	if spawnerTable == nil then
		spawnerTable = {}
		for name, prototype in pairs(prototypes.get_entity_filtered{{filter = "type", type = "unit-spawner"}}) do
			spawnerTable[name] = prototype
		end
	end
end

-- weights of the entries available at this distance; stores allotment_range in every entry
local function computeAllotments(entityTable, regionDistance)
	local allotment_max = 0
	if not entityTable then
		return allotment_max
	end
	for _, v in pairs(entityTable) do
		if v then
			if not v.min_distance or regionDistance > v.min_distance then
				local allotment = v.allotment
				if v.allotment_distance_factor then
					local dist_factor = regionDistance^v.allotment_distance_factor
					if v.max_probability_distance_factor then
						dist_factor = max(dist_factor, v.max_probability_distance_factor)
					end
					allotment = allotment * dist_factor
				end
				v.allotment_range = {min = allotment_max, max = allotment_max + allotment}
				allotment_max = allotment_max + allotment
			else
				v.allotment_range = nil
			end
		end
	end
	return allotment_max
end

local function spawn_entity_helper(surface, prototype, x, y, config)
	local position = {x, y}
	if surface.entity_prototype_collides(prototype, position, true) then
		remove_trees_based_on_bb(surface, x, y, prototype.map_generator_bounding_box)
		if surface.entity_prototype_collides(prototype, position, true) then
			return false
		end
	end
	surface.create_entity{name = prototype.name, position = position, force = game.forces[config.force], spawn_decorations = true, raise_built = true}
	return true
end

local function spawn_entity(surface, ent, r_config, x, y, rng, sizeMult)
	local size = rng(r_config.size.min, r_config.size.max)

	local surfaceData = storage.surfaces[surface.index]
	local r_distance = distanceFromStartingAreas(surfaceData, x/REGION_TILE_SIZE, y/REGION_TILE_SIZE)
	if surfaceData.starting_area_size then
		r_distance = max(r_distance - surfaceData.starting_area_size, 0.5)
	end

	local distanceMultiplier = 1
	if r_config.size_per_region_factor then
		distanceMultiplier = min(r_distance^r_config.size_per_region_factor, 5)
		size = size*distanceMultiplier
	end
	size = size * setting("rso-enemy-base-size") * (sizeMult or 1)

	if DEBUG then debug("spawn_entity "..ent.." "..x..","..y.." size:"..size.." dist:"..r_distance) end

	local maxAttemptCount = 16
	local distancePerBatch = 0.25
	initSpawnerTable()
	local base_allotment_max = computeAllotments(r_config.bases, r_distance)
	local failCount = 0
	local total = 0

	for i = 1, size do
		if failCount > 5 and failCount / (i - 1) > 0.75 then
			break
		end

		local baseSpawned = false
		local baseX, baseY
		for attempt = 1, maxAttemptCount do
			local max_d = floor(CHUNK_SIZE * (0.5 + (attempt/4) * distancePerBatch))
			baseX = x + rng(0, floor(max_d)) - max_d/2
			baseY = y + rng(0, floor(max_d)) - max_d/2

			if surface.get_tile(baseX, baseY).valid then
				if base_allotment_max == 0 then
					log("RSO: no enemy base definition available for "..ent)
					return total
				end
				local spawnerName = nil
				local base_type = rng(0, base_allotment_max)
				for base_name, v in pairs(r_config.bases) do
					if v and v.allotment_range and base_type >= v.allotment_range.min and base_type <= v.allotment_range.max then
						spawnerName = base_name
						break
					end
				end

				if spawnerName and spawnerTable[spawnerName] then
					if spawn_entity_helper(surface, spawnerTable[spawnerName], baseX, baseY, r_config) then
						total = total + 1
						baseSpawned = true
						break
					elseif attempt == maxAttemptCount then
						failCount = failCount + 1
					end
				else
					log("RSO: enemy base entity "..tostring(spawnerName).." doesn't exist")
				end
			end
		end

		if r_config.sub_spawn_probability and baseSpawned then
			local sub_spawn_prob = r_config.sub_spawn_probability*min(r_config.sub_spawn_max_distance_factor, r_config.sub_spawn_distance_factor^r_distance)
			if rng() < sub_spawn_prob then
				local allotment_max = computeAllotments(r_config.sub_spawns, r_distance)
				for _ = 1, (rng(r_config.sub_spawn_size.min, r_config.sub_spawn_size.max)*distanceMultiplier) do
					local sub_type = rng(0, allotment_max)
					for sub_spawn, v in pairs(r_config.sub_spawns) do
						if v.allotment_range and sub_type >= v.allotment_range.min and sub_type <= v.allotment_range.max then
							local turretPrototype = prototypes.entity[sub_spawn]
							if turretPrototype then
								for attempt = 1, maxAttemptCount do
									local max_d = floor((attempt/4) * CHUNK_SIZE * distancePerBatch)
									local s_x = baseX + rng(max_d) - max_d/2
									local s_y = baseY + rng(max_d) - max_d/2
									remove_trees(surface, s_x, s_y, v.clear_range[1], v.clear_range[2])
									if spawn_entity_helper(surface, turretPrototype, s_x, s_y, r_config) then
										break
									end
								end
							end
							break
						end
					end
				end
			end
		end
	end

	if DEBUG then debug("spawn_entity placed "..total.." fails "..failCount.." size "..size) end
	return total
end

--[[ STARTING AREA ]]--

local function hasStartingResources(config)
	for _, resConfig in pairs(config) do
		if type(resConfig) == "table" and resConfig.starting and resConfig.valid and resConfig.allotment > 0
			and resConfig.starting.probability > 0 then
			return true
		end
	end
	return false
end

local function spawn_starting_resources(surface, index)
	local surfaceData = storage.surfaces[surface.index]
	if not (surfaceData and surfaceData.startingAreas and surfaceData.startingAreas[index]) then return end
	local area = surfaceData.startingAreas[index]
	if area.spawned then return end

	local config = surfaceData.config or {}
	-- skip if starting area is too small, starting areas are disabled or there is nothing to spawn
	-- (surfaces of other mods: no chunks are forced to generate for nothing)
	if storage.disableStartingArea or surfaceData.starting_area_size < 0.1 or not hasStartingResources(config) then
		area.spawned = true
		return
	end

	-- generate chunks for starting area - it shouldn't matter at 0,0 but it's needed if it has been moved
	local areaRadius = surfaceData.starting_area_size * REGION_TILE_SIZE
	surface.request_to_generate_chunks(area, ceil(areaRadius/CHUNK_SIZE))
	surface.force_generate_chunk_requests()

	local rng = rng_for_reg_pos(surface.index, area)
	for resName, resConfig in pairs(config) do
		if type(resConfig) == "table" and resConfig.starting and resConfig.valid and resConfig.allotment > 0 then
			local starting = resConfig.starting
			local prob = rng() -- probability that this resource is spawned
			if starting.probability > 0 and prob <= starting.probability then
				local total = 0
				local radius = starting.distance or 50
				local maxRadius = max(350, radius + 100)
				if not starting.distance then
					maxRadius = maxRadius * surface.map_gen_settings.starting_area
				end
				local radiusStep = starting.distance and 5 or 25
				local richness = starting.richness
				local min_threshold = 0
				if resConfig.type == "resource-ore" then
					min_threshold = richness * rng(5, 10) -- at least 5-10 times starting richness
				elseif resConfig.type == "resource-liquid" then
					min_threshold = richness * 0.5 * starting.size
				end

				while radius < maxRadius and total < min_threshold do
					radius = radius + radiusStep
					local angle = rng() * pi * 2
					local dist = radius / 2 + rng(radius / 2)
					local pos = {x = floor(cos(angle) * dist) + area.x, y = floor(sin(angle) * dist) + area.y}
					if resConfig.type == "resource-ore" then
						total = total + spawn_resource_ore(surface, resName, pos, starting.size, richness, true, nil, rng)
					elseif resConfig.type == "resource-liquid" then
						total = total + spawn_resource_liquid(surface, resName, pos, starting.size, richness, true, nil, rng)
					end
					if richness == starting.richness and total > 0 then
						richness = starting.richness / 4
					end
				end
				if total < min_threshold then
					log("RSO: starting area "..index.." on "..surface.name.." got "..total.." of "..min_threshold.." "..resName)
				end
			end
		end
	end

	area.spawned = true
end

--[[ CONFIG ]]--

local function modifyMinMax(value, mod)
	value.min = round(value.min * mod)
	value.max = round(value.max * mod)
end

local function adjustSizeMod(sizeMod)
	if sizeMod > 1 then
		sizeMod = 1 + (sizeMod - 1) / 2
	end
	return sizeMod
end

-- applies the map generator sliders and builds the sorted list with the roll ranges
local function build_config_data(surface)
	local mapGenSettings = not C.ignoreMapGenSettings and surface.map_gen_settings or nil
	local autoPlaceSettings = mapGenSettings and mapGenSettings.autoplace_controls

	local configIndexed = {}
	local surfaceData = storage.surfaces[surface.index]
	local config = surfaceData.config or {}
	local multiResource = setting("rso-multi-resource-active")
	local oilInStart = setting("rso-oil-in-start-area")
	local oreInStart = setting("rso-ore-in-start-area")
	local validCount = 0
	surfaceData.enemyName = nil

	for res_name, resConf in pairs(config) do
		if type(resConf) == "table" and resConf.valid then
			validCount = validCount + 1
			local isEntity = resConf.type == "entity"
			local addResource = true
			local settingsForResource = autoPlaceSettings and autoPlaceSettings[resConf.autoplace_name or res_name]

			if settingsForResource then
				local allotmentMod = settingsForResource.frequency
				local sizeMod = settingsForResource.size
				local richnessMod = settingsForResource.richness

				if allotmentMod then
					if isEntity then
						resConf.absolute_probability = resConf.absolute_probability * allotmentMod
					else
						resConf.allotment = round(resConf.allotment * allotmentMod)
					end
				end

				if sizeMod ~= nil then
					if sizeMod == 0 then
						addResource = false
					end
					sizeMod = adjustSizeMod(sizeMod)
					modifyMinMax(resConf.size, sizeMod)
					if resConf.starting then
						if sizeMod == 0 then
							resConf.starting = nil
						else
							resConf.starting.size = round(resConf.starting.size * sizeMod)
						end
					end
					if isEntity then
						if resConf.sub_spawn_size then
							modifyMinMax(resConf.sub_spawn_size, sizeMod)
						end
						modifyMinMax(resConf.spawns_per_region, sizeMod)
					end
				end

				if richnessMod then
					if resConf.type == "resource-ore" then
						resConf.richness = round(resConf.richness * richnessMod)
					elseif resConf.type == "resource-liquid" then
						modifyMinMax(resConf.richness, richnessMod)
					end
					if resConf.starting then
						resConf.starting.richness = round(resConf.starting.richness * richnessMod)
					end
				end
			end

			if not oilInStart and res_name == "crude-oil" and surface.name == "nauvis" then
				resConf.starting = nil
			end
			if not oreInStart and resConf.type == "resource-ore" then
				resConf.starting = nil
			end

			if addResource then
				local res_conf = table.deepcopy(resConf)
				res_conf.name = res_name
				if res_conf.multi_resource and multiResource then
					local new_list = {}
					for sub_res_name, allotment in pairs(res_conf.multi_resource) do
						if config[sub_res_name] and config[sub_res_name].valid then
							new_list[#new_list + 1] = {name = sub_res_name, allotment = allotment}
						end
					end
					table.sort(new_list, function(a, b) return a.name < b.name end)
					res_conf.multi_resource = new_list
				else
					res_conf.multi_resource_chance = nil
				end
				configIndexed[#configIndexed + 1] = res_conf
				if isEntity and res_conf.bases and (not surfaceData.enemyName or res_name < surfaceData.enemyName) then
					surfaceData.enemyName = res_name
				end
			end
		end
	end

	table.sort(configIndexed, function(a, b) return a.name < b.name end)

	local pr = 0
	local maxAllotment = 0
	for _, v in pairs(configIndexed) do
		if v.along_resource_probability then
			v.along_resource_probability_range = {min = pr, max = pr + v.along_resource_probability}
			pr = pr + v.along_resource_probability
		end
		if v.allotment and v.allotment > 0 then
			v.allotment_range = {min = maxAllotment, max = maxAllotment + v.allotment}
			maxAllotment = maxAllotment + v.allotment
		end
	end

	surfaceData.maxAllotment = maxAllotment
	-- resource rolls per region (0 based) follow the number of configured entries; entries switched
	-- off by the map sliders still count, so that e.g. a map without enemies keeps the ore density
	surfaceData.rollCount = min(ceil(validCount / 10) - 1, 3)
	surfaceData.starting_area_size = C.starting_area_size
	if mapGenSettings and mapGenSettings.starting_area then
		surfaceData.starting_area_size = C.starting_area_size * mapGenSettings.starting_area
	end
	surfaceData.configIndexed = configIndexed
end

-- marks every configured resource as valid (prototype with autoplace present) or not
local function checkConfigForInvalidResources(surfaceIndex)
	local entities = prototypes.entity
	local config = storage.surfaces[surfaceIndex].config or {}
	for resourceName, resourceConfig in pairs(config) do
		if type(resourceConfig) == "table" then
			if resourceConfig.type == "entity" then
				resourceConfig.valid = true
			else
				local prototype = entities[resourceName]
				resourceConfig.valid = prototype ~= nil and prototype.autoplace_specification ~= nil
				if not prototype then
					log("RSO: resource not available: " .. resourceName)
				end
			end
		end
	end
end

-- Paranoidal: geology by soil colour (Alien-biomes-Reforged, ПР-062). The soil of the chunk that
-- opens a region is sampled on a 3x3 grid; Alien-biomes-Reforged answers which resources suit it
-- (weight multipliers). Without that mod or with its setting off nothing changes, not even the
-- RNG sequence, so maps are identical to plain RSO.
local GEOLOGY_SAMPLES = {4, 16, 28}

local function geology_bias(surface, c_x, c_y)
	local iface = remote.interfaces["alien-biomes-reforged"]
	if not (iface and iface.geology_bias) then return nil end
	local names = {}
	for _, dx in ipairs(GEOLOGY_SAMPLES) do
		for _, dy in ipairs(GEOLOGY_SAMPLES) do
			local tile = surface.get_tile(c_x + dx, c_y + dy)
			if tile and tile.valid then names[#names + 1] = tile.name end
		end
	end
	return remote.call("alien-biomes-reforged", "geology_bias", surface.name, names)
end

-- allotment ranges of configIndexed with the weights multiplied by bias; returns ranges, total
local function weighted_allotments(configIndexed, bias)
	local ranges, total = {}, 0
	for index, v in ipairs(configIndexed) do
		if v.allotment_range then
			local w = (v.allotment_range.max - v.allotment_range.min) * (bias[v.name] or 1)
			ranges[index] = {min = total, max = total + w}
			total = total + w
		end
	end
	return ranges, math.floor(total)
end

--[[ REGIONS ]]--

local function region_key(r_x, r_y)
	return r_x .. ":" .. r_y
end

-- dominant resource of the province of a region (nil: a mixed province); own RNG per province
local function province_dominant(surface, surfaceData, r_x, r_y)
	local px, py = floor(r_x / C.province_size), floor(r_y / C.province_size)
	surfaceData.provinces = surfaceData.provinces or {}
	local key = region_key(px, py)
	local dominant = surfaceData.provinces[key]
	if dominant == nil then
		dominant = false
		local rng = rng_for_reg_pos(surface.index, {x = px + 0.25, y = py + 0.25})
		if rng() >= C.province_mixed_chance then
			local total = 0
			for _, v in ipairs(surfaceData.configIndexed) do
				if v.allotment_range and v.type ~= "entity" then total = total + v.allotment end
			end
			if total > 0 then
				local roll = rng() * total
				for _, v in ipairs(surfaceData.configIndexed) do
					if v.allotment_range and v.type ~= "entity" then
						roll = roll - v.allotment
						if roll < 0 then
							dominant = v.name
							break
						end
					end
				end
			end
		end
		surfaceData.provinces[key] = dominant
	end
	return dominant or nil
end

local function distance_weight(weight, dist)
	local t = (dist - C.distance_near) / (C.distance_far - C.distance_near)
	t = max(0, min(1, t))
	return weight.near + (weight.far - weight.near) * t
end

-- weight multipliers of the region: soil (geology), province and distance; nil if all are 1
local function region_bias(surface, surfaceData, c_x, c_y, r_x, r_y)
	local geoBias = geology_bias(surface, c_x, c_y)
	local provinceWeight = setting("rso-province-weight")
	local dominant = provinceWeight ~= 1 and province_dominant(surface, surfaceData, r_x, r_y)
	local useDistance = setting("rso-distance-composition")
	local dist = distanceFromStartingAreas(surfaceData, r_x, r_y)
	local bias, biased = {}, false
	for _, v in ipairs(surfaceData.configIndexed) do
		if v.allotment_range then
			local m = geoBias and geoBias[v.name] or 1
			if v.name == dominant then m = m * provinceWeight end
			if useDistance and v.distance_weight then m = m * distance_weight(v.distance_weight, dist) end
			if m ~= 1 then
				bias[v.name] = m
				biased = true
			end
		end
	end
	if DEBUG and biased then debug("Region bias "..r_x..","..r_y..": "..serpent.line(bias)) end
	return biased and bias or nil
end

-- Guaranteed ring: every resource gets one field in a region around the first starting area.
-- Planned once per surface among regions that are not rolled and not fully generated yet.
local function plan_guarantees(surface, surfaceData)
	if surfaceData.guarantees or not setting("rso-guaranteed-ring") then return end
	local area = surfaceData.startingAreas and surfaceData.startingAreas[1]
	if not (area and surfaceData.configIndexed) then return end
	surfaceData.guarantees = {}
	local names = {}
	for _, v in ipairs(surfaceData.configIndexed) do
		if v.allotment_range and v.type ~= "entity" then names[#names + 1] = v.name end
	end
	if #names == 0 then return end

	local cx, cy = area.x / REGION_TILE_SIZE, area.y / REGION_TILE_SIZE
	local inner = surfaceData.starting_area_size + 0.5
	local outer = surfaceData.starting_area_size + C.ring_width
	local regions = surfaceData.regions
	local candidates = {}
	for r_x = floor(cx - outer) - 1, ceil(cx + outer) do
		for r_y = floor(cy - outer) - 1, ceil(cy + outer) do
			local d = distance({x = r_x + 0.5, y = r_y + 0.5}, {x = cx, y = cy})
			if d > inner and d <= outer and not (regions[r_x] and regions[r_x][r_y]) then
				local open = false
				for ox = 0, region_size - 1 do
					for oy = 0, region_size - 1 do
						if not surface.is_chunk_generated({r_x * region_size + ox, r_y * region_size + oy}) then
							open = true
							break
						end
					end
					if open then break end
				end
				if open then candidates[#candidates + 1] = {r_x, r_y} end
			end
		end
	end
	if #candidates == 0 then return end

	local rng = rng_for_reg_pos(surface.index, {x = 0.375, y = 0.375})
	for i = #candidates, 2, -1 do
		local j = rng(1, i)
		candidates[i], candidates[j] = candidates[j], candidates[i]
	end
	for i, name in ipairs(names) do
		local c = candidates[(i - 1) % #candidates + 1]
		local key = region_key(c[1], c[2])
		local list = surfaceData.guarantees[key] or {}
		list[#list + 1] = name
		surfaceData.guarantees[key] = list
	end
end

local function add_chunk_entry(r_data, c_x, c_y, name, deep)
	local column = r_data[c_x]
	if not column then
		column = {}
		r_data[c_x] = column
	end
	local c_data = column[c_y]
	if not c_data then
		c_data = {}
		column[c_y] = c_data
	end
	c_data[#c_data + 1] = {name, deep}
end

local function roll_region(surface, c_x, c_y)
	if isInStartingArea(surface.index, c_x, c_y) then
		return
	end

	local r_x = floor(c_x/REGION_TILE_SIZE)
	local r_y = floor(c_y/REGION_TILE_SIZE)
	local surfaceData = storage.surfaces[surface.index]
	local regions = surfaceData.regions
	local column = regions[r_x]
	if column and column[r_y] then
		return -- already rolled
	end
	if not column then
		column = {}
		regions[r_x] = column
	end
	local r_data = {}
	column[r_y] = r_data

	local configIndexed = surfaceData.configIndexed
	local rng = rng_for_reg_pos(surface.index, {x = r_x, y = r_y})

	local rollCount = surfaceData.rollCount or min(ceil(#configIndexed / 10) - 1, 3) -- 0 based
	local resourceChanceMultiplier = surfaceData.config and surfaceData.config.resourceChanceMultiplier or 1.0
	local resourceSetting = setting("rso-resource-chance") * resourceChanceMultiplier
	local maxAllotment = surfaceData.maxAllotment
	local geoRanges, geoMax = nil, nil
	local bias = maxAllotment > 0 and region_bias(surface, surfaceData, c_x, c_y, r_x, r_y)
	if bias then
		geoRanges, geoMax = weighted_allotments(configIndexed, bias)
	end
	local rolled = {}

	-- roll ores only if they are present (rng fails if the allotment is 0)
	if maxAllotment > 0 then
		for rollNumber = 0, rollCount do
			local resourceChance = resourceSetting - rollNumber * 0.1
			if rng() <= resourceChance then
				local res_type = rng(1, geoMax or maxAllotment)
				for index, v in ipairs(configIndexed) do
					local range = geoRanges and geoRanges[index] or (not geoRanges and v.allotment_range)
					if range and res_type >= range.min and res_type <= range.max then
						rolled[v.name] = true
						if DEBUG then debug("Rolled primary resource "..v.name.." with roll="..res_type.." @ "..r_x..","..r_y) end
						local num_spawns
						if v.spawns_per_region.min == v.spawns_per_region.max then
							num_spawns = v.spawns_per_region.min
						else
							num_spawns = rng(v.spawns_per_region.min, v.spawns_per_region.max)
						end
						local last_spawn_coords = {}
						for i = 1, num_spawns do
							local s_x, s_y = find_random_chunk(r_x, r_y, rng)
							-- the region may overlap the starting area
							if not isInStartingArea(surface.index, s_x, s_y) then
								add_chunk_entry(r_data, s_x, s_y, v.name, rollNumber)
								last_spawn_coords[#last_spawn_coords + 1] = {s_x, s_y}
								-- resource that comes along (enemies), only once
								if i == 1 then
									local am_roll = rng()
									for _, vv in ipairs(configIndexed) do
										local along = vv.along_resource_probability_range
										if along and am_roll >= along.min and am_roll <= along.max then
											add_chunk_entry(r_data, s_x, s_y, vv.name, rollNumber)
										end
									end
								end
							end
						end
						-- more resources around the primary one
						if #last_spawn_coords > 0 and v.multi_resource_chance and v.multi_resource then
							local multi = v.multi_resource
							local multiAllotmentMax = 0
							for _, sub_res in ipairs(multi) do multiAllotmentMax = multiAllotmentMax + sub_res.allotment end
							local deep = 0
							while rng() <= v.multi_resource_chance*(C.multi_resource_chance_diminish^deep) do
								deep = deep + 1
								local multi_type = 1 -- rng complains when its range is 0
								if multiAllotmentMax > 1 then
									multi_type = rng(1, multiAllotmentMax)
								end
								local low = 0
								for _, sub_res in ipairs(multi) do
									if multi_type >= low and multi_type <= sub_res.allotment + low then
										local last_coords = last_spawn_coords[rng(1, #last_spawn_coords)]
										local n_x, n_y = find_random_neighbour_chunk(last_coords[1], last_coords[2], rng)
										add_chunk_entry(r_data, n_x, n_y, sub_res.name, deep)
										break
									end
									low = low + sub_res.allotment
								end
							end
						end
						break
					end
				end
			end
		end
	end

	-- guaranteed ring: a missing resource goes to a chunk that is not generated yet (or this one)
	local key = region_key(r_x, r_y)
	local guaranteed = surfaceData.guarantees and surfaceData.guarantees[key]
	if guaranteed then
		surfaceData.guarantees[key] = nil
		local grng = rng_for_reg_pos(surface.index, {x = r_x + 0.625, y = r_y + 0.625})
		for _, name in ipairs(guaranteed) do
			if not rolled[name] then
				for _ = 1, 16 do
					local s_x, s_y = find_random_chunk(r_x, r_y, grng)
					if not isInStartingArea(surface.index, s_x, s_y) and ((s_x == c_x and s_y == c_y)
						or not surface.is_chunk_generated({s_x / CHUNK_SIZE, s_y / CHUNK_SIZE})) then
						add_chunk_entry(r_data, s_x, s_y, name, 0)
						storage.stats = storage.stats or {}
						storage.stats.guaranteed = (storage.stats.guaranteed or 0) + 1
						if DEBUG then debug("Guaranteed "..name.." @ "..s_x..","..s_y) end
						break
					end
				end
			end
		end
	end

	-- absolute_probability: enemies
	for _, v in ipairs(configIndexed) do
		if v.absolute_probability then
			local prob_factor = 1
			if v.probability_distance_factor then
				prob_factor = min(v.max_probability_distance_factor, v.probability_distance_factor^distance({x = 0, y = 0}, {x = r_x, y = r_y}))
			end
			if rng() < v.absolute_probability*prob_factor then
				for _ = 1, rng(v.spawns_per_region.min, v.spawns_per_region.max) do
					local s_x, s_y = find_random_chunk(r_x, r_y, rng)
					if not isInStartingArea(surface.index, s_x, s_y) then
						add_chunk_entry(r_data, s_x, s_y, v.name, 1)
					end
				end
			end
		end
	end
end

local function calculateFactor(dist, exponent)
	if dist < 1 and exponent < 1 then
		return dist
	end
	return dist^exponent
end

local function sort_by_deep(res1, res2)
	return res1[2] < res2[2]
end

local RUINS = "AbandonedRuins-paranoidal"
local RUIN_HALF = {small = 4, medium = 8, large = 16}

-- counters of the Reforged mechanics (remote "stats")
local function count(name)
	storage.stats = storage.stats or {}
	storage.stats[name] = (storage.stats[name] or 0) + 1
end

-- Sites of rich veins and guard nests, for the per-force counters read by achievements (remote
-- "force_stats"): storage.sites[surface index][chunk key] = list of {kind, x, y, found = {force index}}
local GUARD_RADIUS = 40

local function chunk_key(x, y)
	return tile_key(floor(x / CHUNK_SIZE), floor(y / CHUNK_SIZE))
end

local function add_site(surface, kind, x, y)
	storage.sites = storage.sites or {}
	local sites = storage.sites[surface.index] or {}
	storage.sites[surface.index] = sites
	local key = chunk_key(x, y)
	sites[key] = sites[key] or {}
	table.insert(sites[key], {kind = kind, x = x, y = y, found = {}})
end

local function credit(force, stat)
	storage.forceStats = storage.forceStats or {}
	local stats = storage.forceStats[force.index] or {}
	storage.forceStats[force.index] = stats
	stats[stat] = (stats[stat] or 0) + 1
end

-- A field with an infinite core or a rich vein may get a guard nest and an old mine ruin next to it.
local function rich_field_extras(surface, surfaceData, info, dist, rng)
	if not info then return end
	local core = info.infinite >= C.infinite_core_tiles
	if not (core or info.veined > 0) then return end
	local box = info.box
	local cx, cy = (box[1] + box[3]) / 2, (box[2] + box[4]) / 2
	if info.veined > 0 then
		count("veins")
		add_site(surface, "vein", cx, cy)
	end

	local guardChance = setting("rso-guard-chance")
	local enemyName = surfaceData.enemyName
	if guardChance > 0 and enemyName and not storage.skipEnemies and dist >= C.guard_min_distance and rng() < guardChance then
		if DEBUG then debug("Guard nest for the field at "..cx..","..cy) end
		count("guards")
		if spawn_entity(surface, enemyName, surfaceData.config[enemyName], cx, cy, rng, C.guard_size_mult) > 0 then
			add_site(surface, "guard", cx, cy)
		end
	end

	local mineChance = setting("rso-mine-ruin-chance")
	local iface = remote.interfaces[RUINS]
	if mineChance > 0 and iface and iface.spawn_mine and dist >= C.mine_min_distance and rng() < mineChance then
		local size = core and "large" or (rng() < 0.5 and "medium" or "small")
		local half = RUIN_HALF[size]
		local gap = half + 3
		local side = rng(1, 4)
		local x, y
		if side == 1 then
			x, y = box[1] - gap, cy
		elseif side == 2 then
			x, y = box[3] + gap, cy
		elseif side == 3 then
			x, y = cx, box[2] - gap
		else
			x, y = cx, box[4] + gap
		end
		x, y = floor(x), floor(y)
		-- only on generated ground
		for _, corner in ipairs({{x - half, y - half}, {x + half, y - half}, {x - half, y + half}, {x + half, y + half}}) do
			if not surface.is_chunk_generated({floor(corner[1] / CHUNK_SIZE), floor(corner[2] / CHUNK_SIZE)}) then
				return
			end
		end
		if remote.call(RUINS, "spawn_mine", surface.index, {x = x, y = y}, size) then count("mines") end
	end
end

-- generating: called for the chunk that is being generated right now
local function roll_chunk(surface, c_x, c_y, generating)
	if isInStartingArea(surface.index, c_x, c_y) then
		return
	end

	local r_x = floor(c_x/REGION_TILE_SIZE)
	local r_y = floor(c_y/REGION_TILE_SIZE)
	local surfaceData = storage.surfaces[surface.index]
	local column = surfaceData.regions[r_x]
	local r_data = column and column[r_y]
	local resource_list = r_data and r_data[c_x] and r_data[c_x][c_y]
	if not resource_list then
		return
	end

	local c_center_x = c_x + CHUNK_SIZE/2
	local c_center_y = c_y + CHUNK_SIZE/2
	local rng = rng_for_reg_pos(surface.index, {x = c_center_x, y = c_center_y})
	local richness_distance_factor = setting("rso-distance-exponent")
	local fluid_richness_distance_factor = setting("rso-fluid-distance-exponent")
	local size_distance_factor = setting("rso-size-exponent")
	local dist = distanceFromStartingAreas(surfaceData, r_x, r_y)
	local sizeFactor = calculateFactor(dist, size_distance_factor)
	local quiet = generating and {c_x, c_y, c_x + CHUNK_SIZE, c_y + CHUNK_SIZE} or nil
	local oreOptions = {quiet = quiet, veins = true, distance = dist}
	local liquidOptions = {quiet = quiet}

	table.sort(resource_list, sort_by_deep)

	for _, res_con in pairs(resource_list) do
		local resource = res_con[1]
		local deep = res_con[2]
		local r_config = surfaceData.config and surfaceData.config[resource]
		if r_config and r_config.valid then
			local restriction
			if r_config.type == "resource-ore" then
				local richFactor = calculateFactor(dist, richness_distance_factor)
				local size = rng(r_config.size.min, r_config.size.max) * (C.multi_resource_size_factor^deep) * sizeFactor
				local richness = r_config.richness * richFactor * (C.multi_resource_richness_factor^deep)
				-- the centre moves for every following resource of the chunk (as in the original)
				c_center_x, c_center_y, restriction = find_intersection(surface, c_center_x, c_center_y)
				local _, info = spawn_resource_ore(surface, resource, {x = c_center_x, y = c_center_y}, size, richness, false, restriction, rng, oreOptions)
				rich_field_extras(surface, surfaceData, info, dist, rng)
			elseif r_config.type == "resource-liquid" then
				local richFactor = calculateFactor(dist, r_config.useOreScaling and richness_distance_factor or fluid_richness_distance_factor)
				local size = rng(r_config.size.min, r_config.size.max) * (C.multi_resource_size_factor^deep) * sizeFactor
				if r_config.size.min == 1 and r_config.size.max == 1 then
					size = 1
				end
				local richness = rng(r_config.richness.min, r_config.richness.max) * richFactor * (C.multi_resource_richness_factor^deep)
				c_center_x, c_center_y, restriction = find_intersection(surface, c_center_x, c_center_y)
				spawn_resource_liquid(surface, resource, {x = c_center_x, y = c_center_y}, size, richness, false, restriction, rng, liquidOptions)
			elseif r_config.type == "entity" and not storage.skipEnemies then
				spawn_entity(surface, resource, r_config, c_center_x, c_center_y, rng)
			end
		else
			log("RSO: no valid config for " .. tostring(resource) .. " on " .. surface.name)
		end
	end

	r_data[c_x][c_y] = nil
	if next(r_data[c_x]) == nil then
		r_data[c_x] = nil
	end
end

--[[ REGENERATION ]]--

local function clear_chunk(surface, tileX, tileY, ent_list)
	local area = {{tileX, tileY}, {tileX + CHUNK_SIZE, tileY + CHUNK_SIZE}}
	if #ent_list > 0 then
		for _, obj in pairs(surface.find_entities_filtered{area = area, name = ent_list}) do
			if obj.valid then
				obj.destroy()
			end
		end
	end
	if not storage.skipEnemies then
		for _, obj in pairs(surface.find_entities_filtered{area = area, type = "unit", force = "enemy"}) do
			if obj.valid then
				obj.destroy()
			end
		end
	end
end

local function prepareEntityList(surfaceIndex)
	local entityList = {}
	for _, v in pairs(storage.surfaces[surfaceIndex].configIndexed or {}) do
		if prototypes.entity[v.name] then
			entityList[#entityList + 1] = v.name
		end
		if prototypes.entity["infinite-" .. v.name] then
			entityList[#entityList + 1] = "infinite-" .. v.name
		end
		if not storage.skipEnemies then
			for base in pairs(v.bases or {}) do
				entityList[#entityList + 1] = base
			end
			for ent in pairs(v.sub_spawns or {}) do
				entityList[#entityList + 1] = ent
			end
		end
	end
	return entityList
end

local function isIgnoredSurface(surface)
	return storage.ignoreSurfaceNames and storage.ignoreSurfaceNames[surface.name]
end

-- surfaces where RSO actually generates something
local function isGeneratedSurface(surface)
	local surfaceData = storage.surfaces[surface.index]
	return surfaceData and not isIgnoredSurface(surface) and surfaceData.configIndexed and #surfaceData.configIndexed > 0
end

local function regenerateSurface(surface, clearOnly)
	if not isGeneratedSurface(surface) then return end
	local surfaceData = storage.surfaces[surface.index]
	surfaceData.regions = {}

	local entityList = prepareEntityList(surface.index)
	for chunk in surface.get_chunks() do
		local tileX = chunk.x * CHUNK_SIZE
		local tileY = chunk.y * CHUNK_SIZE
		if not isInStartingArea(surface.index, tileX, tileY) then
			clear_chunk(surface, tileX, tileY, entityList)
		end
	end

	if not clearOnly then
		for chunk in surface.get_chunks() do
			local tileX = chunk.x * CHUNK_SIZE
			local tileY = chunk.y * CHUNK_SIZE
			if not isInStartingArea(surface.index, tileX, tileY) then
				roll_region(surface, tileX, tileY)
				roll_chunk(surface, tileX, tileY)
			end
		end
	end
	log(clearOnly and "RSO: ore clear done on " .. surface.name or "RSO: ore regeneration done on " .. surface.name)
end

local function regenerate_everything(clearOnly, noEnemies)
	storage.skipEnemies = noEnemies
	for index in pairs(storage.surfaces) do
		local surface = game.surfaces[index]
		if surface then
			regenerateSurface(surface, clearOnly)
		end
	end
	storage.skipEnemies = nil
end

local function clearStartingArea(surface, pos)
	local startingAreaTilesSize = ceil(storage.surfaces[surface.index].starting_area_size * REGION_TILE_SIZE)
	local chunkPosX = floor(pos.x/CHUNK_SIZE) * CHUNK_SIZE
	local chunkPosY = floor(pos.y/CHUNK_SIZE) * CHUNK_SIZE
	local entityList = prepareEntityList(surface.index)
	for posX = chunkPosX - startingAreaTilesSize, chunkPosX + startingAreaTilesSize, CHUNK_SIZE do
		for posY = chunkPosY - startingAreaTilesSize, chunkPosY + startingAreaTilesSize, CHUNK_SIZE do
			clear_chunk(surface, posX, posY, entityList)
		end
	end
end

--[[ DIAGNOSTICS ]]--

local function printResourceProbability(player)
	local surfaceData = storage.surfaces[player.surface.index]
	local maxAllotment = surfaceData.maxAllotment
	player.print("Max allotment " .. string.format("%.1f", maxAllotment))
	for _, v in pairs(surfaceData.configIndexed) do
		if v.type ~= "entity" and v.allotment then
			player.print("Resource: " .. v.name .. " Prob: " .. string.format("%.1f", (v.allotment/maxAllotment) * 100))
		end
	end
end

local function IsIgnoreResource(prototype)
	local name = prototype.name
	if string.find(name, "underground-", 1, true) or string.find(name, "infinite-", 1, true) then
		return true
	end
	local autoplace = prototype.autoplace_specification
	return autoplace == nil or autoplace.tile_restriction ~= nil
end

-- tells the player about resources with autoplace that RSO has no config for (they are not spawned)
local function checkForUnusedResources(player)
	if script.active_mods["space-age"] then return end
	local surfaceData = storage.surfaces[player.surface.index]
	local config = surfaceData and surfaceData.config
	if not config then return end
	for name, prototype in pairs(prototypes.get_entity_filtered{{filter = "type", type = "resource"}}) do
		if not config[name] and not IsIgnoreResource(prototype) then
			player.print("The resource " .. name .. " is not configured in RSO. It won't be spawned!")
		end
	end
end

--[[ LIFECYCLE ]]--

local function loadAndPrepareConfig(surface)
	local planet = surface.planet
	if planet then
		storage.surfaces[surface.index].config = loadResourceConfig()[planet.name]
	end
	checkConfigForInvalidResources(surface.index)
	build_config_data(surface)
end

local function updateSurfaceConfig(surface, justCreated, surfaceData)
	if not surfaceData then
		storage.surfaces[surface.index] = storage.surfaces[surface.index] or {}
		surfaceData = storage.surfaces[surface.index]
	end

	surfaceData.seed = surface.map_gen_settings.seed
	surfaceData.regions = surfaceData.regions or {}

	if not surfaceData.startingAreas then
		surfaceData.startingAreas = {}
		for _, startingPoint in pairs(surface.map_gen_settings.starting_points or {}) do
			table.insert(surfaceData.startingAreas, {x = startingPoint.x, y = startingPoint.y, spawned = false})
			if not justCreated then
				surfaceData.startingAreas[1].spawned = true
			end
		end
	end

	loadAndPrepareConfig(surface)
	plan_guarantees(surface, surfaceData)

	if C.config_log_enabled then
		log("***** Config for surface " .. surface.index)
		log(serpent.block(surfaceData.config))
		log(serpent.block(surfaceData.configIndexed))
	end
end

-- first run: nauvis data, including regions of very old saves; returns the index it built
local function initConfig()
	if storage.surfaces then return nil end
	storage.surfaces = {}
	local nauvis = game.surfaces.nauvis
	local nauvisSurfaceData = {}
	local justCreated = true
	if storage.regions then
		nauvisSurfaceData.regions = storage.regions
		storage.regions = nil
		justCreated = false
	elseif game.tick > 10 then
		justCreated = false
	else
		-- a map saved right after its creation (e.g. by rso-mod before the rename) already has the
		-- starting resources: do not spawn them a second time
		local spawn = nauvis.map_gen_settings.starting_points
		spawn = spawn and spawn[1] or {x = 0, y = 0}
		local r = C.starting_area_size * REGION_TILE_SIZE
		if nauvis.count_entities_filtered{type = "resource", limit = 1,
			area = {{spawn.x - r, spawn.y - r}, {spawn.x + r, spawn.y + r}}} > 0 then
			justCreated = false
		end
	end
	storage.surfaces[nauvis.index] = nauvisSurfaceData
	updateSurfaceConfig(nauvis, justCreated)
	return nauvis.index
end

local function updateConfig()
	local built = initConfig()
	for surfaceIndex, surfaceData in pairs(storage.surfaces) do
		local surface = game.surfaces[surfaceIndex]
		if surface and surfaceIndex ~= built then
			updateSurfaceConfig(surface, false, surfaceData)
		end
	end
	for _, surface in pairs(game.surfaces) do
		if not storage.surfaces[surface.index] then
			updateSurfaceConfig(surface, false)
		end
	end
	storage.useBobEntity = nil -- no longer used
	log("RSO: Updated resource configurations")
end

local function localGenerateChunk(event)
	local surface = event.surface
	if not isGeneratedSurface(surface) then
		return
	end
	local c_x = event.area.left_top.x
	local c_y = event.area.left_top.y
	roll_region(surface, c_x, c_y)
	roll_chunk(surface, c_x, c_y, true)
end

local function registerChunkHandler()
	if not storage.disableEventHandler then
		script.on_event(defines.events.on_chunk_generated, localGenerateChunk)
	end
end

script.on_init(function()
	updateConfig()
	if game.surfaces.nauvis then
		spawn_starting_resources(game.surfaces.nauvis, 1)
	end
	registerChunkHandler()
end)

script.on_load(registerChunkHandler)

script.on_configuration_changed(updateConfig)

local function notify(event, message)
	local player = event.player_index and game.get_player(event.player_index)
	if player then
		player.print(message)
	else
		game.print(message)
	end
end

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	if event.setting == "rso-region-size" then
		region_size = setting("rso-region-size")
		REGION_TILE_SIZE = CHUNK_SIZE*region_size
		notify(event, "Warning: Region size changed. Dynamic size changes are not supported - recommend regenerating of resources to use new region size")
	elseif event.setting == "rso-enemy-chance" then
		local chance = setting("rso-enemy-chance")
		for _, surfaceData in pairs(storage.surfaces) do
			for _, v in pairs(surfaceData.configIndexed or {}) do
				if v.absolute_probability then
					v.absolute_probability = chance
				end
			end
		end
		notify(event, "Enemy spawn chance update - it will be applied to new regions.")
	end
end)

script.on_event(defines.events.on_player_created, function(event)
	local player = game.get_player(event.player_index)
	if not storage.surfaces[player.surface.index] then
		updateSurfaceConfig(player.surface, false)
	end
	checkForUnusedResources(player)
	if DEBUG then
		printResourceProbability(player)
	end
end)

script.on_event(defines.events.on_surface_created, function(event)
	local surface = game.surfaces[event.surface_index]
	if isIgnoredSurface(surface) then
		return
	end
	initConfig()
	updateSurfaceConfig(surface, true)
	spawn_starting_resources(surface, 1)
end)

--[[ GEOLOGICAL SURVEY ]]--

-- storage.forecasts[surface index][chunk key][force index] = map label (LuaRenderObject)
local function forecast_marks(surface_index)
	storage.forecasts = storage.forecasts or {}
	local marks = storage.forecasts[surface_index]
	if not marks then
		marks = {}
		storage.forecasts[surface_index] = marks
	end
	return marks
end

local function clear_forecasts(surface_index)
	local marks = storage.forecasts and storage.forecasts[surface_index]
	if not marks then return end
	for _, forces in pairs(marks) do
		for _, label in pairs(forces) do
			if label.valid then label.destroy() end
		end
	end
	storage.forecasts[surface_index] = nil
end

-- rough expected amount of an ore field at the region, from the config and the settings
local function estimate(surfaceData, cfg, r_x, r_y)
	if cfg.type ~= "resource-ore" then return "?" end
	local dist = distanceFromStartingAreas(surfaceData, r_x, r_y)
	local size = (cfg.size.min + cfg.size.max) / 2 * calculateFactor(dist, setting("rso-size-exponent")) * setting("rso-global-size-mult")
	local amount = cfg.richness * calculateFactor(dist, setting("rso-distance-exponent")) * 7.5 * size ^ 0.6 * setting("rso-global-richness-mult")
	if amount >= 1e6 then
		return string.format("~%.1fM", amount / 1e6)
	end
	return string.format("~%dk", floor(amount / 1000 + 0.5))
end

local function forecast(surface_index, force_index, position)
	local surface = game.get_surface(surface_index)
	local force = game.forces[force_index]
	local surfaceData = storage.surfaces and storage.surfaces[surface_index]
	if not (surface and force and type(position) == "table" and position.x and position.y and isGeneratedSurface(surface)) then
		return nil
	end
	local marks = forecast_marks(surface_index)
	local best, bestD = nil, nil
	for r_x, column in pairs(surfaceData.regions) do
		for r_y, r_data in pairs(column) do
			for c_x, chunks in pairs(r_data) do
				for c_y, list in pairs(chunks) do
					local d = (c_x + 16 - position.x)^2 + (c_y + 16 - position.y)^2
					local key = tile_key(c_x, c_y)
					if (not bestD or d < bestD) and not (marks[key] and marks[key][force_index]) then
						-- the primary resource of the chunk (the lowest depth)
						local name, deep = nil, nil
						for _, entry in ipairs(list) do
							local cfg = surfaceData.config[entry[1]]
							if cfg and cfg.valid and cfg.type ~= "entity" and (not deep or entry[2] < deep) then
								name, deep = entry[1], entry[2]
							end
						end
						if name and not force.is_chunk_charted(surface, {c_x / CHUNK_SIZE, c_y / CHUNK_SIZE}) then
							best = {c_x = c_x, c_y = c_y, r_x = r_x, r_y = r_y, name = name, key = key}
							bestD = d
						end
					end
				end
			end
		end
	end
	if not best then return nil end

	local x, y = best.c_x + CHUNK_SIZE / 2, best.c_y + CHUNK_SIZE / 2
	local icon = "[img=entity/" .. best.name .. "]"
	local label = rendering.draw_text{
		text = icon .. " " .. estimate(surfaceData, surfaceData.config[best.name], best.r_x, best.r_y),
		surface = surface, target = {x, y}, color = {1, 0.85, 0.4}, forces = {force},
		render_mode = "chart", scale = 1.5, scale_with_zoom = true, use_rich_text = true,
		alignment = "center", vertical_alignment = "middle",
	}
	marks[best.key] = marks[best.key] or {}
	marks[best.key][force_index] = label
	count("forecasts")
	force.print({"rso-message.forecast", icon, string.format("[gps=%d,%d,%s]", x, y, surface.name)})
	return {x = x, y = y}
end

-- a forecast disappears when its chunk is charted by the force: the field is on the map then;
-- a rich vein in the chunk counts as found by the force
script.on_event(defines.events.on_chunk_charted, function(event)
	local force = event.force
	local marks = storage.forecasts and storage.forecasts[event.surface_index]
	if marks then
		local key = tile_key(event.position.x * CHUNK_SIZE, event.position.y * CHUNK_SIZE)
		local forces = marks[key]
		local label = forces and forces[force.index]
		if label then
			if label.valid then label.destroy() end
			forces[force.index] = nil
			if next(forces) == nil then marks[key] = nil end
		end
	end
	local sites = storage.sites and storage.sites[event.surface_index]
	local list = sites and sites[tile_key(event.position.x, event.position.y)]
	if list then
		for _, site in ipairs(list) do
			if site.kind == "vein" and not site.found[force.index] then
				site.found[force.index] = true
				credit(force, "veins")
			end
		end
	end
end)

-- the last nest of a guard site killed by a force clears the site for it
script.on_event(defines.events.on_entity_died, function(event)
	local entity = event.entity
	local sites = storage.sites and storage.sites[entity.surface.index]
	if not sites then return end
	local p = entity.position
	local cx, cy = floor(p.x / CHUNK_SIZE), floor(p.y / CHUNK_SIZE)
	for dx = -1, 1 do
		for dy = -1, 1 do
			local key = tile_key(cx + dx, cy + dy)
			local list = sites[key]
			if list then
				for i = #list, 1, -1 do
					local site = list[i]
					if site.kind == "guard" and (site.x - p.x)^2 + (site.y - p.y)^2 <= GUARD_RADIUS^2
						and entity.surface.count_entities_filtered{position = {site.x, site.y}, radius = GUARD_RADIUS,
							type = "unit-spawner", force = entity.force} <= 1 then
						table.remove(list, i)
						local force = event.force
						if force and force.valid and #force.players > 0 then
							credit(force, "guards")
						end
					end
				end
				if #list == 0 then sites[key] = nil end
			end
		end
	end
end, {{filter = "type", type = "unit-spawner"}})

--[[ NEW VEINS UNDER DEPLETED FIELDS ]]--

script.on_event(defines.events.on_resource_depleted, function(event)
	local chance = setting("rso-depletion-vein-chance")
	local entity = event.entity
	if chance <= 0 or not (entity and entity.valid) then return end
	local surface = entity.surface
	if not isGeneratedSurface(surface) then return end
	local surfaceData = storage.surfaces[surface.index]
	local name = entity.name
	local cfg = surfaceData.config and surfaceData.config[name]
	if not (cfg and cfg.valid and cfg.type == "resource-ore") then return end

	storage.depletionRng = storage.depletionRng or game.create_random_generator(surfaceData.seed % 4294967296)
	local rng = storage.depletionRng
	if rng() >= chance then return end

	local p = entity.position
	local angle = rng() * pi * 2
	local d = C.depletion_vein_distance[1] + rng() * (C.depletion_vein_distance[2] - C.depletion_vein_distance[1])
	local pos = {x = floor(p.x + cos(angle) * d) + 0.5, y = floor(p.y + sin(angle) * d) + 0.5}
	local dist = distanceFromStartingAreas(surfaceData, pos.x / REGION_TILE_SIZE, pos.y / REGION_TILE_SIZE)
	local richness = cfg.richness * calculateFactor(dist, setting("rso-distance-exponent")) * C.depletion_vein_richness
	local size = rng(C.depletion_vein_size[1], C.depletion_vein_size[2])
	local total, info = spawn_resource_ore(surface, name, pos, size, richness, false, '', rng, {no_shift = true, min_ratio = C.depletion_vein_min_ratio})
	if total <= 0 or not info then return end

	count("depletion_veins")
	local box = info.box
	local chunk = {floor(pos.x / CHUNK_SIZE), floor(pos.y / CHUNK_SIZE)}
	local gps = string.format("[gps=%d,%d,%s]", floor(pos.x), floor(pos.y), surface.name)
	for _, force in pairs(game.forces) do
		if #force.players > 0 and force.is_chunk_charted(surface, chunk) then
			force.chart(surface, {{box[1], box[2]}, {box[3], box[4]}})
			force.print({"rso-message.new-vein", "[img=entity/" .. name .. "]", gps})
		end
	end
end)

script.on_event(defines.events.on_surface_deleted, function(event)
	storage.surfaces[event.surface_index] = nil
	if storage.forecasts then storage.forecasts[event.surface_index] = nil end
	if storage.sites then storage.sites[event.surface_index] = nil end
end)

script.on_event(defines.events.on_surface_cleared, function(event)
	if storage.surfaces[event.surface_index] then
		storage.surfaces[event.surface_index].regions = {}
	end
	clear_forecasts(event.surface_index)
	if storage.sites then storage.sites[event.surface_index] = nil end
end)

--[[ COMMANDS ]]--

-- the commands rewrite the whole map: admins (or the server console) only
local function allowed(command)
	local player = command.player_index and game.get_player(command.player_index)
	if player and not player.admin then
		player.print("RSO: only admins can use /" .. command.name)
		return false
	end
	return true
end

local function skipEnemiesParameter(parameters)
	return parameters ~= nil and parameters.parameter == "noenemies"
end

local function regenerateCommand(parameters)
	if parameters and not allowed(parameters) then return end
	regenerate_everything(false, skipEnemiesParameter(parameters))
end

local function clearCommand(parameters)
	if parameters and not allowed(parameters) then return end
	regenerate_everything(true, skipEnemiesParameter(parameters))
end

local function seedCommand(parameters)
	if not allowed(parameters) then return end
	storage.mapSeedOverride = parameters.parameter and tonumber(parameters.parameter) or nil
end

local function regenerateSurfaceCommand(parameters)
	if not allowed(parameters) then return end
	local player = parameters.player_index and game.get_player(parameters.player_index)
	if not player then
		log("RSO: surface regenerate command used without player")
		return
	end
	local surface = player.surface
	local surfaceData = storage.surfaces[surface.index]
	if not isGeneratedSurface(surface) then
		player.print("RSO does not generate resources on surface " .. surface.name)
		return
	end
	local withStartingArea = parameters.parameter == "all"
	if withStartingArea then
		for _, startingArea in pairs(surfaceData.startingAreas) do
			clearStartingArea(surface, startingArea)
			startingArea.spawned = false
		end
	end
	regenerateSurface(surface, false)
	if withStartingArea then
		for index in pairs(surfaceData.startingAreas) do
			spawn_starting_resources(surface, index)
		end
	end
	player.print("Surface " .. surface.name .. " regenerated" .. (withStartingArea and " with starting area" or ""))
end

commands.add_command("rso-regenerate", "", regenerateCommand)
commands.add_command("rso-clear", "", clearCommand)
commands.add_command("rso-override-seed", "", seedCommand)
commands.add_command("rso-regenerate-surface", "", regenerateSurfaceCommand)

--[[ REMOTE INTERFACE ]]--

remote.add_interface("RSO", {
	-- remote.call("RSO", "regenerate")
	regenerate = function()
		regenerateCommand(nil)
	end,

	clear = function()
		clearCommand(nil)
	end,

	-- remote.call("RSO", "ignoreSurface", "name-of-surface")
	ignoreSurface = function(surfaceName)
		if type(surfaceName) ~= "string" then
			log("RSO ignoreSurface interface: surfaceName should be a string")
			return
		end
		storage.ignoreSurfaceNames = storage.ignoreSurfaceNames or {}
		storage.ignoreSurfaceNames[surfaceName] = true
	end,

	-- remote.call("RSO", "addStartLocation", {x = 0, y = 0}, player)
	addStartLocation = function(pos, player)
		if not (pos and pos.x and pos.y) then
			log("Invalid parameters for new start location - please use following format: {x=0, y=0}")
			return
		end
		local outputPlayer = player or game.player
		local surface = outputPlayer and outputPlayer.surface or game.surfaces.nauvis
		local surfaceData = storage.surfaces[surface.index]
		if not surfaceData then
			log("RSO: no data for surface " .. surface.name)
			return
		end
		local radius = surfaceData.starting_area_size * REGION_TILE_SIZE
		for _, startingPos in pairs(surfaceData.startingAreas) do
			if distance(startingPos, pos) < 2 * radius then
				log("Creation of starting area on "..surface.name.." failed - to close to starting area at "..startingPos.x..","..startingPos.y)
				return
			end
		end
		log("Creating new starting area on "..surface.name.." at "..pos.x..","..pos.y)
		clearStartingArea(surface, pos)
		pos.spawned = false
		table.insert(surfaceData.startingAreas, pos)
		spawn_starting_resources(surface, #surfaceData.startingAreas)
	end,

	regenConfig = function()
		for index in pairs(storage.surfaces) do
			local surface = game.surfaces[index]
			if surface then
				loadAndPrepareConfig(surface)
			end
		end
	end,

	disableChunkHandler = function()
		if not storage.disableEventHandler then
			script.on_event(defines.events.on_chunk_generated, nil)
		end
		storage.disableEventHandler = true
	end,

	disableStartingArea = function()
		storage.disableStartingArea = true
	end,

	generateChunk = function(event)
		localGenerateChunk(event)
	end,

	resetGeneration = function(surface, ignoreStartingAreas)
		if surface == nil then
			return
		end
		local surfaceData = storage.surfaces[surface.index]
		updateSurfaceConfig(surface, false, surfaceData)
		surfaceData = storage.surfaces[surface.index]
		surfaceData.regions = {}
		if not ignoreStartingAreas then
			for index, startingArea in pairs(surfaceData.startingAreas) do
				startingArea.spawned = false
				spawn_starting_resources(surface, index)
			end
		end
	end,

	isInStartingArea = function(surfaceIndex, tileX, tileY)
		return isInStartingArea(surfaceIndex, tileX, tileY)
	end,

	-- Geological survey (Ore Radar): marks for the force on its map the nearest field that is rolled
	-- but not generated yet. Returns the marked position or nil.
	-- remote.call("RSO", "forecast", surface_index, force_index, {x = 0, y = 0})
	forecast = forecast,

	-- counters of the Reforged mechanics: veins, guards, mines, guaranteed, depletion_veins, forecasts
	stats = function()
		return storage.stats or {}
	end,

	-- per force: {[force index] = {veins = rich veins found (charted), guards = guard sites cleared}}
	force_stats = function()
		return storage.forceStats or {}
	end,
})
