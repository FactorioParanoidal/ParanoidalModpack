--data-updates
data.raw["assembling-machine"]["assembling-machine-1"].working_visualisations =
{
  {
    light = {intensity = 0.65, size = 10, color = {r=settings.startup["assembler-1-red"].value, g=settings.startup["assembler-1-green"].value, b=settings.startup["assembler-1-blue"].value}},
  }
};
data.raw["assembling-machine"]["assembling-machine-2"].working_visualisations =
{
  {
    light = {intensity = 0.65, size = 10, color = {r=settings.startup["assembler-2-red"].value, g=settings.startup["assembler-2-green"].value, b=settings.startup["assembler-2-blue"].value}},
  }
};
data.raw["assembling-machine"]["assembling-machine-3"].working_visualisations =
{
  {
    light = {intensity = 0.65, size = 10, color = {r=settings.startup["assembler-3-red"].value, g=settings.startup["assembler-3-green"].value, b=settings.startup["assembler-3-blue"].value}},
  }
};

--chemical plants
data.raw["assembling-machine"]["chemical-plant"].working_visualisations = 

{
      {
        north_position = util.by_pixel(30, -24),
        west_position = util.by_pixel(1, -49.5),
        south_position = util.by_pixel(-30, -48),
        east_position = util.by_pixel(-11, -1),
        apply_recipe_tint = "primary",
        animation =
        {
          filename = "__lightorio__/graphics/boiling-green-patch.png",
          frame_count = 32,
          width = 15,
          height = 10,
          animation_speed = 0.5,
          hr_version =
          {
            filename = "__lightorio__/graphics/hr-boiling-green-patch.png",
            frame_count = 32,
            width = 30,
            height = 20,
            animation_speed = 0.5,
            scale = 0.5
          }
        }
      },

      {
        north_position = util.by_pixel(30, -24),
        west_position = util.by_pixel(1, -49.5),
        south_position = util.by_pixel(-30, -48),
        east_position = util.by_pixel(-11, -1),
        apply_recipe_tint = "secondary",
        animation =
        {
          filename = "__lightorio__/graphics/boiling-green-patch-mask.png",
          frame_count = 32,
          width = 15,
          height = 10,
          animation_speed = 0.5,
          hr_version =
          {
            filename = "__lightorio__/graphics/hr-boiling-green-patch-mask.png",
            frame_count = 32,
            width = 30,
            height = 20,
            animation_speed = 0.5,
            scale = 0.5
          }
        }
      },
	  {
		light = {intensity = 0.65, size = 10, color = {r=settings.startup["chemical-1-red"].value, g=settings.startup["chemical-1-green"].value, b=settings.startup["chemical-1-blue"].value}},
	  }
}
--bob's chemical plants
if data.raw["assembling-machine"]["chemical-plant-2"] then
	data.raw["assembling-machine"]["chemical-plant-2"].working_visualisations =
{
      {
        north_position = util.by_pixel(30, -24),
        west_position = util.by_pixel(1, -49.5),
        south_position = util.by_pixel(-30, -48),
        east_position = util.by_pixel(-11, -1),
        apply_recipe_tint = "primary",
        animation =
        {
          filename = "__lightorio__/graphics/boiling-green-patch.png",
          frame_count = 32,
          width = 15,
          height = 10,
          animation_speed = 0.5,
          hr_version =
          {
            filename = "__lightorio__/graphics/hr-boiling-green-patch.png",
            frame_count = 32,
            width = 30,
            height = 20,
            animation_speed = 0.5,
            scale = 0.5
          }
        }
      },

      {
        north_position = util.by_pixel(30, -24),
        west_position = util.by_pixel(1, -49.5),
        south_position = util.by_pixel(-30, -48),
        east_position = util.by_pixel(-11, -1),
        apply_recipe_tint = "secondary",
        animation =
        {
          filename = "__lightorio__/graphics/boiling-green-patch-mask.png",
          frame_count = 32,
          width = 15,
          height = 10,
          animation_speed = 0.5,
          hr_version =
          {
            filename = "__lightorio__/graphics/hr-boiling-green-patch-mask.png",
            frame_count = 32,
            width = 30,
            height = 20,
            animation_speed = 0.5,
            scale = 0.5
          }
        }
      },
	  {
		light = {intensity = 0.65, size = 10, color = {r=settings.startup["chemical-2-red"].value, g=settings.startup["chemical-2-green"].value, b=settings.startup["chemical-2-blue"].value}},
	  }
}
end

