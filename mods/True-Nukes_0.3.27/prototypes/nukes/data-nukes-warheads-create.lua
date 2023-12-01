local nuke_materials = require("data-nukes-material")
local nuke_explosions = require("data-nuke-explosions")

local dead = nuke_materials.deadMaterial
local boom = nuke_materials.boomMaterial
local small = nuke_materials.smallBoomMaterial
local light = nuke_materials.lightMaterial
local reflector = nuke_materials.reflector
local computer = nuke_materials.computer
local fusionMaterial = nuke_materials.fusionMaterial

local create_utils = require("__Warheads__.prototypes.sprite-assembly-util")


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

    appearance = createAppearance({type = "nuclear_core", tints = {tints.californium, tints.californium, tints.nothing}, text_location = "__True-Nukes__/graphics/text/", text = "0_1t"}),
    chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
    cooldown_modifier = 2,
    stack_size = 100,
    energy_required = 100,
    collisions = false,
    recipe_result_count = 10,
    tech = "californium-weapons",
    ingredients = {
      {"steel-plate", 5},
      {light, 5},
      {computer, 2},
      {"explosives", 2},
      {dead, 4},
      {small, 10},
    },
  }
  warheads["TN-warhead-0-5--1"] = {
    appendName = "-atomic-0_5t",
    appendOrder = "x-n-a-m-000005-1",
    target_type = "position",
    size = "small",
    preciseSize = 12,
    final_effect = nuke_explosions.N0_5t_detonation,

    appearance = createAppearance({type = "nuclear_core", tints = {tints.californium, tints.californium, tints.uraniumDead}, text_location = "__True-Nukes__/graphics/text/", text = "0_5t"}),
    chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
    cooldown_modifier = 5,
    stack_size = 100,
    energy_required = 90,

    collisions = false,
    tech = "californium-weapons",
    recipe_result_count = 6,
    ingredients = {
      {"steel-plate", 1},
      {light, 12},
      {computer, 3},
      {"explosives", 3},
      {dead, 4},
      {small, 12}
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

      appearance = createAppearance({type = "nuclear_core", tints = {tints.californium, tints.californium, tints.nothing}, text_location = "__True-Nukes__/graphics/text/", text = "0_1t"}),
      chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 200,
      energy_required = 100,
      collisions = false,
      tech = "compact-californium-weapons",
      recipe_result_count = 5,
      ingredients = {
        {light, 10},
        {computer, 2},
        {reflector, 1},
        {"explosives", 2},
        {dead, 1},
        {small, 8},
      }
    }
    warheads["TN-warhead-0-1--3"] = {
      appendName = "-atomic-0_1t",
      appendOrder = "x-n-a-m-000001-3",
      target_type = "position",
      size = "tiny",
      preciseSize = 2,
      final_effect = nuke_explosions.N0_1t_detonation,

      appearance = createAppearance({type = "nuclear_core", tints = {tints.californium, tints.californium, tints.californium}, text_location = "__True-Nukes__/graphics/text/", text = "0_1t"}),
      chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 200,
      energy_required = 80,
      collisions = false,
      tech = "compact-californium-weapons",
      recipe_result_count = 2,
      ingredients = {
        {light, 3},
        {computer, 2},
        {reflector, 2},
        {"explosives", 1},
        {small, 4},
      }
    }
    warheads["TN-warhead-0-5--2"] = {
      appendName = "-atomic-0_5t",
      appendOrder = "x-n-a-m-000005-2",
      target_type = "position",
      size = "tiny",
      preciseSize = 8,
      final_effect = nuke_explosions.N0_5t_detonation,

      appearance = createAppearance({type = "nuclear_core", tints = {tints.californium, tints.californium, tints.uraniumDead}, text_location = "__True-Nukes__/graphics/text/", text = "0_5t"}),
      chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 100,
      energy_required = 90,
      collisions = false,
      tech = "compact-californium-weapons",
      recipe_result_count = 3,
      ingredients = {
        {light, 9},
        {computer, 3},
        {reflector, 1},
        {"explosives", 2},
        {dead, 1},
        {small, 9}
      }
    }
    warheads["TN-warhead-0-5--3"] = {
      appendName = "-atomic-0_5t",
      appendOrder = "x-n-a-m-000005-3",
      target_type = "position",
      size = "tiny",
      preciseSize = 4,
      final_effect = nuke_explosions.N0_5t_detonation,

      appearance = createAppearance({type = "nuclear_core", tints = {tints.californium, tints.californium, tints.californium}, text_location = "__True-Nukes__/graphics/text/", text = "0_5t"}),
      chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 100,
      energy_required = 60,
      collisions = false,
      tech = "compact-californium-weapons",
      ingredients = {
        {light, 2},
        {computer, 1},
        {reflector, 1},
        {"explosives", 1},
        {small, 5}
      }
    }
  end
end
if (not settings.startup["keep-atomic-bomb-without-changes"]) then
  data.raw.item["atomic-bomb"] = nil
  data.raw.recipe["atomic-bomb"] = nil
end
if(settings.startup["enable-medium-atomics"].value) then
  warheads["TN-warhead-2--1"] = {
    appendName = "-atomic-2t",
    appendOrder = "x-n-a-m-00002-1",
    target_type = "position",
    size = "small",
    preciseSize = 16,
    final_effect = nuke_explosions.N2t_detonation,

    appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.californium, tints.nothing}, text_location = "__True-Nukes__/graphics/text/", text = "2t"}),
    chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
    cooldown_modifier = 5,
    stack_size = 20,
    energy_required = 20,
    collisions = false,
    tech = "californium-weapons",
    ingredients = {
      {"steel-plate", 5},
      {computer, 5},
      {"explosives", 5},
      {dead, 3},
      {boom, 3},
      {small, 4}
    }
  }
  warheads["TN-warhead-4--1"] = {
    appendName = "-atomic-4t",
    appendOrder = "x-n-a-m-00004-1",
    target_type = "position",
    size = "medium",
    preciseSize = 22,
    final_effect = nuke_explosions.N4t_detonation,

    appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.californium, tints.uraniumDead}, text_location = "__True-Nukes__/graphics/text/", text = "4t"}),
    chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
    cooldown_modifier = 5,
    stack_size = 10,
    energy_required = 30,
    collisions = false,
    tech = "atomic-bomb",
    ingredients = {
      {"steel-plate", 5},
      {computer, 5},
      {"explosives", 10},
      {dead, 5},
      {boom, 8}
    }
  }
  warheads["TN-warhead-8--1"] = {
    appendName = "-atomic-8t",
    appendOrder = "x-n-a-m-00008-1",
    target_type = "position",
    size = "medium",
    preciseSize = 28,

    final_effect = nuke_explosions.N8t_detonation,
    appearance = createAppearance({type = "nuclear_core", tints = {tints.californium, tints.uraniumLive, tints.nothing}, text_location = "__True-Nukes__/graphics/text/", text = "8t"}),
    chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
    cooldown_modifier = 5,
    stack_size = 10,
    energy_required = 40,
    collisions = false,
    tech = "atomic-bomb",
    ingredients = {
      {"steel-plate", 6},
      {computer, 5},
      {"explosives", 20},
      {dead, 10},
      {boom, 15}
    }
  }
  warheads["TN-warhead-2--2"] = {
    appendName = "-atomic-2t",
    appendOrder = "x-n-a-m-00002-2",
    target_type = "position",
    size = "small",
    preciseSize = 12,
    final_effect = nuke_explosions.N2t_detonation,

    appearance = createAppearance({type = "nuclear_core", tints = {tints.californium, tints.californium, tints.californium}, text_location = "__True-Nukes__/graphics/text/", text = "2t"}),
    chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
    cooldown_modifier = 5,
    stack_size = 20,
    energy_required = 60,
    collisions = false,
    tech = "compact-californium-weapons",
    ingredients = {
      {"steel-plate", 1},
      {light, 4},
      {computer, 10},
      {reflector, 1},
      {"explosives", 4},
      {dead, 2},
      {boom, 1},
      {small, 8}
    }
  }
  warheads["TN-warhead-20--1"] = {
    appendName = "-atomic-20t",
    appendOrder = "x-n-a-m-00020-1",
    target_type = "position",
    size = "large",
    preciseSize = 32,

    final_effect = nuke_explosions.N20t_detonation,
    appearance = createAppearance({type = "nuclear_core", tints = {tints.californium, tints.uraniumLive, tints.uraniumDead}, text_location = "__True-Nukes__/graphics/text/", text = "20t"}),
    chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
    cooldown_modifier = 5,
    stack_size = 5,
    energy_required = 60,
    collisions = false,
    tech = "basic-atomic-weapons",
    ingredients = {
      {"steel-plate", 10},
      {computer, 8},
      {"explosives", 30},
      {dead, 15},
      {boom, 30}
    }
  }
  warheads["TN-warhead-20--2"] = {
    appendName = "-atomic-20t",
    appendOrder = "x-n-a-m-00020-2",
    target_type = "position",

    size = "medium",
    preciseSize = 26,
    final_effect = nuke_explosions.N20t_detonation,
    appearance = createAppearance({type = "nuclear_core", tints = {tints.californium, tints.uraniumLive, tints.uraniumDead}, text_location = "__True-Nukes__/graphics/text/", text = "20t"}),
    chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
    cooldown_modifier = 5,
    stack_size = 5,
    energy_required = 120,
    collisions = false,
    tech = "atomic-bomb",
    ingredients = {
      {light, 20},
      {computer, 20},
      {"explosives", 15},
      {dead, 5},
      {boom, 50}
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

      appearance = createAppearance({type = "nuclear_core", tints = {tints.californium, tints.californium, tints.californium}, text_location = "__True-Nukes__/graphics/text/", text = "2t"}),
      chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 20,
      energy_required = 120,
      collisions = false,
      tech = "compact-californium-weapons",
      ingredients = {
        {light, 10},
        {computer, 15},
        {reflector, 4},
        {"explosives", 2},
        {small, 15}
      }
    }
    warheads["TN-warhead-4--2"] = {
      appendName = "-atomic-4t",
      appendOrder = "x-n-a-m-00004-2",
      target_type = "position",
      size = "small",
      preciseSize = 16,
      final_effect = nuke_explosions.N4t_detonation,

      appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.californium, tints.uraniumDead}, text_location = "__True-Nukes__/graphics/text/", text = "4t"}),
      chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 10,
      energy_required = 90,
      collisions = false,
      tech = "californium-weapons",
      ingredients = {
        {light, 10},
        {computer, 12},
        {"explosives", 5},
        {boom, 2},
        {small, 10}
      }
    }
    warheads["TN-warhead-4--3"] = {
      appendName = "-atomic-4t",
      appendOrder = "x-n-a-m-00004-3",
      target_type = "position",
      size = "small",
      preciseSize = 12,
      final_effect = nuke_explosions.N4t_detonation,

      appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.californium, tints.californium}, text_location = "__True-Nukes__/graphics/text/", text = "4t"}),
      chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 10,
      energy_required = 180,
      collisions = false,
      tech = "compact-californium-weapons",
      ingredients = {
        {light, 15},
        {computer, 20},
        {reflector, 8},
        {"explosives", 5},
        {small, 20}
      }
    }
    warheads["TN-warhead-8--2"] = {
      appendName = "-atomic-8t",
      appendOrder = "x-n-a-m-00008-2",
      target_type = "position",
      size = "small",
      preciseSize = 20,

      final_effect = nuke_explosions.N8t_detonation,
      appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.californium, tints.californium}, text_location = "__True-Nukes__/graphics/text/", text = "8t"}),
      chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 10,
      energy_required = 120,
      collisions = false,
      tech = "californium-weapons",
      ingredients = {
        {light, 15},
        {computer, 16},
        {"explosives", 8},
        {boom, 2},
        {small, 20}
      }
    }
    warheads["TN-warhead-8--3"] = {
      appendName = "-atomic-8t",
      appendOrder = "x-n-a-m-00008-3",
      target_type = "position",
      size = "small",
      preciseSize = 15,

      final_effect = nuke_explosions.N8t_detonation,
      appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.californium, tints.californium}, text_location = "__True-Nukes__/graphics/text/", text = "8t"}),
      chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 10,
      energy_required = 240,
      collisions = false,
      tech = "compact-californium-weapons",
      ingredients = {
        {light, 20},
        {computer, 24},
        {reflector, 12},
        {"explosives", 10},
        {small, 35}
      }
    }

    warheads["TN-warhead-20--3"] = {
      appendName = "-atomic-20t",
      appendOrder = "x-n-a-m-00020-3",
      target_type = "position",

      size = "small",
      preciseSize = 20,
      final_effect = nuke_explosions.N20t_detonation,
      appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.californium, tints.californium}, text_location = "__True-Nukes__/graphics/text/", text = "20t"}),
      chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-californium-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 5,
      energy_required = 300,
      collisions = false,
      tech = "compact-californium-weapons",
      ingredients = {
        {light, 50},
        {computer, 40},
        {reflector, 12},
        {"explosives", 5},
        {boom, 5},
        {small, 45}
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
    appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.uraniumLive, tints.nothing}, text_location = "__True-Nukes__/graphics/text/", text = "500t"}),
    chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-map-visualization.png",
    cooldown_modifier = 5,
    stack_size = 1,
    energy_required = 90,
    collisions = false,
    tech = "expanded-atomics",
    ingredients = {
      {"steel-plate", 20},
      {computer, 10},
      {"explosives", 40},
      {dead, 25},
      {boom, 75}
    }
  }
  warheads["TN-warhead-1k--1"] = {
    appendName = "-atomic-1kt",
    appendOrder = "x-n-a-m-01-1",
    target_type = "position",

    size = "large",
    preciseSize = 40,
    final_effect = nuke_explosions.N1kt_detonation,
    appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.uraniumLive, tints.uraniumDead}, text_location = "__True-Nukes__/graphics/text/", text = "1kt"}),
    chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-map-visualization.png",
    cooldown_modifier = 5,
    stack_size = 1,
    energy_required = 120,
    collisions = false,
    tech = "full-fission-atomics",
    ingredients = {
      {"steel-plate", 25},
      {computer, 20},
      {"explosives", 100},
      {dead, 25},
      {boom, 100}
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
      appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.uraniumLive, tints.nothing}, text_location = "__True-Nukes__/graphics/text/", text = "500t"}),
      chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 1,
      energy_required = 210,
      collisions = false,
      tech = "full-fission-atomics",
      ingredients = {
        {"steel-plate", 5},
        {light, 15},
        {computer, 20},
        {"explosives", 25},
        {dead, 15},
        {boom, 100},
      }
    }
    warheads["TN-warhead-500--3"] = {
      appendName = "-atomic-500t",
      appendOrder = "x-n-a-m-005-3",
      target_type = "position",

      size = "medium",
      preciseSize = 26,
      final_effect = nuke_explosions.N500t_detonation,
      appearance = createAppearance({type = "nuclear_core", tints = {tints.californium, tints.uraniumLive, tints.uraniumLive}, text_location = "__True-Nukes__/graphics/text/", text = "500t"}),
      chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 1,
      energy_required = 360,
      collisions = false,
      tech = "compact-full-fission-weapons",
      ingredients = {
        {light, 45},
        {computer, 50},
        {reflector, 15},
        {"explosives", 10},
        {boom, 50},
        {small, 60}
      }
    }
    warheads["TN-warhead-1k--2"] = {
      appendName = "-atomic-1kt",
      appendOrder = "x-n-a-m-01-2",
      target_type = "position",

      size = "large",
      preciseSize = 35,
      final_effect = nuke_explosions.N1kt_detonation,
      appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.uraniumLive, tints.uraniumDead}, text_location = "__True-Nukes__/graphics/text/", text = "1kt"}),
      chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 1,
      energy_required = 300,
      collisions = false,
      tech = "compact-full-fission-weapons",
      ingredients = {
        {"steel-plate", 8},
        {light, 20},
        {computer, 45},
        {"explosives", 50},
        {dead, 5},
        {boom, 120},
      }
    }
    warheads["TN-warhead-1k--3"] = {
      appendName = "-atomic-1kt",
      appendOrder = "x-n-a-m-01-3",
      target_type = "position",

      size = "medium",
      preciseSize = 30,
      final_effect = nuke_explosions.N1kt_detonation,
      appearance = createAppearance({type = "nuclear_core", tints = {tints.californium, tints.uraniumLive, tints.uraniumLive}, text_location = "__True-Nukes__/graphics/text/", text = "1kt"}),
      chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 1,
      energy_required = 600,
      collisions = false,
      tech = "compact-full-fission-weapons",
      ingredients = {
        {light, 60},
        {computer, 100},
        {"red-wire", 20},
        {reflector, 20},
        {"explosives", 20},
        {boom, 80},
        {small, 80}
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
    appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.uraniumLive, tints.uraniumLive}, text_location = "__True-Nukes__/graphics/text/", text = "15kt"}),
    chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-map-visualization.png",
    cooldown_modifier = 5,
    stack_size = 1,
    energy_required = 180,
    collisions = false,
    tech = "full-fission-atomics",
    ingredients = {
      {"steel-plate", 30},
      {computer, 40},
      {"red-wire", 5},
      {"green-wire", 5},
      {"explosives", 175},
      {dead, 150},
      {boom, 250}
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
      appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.uraniumLive, tints.uraniumLive}, text_location = "__True-Nukes__/graphics/text/", text = "15kt"}),
      chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 1,
      energy_required = 480,
      collisions = false,
      tech = "compact-full-fission-weapons",
      ingredients = {
        {"steel-plate", 10},
        {light, 30},
        {computer, 160},
        {"red-wire", 10},
        {"green-wire", 10},
        {reflector, 10},
        {"explosives", 130},
        {dead, 25},
        {boom, 325}
      }
    }
    warheads["TN-warhead-15k--3"] = {
      appendName = "-atomic-15kt",
      appendOrder = "x-n-a-m-15-3",
      target_type = "position",

      size = "large",
      preciseSize = 33,
      final_effect = nuke_explosions.N15kt_detonation,
      appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.uraniumLive, tints.uraniumLive}, text_location = "__True-Nukes__/graphics/text/", text = "15kt"}),
      chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 1,
      energy_required = 720,
      collisions = false,
      tech = "compact-full-fission-weapons",
      ingredients = {
        {light, 75},
        {computer, 200},
        {"red-wire", 20},
        {"green-wire", 20},
        {reflector, 50},
        {"explosives", 100},
        {boom, 300},
        {small, 50}
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
    appearance = createAppearance({type = "nuclear_core", tints = {tints.tritium, tints.tritium, tints.tritium}, text_location = "__True-Nukes__/graphics/text/", text = "15kt+"}),
    chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-fusion-map-visualization.png",
    cooldown_modifier = 5,
    stack_size = 1,
    energy_required = 180,
    collisions = false,
    tech = "fusion-weapons",
    ingredients = {
      {"steel-plate", 100},
      {"copper-plate", 100},
      {computer, 100},
      {"red-wire", 20},
      {"green-wire", 20},
      {"FOGBANK", 10},
      {"heat-pipe", 10},
      {reflector, 20},
      {"explosives", 200},
      {dead, 400},
      {boom, 250}
    },
    progressiveRecipe = "from-first",
    explosions = {
      {
        additional_ingedients = {},
        appendName = "-15kt",
        appearance = createAppearance({type = "nuclear_core", tints = {tints.tritium, tints.tritium, tints.tritium}, text_location = "__True-Nukes__/graphics/text/", text = "15kt"}),
        appendOrder = "-0-015",
        final_effect = nuke_explosions.N15kt_detonation
      },
      {
        additional_ingedients = {{fusionMaterial, 2}},
        appendName = "-100kt",
        appearance = createAppearance({type = "nuclear_core", tints = {tints.tritium, tints.tritium, tints.tritium}, text_location = "__True-Nukes__/graphics/text/", text = "100kt"}),
        appendOrder = "-0-100",
        final_effect = nuke_explosions.N100kt_detonation
      }
    }
  }
  if(settings.startup["enable-big-fusion-weapons"].value) then
    table.insert(warheads["TN-warhead-big--1"].explosions, {
      additional_ingedients = {{fusionMaterial, 20}},
      appendName = "-1Mt",
      appearance = createAppearance({type = "nuclear_core", tints = {tints.tritium, tints.tritium, tints.tritium}, text_location = "__True-Nukes__/graphics/text/", text = "1Mt"}),
      appendOrder = "-1-001",
      final_effect = nuke_explosions.N1Mt_detonation
    })
    table.insert(warheads["TN-warhead-big--1"].explosions, {
      additional_ingedients = {{fusionMaterial, 100}},
      appendName = "-5Mt",
      appearance = createAppearance({type = "nuclear_core", tints = {tints.tritium, tints.tritium, tints.tritium}, text_location = "__True-Nukes__/graphics/text/", text = "5Mt"}),
      appendOrder = "-1-005",
      final_effect = nuke_explosions.N5Mt_detonation
    })
    table.insert(warheads["TN-warhead-big--1"].explosions, {
      additional_ingedients = {{fusionMaterial, 200}},
      appendName = "-10Mt",
      appearance = createAppearance({type = "nuclear_core", tints = {tints.tritium, tints.tritium, tints.tritium}, text_location = "__True-Nukes__/graphics/text/", text = "10Mt"}),
      appendOrder = "-1-010",
      final_effect = nuke_explosions.N10Mt_detonation
    })
    table.insert(warheads["TN-warhead-big--1"].explosions, {
      additional_ingedients = {{fusionMaterial, 1000}},
      appendName = "-50Mt",
      appearance = createAppearance({type = "nuclear_core", tints = {tints.tritium, tints.tritium, tints.tritium}, text_location = "__True-Nukes__/graphics/text/", text = "50Mt"}),
      appendOrder = "-1-050",
      final_effect = nuke_explosions.N50Mt_detonation
    })
    table.insert(warheads["TN-warhead-big--1"].explosions, {
      additional_ingedients = {{fusionMaterial, 2000}},
      appendName = "-100Mt",
      appearance = createAppearance({type = "nuclear_core", tints = {tints.tritium, tints.tritium, tints.tritium}, text_location = "__True-Nukes__/graphics/text/", text = "100Mt"}),
      appendOrder = "-1-100",
      final_effect = nuke_explosions.N100Mt_detonation
    })
    table.insert(warheads["TN-warhead-big--1"].explosions, {
      additional_ingedients = {{fusionMaterial, 20000}},
      appendName = "-1Gt",
      appearance = createAppearance({type = "nuclear_core", tints = {tints.tritium, tints.tritium, tints.tritium}, text_location = "__True-Nukes__/graphics/text/", text = "1Gt"}),
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
      appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.tritium, tints.tritium}, text_location = "__True-Nukes__/graphics/text/", text = "15kt+"}),
      chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-fusion-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 1,
      energy_required = 300,
      collisions = false,
      tech = "compact-fusion-weapons",
      ingredients = {
        {"steel-plate", 50},
        {"copper-plate", 50},
        {light, 80},
        {computer, 200},
        {"red-wire", 40},
        {"green-wire", 40},
        {"FOGBANK", 40},
        {"heat-pipe", 40},
        {reflector, 40},
        {"explosives", 130},
        {dead, 200},
        {boom, 325}
      },
      progressiveRecipe = "from-first",
      explosions = {
        {
          additional_ingedients = {},
          appendName = "-15kt",
          appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.tritium, tints.tritium}, text_location = "__True-Nukes__/graphics/text/", text = "15kt"}),
          appendOrder = "-0-015",
          final_effect = nuke_explosions.N15kt_detonation
        },
        {
          additional_ingedients = {{fusionMaterial, 4}},
          appendName = "-100kt",
          appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.tritium, tints.tritium}, text_location = "__True-Nukes__/graphics/text/", text = "100kt"}),
          appendOrder = "-0-100",
          final_effect = nuke_explosions.N100kt_detonation
        }
      }
    }
    if(settings.startup["enable-big-fusion-weapons"].value) then
      table.insert(warheads["TN-warhead-big--2"].explosions, {
        additional_ingedients = {{fusionMaterial, 40}},
        appendName = "-1Mt",
        appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.tritium, tints.tritium}, text_location = "__True-Nukes__/graphics/text/", text = "1Mt"}),
        appendOrder = "-1-001",
        final_effect = nuke_explosions.N1Mt_detonation
      })
      table.insert(warheads["TN-warhead-big--2"].explosions, {
        additional_ingedients = {{fusionMaterial, 200}},
        appendName = "-5Mt",
        appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.tritium, tints.tritium}, text_location = "__True-Nukes__/graphics/text/", text = "5Mt"}),
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
      appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.tritium, tints.uraniumLive}, text_location = "__True-Nukes__/graphics/text/", text = "15kt+"}),
      chart_picture = "__True-Nukes__/graphics/artillery/atomic-artillery-fusion-map-visualization.png",
      cooldown_modifier = 5,
      stack_size = 1,
      energy_required = 720,
      collisions = false,
      tech = "compact-fusion-weapons",
      ingredients = {
        {"copper-plate", 20},
        {light, 150},
        {computer, 300},
        {"red-wire", 100},
        {"green-wire", 100},
        {"FOGBANK", 60},
        {"heat-pipe", 60},
        {reflector, 80},
        {"explosives", 75},
        {dead, 50},
        {boom, 400}
      },
      progressiveRecipe = "from-first",
      explosions = {
        {
          additional_ingedients = {},
          appendName = "-15kt",
          appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.tritium, tints.uraniumLive}, text_location = "__True-Nukes__/graphics/text/", text = "15kt"}),
          appendOrder = "-0-015",
          final_effect = nuke_explosions.N15kt_detonation
        },
        {
          additional_ingedients = {{fusionMaterial, 8}},
          appendName = "-100kt",
          appearance = createAppearance({type = "nuclear_core", tints = {tints.uraniumLive, tints.tritium, tints.uraniumLive}, text_location = "__True-Nukes__/graphics/text/", text = "100kt"}),
          appendOrder = "-0-100",
          final_effect = nuke_explosions.N100kt_detonation
        }
      }
    }
  end
end
