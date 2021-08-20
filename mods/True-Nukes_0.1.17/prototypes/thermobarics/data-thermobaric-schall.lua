local fireutil = require("__base__.prototypes.fire-util")

local circuit_type;
if not mods["bobelectronics"] then
	circuit_type = "advanced-circuit"
else
	circuit_type = "circuit-board"
end
local fuel_type;
if not mods["bobplates"] then
	fuel_type = "rocket-fuel"
else
	fuel_type = "enriched-fuel"
end


local thermobaric_autocannon_recipe = {
    type = "recipe",
    name = "thermobaric-autocannon-shell",
    enabled = false,
    energy_required = 20,
    ingredients =
    {
      {"explosive-autocannon-shell", 1},
      {circuit_type, 10},
      {fuel_type, 10},
      {"empty-barrel", 1}
    },
    result = "thermobaric-autocannon-shell"
  }

local  thermobaric_autocannon_item = table.deepcopy(data.raw["ammo"]["explosive-autocannon-shell"])
thermobaric_autocannon_item.name = "thermobaric-autocannon-shell"
thermobaric_autocannon_item.order = "d[f-explosive-autocannon-shell]-g[thermobaric]"
thermobaric_autocannon_item.ammo_type.range_modifier = 1.5
thermobaric_autocannon_item.ammo_type.action.action_delivery.max_range = thermobaric_autocannon_item.ammo_type.action.action_delivery.max_range*1.5
thermobaric_autocannon_item.ammo_type.cooldown_modifier = 10
thermobaric_autocannon_item.ammo_type.action.action_delivery.projectile = "thermobaric-autocannon-projectile"
thermobaric_autocannon_item.icons[1] = {icon = "__True-Nukes__/graphics/thermobaric-autocannon-shell.png", icon_size = 64, icon_mipmaps = 4}

local thermobaric_autocannon_projectile = table.deepcopy(data.raw["projectile"]["explosive-autocannon-projectile"])
thermobaric_autocannon_projectile.name = "thermobaric-autocannon-projectile"
thermobaric_autocannon_projectile.collision_box = {{0, 0}, {0, 0}}
thermobaric_autocannon_projectile.final_action = {
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "script",
		effect_id = "Thermobaric Weapon hit small-"
      },
      {
        type = "create-entity",
        entity_name = "massive-explosion"
      },
      {
        type = "create-entity",
        entity_name = "medium-scorchmark-tintable",
        check_buildability = true
      },
      {
        type = "nested-result",
        action =
		 {
		   type = "area",
		   radius = 30,
		   action_delivery =
		   {
		     type = "instant",
		     target_effects =
		     {
		       type = "damage",
		       damage = {amount = 0.1, type = "fire"}
		     }
		   }
		 }
      },
      {
        type = "nested-result",
        action =
        {
          type = "area",
          radius = 2,
          action_delivery =
          {
            type = "instant",
            target_effects =
            {
              {
                type = "damage",
                damage = {amount = 600, type = "explosion"}
              }
            }
          }
        }
      }
    }
  }
}
data:extend{thermobaric_autocannon_recipe, thermobaric_autocannon_item, thermobaric_autocannon_projectile}

local thermobaric_cannon_H1_recipe = {
    type = "recipe",
    name = "thermobaric-cannon-H1-shell",
    enabled = false,
    energy_required = 25,
    ingredients =
    {
      {"explosive-cannon-H1-shell", 1},
      {circuit_type, 3},
      {fuel_type, 15},
      {"empty-barrel", 1}
    },
    result = "thermobaric-cannon-H1-shell"
  }

