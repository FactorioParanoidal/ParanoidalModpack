------------------
---- data.lua ----
------------------

-- Fetch animation functions
local sprite_recolor = require("utils.animation").sprite_recolor

-- Load prototypes
require("prototypes.core")
require("prototypes.entities")
require("prototypes.recipes")
require("prototypes.items")
require("prototypes.technology")

-- Assign correct descriptions and names
if settings.startup ["enable-power"].value == true then
	
	data.raw.item["offshore-pump-0"].localised_name = {"entity-name.offshore-pump-0-burner"}
	data.raw["assembling-machine"]["offshore-pump-0"].localised_name = {"entity-name.offshore-pump-0-burner"}
	data.raw.item["offshore-pump-0"].localised_description = {"item-description.offshore-pump-0-burner"}
	
	data.raw.item["offshore-pump-1"].localised_name = {"entity-name.offshore-pump-1-electric"}
	data.raw["assembling-machine"]["offshore-pump-1"].localised_name = {"entity-name.offshore-pump-1-electric"}
	data.raw.item["offshore-pump-1"].localised_description = {"item-description.offshore-pump-1-electric"}
	
	data.raw.item["offshore-pump-2"].localised_name = {"entity-name.offshore-pump-2-electric"}
	data.raw["assembling-machine"]["offshore-pump-2"].localised_name = {"entity-name.offshore-pump-2-electric"}
	data.raw.item["offshore-pump-2"].localised_description = {"item-description.offshore-pump-2-electric"}
	
	data.raw.item["offshore-pump-3"].localised_name = {"entity-name.offshore-pump-3-electric"}
	data.raw["assembling-machine"]["offshore-pump-3"].localised_name = {"entity-name.offshore-pump-3-electric"}
	data.raw.item["offshore-pump-3"].localised_description = {"item-description.offshore-pump-3-electric"}
	
	data.raw.item["offshore-pump-4"].localised_name = {"entity-name.offshore-pump-4-electric"}
	data.raw["assembling-machine"]["offshore-pump-4"].localised_name = {"entity-name.offshore-pump-4-electric"}
	data.raw.item["offshore-pump-4"].localised_description = {"item-description.offshore-pump-4-electric"}
else
	data.raw.item["offshore-pump-0"].localised_description = {"item-description.offshore-pump-0"}
	data.raw.item["offshore-pump-1"].localised_description = {"item-description.offshore-pump-1"}
	data.raw.item["offshore-pump-2"].localised_description = {"item-description.offshore-pump-2"}
	data.raw.item["offshore-pump-3"].localised_description = {"item-description.offshore-pump-3"}
	data.raw.item["offshore-pump-4"].localised_description = {"item-description.offshore-pump-4"}
end

-- Apply color masks
sprite_recolor()