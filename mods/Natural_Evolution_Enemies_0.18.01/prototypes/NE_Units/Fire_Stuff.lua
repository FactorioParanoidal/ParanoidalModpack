require "util"
if not NE_Enemies then NE_Enemies = {} end
if not NE_Enemies.Settings then NE_Enemies.Settings = {} end

NE_Enemies.Settings.NE_Difficulty = settings.startup["NE_Difficulty"].value


local ne_fireutil = {}

function ne_fireutil.foreach(table_, fun_)
  for k, tab in pairs(table_) do fun_(tab) end
  return table_
end


function ne_fireutil.create_fire_pictures(opts)
  local fire_blend_mode = opts.blend_mode or "additive"
  local fire_animation_speed = opts.animation_speed or 0.5
  local fire_scale =  opts.scale or 1
  local fire_tint = {r=1,g=1,b=1,a=1}
  local fire_flags = { "compressed" }
  local retval =
  {
    {
      filename = "__base__/graphics/entity/fire-flame/fire-flame-13.png",
      line_length = 8,
      width = 60,
      height = 118,
      frame_count = 25,
      axially_symmetrical = false,
      direction_count = 1,
      blend_mode = fire_blend_mode,
      animation_speed = fire_animation_speed,
      scale = fire_scale,
      tint = fire_tint,
      flags = fire_flags,
      shift = { -0.0390625, -0.90625 }
    },
    {
      filename = "__base__/graphics/entity/fire-flame/fire-flame-12.png",
      line_length = 8,
      width = 63,
      height = 116,
      frame_count = 25,
      axially_symmetrical = false,
      direction_count = 1,
      blend_mode = fire_blend_mode,
      animation_speed = fire_animation_speed,
      scale = fire_scale,
      tint = fire_tint,
      flags = fire_flags,
      shift = { -0.015625, -0.914065 }
    },
    {
      filename = "__base__/graphics/entity/fire-flame/fire-flame-11.png",
      line_length = 8,
      width = 61,
      height = 122,
      frame_count = 25,
      axially_symmetrical = false,
      direction_count = 1,
      blend_mode = fire_blend_mode,
      animation_speed = fire_animation_speed,
      scale = fire_scale,
      tint = fire_tint,
      flags = fire_flags,
      shift = { -0.0078125, -0.90625 }
    },
    {
      filename = "__base__/graphics/entity/fire-flame/fire-flame-10.png",
      line_length = 8,
      width = 65,
      height = 108,
      frame_count = 25,
      axially_symmetrical = false,
      direction_count = 1,
      blend_mode = fire_blend_mode,
      animation_speed = fire_animation_speed,
      scale = fire_scale,
      tint = fire_tint,
      flags = fire_flags,
      shift = { -0.0625, -0.64844 }
    },
    {
      filename = "__base__/graphics/entity/fire-flame/fire-flame-09.png",
      line_length = 8,
      width = 64,
      height = 101,
      frame_count = 25,
      axially_symmetrical = false,
      direction_count = 1,
      blend_mode = fire_blend_mode,
      animation_speed = fire_animation_speed,
      scale = fire_scale,
      tint = fire_tint,
      flags = fire_flags,
      shift = { -0.03125, -0.695315 }
    },
    {
      filename = "__base__/graphics/entity/fire-flame/fire-flame-08.png",
      line_length = 8,
      width = 50,
      height = 98,
      frame_count = 32,
      axially_symmetrical = false,
      direction_count = 1,
      blend_mode = fire_blend_mode,
      animation_speed = fire_animation_speed,
      scale = fire_scale,
      tint = fire_tint,
      flags = fire_flags,
      shift = { -0.0546875, -0.77344 }
    },
    {
      filename = "__base__/graphics/entity/fire-flame/fire-flame-07.png",
      line_length = 8,
      width = 54,
      height = 84,
      frame_count = 32,
      axially_symmetrical = false,
      direction_count = 1,
      blend_mode = fire_blend_mode,
      animation_speed = fire_animation_speed,
      scale = fire_scale,
      tint = fire_tint,
      flags = fire_flags,
      shift = { 0.015625, -0.640625 }
    },
    {
      filename = "__base__/graphics/entity/fire-flame/fire-flame-06.png",
      line_length = 8,
      width = 65,
      height = 92,
      frame_count = 32,
      axially_symmetrical = false,
      direction_count = 1,
      blend_mode = fire_blend_mode,
      animation_speed = fire_animation_speed,
      scale = fire_scale,
      tint = fire_tint,
      flags = fire_flags,
      shift = { 0, -0.83594 }
    },
    {
      filename = "__base__/graphics/entity/fire-flame/fire-flame-05.png",
      line_length = 8,
      width = 59,
      height = 103,
      frame_count = 32,
      axially_symmetrical = false,
      direction_count = 1,
      blend_mode = fire_blend_mode,
      animation_speed = fire_animation_speed,
      scale = fire_scale,
      tint = fire_tint,
      flags = fire_flags,
      shift = { 0.03125, -0.882815 }
    },
    {
      filename = "__base__/graphics/entity/fire-flame/fire-flame-04.png",
      line_length = 8,
      width = 67,
      height = 130,
      frame_count = 32,
      axially_symmetrical = false,
      direction_count = 1,
      blend_mode = fire_blend_mode,
      animation_speed = fire_animation_speed,
      scale = fire_scale,
      tint = fire_tint,
      flags = fire_flags,
      shift = { 0.015625, -1.109375 }
    },
    {
      filename = "__base__/graphics/entity/fire-flame/fire-flame-03.png",
      line_length = 8,
      width = 74,
      height = 117,
      frame_count = 32,
      axially_symmetrical = false,
      direction_count = 1,
      blend_mode = fire_blend_mode,
      animation_speed = fire_animation_speed,
      scale = fire_scale,
      tint = fire_tint,
      flags = fire_flags,
      shift = { 0.046875, -0.984375 }
    },
    {
      filename = "__base__/graphics/entity/fire-flame/fire-flame-02.png",
      line_length = 8,
      width = 74,
      height = 114,
      frame_count = 32,
      axially_symmetrical = false,
      direction_count = 1,
      blend_mode = fire_blend_mode,
      animation_speed = fire_animation_speed,
      scale = fire_scale,
      tint = fire_tint,
      flags = fire_flags,
      shift = { 0.0078125, -0.96875 }
    },
    {
      filename = "__base__/graphics/entity/fire-flame/fire-flame-01.png",
      line_length = 8,
      width = 66,
      height = 119,
      frame_count = 32,
      axially_symmetrical = false,
      direction_count = 1,
      blend_mode = fire_blend_mode,
      animation_speed = fire_animation_speed,
      scale = fire_scale,
      tint = fire_tint,
      flags = fire_flags,
      shift = { -0.0703125, -1.039065 }
    }
  }
  return ne_fireutil.foreach(retval, function(tab)
    if tab.shift and tab.scale then tab.shift = { tab.shift[1] * tab.scale, tab.shift[2] * tab.scale } end
  end)
