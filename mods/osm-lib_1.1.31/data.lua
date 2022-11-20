------------------
---- data.lua ----
------------------

if not OSM then OSM = {} end

-- Define code stage
OSM.data_stage = 1

-- Load core
require("core.host-tables")
require("core.data-core")

-- Load functions
require("functions.data-utils")
require("functions.data-stage")