local targetDummy = {}

require ("__base__.prototypes.entity.biter-animations")
local small_biter_scale = 0.5
local small_biter_tint1 = {r=0.60, g=0.58, b=0.51, a=1}
local small_biter_tint2 = {r=0.9 , g=0.83, b=0.54, a=1}

function targetDummy.addTargetDummies()

    data:extend({
            {
                type = "radar",
                name = "targetDummyPlasma-rampant",
                icon = "__RampantFixed__/graphics/icons/thief/crystal-drain.png",
                icon_size = 32,
                flags = {"placeable-enemy"},
                minable = nil,
                max_health = 10000,
				healing_per_tick = -0.1,
                corpse = "small-remnants",
                collision_box = {{-0.8, -0.8 }, {0.8, 0.8}},
                selection_box = {{-1, -1}, {1, 1}},
                energy_per_nearby_scan = "6MJ",
                energy_per_sector = "6MJ",
				emissions_per_second = 1,
                max_distance_of_sector_revealed = 0,
				max_distance_of_nearby_sector_revealed = 1,
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
				call_for_help_radius = 1,
                energy_source =  {type = "void"},
                energy_usage = "100kJ",
                pictures =
                    {
                        filename = "__RampantFixed__/graphics/entities/thief/crystal-drain.png",
                        priority = "low",
                        width = 128,
                        height = 128,
                        scale = 1,
                        apply_projection = false,
                        direction_count = 32,
                        animation_speed = 0.5,
                        line_length = 8,
                        shift = {0.65, 0}
                    },
                vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
                radius_minimap_visualisation_color = { r = 0.059, g = 0.092, b = 0.8, a = 0.275 }
           }
    })
	---------------------	
     local targetDummy = util.table.deepcopy(data.raw["radar"]["targetDummyPlasma-rampant"])
	 targetDummy.name = "targetDummyFire-rampant"
	 targetDummy.resistances = {
                    {
                        type = "physical",
						decrease = -90,
                        percent = -1000
                    },
                    {
                        type = "fire",
                        percent = 99
                    },
                    {
                        type = "laser",
						decrease = -90,
                        percent = -1000
                    }
                }

	data:extend({targetDummy})
	---------------------
	local targetDummy = util.table.deepcopy(data.raw["radar"]["targetDummyPlasma-rampant"])
	targetDummy.name = "targetDummyPhysical-rampant"
	targetDummy.resistances = {
					{
						type = "physical",
						decrease = 0,
						percent = 99
					},
					{
						type = "fire",
						decrease = -90,
						percent = -1000
					},
					{
						type = "laser",
						decrease = -90,
						percent = -1000
					}
				}

	data:extend({targetDummy})
	---------------------
	local targetDummy = util.table.deepcopy(data.raw["radar"]["targetDummyPlasma-rampant"])
	targetDummy.name = "targetDummyLaser-rampant"
	targetDummy.resistances = {
					{
						type = "physical",
						decrease = -90,
						percent = -1000
					},
					{
						type = "fire",
						decrease = -90,
						percent = -1000
					},
					{
						type = "laser",
						percent = 99
					}
				}

	data:extend({targetDummy})
	

end

function targetDummy.addDummySetters()
	local scale = small_biter_scale * 0.8
    local DummySetter = util.table.deepcopy(data.raw["unit"]["small-biter"])
	DummySetter.name = "plasmaDummySetter-rampant"
    DummySetter.collision_box = {{-0.2*scale, -0.2*scale}, {0.2*scale, 0.2*scale}}
    DummySetter.selection_box = {{-0.4*scale, -0.7*scale}, {0.4*scale, 0.4*scale}}
    DummySetter.attack_parameters["animation"] = biterattackanimation(scale, small_biter_tint1, small_biter_tint2)
    DummySetter.run_animation = biterrunanimation(scale, small_biter_tint1, small_biter_tint2)
    DummySetter.water_reflection = biter_water_reflection(scale)
	----------------------- tests
	local damaged_trigger_effect = {{type = "script", effect_id = "overdamageProtection, 5"},
									{type = "script", effect_id = "longRangeImmunity, 5"}}
	DummySetter.damaged_trigger_effect = damaged_trigger_effect 
	-------------------------
    DummySetter.dying_trigger_effect = {
                        type = "create-entity",
                        entity_name = "targetDummyPlasma-rampant"
                    }
	
	data:extend({DummySetter})
	---------------------------
    local DummySetter = util.table.deepcopy(data.raw["unit"]["plasmaDummySetter-rampant"])
 	DummySetter.name = "fireDummySetter-rampant"
	DummySetter.dying_trigger_effect = {
                        type = "create-entity",
                        entity_name = "targetDummyFire-rampant"
                    }
	data:extend({DummySetter})
	---------------------------
    local DummySetter = util.table.deepcopy(data.raw["unit"]["plasmaDummySetter-rampant"])
 	DummySetter.name = "physicalDummySetter-rampant"
	DummySetter.dying_trigger_effect = {
                        type = "create-entity",
                        entity_name = "targetDummyPhysical-rampant"
                    }
	data:extend({DummySetter})
	---------------------------
    local DummySetter = util.table.deepcopy(data.raw["unit"]["plasmaDummySetter-rampant"])
 	DummySetter.name = "laserDummySetter-rampant"
	DummySetter.dying_trigger_effect = {
                        type = "create-entity",
                        entity_name = "targetDummyLaser-rampant"
                    }
	data:extend({DummySetter})
	
	
	
	
	
	---------------------------
    local DummySetter = util.table.deepcopy(data.raw["unit"]["plasmaDummySetter-rampant"])
 	DummySetter.name = "randomDummySetter-rampant"
	DummySetter.dying_trigger_effect = {
                        type = "script",
                        effect_id = "createRandomTargetDummy-rampant"
                    }
	data:extend({DummySetter})
	
end

return targetDummy