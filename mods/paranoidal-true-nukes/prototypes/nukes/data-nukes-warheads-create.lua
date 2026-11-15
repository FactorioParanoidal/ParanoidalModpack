local nuke_materials = require("data-nukes-material")
local nuke_explosions = require("data-nuke-explosions")

local dead = nuke_materials.deadMaterial
local boom = nuke_materials.boomMaterial
local small = nuke_materials.smallBoomMaterial
local light = nuke_materials.lightMaterial
local reflector = nuke_materials.reflector
local computer = nuke_materials.computer
local fusionMaterial = nuke_materials.fusionMaterial

local create_utils = require("__paranoidal-true-nukes__.prototypes.sprite-assembly-util")


local createAppearance = create_utils.createAppearance
local tints = create_utils.tints



if(settings.startup["enable-small-atomics"].value) then
  warheads["TN-warhead-0-1--1"] = {
    appendName = "-atomic-0_1t",
    appendOrder = "x-n-a-m-000001-1",
    target_type = "position",
    size = "tiny",
    preciseSize = 8,
    final_effect = nuke_explosions.N0_1t_detonation,

    appearance = createAppearance({type = "nuclear_core", tints = {tints.californium, tints.californium, tints.nothing}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "0_1t"}),
    chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
    cooldown_modifier = 2,
    stack_size = 100,
    energy_required = 100,
    collisions = false,
    recipe_result_count = 10,
    tech = "californium-weapons",
    ingredients = {
      {type = "item", name = "steel-plate", amount = 5},
      {type = "item", name = light, amount = 5},
      {type = "item", name = computer, amount = 2},
      {type = "item", name = "explosives", amount = 2},
      {type = "item", name = dead, amount = 4},
      {type = "item", name = small, amount = 10},
    },
  }
  warheads["TN-warhead-0-5--1"] = {
    appendName = "-atomic-0_5t",
    appendOrder = "x-n-a-m-000005-1",
    target_type = "position",
    size = "small",
    preciseSize = 12,
    final_effect = nuke_explosions.N0_5t_detonation,

    appearance = createAppearance({type = "nuclear_core", tints = {tints.californium, tints.californium, tints.uraniumDead}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "0_5t"}),
    chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
    cooldown_modifier = 5,
    stack_size = 100,
    energy_required = 90,

    collisions = false,
    tech = "californium-weapons",
    recipe_result_count = 6,
    ingredients = {
      {type = "item", name = "steel-plate", amount = 1},
      {type = "item", name = light, amount = 12},
      {type = "item", name = computer, amount = 3},
      {type = "item", name = "explosives", amount = 3},
      {type = "item", name = dead, amount = 4},
      {type = "item", name = small, amount = 12}
    }
  }
  if(settings.startup["enable-compact-small-atomics"].value) then
    warheads["TN-warhead-0-1--2"] = {
      appendName = "-atomic-0_1t",
      appendOrder = "x-n-a-m-000001-2",
      target_type = "position",
      size = "tiny",
      preciseSize = 4,
      final_effect = nuke_explosions.N0_1t_detonation,

      appearance = createAppearance({type = "nuclear_core", tints = {tints.californium, tints.californium, tints.nothing}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "0_1t"}),
      chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 200,
      energy_required = 100,
      collisions = false,
      tech = "compact-californium-weapons",
      recipe_result_count = 5,
      ingredients = {
        {type = "item", name = light, amount = 10},
        {type = "item", name = computer, amount = 2},
        {type = "item", name = reflector, amount = 1},
        {type = "item", name = "explosives", amount = 2},
        {type = "item", name = dead, amount = 1},
        {type = "item", name = small, amount = 8},
      }
    }
    warheads["TN-warhead-0-1--3"] = {
      appendName = "-atomic-0_1t",
      appendOrder = "x-n-a-m-000001-3",
      target_type = "position",
      size = "tiny",
      preciseSize = 2,
      final_effect = nuke_explosions.N0_1t_detonation,

      appearance = createAppearance({type = "nuclear_core", tints = {tints.californium, tints.californium, tints.californium}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "0_1t"}),
      chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 200,
      energy_required = 80,
      collisions = false,
      tech = "compact-californium-weapons",
      recipe_result_count = 2,
      ingredients = {
        {type = "item", name = light, amount = 3},
        {type = "item", name = computer, amount = 2},
        {type = "item", name = reflector, amount = 2},
        {type = "item", name = "explosives", amount = 1},
        {type = "item", name = small, amount = 4},
      }
    }
    warheads["TN-warhead-0-5--2"] = {
      appendName = "-atomic-0_5t",
      appendOrder = "x-n-a-m-000005-2",
      target_type = "position",
      size = "tiny",
      preciseSize = 8,
      final_effect = nuke_explosions.N0_5t_detonation,

      appearance = createAppearance({type = "nuclear_core", tints = {tints.californium, tints.californium, tints.uraniumDead}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "0_5t"}),
      chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 100,
      energy_required = 90,
      collisions = false,
      tech = "compact-californium-weapons",
      recipe_result_count = 3,
      ingredients = {
        {type = "item", name = light, amount = 9},
        {type = "item", name = computer, amount = 3},
        {type = "item", name = reflector, amount = 1},
        {type = "item", name = "explosives", amount = 2},
        {type = "item", name = dead, amount = 1},
        {type = "item", name = small, amount = 9}
      }
    }
    warheads["TN-warhead-0-5--3"] = {
      appendName = "-atomic-0_5t",
      appendOrder = "x-n-a-m-000005-3",
      target_type = "position",
      size = "tiny",
      preciseSize = 4,
      final_effect = nuke_explosions.N0_5t_detonation,

      appearance = createAppearance({type = "nuclear_core", tints = {tints.californium, tints.californium, tints.californium}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "0_5t"}),
      chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 100,
      energy_required = 60,
      collisions = false,
      tech = "compact-californium-weapons",
      ingredients = {
        {type = "item", name = light, amount = 2},
        {type = "item", name = computer, amount = 1},
        {type = "item", name = reflector, amount = 1},
        {type = "item", name = "explosives", amount = 1},
        {type = "item", name = small, amount = 5}
      }
    }
  end
