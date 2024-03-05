local buildingmulti = angelsmods.marathon.buildingmulti
local buildingtime = angelsmods.marathon.buildingtime
---------------------------------------------------------------------------------
data:extend({

    {
		type = "item",
		name = "alloy-mixer-4",
		icons = 
    {
      {icon = "__reskins-angels__/graphics/icons/smelting/induction-furnace/induction-furnace-icon-base.png",
      icon_size = 64, icon_mipmaps = 4,},
      {icon = "__reskins-angels__/graphics/icons/smelting/induction-furnace/induction-furnace-icon-mask.png",
      icon_size = 64, icon_mipmaps = 4, tint = util.color("ccae29"),},
      {icon = "__reskins-angels__/graphics/icons/smelting/induction-furnace/induction-furnace-icon-highlights.png",
      icon_size = 64, icon_mipmaps = 4, blend_mode = "additive",},
      {icon = "__angelsextended-remelting-fixed__/graphics/icons/num_4.png",
			tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5}, scale = 0.32, shift = {-12, -12},}
    },
    icon_size = 64, icon_mipmaps = 4,
		subgroup = "aragas-molten-alloy-mixer",
    order = "d[alloy-mixer-4]", 
    place_result = "alloy-mixer-4",
		stack_size = 10,
	},
---------------------------------------------------------------------------------
{
  type = "recipe",
  name = "alloy-mixer-4",
  normal =
  {
    energy_required = 5,
    enabled = false,
    ingredients =
    {
      {type = "item", name = "alloy-mixer-3", amount = 1},
      {type = "item", name = "titanium-plate", amount = 20},
      {type = "item", name = "processing-unit", amount = 5},
      {type = "item", name = "reinforced-concrete-brick", amount = 25},
      {type = "item", name = "titanium-gear-wheel", amount = 9},
      {type = "item", name = "titanium-pipe", amount = 12},
    },
    result="alloy-mixer-4",
  },
  expensive =
  {
    energy_required = 5 * buildingtime,
    enabled = false,
    ingredients =
    {
      {type = "item", name = "alloy-mixer-3", amount = 1},
      {type = "item", name = "titanium-plate", amount = 100},
      {type = "item", name = "processing-unit", amount = 25},
      {type = "item", name = "reinforced-concrete-brick", amount = 125},
      {type = "item", name = "titanium-gear-wheel", amount = 45},
      {type = "item", name = "titanium-pipe", amount = 60},
    },
    result="alloy-mixer-4",
  },
},
---------------------------------------------------------------------------------
{
    type = "assembling-machine",
    name = "alloy-mixer-4",
		icons = 
    {
      {icon = "__reskins-angels__/graphics/icons/smelting/induction-furnace/induction-furnace-icon-base.png",
      icon_size = 64, icon_mipmaps = 4,},
      {icon = "__reskins-angels__/graphics/icons/smelting/induction-furnace/induction-furnace-icon-mask.png",
      icon_size = 64, icon_mipmaps = 4, tint = util.color("ccae29"),},
      {icon = "__reskins-angels__/graphics/icons/smelting/induction-furnace/induction-furnace-icon-highlights.png",
      icon_size = 64, icon_mipmaps = 4, blend_mode = "additive",},
      {icon = "__angelsextended-remelting-fixed__/graphics/icons/num_4.png",
			tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5}, scale = 0.32, shift = {-12, -12},}
    },
    icon_size = 64, icon_mipmaps = 4,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "alloy-mixer-4"},
    fast_replaceable_group = "alloy-mixer",
    max_health = 300,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    drawing_box = {{-2.5, -3.0}, {2.5, 2.5}},
    module_specification =
    {
        module_slots = 2
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    crafting_categories = {"molten-alloy-mixing"},
    crafting_speed = 3,
    energy_source =
    {
        type = "electric",
        usage_priority = "secondary-input",
        emissions = 0.03 / 3.5
    },
    energy_usage = "250kW",
    ingredient_count = 8,
    animation = {
        layers = {
          {
            filename = "__angelssmelting__/graphics/entity/induction-furnace/induction-furnace-base.png",
            priority = "high",
            width = 170,
            height = 192,
            line_length = 6,
            frame_count = 36,
            animation_speed = 0.5,
            shift = util.by_pixel(0.5, -5.5),
            hr_version = {
              priority = "high",
              width = 336,
              height = 381,
              frame_count = 36,
              stripes = {
                {
                  filename = "__angelssmelting__/graphics/entity/induction-furnace/hr-induction-furnace-base_01.png",
                  width_in_frames = 6,
                  height_in_frames = 3,
                },
                {
                  filename = "__angelssmelting__/graphics/entity/induction-furnace/hr-induction-furnace-base_02.png",
                  width_in_frames = 6,
                  height_in_frames = 3,
                },
              },
              animation_speed = 0.5,
              shift = util.by_pixel(0, -5),
              scale = 0.5
            }
          },

-- Mask
{
  filename = "__reskins-angels__/graphics/entity/smelting/induction-furnace/induction-furnace-mask.png",
  priority = "extra-high",
  width = 170,
  height = 192,
  line_length = 6,
  frame_count = 36,
  animation_speed = 0.5,
  tint = util.color("ccae29"),
  shift = util.by_pixel(0.5, -5.5),
  hr_version = {
      priority = "extra-high",
      width = 336,
      height = 381,
      frame_count = 36,
      stripes = {
          {
              filename = "__reskins-angels__/graphics/entity/smelting/induction-furnace/hr-induction-furnace-mask_01.png",
              width_in_frames = 6,
              height_in_frames = 3,
          },
          {
              filename = "__reskins-angels__/graphics/entity/smelting/induction-furnace/hr-induction-furnace-mask_02.png",
              width_in_frames = 6,
              height_in_frames = 3,
          },
      },
      animation_speed = 0.5,
      tint = util.color("ccae29"),
      shift = util.by_pixel(0, -5),
      scale = 0.5,
  }
},
-- Highlights
{
  filename = "__reskins-angels__/graphics/entity/smelting/induction-furnace/induction-furnace-highlights.png",
  priority = "extra-high",
  width = 170,
  height = 192,
  line_length = 6,
  frame_count = 36,
  animation_speed = 0.5,
  blend_mode = "additive",
  shift = util.by_pixel(0.5, -5.5),
  hr_version = {
      priority = "extra-high",
      width = 336,
      height = 381,
      frame_count = 36,
      stripes = {
          {
              filename = "__reskins-angels__/graphics/entity/smelting/induction-furnace/hr-induction-furnace-highlights_01.png",
              width_in_frames = 6,
              height_in_frames = 3,
          },
          {
              filename = "__reskins-angels__/graphics/entity/smelting/induction-furnace/hr-induction-furnace-highlights_02.png",
              width_in_frames = 6,
              height_in_frames = 3,
          },
      },
      animation_speed = 0.5,
      blend_mode = "additive",
      shift = util.by_pixel(0, -5),
      scale = 0.5,
  }
},


          {
            filename = "__angelssmelting__/graphics/entity/induction-furnace/induction-furnace-shadow.png",
            priority = "high",
            width = 216,
            height = 170,
            line_length = 6,
            frame_count = 36,
            animation_speed = 0.5,
            draw_as_shadow = true,
            shift = util.by_pixel(24, 9),
            hr_version = {
              priority = "high",
              width = 429,
              height = 336,
              frame_count = 36,
              stripes = {
                {
                  filename = "__angelssmelting__/graphics/entity/induction-furnace/hr-induction-furnace-shadow_01.png",
                  width_in_frames = 3,
                  height_in_frames = 6,
                },
                {
                  filename = "__angelssmelting__/graphics/entity/induction-furnace/hr-induction-furnace-shadow_02.png",
                  width_in_frames = 3,
                  height_in_frames = 6,
                },
              },
              animation_speed = 0.5,
              draw_as_shadow = true,
              shift = util.by_pixel(23, 8.5),
              scale = 0.5
            }
          }
        }
      },
      working_visualisations = {
        {
          apply_recipe_tint = "primary",
          always_draw = true,
          animation = {
            filename = "__angelssmelting__/graphics/entity/induction-furnace/induction-furnace-working-recipe-tint-mask.png",
            priority = "high",
            width = 170,
            height = 192,
            line_length = 6,
            frame_count = 36,
            animation_speed = 0.5,
            shift = util.by_pixel(0.5, -5.5),
            hr_version = {
              priority = "high",
              width = 336,
              height = 381,
              frame_count = 36,
              stripes = {
                {
                  filename = "__angelssmelting__/graphics/entity/induction-furnace/hr-induction-furnace-working-recipe-tint-mask_01.png",
                  width_in_frames = 6,
                  height_in_frames = 3,
                },
                {
                  filename = "__angelssmelting__/graphics/entity/induction-furnace/hr-induction-furnace-working-recipe-tint-mask_02.png",
                  width_in_frames = 6,
                  height_in_frames = 3,
                },
              },
              animation_speed = 0.5,
              shift = util.by_pixel(0, -5),
              scale = 0.5
            }
          }
        },
        {
          always_draw = true,
          north_animation = {
            filename = "__angelssmelting__/graphics/entity/induction-furnace/vertical-pipe-shadow-patch.png",
            priority = "high",
            width = 64,
            height = 64,
            repeat_count = 36,
            draw_as_shadow = true,
            shift = {2, -2},
            hr_version = {
              filename = "__angelssmelting__/graphics/entity/induction-furnace/hr-vertical-pipe-shadow-patch.png",
              priority = "high",
              width = 128,
              height = 128,
              repeat_count = 36,
              draw_as_shadow = true,
              shift = {2, -2},
              scale = 0.5
            }
          }
        },
        {
          always_draw = true,
          animation = {
            filename = "__angelssmelting__/graphics/entity/induction-furnace/induction-furnace-working-lights.png",
            priority = "high",
            width = 170,
            height = 192,
            line_length = 6,
            frame_count = 36,
            animation_speed = 0.5,
            shift = util.by_pixel(0.5, -5.5),
            draw_as_light = true,
            hr_version = {
              priority = "high",
              width = 336,
              height = 381,
              frame_count = 36,
              stripes = {
                {
                  filename = "__angelssmelting__/graphics/entity/induction-furnace/hr-induction-furnace-working-lights_01.png",
                  width_in_frames = 6,
                  height_in_frames = 3,
                },
                {
                  filename = "__angelssmelting__/graphics/entity/induction-furnace/hr-induction-furnace-working-lights_02.png",
                  width_in_frames = 6,
                  height_in_frames = 3,
                },
              },
              animation_speed = 0.5,
              shift = util.by_pixel(0, -5),
              draw_as_light = true,
              scale = 0.5
            }
          }
        }
      },
  vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
  working_sound =
  {
    sound = {filename = "__angelssmelting__/sound/induction-furnace.ogg", volume = 0.45},
    idle_sound = {filename = "__base__/sound/idle1.ogg", volume = 0.6},
    audible_distance_modifier = 0.5,
    apparent_volume = 2.5
  },
    fluid_boxes =
    {
        {
            production_type = "input",
            pipe_covers = pipecoverspictures(),
            base_area = 10,
            base_level = -1,
            pipe_connections = {{ type="input", position = {2, 3} }}
        },
        {
            production_type = "input",
            pipe_covers = pipecoverspictures(),
            base_area = 10,
            base_level = -1,
            pipe_connections = {{ type="input", position = {0, 3} }}
        },
        {
            production_type = "input",
            pipe_covers = pipecoverspictures(),
            base_area = 10,
            base_level = -1,
            pipe_connections = {{ type="input", position = {-2, 3} }}
        },
        {
            production_type = "output",
            pipe_covers = pipecoverspictures(),
            base_level = 1,
            pipe_connections = {{ position = {0, -3} }}
        },
    },
},
})