if 	data.raw["assembling-machine"]["chemical-plant-3"] then
	data.raw["assembling-machine"]["chemical-plant-3"].working_visualisations =
{
      {
        north_position = util.by_pixel(30, -24),
        west_position = util.by_pixel(1, -49.5),
        south_position = util.by_pixel(-30, -48),
        east_position = util.by_pixel(-11, -1),
        apply_recipe_tint = "primary",
        animation =
        {
          filename = "__lightorio__/graphics/boiling-green-patch.png",
          frame_count = 32,
          width = 15,
          height = 10,
          animation_speed = 0.5,
          hr_version =
          {
            filename = "__lightorio__/graphics/hr-boiling-green-patch.png",
            frame_count = 32,
            width = 30,
            height = 20,
            animation_speed = 0.5,
            scale = 0.5
          }
        }
      },

      {
        north_position = util.by_pixel(30, -24),
        west_position = util.by_pixel(1, -49.5),
        south_position = util.by_pixel(-30, -48),
        east_position = util.by_pixel(-11, -1),
        apply_recipe_tint = "secondary",
        animation =
        {
          filename = "__lightorio__/graphics/boiling-green-patch-mask.png",
          frame_count = 32,
          width = 15,
          height = 10,
          animation_speed = 0.5,
          hr_version =
          {
            filename = "__lightorio__/graphics/hr-boiling-green-patch-mask.png",
            frame_count = 32,
            width = 30,
            height = 20,
            animation_speed = 0.5,
            scale = 0.5
          }
        }
      },
	  {
		light = {intensity = 0.65, size = 10, color = {r=settings.startup["chemical-3-red"].value, g=settings.startup["chemical-3-green"].value, b=settings.startup["chemical-3-blue"].value}},
	  }
}
end

if data.raw["assembling-machine"]["chemical-plant-4"] then
	data.raw["assembling-machine"]["chemical-plant-4"].working_visualisations =
{
      {
        north_position = util.by_pixel(30, -24),
        west_position = util.by_pixel(1, -49.5),
        south_position = util.by_pixel(-30, -48),
        east_position = util.by_pixel(-11, -1),
        apply_recipe_tint = "primary",
        animation =
        {
          filename = "__lightorio__/graphics/boiling-green-patch.png",
          frame_count = 32,
          width = 15,
          height = 10,
          animation_speed = 0.5,
          hr_version =
          {
            filename = "__lightorio__/graphics/hr-boiling-green-patch.png",
            frame_count = 32,
            width = 30,
            height = 20,
            animation_speed = 0.5,
            scale = 0.5
          }
        }
      },

      {
        north_position = util.by_pixel(30, -24),
        west_position = util.by_pixel(1, -49.5),
        south_position = util.by_pixel(-30, -48),
        east_position = util.by_pixel(-11, -1),
        apply_recipe_tint = "secondary",
        animation =
        {
          filename = "__lightorio__/graphics/boiling-green-patch-mask.png",
          frame_count = 32,
          width = 15,
          height = 10,
          animation_speed = 0.5,
          hr_version =
          {
            filename = "__lightorio__/graphics/hr-boiling-green-patch-mask.png",
            frame_count = 32,
            width = 30,
            height = 20,
            animation_speed = 0.5,
            scale = 0.5
          }
        }
      },
	  {
		light = {intensity = 0.65, size = 10, color = {r=settings.startup["chemical-4-red"].value, g=settings.startup["chemical-4-green"].value, b=settings.startup["chemical-4-blue"].value}},
	  }
}
end


-- oil refinery

    data.raw["assembling-machine"]["oil-refinery"].working_visualisations =
    {
      {
        north_position = util.by_pixel(34, -65),
        east_position = util.by_pixel(-52, -61),
        south_position = util.by_pixel(-59, -82),
        west_position = util.by_pixel(57, -58),
        animation =
        {
          filename = "__lightorio__/graphics/oil-refinery-fire.png",
          line_length = 10,
          width = 20,
          height = 40,
          frame_count = 60,
          animation_speed = 0.75,
          shift = util.by_pixel(0, -14),
          hr_version =
          {
            filename = "__lightorio__/graphics/hr-oil-refinery-fire.png",
            line_length = 10,
            width = 40,
            height = 81,
            frame_count = 60,
            animation_speed = 0.75,
            scale = 0.5,
            shift = util.by_pixel(0, -14.25)
          }
        },
		light = {intensity = 0.65, size = 10, color = {r=settings.startup["refinery-1-red"].value, g=settings.startup["refinery-1-green"].value, b=settings.startup["refinery-1-blue"].value}},
      }
    }


