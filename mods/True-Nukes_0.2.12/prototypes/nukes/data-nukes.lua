
local fireutil = require("__base__.prototypes.fire-util")
local nuke_explosions = require("data-nuke-explosions")
local nuke_materials = require("data-nukes-material")

if settings.startup["enable-atomic-bomb"].value then
	data.raw.projectile["atomic-rocket"].action = 
	{
	  type = "direct",
	  action_delivery =
	  {
		type = "instant",
		target_effects = nuke_explosions.N20t_detonation
		
	  }
	}
	data.raw.ammo["atomic-bomb"].ammo_type.range_modifier = 6
	data.raw.recipe["atomic-bomb"].energy_required=60
	if mods["bobelectronics"] then
		data.raw.recipe["atomic-bomb"].ingredients=
			{
			  {"plastic-bar", 20},
			  {"superior-circuit-board", 5},
			  {"explosives", 10},
			  {nuke_materials.boomMaterial, 30},
			}
	else
		data.raw.recipe["atomic-bomb"].ingredients=
			{
			  {"rocket-control-unit", 10},
			  {"processing-unit", 5},
			  {"explosives", 10},
			  {nuke_materials.boomMaterial, 30},
			}
	end
end

local atom = data.raw["ammo"]["atomic-bomb"]
atom.icon = "__True-Nukes__/graphics/atomic-bomb.png"
atom.pictures.layers[1].filename="__True-Nukes__/graphics/atomic-bomb.png"
atom.pictures.layers[1].mipmap_count = 4
atom.pictures.layers[2].filename="__True-Nukes__/graphics/rocket-light-1.png"
atom.pictures.layers[2].mipmap_count = 4

data:extend({
fireutil.add_basic_fire_graphics_and_effects_definitions
{
  type = "fire",
  name = "nuclear-fire",
  flags = {"placeable-off-grid", "not-on-map"},
  damage_per_tick = {amount = 130 / 60, type = "fire"},
  maximum_damage_multiplier = 6,
  damage_multiplier_increase_per_added_fuel = 1,
  damage_multiplier_decrease_per_tick = 0.0005,

  spawn_entity = "fire-flame-on-tree",

  spread_delay = 300,
  spread_delay_deviation = 180,
  maximum_spread_count = 100,

  emissions_per_second = 0.005,

  initial_lifetime = 3600,
  lifetime_increase_by = 150,
  lifetime_increase_cooldown = 4,
  maximum_lifetime = 3600,
  delay_between_initial_flames = 10,
  --initial_flame_count = 1,

}})



local radiation_cloud_vis_dum = table.deepcopy(data.raw["smoke-with-trigger"]["poison-cloud-visual-dummy"])
radiation_cloud_vis_dum.name="radiation-cloud-visual-dummy"
radiation_cloud_vis_dum.color = {r = 0.220, g = 0.220, b = 0.220, a = 0.800}
radiation_cloud_vis_dum.duration=60*60

local radiation_cloud = table.deepcopy(data.raw["smoke-with-trigger"]["poison-cloud"])
radiation_cloud.name="dangerous-radiation-cloud"
radiation_cloud.action.action_delivery.target_effects.action.action_delivery.target_effects.damage.amount=20
radiation_cloud.color = {r = 0.220, g = 0.220, b = 0.220, a = 0.800}
radiation_cloud.created_effect[1].action_delivery.target_effects[1].entity_name = "radiation-cloud-visual-dummy"
radiation_cloud.created_effect[2].action_delivery.target_effects[1].entity_name = "radiation-cloud-visual-dummy"
radiation_cloud.duration=60*60

local fallout = 
  {
    type = "projectile",
    name = "fallout",
    flags = {"not-on-map"},
    acceleration = 0.005,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects ={
          {
            type = "create-entity",
            entity_name = "dangerous-radiation-cloud"
          },
          {
            type = "create-entity",
            entity_name = "radiation-cloud"
          }
        }
      }
    },
    animation =
    {
      filename = "__core__/graphics/empty.png",
      frame_count = 1,
      width = 1,
      height = 1,
      priority = "high"
    }
  }



local lingering_radiation_cloud_vis_dum = table.deepcopy(data.raw["smoke-with-trigger"]["poison-cloud-visual-dummy"])
lingering_radiation_cloud_vis_dum.name="lingering-radiation-cloud-visual-dummy"
lingering_radiation_cloud_vis_dum.color = {r = 0.220, g = 0.220, b = 0.220, a = 0.800}
lingering_radiation_cloud_vis_dum.duration=60*300
lingering_radiation_cloud_vis_dum.fade_away_duration = 60 * 60


local lingering_radiation_cloud = table.deepcopy(data.raw["smoke-with-trigger"]["poison-cloud"])
lingering_radiation_cloud.name="lingering-radiation-cloud"
lingering_radiation_cloud.color = {r = 0.220, g = 0.220, b = 0.220, a = 0.800}
lingering_radiation_cloud.duration=60*300
lingering_radiation_cloud.fade_away_duration = 40 * 60
lingering_radiation_cloud.created_effect[1].action_delivery.target_effects[1].entity_name = "lingering-radiation-cloud-visual-dummy"
lingering_radiation_cloud.created_effect[2].action_delivery.target_effects[1].entity_name = "lingering-radiation-cloud-visual-dummy"

