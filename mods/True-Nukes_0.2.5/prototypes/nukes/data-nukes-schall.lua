local fireutil = require("__base__.prototypes.fire-util")
local nuke_explosions = require("data-nuke-explosions")



local circuit_type;
local upgrade_circuit_mult = 4
if not mods["bobelectronics"] then
	circuit_type = "processing-unit"
else
	circuit_type = "superior-circuit-board"
	upgrade_circuit_mult = 1
end
local material;
if(settings.startup["use-californium"].value) then
	material = "californium"
else
	material = "uranium-235"
end

local atomic_autocannon_recipe = {
    type = "recipe",
    name = "atomic-autocannon-shell",
    enabled = false,
    energy_required = 60,
    ingredients =
    {
      {"explosive-autocannon-shell", 1},
      {"explosives", 10},
      {material, 20},
      {"uranium-238", 5},
      {circuit_type, 20}
    },
    result = "atomic-autocannon-shell"
  }

local  atomic_autocannon_item = table.deepcopy(data.raw["ammo"]["explosive-autocannon-shell"])
atomic_autocannon_item.name = "atomic-autocannon-shell"
atomic_autocannon_item.order = "d[f-explosive-autocannon-shell]-h[nuclear]"
atomic_autocannon_item.ammo_type.range_modifier = 2
atomic_autocannon_item.ammo_type.action.action_delivery.max_range = atomic_autocannon_item.ammo_type.action.action_delivery.max_range*2
atomic_autocannon_item.ammo_type.cooldown_modifier = 5
atomic_autocannon_item.ammo_type.action.action_delivery.projectile = "atomic-autocannon-projectile"
atomic_autocannon_item.icons[1] = {icon = "__True-Nukes__/graphics/atomic-autocannon-shell.png", icon_size = 64, icon_mipmaps = 4}
atomic_autocannon_item.pictures = {
	  layers =
	  {
	    {
	      size = 64,
	      filename = "__True-Nukes__/graphics/atomic-autocannon-shell.png",
	      scale = 0.25,
	      mipmap_count = 4
	    },
	    {
	      draw_as_light = true,
	      flags = {"light"},
	      size = 64,
	      filename = "__True-Nukes__/graphics/atomic-autocannon-shell-light.png",
	      scale = 0.25,
	      mipmap_count = 4
	    }
	  }
	}

local atomic_autocannon_projectile = table.deepcopy(data.raw["projectile"]["explosive-autocannon-projectile"])
atomic_autocannon_projectile.name = "atomic-autocannon-projectile"
atomic_autocannon_projectile.collision_box = {{0, 0}, {0, 0}}
atomic_autocannon_projectile.final_action = {
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects = nuke_explosions.N0_5t_detonation
  }
}
data:extend{atomic_autocannon_recipe, atomic_autocannon_item, atomic_autocannon_projectile}

local atomic_cannon_H1_recipe = {
    type = "recipe",
    name = "atomic-cannon-H1-shell",
    enabled = false,
    energy_required = 60,
    ingredients =
    {
      {"explosive-uranium-cannon-H1-shell", 1},
      {"explosives", 5},
      {material, 15},
      {circuit_type, 5}
    },
    result = "atomic-cannon-H1-shell"
  }

local  atomic_cannon_H1_item = table.deepcopy(data.raw["ammo"]["cannon-H1-shell"])
atomic_cannon_H1_item.name = "atomic-cannon-H1-shell"
atomic_cannon_H1_item.order = "d[explosive-cannon-shell]-dA[nuclear]-1"
atomic_cannon_H1_item.ammo_type.range_modifier = 3
atomic_cannon_H1_item.ammo_type.action.action_delivery.max_range = atomic_cannon_H1_item.ammo_type.action.action_delivery.max_range*3
atomic_cannon_H1_item.ammo_type.cooldown_modifier = 3
atomic_cannon_H1_item.ammo_type.action.action_delivery.projectile = "atomic-cannon-H1-projectile"
atomic_cannon_H1_item.icons[1] = {icon = "__True-Nukes__/graphics/atomic-cannon-shell.png", icon_size = 64, icon_mipmaps = 4}
atomic_cannon_H1_item.pictures = {
	  layers =
	  {
	    {
	      size = 64,
	      filename = "__True-Nukes__/graphics/atomic-cannon-shell.png",
	      scale = 0.25,
	      mipmap_count = 4
	    },
	    {
	      size = 128,
	      filename = "__SchallTankPlatoon__/graphics/icons/H1.png",
	      scale = 0.125,
	      mipmap_count = 3
	    },
	    {
	      draw_as_light = true,
	      flags = {"light"},
	      size = 64,
	      filename = "__True-Nukes__/graphics/atomic-cannon-shell-light.png",
	      scale = 0.25,
	      mipmap_count = 4
	    }
	  }
	}
