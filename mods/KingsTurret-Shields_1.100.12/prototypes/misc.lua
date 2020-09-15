local neutral_flags = {"not-repairable", "not-blueprintable", "not-deconstructable", "placeable-off-grid", "not-on-map", "placeable-neutral"}
  
  data:extend({
  	{	
		type = "simple-entity",
		name = "ts-unplugged",
		icon = "__KingsTurret-Shields__/graphics/blank.png",	icon_size = 32,
		flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
		subgroup = "wrecks",
		order = "d[remnants]-d[ship-wreck]-b[medium]-a",
		max_health = 200,
		render_layer = "entity-info-icon",
		pictures =
		{
			{
				filename = "__core__/graphics/icons/alerts/electricity-icon-unplugged.png",
				width = 64,
				height= 64,
				scale=0.18,
				shift = {0.7, -0.8},
			}
		},
	},---------------------------
	{
        type = "selection-tool",
        name = "ts-shield-disabler",
        icon = "__KingsTurret-Shields__/graphics/blueprint.png",
        icon_size = 32,
        --flags = {"goes-to-quickbar"},
        selection_color = {r = 1.0, g = 0.55, b = 0.0, a = 0.2},
        alt_selection_color = {r = 1.0, g = 0.2, b = 0.0, a = 0.2},
        selection_mode = {"blueprint"},
        alt_selection_mode = {"blueprint"},
        selection_cursor_box_type = "electricity",
        alt_selection_cursor_box_type = "electricity",
        subgroup = "tool",
        order = "c[automated-construction]-d[outpost-builder]a",
        stack_size = 1
    },---------------------------
    {
        type = "recipe",
        name = "ts-shield-disabler",
        enabled = false,
        energy_required = 0.1,
        category = "crafting",
        ingredients = {},
        result = "ts-shield-disabler"
    

	},--------------------------------------------------------------------------------------------------------------------------------------------
	{
		type = "constant-combinator",
		name = "turret-shield-combinator",
		icon = "__KingsTurret-Shields__/graphics/turret-shield-combinator-icon.png",
		icon_size = 32,
		flags = {"placeable-neutral", "player-creation"},
		minable = {hardness = 0.2, mining_time = 0.5, result = "turret-shield-combinator"},
		max_health = 300,
		resistances = 
		{
			{
				type = "physical",
				percent = 70
			},
			{
				type = "impact",
				percent = 70
			},
			{
				type = "fire",
				percent = 70
			},
			{
				type = "acid",
				percent = 70
			},
			{
				type = "poison",
				percent = 70
			},
			{
				type = "explosion",
				percent = 70
			},
			{
				type = "laser",
				percent = 70
			},
		},
		corpse = "small-remnants",
		collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		item_slot_count = 0,
		sprites =
		{
			north =
			{
				filename = "__KingsTurret-Shields__/graphics/turret-shield-combinator.png",
				x = 158,
				width = 79,
				height = 63,
				frame_count = 1,
				shift = {0.140625, 0.140625},
			},
			east =
			{
				filename = "__KingsTurret-Shields__/graphics/turret-shield-combinator.png",
				width = 79,
				height = 63,
				frame_count = 1,
				shift = {0.140625, 0.140625},
			},
			south =
			{
				filename = "__KingsTurret-Shields__/graphics/turret-shield-combinator.png",
				x = 237,
				width = 79,
				height = 63,
				frame_count = 1,
				shift = {0.140625, 0.140625},
			},
			west =
			{
				filename = "__KingsTurret-Shields__/graphics/turret-shield-combinator.png",
				x = 79,
				width = 79,
				height = 63,
				frame_count = 1,
				shift = {0.140625, 0.140625},
			}
		},

		activity_led_sprites =
		{
			north =
			{
				filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-N.png",
				width = 8,
				height = 6,
				frame_count = 1,
				shift = {0.296875, -0.40625},
			},
			east =
			{
				filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-E.png",
				width = 8,
				height = 8,
				frame_count = 1,
				shift = {0.25, -0.03125},
			},
			south =
			{
				filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-S.png",
				width = 8,
				height = 8,
				frame_count = 1,
				shift = {-0.296875, -0.078125},
			},
			west =
			{
				filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-W.png",
				width = 8,
				height = 8,
				frame_count = 1,
				shift = {-0.21875, -0.46875},
			}
		},
	
		activity_led_light =
		{
			intensity = 0.8,
			size = 1,
		},
	
		activity_led_light_offsets =
		{
			{0.296875, -0.40625},
			{0.25, -0.03125},
			{-0.296875, -0.078125},
			{-0.21875, -0.46875}
		},
	
		circuit_wire_connection_points =
		{
			{
				shadow =
				{
					red = {0.15625, -0.28125},
					green = {0.65625, -0.25}
				},
				wire =
				{
					red = {-0.28125, -0.5625},
					green = {0.21875, -0.5625},
				}
			},
			{
				shadow =
				{
					red = {0.75, -0.15625},
					green = {0.75, 0.25},
				},
				wire =
				{
					red = {0.46875, -0.5},
					green = {0.46875, -0.09375},
				}
			},
			{
				shadow =
				{
					red = {0.75, 0.5625},
					green = {0.21875, 0.5625}
				},
				wire =
				{
					red = {0.28125, 0.15625},
					green = {-0.21875, 0.15625}
				}
			},
			{
				shadow =
				{
					red = {-0.03125, 0.28125},
					green = {-0.03125, -0.125},
				},
				wire =
				{
					red = {-0.46875, 0},
					green = {-0.46875, -0.40625},
				}
			}
		},
    circuit_wire_max_distance = 7.5
  },---------------------------
	  {
    type = "item-with-tags",
    name = "turret-shield-combinator",
    icon = "__KingsTurret-Shields__/graphics/turret-shield-combinator-icon.png",
    icon_size = 32,
    --flags = { "goes-to-quickbar" },
    subgroup = "tool",
    order = "c[automated-construction]-d[outpost-builder]b",
    place_result="turret-shield-combinator",
    stack_size= 50,
  },---------------------------
  {
    type = "recipe",
    name = "turret-shield-combinator",
    enabled = false,
    ingredients =
    {
      {"electronic-circuit", 1},
      {"small-lamp", 1}
    },
    result = "turret-shield-combinator"
  },
		
  })


