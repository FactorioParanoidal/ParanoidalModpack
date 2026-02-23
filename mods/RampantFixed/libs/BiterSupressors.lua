if (biterSupressorG) then
    return biterSupressorG
end
local biterSupressor = {}

local supressorsData = {}
supressorsData["biterSupressor1-rampant"] = {supressionType = 1, number = 1, tint = {0, 0.2, 0.4, 0.5}}	--- if add or remove elements, don't forget to change recipes in biterSupressor.addEntities(). Also locale ru and en
supressorsData["biterSupressor2-rampant"] = {supressionType = 2, number = 2, tint = {0, 0, 0.2, 0.5}}
supressorsData["biterSupressor3-rampant"] = {supressionType = 3, number = 3, tint = {0.4, 0, 0.4, 0.5}}


function biterSupressor.addEntities()
	local newEntities = {}
	for name, supressorData in pairs(supressorsData) do
		
		newEntities[#newEntities + 1] = {
			type = "radar",
			name = "biterSupressor"..supressorData.number.."-rampant",
			icon = "__RampantFixed__/graphics/icons/lightning-rod.png",
			icons = {{icon = "__RampantFixed__/graphics/icons/lightning-rod.png", tint = supressorData.tint}},
			flags = {"placeable-player", "player-creation"},
			minable = {mining_time = 1, result = "biterSupressor"..supressorData.number.."-rampant"},
			max_health = 200,
			corpse = "small-remnants",
			dying_explosion = "medium-electric-pole-explosion",
			collision_box = {{-1.15, -1.15}, {1.15, 1.15}},
			selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
			energy_per_nearby_scan = "3000MJ",
			energy_per_sector = "3000MJ",
			max_distance_of_sector_revealed = 0,
			max_distance_of_nearby_sector_revealed = 1,
			drawing_box_vertical_extension = 4.3,
			resistances = {
				{
					type = "physical",
					decrease = -90,
					percent = -1000
				},
				{
					type = "electric",
					percent = 100
				},
				{
					type = "explosion",
					percent = 99
				},
				{
					type = "laser",
					percent = 99
				}
			},
			energy_source =  {type = "electric", usage_priority = "primary-input"},
			energy_usage = "10MJ",
				
			pictures = 
			{ 
				layers = 
				{
					{
						filename = "__RampantFixed__/graphics/entities/lightning-rod/lightning-rod.png",
						priority = "extra-high",
						size = {108,352},
						width = 12,
						height = 28,
						shift = util.by_pixel(0, -100),
						direction_count = 1,
						animation_speed = 0,
						variation_count = 1,
						scale = 1
					},
					{
						filename = "__RampantFixed__/graphics/entities/lightning-rod/lightning-rod.png",
						priority = "high",
						size = {108,352},
						width = 12,
						height = 28,
						shift = util.by_pixel(0, -100),
						direction_count = 1,
						animation_speed = 0,
						variation_count = 1,
						scale = 1,
						tint = supressorData.tint 
					}
					-- {
						-- filename = "__RampantFixed__/graphics/entities/lightning-rod/lightning-rod-discharge.png",
						-- priority = "high",
						-- size = {108,352},
						-- width = 12,
						-- height = 28,
						-- shift = util.by_pixel(0, -100),
						-- blend_mode = "additive",
						-- scale = 1,
						-- direction_count = 24,
						-- frame_count = 24,
						-- draw_as_glow = true
					  
					-- }
				}
			},
			vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
			radius_minimap_visualisation_color = { r = 0.059, g = 0.092, b = 0.8, a = 0.275 }
	   }
	
		local newEntity = newEntities[#newEntities]
		newEntity.icons[#newEntity.icons+1] =  
		  {
			icon = "__base__/graphics/icons/signal/signal_"..supressorData.number ..".png",
			scale = 0.25,
			icon_size = 64,
			shift = {5, -10}
		  }	
		data:extend({newEntities[#newEntities]})


		newEntities[#newEntities + 1] = 
		{
			type = "item",
			name = "biterSupressor"..supressorData.number.."-rampant",
			icon = "__RampantFixed__/graphics/icons/lightning-rod.png",
			icons = {{icon = "__RampantFixed__/graphics/icons/lightning-rod.png", tint = supressorData.tint}},
			icon_mipmaps = 1,
			-- flags = {"not-in-made-in"},
			subgroup = "space-related",
			order = "a[rocket-silo]_RFx"..supressorData.number,
			hidden = true,
			place_result = "biterSupressor"..supressorData.number.."-rampant",
			weight = 0.5 * tons,
			stack_size = 2
		}

		local newEntity = newEntities[#newEntities]
		newEntity.icons[#newEntity.icons+1] =  
		  {
			icon = "__base__/graphics/icons/signal/signal_"..supressorData.number ..".png",
			scale = 0.25,
			icon_size = 64,
			shift = {5, -10}
		  }	
		data:extend({newEntities[#newEntities]})		
	end	
	-- data:extend({newEntities})
	
	-- local supressorData = {number = 1, tint = {0.2, 0, 0.6}}
	 -- data:extend({
		-- {
			-- type = "item",
			-- name = "biterSupressor"..supressorData.number.."-rampant",
			-- icon = "__RampantFixed__/graphics/icons/lightning-rod.png",
			-- icons = {{icon = "__RampantFixed__/graphics/icons/lightning-rod.png", tint = supressorData.tint}},
			-- icon_mipmaps = 1,
			-- -- flags = {"not-in-made-in"},
			-- subgroup = "space-related",
			-- order = "a[rocket-silo]_RFx"..supressorData.number,
			-- hidden = true,
			-- -- place_result = "biterSupressor"..supressorData.number.."-rampant",
			-- weight = 0.5 * tons,
			-- stack_size = 2
		-- }
	 
	 -- })

data:extend({	
  {
    type = "recipe",
    name = "biterSupressor1-rampant",
	localised_description = {"technology-description.biterSupressor-rampant"},
    enabled = false,
    ingredients =
    {
      {type = "item", name = "processing-unit", amount = 100},
      {type = "item", name = "carbon", amount=30},
      {type = "item", name = "low-density-structure", amount=30},
	  {type = "item", name = "electric-engine-unit", amount = 30},
      {type = "item", name = "accumulator", amount=100},
      {type = "item", name = "radar", amount=1}
    },
    energy_required = 60,
    results = {{type="item", name="biterSupressor1-rampant", amount=1}}
  },
  {
    type = "recipe",
    name = "biterSupressor2-rampant",
	localised_description = {"technology-description.biterSupressor-rampant"},
    enabled = false,
    ingredients =
    {
      {type = "item", name = "biterSupressor1-rampant", amount = 1},
      {type = "item", name = "superconductor", amount = 20},
      {type = "item", name = "supercapacitor", amount = 20},
	  {type = "item", name = "lightning-collector", amount = 1}
    },
    energy_required = 60,
    results = {{type="item", name="biterSupressor2-rampant", amount=1}}
  },
  {
    type = "recipe",
    name = "biterSupressor3-rampant",
	localised_description = {"technology-description.biterSupressor-rampant"},
    enabled = false,
    ingredients =
    {
      {type = "item", name = "biterSupressor2-rampant", amount = 1},
      {type = "item", name = "quantum-processor", amount = 20},
      {type = "item", name = "cryogenic-plant", amount = 2}
    },
    energy_required = 60,
    results = {{type="item", name="biterSupressor3-rampant", amount=1}}
  },
  ----------- technology
  {
    type = "technology",
    name = "biterSupressor1-rampant",
    icons = data.raw["radar"]["biterSupressor1-rampant"].icons,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "biterSupressor1-rampant"
      }
    },
    prerequisites = {"space-platform"},
    unit =
    {
      count = 200,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1}
      },
      time = 60
    }
  },
  {
    type = "technology",
    name = "biterSupressor2-rampant",
    icons = data.raw["radar"]["biterSupressor2-rampant"].icons,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "biterSupressor2-rampant"
      }
    },
    prerequisites = {"electromagnetic-plant", "lightning-collector", "biterSupressor1-rampant"},
    unit =
    {
      count = 200,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"electromagnetic-science-pack", 1},
      },
      time = 60
    }
  },
  {
    type = "technology",
    name = "biterSupressor3-rampant",
    icons = data.raw["radar"]["biterSupressor3-rampant"].icons,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "biterSupressor3-rampant"
      }
    },
    prerequisites = {"cryogenic-plant", "quantum-processor", "biterSupressor2-rampant"},
    unit =
    {
      count = 200,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"metallurgic-science-pack", 1},
        {"agricultural-science-pack", 1},
        {"electromagnetic-science-pack", 1},
        {"cryogenic-science-pack", 1}
      },
      time = 60
    }
  }  
})  
	
