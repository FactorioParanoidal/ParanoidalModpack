require("__Warheads__.prototypes.warheads")

local create_utils = require("__Warheads__.prototypes.sprite-assembly-util")


local createAppearance = create_utils.createAppearance
local tints = create_utils.tints

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
    chart_picture = "__True-Nukes__/graphics/artillery/thermobaric-artillery-map-visualization.png",
    range_modifier = 1.5,
    stack_size = 100,
    energy_required = 20,
    clamp_position = true,
    tech = "thermobaric-weaponry",
    ingredients = {
      {"explosives", 10},
      {circuit_type, 5},
      {fuel_type, 15},
      {"flamethrower-ammo", 5},
      {"empty-barrel", 2}
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
          radius = 3,
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
    chart_picture = "__True-Nukes__/graphics/artillery/thermobaric-artillery-map-visualization.png",
    range_modifier = 1.5,
    stack_size = 20,
    energy_required = 30,
    clamp_position = true,
    tech = "thermobaric-weaponry",
    ingredients = {
      {"explosives", 20},
      {circuit_type, 10},
      {fuel_type, 25},
      {"flamethrower-ammo", 12},
      {"empty-barrel", 5}
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
          radius = 6,
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
    chart_picture = "__True-Nukes__/graphics/artillery/thermobaric-artillery-map-visualization.png",
    stack_size = 10,
    energy_required = 40,
    clamp_position = true,
    tech = "thermobaric-weaponry",
    ingredients = {
      {"explosives", 30},
      {circuit_type, 15},
      {fuel_type, 40},
      {"flamethrower-ammo", 20},
      {"empty-barrel", 10}
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
          radius = 9,
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
end

