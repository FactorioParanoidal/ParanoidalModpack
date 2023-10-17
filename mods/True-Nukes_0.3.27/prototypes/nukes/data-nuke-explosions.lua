function add_mushroom_cloud_effect(effect, prefix)
  table.insert(effect, 2, {
    type = "create-entity",
    entity_name = prefix .. "uranium-explosion-LUQ",
  })
  table.insert(effect, 3, {
    type = "create-entity",
    entity_name = prefix .. "uranium-explosion-RUQ"
  })
  table.insert(effect, 4, {
    type = "create-entity",
    entity_name = prefix .. "uranium-explosion-LLQ"
  })
  table.insert(effect, 5, {
    type = "create-entity",
    entity_name = prefix .. "uranium-explosion-RLQ"
  })
  table.insert(effect, 6, {
    type = "create-entity",
    entity_name = "nuclear-scorchmark",
    check_buildability = true
  })
  table.insert(effect, 7, {
    type = "create-entity",
    entity_name = "radiation-cloud"
  })

end

local N0_1t_detonation = {
  {
    type = "create-trivial-smoke",
    smoke_name = "artillery-smoke",
    initial_height = 0,
    speed_from_center = 0.05,
    speed_from_center_deviation = 0.005,
    offset_deviation = {{-4, -4}, {4, 4}},
    max_radius = 3.5,
    repeat_count = 4 * 4 * 15
  },
  {
    type = "script",
    effect_id = "Atomic Weapon hit 0.1t"
  },
  {
    type = "create-entity",
    entity_name = "medium-scorchmark-tintable",
    check_buildability = true
  },
  {
    type = "create-entity",
    entity_name = "massive-explosion"
  },
  {
    type = "destroy-cliffs",
    radius = 1
  },
  {
    type = "destroy-decoratives",
    from_render_layer = "decals",
    to_render_layer = "object",
    include_soft_decoratives = true,
    include_decals = true,
    invoke_decorative_trigger = false,
    decoratives_with_trigger_only = false,
    radius = 1
  },
  {
    type = "nested-result",
    action =
    {
      type = "area",
      target_entities = true,
      trigger_from_target = true,
      radius = 10,
      action_delivery =
      {
        type = "instant",
        target_effects = {
          {
            type = "create-fire",
            entity_name = "thermobaric-wave-fire",
            initial_ground_flame_count = 1
          }
        }
      }
    }
  },
  {
    type = "nested-result",
    action =
    {
      type = "area",
      target_entities = false,
      trigger_from_target = true,
      repeat_count = 1,
      radius = 1,
      action_delivery =
      {
        type = "projectile",
        show_in_tooltip = false,
        projectile = "fallout",
        starting_speed = 0.0001
      }
    }
  }
}

local N0_5t_detonation = {
  {
    type = "script",
    effect_id = "Atomic Weapon hit 0.5t"
  },
  {
    type = "create-entity",
    entity_name = "medium-scorchmark-tintable",
    check_buildability = true
  },
  {
    type = "create-entity",
    entity_name = "massive-explosion"
  },
  {
    type = "destroy-cliffs",
    radius = 3
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
      radius = 50,
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
      radius = 50,
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          type = "damage",
          damage = {amount = 2, type = "impact"}
        }
      }
    }
  },
  {
    type = "nested-result",
    action =
    {
      type = "area",
      target_entities = true,
      trigger_from_target = true,
      radius = 20,
      action_delivery =
      {
        type = "instant",
        target_effects = {
          {
            type = "create-fire",
            entity_name = "thermobaric-wave-fire",
            initial_ground_flame_count = 1
          }
        }
      }
    }
  },
  {
    type = "nested-result",
    action =
    {
      type = "area",
      target_entities = false,
      trigger_from_target = true,
      repeat_count = 1,
      radius = 2,
      action_delivery =
      {
        type = "projectile",
        show_in_tooltip = false,
        projectile = "fallout",
        starting_speed = 0.0001
      }
    }
  }
}

