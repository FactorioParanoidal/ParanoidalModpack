local fireutil = require("__base__.prototypes.fire-util")
local nuke_explosions = require("data-nuke-explosions")

local nuke_materials = require("data-nukes-material")

local circuit_type;
local upgrade_circuit_mult = 5
if not mods["bobelectronics"] then
	circuit_type = "processing-unit"
else
	circuit_type = "superior-circuit-board"
	upgrade_circuit_mult = 1
end

local material = nuke_materials.smallBoomMaterial;
if(material == "californium") then
	data:extend({
	  {
	    type = "item",
	    name = "californium",
	    icon = "__True-Nukes__/graphics/californium.png",
	    icon_size = 64, icon_mipmaps = 4,
		pictures =
		{
		  layers =
		  {
		    {
		      size = 64,
		      filename = "__True-Nukes__/graphics/californium.png",
		      scale = 0.25,
		      mipmap_count = 4
		    },
		    {
		      draw_as_light = true,
		      blend_mode = "additive",
		      size = 64,
		      filename = "__base__/graphics/icons/uranium-235.png",
		      scale = 0.25,
		      tint = {r = 0.8, g = 0.8, b = 0.1, a = 0.8},
		      mipmap_count = 4
		    }
		  }
		},
	    subgroup = "intermediate-product",
	    order = "r[z-californium]",
	    stack_size = 100
	  },
	  {
	    type = "recipe",
	    name = "californium-processing",
	    energy_required = 120,
	    enabled = false,
	    category = "centrifuging",
	    ingredients = {{nuke_materials.boomMaterial, 10}, {nuke_materials.deadMaterial, 1}},
	    icon = "__True-Nukes__/graphics/californium-processing.png",
	    icon_size = 64, icon_mipmaps = 4,
	    subgroup = "intermediate-product",
	    order = "r[uranium-processing]-d[californium-processing]",
	    main_product = "californium",
	    results = {{nuke_materials.boomMaterial, 9}, {"californium", 1}},
	    allow_decomposition = false
	  },

	});
end


local atomic_ammo_recipe = {
    type = "recipe",
    name = "atomic-rounds-magazine",
    enabled = false,
    energy_required = 120,
    ingredients =
    {
      {"uranium-rounds-magazine", 1},
      {"low-density-structure", 10},
      {material, 10},
      {circuit_type, 2}
    },
    result = "atomic-rounds-magazine"
  }
local  atomic_ammo_item = {
    type = "ammo",
    name = "atomic-rounds-magazine",
    icon = "__True-Nukes__/graphics/atomic-rounds-magazine.png",
    icon_size = 64, icon_mipmaps = 4,
	pictures = {
      layers =
      {
        {
          size = 64,
          filename = "__True-Nukes__/graphics/atomic-rounds-magazine.png",
          scale = 0.25,
          mipmap_count = 4
        },
        {
          draw_as_light = true,
          flags = {"light"},
          size = 64,
          filename = "__True-Nukes__/graphics/atomic-rounds-magazine-light.png",
          scale = 0.25,
          mipmap_count = 4
        }
      }
    },
    ammo_type =
    {
      cooldown_modifier = 2.5,
      category = "bullet",
      target_type = "position",
      clamp_position = true,
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          source_effects =
          {
            type = "create-explosion",
            entity_name = "explosion-gunshot"
          },
          target_effects = nuke_explosions.N0_1t_detonation
        }
      }
    },
    magazine_size = 10,
    subgroup = "ammo",
    order = "a[basic-clips]-d[atomic-rounds-magazine]",
    stack_size = 20
  }


if(settings.startup["enable-atomic-ammo"].value or settings.startup["enable-big-atomic-ammo"].value) then
	data:extend{atomic_ammo_recipe, atomic_ammo_item}
end

local big_atomic_ammo_recipe = {
    type = "recipe",
    name = "big-atomic-rounds-magazine",
    enabled = false,
    energy_required = 240,
    ingredients =
    {
      {"atomic-rounds-magazine", 1},
      {"low-density-structure", 10},
      {material, 20},
      {"processing-unit", 2*upgrade_circuit_mult}
    },
    result = "big-atomic-rounds-magazine"
  }