end
if(settings.startup["enable-medium-atomics"].value) then
  warheads["TN-warhead-2--1"] = {
    appendName = "-atomic-2t",
    appendOrder = "x-n-a-m-00002-1",
    target_type = "position",
    size = "small",
    preciseSize = 16,
    final_effect = nuke_explosions.N2t_detonation,

    appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.californium, tints.nothing}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "2t"}),
    chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
    cooldown_modifier = 5,
    stack_size = 20,
    energy_required = 20,
    collisions = false,
    tech = "californium-weapons",
    ingredients = {
      {type = "item", name = "steel-plate", amount = 5},
      {type = "item", name = computer, amount = 5},
      {type = "item", name = "explosives", amount = 5},
      {type = "item", name = dead, amount = 3},
      {type = "item", name = boom, amount = 3},
      {type = "item", name = small, amount = 4}
    }
  }
  warheads["TN-warhead-4--1"] = {
    appendName = "-atomic-4t",
    appendOrder = "x-n-a-m-00004-1",
    target_type = "position",
    size = "medium",
    preciseSize = 22,
    final_effect = nuke_explosions.N4t_detonation,

    appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.californium, tints.uraniumDead}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "4t"}),
    chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
    cooldown_modifier = 5,
    stack_size = 10,
    energy_required = 30,
    collisions = false,
    tech = "atomic-bomb",
    ingredients = {
      {type = "item", name = "steel-plate", amount = 5},
      {type = "item", name = computer, amount = 5},
      {type = "item", name = "explosives", amount = 10},
      {type = "item", name = dead, amount = 5},
      {type = "item", name = boom, amount = 8}
    }
  }
  warheads["TN-warhead-8--1"] = {
    appendName = "-atomic-8t",
    appendOrder = "x-n-a-m-00008-1",
    target_type = "position",
    size = "medium",
    preciseSize = 28,

    final_effect = nuke_explosions.N8t_detonation,
    appearance = createAppearance({type = "nuclear_core", tints = {tints.californium, tints.uraniumLive, tints.nothing}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "8t"}),
    chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
    cooldown_modifier = 5,
    stack_size = 10,
    energy_required = 40,
    collisions = false,
    tech = "atomic-bomb",
    ingredients = {
      {type = "item", name = "steel-plate", amount = 6},
      {type = "item", name = computer, amount = 5},
      {type = "item", name = "explosives", amount = 20},
      {type = "item", name = dead, amount = 10},
      {type = "item", name = boom, amount = 15}
    }
  }
  warheads["TN-warhead-2--2"] = {
    appendName = "-atomic-2t",
    appendOrder = "x-n-a-m-00002-2",
    target_type = "position",
    size = "small",
    preciseSize = 12,
    final_effect = nuke_explosions.N2t_detonation,

    appearance = createAppearance({type = "nuclear_core", tints = {tints.californium, tints.californium, tints.californium}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "2t"}),
    chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
    cooldown_modifier = 5,
    stack_size = 20,
    energy_required = 60,
    collisions = false,
    tech = "compact-californium-weapons",
    ingredients = {
      {type = "item", name = "steel-plate", amount = 1},
      {type = "item", name = light, amount = 4},
      {type = "item", name = computer, amount = 10},
      {type = "item", name = reflector, amount = 1},
      {type = "item", name = "explosives", amount = 4},
      {type = "item", name = dead, amount = 2},
      {type = "item", name = boom, amount = 1},
      {type = "item", name = small, amount = 8}
    }
  }
  warheads["TN-warhead-20--1"] = {
    appendName = "-atomic-20t",
    appendOrder = "x-n-a-m-00020-1",
    target_type = "position",
    size = "large",
    preciseSize = 32,

    final_effect = nuke_explosions.N20t_detonation,
    appearance = createAppearance({type = "nuclear_core", tints = {tints.californium, tints.uraniumLive, tints.uraniumDead}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "20t"}),
    chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
    cooldown_modifier = 5,
    stack_size = 5,
    energy_required = 60,
    collisions = false,
    tech = "basic-atomic-weapons",
    ingredients = {
      {type = "item", name = "steel-plate", amount = 10},
      {type = "item", name = computer, amount = 8},
      {type = "item", name = "explosives", amount = 30},
      {type = "item", name = dead, amount = 15},
      {type = "item", name = boom, amount = 30}
    }
  }
  warheads["TN-warhead-20--2"] = {
    appendName = "-atomic-20t",
    appendOrder = "x-n-a-m-00020-2",
    target_type = "position",

    size = "medium",
    preciseSize = 26,
    final_effect = nuke_explosions.N20t_detonation,
    appearance = createAppearance({type = "nuclear_core", tints = {tints.californium, tints.uraniumLive, tints.uraniumDead}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "20t"}),
    chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
    cooldown_modifier = 5,
    stack_size = 5,
    energy_required = 120,
    collisions = false,
    tech = "atomic-bomb",
    ingredients = {
      {type = "item", name = light, amount = 20},
      {type = "item", name = computer, amount = 20},
      {type = "item", name = "explosives", amount = 15},
      {type = "item", name = dead, amount = 5},
      {type = "item", name = boom, amount = 50}
    }
  }
  warheadWeaponNameMap["big-rocket-atomic-20t"] = "atomic-bomb"

  if(settings.startup["enable-compact-medium-atomics"].value) then

    warheads["TN-warhead-2--3"] = {
      appendName = "-atomic-2t",
      appendOrder = "x-n-a-m-00002-3",
      target_type = "position",
      size = "tiny",
      preciseSize = 8,
      final_effect = nuke_explosions.N2t_detonation,

      appearance = createAppearance({type = "nuclear_core", tints = {tints.californium, tints.californium, tints.californium}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "2t"}),
      chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 20,
      energy_required = 120,
      collisions = false,
      tech = "compact-californium-weapons",
      ingredients = {
        {type = "item", name = light, amount = 10},
        {type = "item", name = computer, amount = 15},
        {type = "item", name = reflector, amount = 4},
        {type = "item", name = "explosives", amount = 2},
        {type = "item", name = small, amount = 15}
      }
    }
    warheads["TN-warhead-4--2"] = {
      appendName = "-atomic-4t",
      appendOrder = "x-n-a-m-00004-2",
      target_type = "position",
      size = "small",
      preciseSize = 16,
      final_effect = nuke_explosions.N4t_detonation,

      appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.californium, tints.uraniumDead}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "4t"}),
      chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 10,
      energy_required = 90,
      collisions = false,
      tech = "californium-weapons",
      ingredients = {
        {type = "item", name = light, amount = 10},
        {type = "item", name = computer, amount = 12},
        {type = "item", name = "explosives", amount = 5},
        {type = "item", name = boom, amount = 2},
        {type = "item", name = small, amount = 10}
      }
    }
    warheads["TN-warhead-4--3"] = {
      appendName = "-atomic-4t",
      appendOrder = "x-n-a-m-00004-3",
      target_type = "position",
      size = "small",
      preciseSize = 12,
      final_effect = nuke_explosions.N4t_detonation,

      appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.californium, tints.californium}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "4t"}),
      chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 10,
      energy_required = 180,
      collisions = false,
      tech = "compact-californium-weapons",
      ingredients = {
        {type = "item", name = light, amount = 15},
        {type = "item", name = computer, amount = 20},
        {type = "item", name = reflector, amount = 8},
        {type = "item", name = "explosives", amount = 5},
        {type = "item", name = small, amount = 20}
      }
    }
    warheads["TN-warhead-8--2"] = {
      appendName = "-atomic-8t",
      appendOrder = "x-n-a-m-00008-2",
      target_type = "position",
      size = "small",
      preciseSize = 20,

      final_effect = nuke_explosions.N8t_detonation,
      appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.californium, tints.californium}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "8t"}),
      chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 10,
      energy_required = 120,
      collisions = false,
      tech = "californium-weapons",
      ingredients = {
        {type = "item", name = light, amount = 15},
        {type = "item", name = computer, amount = 16},
        {type = "item", name = "explosives", amount = 8},
        {type = "item", name = boom, amount = 2},
        {type = "item", name = small, amount = 20}
      }
    }
    warheads["TN-warhead-8--3"] = {
      appendName = "-atomic-8t",
      appendOrder = "x-n-a-m-00008-3",
      target_type = "position",
      size = "small",
      preciseSize = 15,

      final_effect = nuke_explosions.N8t_detonation,
      appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.californium, tints.californium}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "8t"}),
      chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 10,
      energy_required = 240,
      collisions = false,
      tech = "compact-californium-weapons",
      ingredients = {
        {type = "item", name = light, amount = 20},
        {type = "item", name = computer, amount = 24},
        {type = "item", name = reflector, amount = 12},
        {type = "item", name = "explosives", amount = 10},
        {type = "item", name = small, amount = 35}
      }
    }

    warheads["TN-warhead-20--3"] = {
      appendName = "-atomic-20t",
      appendOrder = "x-n-a-m-00020-3",
      target_type = "position",

      size = "small",
      preciseSize = 20,
      final_effect = nuke_explosions.N20t_detonation,
      appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.californium, tints.californium}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "20t"}),
      chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 5,
      energy_required = 300,
      collisions = false,
      tech = "compact-californium-weapons",
      ingredients = {
        {type = "item", name = light, amount = 50},
        {type = "item", name = computer, amount = 40},
        {type = "item", name = reflector, amount = 12},
        {type = "item", name = "explosives", amount = 5},
        {type = "item", name = boom, amount = 5},
        {type = "item", name = small, amount = 45}
      }
    }
  end