local N2t_detonation = {
  {
    type = "script",
    effect_id = "Atomic Weapon hit 2t"
  },
  {
    repeat_count = 100,
    type = "create-trivial-smoke",
    smoke_name = "nuclear-smoke",
    offset_deviation = {{-1, -1}, {1, 1}},
    starting_frame = 3,
    starting_frame_deviation = 5,
    starting_frame_speed = 0,
    starting_frame_speed_deviation = 5,
    speed_from_center = 3
  },
  {
    type = "create-entity",
    entity_name = "big-scorchmark-tintable",
    check_buildability = true
  },
  {
    type = "create-entity",
    entity_name = "nuke-explosion"
  },
  {
    type = "destroy-cliffs",
    radius = 5
  },
  {
    type = "destroy-decoratives",
    from_render_layer = "decals",
    to_render_layer = "object",
    include_soft_decoratives = true,
    include_decals = true,
    invoke_decorative_trigger = false,
    decoratives_with_trigger_only = false,
    radius = 10
  },
  {
    type = "nested-result",
    action =
    {
      type = "area",
      radius = 150,
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
      radius = 150,
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          type = "damage",
          damage = {amount = 2, type = "impact"}
        }
      }
    }
  },
  {
    type = "nested-result",
    action =
    {
      type = "area",
      target_entities = true,
      trigger_from_target = true,
      radius = 50,
      action_delivery =
      {
        type = "instant",
        target_effects = {
          {
            type = "create-fire",
            entity_name = "thermobaric-wave-fire",
            initial_ground_flame_count = 1
          }
        }
      }
    }
  },
  {
    type = "nested-result",
    action =
    {
      type = "area",
      target_entities = false,
      trigger_from_target = true,
      repeat_count = 1,
      radius = 10,
      action_delivery =
      {
        type = "projectile",
        show_in_tooltip = false,
        projectile = "lingering-fallout",
        starting_speed = 0.0001
      }
    }
  },
  {
    type = "nested-result",
    action =
    {
      type = "area",
      target_entities = false,
      trigger_from_target = true,
      repeat_count = 5,
      radius = 20,
      action_delivery =
      {
        type = "projectile",
        show_in_tooltip = false,
        projectile = "fallout",
        starting_speed = 0.0001
      }
    }
  }
}


local N4t_detonation = {
  {
    type = "script",
    effect_id = "Atomic Weapon hit 4t"
  },
  {
    repeat_count = 100,
    type = "create-trivial-smoke",
    smoke_name = "nuclear-smoke",
    offset_deviation = {{-1, -1}, {1, 1}},
    starting_frame = 3,
    starting_frame_deviation = 5,
    starting_frame_speed = 0,
    starting_frame_speed_deviation = 5,
    speed_from_center = 3
  },
  {
    type = "create-entity",
    entity_name = "big-scorchmark-tintable",
    check_buildability = true
  },
  {
    type = "create-entity",
    entity_name = "nuke-explosion"
  },
  {
    type = "destroy-cliffs",
    radius = 8
  },
  {
    type = "destroy-decoratives",
    from_render_layer = "decals",
    to_render_layer = "object",
    include_soft_decoratives = true,
    include_decals = true,
    invoke_decorative_trigger = false,
    decoratives_with_trigger_only = false,
    radius = 10
  },
  {
    type = "nested-result",
    action =
    {
      type = "area",
      radius = 200,
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
      radius = 200,
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          type = "damage",
          damage = {amount = 2, type = "impact"}
        }
      }
    }
  },
  {
    type = "nested-result",
    action =
    {
      type = "area",
      target_entities = true,
      trigger_from_target = true,
      radius = 70,
      action_delivery =
      {
        type = "instant",
        target_effects = {
          {
            type = "create-fire",
            entity_name = "thermobaric-wave-fire",
            initial_ground_flame_count = 1
          }
        }
      }
    }
  },
  {
    type = "nested-result",
    action =
    {
      type = "area",
      target_entities = false,
      trigger_from_target = true,
      repeat_count = 3,
      radius = 10,
      action_delivery =
      {
        type = "projectile",
        show_in_tooltip = false,
        projectile = "lingering-fallout",
        starting_speed = 0.0001
      }
    }
  },
  {
    type = "nested-result",
    action =
    {
      type = "area",
      target_entities = false,
      trigger_from_target = true,
      repeat_count = 10,
      radius = 30,
      action_delivery =
      {
        type = "projectile",
        show_in_tooltip = false,
        projectile = "fallout",
        starting_speed = 0.0001
      }
    }
  }
}

