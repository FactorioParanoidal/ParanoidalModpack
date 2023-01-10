---------------------
---- control.lua ----
---------------------

OSM = {}

-- Utils path
require("__osm-lib__.functions.utils")

OSM.PP = {}
OSM.PP = require("control-core")

local debug_mode = settings.startup["OSM-debug-mode"].value

local function on_init()

	local stage = "on_init"

	OSM.PP.init_globals()
	OSM.PP.init_script(stage)
end

local function on_configuration_changed()

	local stage = "on_configuration_changed"

	OSM.PP.init_globals()
	OSM.PP.init_script(stage)
end

local function on_load()

	local stage = "on_load"

	OSM.PP.init_script(stage)
end

-- Init
script.on_init(on_init)
script.on_configuration_changed(on_configuration_changed)
script.on_load(on_load)