end
if(settings.startup["enable-large-atomics"].value) then
  warheads["TN-warhead-500--1"] = {
    appendName = "-atomic-500t",
    appendOrder = "x-n-a-m-005-1",
    target_type = "position",

    size = "large",
    preciseSize = 38,
    final_effect = nuke_explosions.N500t_detonation,
    appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.uraniumLive, tints.nothing}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "500t"}),
    chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-map-visualization.png",
    cooldown_modifier = 5,
    stack_size = 1,
    energy_required = 90,
    collisions = false,
    tech = "expanded-atomics",
    ingredients = {
      {type = "item", name = "steel-plate", amount = 20},
      {type = "item", name = computer, amount = 10},
      {type = "item", name = "explosives", amount = 40},
      {type = "item", name = dead, amount = 25},
      {type = "item", name = boom, amount = 75}
    }
  }
  warheads["TN-warhead-1k--1"] = {
    appendName = "-atomic-1kt",
    appendOrder = "x-n-a-m-01-1",
    target_type = "position",

    size = "large",
    preciseSize = 40,
    final_effect = nuke_explosions.N1kt_detonation,
    appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.uraniumLive, tints.uraniumDead}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "1kt"}),
    chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-map-visualization.png",
    cooldown_modifier = 5,
    stack_size = 1,
    energy_required = 120,
    collisions = false,
    tech = "full-fission-atomics",
    ingredients = {
      {type = "item", name = "steel-plate", amount = 25},
      {type = "item", name = computer, amount = 20},
      {type = "item", name = "explosives", amount = 100},
      {type = "item", name = dead, amount = 25},
      {type = "item", name = boom, amount = 100}
    }
  }
  if(settings.startup["enable-compact-large-atomics"].value) then

    warheads["TN-warhead-500--2"] = {
      appendName = "-atomic-500t",
      appendOrder = "x-n-a-m-005-2",
      target_type = "position",

      size = "large",
      preciseSize = 32,
      final_effect = nuke_explosions.N500t_detonation,
      appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.uraniumLive, tints.nothing}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "500t"}),
      chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 1,
      energy_required = 210,
      collisions = false,
      tech = "full-fission-atomics",
      ingredients = {
        {type = "item", name = "steel-plate", amount = 5},
        {type = "item", name = light, amount = 15},
        {type = "item", name = computer, amount = 20},
        {type = "item", name = "explosives", amount = 25},
        {type = "item", name = dead, amount = 15},
        {type = "item", name = boom, amount = 100},
      }
    }
    warheads["TN-warhead-500--3"] = {
      appendName = "-atomic-500t",
      appendOrder = "x-n-a-m-005-3",
      target_type = "position",

      size = "medium",
      preciseSize = 26,
      final_effect = nuke_explosions.N500t_detonation,
      appearance = createAppearance({type = "nuclear_core", tints = {tints.californium, tints.uraniumLive, tints.uraniumLive}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "500t"}),
      chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 1,
      energy_required = 360,
      collisions = false,
      tech = "compact-full-fission-weapons",
      ingredients = {
        {type = "item", name = light, amount = 45},
        {type = "item", name = computer, amount = 50},
        {type = "item", name = reflector, amount = 15},
        {type = "item", name = "explosives", amount = 10},
        {type = "item", name = boom, amount = 50},
        {type = "item", name = small, amount = 60}
      }
    }
    warheads["TN-warhead-1k--2"] = {
      appendName = "-atomic-1kt",
      appendOrder = "x-n-a-m-01-2",
      target_type = "position",

      size = "large",
      preciseSize = 35,
      final_effect = nuke_explosions.N1kt_detonation,
      appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.uraniumLive, tints.uraniumDead}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "1kt"}),
      chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 1,
      energy_required = 300,
      collisions = false,
      tech = "compact-full-fission-weapons",
      ingredients = {
        {type = "item", name = "steel-plate", amount = 8},
        {type = "item", name = light, amount = 20},
        {type = "item", name = computer, amount = 45},
        {type = "item", name = "explosives", amount = 50},
        {type = "item", name = dead, amount = 5},
        {type = "item", name = boom, amount = 120},
      }
    }
    warheads["TN-warhead-1k--3"] = {
      appendName = "-atomic-1kt",
      appendOrder = "x-n-a-m-01-3",
      target_type = "position",

      size = "medium",
      preciseSize = 30,
      final_effect = nuke_explosions.N1kt_detonation,
      appearance = createAppearance({type = "nuclear_core", tints = {tints.californium, tints.uraniumLive, tints.uraniumLive}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "1kt"}),
      chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 1,
      energy_required = 600,
      collisions = false,
      tech = "compact-full-fission-weapons",
      ingredients = {
        {type = "item", name = light, amount = 60},
        {type = "item", name = computer, amount = 100},
        {type = "item", name = "copper-cable", amount = 20},
        {type = "item", name = reflector, amount = 20},
        {type = "item", name = "explosives", amount = 20},
        {type = "item", name = boom, amount = 80},
        {type = "item", name = small, amount = 80}
      }
    }
  end
