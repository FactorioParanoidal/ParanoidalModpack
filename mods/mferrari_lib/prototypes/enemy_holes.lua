local hit_effects = require("__base__/prototypes/entity/hit-effects.lua")
local decorative_trigger_effects = require("__base__/prototypes/decorative/decorative-trigger-effects.lua")


local spawn_all_vanilla_units = {
      {"small-biter", {{0.0, 0.3}, {0.25, 0.3}, {0.35, 0.0}}},
      {"small-spitter", {{0.25, 0.3}, {0.5, 0.3}, {0.7, 0.0}}},
	  {"medium-biter", 		 {{0.30, 0.0}, {0.50, 0.3}, {0.60, 0.0}}},
      {"medium-spitter", {{0.4, 0.0}, {0.5, 0.3}, {0.6, 0.0}}},
      {"big-spitter", {{0.59, 0.0}, {0.6, 0.4}, {0.7, 0.0}}},
	  {"big-biter",	{{0.59, 0.0}, {0.6, 0.3}, {0.7, 0.0}}},
	  {"behemoth-biter", {{0.69, 0.0}, {0.9, 0.4}}},
	  {"behemoth-spitter", {{0.69, 0.0}, {0.9, 0.4}}}
	  }


if mods["Arachnids_enemy"] then 
	concat_lists(spawn_all_vanilla_units,
	{
	{"arachnid-biter-drone-unit", {{0.0, 0.3}, {0.6, 0.0}}},
	{"arachnid-biter-warrior-unit", {{0.2, 0.0}, {0.6, 0.3}, {0.7, 0.1}}},
	{"arachnid-biter-tiger-unit", {{0.5, 0.0}, {1.0, 0.4}}},
	{"arachnid-biter-royalwarrior-unit", {{0.9, 0.0}, {1.0, 0.3}}},
	{"arachnid-spitter-smallspitter-unit", {{0.25, 0.0}, {0.5, 0.3}, {0.7, 0.0}}},
	{"arachnid-spitter-mediumspitter-unit", {{0.4, 0.0}, {0.7, 0.3}, {0.9, 0.1}}},
	{"arachnid-spitter-bigspitter-unit", {{0.5, 0.0}, {1.0, 0.4}}},
	{"arachnid-spitter-behemothspitter-unit", {{0.9, 0.0}, {1.0, 0.3}}},
	{"arachnid-biter-leviathan-unit", {{0.965, 0.0}, {1.0, 0.03}}}	
	})
	end


--------------------------------------------------------------------------------------
local hole_corpse = table.deepcopy(data.raw.corpse["biter-spawner-corpse"])
hole_corpse.name = "mf-hole-corpse"
hole_corpse.decay_animation=nil
hole_corpse.dying_speed = 0.02
hole_corpse.final_render_layer = "lower-object-above-shadow"
hole_corpse.animation =
{
	{
		layers =
		{
			{
			filename = "__base__/graphics/entity/worm/worm-hole-collapse.png",
			width = 330,
			height = 298,
			shift = util.by_pixel( 5.0, -14.5),
			line_length = 5,
			frame_count = 20,
			direction_count = 1,
			scale = 0.5,
			},
		}
	}
}
hole_corpse.time_before_removed = 10 * 60 * 60


--------------------------------------------------------------------------------------
local hole_spawner =  table.deepcopy(data.raw["unit-spawner"]["biter-spawner"])
hole_spawner.name="mf-hole-spawner"
hole_spawner.corpse = "mf-hole-corpse"
hole_spawner.time_to_capture=0
hole_spawner.captured_spawner_entity=nil
hole_spawner.autoplace = nil 
hole_spawner.collision_box = {{-1.5, -1.3}, {1.5, 1.3}}
hole_spawner.selection_box = {{-1.5, -1.3}, {1.5, 1.3}}
hole_spawner.shooting_cursor_size = 4
hole_spawner.damaged_trigger_effect = hit_effects.rock()
hole_spawner.dying_explosion = nil
hole_spawner.dying_trigger_effect = decorative_trigger_effects.huge_rock()
hole_spawner.result_units = spawn_all_vanilla_units
hole_spawner.graphics_set = { animations =
{
	{
		layers =
		{
			{
			filename = "__base__/graphics/entity/worm/worm-hole-collapse.png",
			line_length = 1,
			width = 330,
			height = 298,
			scale = 0.5,
			frame_count = 1,
			animation_speed = 0.18,
			direction_count = 1,
			shift = util.by_pixel( 5.0, -14.5),
			--run_mode = "forward-then-backward",
			},
		}
	}
}}


data:extend(
{
hole_spawner,hole_corpse,



-- diggy hole
  {
    type = "simple-entity-with-owner",
    name = "mf-diggy-hole",
    flags = {"player-creation", "not-blueprintable", "not-deconstructable", "not-rotatable"},
    map_color = {r=1, g=0.5, b=0},
--    placeable_by = {item="portal-gun", count= 1},
    minable = {mining_time = 0.7, result = nil},
    max_health = 300,
	collision_box = {{-1.5, -1.3}, {1.5, 1.3}},
	selection_box = {{-1.5, -1.3}, {1.5, 1.3}},
    collision_mask = {layers={item=true, object=true, water_tile=true, is_object=true, is_lower_object=true}},
	selectable_in_game=false,
    random_animation_offset = false,
    animations =
    {
	{
		layers =
		{
			{
			filename = "__base__/graphics/entity/worm/worm-hole-collapse.png",
			line_length = 1,
			width = 330,
			height = 298,
			scale = 0.5,
			frame_count = 1,
			animation_speed = 0.18,
			direction_count = 1,
			shift = util.by_pixel( 5.0, -14.5),
			--run_mode = "forward-then-backward",
			},
		}
	}
    },
    working_sound =
    {
      sound = { filename = "__base__/sound/wind/wind.ogg" },
      volume = 0.8,
      audible_distance_modifier = 0.5,
      probability = 1
    },
    render_layer = "floor",
    tile_width = 2,
    tile_height = 2,
  },
  
 })