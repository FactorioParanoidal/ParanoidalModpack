require "config"
require "util"

require "resourceconfigs.mainconfig"
require "libs.straight_world"
require "libs.straight_world_platforms"

local MB=require "libs/metaball"

local logger = require 'libs/logger'
local l = logger.new_logger()

-- math shortcuts
local floor = math.floor
local abs = math.abs
local cos = math.cos
local sin = math.sin
local pi = math.pi
local max = math.max

local function round(value)
	return math.floor(value + 0.5)
end

local function debug(str)
	if debug_enabled then
		l:log(str)
	end
end

function tableLength(tableToCount)
	local count = 0
	for _ in pairs(tableToCount) do count = count + 1 end
	return count
end

-- cached setting value
local region_size = settings.global["rso-region-size"].value

-- constants
local CHUNK_SIZE = 32
local REGION_TILE_SIZE = CHUNK_SIZE*region_size
local MIN_BALL_DISTANCE = CHUNK_SIZE/6
local P_BALL_SIZE_FACTOR = 0.7
local N_BALL_SIZE_FACTOR = 0.95
local NEGATIVE_MODIFICATOR = 9973

local meta_shapes = nil

if settings.global["rso-use-donuts"].value then
	meta_shapes = {MB.MetaEllipse, MB.MetaSquare, MB.MetaDonut}
else
	meta_shapes = {MB.MetaEllipse, MB.MetaSquare}
end	

-- local globals
local distance = util.distance
local invalidResources = {}

--[[ HELPER METHODS ]]--

local function normalize(n) -- keep numbers at 32 bits
	return floor(n) % 0xffffffff
end

local function bearing(origin, dest)
	-- finds relative angle
	local xd = dest.x - origin.x
	local yd = dest.y - origin.y
	return math.atan2(xd, yd);
end

local function str2num(s)
	local num = 0
	for i=1,s:len() do
		num=num + (s:byte(i) - 33)*i
	end
	return num
end

--local function rng_for_pos(pos)
--	local num = 0
--	local x = pos.x
--	local y = pos.y
--	
--	if x == 0 then x = 0.5 end
--	if y == 0 then y = 0.5 end
--	if x < 0 then
--		x = abs(x) + NEGATIVE_MODIFICATOR
--	end
--	if y < 0 then
--		y = abs(y) + NEGATIVE_MODIFICATOR
--	end
--	
--	return rng* drand.lcg(y, 'mvc'):random(0)*drand.lcg(x, 'nr'):random(0)
--end

local function rng_for_reg_pos(surfaceIndex, pos)
	local x = pos.x
	local y = pos.y
	
	local rng = game.create_random_generator()

	if x == 0 then x = 0.5 end
	if y == 0 then y = 0.5 end

	if x < 0 then
		x = abs(x) + NEGATIVE_MODIFICATOR
	end
	if y < 0 then
		y = abs(y) + NEGATIVE_MODIFICATOR
	end

	rng.re_seed(normalize(x * 65536))
	local valX = rng(65536)
	rng.re_seed(normalize(y * 32768))
	local valY = rng(32768)
	
	local mapSeed = global.surfaces[surfaceIndex].seed
	if global.mapSeedOverride then
		mapSeed = global.mapSeedOverride
	end
	local seed = normalize( valX * valY * mapSeed )
	rng.re_seed( seed )
	
	debug("Generator for " .. pos.x .. "," .. pos.y .. " created with seed " .. seed .. " x:" .. valX .. " y:" .. valY)
	
	return rng
end

local function rng_restricted_angle(restrictions, rng)
	local value = rng()
	local x_scale, y_scale, angle
	local deformX = rng() * 2 - 1
	local deformY = rng() * 2 - 1
	
	if restrictions=='xy' then
		y_scale=1.0 + deformY*0.5
		x_scale=1.0 + deformX*0.5
		angle = value*pi*2  
	elseif restrictions=='x' then
		y_scale=1.0 + deformY*0.6
		x_scale=1.0 + deformX*0.6
		angle = value*pi/2 - pi/4
	elseif restrictions=='y' then
		y_scale=1.0 + deformY*0.6
		x_scale=1.0 + deformX*0.6
		angle = value*pi/2 + pi/2
	else
		y_scale=1.0 + deformY*0.3
		x_scale=1.0 + deformX*0.3
		angle = value*pi*2
	end
	
	return angle, x_scale, y_scale
end

local function vary_by_percentage(x, p, rng)
	return x + (0.5 - rng())*2*x*p
end


local function remove_trees(surface, x, y, x_size, y_size )
	local bb = {{x - x_size, y - y_size}, {x + x_size, y + y_size}}
	
	for _, entity in pairs(surface.find_entities_filtered{area = bb, type={"tree", "simple-entity"}}) do
		if entity.valid then
			entity.destroy()
		end
	end
end

local function remove_trees_based_on_bb(surface, x, y, boundingBox)
	local bb = {{x + boundingBox.left_top.x, y + boundingBox.left_top.y}, {x + boundingBox.right_bottom.x, y + boundingBox.right_bottom.x}}
	
	for _, entity in pairs(surface.find_entities_filtered{area = bb, type={"tree", "simple-entity"}}) do
		if entity.valid then
			entity.destroy()
		end
	end
end

local function find_intersection(surface, x, y)
	-- try to get position in between of valid chunks by probing map
	-- this may breaks determinism of generation, but so far it returned on first if
	local gt = surface.get_tile
	local restriction = ''
	if gt(x + CHUNK_SIZE*2, y + CHUNK_SIZE*2).valid and gt(x - CHUNK_SIZE*2, y - CHUNK_SIZE*2).valid and gt(x + CHUNK_SIZE*2, y - CHUNK_SIZE*2).valid and gt(x - CHUNK_SIZE*2, y + CHUNK_SIZE*2).valid then
		restriction = 'xy'
	elseif gt(x + CHUNK_SIZE*2, y + CHUNK_SIZE*2).valid and gt(x + CHUNK_SIZE*2, y).valid and gt(x, y + CHUNK_SIZE*2).valid then
		x=x + CHUNK_SIZE/2
		y=y + CHUNK_SIZE/2
		restriction = 'xy'
	elseif gt(x + CHUNK_SIZE*2, y - CHUNK_SIZE*2).valid and gt(x + CHUNK_SIZE*2, y).valid and gt(x, y - CHUNK_SIZE*2).valid then
		x=x + CHUNK_SIZE/2
		y=y - CHUNK_SIZE/2
		restriction = 'xy'
	elseif gt(x - CHUNK_SIZE*2, y + CHUNK_SIZE*2).valid and gt(x - CHUNK_SIZE*2, y).valid and gt(x, y + CHUNK_SIZE*2).valid then
		x=x - CHUNK_SIZE/2
		y=y + CHUNK_SIZE/2
		restriction = 'xy'    
	elseif gt(x - CHUNK_SIZE*2, y - CHUNK_SIZE*2).valid and gt(x - CHUNK_SIZE*2, y).valid and gt(x, y - CHUNK_SIZE*2).valid then
		x=x - CHUNK_SIZE/2
		y=y - CHUNK_SIZE/2
		restriction = 'xy'
	elseif gt(x + CHUNK_SIZE*2, y).valid then
		x=x + CHUNK_SIZE/2
		restriction = 'x'
	elseif gt(x - CHUNK_SIZE*2, y).valid then
		x=x - CHUNK_SIZE/2
		restriction = 'x'
	elseif gt(x, y + CHUNK_SIZE*2).valid then
		y=y + CHUNK_SIZE/2
		restriction = 'y'
	elseif gt(x, y - CHUNK_SIZE*2).valid then
		y=y - CHUNK_SIZE/2
		restriction = 'y'
	end
	return x, y, restriction
end

local function find_random_chunk(r_x, r_y, rng)
	local offset_x=rng(region_size) - 1
	local offset_y=rng(region_size) - 1
	local c_x=r_x*REGION_TILE_SIZE + offset_x*CHUNK_SIZE
	local c_y=r_y*REGION_TILE_SIZE + offset_y*CHUNK_SIZE
	-- debug("Random chunk "..r_x..","..r_y.." coords "..c_x..","..c_y.." offset "..offset_x..","..offset_y)
	return c_x, c_y
end

local function is_same_region(c_x1, c_y1, c_x2, c_y2)
	if not (floor(c_x1/REGION_TILE_SIZE) == floor(c_x2/REGION_TILE_SIZE)) then
		return false
	end
	if not (floor(c_y1/REGION_TILE_SIZE) == floor(c_y2/REGION_TILE_SIZE)) then
		return false
	end
	return true
end

local function find_random_neighbour_chunk(ocx, ocy, rng)
	-- somewhat bruteforce and unoptimized
	local x_dir = rng(-2,2)
	local y_dir = rng(-2,2)
	
	local ncx = ocx + x_dir * CHUNK_SIZE
	local ncy = ocy + y_dir * CHUNK_SIZE
	if is_same_region(ncx, ncy, ocx, ocy) then
		return ncx, ncy
	end
	
	ncx = ocx - x_dir * CHUNK_SIZE
	ncy = ocy - y_dir * CHUNK_SIZE
	if is_same_region(ncx, ncy, ocx, ocy) then
		return ncx, ncy
	end
	
	ncx = ocx - x_dir * CHUNK_SIZE
	ncy = ocy + y_dir * CHUNK_SIZE
	if is_same_region(ncx, ncy, ocx, ocy) then
		return ncx, ncy
	end
	
	ncx = ocx + x_dir * CHUNK_SIZE
	ncy = ocy - y_dir * CHUNK_SIZE
	if is_same_region(ncx, ncy, ocx, ocy) then
		return ncx, ncy
	end
	
	return ocx, ocy
