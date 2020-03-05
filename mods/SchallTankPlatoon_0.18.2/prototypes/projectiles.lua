local collision_box_none = {{0, 0}, {0, 0}}
local collision_box_ori = {{-0.3, -1.1}, {0.3, 1.1}}

local cannon_ap_collision_box = collision_box_ori

local cannon_he_collision_box
-- if not settings.startup["tankplatoon-tank-cannon-collision"].value then
--   cannon_he_collision_box = collision_box_none
-- else
  cannon_he_collision_box = collision_box_ori
-- end

local autocannon_he_collision_box
-- if not settings.startup["tankplatoon-tank-autocannon-collision"].value then
--   autocannon_he_collision_box = collision_box_none
-- else
  autocannon_he_collision_box = collision_box_ori
-- end

local cannon_force_condition = settings.startup["tankplatoon-tank-cannon-force-condition"].value
local autocannon_force_condition = settings.startup["tankplatoon-tank-autocannon-force-condition"].value


data.raw["projectile"]["cannon-projectile"].collision_box = cannon_ap_collision_box
data.raw["projectile"]["uranium-cannon-projectile"].collision_box = cannon_ap_collision_box
data.raw["projectile"]["explosive-cannon-projectile"].collision_box = cannon_he_collision_box
data.raw["projectile"]["explosive-uranium-cannon-projectile"].collision_box = cannon_he_collision_box

data.raw["projectile"]["cannon-projectile"].force_condition = cannon_force_condition
data.raw["projectile"]["uranium-cannon-projectile"].force_condition = cannon_force_condition
data.raw["projectile"]["explosive-cannon-projectile"].force_condition = cannon_force_condition
data.raw["projectile"]["explosive-uranium-cannon-projectile"].force_condition = cannon_force_condition



