if settings.startup["no-clouds"].value  then
	data.raw["utility-sprites"]["default"].clouds =
    {
      filename = "__core__/graphics/clouds.png",
      priority = "low",
      flags = { "linear-minification", "linear-magnification" },
      width = 1,
      height = 1,
      frame_count = 1
    }
	end

if settings.startup["white-stone"].value  then
data.raw["tile"]["stone-path"].variants =
    {
      main =
      {
        {
          picture = "__SingleColorTerrain__/graphics/stone-path/stone-path-1.png",
          count = 16,
          size = 1,
          hr_version =
          {
            picture = "__SingleColorTerrain__/graphics/stone-path/hr-stone-path-1.png",
            count = 16,
            size = 1,
            scale = 0.5
          }
        },
        {
          picture = "__SingleColorTerrain__/graphics/stone-path/stone-path-2.png",
          count = 16,
          size = 2,
          probability = 0.39,
          hr_version =
          {
            picture = "__SingleColorTerrain__/graphics/stone-path/hr-stone-path-2.png",
            count = 16,
            size = 2,
            probability = 0.39,
            scale = 0.5
          }
        },
        {
          picture = "__SingleColorTerrain__/graphics/stone-path/stone-path-4.png",
          count = 16,
          size = 4,
          probability = 1,
          hr_version =
          {
            picture = "__SingleColorTerrain__/graphics/stone-path/hr-stone-path-4.png",
            count = 16,
            size = 4,
            probability = 1,
            scale = 0.5
          }
        }
      },
      inner_corner =
      {
        picture = "__SingleColorTerrain__/graphics/stone-path/stone-path-inner-corner.png",
        count = 16,
        tall = true,
        hr_version =
        {
          picture = "__SingleColorTerrain__/graphics/stone-path/hr-stone-path-inner-corner.png",
          count = 16,
          tall = true,
          scale = 0.5
        }
      },
      outer_corner =
      {
        picture = "__SingleColorTerrain__/graphics/stone-path/stone-path-outer-corner.png",
        count = 8,
        tall = true,
        hr_version =
        {
          picture = "__SingleColorTerrain__/graphics/stone-path/hr-stone-path-outer-corner.png",
          count = 8,
          tall = true,
          scale = 0.5
        }
      },
      side =
      {
        picture = "__SingleColorTerrain__/graphics/stone-path/stone-path-side.png",
        count = 16,
        tall = true,
        hr_version =
        {
          picture = "__SingleColorTerrain__/graphics/stone-path/hr-stone-path-side.png",
          count = 16,
          tall = true,
          scale = 0.5
        }
      },
      u_transition =
      {
        picture = "__SingleColorTerrain__/graphics/stone-path/stone-path-u.png",
        count = 8,
        tall = true,
        hr_version =
        {
          picture = "__SingleColorTerrain__/graphics/stone-path/hr-stone-path-u.png",
          count = 8,
          tall = true,
          scale = 0.5
        }
      },
      o_transition =
      {
        picture = "__SingleColorTerrain__/graphics/stone-path/stone-path-o.png",
        count = 4,
        hr_version =
        {
          picture = "__SingleColorTerrain__/graphics/stone-path/hr-stone-path-o.png",
          count = 4,
          scale = 0.5
        }
      }
    }
	end
	
if settings.startup["white-concrete"].value  then
data.raw["tile"]["concrete"].variants =
      {
        main =
        {
          {
            picture = "__base__/graphics/terrain/concrete/concrete-dummy.png",
            count = 1,
            size = 1
          },
          {
            picture = "__base__/graphics/terrain/concrete/concrete-dummy.png",
            count = 1,
            size = 2,
            probability = 0.39
          },
          {
            picture = "__base__/graphics/terrain/concrete/concrete-dummy.png",
            count = 1,
            size = 4,
            probability = 1
          },
        },
        inner_corner =
        {
          picture = "__SingleColorTerrain__/graphics/concrete/concrete-inner-corner.png",
          count = 16,
          hr_version = {
            picture = "__SingleColorTerrain__/graphics/concrete/hr-concrete-inner-corner.png",
            count = 16,
            scale = 0.5
          },
        },
        inner_corner_mask =
        {
          picture = "__base__/graphics/terrain/concrete/concrete-inner-corner-mask.png",
          count = 16,
          hr_version = {
            picture = "__base__/graphics/terrain/concrete/hr-concrete-inner-corner-mask.png",
            count = 16,
            scale = 0.5
          },
        },

        outer_corner =
        {
          picture = "__SingleColorTerrain__/graphics/concrete/concrete-outer-corner.png",
          count = 8,
          hr_version = {
            picture = "__SingleColorTerrain__/graphics/concrete/hr-concrete-outer-corner.png",
            count = 8,
            scale = 0.5
          },
        },
        outer_corner_mask =
        {
          picture = "__base__/graphics/terrain/concrete/concrete-outer-corner-mask.png",
          count = 8,
          hr_version = {
            picture = "__base__/graphics/terrain/concrete/hr-concrete-outer-corner-mask.png",
            count = 8,
            scale = 0.5
          },
        },

        side =
        {
          picture = "__SingleColorTerrain__/graphics/concrete/concrete-side.png",
          count = 16,
          hr_version = {
            picture = "__SingleColorTerrain__/graphics/concrete/hr-concrete-side.png",
            count = 16,
            scale = 0.5
          },
        },
        side_mask =
        {
          picture = "__base__/graphics/terrain/concrete/concrete-side-mask.png",
          count = 16,
          hr_version = {
            picture = "__base__/graphics/terrain/concrete/hr-concrete-side-mask.png",
            count = 16,
            scale = 0.5
          },
        },

        u_transition =
        {
          picture = "__SingleColorTerrain__/graphics/concrete/concrete-u.png",
          count = 8,
          hr_version = {
            picture = "__SingleColorTerrain__/graphics/concrete/hr-concrete-u.png",
            count = 8,
            scale = 0.5
          },
        },
        u_transition_mask =
        {
          picture = "__base__/graphics/terrain/concrete/concrete-u-mask.png",
          count = 8,
          hr_version = {
            picture = "__base__/graphics/terrain/concrete/hr-concrete-u-mask.png",
            count = 8,
            scale = 0.5
          },
        },

        o_transition =
        {
          picture = "__SingleColorTerrain__/graphics/concrete/concrete-o.png",
          count = 4,
          hr_version = {
            picture = "__SingleColorTerrain__/graphics/concrete/hr-concrete-o.png",
            count = 4,
            scale = 0.5
          },
        },
        o_transition_mask =
        {
          picture = "__base__/graphics/terrain/concrete/concrete-o-mask.png",
          count = 4,
          hr_version = {
            picture = "__base__/graphics/terrain/concrete/hr-concrete-o-mask.png",
            count = 4,
            scale = 0.5
          },
        },


        material_background =
        {
          picture = "__SingleColorTerrain__/graphics/concrete/concrete.png",
          count = 8,
          hr_version =
          {
            picture = "__SingleColorTerrain__/graphics/concrete/hr-concrete.png",
            count = 8,
            scale = 0.5
          }
        }
      }

	  end
	  
	