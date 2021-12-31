local fireutil = require("__base__.prototypes.fire-util")
local nuke_explosions = require("data-nuke-explosions")


local bigBoomMaterial = "uranium-235";
if mods["apm_nuclear_ldinc"] then
	bigBoomMaterial = "apm_oxide_pellet_pu239";
end

local atomic_artillery_recipe = {
    type = "recipe",
    name = "TN-atomic-artillery-shell",
    enabled = false,
    energy_required = 120,
    ingredients =
    {
      {"artillery-shell", 1},
      {"processing-unit", 20},
      {bigBoomMaterial, 100},
      {"explosives", 10}
    },
    result = "TN-atomic-artillery-shell"
}

local atomic_artillery_item = table.deepcopy(data.raw["ammo"]["artillery-shell"])
atomic_artillery_item.name = "TN-atomic-artillery-shell"
if mods["SchallTankPlatoon"] then
	atomic_artillery_item.order = "h[artillery]-e[atomic-artillery]"
else
	atomic_artillery_item.order = "d[explosive-cannon-shell]-e[atomic-artillery]"
end
atomic_artillery_item.ammo_type.cooldown_modifier = 10
atomic_artillery_item.ammo_type.action.action_delivery.projectile = "TN-atomic-artillery-projectile"
atomic_artillery_item.icon = "__True-Nukes__/graphics/atomic-artillery-shell.png"
atomic_artillery_item.pictures = {
      layers =
      {
        {
          size = 64,
          filename = "__True-Nukes__/graphics/atomic-artillery-shell.png",
          scale = 0.25,
          mipmap_count = 4
        },
        {
          draw_as_light = true,
          flags = {"light"},
          size = 64,
          filename = "__True-Nukes__/graphics/atomic-artillery-shell-light.png",
          scale = 0.25,
          mipmap_count = 4
        }
      }
    }

local atomic_artillery_projectile = table.deepcopy(data.raw["artillery-projectile"]["artillery-projectile"])
atomic_artillery_projectile.name = "TN-atomic-artillery-projectile"
atomic_artillery_projectile.created_effect = {
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

--Hack to fix Make Artillery Great Again's removal of the 'chart_picture'... also just being defensive
if(atomic_artillery_projectile.chart_picture) then
	atomic_artillery_projectile.chart_picture.filename = "__True-Nukes__/graphics/atomic-artillery-map-visualization.png"
else
	atomic_artillery_projectile.chart_picture = {
	      filename = "__True-Nukes__/graphics/atomic-artillery-map-visualization.png",
	      flags = { "icon" },
	      frame_count = 1,
	      width = 64,
	      height = 64,
	      priority = "high",
	      scale = 0.25
	    }
end

atomic_artillery_projectile.action = {
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects = nuke_explosions.N1kt_detonation
  }
}
if(settings.startup["enable-atomic-artillery"].value or settings.startup["enable-big-atomic-artillery"].value or settings.startup["enable-very-big-atomic-artillery"].value) then
	data:extend{atomic_artillery_recipe, atomic_artillery_item, atomic_artillery_projectile}
end

if(settings.startup["enable-big-atomic-artillery"].value or settings.startup["enable-very-big-atomic-artillery"].value) then
	local big_atomic_artillery_recipe = {
		type = "recipe",
		name = "TN-big-atomic-artillery-shell",
		enabled = false,
		energy_required = 300,
		ingredients =
		{
		  {"TN-atomic-artillery-shell", 1},
		  {"processing-unit", 100},
		  {bigBoomMaterial, 200},
		  {"explosives", 100}
		},
		result = "TN-big-atomic-artillery-shell"
	}

	local big_atomic_artillery_item = table.deepcopy(data.raw["ammo"]["artillery-shell"])
	big_atomic_artillery_item.name = "TN-big-atomic-artillery-shell"
	if mods["SchallTankPlatoon"] then
		big_atomic_artillery_item.order = "h[artillery]-e[big-atomic-artillery]"
	else
		big_atomic_artillery_item.order = "d[explosive-cannon-shell]-e[big-atomic-artillery]"
	end
	big_atomic_artillery_item.ammo_type.cooldown_modifier = 15
	big_atomic_artillery_item.ammo_type.action.action_delivery.projectile = "TN-big-atomic-artillery-projectile"
	big_atomic_artillery_item.icon = "__True-Nukes__/graphics/big-atomic-artillery-shell.png"
	big_atomic_artillery_item.pictures = {
		  layers =
		  {
		    {
		      size = 64,
		      filename = "__True-Nukes__/graphics/big-atomic-artillery-shell.png",
		      scale = 0.25,
		      mipmap_count = 4
		    },
		    {
		      draw_as_light = true,
		      flags = {"light"},
		      size = 64,
		      filename = "__True-Nukes__/graphics/big-atomic-artillery-shell-light.png",
		      scale = 0.25,
		      mipmap_count = 1
		    }
		  }
		}

	local big_atomic_artillery_projectile = table.deepcopy(data.raw["artillery-projectile"]["TN-atomic-artillery-projectile"])
	big_atomic_artillery_projectile.name = "TN-big-atomic-artillery-projectile"
	big_atomic_artillery_projectile.action.action_delivery.target_effects = nuke_explosions.N15kt_detonation

	data:extend{big_atomic_artillery_recipe, big_atomic_artillery_item, big_atomic_artillery_projectile}