local  thermobaric_cannon_H1_item = table.deepcopy(data.raw["ammo"]["cannon-H1-shell"])
thermobaric_cannon_H1_item.name = "thermobaric-cannon-H1-shell"
thermobaric_cannon_H1_item.order = "d[cannon-shell]-c[thermobaric]-1"
thermobaric_cannon_H1_item.ammo_type.range_modifier = 1.5
thermobaric_cannon_H1_item.ammo_type.action.action_delivery.max_range = thermobaric_cannon_H1_item.ammo_type.action.action_delivery.max_range*1.5
thermobaric_cannon_H1_item.ammo_type.cooldown_modifier = 3
thermobaric_cannon_H1_item.ammo_type.action.action_delivery.projectile = "thermobaric-cannon-H1-projectile"
thermobaric_cannon_H1_item.icons[1] = {icon = "__True-Nukes__/graphics/thermobaric-cannon-shell.png", icon_size = 64, icon_mipmaps = 4}
local thermobaric_cannon_H1_projectile = table.deepcopy(data.raw["projectile"]["explosive-cannon-H1-projectile"])
thermobaric_cannon_H1_projectile.name = "thermobaric-cannon-H1-projectile"
thermobaric_cannon_H1_projectile.collision_box = {{0, 0}, {0, 0}}
thermobaric_cannon_H1_projectile.final_action = {
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "script",
		effect_id = "Thermobaric Weapon hit small+"
      },
      {
        type = "create-entity",
        entity_name = "nuke-explosion"
      },
      {
        type = "create-entity",
        entity_name = "medium-scorchmark-tintable",
        check_buildability = true
      },
      {
        type = "destroy-decoratives",
        from_render_layer = "decals",
        to_render_layer = "object",
        include_soft_decoratives = true,
        include_decals = true,
        invoke_decorative_trigger = false,
        decoratives_with_trigger_only = false,
        radius = 4
      },
      {
        type = "nested-result",
        action =
		 {
		   type = "area",
		   radius = 45,
		   action_delivery =
		   {
		     type = "instant",
		     target_effects =
		     {
		       type = "damage",
		       damage = {amount = 0.1, type = "fire"}
		     }
		   }
		 }
      },
      {
        type = "nested-result",
        action =
        {
          type = "area",
          radius = 4,
          action_delivery =
          {
            type = "instant",
            target_effects =
            {
              {
                type = "damage",
                damage = {amount = 600, type = "explosion"}
              }
            }
          }
        }
      }
    }
  }
}
data:extend{thermobaric_cannon_H1_recipe, thermobaric_cannon_H1_item, thermobaric_cannon_H1_projectile}

local thermobaric_cannon_H2_recipe = {
    type = "recipe",
    name = "thermobaric-cannon-H2-shell",
    enabled = false,
    energy_required = 25,
    ingredients =
    {
      {"explosive-cannon-H2-shell", 1},
      {circuit_type, 3},
      {fuel_type, 20},
      {"empty-barrel", 2}
    },
    result = "thermobaric-cannon-H2-shell"
  }

local  thermobaric_cannon_H2_item = table.deepcopy(data.raw["ammo"]["explosive-cannon-H2-shell"])
thermobaric_cannon_H2_item.name = "thermobaric-cannon-H2-shell"
thermobaric_cannon_H2_item.order = "d[cannon-shell]-c[thermobaric]-1"
thermobaric_cannon_H2_item.ammo_type.range_modifier = 1.5
thermobaric_cannon_H2_item.ammo_type.action.action_delivery.max_range = thermobaric_cannon_H2_item.ammo_type.action.action_delivery.max_range*1.5
thermobaric_cannon_H2_item.ammo_type.cooldown_modifier = 3
thermobaric_cannon_H2_item.ammo_type.action.action_delivery.projectile = "thermobaric-cannon-H2-projectile"
thermobaric_cannon_H2_item.icons[1] = {icon = "__True-Nukes__/graphics/thermobaric-cannon-shell.png", icon_size = 64, icon_mipmaps = 4}

local thermobaric_cannon_H2_projectile = table.deepcopy(data.raw["projectile"]["explosive-cannon-H2-projectile"])
thermobaric_cannon_H2_projectile.name = "thermobaric-cannon-H2-projectile"
thermobaric_cannon_H2_projectile.collision_box = {{0, 0}, {0, 0}}
thermobaric_cannon_H2_projectile.final_action = {
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "script",
		effect_id = "Thermobaric Weapon hit medium-"
      },
      {
        type = "create-entity",
        entity_name = "medium-scorchmark-tintable",
        check_buildability = true
      },
      {
        type = "destroy-decoratives",
        from_render_layer = "decals",
        to_render_layer = "object",
        include_soft_decoratives = true,
        include_decals = true,
        invoke_decorative_trigger = false,
        decoratives_with_trigger_only = false,
        radius = 5
      },
      {
        type = "nested-result",
        action =
		 {
		   type = "area",
		   radius = 60,
		   action_delivery =
		   {
		     type = "instant",
		     target_effects =
		     {
		       type = "damage",
		       damage = {amount = 0.1, type = "fire"}
		     }
		   }
		 }
      },
      {
        type = "nested-result",
        action =
        {
          type = "area",
          radius = 5,
          action_delivery =
          {
            type = "instant",
            target_effects =
            {
              {
                type = "damage",
                damage = {amount = 600, type = "explosion"}
              }
            }
          }
        }
      }
    }
  }
}
data:extend{thermobaric_cannon_H2_recipe, thermobaric_cannon_H2_item, thermobaric_cannon_H2_projectile}

table.insert(data.raw.technology["thermobaric-weaponry"].effects, 2, {
        type = "unlock-recipe",
        recipe = "thermobaric-cannon-H2-shell"
      })
table.insert(data.raw.technology["thermobaric-weaponry"].effects, 2, {
        type = "unlock-recipe",
        recipe = "thermobaric-cannon-H1-shell"
      })
table.insert(data.raw.technology["thermobaric-weaponry"].effects, 1, {
        type = "unlock-recipe",
        recipe = "thermobaric-autocannon-shell"
      })
