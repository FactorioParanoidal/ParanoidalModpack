direction = {
  north = 0,
  northeast = 1,
  east = 2,
  southeast = 3,
  south = 4,
  southwest = 5,
  west = 6,
  northwest = 7
}

opposite = {}
opposite[direction.north] = direction.south
opposite[direction.northeast] = direction.southwest
opposite[direction.east] = direction.west
opposite[direction.southeast] = direction.northwest
opposite[direction.south] = direction.north
opposite[direction.southwest] = direction.northeast
opposite[direction.west] = direction.east
opposite[direction.northwest] = direction.southeast

function getCardinal(orient)
	return math.floor(orient * 200.0 / 25.0 + 0.5) % 8
end

function isOnLeft(origin, target, dir)
	if dir == direction.north then
		return target.x < origin.x
	end
	if dir == direction.west then
		return target.y > origin.y
	end
	if dir == direction.east then
		return target.y < origin.y
	end
	if dir == direction.south then
		return target.x > origin.x
	end
	local diffx = target.x - origin.x
	local diffy = target.y - origin.y
	
	local x = diffx - diffy
	local y = diffx + diffy
	
	--printToAll(dir .. ' -> ' .. x .. ', ' .. y)
	if dir == direction.northeast then
		return y < 0
	end
	
	if dir == direction.southeast then
		return x > 0
	end
	
	if dir == direction.southwest then
		return y > 0
	end
	
	if dir == direction.northwest then
		return x < 0
	end
	
	return false
end

function isFrontLocomotive(ent)
	local train = ent.train
	local movers = {}
	
	if train.speed > 0 then
		movers = train.locomotives.front_movers
	elseif train.speed < 0 then
		movers = train.locomotives.back_movers
	end
	
	for k,v in pairs(movers) do
		if v == ent then
			return true
		end
	end
	return false
	
end