local rpath = (...):match("(.-)[^%.]+$")
local rroot = rpath:match("^([^%.]+%.)")
local on = require(rpath .. "util").on
local network = require(rroot .. "heat.network")
local reactor = require(rroot .. "entity.reactor")
local interface = require(rroot .. "entity.interface")
local tower = require(rroot .. "entity.tower")
local ruin = require(rroot .. "entity.ruin")
local isempty = require(rroot .. "util").isempty

local event_filters = {}
local event_listener = {}


local function on_ghost_interface_removed(ghost) --interface ghost has been mined via deconstruction planner or player mouse
	local x,y,z = ghost.position.x,ghost.position.y,ghost.surface.index
	interface.definitions(x,y-1,z) -- remove known interface ghosts
	--remove reactor on interface ghost removal
	local ghosts = {
		reactor.find_ghost(ghost.surface, ghost.position, REACTOR_ENTITY_NAME),
		reactor.find_ghost(ghost.surface, ghost.position, BREEDER_ENTITY_NAME),
	}
	for _,entity in pairs(ghosts) do
		entity.destroy()
	end
end


local function on_ghost_reactor_removed(ghost)
	local x,y,z = ghost.position.x,ghost.position.y,ghost.surface.index
	interface.definitions(x,y,z) -- remove known interface ghosts
	--remove interface on reactor ghost removal
	local ghosts = {
		interface.find_ghost(ghost.surface, ghost.position, REACTOR_INTERFACE_ENTITY_NAME),
		interface.find_ghost(ghost.surface, ghost.position, BREEDER_INTERFACE_ENTITY_NAME),
	}
	for _,entity in pairs(ghosts) do
		entity.destroy()
	end
end



local function reactor_is_not_robot_minable(entity, event_name)
	return event_name == defines.events.on_robot_pre_mined
	   and not reactor.is_minable(entity)
end

local function on_reactor_removed(entity, tick, has_died, event_name)
	if reactor_is_not_robot_minable(entity, event_name) then return end
	reactor.remove(entity, tick, has_died)
end


local function on_heatpipe_removed(entity, tick, has_died)
	network.remove_heat_pipe(entity)
end


local function on_coolingtower_removed(entity, tick, has_died)
	tower.remove(entity)
end


local function on_ruin_removed(entity, tick, has_died)
	ruin.remove(entity)
end


event_filters.ghost = {}
event_listener.ghost = {
	[REACTOR_INTERFACE_ENTITY_NAME] = on_ghost_interface_removed,
	[BREEDER_INTERFACE_ENTITY_NAME] = on_ghost_interface_removed,
	[REACTOR_ENTITY_NAME] = on_ghost_reactor_removed,
	[BREEDER_ENTITY_NAME] = on_ghost_reactor_removed,
}


local ghost_removed = event_listener.ghost

for ghost_name in pairs(ghost_removed) do
	table.insert(event_filters.ghost, {mode = "or", filter = "ghost_name", name = ghost_name})
end


local function on_ghost_removed(entity, ...)
	ghost_removed[entity.ghost_name](entity, ...)
end


event_filters.entity = {
	{mode = "or", filter = "type", type = "heat-pipe"},
	{mode = "or", filter = "type", type = "reactor"},
	unpack(event_filters.ghost),
}

event_listener.entity = {
	["entity-ghost"] = on_ghost_removed,
	[REACTOR_ENTITY_NAME] = on_reactor_removed,
	[BREEDER_ENTITY_NAME] = on_reactor_removed,
	[TOWER_ENTITY_NAME] = on_coolingtower_removed,
	[REACTOR_RUIN_NAME] = on_ruin_removed,
	[BREEDER_RUIN_NAME] = on_ruin_removed,
}

local entity_removed = event_listener.entity

for entity_name in pairs(entity_removed) do
	if entity_name ~= "entity-ghost" then
		table.insert(event_filters.entity, {mode = "or", filter = "name", name = entity_name})
	end
end

local function on_entity_removed(entity, ...)
	if reactor.is(entity) then
		network.remove_reactor(entity)
	end
	if entity.type == "heat-pipe" then
		on_heatpipe_removed(entity, ...)
	else
		on(entity_removed, entity, ...)
	end
end

return { -- exports
	ghost  = on_ghost_removed,
	entity = on_entity_removed,
	filters = event_filters,
	listeners = event_listener,
}