local N8t_detonation = {
  {
    type = "script",
    effect_id = "Atomic Weapon hit 8t"
  },
  {
    repeat_count = 100,
    type = "create-trivial-smoke",
    smoke_name = "nuclear-smoke",
    offset_deviation = {{-1, -1}, {1, 1}},
    starting_frame = 3,
    starting_frame_deviation = 5,
    starting_frame_speed = 0,
    starting_frame_speed_deviation = 5,
    speed_from_center = 3
  },
  {
    type = "create-entity",
    entity_name = "big-scorchmark-tintable",
    check_buildability = true
  },
  {
    type = "destroy-cliffs",
    radius = 10
  },
  {
    type = "destroy-decoratives",
    from_render_layer = "decals",
    to_render_layer = "object",
    include_soft_decoratives = true,
    include_decals = true,
    invoke_decorative_trigger = false,
    decoratives_with_trigger_only = false,
    radius = 10
  },
  {
    type = "nested-result",
    action =
    {
      type = "area",
      radius = 250,
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
      radius = 250,
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          type = "damage",
          damage = {amount = 2, type = "impact"}
        }
      }
    }
  },
  {
    type = "nested-result",
    action =
    {
      type = "area",
      target_entities = true,
      trigger_from_target = true,
      radius = 100,
      action_delivery =
      {
        type = "instant",
        target_effects = {
          {
            type = "create-fire",
            entity_name = "thermobaric-wave-fire",
            initial_ground_flame_count = 1
          }
        }
      }
    }
  },
  {
    type = "nested-result",
    action =
    {
      type = "area",
      target_entities = false,
      trigger_from_target = true,
      repeat_count = 5,
      radius = 15,
      action_delivery =
      {
        type = "projectile",
        show_in_tooltip = false,
        projectile = "lingering-fallout",
        starting_speed = 0.0001
      }
    }
  },
  {
    type = "nested-result",
    action =
    {
      type = "area",
      target_entities = false,
      trigger_from_target = true,
      repeat_count = 15,
      radius = 40,
      action_delivery =
      {
        type = "projectile",
        show_in_tooltip = false,
        projectile = "fallout",
        starting_speed = 0.0001
      }
    }
  }
}
local N20t_detonation =
  {
    {
      type = "script",
      effect_id = "Atomic Weapon hit 20t"
    },
    {
      repeat_count = 1000,
      type = "create-trivial-smoke",
      smoke_name = "nuclear-smoke",
      offset_deviation = {{-1, -1}, {1, 1}},
      starting_frame = 3,
      starting_frame_deviation = 5,
      starting_frame_speed = 0,
      starting_frame_speed_deviation = 5,
      speed_from_center = 3
    },
    {
      type = "create-entity",
      entity_name = "nuclear-scorchmark",
      check_buildability = true
    },
    {
      type = "destroy-cliffs",
      radius = 10
    },
    {
      type = "destroy-decoratives",
      from_render_layer = "decals",
      to_render_layer = "object",
      include_soft_decoratives = true, -- soft decoratives are decoratives with grows_through_rail_path = true
      include_decals = true,
      invoke_decorative_trigger = false,
      decoratives_with_trigger_only = false, -- if true, destroys only decoratives that have trigger_effect set
      radius = 20 -- large radius for demostrative purposes
    },
    {
      type = "nested-result",
      action =
      {
        type = "area",
        radius = 340,
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
        target_entities = true,
        trigger_from_target = true,
        radius = 140,
        action_delivery =
        {
          type = "instant",
          target_effects = {
            {
              type = "create-fire",
              entity_name = "thermobaric-wave-fire",
              initial_ground_flame_count = 1
            }
          }
        }
      }
    },
    {
      type = "nested-result",
      action =
      {
        type = "area",
        target_entities = false,
        trigger_from_target = true,
        repeat_count = 50,
        radius = 30,
        action_delivery =
        {
          type = "projectile",
          projectile = "lingering-fallout",
          starting_speed = 0.0001
        }
      }
    },
    {
      type = "nested-result",
      action =
      {
        type = "area",
        target_entities = false,
        trigger_from_target = true,
        repeat_count = 100,
        radius = 30,
        action_delivery =
        {
          type = "projectile",
          projectile = "fallout",
          starting_speed = 0.0001
        }
      }
    },
    {
      type = "nested-result",
      action =
      {
        type = "area",
        target_entities = false,
        trigger_from_target = true,
        repeat_count = 100,
        radius = 50,
        action_delivery =
        {
          type = "projectile",
          projectile = "fallout",
          starting_speed = 0.0001
        }
      }
    },
    {
      type = "nested-result",
      action =
      {
        type = "area",
        target_entities = false,
        trigger_from_target = true,
        repeat_count = 100,
        radius = 100,
        action_delivery =
        {
          type = "projectile",
          projectile = "fallout",
          starting_speed = 0.0001
        }
      }
    }
  }