data:extend
{
  -- Autocannon
  {
    type = "projectile",
    name = "explosive-autocannon-projectile",
    flags = {"not-on-map"},
    collision_box = autocannon_he_collision_box,
    force_condition = autocannon_force_condition,
    acceleration = 0,
    piercing_damage = 10, --100,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "damage",
            damage = {amount = 18, type = "physical"}
            -- damage = {amount = 180, type = "physical"}
          },
          {
            type = "create-entity",
            entity_name = "autocannon-explosion" --"small-explosion" --"explosion"
          }
        }
      }
    },
    final_action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "create-entity",
            entity_name = "explosion" --"big-explosion"
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
                    damage = {amount = 30, type = "explosion"}
                    -- damage = {amount = 300, type = "explosion"}
                  },
                  {
                    type = "create-entity",
                    entity_name = "autocannon-explosion" --"small-explosion" --"explosion"
                  }
                }
              }
            }
          }
        }
      }
    },
    animation =
    {
      filename = "__base__/graphics/entity/bullet/bullet.png",
      frame_count = 1,
      width = 3,
      height = 50,
      priority = "high"
    }
  },
  {
    type = "projectile",
    name = "explosive-uranium-autocannon-projectile",
    flags = {"not-on-map"},
    collision_box = autocannon_he_collision_box,
    force_condition = autocannon_force_condition,
    acceleration = 0,
    piercing_damage = 15, --150,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "damage",
            damage = {amount = 35 , type = "physical"}
            -- damage = {amount = 350 , type = "physical"}
          },
          {
            type = "create-entity",
            entity_name = "uranium-autocannon-explosion" --"uranium-cannon-explosion"
          }
        }
      }
    },
    final_action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "create-entity",
            entity_name = "uranium-autocannon-shell-explosion" --"uranium-cannon-shell-explosion"
          },
          {
            type = "nested-result",
            action =
            {
              type = "area",
              radius = 4.25,
              action_delivery =
              {
                type = "instant",
                target_effects =
                {
                  {
                    type = "damage",
                    damage = {amount = 31.5, type = "explosion"}
                    -- damage = {amount = 315, type = "explosion"}
                  },
                  {
                    type = "create-entity",
                    entity_name = "uranium-autocannon-explosion" --"uranium-cannon-explosion"
                  }
                }
              }
            }
          },
          {
            type = "create-entity",
            entity_name = "small-scorchmark",
            check_buildability = true
          }
        }
      }
    },
    animation =
    {
      filename = "__base__/graphics/entity/bullet/bullet.png",
      frame_count = 1,
      width = 3,
      height = 50,
      priority = "high"
    }
  },
  -- Rocket
  {
    type = "projectile",
    name = "Schall-explosive-rocket-pack",
    flags = {"not-on-map"},
    acceleration = 0.005,
    action =
    {
      {
        type = "cluster",
        cluster_count = 7,
        distance = 8,
        distance_deviation = 3,
        action_delivery =
        {
          type = "projectile",
          projectile = "explosive-rocket",
          direction_deviation = 0.6,
          starting_speed = 0.25,
          starting_speed_deviation = 0.3
        }
      }
    },
    light = {intensity = 0.5, size = 4},
    animation =
    {
      filename = "__base__/graphics/entity/rocket/rocket.png",
      frame_count = 8,
      line_length = 8,
      width = 9,
      height = 35,
      shift = {0, 0},
      priority = "high"
    },
    shadow =
    {
      filename = "__base__/graphics/entity/rocket/rocket-shadow.png",
      frame_count = 1,
      width = 7,
      height = 24,
      priority = "high",
      shift = {0, 0}
    },
    smoke =
    {
      {
        name = "smoke-fast",
        deviation = {0.15, 0.15},
        frequency = 1,
        position = {0, -1},
        slow_down_factor = 1,
        starting_frame = 3,
        starting_frame_deviation = 5,
        starting_frame_speed = 0,
        starting_frame_speed_deviation = 5
      }
    }
  },
  -- High Caliber Cannon
  {
    type = "projectile",
    name = "cannon-H1-projectile",
    flags = {"not-on-map"},
    collision_box = cannon_ap_collision_box, --{{-0.3, -1.1}, {0.3, 1.1}},
    force_condition = cannon_force_condition,
    acceleration = 0,
    direction_only = true,
    piercing_damage = 400,--300,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "damage",
            -- damage = {amount = 200 , type = "physical"}
            damage = {amount = 350 , type = "physical"}
          },
          {
            type = "damage",
            -- damage = {amount = 100 , type = "explosion"}
            damage = {amount = 160 , type = "explosion"}
          },
          {
            type = "create-entity",
            entity_name = "explosion"
          }
        }
      }
    },
    final_action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "create-entity",
            entity_name = "small-scorchmark",
            check_buildability = true
          }
        }
      }
    },
    animation =
    {
      filename = "__base__/graphics/entity/bullet/bullet.png",
      frame_count = 1,
      width = 3,
      height = 50,
      priority = "high"
    }
  },
  {
    type = "projectile",
    name = "cannon-H2-projectile",
    flags = {"not-on-map"},
    collision_box = cannon_ap_collision_box, --{{-0.3, -1.1}, {0.3, 1.1}},
    force_condition = cannon_force_condition,
    acceleration = 0,
    direction_only = true,
    piercing_damage = 500,--300,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "damage",
            -- damage = {amount = 200 , type = "physical"}
            damage = {amount = 500 , type = "physical"}
          },
          {
            type = "damage",
            -- damage = {amount = 100 , type = "explosion"}
            damage = {amount = 360 , type = "explosion"}
          },
          {
            type = "create-entity",
            entity_name = "explosion"
          }
        }
      }
    },
    final_action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "create-entity",
            entity_name = "small-scorchmark",
            check_buildability = true
          }
        }
      }
    },
    animation =
    {
      filename = "__base__/graphics/entity/bullet/bullet.png",
      frame_count = 1,
      width = 3,
      height = 50,
      priority = "high"
    }
  },
  {
    type = "projectile",
    name = "explosive-cannon-H1-projectile",
    flags = {"not-on-map"},
    collision_box = cannon_he_collision_box, --{{-0.3, -1.1}, {0.3, 1.1}},
    force_condition = cannon_force_condition,
    acceleration = 0,
    piercing_damage = 133,--100,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "damage",
            -- damage = {amount = 180, type = "physical"}
            damage = {amount = 315, type = "physical"}
          },
          {
            type = "create-entity",
            entity_name = "explosion"
          }
        }
      }
    },
    final_action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "create-entity",
            entity_name = "big-explosion"
          },
          {
            type = "nested-result",
            action =
            {
              type = "area",
              radius = 4.45,--4,
              action_delivery =
              {
                type = "instant",
                target_effects =
                {
                  {
                    type = "damage",
                    -- damage = {amount = 300, type = "explosion"}
                    damage = {amount = 380, type = "explosion"}
                  },
                  {
                    type = "create-entity",
                    entity_name = "explosion"
                  }
                }
              }
            }
          }
        }
      }
    },
    animation =
    {
      filename = "__base__/graphics/entity/bullet/bullet.png",
      frame_count = 1,
      width = 3,
      height = 50,
      priority = "high"
    }
  },
  {
    type = "projectile",
    name = "explosive-cannon-H2-projectile",
    flags = {"not-on-map"},
    collision_box = cannon_he_collision_box, --{{-0.3, -1.1}, {0.3, 1.1}},
    force_condition = cannon_force_condition,
    acceleration = 0,
    piercing_damage = 166,--100,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "damage",
            -- damage = {amount = 180, type = "physical"}
            damage = {amount = 450, type = "physical"}
          },
          {
            type = "create-entity",
            entity_name = "explosion"
          }
        }
      }
    },
    final_action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "create-entity",
            entity_name = "big-explosion"
          },
          {
            type = "nested-result",
            action =
            {
              type = "area",
              radius = 6,--4,
              action_delivery =
              {
                type = "instant",
                target_effects =
                {
                  {
                    type = "damage",
                    -- damage = {amount = 300, type = "explosion"}
                    damage = {amount = 570, type = "explosion"}
                  },
                  {
                    type = "create-entity",
                    entity_name = "explosion"
                  }
                }
              }
            }
          }
        }
      }
    },
    animation =
    {
      filename = "__base__/graphics/entity/bullet/bullet.png",
      frame_count = 1,
      width = 3,
      height = 50,
      priority = "high"
    }
  },
  {
    type = "projectile",
    name = "uranium-cannon-H1-projectile",
    flags = {"not-on-map"},
    collision_box = cannon_ap_collision_box, --{{-0.3, -1.1}, {0.3, 1.1}},
    force_condition = cannon_force_condition,
    acceleration = 0,
    direction_only = true,
    piercing_damage = 800,--600,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "damage",
            -- damage = {amount = 400 , type = "physical"}
            damage = {amount = 700 , type = "physical"}
          },
          {
            type = "damage",
            -- damage = {amount = 200 , type = "explosion"}
            damage = {amount = 320 , type = "explosion"}
          },
          {
            type = "create-entity",
            entity_name = "uranium-cannon-explosion"
          }
        }
      }
    },
    final_action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "create-entity",
            entity_name = "small-scorchmark",
            check_buildability = true
          }
        }
      }
    },
    animation =
    {
      filename = "__base__/graphics/entity/bullet/bullet.png",
      frame_count = 1,
      width = 3,
      height = 50,
      priority = "high"
    }
  },
  {
    type = "projectile",
    name = "uranium-cannon-H2-projectile",
    flags = {"not-on-map"},
    collision_box = cannon_ap_collision_box, --{{-0.3, -1.1}, {0.3, 1.1}},
    force_condition = cannon_force_condition,
    acceleration = 0,
    direction_only = true,
    piercing_damage = 1000,--600,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "damage",
            -- damage = {amount = 400 , type = "physical"}
            damage = {amount = 1000 , type = "physical"}
          },
          {
            type = "damage",
            -- damage = {amount = 200 , type = "explosion"}
            damage = {amount = 720 , type = "explosion"}
          },
          {
            type = "create-entity",
            entity_name = "uranium-cannon-explosion"
          }
        }
      }
    },
    final_action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "create-entity",
            entity_name = "small-scorchmark",
            check_buildability = true
          }
        }
      }
    },
    animation =
    {
      filename = "__base__/graphics/entity/bullet/bullet.png",
      frame_count = 1,
      width = 3,
      height = 50,
      priority = "high"
    }
  },
  {
    type = "projectile",
    name = "explosive-uranium-cannon-H1-projectile",
    flags = {"not-on-map"},
    collision_box = cannon_he_collision_box, --{{-0.3, -1.1}, {0.3, 1.1}},
    force_condition = cannon_force_condition,
    acceleration = 0,
    piercing_damage = 200,--150,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "damage",
            -- damage = {amount = 350 , type = "physical"}
            damage = {amount = 612 , type = "physical"}
          },
          {
            type = "create-entity",
            entity_name = "uranium-cannon-explosion"
          }
        }
      }
    },
    final_action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "create-entity",
            entity_name = "uranium-cannon-shell-explosion"
          },
          {
            type = "nested-result",
            action =
            {
              type = "area",
              radius = 4.75, --4.25,
              action_delivery =
              {
                type = "instant",
                target_effects =
                {
                  {
                    type = "damage",
                    -- damage = {amount = 315, type = "explosion"}
                    damage = {amount = 400, type = "explosion"}
                  },
                  {
                    type = "create-entity",
                    entity_name = "uranium-cannon-explosion"
                  }
                }
              }
            }
          },
          {
            type = "create-entity",
            entity_name = "small-scorchmark",
            check_buildability = true
          }
        }
      }
    },
    animation =
    {
      filename = "__base__/graphics/entity/bullet/bullet.png",
      frame_count = 1,
      width = 3,
      height = 50,
      priority = "high"
    }
  },
  {
    type = "projectile",
    name = "explosive-uranium-cannon-H2-projectile",
    flags = {"not-on-map"},
    collision_box = cannon_he_collision_box, --{{-0.3, -1.1}, {0.3, 1.1}},
    force_condition = cannon_force_condition,
    acceleration = 0,
    piercing_damage = 250,--150,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "damage",
            -- damage = {amount = 350 , type = "physical"}
            damage = {amount = 875 , type = "physical"}
          },
          {
            type = "create-entity",
            entity_name = "uranium-cannon-explosion"
          }
        }
      }
    },
    final_action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "create-entity",
            entity_name = "uranium-cannon-shell-explosion"
          },
          {
            type = "nested-result",
            action =
            {
              type = "area",
              radius = 6.375, --4.25,
              action_delivery =
              {
                type = "instant",
                target_effects =
                {
                  {
                    type = "damage",
                    -- damage = {amount = 315, type = "explosion"}
                    damage = {amount = 600, type = "explosion"}
                  },
                  {
                    type = "create-entity",
                    entity_name = "uranium-cannon-explosion"
                  }
                }
              }
            }
          },
          {
            type = "create-entity",
            entity_name = "small-scorchmark",
            check_buildability = true
          }
        }
      }
    },
    animation =
    {
      filename = "__base__/graphics/entity/bullet/bullet.png",
      frame_count = 1,
      width = 3,
      height = 50,
      priority = "high"
    }
  },

  -- Incendiary Autocannon
  {
    type = "projectile",
    name = "incendiary-autocannon-projectile",
    flags = {"not-on-map"},
    collision_box = collision_box_none,
    force_condition = autocannon_force_condition,
    acceleration = 0,
    action =
    {
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
            {
              type = "create-fire",
              entity_name = "fire-flame",
              initial_ground_flame_count = 50,--30,
            },
          }
        }
      },
      {
        type = "area",
        radius = 2,--10,
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
            {
              type = "create-sticker",
              sticker = "fire-sticker",
            },
            {
              type = "damage",
              damage = {amount = 3, type = "fire"},
              apply_damage_to_trees = false
            }
          }
        }
      },
    },
    light = {intensity = 0.8, size = 5},
    animation =
    {
      filename = "__base__/graphics/entity/bullet/bullet.png",
      frame_count = 1,
      width = 3,
      height = 50,
      priority = "high"
    }
  },
  -- Incendiary Rocket
  {
    type = "projectile",
    name = "Schall-incendiary-rocket",
    flags = {"not-on-map"},
    acceleration = 0.005,
    action =
    {
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
            {
                repeat_count = 10,
                type = "create-trivial-smoke",
                smoke_name = "nuclear-smoke",
                offset_deviation = {{-1, -1}, {1, 1}},
                slow_down_factor = 1,
                starting_frame = 3,
                starting_frame_deviation = 5,
                starting_frame_speed = 0,
                starting_frame_speed_deviation = 5,
                speed_from_center = 0.5,
                speed_deviation = 0.2
            },
            {
              type = "create-entity",
              -- entity_name = "napalm-big-explosion"
              entity_name = "big-explosion"
              -- entity_name = "explosion"
            },
            -- {
            --   type = "damage",
            --   damage = {amount = 20, type = "fire"}
            -- },
            {
              type = "create-entity",
              entity_name = "small-scorchmark",
              check_buildability = true
            },
            {
              type = "nested-result",
              action =
              {
                type = "cluster",
                cluster_count = 4,
                distance = 2,
                distance_deviation = 6,
                action_delivery =
                {
                  type = "projectile",
                  projectile = "napalm-fire",
                  direction_deviation = 0.6,
                  starting_speed = 0.3,
                  starting_speed_deviation = 0.1
                }
              }
            }
          }
        }
      },
    },
    light = {intensity = 0.8, size = 15},
    animation =
    {
      filename = "__base__/graphics/entity/rocket/rocket.png",
      frame_count = 8,
      line_length = 8,
      width = 9,
      height = 35,
      shift = {0, 0},
      priority = "high"
    },
    shadow =
    {
      filename = "__base__/graphics/entity/rocket/rocket-shadow.png",
      frame_count = 1,
      width = 7,
      height = 24,
      priority = "high",
      shift = {0, 0}
    },
    smoke =
    {
      {
        name = "smoke-fast",
        deviation = {0.15, 0.15},
        frequency = 1,
        position = {0, -1},
        slow_down_factor = 1,
        starting_frame = 3,
        starting_frame_deviation = 5,
        starting_frame_speed = 0,
        starting_frame_speed_deviation = 5
      }
    }
  },
  -- Napalm Rocket
  {
    type = "projectile",
    name = "Schall-napalm-rocket",
    flags = {"not-on-map"},
    acceleration = 0.005,
    action =
    {
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
            {
              repeat_count = 100,
              type = "create-trivial-smoke",
              smoke_name = "nuclear-smoke",
              offset_deviation = {{-1, -1}, {1, 1}},
              slow_down_factor = 1,
              starting_frame = 3,
              starting_frame_deviation = 5,
              starting_frame_speed = 0,
              starting_frame_speed_deviation = 5,
              speed_from_center = 0.5,
              speed_deviation = 0.2
            },
            {
              type = "create-entity",
              entity_name = "napalm-big-explosion"
              -- entity_name = "big-explosion"
              -- entity_name = "explosion"
            },
            -- {
            --   type = "damage",
            --   damage = {amount = 20, type = "fire"}
            -- },
            {
              type = "create-entity",
              entity_name = "small-scorchmark",
              check_buildability = true
            },
            {
              type = "nested-result",
              action =
              {
                type = "cluster",
                cluster_count = 100,--30,--10,
                distance = 2,
                distance_deviation = 50,--35,
                action_delivery =
                {
                  type = "projectile",
                  projectile = "napalm-fire",
                  direction_deviation = 0.6,
                  starting_speed = 0.3,
                  starting_speed_deviation = 0.1
                }
              }
            }
          }
        }
      },
    },
    light = {intensity = 0.8, size = 15},
    animation =
    {
      filename = "__base__/graphics/entity/rocket/rocket.png",
      frame_count = 8,
      line_length = 8,
      width = 9,
      height = 35,
      shift = {0, 0},
      priority = "high"
    },
    shadow =
    {
      filename = "__base__/graphics/entity/rocket/rocket-shadow.png",
      frame_count = 1,
      width = 7,
      height = 24,
      priority = "high",
      shift = {0, 0}
    },
    smoke =
    {
      {
        name = "smoke-fast",
        deviation = {0.15, 0.15},
        frequency = 1,
        position = {0, -1},
        slow_down_factor = 1,
        starting_frame = 3,
        starting_frame_deviation = 5,
        starting_frame_speed = 0,
        starting_frame_speed_deviation = 5
      }
    }
  },
  {
    type = "projectile",
    name = "napalm-fire",
    flags = {"not-on-map"},
    acceleration = 0.005,
    action =
    {
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
            {
              type = "create-fire",
              entity_name = "fire-flame",
              initial_ground_flame_count = 200,--30,
            },
          }
        }
      },
      {
        type = "area",
        radius = 2,--10,
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
            {
              type = "create-sticker",
              sticker = "fire-sticker",
            },
            {
              type = "damage",
              damage = {amount = 3, type = "fire"},
              apply_damage_to_trees = false
            }
          }
        }
      },
    },
    light = {intensity = 0.5, size = 10},
    animation =
    {
      filename = "__base__/graphics/entity/grenade/grenade-shadow.png",
      frame_count = 1,
      width = 24,
      height = 24,
      priority = "high"
    },
    shadow =
    {
      filename = "__base__/graphics/entity/grenade/grenade-shadow.png",
      frame_count = 1,
      width = 24,
      height = 24,
      priority = "high"
    }
  },  
  -- Poison Rocket
  {
    type = "projectile",
    name = "Schall-poison-rocket",
    flags = {"not-on-map"},
    acceleration = 0.005,
    action =
    {
      {
        type = "cluster",
        cluster_count = 6,
        distance = 8,
        distance_deviation = 3,
        action_delivery =
        {
          type = "projectile",
          projectile = "Schall-poison-capsule",  --"poison-capsule",
          starting_speed = 0.3
        }
      },
    },
    light = {intensity = 0.8, size = 15},
    animation =
    {
      filename = "__base__/graphics/entity/rocket/rocket.png",
      frame_count = 8,
      line_length = 8,
      width = 9,
      height = 35,
      shift = {0, 0},
      priority = "high"
    },
    shadow =
    {
      filename = "__base__/graphics/entity/rocket/rocket-shadow.png",
      frame_count = 1,
      width = 7,
      height = 24,
      priority = "high",
      shift = {0, 0}
    },
    smoke =
    {
      {
        name = "smoke-fast",
        deviation = {0.15, 0.15},
        frequency = 1,
        position = {0, -1},
        slow_down_factor = 1,
        starting_frame = 3,
        starting_frame_deviation = 5,
        starting_frame_speed = 0,
        starting_frame_speed_deviation = 5
      }
    }
  },
  -- Poison Capsule up to 0.18.6
  {
    type = "projectile",
    name = "Schall-poison-capsule",  --"poison-capsule",
    flags = {"not-on-map"},
    acceleration = 0.005,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          type = "create-entity",
          show_in_tooltip = true,
          entity_name = "Schall-poison-cloud" --"poison-cloud"
        }
      }
    },
    light = {intensity = 0.5, size = 4},
    animation =
    {
      filename = "__SchallTankPlatoon__/graphics/entity/projectiles/poison-capsule.png",  --"__base__/graphics/entity/poison-capsule/poison-capsule.png",
      frame_count = 1,
      width = 32,
      height = 32,
      priority = "high"
    },
    shadow =
    {
      filename = "__SchallTankPlatoon__/graphics/entity/projectiles/poison-capsule-shadow.png", --"__base__/graphics/entity/poison-capsule/poison-capsule-shadow.png",
      frame_count = 1,
      width = 32,
      height = 32,
      priority = "high"
    },
    smoke = capsule_smoke
  },
}
