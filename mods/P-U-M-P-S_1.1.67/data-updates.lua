--------------------------
---- data-updates.lua ----
--------------------------

-- Set mod name
OSM.mod = "Offshore P.U.M.P.S."

-- Local functions host
local OSM_local = require("utils.lib")

-- Apply overrides
require("prototypes.override.angel-overrides")
require("prototypes.override.bob-updates")
require("prototypes.override.bob-overrides")
require("locale.locale")

-- Ground water pumpjacks
if mods["reskins-bobs"] and reskins.bobs and reskins.bobs.triggers.mining.entities then

	-- Reskin entities
	OSM_local.pumpjack_entity_tiering()

	-- Reskin icons
	OSM_local.pumpjack_icon_tiering()
end

OSM.mod = nil