local N1kt_detonation = {
  {
    type = "script",
    effect_id = "Atomic Weapon hit 1kt"
  },
  {
    repeat_count = 10000,
    type = "create-trivial-smoke",
    smoke_name = "nuclear-smoke",
    offset_deviation = {{-1, -1}, {1, 1}},
    starting_frame = 3,
    starting_frame_deviation = 5,
    starting_frame_speed = 0,
    starting_frame_speed_deviation = 5,
    speed_from_center = 3
  },
  {
    type = "create-entity",
    entity_name = "nuclear-scorchmark",
    check_buildability = true
  },
  {
    type = "destroy-cliffs",
    radius = 80
  },
  {
    type = "destroy-decoratives",
    from_render_layer = "decals",
    to_render_layer = "object",
    include_soft_decoratives = true,
    include_decals = true,
    invoke_decorative_trigger = false,
    decoratives_with_trigger_only = false,
    radius = 80
  },
  {
    type = "nested-result",
    action =
    {
      type = "area",
      radius = 300,
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          type = "damage",
          damage = {amount = 2, type = "impact"}
        }
      }
    }
  },
  {
    type = "nested-result",
    action =
    {
      type = "area",
      target_entities = false,
      trigger_from_target = true,
      repeat_count = 50,
      radius = 50,
      action_delivery =
      {
        type = "projectile",
        projectile = "lingering-fallout",
        starting_speed = 0.0001
      }
    }
  },
  {
    type = "nested-result",
    action =
    {
      type = "area",
      target_entities = false,
      trigger_from_target = true,
      repeat_count = 100,
      radius = 50,
      action_delivery =
      {
        type = "projectile",
        projectile = "fallout",
        starting_speed = 0.0001
      }
    }
  },
  {
    type = "nested-result",
    action =
    {
      type = "area",
      target_entities = false,
      trigger_from_target = true,
      repeat_count = 100,
      radius = 100,
      action_delivery =
      {
        type = "projectile",
        projectile = "fallout",
        starting_speed = 0.0001
      }
    }
  },
  {
    type = "nested-result",
    action =
    {
      type = "area",
      target_entities = false,
      trigger_from_target = true,
      repeat_count = 100,
      radius = 200,
      action_delivery =
      {
        type = "projectile",
        projectile = "fallout",
        starting_speed = 0.0001
      }
    }
  }
}
local N500t_detonation = table.deepcopy(N1kt_detonation)
N500t_detonation[1].effect_id = "Atomic Weapon hit 500t"
N500t_detonation[4].radius = 60
N500t_detonation[5].radius = 60
N500t_detonation[6].action.radius = 150
N500t_detonation[7].action.radius = 25
N500t_detonation[7].action.repeat_count = 15
N500t_detonation[8].action.radius = 50
N500t_detonation[8].action.repeat_count = 15
N500t_detonation[9].action.radius = 50
N500t_detonation[9].action.repeat_count = 25
N500t_detonation[10].action.radius = 50
N500t_detonation[10].action.repeat_count = 40

