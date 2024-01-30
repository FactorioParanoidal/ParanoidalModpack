---------------------
---- control.lua ----
---------------------

OSM = {}
OSM.PUMPS = {}
OSM.PUMPS.functions = require("script.functions")
OSM.PUMPS.init = require("script.init")

OSM.PUMPS.collision_layer = "OSM-offshore-pump-collision-layer"

OSM.PUMPS.debug_mode = settings.startup["OSM-debug-mode"].value
OSM.PUMPS.boiler_start_water = settings.global["osm-pumps-boiler-start-water"].value
OSM.PUMPS.power_enabled = settings.startup["osm-pumps-enable-power"].value
OSM.PUMPS.landfill_goes_boom = settings.startup["osm-pumps-landfill-goes-boom"].value

OSM.PUMPS.powered_pumps = require("utils.pumps").powered_pumps
OSM.PUMPS.bugged_pumps = require("utils.pumps").bugged_pumps

-- Initialize
script.on_init(OSM.PUMPS.init.on_init)
script.on_configuration_changed(OSM.PUMPS.init.on_init)
script.on_load(OSM.PUMPS.init.on_load)

-- Place offshore pump
script.on_event(defines.events.on_built_entity, OSM.PUMPS.functions.make_offshore_pump)
script.on_event(defines.events.on_robot_built_entity, OSM.PUMPS.functions.make_offshore_pump)

-- Offshore pumps stay offshore
script.on_event(defines.events.on_player_built_tile, OSM.PUMPS.functions.offshore_means_offshore)
script.on_event(defines.events.on_robot_built_tile, OSM.PUMPS.functions.offshore_means_offshore)

-- Replace vanilla offshore pump if found in inventory
script.on_event(defines.events.on_player_main_inventory_changed, OSM.PUMPS.functions.replace_vanilla_item)

-- Remove collision layer placeholder
script.on_event(defines.events.on_player_mined_entity, OSM.PUMPS.functions.remove_collision_layer)
script.on_event(defines.events.on_robot_mined_entity, OSM.PUMPS.functions.remove_collision_layer)
script.on_event(defines.events.on_entity_died, OSM.PUMPS.functions.remove_collision_layer)