local atomic_cannon_H1_projectile = table.deepcopy(data.raw["projectile"]["explosive-cannon-H1-projectile"])
atomic_cannon_H1_projectile.name = "atomic-cannon-H1-projectile"
atomic_cannon_H1_projectile.collision_box = {{0, 0}, {0, 0}}
atomic_cannon_H1_projectile.final_action = {
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects = nuke_explosions.N4t_detonation
  }
}
data:extend{atomic_cannon_H1_recipe, atomic_cannon_H1_item, atomic_cannon_H1_projectile}

local atomic_cannon_H2_recipe = {
    type = "recipe",
    name = "atomic-cannon-H2-shell",
    enabled = false,
    energy_required = 60,
    ingredients =
    {
      {"explosive-uranium-cannon-H2-shell", 1},
      {"explosives", 5},
      {material, 20},
      {circuit_type, 10}
    },
    result = "atomic-cannon-H2-shell"
  }

local  atomic_cannon_H2_item = table.deepcopy(data.raw["ammo"]["explosive-cannon-H2-shell"])
atomic_cannon_H2_item.name = "atomic-cannon-H2-shell"
atomic_cannon_H2_item.order = "d[explosive-cannon-shell]-dA[nuclear]-1"
atomic_cannon_H2_item.ammo_type.range_modifier = 3
atomic_cannon_H2_item.ammo_type.action.action_delivery.max_range = atomic_cannon_H2_item.ammo_type.action.action_delivery.max_range*3
atomic_cannon_H2_item.ammo_type.cooldown_modifier = 3
atomic_cannon_H2_item.ammo_type.action.action_delivery.projectile = "atomic-cannon-H2-projectile"
atomic_cannon_H2_item.icons[1] = {icon = "__True-Nukes__/graphics/atomic-cannon-shell.png", icon_size = 64, icon_mipmaps = 4}
atomic_cannon_H2_item.pictures = {
	  layers =
	  {
	    {
	      size = 64,
	      filename = "__True-Nukes__/graphics/atomic-cannon-shell.png",
	      scale = 0.25,
	      mipmap_count = 4
	    },
	    {
	      size = 128,
	      filename = "__SchallTankPlatoon__/graphics/icons/H2.png",
	      scale = 0.125,
	      mipmap_count = 3
	    },
	    {
	      draw_as_light = true,
	      flags = {"light"},
	      size = 64,
	      filename = "__True-Nukes__/graphics/atomic-cannon-shell-light.png",
	      scale = 0.25,
	      mipmap_count = 4
	    }
	  }
	}


local atomic_cannon_H2_projectile = table.deepcopy(data.raw["projectile"]["explosive-cannon-H2-projectile"])
atomic_cannon_H2_projectile.name = "atomic-cannon-H2-projectile"
atomic_cannon_H2_projectile.collision_box = {{0, 0}, {0, 0}}
atomic_cannon_H2_projectile.final_action = {
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects = nuke_explosions.N8t_detonation
  }
}
data:extend{atomic_cannon_H2_recipe, atomic_cannon_H2_item, atomic_cannon_H2_projectile}




local big_atomic_autocannon_recipe = {
    type = "recipe",
    name = "big-atomic-autocannon-shell",
    enabled = false,
    energy_required = 60,
    ingredients =
    {
      {"atomic-autocannon-shell", 1},
      {material, 30},
      {"low-density-structure", 40},
      {"processing-unit", 5*upgrade_circuit_mult}
    },
    result = "big-atomic-autocannon-shell"
  }