local  big_atomic_ammo_item = {
    type = "ammo",
    name = "big-atomic-rounds-magazine",
    icon = "__True-Nukes__/graphics/big-atomic-rounds-magazine.png",
    icon_size = 64, icon_mipmaps = 4,
	pictures = {
      layers =
      {
        {
          size = 64,
          filename = "__True-Nukes__/graphics/big-atomic-rounds-magazine.png",
          scale = 0.25,
          mipmap_count = 4
        },
        {
          draw_as_light = true,
          flags = {"light"},
          size = 64,
          filename = "__True-Nukes__/graphics/atomic-rounds-magazine-light.png",
          scale = 0.25,
          mipmap_count = 4
        }
      }
    },
    ammo_type =
    {
      cooldown_modifier = 5,
      category = "bullet",
      target_type = "position",
      clamp_position = true,
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          source_effects =
          {
            type = "create-explosion",
            entity_name = "explosion-gunshot"
          },
          target_effects = nuke_explosions.N0_5t_detonation
        }
      }
    },
    magazine_size = 10,
    subgroup = "ammo",
    order = "a[basic-clips]-d[big-atomic-rounds-magazine]",
    stack_size = 10
  }


if(settings.startup["enable-big-atomic-ammo"].value) then
	data:extend{big_atomic_ammo_recipe, big_atomic_ammo_item}
end

local atomic_cannon_recipe = {
    type = "recipe",
    name = "atomic-cannon-shell",
    enabled = false,
    energy_required = 60,
    ingredients =
    {
      {"explosive-uranium-cannon-shell", 1},
      {"explosives", 5},
      {material, 10},
      {circuit_type, 5}
    },
    result = "atomic-cannon-shell"
  }

local  atomic_cannon_item = table.deepcopy(data.raw["ammo"]["explosive-uranium-cannon-shell"])
atomic_cannon_item.name = "atomic-cannon-shell"
atomic_cannon_item.collision_box = {{0, 0}, {0, 0}}
atomic_cannon_item.order = "d[explosive-cannon-shell]-dA[nuclear]"
atomic_cannon_item.ammo_type.range_modifier = 3
atomic_cannon_item.ammo_type.action.action_delivery.max_range = 90
atomic_cannon_item.ammo_type.cooldown_modifier = 5
atomic_cannon_item.stack_size = 50
atomic_cannon_item.ammo_type.action.action_delivery.projectile = "atomic-cannon-projectile"
atomic_cannon_item.icon = "__True-Nukes__/graphics/atomic-cannon-shell.png"
atomic_cannon_item.pictures.layers[1].filename="__True-Nukes__/graphics/atomic-cannon-shell.png"
atomic_cannon_item.pictures.layers[2].filename="__True-Nukes__/graphics/atomic-cannon-shell-light.png"

local atomic_cannon_projectile = table.deepcopy(data.raw["projectile"]["explosive-uranium-cannon-projectile"])
atomic_cannon_projectile.name = "atomic-cannon-projectile"
atomic_cannon_projectile.collision_box = {{0, 0}, {0, 0}}
atomic_cannon_projectile.final_action = {
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects = nuke_explosions.N2t_detonation
  }
}
if(settings.startup["enable-atomic-cannons"].value or settings.startup["enable-big-atomic-cannons"].value) then
	data:extend{atomic_cannon_recipe, atomic_cannon_item, atomic_cannon_projectile}
end
local big_atomic_cannon_recipe = {
    type = "recipe",
    name = "big-atomic-cannon-shell",
    enabled = false,
    energy_required = 120,
    ingredients =
    {
      {"atomic-cannon-shell", 1},
      {material, 15},
      {"low-density-structure", 10},
      {"processing-unit", 3*upgrade_circuit_mult}
    },
    result = "big-atomic-cannon-shell"
  }

