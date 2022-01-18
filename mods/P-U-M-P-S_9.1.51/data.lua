------------------
---- data.lua ----
------------------

-- Set mod name
OSM.mod_name = "P.U.M.P.S."

-- Local functions host
local OSM_anim = require("utils.animation")
local disable_prototype = OSM.lib.prototype.disable_prototype

-- Load mod core
require("core")

-- Load prototypes
require("prototypes.entities")
require("prototypes.recipes")
require("prototypes.items")
require("prototypes.technology")

-- Disable vanilla offshore pump
disable_prototype("offshore-pump", "all")

-- Change entity in tips and tricks
for _, trigger in pairs(data.raw["tips-and-tricks-item"]["electric-network"].trigger.triggers) do
	if trigger.entity == "offshore-pump" then trigger.entity = "offshore-pump-0" end
end

-- Assign colors to offshore pumps
OSM_anim.assign_tier_color()

OSM.mod_name = nil