end

if(settings.startup["enable-very-big-atomic-artillery"].value) then
	local very_big_atomic_artillery_recipe = {
		type = "recipe",
		name = "TN-very-big-atomic-artillery-shell",
		enabled = false,
		energy_required = 600,
		ingredients =
		{
		  {"TN-big-atomic-artillery-shell", 1},
		  {"processing-unit", 200},
		  {"FOGBANK", 50},
		  {"tritium-canister", 5},
		  {"heat-pipe", 5}
		},
		result = "TN-very-big-atomic-artillery-shell"
	}

	local very_big_atomic_artillery_item = table.deepcopy(data.raw["ammo"]["artillery-shell"])
	very_big_atomic_artillery_item.name = "TN-very-big-atomic-artillery-shell"
	if mods["SchallTankPlatoon"] then
		very_big_atomic_artillery_item.order = "h[artillery]-e[very-big-atomic-artillery]"
	else
		very_big_atomic_artillery_item.order = "d[explosive-cannon-shell]-e[very-big-atomic-artillery]"
	end
	very_big_atomic_artillery_item.ammo_type.cooldown_modifier = 30
	very_big_atomic_artillery_item.ammo_type.action.action_delivery.projectile = "TN-very-big-atomic-artillery-projectile"
	very_big_atomic_artillery_item.icon = "__True-Nukes__/graphics/very-big-atomic-artillery-shell.png"
	very_big_atomic_artillery_item.pictures = {
		  layers =
		  {
		    {
		      size = 64,
		      filename = "__True-Nukes__/graphics/very-big-atomic-artillery-shell.png",
		      scale = 0.25,
		      mipmap_count = 4
		    },
		    {
		      draw_as_light = true,
		      flags = {"light"},
		      size = 64,
		      filename = "__True-Nukes__/graphics/big-atomic-artillery-shell-light.png",
		      scale = 0.25,
		      mipmap_count = 1
		    }
		  }
		}


	local very_big_atomic_artillery_projectile = table.deepcopy(data.raw["artillery-projectile"]["TN-atomic-artillery-projectile"])
	very_big_atomic_artillery_projectile.name = "TN-very-big-atomic-artillery-projectile"
	very_big_atomic_artillery_projectile.action.action_delivery.target_effects = nuke_explosions.N100kt_detonation

	data:extend{very_big_atomic_artillery_recipe, very_big_atomic_artillery_item, very_big_atomic_artillery_projectile}
end



local small_atomic_artillery_recipe = {
    type = "recipe",
    name = "TN-small-atomic-artillery-shell",
    enabled = false,
    energy_required = 90,
    ingredients =
    {
      {"artillery-shell", 1},
      {"processing-unit", 10},
      {bigBoomMaterial, 75},
      {"explosives", 10}
    },
    result = "TN-small-atomic-artillery-shell"
}

local small_atomic_artillery_item = table.deepcopy(data.raw["ammo"]["artillery-shell"])
small_atomic_artillery_item.name = "TN-small-atomic-artillery-shell"
if mods["SchallTankPlatoon"] then
	small_atomic_artillery_item.order = "h[artillery]-d[small-atomic-artillery]"
else
	small_atomic_artillery_item.order = "d[explosive-cannon-shell]-d[small-atomic-artillery]"
end
small_atomic_artillery_item.ammo_type.cooldown_modifier = 3
small_atomic_artillery_item.ammo_type.action.action_delivery.projectile = "TN-small-atomic-artillery-projectile"
small_atomic_artillery_item.icon = "__True-Nukes__/graphics/small-atomic-artillery-shell.png"
small_atomic_artillery_item.pictures = {
      layers =
      {
        {
          size = 64,
          filename = "__True-Nukes__/graphics/small-atomic-artillery-shell.png",
          scale = 0.25,
          mipmap_count = 4
        },
        {
          draw_as_light = true,
          flags = {"light"},
          size = 64,
          filename = "__True-Nukes__/graphics/small-atomic-artillery-shell-light.png",
          scale = 0.25,
          mipmap_count = 4
        }
      }
    }