local  big_atomic_cannon_item = table.deepcopy(data.raw["ammo"]["explosive-uranium-cannon-shell"])
big_atomic_cannon_item.name = "big-atomic-cannon-shell"
big_atomic_cannon_item.order = "d[explosive-cannon-shell]-dB[nuclear]"
big_atomic_cannon_item.ammo_type.range_modifier = 5
big_atomic_cannon_item.ammo_type.action.action_delivery.max_range = 150
big_atomic_cannon_item.ammo_type.cooldown_modifier = 10
big_atomic_cannon_item.stack_size = 20
big_atomic_cannon_item.ammo_type.action.action_delivery.projectile = "big-atomic-cannon-projectile"
big_atomic_cannon_item.icon = "__True-Nukes__/graphics/big-atomic-cannon-shell.png"
big_atomic_cannon_item.pictures.layers[1].filename="__True-Nukes__/graphics/big-atomic-cannon-shell.png"
big_atomic_cannon_item.pictures.layers[2].filename="__True-Nukes__/graphics/atomic-cannon-shell-light.png"


local big_atomic_cannon_projectile = table.deepcopy(data.raw["projectile"]["explosive-uranium-cannon-projectile"])
big_atomic_cannon_projectile.name = "big-atomic-cannon-projectile"
big_atomic_cannon_projectile.collision_box = {{0, 0}, {0, 0}}
big_atomic_cannon_projectile.final_action = {
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects = nuke_explosions.N4t_detonation
  }
}
if(settings.startup["enable-big-atomic-cannons"].value) then
	data:extend{big_atomic_cannon_recipe, big_atomic_cannon_item, big_atomic_cannon_projectile}
end




local small_atomic_bomb_recipe = {
    type = "recipe",
    name = "small-atomic-bomb",
    enabled = false,
    energy_required = 120,
    ingredients =
    {
      {"plastic-bar", 20},
      {"explosives", 5},
      {material, 20},
      {circuit_type, 10},
      {"rocket-fuel", 5}
    },
    result = "small-atomic-bomb"
  }

if(settings.startup["enable-small-atomic-bomb"].value or settings.startup["enable-very-small-atomic-bomb"].value or settings.startup["enable-really-very-small-atomic-bomb"].value) then
	data.raw["ammo"]["rocket"].icon = "__True-Nukes__/graphics/rocket.png"
end

local  small_atomic_bomb_item = table.deepcopy(data.raw["ammo"]["atomic-bomb"])
small_atomic_bomb_item.name = "small-atomic-bomb"
small_atomic_bomb_item.order = "d[rocket-launcher]-c[ small-atomic-bomb]"
small_atomic_bomb_item.ammo_type.range_modifier = 3
small_atomic_bomb_item.ammo_type.cooldown_modifier = 5
small_atomic_bomb_item.ammo_type.action.action_delivery.starting_speed = 0.025
small_atomic_bomb_item.ammo_type.action.action_delivery.projectile = "small-atomic-bomb-projectile"
small_atomic_bomb_item.icon = "__True-Nukes__/graphics/small-3-atomic-bomb.png"
small_atomic_bomb_item.icon_mipmaps = 4
small_atomic_bomb_item.stack_size = 10
small_atomic_bomb_item.pictures.layers[1].filename="__True-Nukes__/graphics/small-3-atomic-bomb.png"
small_atomic_bomb_item.pictures.layers[1].mipmap_count = 4
small_atomic_bomb_item.pictures.layers[2].filename="__True-Nukes__/graphics/rocket-light-3.png"
small_atomic_bomb_item.pictures.layers[2].mipmap_count = 4

if mods["SchallTankPlatoon"] then
	small_atomic_bomb_item.order = "d[rocket-launcher]-n[ small-atomic-bomb]"
end

local small_atomic_bomb_projectile = table.deepcopy(data.raw["projectile"]["atomic-rocket"])
small_atomic_bomb_projectile.name = "small-atomic-bomb-projectile"
small_atomic_bomb_projectile.action.action_delivery.target_effects = nuke_explosions.N8t_detonation

