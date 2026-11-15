require("__paranoidal-true-nukes__.prototypes.warheads")

local create_utils = require("__paranoidal-true-nukes__.prototypes.sprite-assembly-util")


local createAppearance = create_utils.createAppearance
local tints = create_utils.tints

local circuit_type;
if not mods["bobelectronics"] then
  circuit_type = "advanced-circuit"
else
  circuit_type = "bob-circuit-board" -- Bob 2.x name
end
local fuel_type;
if not mods["bobplates"] then
  fuel_type = "rocket-fuel"
else
  fuel_type = "bob-enriched-fuel" -- Bob 2.x name
end
local function createAppearanceSimple(setup)
  return {
    icons = {
      {
        icon_size = 64,
        icon = setup.location .. setup.icon_name .. ".png",
      }
    }
  }
end

if(settings.startup["enable-small-thermobarics"].value) then
  warheads["TN-thermobaric-1"] = {
    name = "TN-thermobaric-1",
    appendName = "-thermobaric-1",
    appendOrder = "d-t-1",
    target_type = "position",

    size = "small",
    preciseSize = 16,
    appearance = createAppearance({type = "can_1", style = 4, tints = {tints.explosive, tints.explosive}}),
    chart_picture = "__paranoidal-true-nukes__/graphics/artillery/thermobaric-artillery-map-visualization.png",
    range_modifier = 1.5,
    stack_size = 100,
    energy_required = 20,
    clamp_position = true,
    tech = "thermobaric-weaponry",
    ingredients = {
      {type = "item", name = "explosives", amount = 10},
      {type = "item", name = circuit_type, amount = 5},
      {type = "item", name = fuel_type, amount = 15},
      {type = "item", name = "flamethrower-ammo", amount = 5},
      {type = "item", name = "barrel", amount = 2}
    },
    final_effect = {
      {
        type = "script",
        effect_id = "Thermobaric Weapon hit small"
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
        radius = 3
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
              damage = {amount = 1, type = "fire"}
            }
          }
        }
      },
      {
        type = "nested-result",
        action =
        {
          type = "area",
          radius = 3,
          action_delivery =
          {
            type = "instant",
            target_effects =
            {
              {
                type = "damage",
                damage = {amount = 1200, type = "explosion"}
              }
            }
          }
        }
      }
    }
  }
end

if(settings.startup["enable-medium-thermobarics"].value) then
  warheads["TN-thermobaric-2"] = {
    name = "TN-thermobaric-2",
    appendName = "-thermobaric-2",
    appendOrder = "d-t-2",
    target_type = "position",

    size = "medium",
    preciseSize = 24,
    appearance = createAppearance({type = "can_2", style = 2, tints = {tints.explosive}}),
    chart_picture = "__paranoidal-true-nukes__/graphics/artillery/thermobaric-artillery-map-visualization.png",
    range_modifier = 1.5,
    stack_size = 20,
    energy_required = 30,
    clamp_position = true,
    tech = "thermobaric-weaponry",
    ingredients = {
      {type = "item", name = "explosives", amount = 20},
      {type = "item", name = circuit_type, amount = 10},
      {type = "item", name = fuel_type, amount = 25},
      {type = "item", name = "flamethrower-ammo", amount = 12},
      {type = "item", name = "barrel", amount = 5}
    },
    final_effect = {
      {
        type = "script",
        effect_id = "Thermobaric Weapon hit medium"
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
        radius = 6
      },
      {
        type = "nested-result",
        action =
        {
          type = "area",
          radius = 80,
          action_delivery =
          {
            type = "instant",
            target_effects =
            {
              type = "damage",
              damage = {amount = 1, type = "fire"}
            }
          }
        }
      },
      {
        type = "nested-result",
        action =
        {
          type = "area",
          radius = 6,
          action_delivery =
          {
            type = "instant",
            target_effects =
            {
              {
                type = "damage",
                damage = {amount = 1200, type = "explosion"}
              }
            }
          }
        }
      }
    }
  }

end

if(settings.startup["enable-large-thermobarics"].value) then

  warheads["TN-thermobaric-3"] = {
    name = "TN-thermobaric-3",
    appendName = "-thermobaric-3",
    appendOrder = "d-t-3",
    target_type = "position",

    size = "large",
    preciseSize = 32,
    appearance = createAppearance({type = "can_3", tints = {tints.explosive}}),
    chart_picture = "__paranoidal-true-nukes__/graphics/artillery/thermobaric-artillery-map-visualization.png",
    stack_size = 10,
    energy_required = 40,
    clamp_position = true,
    tech = "thermobaric-weaponry",
    ingredients = {
      {type = "item", name = "explosives", amount = 30},
      {type = "item", name = circuit_type, amount = 15},
      {type = "item", name = fuel_type, amount = 40},
      {type = "item", name = "flamethrower-ammo", amount = 20},
      {type = "item", name = "barrel", amount = 10}
    },
    final_effect = {
      {
        type = "script",
        effect_id = "Thermobaric Weapon hit large"
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
        radius = 9
      },
      {
        type = "nested-result",
        action =
        {
          type = "area",
          radius = 120,
          action_delivery =
          {
            type = "instant",
            target_effects =
            {
              type = "damage",
              damage = {amount = 1, type = "fire"}
            }
          }
        }
      },
      {
        type = "nested-result",
        action =
        {
          type = "area",
          radius = 9,
          action_delivery =
          {
            type = "instant",
            target_effects =
            {
              {
                type = "damage",
                damage = {amount = 1200, type = "explosion"}
              }
            }
          }
        }
      }
    }
  }
end

-- Paranoidal 9.0.0 (user decision 2026-11-15): the thermobaric charges are the build's one line of
-- fuel-air weapons; Bob's flame rocket and fire artillery shell (the same roles) are removed by
-- zzzparanoidal. The large charge takes their place: Bob's alien fire in the recipe, unlocked by
-- Bob's "fire artillery shells" research (alien science) instead of "thermobaric weaponry".
local large = warheads["TN-thermobaric-3"]
if large and data.raw.fluid["bob-alien-fire"] and data.raw.technology["bob-fire-artillery-shells"] then
  table.insert(large.ingredients, {type = "fluid", name = "bob-alien-fire", amount = 150})
  large.recipe_category = "crafting-with-fluid"
  large.tech = "bob-fire-artillery-shells"
end