local small_atomic_artillery_projectile = table.deepcopy(atomic_artillery_projectile)
small_atomic_artillery_projectile.name = "TN-small-atomic-artillery-projectile"
small_atomic_artillery_projectile.action.action_delivery.target_effects = nuke_explosions.N500t_detonation
if(settings.startup["enable-small-atomic-artillery"].value) then
	data:extend{small_atomic_artillery_recipe, small_atomic_artillery_item, small_atomic_artillery_projectile}
end

local very_small_atomic_artillery_recipe = {
    type = "recipe",
    name = "TN-very-small-atomic-artillery-shell",
    enabled = false,
    energy_required = 60,
    ingredients =
    {
      {"artillery-shell", 1},
      {"processing-unit", 5},
      {bigBoomMaterial, 30},
      {"explosives", 10}
    },
    result = "TN-very-small-atomic-artillery-shell"
}

local very_small_atomic_artillery_item = table.deepcopy(data.raw["ammo"]["artillery-shell"])
very_small_atomic_artillery_item.name = "TN-very-small-atomic-artillery-shell"
if mods["SchallTankPlatoon"] then
	very_small_atomic_artillery_item.order = "h[artillery]-d[atomic-artillery]"
else
	very_small_atomic_artillery_item.order = "d[explosive-cannon-shell]-d[atomic-artillery]"
end
very_small_atomic_artillery_item.ammo_type.cooldown_modifier = 1.5
very_small_atomic_artillery_item.ammo_type.action.action_delivery.projectile = "TN-very-small-atomic-artillery-projectile"
very_small_atomic_artillery_item.icon = "__True-Nukes__/graphics/very-small-atomic-artillery-shell.png"
very_small_atomic_artillery_item.icon_mipmaps = 4
very_small_atomic_artillery_item.pictures = {
      layers =
      {
        {
          size = 64,
          filename = "__True-Nukes__/graphics/very-small-atomic-artillery-shell.png",
          scale = 0.25,
          mipmap_count = 4
        },
        {
          draw_as_light = true,
          flags = {"light"},
          size = 64,
          filename = "__True-Nukes__/graphics/very-small-atomic-artillery-shell-light.png",
          scale = 0.25,
          mipmap_count = 4
        }
      }
    }

local very_small_atomic_artillery_projectile = table.deepcopy(atomic_artillery_projectile)
very_small_atomic_artillery_projectile.name = "TN-very-small-atomic-artillery-projectile"
very_small_atomic_artillery_projectile.action.action_delivery.target_effects = nuke_explosions.N20t_detonation
if(settings.startup["enable-very-small-atomic-artillery"].value) then
	data:extend{very_small_atomic_artillery_recipe, very_small_atomic_artillery_item, very_small_atomic_artillery_projectile}
end


local artillery_nuke_tech = table.deepcopy(data.raw["technology"]["atomic-bomb"])
artillery_nuke_tech.name = "atomic-artillery-shells"
artillery_nuke_tech.effects = {}
if(settings.startup["enable-very-small-atomic-artillery"].value) then
	table.insert(artillery_nuke_tech.effects, 
	  {
        type = "unlock-recipe",
        recipe = "TN-very-small-atomic-artillery-shell"
      })
end
if(settings.startup["enable-small-atomic-artillery"].value) then
	table.insert(artillery_nuke_tech.effects, 
	  {
        type = "unlock-recipe",
        recipe = "TN-small-atomic-artillery-shell"
      })
end
if(settings.startup["enable-atomic-artillery"].value or settings.startup["enable-big-atomic-artillery"].value or settings.startup["enable-very-big-atomic-artillery"].value) then
	table.insert(artillery_nuke_tech.effects, 
	  {
        type = "unlock-recipe",
        recipe = "TN-atomic-artillery-shell"
      })
end
artillery_nuke_tech.unit.count=2000
artillery_nuke_tech.prerequisites = {"atomic-bomb", "artillery"}
artillery_nuke_tech.order = "e-a-c"
artillery_nuke_tech.icon = "__True-Nukes__/graphics/atomic-artillery-tech.png"
artillery_nuke_tech.icon_mipmaps = 1
data:extend{artillery_nuke_tech}

      