end
if(settings.startup["enable-15kt"].value) then
  warheads["TN-warhead-15k--1"] = {
    appendName = "-atomic-15kt",
    appendOrder = "x-n-a-m-15-1",
    target_type = "position",

    size = "huge",
    preciseSize = 44,
    final_effect = nuke_explosions.N15kt_detonation,
    appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.uraniumLive, tints.uraniumLive}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "15kt"}),
    chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-map-visualization.png",
    cooldown_modifier = 5,
    stack_size = 1,
    energy_required = 180,
    collisions = false,
    tech = "full-fission-atomics",
    ingredients = {
      {type = "item", name = "steel-plate", amount = 30},
      {type = "item", name = computer, amount = 40},
      {type = "item", name = "copper-cable", amount = 10},
      {type = "item", name = "explosives", amount = 175},
      {type = "item", name = dead, amount = 150},
      {type = "item", name = boom, amount = 250}
    }
  }
  if(settings.startup["enable-compact-15kt"].value) then

    warheads["TN-warhead-15k--2"] = {
      appendName = "-atomic-15kt",
      appendOrder = "x-n-a-m-15-2",
      target_type = "position",

      size = "large",
      preciseSize = 38,
      final_effect = nuke_explosions.N15kt_detonation,
      appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.uraniumLive, tints.uraniumLive}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "15kt"}),
      chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 1,
      energy_required = 480,
      collisions = false,
      tech = "compact-full-fission-weapons",
      ingredients = {
        {type = "item", name = "steel-plate", amount = 10},
        {type = "item", name = light, amount = 30},
        {type = "item", name = computer, amount = 160},
        {type = "item", name = "copper-cable", amount = 20},
        {type = "item", name = reflector, amount = 10},
        {type = "item", name = "explosives", amount = 130},
        {type = "item", name = dead, amount = 25},
        {type = "item", name = boom, amount = 325}
      }
    }
    warheads["TN-warhead-15k--3"] = {
      appendName = "-atomic-15kt",
      appendOrder = "x-n-a-m-15-3",
      target_type = "position",

      size = "large",
      preciseSize = 33,
      final_effect = nuke_explosions.N15kt_detonation,
      appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.uraniumLive, tints.uraniumLive}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "15kt"}),
      chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 1,
      energy_required = 720,
      collisions = false,
      tech = "compact-full-fission-weapons",
      ingredients = {
        {type = "item", name = light, amount = 75},
        {type = "item", name = computer, amount = 200},
        {type = "item", name = "copper-cable", amount = 40},
        {type = "item", name = reflector, amount = 50},
        {type = "item", name = "explosives", amount = 100},
        {type = "item", name = boom, amount = 300},
        {type = "item", name = small, amount = 50}
      }
    }
  end
