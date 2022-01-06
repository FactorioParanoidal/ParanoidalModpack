------------------
---- data.lua ----
------------------

-- Set mod name
OSM.mod_name = "P.U.M.P.S."

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
OSM.lib.prototype.disable_prototype("offshore-pump", "all")

-- Adjust bobmining water miners
local base_prototype = "technology"
if mods ["angelsrefining"] then base_prototype = "all" end
OSM.lib.prototype.disable_prototype("water-miner-1", base_prototype)
OSM.lib.prototype.disable_prototype("water-miner-2", base_prototype)
OSM.lib.prototype.disable_prototype("water-miner-3", base_prototype)
OSM.lib.prototype.disable_prototype("water-miner-4", base_prototype)
OSM.lib.prototype.disable_prototype("water-miner-5", base_prototype)

-- Change entity in tips and tricks
for _, trigger in pairs(data.raw["tips-and-tricks-item"]["electric-network"].trigger.triggers) do
	if trigger.entity == "offshore-pump" then trigger.entity = "offshore-pump-0" end
end

-- Assign correct descriptions and names
local offshore_pumps =
{
	"offshore-pump-0",
	"offshore-pump-1",
	"offshore-pump-2",
	"offshore-pump-3",
	"offshore-pump-4"
}

if settings.startup ["enable-power"].value == true then
	for _, pump_name in pairs (offshore_pumps) do
		data.raw.item[pump_name].localised_name = {"entity-name."..pump_name.."-pwr"}
		data.raw["assembling-machine"][pump_name].localised_name = {"entity-name."..pump_name.."-pwr"}
		data.raw.item[pump_name].localised_description = {"item-description."..pump_name.."-pwr"}
	end
else
	for _, pump_name in pairs (offshore_pumps) do
		data.raw.item[pump_name].localised_description = {"item-description."..pump_name}
	end
end

-- Assign colors to offshore pumps
OSM_anim.assign_offshore_color()

OSM.mod_name = nil