local N15kt_detonation = table.deepcopy(N1kt_detonation)
N15kt_detonation[1].effect_id = "Atomic Weapon hit 15kt"
N15kt_detonation[4].radius = 200
N15kt_detonation[5].radius = 100
N15kt_detonation[6].action.radius = 500
N15kt_detonation[7].action.radius = 100
N15kt_detonation[8].action.radius = 200
N15kt_detonation[8].action.repeat_count = 200
N15kt_detonation[9].action.radius = 150
N15kt_detonation[9].action.repeat_count = 300
N15kt_detonation[10].action.radius = 250
N15kt_detonation[10].action.repeat_count = 100

local N100kt_detonation = table.deepcopy(N1kt_detonation)
N100kt_detonation[1].effect_id = "Atomic Weapon hit 100kt"
N100kt_detonation[4].radius = 500
N100kt_detonation[5].radius = 100
N100kt_detonation[6].action.radius = 200
N100kt_detonation[7].action.radius = 100
N100kt_detonation[7].action.repeat_count = 100
N100kt_detonation[8].action.radius = 100
N100kt_detonation[8].action.repeat_count = 500
N100kt_detonation[9].action.radius = 150
N100kt_detonation[9].action.repeat_count = 300
N100kt_detonation[10].action.radius = 250
N100kt_detonation[10].action.repeat_count = 100

local N1Mt_detonation = table.deepcopy(N100kt_detonation)
N1Mt_detonation[1].effect_id = "Atomic Weapon hit 1Mt"

local N5Mt_detonation = table.deepcopy(N1Mt_detonation)
N5Mt_detonation[1].effect_id = "Atomic Weapon hit 5Mt"
local N10Mt_detonation = table.deepcopy(N1Mt_detonation)
N10Mt_detonation[1].effect_id = "Atomic Weapon hit 10Mt"
local N50Mt_detonation = table.deepcopy(N1Mt_detonation)
N50Mt_detonation[1].effect_id = "Atomic Weapon hit 50Mt"
local N100Mt_detonation = table.deepcopy(N1Mt_detonation)
N100Mt_detonation[1].effect_id = "Atomic Weapon hit 100Mt"

local N1Gt_detonation = table.deepcopy(N1Mt_detonation)
N1Gt_detonation[1].effect_id = "Atomic Weapon hit 1Gt"

add_mushroom_cloud_effect(N8t_detonation, "small-")
add_mushroom_cloud_effect(N20t_detonation, "small-")
add_mushroom_cloud_effect(N500t_detonation, "")
add_mushroom_cloud_effect(N15kt_detonation, "huge-")
add_mushroom_cloud_effect(N100kt_detonation, "really-huge-")
add_mushroom_cloud_effect(N1Mt_detonation, "really-huge-")

return {
  N0_1t_detonation = N0_1t_detonation,
  N0_5t_detonation = N0_5t_detonation,
  N2t_detonation = N2t_detonation,
  N4t_detonation = N4t_detonation,
  N8t_detonation = N8t_detonation,
  N20t_detonation = N20t_detonation,
  N500t_detonation = N500t_detonation,
  N1kt_detonation = N1kt_detonation,
  N15kt_detonation = N15kt_detonation,
  N100kt_detonation = N100kt_detonation,
  N1Mt_detonation = N1Mt_detonation,
  N5Mt_detonation = N5Mt_detonation,
  N10Mt_detonation = N10Mt_detonation,
  N50Mt_detonation = N50Mt_detonation,
  N100Mt_detonation = N100Mt_detonation,
  N1Gt_detonation = N1Gt_detonation
}

