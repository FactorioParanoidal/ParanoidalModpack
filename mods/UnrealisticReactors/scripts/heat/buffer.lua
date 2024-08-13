local rpath = (...):match("(.-)[^%.]+$")
local rroot = rpath:match("^([^%.]+%.)")
local bigunpack = require("__big-data-string__.unpack")
local util = require(rpath .. "util")
local moveposition = util.moveposition
local get2d = util.get2d
local set2d = util.set2d
local split = util.split
local memo = util.memo


local function decode(s)
	return split(s or "",",",tonumber)
end

local function is_internal(prototype)
	return prototype.type == "reactor"
	   and string.sub(prototype.name, 1,17) == "realistic-reactor"
	   and not       (prototype.name        == "realistic-reactor")
end

local function heat_buffer_prototype_connections(prototype)
	local data = decode(bigunpack(prototype.name .. "-heat-buffer-connections"))
	local connections = {}
	for i = 1,#data,3 do
		local d,x,y = unpack(data,i)
		table.insert(connections, {direction=d, position={x=x,y=y}})
	end
	return connections
end

local function all_heat_buffer_prototype_connections()
	local connections = {}
	local filters = {
		{mode="or", filter="type", type="reactor"},
		{mode="or", filter="type", type="heat-pipe"},
	}
	for name,prototype in pairs(game.get_filtered_entity_prototypes(filters)) do
		if not is_internal(prototype) then
			connections[name] = heat_buffer_prototype_connections(prototype)
		end
	end
	-- add connections for internals
	connections["realistic-reactor-normal" ] = connections["realistic-reactor"]
	connections["realistic-reactor-breeder"] = connections["realistic-reactor"]
	return connections
end

local function get_heat_buffer_prototype_connections(name)
	return memo(all_heat_buffer_prototype_connections)[name] or {}
end

local function get_heat_buffer_prototype_transitions(name)
	local transitions = {}
	for i,connection in ipairs(get_heat_buffer_prototype_connections(name)) do
		transitions[i] = {
			p = connection.position, -- inside entity
			o = moveposition({x=0,y=0}, connection.direction, 1), -- outlet offset
		}
	end
	return transitions
end

local function vecadd(a,b) return {x=a.x+b.x, y=a.y+b.y} end
local function vecfmut(f,v) v.x = f(v.x) v.y = f(v.y) return v end
local function iterate_heat_buffer_prototype_transitions(s, i)
	i = i + 1 local t = s.t[i] -- transition
	if not t then return end -- stop iteration
	local p = vecfmut(math.floor, vecadd(s,t.p))
	return i, p, vecadd(p,t.o)
end

local TRANSITIONS = setmetatable({}, { __index = function (T, name)
	local transitions = get_heat_buffer_prototype_transitions(name)
	T[name] = transitions -- memoize
	return transitions
end})

local function heat_buffer_transitions(entity)
	local index = 0
	local iterator = iterate_heat_buffer_prototype_transitions
	local state = {
		t = TRANSITIONS[entity.name],
		x = entity.position.x,
		y = entity.position.y,
	}
	return iterator, state, index
end


local function get_heat_buffer_prototype_transition_lookup(name)
	local lookup = {}
	for _,transition in ipairs(TRANSITIONS[name]) do
		local p = vecfmut(math.floor,vecadd({x=0.5,y=0.5},transition.p))
		local v = vecadd(transition.o, p)
		set2d(lookup, v.x,v.y, p)
	end
	return lookup
end

local TRANSITION_LOOKUP = setmetatable({}, {__index = function (T, name)
	local lookup = get_heat_buffer_prototype_transition_lookup(name)
	T[name] = lookup -- memoize
	return lookup
end})

local function heat_buffer_transition_position(entity, o,p)
	local t = get2d(TRANSITION_LOOKUP[entity.name], p.x-o.x, p.y-o.y)
	if t then return vecadd(t,o) end
end

return { -- exports
	get_heat_buffer_prototype_connections = get_heat_buffer_prototype_connections,
	heat_buffer_transition_position = heat_buffer_transition_position,
	heat_buffer_transitions = heat_buffer_transitions,
}

