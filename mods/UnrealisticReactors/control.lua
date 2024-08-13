local rpath = "scripts."
require(rpath .. "const") -- globals
local mod = require(rpath .. "init")
local gui = require(rpath .. "gui.init")
local events = require(rpath .. "events.init")
local interface = require(rpath .. "interface")
local network = require(rpath .. "heat.network")
local fx = require(rpath .. "fx")

-- INITIALIZING AND UPDATING FUNCTIONS

-- mod initialization
script.on_init(mod.init)
script.on_load(mod.load)
script.on_configuration_changed(mod.migration)

-- hook ticks
script.on_event(events.defined.tick, function (event)
	mod.tick(event.tick)
end)

-- hook gui
script.on_event(events.defined.gui.opened, function (event)
	gui.opened(event.player_index)
end)
script.on_event(events.defined.gui.clicked, function (event)
	gui.clicked(event.player_index, event.element, event.tick)
end)

-- hook heat network
script.on_event(events.defined.removed.surface, function (event)
	network.remove_from_surface(event.surface_index)
end)
script.on_event(events.defined.removed.chunk, function (event)
	local z = event.surface_index
	for _,p in pairs(event.positions) do
		network.remove_from_chunk(p.x,p.y,z)
	end
end)

-- hook fx
script.on_event(events.defined.trigger.effect, function (event)
	fx.effect(event.effect_id, event.target_entity, event.force, event.tick)
end)

-- hook construct events
script.on_event(events.defined.pipette, function (event)
	events.construct.pipette(event.player_index, event.item)
end)
script.on_event(events.defined.added.entity, function (event)
	events.construct.entity(event.created_entity or event.entity, event.tick)
end)

-- hook destruct events
script.on_event(events.defined.removed.ghost, function (event)
	if event.ghost.type == "item-request-proxy" then return end
	events.destruct.ghost(event.ghost)
end)
script.on_event(events.defined.removed.entity, function (event)
	local has_died = event.name == defines.events.on_entity_died
	events.destruct.entity(event.entity, event.tick, has_died, event.name)
end)


-- add events filter
for action,event_filters in pairs(events.filters) do
	for key,filters in pairs(event_filters) do
		for _,event in pairs(events.defined[action][key]) do
			script.set_event_filter(event, filters)
		end
	end
end


remote.add_interface(REMOTE_INTERFACE_NAME, interface)