local lingering_fallout = 
  {
    type = "projectile",
    name = "lingering-fallout",
    flags = {"not-on-map"},
    acceleration = 0.005,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          type = "create-entity",
          entity_name = "lingering-radiation-cloud"
        }
      }
    },
    animation =
    {
      filename = "__core__/graphics/empty.png",
      frame_count = 1,
      width = 1,
      height = 1,
      priority = "high"
    }
  }

data:extend{radiation_cloud_vis_dum, radiation_cloud, fallout, lingering_radiation_cloud_vis_dum, lingering_radiation_cloud, lingering_fallout}





if(settings.startup["enable-very-small-atomic-artillery"].value or settings.startup["enable-small-atomic-artillery"].value
		or settings.startup["enable-atomic-artillery"].value or settings.startup["enable-big-atomic-artillery"].value or settings.startup["enable-very-big-atomic-artillery"].value) then
	require("data-nukes-artillery")
end






local big_atomic_bomb_recipe = {
    type = "recipe",
    name = "big-atomic-bomb",
    enabled = false,
    energy_required = 300,
    ingredients =
    {
      {"atomic-bomb", 1},
      {"processing-unit", 10},
      {nuke_materials.boomMaterial, 75},
      {"explosives", 10},
      {"rocket-fuel", 20}
    },
    result = "big-atomic-bomb"
  }

local  big_atomic_bomb_item = table.deepcopy(data.raw["ammo"]["atomic-bomb"])
big_atomic_bomb_item.name = "big-atomic-bomb"
big_atomic_bomb_item.order = "d[rocket-launcher]-c[big-atomic-bomb]"
big_atomic_bomb_item.ammo_type.range_modifier = 10
big_atomic_bomb_item.ammo_type.cooldown_modifier = 10
big_atomic_bomb_item.ammo_type.action.action_delivery.starting_speed = 0.025
big_atomic_bomb_item.ammo_type.action.action_delivery.projectile = "big-atomic-bomb-projectile"
big_atomic_bomb_item.icon = "__True-Nukes__/graphics/big-atomic-bomb.png"
big_atomic_bomb_item.stack_size = 5
if mods["SchallTankPlatoon"] then
	big_atomic_bomb_item.order = "d[rocket-launcher]-n[very-big-atomic-bomb]"
end
big_atomic_bomb_item.pictures.layers[1].filename="__True-Nukes__/graphics/big-atomic-bomb.png"
big_atomic_bomb_item.pictures.layers[1].mipmap_count = 4
big_atomic_bomb_item.pictures.layers[2].filename="__True-Nukes__/graphics/rocket-light-2.png"
big_atomic_bomb_item.pictures.layers[2].mipmap_count = 4

local big_atomic_bomb_projectile = table.deepcopy(data.raw["projectile"]["atomic-rocket"])
big_atomic_bomb_projectile.name = "big-atomic-bomb-projectile"
big_atomic_bomb_projectile.action.action_delivery.target_effects = nuke_explosions.N500t_detonation
big_atomic_bomb_projectile.created_effect = {
					  type = "direct",
					  action_delivery =
					  {
						type = "instant",
						target_effects = {
				            type = "script",
							effect_id = "Nuke firing"
				          }
					  }
                  }

if(settings.startup["enable-big-atomic-bomb"].value) then
	data:extend{big_atomic_bomb_recipe, big_atomic_bomb_item, big_atomic_bomb_projectile}
end









local very_big_atomic_bomb_recipe = {
    type = "recipe",
    name = "very-big-atomic-bomb",
    enabled = false,
    energy_required = 300,
    ingredients =
    {
      {"atomic-bomb", 1},
      {"processing-unit", 20},
      {nuke_materials.boomMaterial, 100},
      {"explosives", 10},
      {"rocket-fuel", 50}
    },
    result = "very-big-atomic-bomb"
  }

local  very_big_atomic_bomb_item = table.deepcopy(data.raw["ammo"]["atomic-bomb"])
very_big_atomic_bomb_item.name = "very-big-atomic-bomb"
very_big_atomic_bomb_item.order = "d[rocket-launcher]-c[very-big-atomic-bomb]"
very_big_atomic_bomb_item.ammo_type.range_modifier = 30
very_big_atomic_bomb_item.ammo_type.cooldown_modifier = 30
very_big_atomic_bomb_item.ammo_type.action.action_delivery.projectile = "very-big-atomic-bomb-projectile"
very_big_atomic_bomb_item.ammo_type.action.action_delivery.starting_speed = 0.01
very_big_atomic_bomb_item.icon = "__True-Nukes__/graphics/very-big-atomic-bomb.png"
very_big_atomic_bomb_item.stack_size = 1
very_big_atomic_bomb_item.pictures.layers[1].filename="__True-Nukes__/graphics/very-big-atomic-bomb.png"
very_big_atomic_bomb_item.pictures.layers[1].mipmap_count = 4
very_big_atomic_bomb_item.pictures.layers[2].filename="__True-Nukes__/graphics/rocket-light-3.png"
very_big_atomic_bomb_item.pictures.layers[2].mipmap_count = 4

