------------------
---- data.lua ----
------------------

-- Set mod name
OSM.mod = "Offshore P.U.M.P.S."

-- Local functions host
local OSM_anim = require("utils.animation")

-- Load mod core
require("core")

-- Load prototypes
require("prototypes.entities")
require("prototypes.recipes")
require("prototypes.items")
require("prototypes.technology")

-- Disable vanilla offshore pump
OSM.lib.disable_prototype("all", "offshore-pump")

-- Change entity in tips and tricks
for _, trigger in pairs(data.raw["tips-and-tricks-item"]["electric-network"].trigger.triggers) do
	if trigger.entity == "offshore-pump" then trigger.entity = "offshore-pump-0" end
end

-- Assign colors to offshore pumps
OSM_anim.assign_tier_color()

OSM.mod = nil