end

function biterSupressor.supressionType(entityName)
	if not supressorsData[entityName] then
		return nil
	else	
		return supressorsData[entityName].supressionType
	end
end

local characterQuery = {type = "character", force = nil}
function biterSupressor.processSupression(entity)
	if not entity.valid then
		return
	end	
	local surface = entity.surface
	local map = storage.universe.maps[surface.index]
	if not map then
		rendering.draw_light({sprite = "utility/light_medium", scale = 5, color = {1, 0, 0, 0.5}, minimum_darkness = 0, target = entity, surface = surface, time_to_live = 300})
		rendering.draw_circle({color = {1, 0, 0, 0.5}, radius = 0.1, filled = true, target= entity, surface = surface, time_to_live = 300})
		return
	end
	
	if not map.supressionData then 
		map.supressionData = {}
	end
	------- check characters
	local hasCharacters = false
	for i=1,#game.connected_players do
		local player = game.connected_players[i]
		if player.valid and (player.force==entity.force) then
			local character = player.character
			if character and character.valid and (character.surface == surface) then
				hasCharacters = true
				break
			end
		end
	end	
	if hasCharacters then
		map.supressionData.supressionType = 0
	else	
		map.supressionData.supressionType = (biterSupressor.supressionType(entity.name) or 0)
	end
	----- freezze evo
	if map.supressionData.supressionType >= 3 then
		if map.supressionData.evo and ((map.supressionData.supressionEndTick + 60) >= game.tick) then
			local evo = game.forces.enemy.get_evolution_factor(surface)
			if evo > map.supressionData.evo then
				game.forces.enemy.set_evolution_factor(map.supressionData.evo, surface)
			end	
		end
		map.supressionData.evo = game.forces.enemy.get_evolution_factor(surface)
	end
	-----

	if map.supressionData.supressionType == 0 then
		rendering.draw_light({sprite = "utility/light_medium", scale = 5, color = {1, 1, 0, 0.5}, minimum_darkness = 0, target = entity, surface = surface, time_to_live = 300})
		rendering.draw_circle({color = {1, 1, 0, 0.5}, radius = 0.1, filled = true, target= entity, surface = surface, time_to_live = 300})
	else
		rendering.draw_light({sprite = "utility/light_medium", scale = 5, color = {0, 1, 0, 0.5}, minimum_darkness = 0, target = entity, surface = surface, time_to_live = 300})
		rendering.draw_circle({color = {0, 1, 0, 0.5}, radius = 0.1, filled = true, target= entity, surface = surface, time_to_live = 300})
	end
	
end

function biterSupressor.increaseNextDemolisherAttackTick(map, demolisherAttackInterval)
	if map.supressionData and (map.supressionData.supressionType >=2) and (map.supressionData.supressionEndTick >= game.tick) then
		demolisherAttackInterval = demolisherAttackInterval * 1.5
	end
	map.nextDemolisherAttackTick = math.max(game.tick, map.nextDemolisherAttackTick) + demolisherAttackInterval
end

function biterSupressor.setNextDemolisherAttackTick(map, demolisherAttackInterval)
	if map.supressionData and (map.supressionData.supressionType >=2) and (map.supressionData.supressionEndTick >= game.tick) then
		demolisherAttackInterval = demolisherAttackInterval * 1.5
	end
	map.nextDemolisherAttackTick = game.tick + demolisherAttackInterval
end


return biterSupressor