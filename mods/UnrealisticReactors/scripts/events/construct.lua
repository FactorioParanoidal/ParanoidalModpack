local rpath = (...):match("(.-)[^%.]+$")
local rroot = rpath:match("^([^%.]+%.)")
local on = require(rpath .. "util").on
local network = require(rroot .. "heat.network")
local reactor = require(rroot .. "entity.reactor")
local interface = require(rroot .. "entity.interface")
local tower = require(rroot .. "entity.tower")
local sameposition = require(rroot .. "heat.util").sameposition
local util = require(rroot .. "entity.util")
local find_nuclear_entity = util.find_nuclear_entity
local find_nuclear_ghost  = util.find_nuclear_ghost


local event_filters = {}
local event_listener = {}


local function on_ghost_interface_added(ghost)
	-- this should tell factorio to not delete it between on_pre_built and on_built_entity
	interface.remember(ghost)
end

local function on_reactor_added(entity, tick)
	entity.active = false
	entity.minable = true
	reactor.add(entity, interface.create(entity.surface, {
		name = E2I_NAME[entity.name],
		position = entity.position,
		force = entity.force,
	}))
end


local function on_heatpipe_added(entity, tick)
	network.add_heat_pipe(entity)
end


local function on_coolingtower_added(entity, tick)
	tower.add(entity)
end


local function on_sarcophagus_added(entity)
	entity.health = 0.1
	entity.destructible = false
	entity.minable = false
	global.sarcophagus[entity.unit_number] = entity
	local fallout = entity.surface.find_entities_filtered{name="permanent-radiation",area={{entity.position.x-5,entity.position.y-5},{entity.position.x+5,entity.position.y+5}}}
	for i, ent in pairs (fallout) do
		if i % 20 ~= 1 then
			ent.destroy()
		end
	end
end


event_filters.ghost = {}
event_listener.ghost = {
	[REACTOR_INTERFACE_ENTITY_NAME] = on_ghost_interface_added,
	[BREEDER_INTERFACE_ENTITY_NAME] = on_ghost_interface_added,
}

local ghost_added = event_listener.ghost

for ghost_name in pairs(ghost_added) do
	table.insert(event_filters.ghost, {mode = "or", filter = "ghost_name", name = ghost_name})
end

local function on_ghost_added(entity, ...)
	ghost_added[entity.ghost_name](entity, ...)
end


event_listener.entity = {
	["entity-ghost"] = on_ghost_added,
	[REACTOR_ENTITY_NAME] = on_reactor_added,
	[BREEDER_ENTITY_NAME] = on_reactor_added,
	[TOWER_ENTITY_NAME] = on_coolingtower_added,
	[SARCOPHAGUS_ENTITY_NAME] = on_sarcophagus_added,
}

event_filters.entity = {
	{mode = "or", filter = "type", type = "heat-pipe"},
	{mode = "or", filter = "type", type = "reactor"},
	unpack(event_filters.ghost)
}

event_filters.ghost = nil -- dont set them, cuz not used

local entity_added = event_listener.entity

for entity_name,_ in pairs(entity_added) do
	if entity_name ~= "entity-ghost" then
		table.insert(event_filters.entity, {mode = "or", filter = "name", name = entity_name})
	end
end

local function on_entity_added(entity, ...)
	if reactor.is(entity) then
		network.add_reactor(entity)
	end
	if entity.type == "heat-pipe" then
		on_heatpipe_added(entity, ...)
	else
		on(entity_added, entity, ...)
	end
end



local function on_player_pipette(player_index, item)
	if I2E_NAME[item.name] then -- reactor interface
		local player = game.players[player_index]
		player.pipette_entity(I2E_NAME[item.name])
	end
end


return { -- exports
	entity = on_entity_added,
	pipette = on_player_pipette,
	filters = event_filters,
	listeners = event_listener,
}