end

local function isInStartingArea( surfaceIndex, tileX, tileY )

	local surfaceData = global.surfaces[surfaceIndex]

	if surfaceData and surfaceData.startingAreas then
		for idx, data in pairs( surfaceData.startingAreas ) do
			
			local adjustedX = ( tileX - data.x ) / REGION_TILE_SIZE
			local adjustedY = ( tileY - data.y ) / REGION_TILE_SIZE
			if ((adjustedX * adjustedX + adjustedY * adjustedY) <= surfaceData.starting_area_size * surfaceData.starting_area_size) then
				return true
			end
		end
	end
	
	return false
end

local function distanceFromStartingAreas( surfaceData, regionX, regionY )

	local minDistance = nil

	for idx, data in pairs( surfaceData.startingAreas ) do
		local dist = distance({x = data.x / REGION_TILE_SIZE, y = data.y / REGION_TILE_SIZE},{x = regionX, y = regionY})
		if minDistance ~= nil then
			minDistance = math.min(minDistance, dist)
		else
			minDistance = dist
		end
	end

	if minDistance == nil then
		minDistance = distance({x = 0, y = 0},{x = regionX, y = regionY})
	end

	return minDistance
end


-- modifies the resource size - only used in endless_resource_mode
local function modify_resource_size(resourceName, resourceSize, startingArea)
	
	if not startingArea then
		resourceSize = math.ceil(resourceSize * settings.global["rso-global-size-mult"].value)
	end
	
	local resourceEntity = game.entity_prototypes[resourceName]
	if resourceEntity and resourceEntity.infinite_resource then
		
		newResourceSize = resourceSize * endless_resource_mode_sizeModifier
		
		-- make sure it's still an integer
		newResourceSize = math.ceil(newResourceSize)
		-- make sure it's not 0
		if newResourceSize == 0 then newResourceSize = 1 end
		return newResourceSize
	else
		return resourceSize
	end
end

--[[ SPAWN METHODS ]]--

local locationOrder =
{
	{ x = 0, y = 0 },
	{ x = -1, y = 0 },
	{ x = 1, y = 0 },
	{ x = 0, y = -1 },
	{ x = 0, y = 1 },
	{ x = -1, y = -1 },
	{ x = 1, y = -1 },
	{ x = -1, y = 1 },
	{ x = 1, y = 1 }
}