-- bob's refineries
if data.raw["assembling-machine"]["oil-refinery-2"] then
data.raw["assembling-machine"]["oil-refinery-2"].working_visualisations = 
    {
      {
        north_position = util.by_pixel(34, -65),
        east_position = util.by_pixel(-52, -61),
        south_position = util.by_pixel(-59, -82),
        west_position = util.by_pixel(57, -58),
        animation =
        {
          filename = "__lightorio__/graphics/oil-refinery-fire.png",
          line_length = 10,
          width = 20,
          height = 40,
          frame_count = 60,
          animation_speed = 0.75,
          shift = util.by_pixel(0, -14),
          hr_version =
          {
            filename = "__lightorio__/graphics/hr-oil-refinery-fire.png",
            line_length = 10,
            width = 40,
            height = 81,
            frame_count = 60,
            animation_speed = 0.75,
            scale = 0.5,
            shift = util.by_pixel(0, -14.25)
          }
        },
		light = {intensity = 0.65, size = 10, color = {r=settings.startup["refinery-2-red"].value, g=settings.startup["refinery-2-green"].value, b=settings.startup["refinery-2-blue"].value}},
      }
    }
end

if data.raw["assembling-machine"]["oil-refinery-3"] then
data.raw["assembling-machine"]["oil-refinery-3"].working_visualisations = 
    {
      {
        north_position = util.by_pixel(34, -65),
        east_position = util.by_pixel(-52, -61),
        south_position = util.by_pixel(-59, -82),
        west_position = util.by_pixel(57, -58),
        animation =
        {
          filename = "__lightorio__/graphics/oil-refinery-fire.png",
          line_length = 10,
          width = 20,
          height = 40,
          frame_count = 60,
          animation_speed = 0.75,
          shift = util.by_pixel(0, -14),
          hr_version =
          {
            filename = "__lightorio__/graphics/hr-oil-refinery-fire.png",
            line_length = 10,
            width = 40,
            height = 81,
            frame_count = 60,
            animation_speed = 0.75,
            scale = 0.5,
            shift = util.by_pixel(0, -14.25)
          }
        },
		light = {intensity = 0.65, size = 10, color = {r=settings.startup["refinery-3-red"].value, g=settings.startup["refinery-3-green"].value, b=settings.startup["refinery-3-blue"].value}},
      }
    }
end

if data.raw["assembling-machine"]["oil-refinery-4"] then
data.raw["assembling-machine"]["oil-refinery-4"].working_visualisations = 
    {
      {
        north_position = util.by_pixel(34, -65),
        east_position = util.by_pixel(-52, -61),
        south_position = util.by_pixel(-59, -82),
        west_position = util.by_pixel(57, -58),
        animation =
        {
          filename = "__lightorio__/graphics/oil-refinery-fire.png",
          line_length = 10,
          width = 20,
          height = 40,
          frame_count = 60,
          animation_speed = 0.75,
          shift = util.by_pixel(0, -14),
          hr_version =
          {
            filename = "__lightorio__/graphics/hr-oil-refinery-fire.png",
            line_length = 10,
            width = 40,
            height = 81,
            frame_count = 60,
            animation_speed = 0.75,
            scale = 0.5,
            shift = util.by_pixel(0, -14.25)
          }
        },
		light = {intensity = 0.65, size = 10, color = {r=settings.startup["refinery-4-red"].value, g=settings.startup["refinery-4-green"].value, b=settings.startup["refinery-4-blue"].value}},
      }
    }
end


-- bob's assemblers
if data.raw["assembling-machine"]["assembling-machine-4"] then
	data.raw["assembling-machine"]["assembling-machine-4"].working_visualisations =
	{
	  {
    light = {intensity = 0.65, size = 10, color = {r=settings.startup["assembler-4-red"].value, g=settings.startup["assembler-4-green"].value, b=settings.startup["assembler-4-blue"].value}},
	  }
	};
end
if data.raw["assembling-machine"]["assembling-machine-5"] then
	data.raw["assembling-machine"]["assembling-machine-5"].working_visualisations =
	{
	  {
    light = {intensity = 0.65, size = 10, color = {r=settings.startup["assembler-5-red"].value, g=settings.startup["assembler-5-green"].value, b=settings.startup["assembler-5-blue"].value}},
	  }
	};
