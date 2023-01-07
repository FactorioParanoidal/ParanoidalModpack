------------------
---- data.lua ----
------------------

if not OSM then OSM = {} end

-- Define code stage
OSM.data_stage = 0

-- Load core
require("__osm-lib__.core.lib-core")
require("__osm-lib__.functions.data-stage")

OSM.data_stage = 1

-- Load prototypes
require("__osm-lib__.prototypes.data-core")