end
if(settings.startup["enable-fusion"].value) then
  warheads["TN-warhead-big--1"] = {
    appendName = "-atomic-2-stage",
    appendOrder = "x-n-a-t",
    target_type = "position",
    size = "huge",
    preciseSize = 56,
    final_effect = nuke_explosions.N15kt_detonation,
    appearance = createAppearance({type = "nuclear_core", tints = {tints.tritium, tints.tritium, tints.tritium}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "15kt+"}),
    chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-fusion-map-visualization.png",
    cooldown_modifier = 5,
    stack_size = 1,
    energy_required = 180,
    collisions = false,
    tech = "fusion-weapons",
    ingredients = {
      {type = "item", name = "steel-plate", amount = 100},
      {type = "item", name = "copper-plate", amount = 100},
      {type = "item", name = computer, amount = 100},
      {type = "item", name = "copper-cable", amount = 40},
      {type = "item", name = "FOGBANK", amount = 10},
      {type = "item", name = "heat-pipe", amount = 10},
      {type = "item", name = reflector, amount = 20},
      {type = "item", name = "explosives", amount = 200},
      {type = "item", name = dead, amount = 400},
      {type = "item", name = boom, amount = 250}
    },
    progressiveRecipe = "from-first",
    explosions = {
      {
        additional_ingedients = {},
        appendName = "-15kt",
        appearance = createAppearance({type = "nuclear_core", tints = {tints.tritium, tints.tritium, tints.tritium}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "15kt"}),
        appendOrder = "-0-015",
        final_effect = nuke_explosions.N15kt_detonation
      },
      {
        additional_ingedients = {{type = "item", name = fusionMaterial, amount = 2}},
        appendName = "-100kt",
        appearance = createAppearance({type = "nuclear_core", tints = {tints.tritium, tints.tritium, tints.tritium}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "100kt"}),
        appendOrder = "-0-100",
        final_effect = nuke_explosions.N100kt_detonation
      }
    }
  }
  if(settings.startup["enable-big-fusion-weapons"].value) then
    table.insert(warheads["TN-warhead-big--1"].explosions, {
      additional_ingedients = {{type = "item", name = fusionMaterial, amount = 20}},
      appendName = "-1Mt",
      appearance = createAppearance({type = "nuclear_core", tints = {tints.tritium, tints.tritium, tints.tritium}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "1Mt"}),
      appendOrder = "-1-001",
      final_effect = nuke_explosions.N1Mt_detonation
    })
    table.insert(warheads["TN-warhead-big--1"].explosions, {
      additional_ingedients = {{type = "item", name = fusionMaterial, amount = 100}},
      appendName = "-5Mt",
      appearance = createAppearance({type = "nuclear_core", tints = {tints.tritium, tints.tritium, tints.tritium}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "5Mt"}),
      appendOrder = "-1-005",
      final_effect = nuke_explosions.N5Mt_detonation
    })
    table.insert(warheads["TN-warhead-big--1"].explosions, {
      additional_ingedients = {{type = "item", name = fusionMaterial, amount = 200}},
      appendName = "-10Mt",
      appearance = createAppearance({type = "nuclear_core", tints = {tints.tritium, tints.tritium, tints.tritium}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "10Mt"}),
      appendOrder = "-1-010",
      final_effect = nuke_explosions.N10Mt_detonation
    })
    table.insert(warheads["TN-warhead-big--1"].explosions, {
      additional_ingedients = {{type = "item", name = fusionMaterial, amount = 1000}},
      appendName = "-50Mt",
      appearance = createAppearance({type = "nuclear_core", tints = {tints.tritium, tints.tritium, tints.tritium}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "50Mt"}),
      appendOrder = "-1-050",
      final_effect = nuke_explosions.N50Mt_detonation
    })
    table.insert(warheads["TN-warhead-big--1"].explosions, {
      additional_ingedients = {{type = "item", name = fusionMaterial, amount = 2000}},
      appendName = "-100Mt",
      appearance = createAppearance({type = "nuclear_core", tints = {tints.tritium, tints.tritium, tints.tritium}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "100Mt"}),
      appendOrder = "-1-100",
      final_effect = nuke_explosions.N100Mt_detonation
    })
    table.insert(warheads["TN-warhead-big--1"].explosions, {
      additional_ingedients = {{type = "item", name = fusionMaterial, amount =20000}},
      appendName = "-1Gt",
      appearance = createAppearance({type = "nuclear_core", tints = {tints.tritium, tints.tritium, tints.tritium}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "1Gt"}),
      appendOrder = "-2-001",
      final_effect = nuke_explosions.N1Gt_detonation
    })
  end
  if(settings.startup["enable-compact-fusion"].value) then

    warheads["TN-warhead-big--2"] = {
      appendName = "-atomic-2-stage",
      appendOrder = "x-n-a-t",
      target_type = "position",
      size = "huge",
      preciseSize = 48,
      appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.tritium, tints.tritium}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "15kt+"}),
      chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-fusion-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 1,
      energy_required = 300,
      collisions = false,
      tech = "compact-fusion-weapons",
      ingredients = {
        {type = "item", name = "steel-plate", amount = 50},
        {type = "item", name = "copper-plate", amount = 50},
        {type = "item", name = light, amount = 80},
        {type = "item", name = computer, amount = 200},
        {type = "item", name = "copper-cable", amount = 80},
        {type = "item", name = "FOGBANK", amount = 40},
        {type = "item", name = "heat-pipe", amount = 40},
        {type = "item", name = reflector, amount = 40},
        {type = "item", name = "explosives", amount = 130},
        {type = "item", name = dead, amount = 200},
        {type = "item", name = boom, amount = 325}
      },
      progressiveRecipe = "from-first",
      explosions = {
        {
          additional_ingedients = {},
          appendName = "-15kt",
          appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.tritium, tints.tritium}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "15kt"}),
          appendOrder = "-0-015",
          final_effect = nuke_explosions.N15kt_detonation
        },
        {
          additional_ingedients = {{type = "item", name = fusionMaterial, amount = 4}},
          appendName = "-100kt",
          appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.tritium, tints.tritium}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "100kt"}),
          appendOrder = "-0-100",
          final_effect = nuke_explosions.N100kt_detonation
        }
      }
    }
    if(settings.startup["enable-big-fusion-weapons"].value) then
      table.insert(warheads["TN-warhead-big--2"].explosions, {
        additional_ingedients = {{type = "item", name = fusionMaterial, amount = 40}},
        appendName = "-1Mt",
        appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.tritium, tints.tritium}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "1Mt"}),
        appendOrder = "-1-001",
        final_effect = nuke_explosions.N1Mt_detonation
      })
      table.insert(warheads["TN-warhead-big--2"].explosions, {
        additional_ingedients = {{type = "item", name = fusionMaterial, amount = 200}},
        appendName = "-5Mt",
        appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.tritium, tints.tritium}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "5Mt"}),
        appendOrder = "-1-005",
        final_effect = nuke_explosions.N5Mt_detonation
      })
    end
    warheads["TN-warhead-big--3"] = {
      appendName = "-atomic-2-stage",
      appendOrder = "x-n-a-t",
      target_type = "position",
      size = "large",
      preciseSize = 40,
      appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.tritium, tints.uraniumLive}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "15kt+"}),
      chart_picture = "__paranoidal-true-nukes__/graphics/artillery/atomic-artillery-fusion-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 1,
      energy_required = 720,
      collisions = false,
      tech = "compact-fusion-weapons",
      ingredients = {
        {type = "item", name = "copper-plate", amount = 20},
        {type = "item", name = light, amount = 150},
        {type = "item", name = computer, amount = 300},
        {type = "item", name = "copper-cable", amount = 200},
        {type = "item", name = "FOGBANK", amount = 60},
        {type = "item", name = "heat-pipe", amount = 60},
        {type = "item", name = reflector, amount = 80},
        {type = "item", name = "explosives", amount = 75},
        {type = "item", name = dead, amount = 50},
        {type = "item", name = boom, amount = 400}
      },
      progressiveRecipe = "from-first",
      explosions = {
        {
          additional_ingedients = {},
          appendName = "-15kt",
          appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.tritium, tints.uraniumLive}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "15kt"}),
          appendOrder = "-0-015",
          final_effect = nuke_explosions.N15kt_detonation
        },
        {
          additional_ingedients = {{type = "item", name = fusionMaterial, amount = 8}},
          appendName = "-100kt",
          appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.tritium, tints.uraniumLive}, text_location = "__paranoidal-true-nukes__/graphics/text/", text = "100kt"}),
          appendOrder = "-0-100",
          final_effect = nuke_explosions.N100kt_detonation
        }
      }
    }
  end