--[[ entity-field ]]--
local function spawn_resource_ore(surface, rname, pos, size, richness, startingArea, restrictions, rng)
	-- blob generator, centered at pos, size controls blob diameter
	restrictions = restrictions or ''
	debug("Entering spawn_resource_ore "..rname.." at:"..pos.x..","..pos.y.." size:"..size.." richness:"..richness.." isStart:"..tostring(startingArea).." restrictions:"..restrictions)
	
	size = modify_resource_size(rname, size, startingArea)
	local radius = size / 2 -- to radius
	
	local p_balls={}
	local n_balls={}
	local MIN_BALL_DISTANCE = math.min(MIN_BALL_DISTANCE, radius/2)
	
	local maxPradius = 0	
	local outside = { xmin = 1e10, xmax = -1e10, ymin = 1e10, ymax = -1e10 }
	local inside = { xmin = 1e10, xmax = -1e10, ymin = 1e10, ymax = -1e10 }
	
	local function updateRect(rect, x, y, radius)
		rect.xmin = math.min(rect.xmin, x - radius)
		rect.xmax = math.max(rect.xmax, x + radius)
		rect.ymin = math.min(rect.ymin, y - radius)
		rect.ymax = math.max(rect.ymax, y + radius)
	end

	local function updateRects(x, y, radius, scaleX, scaleY)
		local radiusMax = radius * 3 -- arbitrary multiplier - needs to be big enough to not cut any metaballs
		updateRect(outside, x, y, radiusMax)
		updateRect(inside, x, y, radius)
	end
	
	local function roundRect( rect )
		rect.xmin = round( rect.xmin )
		rect.xmax = round( rect.xmax )
		rect.ymin = round( rect.ymin )
		rect.ymax = round( rect.ymax )
	end

	local function generate_p_ball(rng)
		local angle, x_scale, y_scale, x, y, b_radius, shape
		angle, x_scale, y_scale=rng_restricted_angle(restrictions, rng)
		local dev = radius / 2 + rng() * radius / 4--math.min(CHUNK_SIZE/3, radius*1.5)
		local dev_x, dev_y = pos.x, pos.y
		x = rng(-dev, dev)+dev_x
		y = rng(-dev, dev)+dev_y
		if p_balls[#p_balls] and distance(p_balls[#p_balls], {x=x, y=y}) < MIN_BALL_DISTANCE then
			local new_angle = bearing(p_balls[#p_balls], {x=x, y=y})
			debug("Move ball old xy @ "..x..","..y)
			x=(cos(new_angle)*MIN_BALL_DISTANCE) + x
			y=(sin(new_angle)*MIN_BALL_DISTANCE) + y
			debug("Move ball new xy @ "..x..","..y)
		end
		
		if #p_balls == 0 then
			b_radius = ( 3 * radius / 4 + rng() * radius / 4) -- * (P_BALL_SIZE_FACTOR^#p_balls)
		else
			b_radius = ( radius / 4 + rng() * radius / 2) -- * (P_BALL_SIZE_FACTOR^#p_balls)
		end
		
		
		if #p_balls > 0 then
			local tempRect = table.deepcopy(inside)
			updateRect(tempRect, x, y, b_radius, x_scale, y_scale)
			local rectSize = math.max(tempRect.xmax - tempRect.xmin, tempRect.ymax - tempRect.ymin)
			local targetSize = size * 1.25
			debug("Rect size "..rectSize.." targetSize "..targetSize)
			if rectSize > targetSize then
				local widthLeft = (targetSize - (inside.xmax - inside.xmin))
				local heightLeft = (targetSize - (inside.ymax - inside.ymin))
				local widthMod = math.min(x - inside.xmin, inside.xmax - x)
				local heightMod = math.min(y - inside.ymin, inside.ymax - y)
				local radiusBackup = b_radius
				b_radius = math.min(widthLeft + widthMod, heightLeft + heightMod)
				debug("Reduced ball radius from "..radiusBackup.." to "..b_radius.." widthLeft:"..widthLeft.." heightLeft:"..heightLeft.." widthMod:"..widthMod.." heightMod:"..heightMod)
			end
		end

		if b_radius < 2 and #p_balls == 0 then
			b_radius = 2
		end
		
		if b_radius > 0 then
			
			maxPradius = math.max(maxPradius, b_radius)
			shape = meta_shapes[rng(1,#meta_shapes)]
			local radiusText = ""
--			log("Index rolled "..index.." shapes amount "..#meta_shapes)
			if shape.type == "MetaDonut" then
				local inRadius = b_radius / 4 + b_radius / 2 * rng()
				radiusText = " inRadius:"..inRadius
				p_balls[#p_balls+1] = shape:new(x, y, b_radius, inRadius, angle, x_scale, y_scale, 1.1)
			else
				p_balls[#p_balls+1] = shape:new(x, y, b_radius, angle, x_scale, y_scale, 1.1)
			end
			updateRects(x, y, b_radius, x_scale, y_scale)
		
			debug("P+Ball "..shape.type.." @ "..x..","..y.." radius: "..b_radius..radiusText.." angle: "..math.deg(angle).." scale: "..x_scale..", "..y_scale)
		end
	end
	
	local function generate_n_ball(i, rng)
		local angle, x_scale, y_scale, x, y, b_radius, shape
		angle, x_scale, y_scale=rng_restricted_angle('xy', rng)
		if p_balls[i] then
			local new_angle = p_balls[i].angle + pi*rng(0,2) + (rng()-0.5)*pi/2
			local dist = p_balls[i].radius
			x=(cos(new_angle)*dist) + p_balls[i].x
			y=(sin(new_angle)*dist) + p_balls[i].y
			angle = p_balls[i].angle + pi/2 + (rng()-0.5)*pi*2/3
		else
			x = rng(-radius, radius)+pos.x
			y = rng(-radius, radius)+pos.y
		end
		
		if p_balls[i] then
			b_radius = (p_balls[i].radius / 4 + rng() * p_balls[i].radius / 2) -- * (N_BALL_SIZE_FACTOR^#n_balls)
		else
			b_radius = (radius / 4 + rng() * radius / 2) -- * (N_BALL_SIZE_FACTOR^#n_balls)
		end
		
		if b_radius < 1 then
			b_radius = 1
		end
		
		shape = meta_shapes[rng(1,#meta_shapes)]
--		log("Index rolled "..index.." shapes amount "..#meta_shapes)
		local radiusText = ""
		if shape.type == "MetaDonut" then
			local inRadius = b_radius / 4 + b_radius / 2 * rng()
			radiusText = " inRadius:"..inRadius
			n_balls[#n_balls+1] = shape:new(x, y, b_radius, inRadius, angle, x_scale, y_scale, 1.15)
		else
			n_balls[#n_balls+1] = shape:new(x, y, b_radius, angle, x_scale, y_scale, 1.15)
		end
		-- updateRects(x, y, b_radius, x_scale, y_scale) -- should not be needed here - only positive ball can generate ore
		debug("N-Ball "..shape.type.." @ "..x..","..y.." radius: "..b_radius..radiusText.." angle: "..math.deg(angle).." scale: "..x_scale..", "..y_scale)
	end
	
	local function calculate_force(x,y)
		local p_force = 0
		local n_force = 0
		for _,ball in pairs(p_balls) do
			p_force = p_force + ball:force(x,y)
		end
		for _,ball in pairs(n_balls) do
			n_force = n_force + ball:force(x,y)
		end
		local totalForce = 0
		if p_force > n_force then
			totalForce = 1 - 1/(p_force - n_force)
		end
		--debug("Force at "..x..","..y.." p:"..p_force.." n:"..n_force.." result:"..totalForce)
		--return (1 - 1/p_force) - n_force
		return totalForce
	end  
	
	local max_p_balls = 2
	local min_amount = global.surfaces[surface.index].config[rname].min_amount or min_amount
	if restrictions == 'xy' then
		-- we have full 4 chunks
		--radius = radius * 1.5
		--richness = richness * 2 / 3
		--min_amount = min_amount / 3
		max_p_balls = 3
	end

	radius = math.min(radius, 2*CHUNK_SIZE)

	local force
	-- generate blobs
	for i=1,max_p_balls do
		generate_p_ball(rng)
	end
	
	for i=1,rng(1, #p_balls) do
		generate_n_ball(i, rng)
	end
	
	local _total = 0
	local oreLocations = {}
	local forceTotal = 0
	
	roundRect( outside )

	for y=outside.ymin, outside.ymax do
		for x=outside.xmin, outside.xmax do
			force = calculate_force(x, y)
			if force > 0 then
				oreLocations[#oreLocations + 1] = {x = x, y = y, force = force}
				forceTotal = forceTotal + force
			end
		end
	end

	local validCount, resOffsetX, resOffsetY, ratio

	local bestRatio = 0
	local bestRatioIndex = -1
	local checkedLocations = {}
	
	for index, locationOffset in pairs(locationOrder) do
		validCount = 0
		resOffsetX = locationOffset.x * CHUNK_SIZE
		resOffsetY = locationOffset.y * CHUNK_SIZE
		
		for _, location in pairs(oreLocations) do
			
			local newX = location.x + resOffsetX
			local newY = location.y + resOffsetY

			if not checkedLocations[newX] then
				checkedLocations[newX] = {}
			end
			if checkedLocations[newX][newY] == nil then
				checkedLocations[newX][newY] = surface.can_place_entity{name = rname, position = {x = newX,y = newY}}
			end
			
			if checkedLocations[newX][newY] then
				validCount = validCount + 1
			end
		end
		
		ratio = 0
		
		if validCount > 0 then
			ratio = validCount / #oreLocations
		end
		
		debug("Valid ratio "..ratio.." for index "..index.." offsets "..resOffsetX..","..resOffsetY	)
		
		if not useResourceCollisionDetection then
			break
		end
		
		if ratio > bestRatio then
			bestRatio = ratio
			bestRatioIndex = index
		end
		if ratio > resourceCollisionDetectionRatio then
			break
		end
	end
	
	if resourceCollisionFieldSkip and bestRatio < resourceCollisionDetectionRatioFallback then
		validCount = 0
		debug("Cancelled with best ratio "..bestRatio.." for index "..bestRatioIndex )
	else
		resOffsetX = locationOrder[bestRatioIndex].x * CHUNK_SIZE
		resOffsetY = locationOrder[bestRatioIndex].y * CHUNK_SIZE
		validCount = floor( bestRatio * #oreLocations )
		debug("Selected ratio "..bestRatio.." for index "..bestRatioIndex.." offsets "..resOffsetX..","..resOffsetY	)
	end

	if validCount > 0 then
		local removeTrees = settings.global["rso-remove-trees"].value
		local revealResources = settings.global["rso-reveal-spawned-resources"].value
		local revealChunks = {}
		revealChunks.minX = 1e9
		revealChunks.minY = 1e9
		revealChunks.maxX = -1e9
		revealChunks.maxY = -1e9
		
		local rectSize = ((inside.xmax - inside.xmin) + (inside.ymax - inside.ymin)) / 2

		local sizeMultiplier = rectSize ^ 0.6
		local minSize = richness * 5 * sizeMultiplier
		local maxSize = richness * 10 * sizeMultiplier
		local approxDepositSize = rng(minSize, maxSize)

		approxDepositSize = approxDepositSize - validCount * min_amount
		
		if approxDepositSize < 0 then
			approxDepositSize = 100 * validCount
		end

		local forceFactor = approxDepositSize / forceTotal

		-- don't create very dense resources in starting area - another field will be generated
		if startingArea and forceFactor > 4000 then
			forceFactor = rng(3000, 4000)
		end
--		elseif forceFactor > 25000 then -- limit size of one resource pile
--			forceFactor = rgen:random(20000, 25000)
--		end

		debug( "Force total:"..forceTotal.." sizeMin:"..minSize.." sizeMax:"..maxSize.." factor:"..forceFactor.." location#:"..validCount.." rectSize:"..rectSize.." sizeMultiplier:"..sizeMultiplier)
		local richnessMultiplier = settings.global["rso-global-richness-mult"].value
		
		if startingArea then
			richnessMultiplier = settings.global["rso-starting-richness-mult"].value
		end
--		if game.players[1] then
--			game.players[1].print("Spawning "..rname.." total amount "..(approxDepositSize + validCount * min_amount)*richnessMultiplier)
--		end
		
		-- infinite ore handling for Angels Ores mod
		local infiniteOrePresent = false
		local infiniteOreName = "infinite-"..rname
		local minimumInfiniteOreAmount = nil
		local spawnName = rname

		if game.entity_prototypes[infiniteOreName] then
			infiniteOrePresent = true
			minimumInfiniteOreAmount = game.entity_prototypes[infiniteOreName].minimum_resource_amount
		end
		
		if startingArea and not settings.global["rso-infinite-ores-in-start-area"].value then
			infiniteOrePresent = false
		end

		local infiniteResourceSpawnThreshold = settings.global["rso-infinite-ore-threshold"].value
		
		for _,location in pairs(oreLocations) do
	
			local spawnX = location.x + resOffsetX
			local spawnY = location.y + resOffsetY
	
			if checkedLocations[spawnX][spawnY] then
				
				local amount = floor(( forceFactor * location.force + min_amount ) * richnessMultiplier)
				
				if amount > 1e9 then
					amount = 1e9
				end
				
				_total = _total + amount
				
				spawnName = rname
				if infiniteOrePresent and location.force > infiniteResourceSpawnThreshold then
					spawnName = infiniteOreName
					if minimumInfiniteOreAmount and amount <  minimumInfiniteOreAmount then
						amount = minimumInfiniteOreAmount
					end
--					debug("Infinite spawn: "..location.force)
				end
				
				if amount > 0 then
					surface.create_entity{name = spawnName,
						position = {spawnX, spawnY},
						force = game.forces.neutral,
						amount = amount,
						raise_built = true}

					if removeTrees then
						remove_trees(surface, spawnX, spawnY, 1, 1)
					end

					revealChunks.minX = math.min( revealChunks.minX, spawnX )
					revealChunks.minY = math.min( revealChunks.minY, spawnY )
					revealChunks.maxX = math.max( revealChunks.maxX, spawnX )
					revealChunks.maxY = math.max( revealChunks.maxY, spawnY )
				end
			end
		end
		
		if revealResources then
			for _,force in pairs( game.forces )do
				force.chart( surface, {{x = revealChunks.minX, y = revealChunks.minY}, {x = revealChunks.maxX, y = revealChunks.maxY}})
			end
		end

		-- special handling for homeworld - sand resource has no graphics and is simply marked as sand tiles
		if rname == "sand-source" then
			local tileTable = {}
			for _,location in pairs(oreLocations) do
				if location.valid then
					table.insert(tileTable,{ name = "sand-1", position = {location.x + resOffsetX,location.y + resOffsetY}})
				end
			end
			if #tileTable > 1 then
				surface.set_tiles(tileTable)
			end
		end
	end
	
	if debug_enabled then
--		debug("Search time "..scanProfiler.." spawn time "..placeProfiler)
		debug("Total amount: ".._total)
--*		for _,v in pairs(_a) do
			--output a nice ASCII map
--*			debug(table.concat(v))
--*		end
		debug("Leaving spawn_resource_ore")
	end
	return _total
end

--[[ entity-liquid ]]--
local function spawn_resource_liquid(surface, rname, pos, size, richness, startingArea, restrictions, rng)
	restrictions = restrictions or ''
	debug("Entering spawn_resource_liquid "..rname.." "..pos.x..","..pos.y.." "..size.." "..richness.." "..tostring(startingArea).." "..restrictions)
	local _total = 0
	local max_radius = rng() * CHUNK_SIZE / 2 + CHUNK_SIZE
	--[[
		if restrictions == 'xy' then
		-- we have full 4 chunks
		max_radius = floor(max_radius*1.5)
		size = floor(size*1.2)
		end
	]]--
	-- don't reduce amount of liquids - they are already infinite
	--  size = modify_resource_size(size)
	
	richness = ( 0.75 + rng() / 2 ) * richness * size
	
	local resourceEntity = game.entity_prototypes[rname]
	
	local total_share = 0
	local avg_share = 1/size
	local angle = rng()*pi*2
	local saved = 0
	local removeTrees = settings.global["rso-remove-trees"].value
	local richnessMultiplier = settings.global["rso-global-richness-mult"].value
	local spawnCount = 0

	if startingArea then
		richnessMultiplier = settings.global["rso-starting-richness-mult"].value
	end

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
			-- too small
			break 
		end
		local amount = floor(richness*new_share) + saved
		
		--if amount >= game.entity_prototypes[rname].minimum then 
		if amount >= global.surfaces[surface.index].config[rname].minimum_amount then 
			saved = 0
			
			local spawned = false
			local x, y
			
			for try=1,15 do
				local dist = rng()*(max_radius - max_radius*0.1) * try / 15
				angle = angle + pi/4 + rng()*pi/2
				x = pos.x + cos(angle)*dist
				y = pos.y + sin(angle)*dist
				if surface.can_place_entity{name = rname, position = {x,y}} then
					debug("@ "..x..","..y.." amount: "..amount.." new_share: "..new_share.." try: "..try)
					amount = floor(amount * richnessMultiplier)
					
					if amount > 1e9 then
						amount = 1e9
					end
					
					_total = _total + amount
					
					if amount > 0 then
						surface.create_entity{name = rname,
							position = {x,y},
							force = game.forces.neutral,
							amount = amount,
							direction = rng(4),
							raise_built = true}
						if removeTrees then
							remove_trees(surface, x, y, 4, 4)
						end
					end
					
					if spawnCount == 0 then
						debug("Switched center location to "..x..","..y)
						pos.x = x
						pos.y = y
					end
					
					spawnCount = spawnCount + 1
					spawned = true
					break
				end
			end
			
			if not startingArea and not spawned then -- we don't want to make ultra rich nodes in starting area - failing to make them will add second spawn in different location
				local entities = surface.find_entities_filtered{area = {{x - 5, y - 5}, {x + 5, y + 5}}, name=rname}
				if entities and #entities > 0 then
					for k, ent in pairs(entities) do
						local newAmount = ent.amount + floor(amount/#entities)
						if newAmount > 1e9 then
							newAmount = 1e9
						end
						
						ent.amount = newAmount
						_total = _total + newAmount
					end
					break
				end
			end
		else
			saved = amount
			debug("Not placed "..rname.." amount "..amount.." minimum "..global.surfaces[surface.index].config[rname].minimum_amount.. " total share "..total_share.." placed till now ".._total)
		end
	end
	debug("Total amount: ".._total.." in "..spawnCount.." fields")
	debug("Leaving spawn_resource_liquid")
	return _total
end

local spawnerTable = nil

local function initSpawnerTable()
	if spawnerTable == nil then	
		spawnerTable = {}
		for _, prototype in pairs(game.entity_prototypes) do
			if prototype.type == "unit-spawner" then
				spawnerTable[prototype.name] = prototype
			end
		end
--		log("Spawner table "..serpent.block(spawnerTable))
	end
end

local function computeAllotments(entityTable, regionDistance)
	
	local allotment_max = 0
	
	if not entityTable then
		return allotment_max
	end
	
	for k,v in pairs(entityTable) do
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
				v.allotment_range ={min = allotment_max, max = allotment_max + allotment}
				allotment_max = allotment_max + allotment
			else
				v.allotment_range = nil
			end 
		end
	end
	
	return allotment_max
end

local function spawn_entity_helper(surface, prototype, x, y, config)
	position = {x, y}
	local collides = surface.entity_prototype_collides(prototype, position, true)
	if collides then 
		remove_trees_based_on_bb(surface, x, y, prototype.map_generator_bounding_box)
	end
	
	collides = surface.entity_prototype_collides(prototype, position, true)
	
	if not collides then
		surface.create_entity{name=prototype.name, position={x, y}, force=game.forces[config.force], spawn_decorations=true, raise_built = true}
	end
	
	return not collides
end

local function spawn_entity(surface, ent, r_config, x, y, rng)
	if not settings.global["rso-biter-generation"].value then return end
	local size = rng(r_config.size.min, r_config.size.max)
	
	local _total = 0
	local r_distance = distanceFromStartingAreas(global.surfaces[surface.index], x/REGION_TILE_SIZE, y/REGION_TILE_SIZE)  
	local surfaceData = global.surfaces[surface.index]
	
	if surfaceData and surfaceData.starting_area_size then
		r_distance = r_distance - surfaceData.starting_area_size
		if r_distance < 0.5 then
			r_distance = 0.5
		end
	end
	
	local distanceMultiplier = math.min(r_distance^r_config.size_per_region_factor, 5)
	if r_config.size_per_region_factor then
		size = size*distanceMultiplier
	end
	
	size = size * settings.global["rso-enemy-base-size"].value
	
	debug("Entering spawn_entity "..ent.." "..x..","..y.." size:"..size.." dist:"..r_distance)
	
	local maxAttemptCount = 16
	local distancePerBatch = 0.25
	
	initSpawnerTable()

	local spawnerName = nil
	local spawnString = ""
	local failCount = 0

	for i=1,size do
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

				spawnerName = nil
				local allotment_max = computeAllotments(r_config.bases, r_distance)
				
				if allotment_max == 0 then
					log("No enemy base definition found")
					return
				end
				
				local base_type = rng(0, allotment_max)
				for base_name,v in pairs(r_config.bases) do
					if v and v.allotment_range and base_type >= v.allotment_range.min and base_type <= v.allotment_range.max then
						spawnerName = base_name
						break
					end
				end
				
				if spawnerName and spawnerTable[spawnerName] then
					if spawn_entity_helper(surface, spawnerTable[spawnerName], baseX, baseY, r_config) then
						_total = _total + 1
						debug(spawnerName.." @ "..baseX..","..baseY.." placed on "..attempt.." attempt")
						spawnString = spawnString.."+"
						baseSpawned = true
						break;
					else
						if attempt == maxAttemptCount then
							debug(spawnerName.." @ "..baseX..","..baseY.." failed to spawn")
							failCount = failCount + 1
							spawnString = spawnString.."-"
						end
					end
				else
					game.players[1].print("Entity "..spawnerName.." doesn't exist")
				end
			end
		end
			
		if r_config.sub_spawn_probability and baseSpawned then
			local sub_spawn_prob = r_config.sub_spawn_probability*math.min(r_config.sub_spawn_max_distance_factor, r_config.sub_spawn_distance_factor^r_distance)
			if rng() < sub_spawn_prob then

				local allotment_max = computeAllotments(r_config.sub_spawns, r_distance)
				
				for i=1,(rng(r_config.sub_spawn_size.min, r_config.sub_spawn_size.max)*distanceMultiplier) do
					
					local sub_type = rng(0, allotment_max)
					for sub_spawn,v in pairs(r_config.sub_spawns) do
						if v.allotment_range and sub_type >= v.allotment_range.min and sub_type <= v.allotment_range.max then
							local turretPrototype = game.entity_prototypes[sub_spawn]
							if turretPrototype then
								for attempt = 1, maxAttemptCount do
									local max_d = floor((attempt/4) * CHUNK_SIZE * distancePerBatch)
									local s_x = baseX + rng(max_d) - max_d/2
									local s_y = baseY + rng(max_d) - max_d/2
									remove_trees(surface, s_x, s_y, v.clear_range[1], v.clear_range[2])
									if spawn_entity_helper(surface, turretPrototype, s_x, s_y, r_config) then
										debug("Rolled subspawn "..sub_spawn.." @ "..s_x..","..s_x.." after "..attempt.." attempts")
										break;
									else
										if attempt == maxAttemptCount then
											debug("Rolling subspawn "..sub_spawn.." @ "..s_x..","..s_x.." failed")
										end
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
	
	debug("Total entity amount: ".._total.." fails "..failCount.." size "..size.." spawn map "..spawnString)
end

--[[ EVENT/INIT METHODS ]]--

local function spawn_starting_resources( surface, index )
	
	local surfaceData = global.surfaces[surface.index]
	if surfaceData.startingAreas[index].spawned then return end
	
	-- skip spawning if starting area is to small or starting areas are disabled
	if global.disableStartingArea or surfaceData.starting_area_size < 0.1 then
		surfaceData.startingAreas[index].spawned = true
		return
	end
	
	local position = surfaceData.startingAreas[index]
	local config = surfaceData.config

	-- generate chunks for starting area - it shouldn't matter at 0,0 but it's needed if it has been moved
	local areaRadius = surfaceData.starting_area_size * REGION_TILE_SIZE
	surface.request_to_generate_chunks(position, math.ceil(areaRadius/CHUNK_SIZE))
	surface.force_generate_chunk_requests()

	local rng = rng_for_reg_pos( surface.index, position )
	local status = true
	for resName,resConfig in pairs(config) do
		if resConfig.starting and resConfig.valid and resConfig.allotment > 0 then 
			local prob = rng() -- probability that this resource is spawned
			debug("starting resource probability rolled "..prob)
			if resConfig.starting.probability > 0 and prob <= resConfig.starting.probability then
				local total = 0
				local radius = 50
				local maxRadius = 301
				maxRadius = maxRadius * surface.map_gen_settings.starting_area
				local min_threshold = 0
				local richness = resConfig.starting.richness
				
				if resConfig.type == "resource-ore" then
					min_threshold = richness * rng(5, 10) -- lets make sure that there is at least 5-10 times starting richness ore at start
				elseif resConfig.type == "resource-liquid" then
					min_threshold = richness * 0.5 * resConfig.starting.size
				end
				
				while (radius < maxRadius) and (total < min_threshold) do
				
					radius = radius + 25
				
					local angle = rng() * pi * 2
					local dist = radius / 2 + rng(radius / 2)
--					debug("Starting offset "..dist.." at "..angle)
					local pos = { x = floor(cos(angle) * dist) + position.x, y = floor(sin(angle) * dist) + position.y }
					if resConfig.type == "resource-ore" then
						total = total + spawn_resource_ore(surface, resName, pos, resConfig.starting.size, richness, true, null, rng)
					elseif resConfig.type == "resource-liquid" then
						total = total + spawn_resource_liquid(surface, resName, pos, resConfig.starting.size, richness, true, null, rng)
					end
					
					if richness == resConfig.starting.richness and total > 0 then
						richness = resConfig.starting.richness / 4
					end
				end
				if total < min_threshold then
					status = false
				end
			end
		end
	end

	surfaceData.startingAreas[index].spawned = true
end

local function modifyMinMax(value, mod)
	value.min = round( value.min * mod )
	value.max = round( value.max * mod )
end

local function build_config_data(surface)
	local mapGenSettings = nil
	
	if not ignoreMapGenSettings then
		mapGenSettings = surface.map_gen_settings
	end
	local autoPlaceSettings = nil
	if mapGenSettings then
		autoPlaceSettings = mapGenSettings.autoplace_controls
	end
	
	local configIndexed = {}
	local surfaceData = global.surfaces[surface.index]
	local config = surfaceData.config
	
	debug("Building config for " .. surface.name .. " index " .. surface.index)
	-- build additional indexed array to the associative array
	for res_name, resConf in pairs(config) do
		if resConf.valid then -- only add valid resources
		
			local settingsForResource = nil
			local isEntity = (resConf.type == "entity")
			local addResource = true
			
			local autoplaceName = res_name
			
			if resConf.autoplace_name then
				autoplaceName = resConf.autoplace_name
			end
			
			if autoPlaceSettings then
				settingsForResource = autoPlaceSettings[autoplaceName]
			end

			if settingsForResource then
				local allotmentMod = settingsForResource.frequency
				local sizeMod = settingsForResource.size
				local richnessMod = settingsForResource.richness
				
				if allotmentMod then
					if isEntity then
						resConf.absolute_probability = resConf.absolute_probability * allotmentMod
						debug("Entity chance modified to "..resConf.absolute_probability)
					else
						resConf.allotment = round( resConf.allotment * allotmentMod )
					end
				else
					log("Null allotment mod for "..res_name.." value "..settingsForResource.frequency)
				end

				if sizeMod ~= nil and sizeMod == 0 then
					addResource = false
					--log("Null size mod for "..res_name.." value "..settingsForResource.size)
				end

				if sizeMod ~= nil then
					modifyMinMax(resConf.size, sizeMod)
					
					if resConf.starting then
						if sizeMod == 0 then
							resConf.starting = nil
						else
							resConf.starting.size = round( resConf.starting.size * sizeMod )
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
						resConf.richness = round( resConf.richness * richnessMod )
					elseif resConf.type == "resource-liquid" then
						modifyMinMax(resConf.richness, richnessMod)
					end
					
					if resConf.starting then
						resConf.starting.richness = round( resConf.starting.richness * richnessMod )
					end
				else
					log("Null richness mod for "..res_name.." value "..settingsForResource.richness)
				end
				
				if allotmentMod and richnessMod and sizeMod then
					debug(res_name .. " allotment mod " .. allotmentMod .. " size mod " .. sizeMod .. " richness mod " .. richnessMod )
				end
			end
			
			if not settings.global["rso-oil-in-start-area"].value and resConf.type == "resource-liquid" then
				resConf.starting = nil
			end
			
			if not settings.global["rso-ore-in-start-area"].value and resConf.type == "resource-ore" then
				resConf.starting = nil
			end
			
			if addResource then
				-- this should be a limited table most likely not full config copy
				local res_conf = table.deepcopy(resConf)
				res_conf.name = res_name
				
				if res_conf.multi_resource and settings.global["rso-multi-resource-active"].value then
					local new_list = {}
					for sub_res_name, allotment in pairs(res_conf.multi_resource) do
						if config[sub_res_name] and config[sub_res_name].valid then
							new_list[#new_list+1] = {name = sub_res_name, allotment = allotment}
						end
					end
					table.sort(new_list, function(a, b) return a.name < b.name end)
					res_conf.multi_resource = new_list
				else
					res_conf.multi_resource_chance = nil
				end
				configIndexed[#configIndexed + 1] = res_conf
			end
		end
	end
	
	table.sort(configIndexed, function(a, b) return a.name < b.name end)
	
	local pr=0
	local maxAllotment = 0
	for index,v in pairs(configIndexed) do
		if v.along_resource_probability then  
			v.along_resource_probability_range={min=pr, max=pr+v.along_resource_probability}
			pr = pr + v.along_resource_probability
		end
		if v.allotment and v.allotment > 0 then
			v.allotment_range={min = maxAllotment, max = maxAllotment + v.allotment}
			maxAllotment = maxAllotment + v.allotment
		end
	end
	
	surfaceData.maxAllotment = maxAllotment
	surfaceData.starting_area_size = starting_area_size

	if mapGenSettings and mapGenSettings.starting_area then
		surfaceData.starting_area_size = starting_area_size * mapGenSettings.starting_area
		debug("Starting area "..surfaceData.starting_area_size.." for surface "..surface.index)
	end
	
	surfaceData.configIndexed = configIndexed
end

local function checkConfigForInvalidResources(surfaceIndex)
	--make sure that every resource in the config is actually available.
	--call this function, before the auxiliary config is prebuilt!
	
	local prototypes = game.entity_prototypes
	local config = global.surfaces[surfaceIndex].config
	
	for resourceName, resourceConfig in pairs(config) do
		if prototypes[resourceName] or resourceConfig.type == "entity" then
			resourceConfig.valid = true
		else
			-- resource was in config, but it doesn't exist in game files anymore - mark it invalid
			resourceConfig.valid = false
			
			--table.insert(invalidResources, "Resource not available: " .. resourceName)
			debug("Resource not available: " .. resourceName)
			log("Resource not available: " .. resourceName)
		end
		
		if resourceConfig.valid and resourceConfig.type ~= "entity" then
 			if prototypes[resourceName].autoplace_specification == nil then
				resourceConfig.valid = false
				debug("Resource "..resourceName.." invalidated - autoplace not present")
			end
		end
	end
end

local function checkForBobEnemies()
	if game.entity_prototypes["bob-biter-spawner"] and game.entity_prototypes["bob-spitter-spawner"] then
		global.useBobEntity = true
	else
		global.useBobEntity = false
	end
end

local function roll_region(surface, c_x, c_y)
	--in what region is this chunk?
	local r_x=floor(c_x/REGION_TILE_SIZE)
	local r_y=floor(c_y/REGION_TILE_SIZE)
	local r_data = nil
	--don't spawn stuff in starting area
	if isInStartingArea( surface.index, c_x, c_y ) then
		return false
	end

	local surfaceData = global.surfaces[surface.index]
	local configIndexed = surfaceData.configIndexed
	local regions = surfaceData.regions
	
	if regions[r_x] and regions[r_x][r_y] then
		r_data = regions[r_x][r_y]
	else
		--if this chunk is the first in its region to be generated
		if not regions[r_x] then regions[r_x] = {} end
		regions[r_x][r_y]={}
		r_data = regions[r_x][r_y]
		local rng = rng_for_reg_pos(surface.index, {x=r_x,y=r_y})
		
		local rollCount = math.ceil(#configIndexed / 10) - 1 -- 0 based counter is more convenient here
		rollCount = math.min(rollCount, 3)
		
		local resourceSetting = settings.global["rso-resource-chance"].value
		
		local maxAllotment = surfaceData.maxAllotment
		
		-- rolle ores only if they are present (it will fail if allotment is 0)
		if maxAllotment > 0 then
			for rollNumber = 0,rollCount do
			
				local resourceChance = resourceSetting - rollNumber * 0.1
				--absolute chance to spawn resource
				local abct = rng()
				debug("Rolling resource "..abct.." against "..resourceChance.." roll "..rollNumber)
				if abct <= resourceChance then
					local res_type=rng(1, maxAllotment)
					for index,v in pairs(configIndexed) do
						if v.allotment_range and ((res_type >= v.allotment_range.min) and (res_type <= v.allotment_range.max)) then
							debug("Rolled primary resource "..v.name.." with roll="..res_type.." @ "..r_x..","..r_y)
							local num_spawns = 0
							if v.spawns_per_region.min == v.spawns_per_region.max then
								num_spawns = v.spawns_per_region.min
							else
								num_spawns = rng(v.spawns_per_region.min, v.spawns_per_region.max)
							end
							local last_spawn_coords = {}
							local along_
							for i=1,num_spawns do
								local c_x, c_y = find_random_chunk(r_x, r_y, rng)
								
								-- even if initial chunk is outside region might overlap with starting area - need to recheck here if rolled coords are outside
								if not isInStartingArea( surface.index, c_x, c_y ) then
									if not r_data[c_x] then r_data[c_x] = {} end
									if not r_data[c_x][c_y] then r_data[c_x][c_y] = {} end
									local c_data = r_data[c_x][c_y]
									c_data[#c_data+1]={v.name, rollNumber}
									last_spawn_coords[#last_spawn_coords+1] = {c_x, c_y}
									debug("Rolled primary chunk "..v.name.." @ "..c_x..","..c_y.." reg: "..r_x..","..r_y.." actual reg: "..floor(c_x/REGION_TILE_SIZE)..","..floor(c_y/REGION_TILE_SIZE))
									-- Along resource spawn, only once
									if i == 1 then
										local am_roll = rng()
										for index,vv in pairs(configIndexed) do
											if vv.along_resource_probability_range and am_roll >= vv.along_resource_probability_range.min and am_roll <= vv.along_resource_probability_range.max then
												c_data = r_data[c_x][c_y]
												c_data[#c_data+1]={vv.name, rollNumber}
												debug("Rolled along "..vv.name.." @ "..c_x.."."..c_y.." reg: "..r_x..","..r_y)
											end
										end
									end
								end
							end
							-- roll multiple resources in same region
							local deep=0
							if #last_spawn_coords > 0 then
								while v.multi_resource_chance and rng() <= v.multi_resource_chance*(multi_resource_chance_diminish^deep) do
									debug("Multi roll chance "..v.multi_resource_chance.." with diminish chance "..v.multi_resource_chance*(multi_resource_chance_diminish^deep))
									deep = deep + 1
									local multiAllotmentMax = 0
									for index,sub_res in pairs(v.multi_resource) do multiAllotmentMax = multiAllotmentMax + sub_res.allotment end
									
									local res_type = 1 -- with allotment of 1 we don't need to roll rng and rng will complain when it's range is 0
									if multiAllotmentMax > 1 then
										res_type = rng(1, multiAllotmentMax)
									end
									local min=0
									for _, sub_res in pairs(v.multi_resource) do
										if (res_type >= min) and (res_type <= sub_res.allotment + min) then
											local last_coords = last_spawn_coords[rng(1, #last_spawn_coords)]
											local c_x, c_y = find_random_neighbour_chunk(last_coords[1], last_coords[2], rng) -- in same region as primary resource chunk
											if not r_data[c_x] then r_data[c_x] = {} end
											if not r_data[c_x][c_y] then r_data[c_x][c_y] = {} end
											local c_data = r_data[c_x][c_y]
											c_data[#c_data+1]={sub_res.name, deep}
											debug("Rolled multiple "..sub_res.name..":"..deep.." with res_type="..res_type.." @ "..c_x..","..c_y.." reg: "..r_x..","..r_y)
											break
										else
											min = min + sub_res.allotment
										end
									end
								end
							end
							break
						end
					end
					
				end
			end
		end
		
		-- roll for absolute_probability - this rolls the enemies
		for index,v in pairs(configIndexed) do
			if v.absolute_probability then
				local prob_factor = 1 
				if v.probability_distance_factor then 
					prob_factor = math.min(v.max_probability_distance_factor, v.probability_distance_factor^distance({x=0,y=0},{x=r_x,y=r_y}))
				end 
				local abs_roll = rng()
				if abs_roll<v.absolute_probability*prob_factor then
					local num_spawns=rng(v.spawns_per_region.min, v.spawns_per_region.max)
					for i=1,num_spawns do
						local c_x, c_y = find_random_chunk(r_x, r_y, rng)
						if not isInStartingArea( surface.index, c_x, c_y ) then
							if not r_data[c_x] then r_data[c_x] = {} end
							if not r_data[c_x][c_y] then r_data[c_x][c_y] = {} end
							local c_data = r_data[c_x][c_y]
							c_data[#c_data+1] = {v.name, 1}
							debug("Rolled absolute "..v.name.." with rt="..abs_roll.." @ "..c_x..","..c_y.." reg: "..r_x..","..r_y)
						end
					end
				end
			end
		end
	
	end
	
end

local function roll_chunk(surface, c_x, c_y)
	--handle spawn in chunks
	local r_x=floor(c_x/REGION_TILE_SIZE)
	local r_y=floor(c_y/REGION_TILE_SIZE)
	local r_data = nil

	debug("Entering roll chunk "..c_x..","..c_y.." reg: "..r_x..","..r_y)

	--don't spawn stuff in starting area
	if isInStartingArea( surface.index, c_x, c_y ) then
		return false
	end
	
	local surfaceData = global.surfaces[surface.index]
	
	local c_center_x=c_x + CHUNK_SIZE/2
	local c_center_y=c_y + CHUNK_SIZE/2
	if not (surfaceData.regions[r_x] and surfaceData.regions[r_x][r_y]) then
		return
	end
	
	r_data = surfaceData.regions[r_x][r_y]
	if not (r_data[c_x] and r_data[c_x][c_y]) then
		return
	end
	
--	log("Region data for "..r_x..","..r_y.." for pos "..c_x..","..c_y)
--	log(serpent.dump(r_data))
	
	if r_data[c_x] and r_data[c_x][c_y] then
		local rng = rng_for_reg_pos(surface.index, {x=c_center_x,y=c_center_y})

		debug("Stumbled upon "..c_x..","..c_y.." reg: "..r_x..","..r_y)
		local resource_list = r_data[c_x][c_y]
		local richness_distance_factor = settings.global["rso-distance-exponent"].value
		local fluid_richness_distance_factor = settings.global["rso-fluid-distance-exponent"].value
		local size_distance_factor = settings.global["rso-size-exponent"].value
		--for resource, deep in pairs(r_data[c_x][c_y]) do
		--  resource_list[#resource_list+1] = {resource, deep}
		--end
		table.sort(resource_list, function(res1, res2) return res1[2] < res2[2] end)
		
		local function calculateFactor(distance, exponent)
			if distance < 1 and exponent < 1 then
				return distance
			end
			return distance^exponent
		end
		
		for _, res_con in pairs(resource_list) do
			local resource = res_con[1]
			local deep = res_con[2]
			local r_config = surfaceData.config[resource]
			if r_config and r_config.valid then
				local dist = distanceFromStartingAreas(surfaceData, r_x, r_y)
				local sizeFactor = calculateFactor(dist, size_distance_factor)
				if r_config.type=="resource-ore" then
					local richFactor = calculateFactor(dist, richness_distance_factor)
					debug("Resource "..resource.." distance "..dist.." factors (size, richness) "..sizeFactor..","..richFactor)
					local size=rng(r_config.size.min, r_config.size.max) * (multi_resource_size_factor^deep) * sizeFactor
					local richness = r_config.richness * richFactor * (multi_resource_richness_factor^deep)
					local restriction = ''
					debug("Center @ "..c_center_x..","..c_center_y)
					c_center_x, c_center_y, restriction = find_intersection(surface, c_center_x, c_center_y)
					debug("New Center @ "..c_center_x..","..c_center_y)

--					local richness_max = 20000
--					local size_max = 30
--					if (richness_max > 0 and richness > richness_max) then
--						richness = math.min(richness, richness_max)
--					end
--					if (size_max > 0 and size > size_max) then
--						size = math.min(size, size_max)
--					end
					
					spawn_resource_ore(surface, resource, {x=c_center_x,y=c_center_y}, size, richness, false, restriction, rng)
				elseif r_config.type=="resource-liquid" then
					local richFactor = 0;
					if r_config.useOreScaling then
						richFactor = calculateFactor(dist, richness_distance_factor)
					else
						richFactor = calculateFactor(dist, fluid_richness_distance_factor)
					end
					debug("Resource "..resource.." distance "..dist.." factors (size, richness) "..sizeFactor..","..richFactor)
					local size=rng(r_config.size.min, r_config.size.max)  * (multi_resource_size_factor^deep) * sizeFactor
					if r_config.size.min == 1 and r_config.size.max == 1 then
						size = 1
					end
					local richness=rng(r_config.richness.min, r_config.richness.max) * richFactor * (multi_resource_richness_factor^deep)
					local restriction = ''
					c_center_x, c_center_y, restriction = find_intersection(surface, c_center_x, c_center_y)
					spawn_resource_liquid(surface, resource, {x=c_center_x,y=c_center_y}, size, richness, false, restriction, rng)
				elseif r_config.type=="entity" and not global.skipEnemies then
					spawn_entity(surface, resource, r_config, c_center_x, c_center_y, rng)
				end
			else
				debug("Resource access failed for " .. resource)
				game.players[1].print("Resource access failed for " .. resource)
			end
		end
		r_data[c_x][c_y] = nil
		
		if tableLength(r_data[c_x]) == 0 then
			r_data[c_x] = nil
		end
		
		--l:dump()
	end
end

local function clear_chunk(surface, tileX, tileY, ent_list)
	
	local _count = 0
	for _, obj in pairs(surface.find_entities_filtered{area = {{tileX, tileY}, {tileX + CHUNK_SIZE, tileY + CHUNK_SIZE}}, name=ent_list}) do
		if obj.valid then
			obj.destroy()
			_count = _count + 1
		end
	end
	
	if not global.skipEnemies then
		-- remove biters
		for _, obj in pairs(surface.find_entities_filtered{area = {{tileX, tileY}, {tileX + CHUNK_SIZE, tileY + CHUNK_SIZE}}, type="unit"}) do
			-- and (string.find(obj.name, "-biter", -6) or string.find(obj.name, "-spitter", -8))
			if obj.valid and obj.force.name == "enemy" then
				obj.destroy()
				_count = _count + 1
			end
		end
	end
	
	if _count > 0 then debug("Destroyed - ".._count) end
end

local function prepareEntityList(surfaceIndex)
	local entityList = {}
	local configIndexed = global.surfaces[surfaceIndex].configIndexed
	
	for _,v in pairs(configIndexed) do
		entityList[#entityList + 1] = v.name
		local infiniteOreName = "infinite-".. v.name

		if game.entity_prototypes[infiniteOreName] then
			entityList[#entityList + 1] = infiniteOreName
		end
		
		if not global.skipEnemies then
			if v.bases then
				for base, config in pairs(v.bases) do
					entityList[#entityList + 1] = base
				end
			end
				
			if v.sub_spawns then
				for ent,vv in pairs(v.sub_spawns) do
					entityList[#entityList + 1] = ent
				end
			end
		end
	end
	
	return entityList
end

local function regenerateSurface(surface, clearOnly)

	local surfaceData = global.surfaces[surface.index]
	surfaceData.regions = {}
	
	local entityList = prepareEntityList(surface.index)

	for chunk in surface.get_chunks() do
		local tileX = chunk.x * CHUNK_SIZE
		local tileY = chunk.y * CHUNK_SIZE

		if not isInStartingArea( surface.index, tileX, tileY ) then
			clear_chunk(surface, tileX, tileY, entityList)
		end
	end

	if not clearOnly then
		for chunk in surface.get_chunks() do

			local tileX = chunk.x * CHUNK_SIZE
			local tileY = chunk.y * CHUNK_SIZE

			if not isInStartingArea( surface.index, tileX, tileY ) then
				roll_region(surface, tileX, tileY)
				roll_chunk(surface, tileX, tileY)
			
				if useStraightWorldMod then
					straightWorld(surface, {x = tileX, y = tileY}, {x = tileX + CHUNK_SIZE, y = tileY + CHUNK_SIZE})
				end
			end		
		end
	end
	if clearOnly then
		log("Ore clear done")
	else
		log("Ore regeneration done")
	end
end

local function regenerate_everything(clearOnly, noEnemies)
	global.skipEnemies = noEnemies
	
	for index, surfaceData in pairs(global.surfaces) do
		local surface = game.surfaces[index]
		regenerateSurface(surface, clearOnly)
	end
	
	global.skipEnemies = nil
end

local function clearStartingArea( surface, pos )
	
	local startingAreaTilesSize = math.ceil( global.surfaces[surface.index].starting_area_size * REGION_TILE_SIZE )
	
	local chunkPosX = math.floor( pos.x/CHUNK_SIZE ) * CHUNK_SIZE
	local chunkPosY = math.floor( pos.y/CHUNK_SIZE ) * CHUNK_SIZE
	local entityList = prepareEntityList(surface.index)

	for posX = chunkPosX - startingAreaTilesSize, chunkPosX + startingAreaTilesSize, CHUNK_SIZE do
		for posY = chunkPosY - startingAreaTilesSize, chunkPosY + startingAreaTilesSize, CHUNK_SIZE do
			clear_chunk(surface, posX, posY, entityList)
		end
	end
end

local function extendRect(leftTop, bottomRight)
	leftTop.x = leftTop.x - CHUNK_SIZE / 2
	leftTop.y = leftTop.y - CHUNK_SIZE / 2
	bottomRight.x = bottomRight.x + CHUNK_SIZE
	bottomRight.x = bottomRight.x + CHUNK_SIZE
	
	return leftTop, bottomRight
end

local function printResourceProbability(player)
	-- prints the probability of each resource - how likely it is to be spawned in percent
	-- this ignores the multi resource chance
	local surfaceData = global.surfaces[player.surface.index]
	local maxAllotment = surfaceData.maxAllotment
	player.print("Max allotment"..string.format("%.1f",maxAllotment))
	debug("Max allotment"..string.format("%.1f",maxAllotment))
	local sanityCheckAllotment = 0
	for index,v in pairs(surfaceData.configIndexed) do
		if v.type ~= "entity" then		-- ignore enemies - they don't have allotment set
			if v.allotment then
				local resProbability = (v.allotment/maxAllotment) * 100
				sanityCheckAllotment = sanityCheckAllotment + v.allotment
				player.print("Resource: "..v.name.." Prob: "..string.format("%.1f",resProbability))
				debug("Resource: "..v.name.." Prob: "..string.format("%.1f",resProbability))
			else
				player.print("Resource: "..v.name.." Allotment not set")
				debug("Resource: "..v.name.." Allotment not set")
			end
		end
	end
	
	player.print("SanityCheck Allotment: "..string.format("%.1f", sanityCheckAllotment))
	debug("SanityCheck Allotment: "..string.format("%.1f", sanityCheckAllotment))
end

local IgnoredResources =
{
	["deep_oil"] = true,
	["bi-ground-steam"] = true,
	["bi-ground-sulfuric-acid"] = true,
	["fossil-roots"] = true,
--	["termal"] = true,
	["termal2"] = true,
	["tibGrowthNode"] = true,
	["natural-gas-1"] = true,
	["natural-gas-2"] = true,
	["natural-gas-3"] = true,
	["natural-gas-4"] = true
}

local function IsIgnoreResource(ResourcePrototype)
	if string.find( ResourcePrototype.name, "underground-" ) ~= nil then
		return true
	end
	if string.find( ResourcePrototype.name, "infinite-" ) ~= nil then
		return true
	end
	-- Cargo ships mod - it takes care of spawning it by itself but leaves it's autoplace in it so needs to be ignored
	if IgnoredResources[ResourcePrototype.name] then
		return true
	end
	if ResourcePrototype.autoplace_specification == nil then
		return true
	end
	if ResourcePrototype.autoplace_specification and ResourcePrototype.autoplace_specification.tile_restriction then
		return true
	end
	return false
end

local function checkForUnusedResources(player)
	-- find all resources and check if we have it in our config
	-- if not, tell the user that this resource won't be spawned (with RSO)
	local surfaceData = global.surfaces[player.surface.index]
	
	for prototypeName, prototype in pairs(game.entity_prototypes) do
		if prototype.type == "resource" then
			if not surfaceData.config[prototypeName] then
				if IsIgnoreResource(prototype) then	-- ignore resources which are not autoplace
					debug("Resource not configured but ignored (non-autoplace): "..prototypeName)
				else
					player.print("The resource "..prototypeName.." is not configured in RSO. It won't be spawned!")
					debug("Resource not configured: "..prototypeName)
				end
			else
				-- these are the configured ones
				if IsIgnoreResource(prototype) then
					debug("Configured resource (but it is in ignore list - will be used!): " .. prototypeName)
				else
					debug("Configured resource: " .. prototypeName)
				end
			end
		end
	end
end

local function printInvalidResources(player)
	-- prints all invalid resources which were found when the config was processed.
	for _, message in pairs(invalidResources) do
		player.print(message)
	end
end

local function loadAndPrepareConfig(surface)
	global.surfaces[surface.index].config = loadResourceConfig()
	checkConfigForInvalidResources(surface.index)
	build_config_data(surface)
end

local function updateSurfaceConfig(surface, justCreated, surfaceData)
	
	if not surfaceData then
		global.surfaces[surface.index] = global.surfaces[surface.index] or {}
		surfaceData = global.surfaces[surface.index]
	end
	
	surfaceData.seed = surface.map_gen_settings.seed
	
	if not surfaceData.regions then
		surfaceData.regions = {}
	end

	if not surfaceData.startingAreas then
		surfaceData.startingAreas = {}
		
		local startingPoints = surface.map_gen_settings.starting_points
		if startingPoints and surface.index == game.surfaces['nauvis'].index then
			for _, startingPoint in pairs(startingPoints) do
				local startX = 0
				local startY = 0
			
				startX = startingPoint.x
				startY = startingPoint.y

				table.insert( surfaceData.startingAreas, { x = startX, y = startY, spawned = false } )
				
				if not justCreated then
					surfaceData.startingAreas[1].spawned = true
				end
			end
		end
	end

	loadAndPrepareConfig(surface)

	if config_log_enabled then
		log("***** Config for surface "..surface.index)
		log(serpent.block(global.surfaces[surface.index].config))
		log(serpent.block(global.surfaces[surface.index].configIndexed))
	end
end

local function initConfig()
	if not global.surfaces then
		global.surfaces = {}
	
		local nauvisSurfaceData = global.surfaces[game.surfaces['nauvis'].index]
		
		if not nauvisSurfaceData then
			nauvisSurfaceData = {}
			
			local justCreated = true
			
			if global.regions then
				nauvisSurfaceData.regions = global.regions
				global.regions = nil
				justCreated = false
			else
				if game.tick > 10 then
					justCreated = false
				end
			end
			
			global.surfaces[game.surfaces['nauvis'].index] = nauvisSurfaceData
			
			updateSurfaceConfig(game.surfaces['nauvis'], justCreated)
		end
	end
end

local function updateConfig()
	
	initConfig()
	
	for surfaceIndex, surfaceData in pairs(global.surfaces) do
		local surface = game.surfaces[surfaceIndex]
		if surface then
			updateSurfaceConfig(surface, false, surfaceData)
		else
			game.surfaces[surfaceIndex] = nil
		end
	end

	for _,surface in pairs(game.surfaces) do
		if not global.surfaces[surface.index] then
			updateSurfaceConfig(surface, false)
		end
	end

	checkForBobEnemies()
	log("RSO: Updated resource configurations")
end

local function localGenerateChunk( event )
	--changes by xiaoHong - ignore surfaces interface - 11/29/2015
	if global.ignoreSurfaceNames and global.ignoreSurfaceNames[event.surface.name] then
		return
	end

	local c_x = event.area.left_top.x
	local c_y = event.area.left_top.y

	roll_region(event.surface, c_x, c_y)
	roll_chunk(event.surface, c_x, c_y)
	
	if useStraightWorldMod then		
		straightWorld(event.surface, event.area.left_top, event.area.right_bottom)
	elseif game.active_mods["building-platform"] and useStraightWorldPlatforms then
		straightWorldPlatforms(event.surface, event.area.left_top, event.area.right_bottom)
	end

end

local function init()

	updateConfig()

	spawn_starting_resources(game.surfaces['nauvis'], 1 )
	
	if not global.disableEventHandler then
		script.on_event(defines.events.on_chunk_generated, localGenerateChunk)
	end
end

script.on_init(init)
script.on_load(function()
	if not global.disableEventHandler then
		script.on_event(defines.events.on_chunk_generated, localGenerateChunk)
	end
end)

script.on_configuration_changed(updateConfig)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	if event.setting == "rso-region-size" then
		game.players[event.player_index].print("Warning: Region size changed. Dynamic size changes are not supported - recommend regenerating of resources to use new region size")
		region_size = settings.global["rso-region-size"].value
		REGION_TILE_SIZE = CHUNK_SIZE*region_size
	elseif event.setting == "rso-enemy-chance" then
		for surfaceIndex, surfaceData in pairs(global.surfaces) do
			for index,v in pairs(surfaceData.configIndexed) do
				if v.absolute_probability then
					v.absolute_probability = settings.global["rso-enemy-chance"].value
				end
			end
		end
		game.players[event.player_index].print("Enemy spawn chance update - it will be applied to new regions.")
	end
	
end)


script.on_event(defines.events.on_player_created, function(event)
	
	local player = game.players[event.player_index]
	
	if not global.surfaces[player.surface.index] then
		updateSurfaceConfig(player.surface, false)
	end
	
	checkForUnusedResources(player)
	printInvalidResources(player)
	
	if debug_enabled then
		
		printResourceProbability(player)
		
		if useBobEntity then
			player.print("RSO: BobEnemies found")
		end
		
		if debug_items_enabled then
			player.character.insert{name = "coal", count = 1000}
			player.character.insert{name = "raw-wood", count = 100}
			player.character.insert{name = "car", count = 1}
			player.character.insert{name = "car", count = 1}
			player.character.insert{name = "car", count = 1}
			
			if game.item_prototypes["resource-monitor"] then
				player.character.insert{name = "resource-monitor", count = 1}
			end
		end
	end
	
	l:dump()
end)

script.on_event(defines.events.on_surface_created, function(event)

	local surface = game.surfaces[event.surface_index]
	
	if global.ignoreSurfaceNames and global.ignoreSurfaceNames[surface.name] then
		return
	end
	
	initConfig()
	
	updateSurfaceConfig(surface, true)
end)

script.on_event(defines.events.on_surface_deleted, function(event)
	global.surfaces[event.surface_index] = nil
end)

script.on_event(defines.events.on_surface_cleared, function(event)
	if global.surfaces[event.surface_index] then 
		global.surfaces[event.surface_index].regions = {}
	end
end)

function regenerateCommand(parameters)
	local skipEnemies = false
	
	if parameters and parameters.parameter then
		if parameters.parameter == "noenemies" then
			skipEnemies = true
		end
	end
	
	regenerate_everything(false, skipEnemies)
end

function clearCommand(parameters)
	local skipEnemies = false

	if parameters and parameters.parameter then
		if parameters.parameter == "noenemies" then
			skipEnemies = true
		end
	end
	
	regenerate_everything(true, skipEnemies)
end

function seedCommand(parameters)

	global.mapSeedOverride = nil

	if parameters and parameters.parameter then
		global.mapSeedOverride = tonumber(parameters.parameter)
	end
end


commands.add_command("rso-regenerate", "", regenerateCommand)
commands.add_command("rso-clear", "", clearCommand)
commands.add_command("rso-override-seed", "", seedCommand)


remote.add_interface("RSO", {
	-- remote.call("RSO", "regenerate", true/false, surface)
	regenerate = function(new_seed, surface)
		regenerateCommand(nil)
	end,

	clear = function()
		clearCommand(nil)
	end,
	
	--changes by xiaoHong - ignore surfaces interface - 11/29/2015
	-- remote.call("RSO", "ignoreSurface", "name-of-surface")
	ignoreSurface = function(surfaceName)
		if type(surfaceName) ~= "string" then 
			game.players[1].print("RSO ignoreSurface interface: surfaceName should be a string")
		end
		if debug_enabled then 
			game.players[1].print("RSO ignoring surface " .. surfaceName .. " for generation") 
		end
		global.ignoreSurfaceNames = global.ignoreSurfaceNames or {}
		global.ignoreSurfaceNames[surfaceName] = true
	end,
		
	addStartLocation = function(pos, player)
		local outputPlayer = nil
		
		if game.player then
			outputPlayer = game.player
		end
		
		if player then
			outputPlayer = player
		end
		
		if not ( pos and pos.x and pos.y ) then
			log("Invalid parameters for new start location - please use following format: {x=0, y=0}")
			return
		end

		local surface = nil
		if outputPlayer then
			surface = outputPlayer.surface
		else
			surface = game.surfaces['nauvis']
		end
			
		local surfaceData = global.surfaces[surface.index]

		local radius = surfaceData.starting_area_size * REGION_TILE_SIZE
		
		for idx, startingPos in pairs( surfaceData.startingAreas ) do
			if distance( startingPos, pos ) < 2 * radius then
				log("Creation of starting area on "..surface.name.." failed - to close to starting area at "..startingPos.x..","..startingPos.y)
				return
			end
		end
		
		log("Creating new starting area on "..surface.name.." at "..pos.x..","..pos.y)
		
		clearStartingArea( surface, pos )
		
		pos.spawned = false;
		
		table.insert( surfaceData.startingAreas, pos )
		
		spawn_starting_resources( surface, #surfaceData.startingAreas )
		
--		if outputPlayer then
--			outputPlayer.force.chart(outputPlayer.surface, {{x = pos.x - radius, y = pos.y - radius}, {x = pos.x + radius, y = pos.y + radius}})
--		end
	end,
		
	saveLog = function()
		--debug(serpent.block(global.surfaces[1]))
		l:dump()
	end,
	
	regenConfig = function()
		for index, surfaceData in pairs(global.surfaces) do
			loadAndPrepareConfig(game.surfaces[index])
		end
	end,
	
	disableChunkHandler = function()
		if not global.disableEventHandler then
			script.on_event(defines.events.on_chunk_generated, nil)
		end
		global.disableEventHandler = true
	end,
	
	disableStartingArea = function()
		global.disableStartingArea = true
	end,

	generateChunk = function(event)
		localGenerateChunk(event)
	end,
	
	resetGeneration = function(surface, ignoreStartingAreas)
		if surface == nil then
			return
		end
		
		local surfaceData = global.surfaces[surface.index]
		
		updateSurfaceConfig(surface, false, surfaceData)

		surfaceData.regions = {}

		if not ignoreStartingAreas then
			for index, startingArea in pairs(surfaceData.startingAreas) do
				startingArea.spawned = false
				spawn_starting_resources(surface, index)
			end
		end
	end,
	
	runTest = function(areaSizeX, areaSizeY)
        game.player.character = god
        local sizeX = areaSizeX or 2000
        local sizeY = areaSizeY or 2000
		game.forces.player.chart(game.player.surface, {left_top = {x = -sizeX, y = -sizeY},
			right_bottom = {x = sizeX, y = sizeY}})
        game.speed = 2
        game.player.cheat_mode = true
		
		if game.player.force.technologies["resource-monitoring"] then
			game.player.force.technologies["resource-monitoring"].researched = true
		end
	end,
	
	isInStartingArea = function(surfaceIndex, tileX, tileY)
		return isInStartingArea(surfaceIndex, tileX, tileY)
	end,
})

--Time for the debug code.  If any (not global.) globals are written to at this point, an error will be thrown.
--eg, x = 2 will throw an error because it's not global.x or local x (by Mylon to check for global variables that might cause desyncs)
--setmetatable(_G, {
--   __newindex = function(_, n, v)
--      log("Desync warning: attempt to write to undeclared var " .. n)
      -- game.print("Attempt to write to undeclared var " .. n)
--      global[n] = v;
--   end,
--   __index = function(_, n)
--      return global[n];
--   end
--})