if(settings.startup["enable-small-atomic-bomb"].value) then
	data:extend{small_atomic_bomb_recipe, small_atomic_bomb_item, small_atomic_bomb_projectile}
end

local very_small_atomic_bomb_recipe = {
    type = "recipe",
    name = "very-small-atomic-bomb",
    enabled = false,
    energy_required = 120,
    ingredients =
    {
      {"plastic-bar", 20},
      {"explosives", 5},
      {material, 15},
      {circuit_type, 5},
      {"rocket-fuel", 3}
    },
    result = "very-small-atomic-bomb"
  }

local  very_small_atomic_bomb_item = table.deepcopy(data.raw["ammo"]["atomic-bomb"])
very_small_atomic_bomb_item.name = "very-small-atomic-bomb"
very_small_atomic_bomb_item.order = "d[rocket-launcher]-c[ avery-small-atomic-bomb]"
very_small_atomic_bomb_item.ammo_type.range_modifier = 2
very_small_atomic_bomb_item.ammo_type.cooldown_modifier = 3
very_small_atomic_bomb_item.ammo_type.action.action_delivery.starting_speed = 0.05
very_small_atomic_bomb_item.ammo_type.action.action_delivery.projectile = "very-small-atomic-bomb-projectile"
very_small_atomic_bomb_item.icon = "__True-Nukes__/graphics/small-2-atomic-bomb.png"
very_small_atomic_bomb_item.icon_mipmaps = 4
very_small_atomic_bomb_item.stack_size = 20
very_small_atomic_bomb_item.pictures.layers[1].filename="__True-Nukes__/graphics/small-2-atomic-bomb.png"
very_small_atomic_bomb_item.pictures.layers[1].mipmap_count = 4
very_small_atomic_bomb_item.pictures.layers[2].filename="__True-Nukes__/graphics/rocket-light-2.png"
very_small_atomic_bomb_item.pictures.layers[2].mipmap_count = 4

if mods["SchallTankPlatoon"] then
	very_small_atomic_bomb_item.order = "d[rocket-launcher]-n[ avery-small-atomic-bomb]"
end

local very_small_atomic_bomb_projectile = table.deepcopy(data.raw["projectile"]["atomic-rocket"])
very_small_atomic_bomb_projectile.name = "very-small-atomic-bomb-projectile"
very_small_atomic_bomb_projectile.action.action_delivery.target_effects = nuke_explosions.N4t_detonation

if(settings.startup["enable-very-small-atomic-bomb"].value) then
	data:extend{very_small_atomic_bomb_recipe, very_small_atomic_bomb_item, very_small_atomic_bomb_projectile}
end

local really_very_small_atomic_bomb_recipe = {
    type = "recipe",
    name = "really-very-small-atomic-bomb",
    enabled = false,
    energy_required = 120,
    ingredients =
    {
      {"plastic-bar", 20},
      {"explosives", 5},
      {material, 10},
      {circuit_type, 5},
      {"rocket-fuel", 2}
    },
    result = "really-very-small-atomic-bomb"
  }

local  really_very_small_atomic_bomb_item = table.deepcopy(data.raw["ammo"]["atomic-bomb"])
really_very_small_atomic_bomb_item.name = "really-very-small-atomic-bomb"
really_very_small_atomic_bomb_item.order = "d[rocket-launcher]-c[ areally-very-small-atomic-bomb]"
really_very_small_atomic_bomb_item.ammo_type.range_modifier = 1.5
really_very_small_atomic_bomb_item.ammo_type.cooldown_modifier = 1.5
really_very_small_atomic_bomb_item.ammo_type.action.action_delivery.projectile = "really-very-small-atomic-bomb-projectile"
really_very_small_atomic_bomb_item.icon = "__True-Nukes__/graphics/small-1-atomic-bomb.png"
really_very_small_atomic_bomb_item.icon_mipmaps = 4
really_very_small_atomic_bomb_item.stack_size = 50
really_very_small_atomic_bomb_item.pictures.layers[1].filename="__True-Nukes__/graphics/small-1-atomic-bomb.png"
really_very_small_atomic_bomb_item.pictures.layers[2].filename="__True-Nukes__/graphics/rocket-light-1.png"
really_very_small_atomic_bomb_item.pictures.layers[1].mipmap_count = 4
really_very_small_atomic_bomb_item.pictures.layers[2].mipmap_count = 4

