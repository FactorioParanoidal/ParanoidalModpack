--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: createMuLocoItemPrototype.lua
 * Description: Copies a locomotive item and creates the "-mu" version with:
 *   - MU localization text is added to name and description fields.
--]]

local create_icons = require("__OpteraLib__.data.utilities").create_icons
local icon_overlay = { { icon = "__MultipleUnitTrainControl__/graphics/icons/mu-overlay.png", icon_size = 32, tint = {r=255, g=255, b=0, a=196} } }

function createMuLocoItemPrototype(item_type,name,newName)
	-- Copy source locomotive prototype
	local newItem = copy_prototype(data.raw[item_type][name], newName)
	
	-- Make the new icon
	newItem.icons = create_icons(newItem,icon_overlay) or icon_overlay
	
	-- Fix the localization
	newItem.localised_name = {'template.mu-name',{'entity-name.'..name}}
	newItem.localised_description = {'template.mu-item-description',{'entity-name.'..name}}
	
	return newItem
end
return createMuLocoItemPrototype