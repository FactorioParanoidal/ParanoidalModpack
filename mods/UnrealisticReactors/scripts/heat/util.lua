local rpath = (...):match("(.-)[^%.]+$")
local rroot = rpath:match("^([^%.]+%.)")
local isempty = require(rroot .. "util").isempty


local function split(s,d,f)
    local r = {} for x in s:gmatch("[^" .. d .. "]+") do table.insert(r,f(x)) end return r
end

local function imerge(a,b)
	if #a < #b then a,b = b,a end -- spare some work
	for _,v in ipairs(b) do table.insert(a,v) end
	return a
end

local function isemptyline(t2d, y)
	for _,xs in pairs(t2d) do
		if xs[y] then return false end
	end
	return true
end

local function get(t,k,d) return t[k] or d end
local function set(t,k,v) t[k] = v return t end

local function get2d(t,x,y,d) return get(get(t, x, {}), y, d) end
local function set2d(t,x,y,v) return set(t, x, set(get(t, x, {}), y, v)) end

local function get3d(t,x,y,z,d) return get2d(get(t, x, {}), y, z, d) end
local function set3d(t,x,y,z,v) return set(t, x, set2d(get(t, x, {}), y, z, v)) end

local function rm2d(t,x,y)
	if t[x] then
		set2d(t,x,y,nil)
		if isempty(t[x]) then
			t[x] = nil
		end
	end
	return t
end

local function sameposition(a,b)
	return a.x == b.x and a.y == b.y
end

local function moveposition(position, direction, distance)
	local offset = O[direction]
	if offset then
		return {
			x = position.x + offset.x * distance,
			y = position.y + offset.y * distance,
		}
	end
end

--[[ not used atm
local function growarea(a,b)
	if not a then return b elseif not b then return a end
	a.left_top.x = math.min(a.left_top.x,b.left_top.x)
	a.left_top.y = math.min(a.left_top.y,b.left_top.y)
	a.right_bottom.x = math.max(a.right_bottom.x,b.right_bottom.x)
	a.right_bottom.y = math.max(a.right_bottom.y,b.right_bottom.y)
	return a
end

local function subarea(sub,area) -- sub is sub  area of area
	if not sub then return area end
	if sameposition(sub.left_top, area.left_top) then
		if sub.right_bottom.x == area.right_bottom.x then
			area.left_top.y = sub.right_bottom.y
		end -- no else here to contract area to a point
		if sub.right_bottom.y == area.right_bottom.y then
			area.left_top.x = sub.right_bottom.x
		end
	elseif sameposition(sub.right_bottom, area.right_bottom) then
		if sub.left_top.x == area.left_top.x then
			area.right_bottom.y = sub.left_top.y
		elseif sub.left_top.y == area.left_top.y then -- but else here is ok -- sit in front of a black screen and let it fill up your mind.
			area.right_bottom.x = sub.left_top.x
		end
	end
	return area -- nothing changed, lol
end

local function shrinkarea(area,entities)
	if area.left_top.x == x and not entities[x] then
		area.left_top.x = area.left_top.x + 1
	end
	if area.right_bottom.x == x and not entities[x] then
		area.right_bottom.x = area.right_bottom.x - 1
	end
	if area.left_top.y == y and isemptyline(entities,y) then
		area.left_top.y = area.left_top.y + 1
	end
	if area.right_bottom.y == y and isemptyline(entities,y) then
		area.right_bottom.y = area.right_bottom.y - 1
	end
	return area
end
--]]


local MEMO = {} -- memoize
local function memo(f,...) -- doens't support arguments
	return MEMO[f] or set(MEMO,f,f(...))[f]
end


return { -- exports
	memo = memo,
	split = split,
	imerge = imerge,
	isemptyline = isemptyline,
	get   = get  , set   = set  ,
	get2d = get2d, set2d = set2d,
	get3d = get3d, set3d = set3d,
	 rm2d =  rm2d,
	sameposition = sameposition,
	moveposition = moveposition,
-- 	  growarea =   growarea,
-- 	   subarea =    subarea,
-- 	shrinkarea = shrinkarea,
}

