data:extend({

{
    type = "electric-pole",
    name = "hidden-electric-pole",
    icon = "__base__/graphics/icons/copper-cable.png",
	icon_size = 32,
	flags = {"not-deconstructable", "not-on-map", "placeable-off-grid", "not-repairable", "not-blueprintable"},
	selectable_in_game = false,
    max_health = 100,
    resistances = {{type = "fire", percent = 100}},
    collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
	--collision_mask = {},
    maximum_wire_distance = 6,
    supply_area_distance = 1,
    pictures =
    {
      filename = "__zzzparanoidal__/graphics/nothing.png",
      priority = "low",
      width = 1,
      height = 1,
	  frame_count = 1,
      axially_symmetrical = false,
      direction_count = 4,
	  shift = {0.75, 0},
    },
    connection_points =
    {
      {
        shadow =
        {

        },
        wire =
        {

        }
      },
      {
        shadow =
        {
 
        },
        wire =
        {

        }
      },
      {
        shadow =
        {

        },
        wire =
        {

        }
      },
      {
        shadow =
        {

        },
        wire =
        {

        }
      }

	},
    radius_visualisation_picture =
    {
      filename = "__zzzparanoidal__/graphics/nothing.png",
      width = 1,
      height = 1,
      priority = "low"
    },
  }
})