end

-- Paranoidal 9.0.0, hybrid materials (user decision 2026-11-15): the early charges (up to 20 t) stay on
-- uranium-235; the main fission charges (500 t, 1 kt, 15 kt) and the primary stage of the two-stage charges
-- use the build's plutonium, a third of the uranium-235 amount (a smaller critical mass). The two-stage
-- warheads also carry the expensive parts of the removed Clowns thermonuclear bomb: a fission reactor and
-- three tier 5 modules.
local function exists(name)
  for _, kind in pairs({"item", "module", "item-with-entity-data", "ammo", "capsule", "tool"}) do
    if data.raw[kind] and data.raw[kind][name] then return true end
  end
  return false
end
local plutonium = "bob-plutonium-239"
if exists(plutonium) and boom ~= plutonium then
  for _, key in pairs({"TN-warhead-500--1", "TN-warhead-500--3", "TN-warhead-1k--1", "TN-warhead-1k--3",
    "TN-warhead-15k--1", "TN-warhead-15k--2", "TN-warhead-big--1", "TN-warhead-big--2", "TN-warhead-big--3"}) do
    for _, i in pairs(warheads[key] and warheads[key].ingredients or {}) do
      if i.name == boom then
        i.name = plutonium
        i.amount = math.max(1, math.ceil(i.amount / 3))
      end
    end
  end
end
for _, key in pairs({"TN-warhead-big--1", "TN-warhead-big--2", "TN-warhead-big--3"}) do
  local w = warheads[key]
  if w then
    for _, extra in pairs({"bob-fission-reactor-equipment-2", "bob-speed-module-5", "bob-productivity-module-5", "bob-efficiency-module-5"}) do
      if exists(extra) then table.insert(w.ingredients, {type = "item", name = extra, amount = 1}) end
    end
  end
end
