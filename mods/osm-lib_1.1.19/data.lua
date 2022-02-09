------------------
---- data.lua ----
------------------

-- Setup hosts
if not OSM then OSM = {} end
if not OSM.lib then OSM.lib = {} end

-- Mod name
OSM.mod_name = "osm-lib"

-- Load core
require("core")

-- load utils
require("utils.utils")

-- Load functions
require("functions.technology")
require("functions.item")
require("functions.recipe")
require("functions.entity")
require("functions.prototype")
