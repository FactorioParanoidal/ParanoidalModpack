
local create_utils = require("__Warheads__.prototypes.sprite-assembly-util")


local createAppearance = create_utils.createAppearance
local tints = create_utils.tints

warheads["STP-incendiary-small"] = {
  name = "STP-incendiary-small",
  appendName = "-incendiary-STP-small",
  appendOrder = "j-i-a-m-30",
  size = "small",
  preciseSize = 13,
  final_effect = data.raw.projectile["incendiary-autocannon-projectile"].action[1].action_delivery.target_effects,

  appearance = createAppearance({type = "can_1", style = 4, tints = {tints.flamable, tints.flamable}}),
  range_modifier = 1.2,
  cooldown_modifier = 1.6,
  stack_size = 100,
  energy_required = 8,
  clamp_position = true,
  recipe_result_count = 10,
  tech = "flammables",
  recipe_category = "crafting-with-fluid",
  ingredients = {
    {type="item", name="steel-plate", amount=2},
    {type="fluid", name="light-oil", amount=100},
    {type="fluid", name="heavy-oil", amount=100}
  },
}

warheads["STP-incendiary-mid"] = {
  name = "STP-incendiary-mid",
  appendName = "-incendiary-STP-mid",
  appendOrder = "j-i-a-m-50",
  size = "small",
  preciseSize = 18,
  final_effect = data.raw.projectile["Schall-incendiary-rocket"].action[1].action_delivery.target_effects,

  appearance = createAppearance({type = "can_2", style = 2, tints = {tints.flamable}}),
  range_modifier = 1.2,
  cooldown_modifier = 1.6,
  stack_size = 100,
  clamp_position = true,
  energy_required = 40,
  tech = "flammables",
  recipe_category = "crafting-with-fluid",
  ingredients = {
    {type="item", name="steel-plate", amount=1},
    {type="fluid", name="light-oil", amount=20},
    {type="fluid", name="heavy-oil", amount=20}
  },
}

warheads["STP-napalm-mid"] = {
  name = "STP-napalm-mid",
  appendName = "-napalm-STP-mid",
  appendOrder = "p-n-a-m-50",
  size = "medium",
  target = "position",
  preciseSize = 26,
  final_effect = data.raw.projectile["Schall-napalm-rocket"].action[1].action_delivery.target_effects,

  appearance = createAppearance({type = "can_3", tints = {tints.flamable}}),
  range_modifier = 1.5,
  cooldown_modifier = 2,
  stack_size = 10,
  energy_required = 40,
  clamp_position = true,
  tech = "flammables",
  recipe_category = "crafting-with-fluid",
  ingredients = {
    {type="item", name="advanced-circuit", amount=20},
    {type="item", name="steel-plate", amount=10},
    {type="item", name="explosives", amount=10},
    {type="fluid", name="light-oil", amount=500},
    {type="fluid", name="heavy-oil", amount=500}
  },
}

