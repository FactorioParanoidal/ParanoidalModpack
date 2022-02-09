-- Setup function host
if not OSM.lib.entity then OSM.lib.entity = {} end 

-- Get local functions
local OSM_local = require("utils.local-functions")

-- Remove resource
function OSM.lib.entity.remove_resource(resource_name)
	if data.raw.resource[resource_name] then
		data.raw.resource[resource_name] = nil
		data.raw["autoplace-control"][resource_name] = nil
	end
	
	local infinite_resource = nil
	if data.raw.resource["infinite-"..resource_name] then
		infinite_resource = "infinite-"..resource_name
		data.raw.resource["infinite-"..resource_name] = nil
		data.raw["autoplace-control"]["infinite-"..resource_name] = nil
	end

	for _, preset in pairs(data.raw["map-gen-presets"]["default"]) do
		if
			preset and preset.basic_settings and preset.basic_settings.autoplace_controls and
			preset.basic_settings.autoplace_controls[resource]
		then
			preset.basic_settings.autoplace_controls[resource] = nil
		end
		if infinite_resource and preset and preset.basic_settings and preset.basic_settings.autoplace_controls and preset.basic_settings.autoplace_controls[infinite_resource] then
			preset.basic_settings.autoplace_controls[infinite_resource] = nil
		end
	end
end