end


data:extend({

	--- Fire Flame 1
	{
	  type = "fire",
	  name = "ne-fire-flame-1",
	  flags = {"placeable-off-grid", "not-on-map"},
	  damage_per_tick = {amount = 3 / 60, type = "ne_fire", force = "enemy"}, -- v 13
	  maximum_damage_multiplier = 3,
	  damage_multiplier_increase_per_added_fuel = 1,
	  damage_multiplier_decrease_per_tick = 0.005,

	  spread_delay = 300,
	  spread_delay_deviation = 180,
	  maximum_spread_count = 25,

	  flame_alpha = 0.35,
	  flame_alpha_deviation = 0.05,

	  add_fuel_cooldown = 10,
	  fade_in_duration = 30,
	  fade_out_duration = 30,

	  initial_lifetime = 60,
	  lifetime_increase_by = 100,
	  lifetime_increase_cooldown = 4,
	  maximum_lifetime = 600,
	  delay_between_initial_flames = 10,
	  burnt_patch_lifetime = 600,

	  on_fuel_added_action = nil,

	  pictures = ne_fireutil.create_fire_pictures({ blend_mode = "normal", animation_speed = 1, scale = 0.5}),

	  smoke_source_pictures =
	  {
		{
		  filename = "__base__/graphics/entity/fire-flame/fire-smoke-source-1.png",
		  line_length = 8,
		  width = 101,
		  height = 138,
		  frame_count = 31,
		  axially_symmetrical = false,
		  direction_count = 1,
		  shift = {-0.109375, -1.1875},
		  animation_speed = 0.5
		},
		{
		  filename = "__base__/graphics/entity/fire-flame/fire-smoke-source-2.png",
		  line_length = 8,
		  width = 99,
		  height = 138,
		  frame_count = 31,
		  axially_symmetrical = false,
		  direction_count = 1,
		  shift = {-0.203125, -1.21875},
		  animation_speed = 0.5
		}
	  },

	  burnt_patch_pictures = nil,
	  burnt_patch_alpha_default = 0.4,
	  burnt_patch_alpha_variations = nil,

	  smoke = nil,

	  light = {intensity = 0.8, size = 10},

	  working_sound = nil
	  --[[
	  {
		sound = { filename = "__base__/sound/furnace.ogg" },
		max_sounds_per_type = 3
	  },]]

	},

	--- Fire Flame 2
	{
	  type = "fire",
	  name = "ne-fire-flame-2",
	  flags = {"placeable-off-grid", "not-on-map"},
	  damage_per_tick = {amount = 15 / 60, type = "ne_fire", force = "enemy"}, -- v 13
	  maximum_damage_multiplier = 6,
	  damage_multiplier_increase_per_added_fuel = 1,
	  damage_multiplier_decrease_per_tick = 0.005,


	  spread_delay = 300,
	  spread_delay_deviation = 180,
	  maximum_spread_count = 50,

	  flame_alpha = 0.35,
	  flame_alpha_deviation = 0.05,


	  add_fuel_cooldown = 10,
	  fade_in_duration = 30,
	  fade_out_duration = 30,

	  initial_lifetime = 70,
	  lifetime_increase_by = 125,
	  lifetime_increase_cooldown = 4,
	  maximum_lifetime = 700,
	  delay_between_initial_flames = 10,
	  burnt_patch_lifetime = 600,

	  on_fuel_added_action = nil,

	  pictures = ne_fireutil.create_fire_pictures({ blend_mode = "normal", animation_speed = 1, scale = 0.5}),

	  smoke_source_pictures =
	  {
		{
		  filename = "__base__/graphics/entity/fire-flame/fire-smoke-source-1.png",
		  line_length = 8,
		  width = 101,
		  height = 138,
		  frame_count = 31,
		  axially_symmetrical = false,
		  direction_count = 1,
		  shift = {-0.109375, -1.1875},
		  animation_speed = 0.5
		},
		{
		  filename = "__base__/graphics/entity/fire-flame/fire-smoke-source-2.png",
		  line_length = 8,
		  width = 99,
		  height = 138,
		  frame_count = 31,
		  axially_symmetrical = false,
		  direction_count = 1,
		  shift = {-0.203125, -1.21875},
		  animation_speed = 0.5
		}
	  },

	  burnt_patch_pictures = nil,
	  burnt_patch_alpha_default = 0.4,
	  burnt_patch_alpha_variations = nil,

	  smoke = nil,

	  light = {intensity = 0.8, size = 10},

	  working_sound = nil
	  --[[
	  {
		sound = { filename = "__base__/sound/furnace.ogg" },
		max_sounds_per_type = 3
	  },]]

	},

	--- Fire Flame 3
	{
	  type = "fire",
	  name = "ne-fire-flame-3",
	  flags = {"placeable-off-grid", "not-on-map"},
	  damage_per_tick = {amount = 40 / 60, type = "ne_fire", force = "enemy"}, -- v 13
	  maximum_damage_multiplier = 9,
	  damage_multiplier_increase_per_added_fuel = 1,
	  damage_multiplier_decrease_per_tick = 0.005,

	  spread_delay = 300,
	  spread_delay_deviation = 180,
	  maximum_spread_count = 100,

	  flame_alpha = 0.35,
	  flame_alpha_deviation = 0.05,


	  add_fuel_cooldown = 10,
	  fade_in_duration = 30,
	  fade_out_duration = 30,

	  initial_lifetime = 80,
	  lifetime_increase_by = 150,
	  lifetime_increase_cooldown = 4,
	  maximum_lifetime = 800,
	  delay_between_initial_flames = 10,
	  burnt_patch_lifetime = 600,

	  on_fuel_added_action = nil,

	  pictures = ne_fireutil.create_fire_pictures({ blend_mode = "normal", animation_speed = 1, scale = 0.5}),

	  smoke_source_pictures =
	  {
		{
		  filename = "__base__/graphics/entity/fire-flame/fire-smoke-source-1.png",
		  line_length = 8,
		  width = 101,
		  height = 138,
		  frame_count = 31,
		  axially_symmetrical = false,
		  direction_count = 1,
		  shift = {-0.109375, -1.1875},
		  animation_speed = 0.5
		},
		{
		  filename = "__base__/graphics/entity/fire-flame/fire-smoke-source-2.png",
		  line_length = 8,
		  width = 99,
		  height = 138,
		  frame_count = 31,
		  axially_symmetrical = false,
		  direction_count = 1,
		  shift = {-0.203125, -1.21875},
		  animation_speed = 0.5
		}
	  },

	  burnt_patch_pictures = nil,
	  burnt_patch_alpha_default = 0.4,
	  burnt_patch_alpha_variations = nil,

	  smoke = nil,

	  light = {intensity = 0.8, size = 10},

	  working_sound = nil
	  --[[
	  {
		sound = { filename = "__base__/sound/furnace.ogg" },
		max_sounds_per_type = 3
	  },]]

	},
	

}
)



Small_Fire_Flame = table.deepcopy(data.raw.fire["ne-fire-flame-1"])
Small_Fire_Flame.name = "ne-fire-flame-0"
Small_Fire_Flame.initial_lifetime = 50
Small_Fire_Flame.lifetime_increase_by = 20
Small_Fire_Flame.maximum_spread_count = 5
Small_Fire_Flame.lifetime_increase_cooldown = 4
Small_Fire_Flame.maximum_lifetime = 180
Small_Fire_Flame.delay_between_initial_flames = 10
Small_Fire_Flame.burnt_patch_lifetime = 180

data:extend{Small_Fire_Flame}


