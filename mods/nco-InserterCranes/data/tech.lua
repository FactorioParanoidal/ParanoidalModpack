local util = require("util")

local make_layered_icon = require("icon")

local function get_parent_technology(recipe_name)
	for _, technology in pairs(data.raw.technology) do
		--log(technology.name)
		if (technology.enabled or technology.enabled == nil) and technology.effects then
			for _, effect in pairs(technology.effects) do
				if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
					--log(recipe_name)
					return technology.name
				end
			end
		end
	end
	return nil
end

local function setup_crane_tech(itemName, newName)
	local parent_tech_name = get_parent_technology(itemName)
	--log(itemName.. " is unlocked by " .. parent_tech_name)
	if parent_tech_name then
		local tech_name = "technology-" .. parent_tech_name .. "-crane"
		local technology = data.raw["technology"][tech_name]
		if not technology then
			technology = util.table.deepcopy(data.raw["technology"][parent_tech_name])
			technology.name = tech_name
			make_layered_icon(technology,true)
			technology.effects = {}
			technology.unit.count = technology.unit.count * 2
			technology.prerequisites = {
				"railway",
				parent_tech_name
			}
			data:extend({technology})
		end
		table.insert(
			technology.effects,
			{
				type = "unlock-recipe",
				recipe = newName
			}
		)
	end
end

return setup_crane_tech