local  big_atomic_autocannon_item = table.deepcopy(data.raw["ammo"]["explosive-autocannon-shell"])
big_atomic_autocannon_item.name = "big-atomic-autocannon-shell"
big_atomic_autocannon_item.order = "d[f-explosive-autocannon-shell]-h[nuclear]"
big_atomic_autocannon_item.ammo_type.range_modifier = 3
big_atomic_autocannon_item.ammo_type.action.action_delivery.max_range = big_atomic_autocannon_item.ammo_type.action.action_delivery.max_range*3
big_atomic_autocannon_item.ammo_type.cooldown_modifier = 10
big_atomic_autocannon_item.ammo_type.action.action_delivery.projectile = "big-atomic-autocannon-projectile"
big_atomic_autocannon_item.icons[1] = {icon = "__True-Nukes__/graphics/big-atomic-autocannon-shell.png", icon_size = 64, icon_mipmaps = 4}
big_atomic_autocannon_item.pictures = {
	  layers =
	  {
	    {
	      size = 64,
	      filename = "__True-Nukes__/graphics/big-atomic-autocannon-shell.png",
	      scale = 0.25,
	      mipmap_count = 4
	    },
	    {
	      draw_as_light = true,
	      flags = {"light"},
	      size = 64,
	      filename = "__True-Nukes__/graphics/atomic-autocannon-shell-light.png",
	      scale = 0.25,
	      mipmap_count = 4
	    }
	  }
	}
	
local big_atomic_autocannon_projectile = table.deepcopy(data.raw["projectile"]["explosive-autocannon-projectile"])
big_atomic_autocannon_projectile.name = "big-atomic-autocannon-projectile"
big_atomic_autocannon_projectile.collision_box = {{0, 0}, {0, 0}}
big_atomic_autocannon_projectile.final_action = {
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects = nuke_explosions.N2t_detonation
  }
}
if(settings.startup["enable-big-atomic-ammo"].value) then
	data:extend{big_atomic_autocannon_recipe, big_atomic_autocannon_item, big_atomic_autocannon_projectile}
end
local big_atomic_cannon_H1_recipe = {
    type = "recipe",
    name = "big-atomic-cannon-H1-shell",
    enabled = false,
    energy_required = 60,
    ingredients =
    {
      {"atomic-cannon-H1-shell", 1},
      {material, 25},
      {"low-density-structure", 15},
      {"processing-unit", 2*upgrade_circuit_mult}
    },
    result = "big-atomic-cannon-H1-shell"
  }

local  big_atomic_cannon_H1_item = table.deepcopy(data.raw["ammo"]["cannon-H1-shell"])
big_atomic_cannon_H1_item.name = "big-atomic-cannon-H1-shell"
big_atomic_cannon_H1_item.order = "d[explosive-cannon-shell]-dB[nuclear]-1"
big_atomic_cannon_H1_item.ammo_type.range_modifier = 5
big_atomic_cannon_H1_item.ammo_type.action.action_delivery.max_range = big_atomic_cannon_H1_item.ammo_type.action.action_delivery.max_range*5
big_atomic_cannon_H1_item.ammo_type.cooldown_modifier = 5
big_atomic_cannon_H1_item.ammo_type.action.action_delivery.projectile = "big-atomic-cannon-H1-projectile"
big_atomic_cannon_H1_item.pictures = {
	  layers =
	  {
	    {
	      size = 64,
	      filename = "__True-Nukes__/graphics/big-atomic-cannon-shell.png",
	      scale = 0.25,
	      mipmap_count = 4
	    },
	    {
	      size = 128,
	      filename = "__SchallTankPlatoon__/graphics/icons/H1.png",
	      scale = 0.125,
	      mipmap_count = 3
	    },
	    {
	      draw_as_light = true,
	      flags = {"light"},
	      size = 64,
	      filename = "__True-Nukes__/graphics/atomic-cannon-shell-light.png",
	      scale = 0.25,
	      mipmap_count = 4
	    }
	  }
	}
big_atomic_cannon_H1_item.icons[1] = {icon = "__True-Nukes__/graphics/big-atomic-cannon-shell.png", icon_size = 64, icon_mipmaps = 4}
local big_atomic_cannon_H1_projectile = table.deepcopy(data.raw["projectile"]["explosive-cannon-H1-projectile"])
big_atomic_cannon_H1_projectile.name = "big-atomic-cannon-H1-projectile"
big_atomic_cannon_H1_projectile.collision_box = {{0, 0}, {0, 0}}
big_atomic_cannon_H1_projectile.final_action = {
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects = nuke_explosions.N8t_detonation
  }
}
if(settings.startup["enable-big-atomic-ammo"].value) then
	data:extend{big_atomic_cannon_H1_recipe, big_atomic_cannon_H1_item, big_atomic_cannon_H1_projectile}
