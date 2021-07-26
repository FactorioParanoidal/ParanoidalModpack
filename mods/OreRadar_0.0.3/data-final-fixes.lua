-- try to set up technology

--data.raw.recipe.radar.type = "recipe"
--data.raw.recipe.radar.name = "radar"
--data.raw.recipe.radar.ingredients[1] = {"electronic-circuit", 5}
--data.raw.recipe.radar.ingredients[2] = {"iron-gear-wheel", 5}
--data.raw.recipe.radar.ingredients[3] = {"iron-plate", 10}
--data.raw.recipe.radar.result = "radar"

local tint = {0.6,0.6,0}

local function get_technology_names (recipe_name)
	local names = {}
	for i, tech in pairs (data.raw.technology) do
		if tech.effects then
			for j, effect in pairs (tech.effects) do
				if effect.type == "unlock-recipe" and
					effect.recipe == recipe_name
				then
					table.insert (names, tech.name)
				end
			end
		end
	end
	return names
end

local technology = 
    {
        type = "technology",
        name = "ore-radar",
--      icon = "__OreRadar__/thumbnail.png",
--      icon_size = 144,
		
		
        icons = {{icon = "__OreRadar__/graphics/technology/radar.png", icon_size = 128, tint = tint}},
        prerequisites = {"radar"},
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "ore-radar"
            }
        },
        unit =
        {
            count = 100,
            ingredients =
            {
                {"automation-science-pack", 1}
            },
            time = 60
        },
    }


if data.raw.recipe["ore-radar"] 
	and not (data.raw.recipe["ore-radar"].enabled == false)
	and data.raw.radar.radar 
	and data.raw.item.radar 
	and data.raw.recipe.radar 
	and (data.raw.recipe.radar.enabled == false) -- true and nil give false
then
	local tech_names = get_technology_names ("radar")
	if #tech_names > 0 then
		data.raw.recipe["ore-radar"].enabled = false
		
		-- for test and mod compatibility :
		technology.prerequisites = tech_names
		
		data:extend({technology})
		log ("added ore radar technology")
	else
		log ("no prerequisites for ore radar tehnology")
	end
elseif not data.raw.recipe["ore-radar"] then log ("no entity ore radar")
elseif (data.raw.recipe["ore-radar"].enabled == false) then log ("ore radar was false")
elseif not data.raw.radar.radar then log ("no entity radar")
elseif not data.raw.item.radar then log ("no item radar")
elseif not data.raw.recipe.radar then log ("no recipe radar")
elseif not (data.raw.recipe.radar.enabled == false) then log ("radar recipe enabled was true")
	
end