end
if data.raw["assembling-machine"]["assembling-machine-6"] then
	data.raw["assembling-machine"]["assembling-machine-6"].working_visualisations =
	{
	  {
    light = {intensity = 0.65, size = 10, color = {r=settings.startup["assembler-6-red"].value, g=settings.startup["assembler-6-green"].value, b=settings.startup["assembler-6-blue"].value}},
	  }
	};
end

--induction furnaces
if data.raw.recipe["induction-furnace"] then
		
data.raw["assembling-machine"]["induction-furnace"].working_visualisations =
{
 {
    light = {intensity = 0.5, size = 5, color = {r=1.00, g=0.45, b=0.4}},
  }
};

data.raw["assembling-machine"]["induction-furnace-2"].working_visualisations =
{
 {
    light = {intensity = 0.5, size = 5, color = {r=1.00, g=0.45, b=0.4}},
  }
};
data.raw["assembling-machine"]["induction-furnace-3"].working_visualisations =
{
 {
    light = {intensity = 0.5, size = 5, color = {r=1.00, g=0.45, b=0.4}},
  }
};
data.raw["assembling-machine"]["induction-furnace-4"].working_visualisations =
{
 {
    light = {intensity = 0.5, size = 5, color = {r=1.00, g=0.45, b=0.4}},
  }
};

end

-- casting machines
if data.raw.recipe["casting-machine"] then
		
data.raw["assembling-machine"]["casting-machine"].working_visualisations =
{
 {
    light = {intensity = 0.5, size = 5, color = {r=1.00, g=0.45, b=0.4}},
  }
};

data.raw["assembling-machine"]["casting-machine-2"].working_visualisations =
{
 {
    light = {intensity = 0.5, size = 5, color = {r=1.00, g=0.45, b=0.4}},
  }
};
data.raw["assembling-machine"]["casting-machine-3"].working_visualisations =
{
 {
    light = {intensity = 0.5, size = 5, color = {r=1.00, g=0.45, b=0.4}},
  }
};
data.raw["assembling-machine"]["casting-machine-4"].working_visualisations =
{
 {
    light = {intensity = 0.5, size = 5, color = {r=1.00, g=0.45, b=0.4}},
  }
};

end


-- electrolyser
if data.raw["assembling-machine"]["eangels-electrolyser"] then
	data.raw["assembling-machine"]["angels-electrolyser"].working_visualisations =
	{
	  {
		light = {intensity = 0.7, size = 15, color = {r=0.03, g=0.573, b=0.816}},
	  }
	};
end
if data.raw["assembling-machine"]["angels-electrolyser-2"] then
	data.raw["assembling-machine"]["angels-electrolyser-2"].working_visualisations =
	{
	  {
		light = {intensity = 0.7, size = 15, color = {r=0.03, g=0.573, b=0.816}},
	  }
	};
end
if data.raw["assembling-machine"]["angels-electrolyser-3"] then
	data.raw["assembling-machine"]["angels-electrolyser-3"].working_visualisations =
	{
	  {
		light = {intensity = 0.7, size = 15, color = {r=0.03, g=0.573, b=0.816}},
	  }
	};
end
if data.raw["assembling-machine"]["angels-electrolyser-4"] then
	data.raw["assembling-machine"]["angels-electrolyser-4"].working_visualisations =
	{
	  {
		light = {intensity = 0.7, size = 15, color = {r=0.03, g=0.573, b=0.816}},
	  }
	};
end


-- electronic assembling machines
if data.raw["assembling-machine"]["electronics-machine-1"] then
	data.raw["assembling-machine"]["electronics-machine-1"].working_visualisations =
	{
	  {
		light = {intensity = 0.65, size = 10, color = {r=settings.startup["elecassembler-1-red"].value, g=settings.startup["elecassembler-1-green"].value, b=settings.startup["elecassembler-1-blue"].value}},
	  }
	};
end

if data.raw["assembling-machine"]["electronics-machine-2"] then
	data.raw["assembling-machine"]["electronics-machine-2"].working_visualisations =
	{
	  {
		light = {intensity = 0.65, size = 10, color = {r=settings.startup["elecassembler-2-red"].value, g=settings.startup["elecassembler-2-green"].value, b=settings.startup["elecassembler-2-blue"].value}},
	  }
	};
end

if data.raw["assembling-machine"]["electronics-machine-3"] then
	data.raw["assembling-machine"]["electronics-machine-3"].working_visualisations =
	{
	  {
		light = {intensity = 0.65, size = 10, color = {r=settings.startup["elecassembler-3-red"].value, g=settings.startup["elecassembler-3-green"].value, b=settings.startup["elecassembler-3-blue"].value}},
	  }
	};
end










