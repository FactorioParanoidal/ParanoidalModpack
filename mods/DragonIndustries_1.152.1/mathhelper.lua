function roundToGridBitShift(position, shift)
	position.x = bit32.lshift(bit32.rshift(position.x, shift), shift)
	position.y = bit32.lshift(bit32.rshift(position.y, shift), shift)
	return position
end

function getBoundingBoxAverageEdgeLength(box)
	local pos1 = box.left_top
	local pos2 = box.right_bottom
	local dx = pos2.x-pos1.x
	local dy = pos2.y-pos1.y
	return (dx+dy)/2
end

function getDistance(e1, e2)
	local dx = e1.position.x-e2.position.x
	local dy = e1.position.y-e2.position.y
	return math.sqrt(dx*dx+dy*dy)
end

function directionToVector(dir)
	if dir == defines.direction.north then
		return {dx=0, dy=-1}
	elseif dir == defines.direction.south then
		return {dx=0, dy=1}
	elseif dir == defines.direction.east then
		return {dx=1, dy=0}
	elseif dir == defines.direction.west then
		return {dx=-1, dy=0}
	end
end

function roundToNearest(i, n)
	local m = n/2
	return i+m-(i+m)%n
end

function roundToPlaces(num, places)
  local mult = 10^(places or 0)
  return math.floor(num * mult + 0.5) / mult
end

function getOppositeDirection(dir) --direction is a number from 0 to 7
	return (dir+4)%8
end

function getPerpendicularDirection(dir) --direction is a number from 0 to 7
	return (dir+2)%8
end

function sigFig(num, figures)
    local x = figures - math.ceil(math.log(math.abs(num), 10))
    return (math.floor(num*10^x+0.5)/10^x)
end

function getCosInterpolate(x, xmax, ymax)
	if x >= xmax then
		return ymax
	end
	local func = 0.5-0.5*math.cos(x*math.pi/xmax)
	return func*ymax
end

function getCustomWeightedRandom(values, randFunc)
	local sum = 0
	for idx,num in pairs(values) do
		sum = sum+num
	end
	local rand = randFunc and randFunc(0, sum) or math.random(0, sum)
	local val = 0
	for key,num in pairs(values) do
		val = val+num
		if val >= rand then
			return key
		end
	end
	return 0
end

---@generic T
---@param vals table(T)
---@return T
function getWeightedRandom(vals)
	local sum = 0
	for _,entry in pairs(vals) do
		local weight = entry[1]
		sum = sum+weight
	end
	
	--Copied and Luafied from DragonAPI WeightedRandom
	local d = math.random()*sum;
	local p = 0
	for _,entry in pairs(vals) do
		p = p + entry[1]
		if d <= p then
			return entry[2]
		end
	end
	return nil
end

function cantorCombine(a, b)
	--a = (a+1024)%16384
	--b = b%16384
	local k1 = a*2
	local k2 = b*2
	if a < 0 then
		k1 = a*-2-1
	end
	if b < 0 then
		k2 = b*-2-1
	end
	return 0.5*(k1 + k2)*(k1 + k2 + 1) + k2
end