if mods["SchallTankPlatoon"] then
	really_very_small_atomic_bomb_item.order = "d[rocket-launcher]-n[ areally-very-small-atomic-bomb]"
end

local really_very_small_atomic_bomb_projectile = table.deepcopy(data.raw["projectile"]["atomic-rocket"])
really_very_small_atomic_bomb_projectile.name = "really-very-small-atomic-bomb-projectile"
really_very_small_atomic_bomb_projectile.action.action_delivery.target_effects = nuke_explosions.N2t_detonation

if(settings.startup["enable-really-very-small-atomic-bomb"].value) then
	data:extend{really_very_small_atomic_bomb_recipe, really_very_small_atomic_bomb_item, really_very_small_atomic_bomb_projectile}
end

data:extend{
  {
    type = "technology",
    name = "californium-processing",
    icon_size = 256, icon_mipmaps = 4,
    icon = "__True-Nukes__/graphics/californium-processing-tech.png",
    effects = {},
    prerequisites = { "atomic-bomb"},
    unit =
    {
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1}
      },
      time = 30,
      count = 500
    },
    order = "e-a-d"
  }
}

if mods["apm_nuclear_ldinc"] then
	table.insert(data.raw.technology["californium-processing"].prerequisites, "apm_nuclear_breeder");
elseif mods["Nuclear Fuel"] then
	table.insert(data.raw.technology["californium-processing"].prerequisites, "plutonium-breeding");
elseif mods["Clowns-AngelBob-Nuclear"] then
	table.insert(data.raw.technology["californium-processing"].prerequisites, "nuclear-fuel-reprocessing-2");
else
	table.insert(data.raw.technology["californium-processing"].prerequisites, "kovarex-enrichment-process");
end

if(settings.startup["enable-atomic-ammo"].value or settings.startup["enable-big-atomic-ammo"].value) then
	table.insert(data.raw.technology["californium-processing"].effects, 
	  {
	    type = "unlock-recipe",
	    recipe = "atomic-rounds-magazine"
	  })
	  
end
if(settings.startup["enable-atomic-cannons"].value or settings.startup["enable-big-atomic-cannons"].value) then
	table.insert(data.raw.technology["californium-processing"].effects, 
	  {
	    type = "unlock-recipe",
	    recipe = "atomic-cannon-shell"
	  })
end
if(settings.startup["enable-really-very-small-atomic-bomb"].value) then
	table.insert(data.raw.technology["californium-processing"].effects, {
	        type = "unlock-recipe",
	        recipe = "really-very-small-atomic-bomb"
 	     })
end
if(settings.startup["enable-very-small-atomic-bomb"].value) then
	table.insert(data.raw.technology["scary-atomic-weapons"].effects, {
	        type = "unlock-recipe",
	        recipe = "very-small-atomic-bomb"
 	     })
end
if(settings.startup["enable-small-atomic-bomb"].value) then
	table.insert(data.raw.technology["scary-atomic-weapons"].effects, {
	        type = "unlock-recipe",
	        recipe = "small-atomic-bomb"
 	     })
end
if(material == "californium") then
	table.insert(data.raw.technology["californium-processing"].effects, {
	        type = "unlock-recipe",
	        recipe = "californium-processing"
 	     })
end

if(settings.startup["enable-big-atomic-ammo"].value) then
	table.insert(data.raw.technology["scary-atomic-weapons"].effects, 1, {
		    type = "unlock-recipe",
		    recipe = "big-atomic-rounds-magazine"
		  })
end
if(settings.startup["enable-big-atomic-cannons"].value) then
	table.insert(data.raw.technology["scary-atomic-weapons"].effects, 2, {
			type = "unlock-recipe",
			recipe = "big-atomic-cannon-shell"
		  })
end


