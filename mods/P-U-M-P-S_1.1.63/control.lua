---------------------
---- control.lua ----
---------------------

OSM = {}
OSM.init = require("script.init")
OSM.functions = require("script.functions")
OSM.debug_mode = settings.startup["OSM-debug-mode"].value

OSM.collision_layer = "OSM-offshore-pump-collision-layer"
OSM.boiler_start_water = settings.global["osm-pumps-boiler-start-water"].value
OSM.landfill_goes_boom = settings.startup["osm-pumps-landfill-goes-boom"].value

OSM.powered_pumps =
{
	["offshore-pump-0-placeholder"] =	{name="offshore-pump-0",	is_offshore=true},
	["offshore-pump-1-placeholder"] =	{name="offshore-pump-1",	is_offshore=true},
	["offshore-pump-2-placeholder"] =	{name="offshore-pump-2",	is_offshore=true},
	["offshore-pump-3-placeholder"] =	{name="offshore-pump-3",	is_offshore=true},
	["offshore-pump-4-placeholder"] =	{name="offshore-pump-4",	is_offshore=true},
	["seafloor-pump-placeholder"] =		{name="seafloor-pump",		is_offshore=true},	-- Angels Refining
	["ground-water-pump-placeholder"] =	{name="ground-water-pump",	is_offshore=false},	-- Angels Refining
}
OSM.bugged_pumps =
{
	"offshore-pump-output", -- AAI Industries
}

-- Init on init
local function init_globals()
--	NOT IN USE
end

-- Init on tick
local function init_on_tick(event)
	if global.on_tick_trigger then

		OSM.init.regenerate_pumps()

	else -- Unregister event
		script.on_event(defines.events.on_tick, nil)
	end
end

-- Init handler
local function init_script()

	-- Init before first tick
	init_globals()
	
	-- Init on first tick
	if not global.on_tick_trigger then
		global.on_tick_trigger = true
		script.on_event(defines.events.on_tick, init_on_tick)
	end
end

local function init_on_load()
	if global.on_tick_trigger then
		script.on_event(defines.events.on_tick, init_on_tick)
	else
		script.on_event(defines.events.on_tick, nil)
	end
end

-- Initialize
script.on_init(init_script)
script.on_configuration_changed(init_script)
script.on_load(init_on_load)

-- Place offshore pump
script.on_event(defines.events.on_built_entity, OSM.functions.make_offshore_pump)
script.on_event(defines.events.on_robot_built_entity, OSM.functions.make_offshore_pump)

-- Offshore pumps stay offshore
script.on_event(defines.events.on_player_built_tile, OSM.functions.offshore_means_offshore)
script.on_event(defines.events.on_robot_built_tile, OSM.functions.offshore_means_offshore)

-- Replace vanilla offshore pump if found in inventory
script.on_event(defines.events.on_player_main_inventory_changed, OSM.functions.replace_vanilla_item)