------------------
---- data.lua ----
------------------

-- Set environment
OSM = {}

-- Define code stage
OSM.data_stage = 1

-- Load data types
require("__osm-lib__.core.data-definitions")

-- Load core
require("__osm-lib__.core.lib-core")
require("__osm-lib__.functions.data-stage")

-- Load prototypes
require("__osm-lib__.prototypes.data-core")