if mods["SchallTankPlatoon"] then
	very_big_atomic_bomb_item.order = "d[rocket-launcher]-n[very-big-atomic-bomb]"
end
local very_big_atomic_bomb_projectile = table.deepcopy(data.raw["projectile"]["atomic-rocket"])
very_big_atomic_bomb_projectile.name = "very-big-atomic-bomb-projectile"
very_big_atomic_bomb_projectile.action.action_delivery.target_effects = nuke_explosions.N1kt_detonation
very_big_atomic_bomb_projectile.created_effect = {
					  type = "direct",
					  action_delivery =
					  {
						type = "instant",
						target_effects = {
				            type = "script",
							effect_id = "Nuke firing"
				          }
					  }
                  }


if(settings.startup["enable-very-big-atomic-bomb"].value) then
	data:extend{very_big_atomic_bomb_recipe, very_big_atomic_bomb_item, very_big_atomic_bomb_projectile}
end







if(settings.startup["enable-big-atomic-ammo"].value or settings.startup["enable-big-atomic-cannons"].value
    	or settings.startup["enable-big-atomic-bomb"].value or settings.startup["enable-very-big-atomic-bomb"].value
    	or settings.startup["enable-big-atomic-artillery"].value or settings.startup["enable-very-big-atomic-artillery"].value) then
	local scary_nuke_tech = table.deepcopy(data.raw["technology"]["atomic-bomb"])
	scary_nuke_tech.name = "scary-atomic-weapons"
	scary_nuke_tech.effects = {}
	
	if (settings.startup["enable-big-atomic-bomb"].value) then
		table.insert(scary_nuke_tech.effects, 
		  {
		    type = "unlock-recipe",
		    recipe = "big-atomic-bomb"
		  })
	end
	if (settings.startup["enable-very-big-atomic-bomb"].value) then
		table.insert(scary_nuke_tech.effects, 
		  {
		    type = "unlock-recipe",
		    recipe = "very-big-atomic-bomb"
		  })
	end
	if (settings.startup["enable-big-atomic-artillery"].value or settings.startup["enable-very-big-atomic-artillery"].value) then
		table.insert(scary_nuke_tech.effects, 
		  {
		    type = "unlock-recipe",
		    recipe = "TN-big-atomic-artillery-shell"
		  })
	end
	scary_nuke_tech.unit.count=1000
	scary_nuke_tech.unit.ingredients = {
		    {"automation-science-pack", 1},
		    {"logistic-science-pack", 1},
		    {"chemical-science-pack", 1},
		    {"military-science-pack", 1},
		    {"production-science-pack", 1},
		    {"utility-science-pack", 1},
		    {"space-science-pack", 1}
		  }
    scary_nuke_tech.order = "e-b-a"
	scary_nuke_tech.prerequisites = {} -- "atomic-artillery-shells", "californium-processing"
	if(settings.startup["enable-atomic-ammo"].value or settings.startup["enable-big-atomic-ammo"].value
			or settings.startup["enable-atomic-cannons"].value or settings.startup["enable-big-atomic-cannons"].value) then
		table.insert(scary_nuke_tech.prerequisites, "californium-processing")
		if(settings.startup["enable-small-atomic-artillery"].value or settings.startup["enable-atomic-artillery"].value
    			or settings.startup["enable-big-atomic-artillery"].value or settings.startup["enable-very-big-atomic-artillery"].value) then
			table.insert(scary_nuke_tech.prerequisites, "atomic-artillery-shells")
		end
	elseif(settings.startup["enable-small-atomic-artillery"].value or settings.startup["enable-atomic-artillery"].value
    	or settings.startup["enable-big-atomic-artillery"].value or settings.startup["enable-very-big-atomic-artillery"].value) then
		table.insert(scary_nuke_tech.prerequisites, "atomic-artillery-shells")
	else
		table.insert(scary_nuke_tech.prerequisites, "atomic-bomb")
	end
	scary_nuke_tech.icon = "__True-Nukes__/graphics/scary-atomic-tech.png"
	scary_nuke_tech.icon_mipmaps = 1
	data:extend{scary_nuke_tech}
end

if(settings.startup["enable-atomic-ammo"].value or settings.startup["enable-big-atomic-ammo"].value
    	or settings.startup["enable-atomic-cannons"].value or settings.startup["enable-big-atomic-cannons"].value) then
	require("data-nukes-californium")
end

if(settings.startup["enable-very-big-atomic-artillery"].value or settings.startup["enable-fusion-building"].value or settings.startup["enable-mega-fusion-building"].value) then
	require("data-nukes-huge")
end






if ((settings.startup["enable-atomic-cannons"].value or settings.startup["enable-big-atomic-cannons"].value) and mods["SchallTankPlatoon"] )then
  require("data-nukes-schall")
end
if(settings.startup["enable-fire-shield"].value) then
	table.insert(data.raw.technology["atomic-bomb"].effects, {
        type = "unlock-recipe",
        recipe = "fire-shield-equipment"
      })
end
      
