---------------------
---- control.lua ----
---------------------

OSM = {}
OSM.debug_mode = settings.startup["OSM-debug-mode"].value
OSM.boiler_start_water = settings.global["osm-pumps-boiler-start-water"].value

local osm_init = require("script.init")
local osm_script = require("script.functions")

-- Init on init
local function init_globals()
	-- NOT YET IN USE
end

-- Init on tick
local function init_on_tick(event)
	if global.on_tick_trigger then

		osm_init.regenerate_pumps()

	else
		script.on_event(defines.events.on_tick, nil)
	end
end

local function init_script()

	-- Init before first tick
	init_globals()
	
	-- Init on first tick
	if not global.on_tick_trigger then
		global.on_tick_trigger = true
		script.on_event(defines.events.on_tick, init_on_tick)
	end
end

local function on_load_script()
	if global.on_tick_trigger then
		script.on_event(defines.events.on_tick, init_on_tick)
	else
		script.on_event(defines.events.on_tick, nil)
	end
end

-- Initialize
script.on_init(init_script)
script.on_configuration_changed(init_script)

-- Prevents desync
script.on_load(on_load_script)

-- Place offshore pump
script.on_event(defines.events.on_built_entity, osm_script.make_offshore_pump)
script.on_event(defines.events.on_robot_built_entity, osm_script.make_offshore_pump)

-- Offshore pumps stay offshore...
script.on_event(defines.events.on_player_built_tile, osm_script.offshore_means_offshore)
script.on_event(defines.events.on_robot_built_tile, osm_script.offshore_means_offshore)

-- Replace vanilla offshore pump if found in inventory
script.on_event(defines.events.on_player_main_inventory_changed, replace_vanilla_item)