end
local big_atomic_cannon_H2_recipe = {
    type = "recipe",
    name = "big-atomic-cannon-H2-shell",
    enabled = false,
    energy_required = 60,
    ingredients =
    {
      {"atomic-cannon-H2-shell", 1},
      {"low-density-structure", 20},
      {material, 30},
      {"processing-unit", 3*upgrade_circuit_mult}
    },
    result = "big-atomic-cannon-H2-shell"
  }

local  big_atomic_cannon_H2_item = table.deepcopy(data.raw["ammo"]["explosive-cannon-H2-shell"])
big_atomic_cannon_H2_item.name = "big-atomic-cannon-H2-shell"
big_atomic_cannon_H2_item.order = "d[explosive-cannon-shell]-dB[nuclear]-1"
big_atomic_cannon_H2_item.ammo_type.range_modifier = 5
big_atomic_cannon_H2_item.ammo_type.action.action_delivery.max_range = big_atomic_cannon_H2_item.ammo_type.action.action_delivery.max_range*5
big_atomic_cannon_H2_item.ammo_type.cooldown_modifier = 5
big_atomic_cannon_H2_item.ammo_type.action.action_delivery.projectile = "big-atomic-cannon-H2-projectile"
big_atomic_cannon_H2_item.icons[1] = {icon = "__True-Nukes__/graphics/big-atomic-cannon-shell.png", icon_size = 64, icon_mipmaps = 4}
big_atomic_cannon_H2_item.pictures = {
	  layers =
	  {
	    {
	      size = 64,
	      filename = "__True-Nukes__/graphics/big-atomic-cannon-shell.png",
	      scale = 0.25,
	      mipmap_count = 4
	    },
	    {
	      size = 128,
	      filename = "__SchallTankPlatoon__/graphics/icons/H2.png",
	      scale = 0.125,
	      mipmap_count = 3
	    },
	    {
	      draw_as_light = true,
	      flags = {"light"},
	      size = 64,
	      filename = "__True-Nukes__/graphics/atomic-cannon-shell-light.png",
	      scale = 0.25,
	      mipmap_count = 4
	    }
	  }
	}

local big_atomic_cannon_H2_projectile = table.deepcopy(data.raw["projectile"]["explosive-cannon-H2-projectile"])
big_atomic_cannon_H2_projectile.name = "big-atomic-cannon-H2-projectile"
big_atomic_cannon_H2_projectile.collision_box = {{0, 0}, {0, 0}}
big_atomic_cannon_H2_projectile.final_action = {
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects = nuke_explosions.N20t_detonation
  }
}
if(settings.startup["enable-big-atomic-ammo"].value) then
	data:extend{big_atomic_cannon_H2_recipe, big_atomic_cannon_H2_item, big_atomic_cannon_H2_projectile}
end
table.insert(data.raw.technology["californium-processing"].effects, 3, {
        type = "unlock-recipe",
        recipe = "atomic-autocannon-shell"
      })
table.insert(data.raw.technology["californium-processing"].effects, {
        type = "unlock-recipe",
        recipe = "atomic-cannon-H1-shell"
      })
table.insert(data.raw.technology["californium-processing"].effects, {
        type = "unlock-recipe",
        recipe = "atomic-cannon-H2-shell"
      })
if(settings.startup["enable-big-atomic-ammo"].value) then
	table.insert(data.raw.technology["scary-atomic-weapons"].effects, 3, {
		    type = "unlock-recipe",
		    recipe = "big-atomic-cannon-H2-shell"
		  })
	table.insert(data.raw.technology["scary-atomic-weapons"].effects, 3, {
		    type = "unlock-recipe",
		    recipe = "big-atomic-cannon-H1-shell"
		  })
	table.insert(data.raw.technology["scary-atomic-weapons"].effects, 2, {
		    type = "unlock-recipe",
		    recipe = "big-atomic-autocannon-shell"
		  })
end
