local rpath = (...):match("(.-)[^%.]+$")
local rroot = rpath:match("^([^%.]+%.)")
local set3d = require(rroot .. "heat.util").set3d
local get3d = require(rroot .. "heat.util").get3d
local isempty = require(rroot .. "util").isempty
local util = require(rpath .. "util")
local find_nuclear_entity = util.find_nuclear_entity
local find_nuclear_ghost  = util.find_nuclear_ghost




local function store_interface(ghost)
	local x,y,z = ghost.position.x,ghost.position.y,ghost.surface.index
-- 	log(string.format("added interface ghost at x=%s y=%s z=%s", x,y,z))
	local definitions = {}
	for _,target in pairs(ghost.circuit_connection_definitions) do
		target.name = target.target_entity.name == "entity-ghost" and target.target_entity.ghost_name or target.target_entity.name
		target.position = target.target_entity.position
		target.target_entity = nil
		table.insert(definitions, target)
	end
	set3d(global.interfaces, z,x,y-1, { -- position of reactor
		name = ghost.ghost_name,
		position = ghost.position,
		definitions = definitions,
	})
end

local function get_interface_definitions(x,y,z)
	local ghost = get3d(global.interfaces, z,x,y)
	if not ghost then return nil end
	--- now its used up
	set3d(global.interfaces, z,x,y, nil)
	return ghost
end


local function create_interface(surface, options)
	local x,y,z = options.position.x,options.position.y,surface.index -- of reactor
	options.position = {x=x,y=y+1}
	local ghost = get_interface_definitions(x,y,z)
	local interface = surface.create_entity(options)
	if not ghost then return interface end
	for _,target in pairs(ghost.definitions) do
		local entity = find_nuclear_entity(surface, target.position, target.name)
		            or find_nuclear_ghost (surface, target.position, target.name)
		if entity then
			target.name = nil
			target.position = nil
			target.target_entity = entity
			interface.connect_neighbour(target)
		end
	end
	return interface
end


local function get_nuclear_entity(surface, position)
	return find_nuclear_entity(surface, position, REACTOR_ENTITY_NAME)
	    or find_nuclear_entity(surface, position, BREEDER_ENTITY_NAME)
end

local function get_nuclear_ghost(surface, position)
	return find_nuclear_ghost(surface, position, REACTOR_ENTITY_NAME)
	    or find_nuclear_ghost(surface, position, BREEDER_ENTITY_NAME)
end


local function find_interface(surface, position, name)
	return find_nuclear_entity(surface, {position.x,position.y+1}, name)
end

local function find_interface_ghost(surface, position, name)
	return find_nuclear_ghost(surface, {position.x,position.y+1}, name)
end


local function get_interface(surface, position)
	return find_interface(surface, position, REACTOR_INTERFACE_ENTITY_NAME)
	    or find_interface(surface, position, BREEDER_INTERFACE_ENTITY_NAME)
end

local function get_interface_ghost(surface, position)
	return find_interface_ghost(surface, position, REACTOR_INTERFACE_ENTITY_NAME)
	    or find_interface_ghost(surface, position, BREEDER_INTERFACE_ENTITY_NAME)
end

local function on_tick(tick)
	-- FIXME this should never happen
	if tick % 9000 == 0 then
		local is = global.interfaces
		for x,xs in pairs(is) do
			local surface = game.surfaces[x] -- actually z :P
			for y,ys in pairs(xs) do
				for z,ghost in pairs(ys) do
					if not find_nuclear_ghost(surface, ghost.position, ghost.name) then
						log(string.format("had to remove dead ghost from x=%s y=%s z=%s", x,y,z))
						game.print("[BUG] Found dead ghost. Please report and send log file!")
						ys[z] = nil -- cleanup dead ghosts, rofl
					end
				end
				if isempty(ys) then xs[y] = nil end
			end
			if isempty(xs) then is[x] = nil end
		end
	end
end


return { -- exports
	tick = on_tick,
	create = create_interface,
	remember = store_interface,
	definitions = get_interface_definitions,
	get       = get_interface,
	get_ghost = get_interface_ghost,
	find       = find_interface,
	find_ghost = find_interface_ghost,
}

