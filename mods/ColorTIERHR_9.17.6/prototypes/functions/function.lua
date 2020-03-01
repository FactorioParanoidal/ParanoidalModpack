function replaceACCUMULATORS(name,base_picture,extra_layer)

	if data.raw["accumulator"][name] then
	
		if base_picture ~= nil then
			
			data.raw["accumulator"][name]["picture"]["layers"][1]["filename"] = ColorTIER_path.."/graphics/low-res/entity/accumulator/" ..base_picture.. ".png"
			data.raw["accumulator"][name]["picture"]["layers"][1]["hr_version"]["filename"] = ColorTIER_path.."/graphics/high-res/entity/accumulator/" ..base_picture.. ".png"
			table.insert(data.raw["accumulator"][name]["charge_animation"]["layers"][1]["layers"]	,baseACCUMULATORS(base_picture))
			table.insert(data.raw["accumulator"][name]["discharge_animation"]["layers"][1]["layers"],baseACCUMULATORS(base_picture))
		
		end

		if extra_layer ~= nil then
		
			table.insert(data.raw["accumulator"][name]["picture"]["layers"]			,xtraACCUMULATORSnorepeat(extra_layer))
			table.insert(data.raw["accumulator"][name]["charge_animation"]["layers"][1]["layers"]	,xtraACCUMULATORS(extra_layer))
			table.insert(data.raw["accumulator"][name]["discharge_animation"]["layers"][1]["layers"],xtraACCUMULATORS(extra_layer))
		
		end

	end	
	
end


----------------------------------------------------------------------------------------------------------------------

function replaceASSEMBLERS1(name,type)
	if data.raw["assembling-machine"][name] then
	data.raw["assembling-machine"][name]["animation"]["layers"] = 
	{
    {
      filename = ColorTIER_path.."/graphics/high-res/entity/assembling-machine/assembling-machine-"..type..".png",
        priority="high",
        width = 214,
        height = 226,
        frame_count = 32,
        line_length = 8,
        shift = util.by_pixel(0, 2),
        scale = 0.5,
      hr_version =
      {
        filename = ColorTIER_path.."/graphics/high-res/entity/assembling-machine/assembling-machine-"..type..".png",
        priority="high",
        width = 214,
        height = 226,
        frame_count = 32,
        line_length = 8,
        shift = util.by_pixel(0, 2),
        scale = 0.5
      }
    },
    {
      filename = "__base__/graphics/entity/assembling-machine-1/hr-assembling-machine-1-shadow.png",
        priority="high",
        width = 190,
        height = 165,
        frame_count = 1,
        line_length = 1,
        repeat_count = 32,
        draw_as_shadow = true,
        shift = util.by_pixel(8.5, 5),
        scale = 0.5,
      hr_version =
      {
        filename = "__base__/graphics/entity/assembling-machine-1/hr-assembling-machine-1-shadow.png",
        priority="high",
        width = 190,
        height = 165,
        frame_count = 1,
        line_length = 1,
        repeat_count = 32,
        draw_as_shadow = true,
        shift = util.by_pixel(8.5, 5),
        scale = 0.5
      }
    }}
	end
end

function replaceASSEMBLERS2(name,type)
	if data.raw["assembling-machine"][name] then
	data.raw["assembling-machine"][name]["animation"]["layers"] = 
    {
    {
      filename = ColorTIER_path.."/graphics/high-res/entity/assembling-machine/assembling-machine-"..type..".png",
        priority = "high",
        width = 214,
        height = 218,
        frame_count = 32,
        line_length = 8,
        shift = util.by_pixel(0, 4),
        scale = 0.5,
      hr_version =
      {
        filename = ColorTIER_path.."/graphics/high-res/entity/assembling-machine/assembling-machine-"..type..".png",
        priority = "high",
        width = 214,
        height = 218,
        frame_count = 32,
        line_length = 8,
        shift = util.by_pixel(0, 4),
        scale = 0.5
      }
    },
    {
      filename = "__base__/graphics/entity/assembling-machine-2/hr-assembling-machine-2-shadow.png",
        priority = "high",
        width = 196,
        height = 163,
        frame_count = 32,
        line_length = 8,
        draw_as_shadow = true,
        shift = util.by_pixel(12, 4.75),
        scale = 0.5,
      hr_version =
      {
        filename = "__base__/graphics/entity/assembling-machine-2/hr-assembling-machine-2-shadow.png",
        priority = "high",
        width = 196,
        height = 163,
        frame_count = 32,
        line_length = 8,
        draw_as_shadow = true,
        shift = util.by_pixel(12, 4.75),
        scale = 0.5
      }
    }}
	end
end

function replaceASSEMBLERS3(name,type)
	if data.raw["assembling-machine"][name] then
	data.raw["assembling-machine"][name]["animation"]["layers"] = 
    {    
		{
      filename = ColorTIER_path.."/graphics/high-res/entity/assembling-machine/assembling-machine-"..type..".png",
        priority = "high",
        width = 214,
        height = 237,
        frame_count = 32,
        line_length = 8,
        shift = util.by_pixel(0, -0.75),
        scale = 0.5,
      hr_version =
      {
        filename = ColorTIER_path.."/graphics/high-res/entity/assembling-machine/assembling-machine-"..type..".png",
        priority = "high",
        width = 214,
        height = 237,
        frame_count = 32,
        line_length = 8,
        shift = util.by_pixel(0, -0.75),
        scale = 0.5
      }
    },
    {
      filename = "__base__/graphics/entity/assembling-machine-3/hr-assembling-machine-3-shadow.png",
        priority = "high",
        width = 260,
        height = 162,
        frame_count = 32,
        line_length = 8,
        draw_as_shadow = true,
        shift = util.by_pixel(28, 4),
        scale = 0.5,
      hr_version =
      {
        filename = "__base__/graphics/entity/assembling-machine-3/hr-assembling-machine-3-shadow.png",
        priority = "high",
        width = 260,
        height = 162,
        frame_count = 32,
        line_length = 8,
        draw_as_shadow = true,
        shift = util.by_pixel(28, 4),
        scale = 0.5
      }
    }}
	end
end

----------------------------ELECTRONIC-MACHINES--------------------------------

function replaceELECTRONICMACHINES(name,type)
	if data.raw["assembling-machine"][name] then
	data.raw["assembling-machine"][name]["animation"]["layers"] = 
    {    
		{
      filename = ColorTIER_path.."/graphics/high-res/entity/assembling-machine/electric-machine-"..type..".png",
        priority = "high",
        width = 214,
        height = 237,
        frame_count = 32,
        line_length = 8,
        shift = util.by_pixel(0, -0.75),
        scale = 0.34,
      hr_version =
      {
        filename = ColorTIER_path.."/graphics/high-res/entity/assembling-machine/electric-machine-"..type..".png",
        priority = "high",
        width = 214,
        height = 237,
        frame_count = 32,
        line_length = 8,
        shift = util.by_pixel(0, -0.75),
        scale = 0.34
      }
    },
    {
      filename = "__base__/graphics/entity/assembling-machine-3/hr-assembling-machine-3-shadow.png",
        priority = "high",
        width = 260,
        height = 162,
        frame_count = 32,
        line_length = 8,
        draw_as_shadow = true,
        shift = util.by_pixel(28, 4),
        scale = 0.34,
      hr_version =
      {
        filename = "__base__/graphics/entity/assembling-machine-3/hr-assembling-machine-3-shadow.png",
        priority = "high",
        width = 260,
        height = 162,
        frame_count = 32,
        line_length = 8,
        draw_as_shadow = true,
        shift = util.by_pixel(28, 4),
        scale = 0.34
      }
    }}
	end
end

----------------------------------------------------------------------------------------------------------------------

function replaceELECTROLYSERS(name,type)
	if data.raw["assembling-machine"][name] then
	data.raw["assembling-machine"][name]["animation"] = 
	{
      north =
      {
    filename = "__bobplates__/graphics/entity/electrolyser/electro-vt1u.png",
    width = 108,
    height = 130,
    frame_count = 1,
    shift = {0, -0.28125},
		hr_version = 
		{
    filename = ColorTIER_path.."/graphics/high-res/entity/electrolyser/electrolyser-north-"..type..".png",
    width = 216,
    height = 260,
    frame_count = 1,
    shift = {0, -0.28125},
		scale = 0.5
		}
      },
      west =
      {
    filename = "__bobplates__/graphics/entity/electrolyser/electro-h-t1l.png",
    width = 112,
    height = 120,
    frame_count = 1,
    shift = {0, -0.21875},
		hr_version = 
		{
    filename = ColorTIER_path.."/graphics/high-res/entity/electrolyser/electrolyser-west-"..type..".png",
    width = 224,
    height = 240,
    frame_count = 1,
    shift = {0, -0.28125},
		scale = 0.5
		}
      },
      south =
      {
    filename = "__bobplates__/graphics/entity/electrolyser/electro-vt1d.png",
    width = 108,
    height = 130,
    frame_count = 1,
    shift = {0, -0.28125},
		hr_version = 
		{
    filename = ColorTIER_path.."/graphics/high-res/entity/electrolyser/electrolyser-south-"..type..".png",
    width = 216,
    height = 260,
    frame_count = 1,
    shift = {0, -0.28125},
		scale = 0.5
		}
      },
      east =
      {
    filename = "__bobplates__/graphics/entity/electrolyser/electro-h-t1r.png",
    width = 112,
    height = 120,
    frame_count = 1,
    shift = {0, -0.21875},
		hr_version = 
		{
    filename = ColorTIER_path.."/graphics/high-res/entity/electrolyser/electrolyser-east-"..type..".png",
    width = 224,
    height = 240,
    frame_count = 1,
    shift = {0, -0.28125},
		scale = 0.5
      }
    }}
	end
end

----------------------------------------------------------------------------------------------------------------------

function replaceSTEAMENGINES(name,type)
	if data.raw["generator"][name] then
	data.raw["generator"][name]["horizontal_animation"]["layers"] = 
    {
		{
      filename = "__base__/graphics/entity/steam-engine/steam-engine-H.png",
      width = 176,
      height = 128,
      frame_count = 32,
      line_length = 8,
      shift = util.by_pixel(1, -5),
      hr_version =
      {
        filename = ColorTIER_path.."/graphics/high-res/entity/steam-engine/steam-engine-H-"..type..".png",
        width = 352,
        height = 257,
        frame_count = 32,
        line_length = 8,
        shift = util.by_pixel(1, -4.75),
        scale = 0.5
      }
    },
    {
      filename = "__base__/graphics/entity/steam-engine/steam-engine-H-shadow.png",
      width = 254,
      height = 80,
      frame_count = 32,
      line_length = 8,
      draw_as_shadow = true,
      shift = util.by_pixel(48, 24),
      hr_version =
      {
        filename = "__base__/graphics/entity/steam-engine/hr-steam-engine-H-shadow.png",
        width = 508,
        height = 160,
        frame_count = 32,
        line_length = 8,
        draw_as_shadow = true,
        shift = util.by_pixel(48, 24),
        scale = 0.5
      }
		}
	}
	data.raw["generator"][name]["vertical_animation"]["layers"] =
    {
		{
      filename = "__base__/graphics/entity/steam-engine/steam-engine-V.png",
      width = 112,
      height = 195,
      frame_count = 32,
      line_length = 8,
      shift = util.by_pixel(5, -6.5),
      hr_version =
      {
        filename = ColorTIER_path.."/graphics/high-res/entity/steam-engine/steam-engine-V-"..type..".png",
        width = 225,
        height = 391,
        frame_count = 32,
        line_length = 8,
        shift = util.by_pixel(4.75, -6.25),
        scale = 0.5
      }
    },
		{
      filename = "__base__/graphics/entity/steam-engine/steam-engine-V-shadow.png",
      width = 165,
      height = 153,
      frame_count = 32,
      line_length = 8,
      draw_as_shadow = true,
      shift = util.by_pixel(40.5, 9.5),
      hr_version =
      {
        filename = "__base__/graphics/entity/steam-engine/hr-steam-engine-V-shadow.png",
        width = 330,
        height = 307,
        frame_count = 32,
        line_length = 8,
        draw_as_shadow = true,
        shift = util.by_pixel(40.5, 9.25),
        scale = 0.5
      }
		}
	}
	end
end

----------------------------------------------------------------------------------------------------------------------

function replaceSTEAMTURBINES(name,type)
	if data.raw["generator"][name] then
	data.raw["generator"][name]["horizontal_animation"]["layers"] = 
      {
    {
      filename = "__base__/graphics/entity/steam-turbine/steam-turbine-H.png",
      width = 160,
      height = 123,
      frame_count = 8,
      line_length = 4,
      shift = util.by_pixel(0, -2.5),
      hr_version =
      {
        filename = ColorTIER_path.."/graphics/high-res/entity/steam-turbine/steam-turbine-H-"..type..".png",
        width = 320,
        height = 245,
        frame_count = 8,
        line_length = 4,
        shift = util.by_pixel(0, -2.75),
        scale = 0.5
      }
    },
    {
      filename = "__base__/graphics/entity/steam-turbine/steam-turbine-H-shadow.png",
      width = 217,
      height = 74,
      repeat_count = 8,
      frame_count = 1,
      line_length = 1,
      draw_as_shadow = true,
      shift = util.by_pixel(28.75, 18),
      hr_version =
      {
        filename = "__base__/graphics/entity/steam-turbine/hr-steam-turbine-H-shadow.png",
        width = 435,
        height = 150,
        repeat_count = 8,
        frame_count = 1,
        line_length = 1,
        draw_as_shadow = true,
        shift = util.by_pixel(28.5, 18),
        scale = 0.5
      }
    }
	}
	data.raw["generator"][name]["vertical_animation"]["layers"] =
    {
    {
      filename = "__base__/graphics/entity/steam-turbine/steam-turbine-V.png",
      width = 108,
      height = 173,
      frame_count = 8,
      line_length = 4,
      shift = util.by_pixel(5, 6.5),
      hr_version =
      {
        filename = ColorTIER_path.."/graphics/high-res/entity/steam-turbine/steam-turbine-V-"..type..".png",
        width = 217,
        height = 347,
        frame_count = 8,
        line_length = 4,
        shift = util.by_pixel(4.75, 6.75),
        scale = 0.5
      }
    },
    {
      filename = "__base__/graphics/entity/steam-turbine/steam-turbine-V-shadow.png",
      width = 151,
      height = 131,
      repeat_count = 8,
      frame_count = 1,
      line_length = 1,
      draw_as_shadow = true,
      shift = util.by_pixel(39.5, 24.5),
      hr_version =
      {
        filename = "__base__/graphics/entity/steam-turbine/hr-steam-turbine-V-shadow.png",
        width = 302,
        height = 260,
        repeat_count = 8,
        frame_count = 1,
        line_length = 1,
        draw_as_shadow = true,
        shift = util.by_pixel(39.5, 24.5),
        scale = 0.5
      }
    }
	}
	end
end

----------------------------------------------------------------------------------------------------------------------

function replaceBEACONS(name,type)
	if data.raw["beacon"][name] then
	data.raw["beacon"][name]["base_picture"] =
    {
      filename = "__base__/graphics/entity/beacon/beacon-base.png",
      width = 116,
      height = 93,
      shift = { 0.34375, 0.046875},
	  hr_version =
	  {
	  filename = ColorTIER_path.."/graphics/high-res/entity/beacon/beacon-base-"..type..".png",
      width = 232,
      height = 186,
      shift = { 0.34375, 0.046875},
	  scale = 0.5
	  }
    }
    data.raw["beacon"][name]["animation"] =
    {
      filename = "__base__/graphics/entity/beacon/beacon-antenna.png",
      width = 54,
      height = 50,
      line_length = 8,
      frame_count = 32,
      shift = { -0.03125, -1.71875},
      animation_speed = 0.5,
	  hr_version =
	  {
      filename = ColorTIER_path.."/graphics/high-res/entity/beacon/beacon-antenna.png",
      width = 108,
      height = 100,
      line_length = 8,
      frame_count = 32,
      shift = { -0.03125, -1.71875},
      animation_speed = 0.5,
	  scale = 0.5
	  }
    }
    data.raw["beacon"][name]["animation_shadow"] =
    {
      filename = "__base__/graphics/entity/beacon/beacon-antenna-shadow.png",
      width = 63,
      height = 49,
      line_length = 8,
      frame_count = 32,
      shift = { 3.140625, 0.484375},
      animation_speed = 0.5,
	  hr_version =
	  {
      filename = "__base__/graphics/entity/beacon/beacon-antenna-shadow.png",
      width = 63,
      height = 49,
      line_length = 8,
      frame_count = 32,
      shift = { 3.140625, 0.484375},
      animation_speed = 0.5,
	  }
    }
	data.raw["beacon"][name].fast_replaceable_group = "beacon"
	end
end

----------------------------------------------------------------------------------------------------------------------

function replaceSTORAGETANK(name,type)
	if data.raw["storage-tank"][name] then
	data.raw["storage-tank"][name]["pictures"]["picture"]["sheets"] =
    {
      {
        filename = "__base__/graphics/entity/storage-tank/storage-tank.png",
        priority = "extra-high",
        frames = 2,
        width = 110,
        height = 108,
        shift = util.by_pixel(0, 4),
        hr_version =
        {
          filename = ColorTIER_path.."/graphics/high-res/entity/storage-tank/storage-tank-"..type..".png",
          priority = "extra-high",
          frames = 2,
          width = 219,
          height = 215,
          shift = util.by_pixel(-0.25, 3.75),
          scale = 0.5
        }
      },
      {
        filename = "__base__/graphics/entity/storage-tank/storage-tank-shadow.png",
        priority = "extra-high",
        frames = 2,
        width = 146,
        height = 77,
        shift = util.by_pixel(30, 22.5),
        draw_as_shadow = true,
        hr_version =
        {
          filename = "__base__/graphics/entity/storage-tank/hr-storage-tank-shadow.png",
          priority = "extra-high",
          frames = 2,
          width = 291,
          height = 153,
          shift = util.by_pixel(29.75, 22.25),
          scale = 0.5,
          draw_as_shadow = true
        }
      }
    }
	end
end

----------------------------------------------------------------------------------------------------------------------

function replaceBOILERS(name,type)
	if data.raw["boiler"][name] then
	data.raw["boiler"][name]["structure"] = {
      north =
      {
    layers =
    {
      {
        filename = "__base__/graphics/entity/boiler/boiler-N-idle.png",
        priority = "extra-high",
        width = 131,
        height = 108,
        shift = util.by_pixel(-0.5, 4),
        hr_version =
			{
          filename = ColorTIER_path.."/graphics/high-res/entity/boiler/boiler-N-idle-"..type..".png",
          priority = "extra-high",
          width = 269,
          height = 221,
          shift = util.by_pixel(-1.25, 5.25),
          scale = 0.5
        }
      },
      {
        filename = "__base__/graphics/entity/boiler/boiler-N-shadow.png",
        priority = "extra-high",
        width = 137,
        height = 82,
        shift = util.by_pixel(20.5, 9),
        draw_as_shadow = true,
        hr_version =
    {
          filename = "__base__/graphics/entity/boiler/hr-boiler-N-shadow.png",
          priority = "extra-high",
          width = 274,
          height = 164,
          scale = 0.5,
          shift = util.by_pixel(20.5, 9),
          draw_as_shadow = true
        }
      }
    }
      },
      east =
      {
    layers =
    {
      {
        filename = "__base__/graphics/entity/boiler/boiler-E-idle.png",
        priority = "extra-high",
        width = 105,
        height = 147,
        shift = util.by_pixel(-3.5, -0.5),
        hr_version =
    {
          filename = ColorTIER_path.."/graphics/high-res/entity/boiler/boiler-E-idle-"..type..".png",
          priority = "extra-high",
          width = 216,
          height = 301,
          shift = util.by_pixel(-3, 1.25),
          scale = 0.5
        }
      },
      {
        filename = "__base__/graphics/entity/boiler/boiler-E-shadow.png",
        priority = "extra-high",
        width = 92,
        height = 97,
        shift = util.by_pixel(30, 9.5),
        draw_as_shadow = true,
        hr_version =
    {
          filename = "__base__/graphics/entity/boiler/hr-boiler-E-shadow.png",
          priority = "extra-high",
          width = 184,
          height = 194,
          scale = 0.5,
          shift = util.by_pixel(30, 9.5),
          draw_as_shadow = true
        }
      }
    }
      },
      south =
      {
    layers =
    {
      {
        filename = "__base__/graphics/entity/boiler/boiler-S-idle.png",
        priority = "extra-high",
        width = 128,
        height = 95,
        shift = util.by_pixel(3, 12.5),
        hr_version =
    {
          filename = ColorTIER_path.."/graphics/high-res/entity/boiler/boiler-S-idle-"..type..".png",
          priority = "extra-high",
          width = 260,
          height = 192,
          shift = util.by_pixel(4, 13),
          scale = 0.5
        }
      },
      {
        filename = "__base__/graphics/entity/boiler/boiler-S-shadow.png",
        priority = "extra-high",
        width = 156,
        height = 66,
        shift = util.by_pixel(30, 16),
        draw_as_shadow = true,
        hr_version =
    {
          filename = "__base__/graphics/entity/boiler/hr-boiler-S-shadow.png",
          priority = "extra-high",
          width = 311,
          height = 131,
          scale = 0.5,
          shift = util.by_pixel(29.75, 15.75),
          draw_as_shadow = true
        }
      }
    }
      },
      west =
      {
    layers =
    {
      {
        filename = "__base__/graphics/entity/boiler/boiler-W-idle.png",
        priority = "extra-high",
        width = 96,
        height = 132,
        shift = util.by_pixel(1, 5),
        hr_version =
    {
          filename = ColorTIER_path.."/graphics/high-res/entity/boiler/boiler-W-idle-"..type..".png",
          priority = "extra-high",
          width = 196,
          height = 273,
          shift = util.by_pixel(1.5, 7.75),
          scale = 0.5
        }
      },
      {
        filename = "__base__/graphics/entity/boiler/boiler-W-shadow.png",
        priority = "extra-high",
        width = 103,
        height = 109,
        shift = util.by_pixel(19.5, 6.5),
        draw_as_shadow = true,
        hr_version =
    {
          filename = "__base__/graphics/entity/boiler/hr-boiler-W-shadow.png",
          priority = "extra-high",
          width = 206,
          height = 218,
          scale = 0.5,
          shift = util.by_pixel(19.5, 6.5),
          draw_as_shadow = true
        }
      }
    }}}
	end
end

function replaceHEATEXCHANGERS(name,type)
	if data.raw["boiler"][name] then
	data.raw["boiler"][name]["structure"] = {
      north =
      {
    layers =
    {
      {
        filename = "__base__/graphics/entity/heat-exchanger/heatex-N-idle.png",
        priority = "extra-high",
        width = 131,
        height = 108,
        shift = util.by_pixel(-0.5, 4),
        hr_version =
    {
          filename = ColorTIER_path.."/graphics/high-res/entity/heat-exchanger/heatex-N-idle-"..type..".png",
          priority = "extra-high",
          width = 269,
          height = 221,
          shift = util.by_pixel(-1.25, 5.25),
          scale = 0.5
        }
      },
      {
        filename = "__base__/graphics/entity/boiler/boiler-N-shadow.png",
        priority = "extra-high",
        width = 137,
        height = 82,
        shift = util.by_pixel(20.5, 9),
        draw_as_shadow = true,
        hr_version =
    {
          filename = "__base__/graphics/entity/boiler/hr-boiler-N-shadow.png",
          priority = "extra-high",
          width = 274,
          height = 164,
          scale = 0.5,
          shift = util.by_pixel(20.5, 9),
          draw_as_shadow = true
        }
      }
    }
      },
      east =
      {
    layers =
    {
      {
        filename = "__base__/graphics/entity/heat-exchanger/heatex-E-idle.png",
        priority = "extra-high",
        width = 102,
        height = 147,
        shift = util.by_pixel(-2, -0.5),
        hr_version =
    {
          filename = ColorTIER_path.."/graphics/high-res/entity/heat-exchanger/heatex-E-idle-"..type..".png",
          priority = "extra-high",
          width = 211,
          height = 301,
          shift = util.by_pixel(-1.75, 1.25),
          scale = 0.5
        }
      },
      {
        filename = "__base__/graphics/entity/boiler/boiler-E-shadow.png",
        priority = "extra-high",
        width = 92,
        height = 97,
        shift = util.by_pixel(30, 9.5),
        draw_as_shadow = true,
        hr_version =
    {
          filename = "__base__/graphics/entity/boiler/hr-boiler-E-shadow.png",
          priority = "extra-high",
          width = 184,
          height = 194,
          scale = 0.5,
          shift = util.by_pixel(30, 9.5),
          draw_as_shadow = true
        }
      }
    }
      },
      south =
      {
    layers =
    {
      {
        filename = "__base__/graphics/entity/heat-exchanger/heatex-S-idle.png",
        priority = "extra-high",
        width = 128,
        height = 100,
        shift = util.by_pixel(3, 10),
        hr_version =
    {
          filename = ColorTIER_path.."/graphics/high-res/entity/heat-exchanger/heatex-S-idle-"..type..".png",
          priority = "extra-high",
          width = 260,
          height = 201,
          shift = util.by_pixel(4, 10.75),
          scale = 0.5
        }
      },
      {
        filename = "__base__/graphics/entity/boiler/boiler-S-shadow.png",
        priority = "extra-high",
        width = 156,
        height = 66,
        shift = util.by_pixel(30, 16),
        draw_as_shadow = true,
        hr_version =
    {
          filename = "__base__/graphics/entity/boiler/hr-boiler-S-shadow.png",
          priority = "extra-high",
          width = 311,
          height = 131,
          scale = 0.5,
          shift = util.by_pixel(29.75, 15.75),
          draw_as_shadow = true
        }
      }
    }
      },
      west =
      {
    layers =
    {
      {
        filename = "__base__/graphics/entity/heat-exchanger/heatex-W-idle.png",
        priority = "extra-high",
        width = 96,
        height = 132,
        shift = util.by_pixel(1, 5),
        hr_version =
    {
          filename = ColorTIER_path.."/graphics/high-res/entity/heat-exchanger/heatex-W-idle-"..type..".png",
          priority = "extra-high",
          width = 196,
          height = 273,
          shift = util.by_pixel(1.5, 7.75),
          scale = 0.5
        }
      },
      {
        filename = "__base__/graphics/entity/boiler/boiler-W-shadow.png",
        priority = "extra-high",
        width = 103,
        height = 109,
        shift = util.by_pixel(19.5, 6.5),
        draw_as_shadow = true,
        hr_version =
    {
          filename = "__base__/graphics/entity/boiler/hr-boiler-W-shadow.png",
          priority = "extra-high",
          width = 206,
          height = 218,
          scale = 0.5,
          shift = util.by_pixel(19.5, 6.5),
          draw_as_shadow = true
        }
      }
    }}}
	end
end

----------------------------------------------------------------------------------------------------------------------

function replaceMEDIUMPOLES(name,type)
	if data.raw["electric-pole"][name] then
	data.raw["electric-pole"][name]["pictures"]["layers"] =
      {
        {
          filename = "__base__/graphics/entity/medium-electric-pole/medium-electric-pole.png",
          priority = "extra-high",
          width = 40,
          height = 124,
          direction_count = 4,
          shift = util.by_pixel(4, -44),
          hr_version =
          {
            filename = ColorTIER_path.."/graphics/high-res/entity/medium-electric-pole/medium-electric-pole-"..type..".png",
            priority = "extra-high",
            width = 84,
            height = 252,
            direction_count = 4,
            shift = util.by_pixel(3.5, -44),
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/medium-electric-pole/medium-electric-pole-shadow.png",
          priority = "extra-high",
          width = 140,
          height = 32,
          direction_count = 4,
          shift = util.by_pixel(56, -1),
          draw_as_shadow = true,
          hr_version =
          {
            filename = "__base__/graphics/entity/medium-electric-pole/hr-medium-electric-pole-shadow.png",
            priority = "extra-high",
            width = 280,
            height = 64,
            direction_count = 4,
            shift = util.by_pixel(56.5, -1),
            draw_as_shadow = true,
            scale = 0.5
          }
        }
      }
	end
end

----------------------------------------------------------------------------------------------------------------------

function replaceBIGPOLES(name,type)
	if data.raw["electric-pole"][name] then
	data.raw["electric-pole"][name]["pictures"]["layers"] =
      {
        {
          filename = "__base__/graphics/entity/big-electric-pole/big-electric-pole.png",
          priority = "extra-high",
          width = 76,
          height = 156,
          direction_count = 4,
          shift = util.by_pixel(1, -51),
          hr_version =
          {
            filename = ColorTIER_path.."/graphics/high-res/entity/big-electric-pole/big-electric-pole-"..type..".png",
            priority = "extra-high",
            width = 148,
            height = 312,
            direction_count = 4,
            shift = util.by_pixel(0, -51),
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/big-electric-pole/big-electric-pole-shadow.png",
          priority = "extra-high",
          width = 188,
          height = 48,
          direction_count = 4,
          shift = util.by_pixel(60, 0),
          draw_as_shadow = true,
          hr_version =
          {
            filename = "__base__/graphics/entity/big-electric-pole/hr-big-electric-pole-shadow.png",
            priority = "extra-high",
            width = 374,
            height = 94,
            direction_count = 4,
            shift = util.by_pixel(60, 0),
            draw_as_shadow = true,
            scale = 0.5
          }
        }
      }
	end
end

----------------------------------------------------------------------------------------------------------------------

function replaceSUBSTATIONS(name,type)
	if data.raw["electric-pole"][name] then
	data.raw["electric-pole"][name]["pictures"]["layers"] =
      {
        {
          filename = "__base__/graphics/entity/substation/substation.png",
          priority = "high",
          width = 70,
          height = 136,
          direction_count = 4,
          shift = util.by_pixel(0, 1-32),
          hr_version =
          {
            filename = ColorTIER_path.."/graphics/high-res/entity/substation/substation-"..type..".png",
            priority = "high",
            width = 138,
            height = 270,
            direction_count = 4,
            shift = util.by_pixel(0, 1-32),
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/substation/substation-shadow.png",
          priority = "high",
          width = 186,
          height = 52,
          direction_count = 4,
          shift = util.by_pixel(62, 42-32),
          draw_as_shadow = true,
          hr_version =
          {
            filename = "__base__/graphics/entity/substation/hr-substation-shadow.png",
            priority = "high",
            width = 370,
            height = 104,
            direction_count = 4,
            shift = util.by_pixel(62, 42-32),
            draw_as_shadow = true,
            scale = 0.5
          }
        }
      }
	end
end

----------------------------------------------------------------------------------------------------------------------

function replacePUMPS(name,type)
	if data.raw["pump"][name] then
	data.raw["pump"][name]["animations"] =
    {
      north =
      {
        filename = "__base__/graphics/entity/pump/pump-north.png",
        width = 53,
        height = 79,
        line_length =8,
        frame_count =32,
        animation_speed = 0.5,
        shift = util.by_pixel(8.000, 7.500),
        hr_version =
        {
          filename = ColorTIER_path.."/graphics/high-res/entity/pump/pump-north-"..type..".png",
          width = 103,
          height = 164,
          scale = 0.5,
          line_length =8,
          frame_count =32,
          animation_speed = 0.5,
          shift = util.by_pixel(8, 3.5) -- {0.515625, 0.21875}
        }
      },
      east =
      {
        filename = "__base__/graphics/entity/pump/pump-east.png",
        width = 66,
        height = 60,
        line_length =8,
        frame_count =32,
        animation_speed = 0.5,
        shift = util.by_pixel(0, 4),
        hr_version =
        {
          filename = ColorTIER_path.."/graphics/high-res/entity/pump/pump-east-"..type..".png",
          width = 130,
          height = 109,
          scale = 0.5,
          line_length =8,
          frame_count =32,
          animation_speed = 0.5,
          shift = util.by_pixel(-0.5, 1.75) --{-0.03125, 0.109375}
        }
      },
      south =
      {
        filename = "__base__/graphics/entity/pump/pump-south.png",
        width = 62,
        height = 87,
        line_length =8,
        frame_count =32,
        animation_speed = 0.5,
        shift = util.by_pixel(13.5, 0.5),
        hr_version =
        {
          filename = ColorTIER_path.."/graphics/high-res/entity/pump/pump-south-"..type..".png",
          width = 114,
          height = 160,
          scale = 0.5,
          line_length =8,
          frame_count =32,
          animation_speed = 0.5,
          shift = util.by_pixel(12.5, -8) -- {0.75, -0.5}
        }
      },
      west =
      {
        filename = "__base__/graphics/entity/pump/pump-west.png",
        width = 69,
        height = 51,
        line_length =8,
        frame_count =32,
        animation_speed = 0.5,
        shift = util.by_pixel(0.5, -0.5),
        hr_version =
        {
          filename = ColorTIER_path.."/graphics/high-res/entity/pump/pump-west-"..type..".png",
          width = 131,
          height = 111,
          scale = 0.5,
          line_length =8,
          frame_count =32,
          animation_speed = 0.5,
          shift = util.by_pixel(-0.25, 1.25) -- {-0.015625, 0.078125}
        }
      }
    }
	end
end



function replaceAIRPUMPS(name,type)
	if data.raw["assembling-machine"][name] then
	data.raw["assembling-machine"][name]["animation"] =
    {
      north =
      {
        filename = "__bobplates__/graphics/entity/pump/pump.png",
        width = 80,
        height = 80,
        frame_count = 8,
        animation_speed = 0.5,
		hr_version =
        {
        filename = ColorTIER_path.."/graphics/high-res/entity/airpump/airpump-"..type..".png",
        width = 160,
        height = 160,
        frame_count = 8,
        animation_speed = 0.5,
		scale = 0.5
		}
      },
      east =
      {
        filename = "__bobplates__/graphics/entity/pump/pump.png",
        y = 80,
        width = 80,
        height = 80,
        frame_count = 8,
        animation_speed = 0.5,
		hr_version =
        {
        filename = ColorTIER_path.."/graphics/high-res/entity/airpump/airpump-"..type..".png",
        y = 160,
        width = 160,
        height = 160,
        frame_count = 8,
        animation_speed = 0.5,
		scale = 0.5
		}
      },
      south =
      {
        filename = "__bobplates__/graphics/entity/pump/pump.png",
        y = 160,
        width = 80,
        height = 80,
        frame_count = 8,
        animation_speed = 0.5,
		hr_version =
        {
        filename = ColorTIER_path.."/graphics/high-res/entity/airpump/airpump-"..type..".png",
        y = 320,
        width = 160,
        height = 160,
        frame_count = 8,
        animation_speed = 0.5,
		scale = 0.5
		}
      },
      west =
      {
        filename = "__bobplates__/graphics/entity/pump/pump.png",
        y = 240,
        width = 80,
        height = 80,
        frame_count = 8,
        animation_speed = 0.5,
		hr_version =
        {
        filename = ColorTIER_path.."/graphics/high-res/entity/airpump/airpump-"..type..".png",
        y = 480,
        width = 160,
        height = 160,
        frame_count = 8,
        animation_speed = 0.5,
		scale = 0.5
		}
      }
    }
	end
end

----------------------------------------------------------------------------------------------------------------------

function replaceOILREFINERIES(name,type)
	if data.raw["assembling-machine"][name] then
	data.raw["assembling-machine"][name]["animation"] = make_4way_animation_from_spritesheet({ layers =
    {
      {
        filename = "__base__/graphics/entity/oil-refinery/oil-refinery.png",
        width = 337,
        height = 255,
        frame_count = 1,
        shift = {2.515625, 0.484375},
        hr_version =
        {
          filename = ColorTIER_path.."/graphics/high-res/entity/oil-refinery/oil-refinery-"..type..".png",
          width = 386,
          height = 430,
          frame_count = 1,
          shift = util.by_pixel(0, -7.5),
          scale = 0.5
        }
      },
      {
        filename = "__base__/graphics/entity/oil-refinery/oil-refinery-shadow.png",
        width = 337,
        height = 213,
        frame_count = 1,
        shift = util.by_pixel(82.5, 26.5),
        draw_as_shadow = true,
        hr_version =
        {
          filename = "__base__/graphics/entity/oil-refinery/hr-oil-refinery-shadow.png",
          width = 674,
          height = 426,
          frame_count = 1,
          shift = util.by_pixel(82.5, 26.5),
          draw_as_shadow = true,
          scale = 0.5
        }
      }
    }})
	end
end

----------------------------------------------------------------------------------------------------------------------

function replaceCHEMICALPLANT(name,type)
	if data.raw["assembling-machine"][name] then
	data.raw["assembling-machine"][name]["animation"] = make_4way_animation_from_spritesheet({ layers =
    {
      {
        filename = "__base__/graphics/entity/chemical-plant/chemical-plant.png",
        width = 122,
        height = 134,
        frame_count = 1,
        shift = util.by_pixel(-5, -4.5),
        hr_version =
        {
          filename = ColorTIER_path.."/graphics/high-res/entity/chemical-plant/chemical-plant-"..type..".png",
          width = 244,
          height = 268,
          frame_count = 1,
          shift = util.by_pixel(-5, -4.5),
          scale = 0.5
          }
      },
      {
        filename = "__base__/graphics/entity/chemical-plant/chemical-plant-shadow.png",
        width = 175,
        height = 141,
        frame_count = 1,
        shift = util.by_pixel(31.5, 11),
        draw_as_shadow = true,
        hr_version =
        {
          filename = "__base__/graphics/entity/chemical-plant/hr-chemical-plant-shadow.png",
          width = 350,
          height = 219,
          frame_count = 1,
          shift = util.by_pixel(31.5, 10.75),
          draw_as_shadow = true,
          scale = 0.5
          }
      }
    }})
	end
end

----------------------------------------------------------------------------------------------------------------------

function replaceARTILLERYTURRET(name,type)
	if data.raw["artillery-turret"][name] then
	data.raw["artillery-turret"][name]["base_picture"]["layers"] =
      {
        {
          filename = "__base__/graphics/entity/artillery-turret/artillery-turret-base.png",
          priority = "high",
          width = 104,
          height = 100,
          direction_count = 1,
          frame_count = 1,
          shift = util.by_pixel(-0, 22),
          hr_version =
          {
            filename = ColorTIER_path.."/graphics/high-res/entity/artillery-turret/artillery-turret-base-"..type..".png",
            line_length = 1,
            width = 207,
            height = 199,
            frame_count = 1,
            direction_count = 1,
            shift = util.by_pixel(-0, 22),
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/artillery-turret/artillery-turret-base-shadow.png",
          priority = "high",
          line_length = 1,
          width = 138,
          height = 75,
          frame_count = 1,
          direction_count = 1,
          shift = util.by_pixel(18, 38),
          draw_as_shadow = true,
          hr_version =
          {
            filename = "__base__/graphics/entity/artillery-turret/hr-artillery-turret-base-shadow.png",
            priority = "high",
            line_length = 1,
            width = 277,
            height = 149,
            frame_count = 1,
            direction_count = 1,
            shift = util.by_pixel(18, 38),
            draw_as_shadow = true,
            scale = 0.5
          }
        }}
	end
end

----------------------------------------------------------------------------------------------------------------------

function replaceROBOPORTS(name,type)
	if data.raw["roboport"][name] then
	data.raw["roboport"][name]["base"]["layers"] =
      {
        {
          filename = "__base__/graphics/entity/roboport/roboport-base.png",
          width = 143,
          height = 135,
          shift = {0.5, 0.25},
          hr_version =
          {
            filename = ColorTIER_path.."/graphics/high-res/entity/roboport/roboport-base-"..type..".png",
            width = 228,
            height = 277,
            shift = util.by_pixel(2, 7.75),
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/roboport/roboport-shadow.png",
          width = 147,
          height = 101,
          draw_as_shadow = true,
          shift = util.by_pixel(28.5, 19.25),
          hr_version =
          {
            filename = "__base__/graphics/entity/roboport/hr-roboport-shadow.png",
            width = 294,
            height = 201,
            draw_as_shadow = true,
            shift = util.by_pixel(28.5, 19.25),
            scale = 0.5
          }
        }
      }
	data.raw["roboport"][name]["base_patch"] =
    {
      filename = "__base__/graphics/entity/roboport/roboport-base-patch.png",
      priority = "medium",
      width = 69,
      height = 50,
      frame_count = 1,
      shift = {0.03125, 0.203125},
      hr_version =
      {
        filename = "__base__/graphics/entity/roboport/hr-roboport-base-patch.png",
        priority = "medium",
        width = 138,
        height = 100,
        frame_count = 1,
        shift = util.by_pixel(1.5, 5),
        scale = 0.5
      }
	}
	data.raw["roboport"][name]["base_patch"] =
    {
      filename = "__base__/graphics/entity/roboport/roboport-base-patch.png",
      priority = "medium",
      width = 69,
      height = 50,
      frame_count = 1,
      shift = {0.03125, 0.203125},
      hr_version =
      {
        filename = ColorTIER_path.."/graphics/high-res/entity/roboport/roboport-base-patch-"..type..".png",
        priority = "medium",
        width = 138,
        height = 100,
        frame_count = 1,
        shift = util.by_pixel(1.5, 5),
        scale = 0.5
      }
	}
	data.raw["roboport"][name]["base_animation"] =
    {
      filename = "__base__/graphics/entity/roboport/roboport-base-animation.png",
      priority = "medium",
      width = 42,
      height = 31,
      frame_count = 8,
      animation_speed = 0.5,
      shift = {-0.5315, -1.9375},
      hr_version =
      {
        filename = ColorTIER_path.."/graphics/high-res/entity/roboport/roboport-base-animation-"..type..".png",
        priority = "medium",
        width = 83,
        height = 59,
        frame_count = 8,
        animation_speed = 0.5,
        shift = util.by_pixel(-17.75, -61.25),
        scale = 0.5
      }
    }
    data.raw["roboport"][name]["door_animation_up"] =
    {
      filename = "__base__/graphics/entity/roboport/roboport-door-up.png",
      priority = "medium",
      width = 52,
      height = 20,
      frame_count = 16,
      shift = {0.015625, -0.890625},
      hr_version =
      {
        filename = ColorTIER_path.."/graphics/high-res/entity/roboport/roboport-door-up.png",
        priority = "medium",
        width = 97,
        height = 38,
        frame_count = 16,
        shift = util.by_pixel(-0.25, -29.5),
        scale = 0.5
      }
    }
    data.raw["roboport"][name]["door_animation_down"] =
    {
      filename = "__base__/graphics/entity/roboport/roboport-door-down.png",
      priority = "medium",
      width = 52,
      height = 22,
      frame_count = 16,
      shift = {0.015625, -0.234375},
      hr_version =
      {
        filename = ColorTIER_path.."/graphics/high-res/entity/roboport/roboport-door-down.png",
        priority = "medium",
        width = 97,
        height = 41,
        frame_count = 16,
        shift = util.by_pixel(-0.25,-9.75),
        scale = 0.5
      }
    }
    data.raw["roboport"][name]["recharging_animation "]=
    {
      filename = "__base__/graphics/entity/roboport/roboport-recharging.png",
      priority = "high",
      width = 37,
      height = 35,
      frame_count = 16,
      scale = 1.5,
      animation_speed = 0.5
    }
	end
end

function replaceROBOPORTSEXPANDER(name,type)
	if data.raw["roboport"][name] then
	data.raw["roboport"][name]["base"]["layers"] =
    {
      {
      filename = "__boblogistics__/graphics/entity/roboport/logistic-zone-expander-2.png",
      width = 136,
      height = 132,
      shift = {1, -0.75},
      hr_version =
		{
        filename = ColorTIER_path.."/graphics/high-res/entity/roboport/TowerH-"..type..".png",
        width = 272,
        height = 264,
        shift = {0.89, -0.75},
        scale = 0.5
		}
      },
      {
      filename = "__base__/graphics/entity/roboport/roboport-shadow.png",
      width = 147,
      height = 101,
      draw_as_shadow = true,
      shift = util.by_pixel(28.5, 19.25),
      hr_version =
        {
        filename = ColorTIER_path.."/graphics/high-res/entity/roboport/TowerH_shadow.png",
        width = 272,
        height = 264,
        draw_as_shadow = true,
        shift = {0.89, -0.75},
        scale = 0.5
		}
      }
    }
	data.raw["roboport"][name]["base_animation"] =
    {
      filename = "__boblogistics__/graphics/entity/roboport/roboport-chargepad.png",
      priority = "medium",
      width = 32,
      height = 32,
      frame_count = 6,
      shift = {0, -2.28125},
      animation_speed = type/10,
      hr_version =
		{
        filename = ColorTIER_path.."/graphics/high-res/entity/roboport/roboport-chargepad-"..type..".png",
        priority = "medium",
        width = 67,
        height = 64,
        frame_count = 6,
        shift = {0, -2.28125},
        animation_speed = type/10,
		scale = 0.5
		}
    }
	data.raw["roboport"][name]["base_patch"] =
    {
      filename = "__boblogistics__/graphics/entity/roboport/blank.png",
      width = 1,
      height = 1,
      frame_count = 1,
    }
    data.raw["roboport"][name]["door_animation_up"] =
    {
      filename = "__boblogistics__/graphics/entity/roboport/blank.png",
      width = 1,
      height = 1,
      frame_count = 1,
    }
    data.raw["roboport"][name]["door_animation_down"] =
    {
      filename = "__boblogistics__/graphics/entity/roboport/blank.png",
      width = 1,
      height = 1,
      frame_count = 1,
    }
    data.raw["roboport"][name]["recharging_animation "]=
    {
      filename = "__boblogistics__/graphics/entity/roboport/roboport-recharging.png",
      priority = "high",
      width = 37,
      height = 35,
      frame_count = 16,
      scale = 1.5,
      animation_speed = 0.5
    }
	end
end

function replaceROBOCHARGER(name,type)
	if data.raw["roboport"][name] then
	data.raw["roboport"][name]["base"] =
    {
      filename = "__boblogistics__/graphics/entity/roboport/blank.png",
      width = 1,
      height = 1,
    }
	data.raw["roboport"][name]["base_animation"]["layers"] =
	{
	  {
      filename = "__boblogistics__/graphics/entity/roboport/roboport-chargepad.png",
      priority = "medium",
      width = 32,
      height = 32,
      frame_count = 6,
      shift = {-0.5, -0.5},
      animation_speed = type/10,
      hr_version =
		{
        filename = ColorTIER_path.."/graphics/high-res/entity/roboport/roboport-chargepad-"..type..".png",
        priority = "medium",
        width = 67,
        height = 64,
        frame_count = 6,
        shift = {-0.5, -0.5},
        animation_speed = type/10,
		scale = 0.5
		}
	  },
	  {
      filename = "__boblogistics__/graphics/entity/roboport/roboport-chargepad.png",
      priority = "medium",
      width = 32,
      height = 32,
      frame_count = 6,
      shift = {0.5, -0.5},
      animation_speed = type/10,
      hr_version =
		{
        filename = ColorTIER_path.."/graphics/high-res/entity/roboport/roboport-chargepad-"..type..".png",
        priority = "medium",
        width = 67,
        height = 64,
        frame_count = 6,
        shift = {0.5, -0.5},
        animation_speed = type/10,
		scale = 0.5
		}
	  },
	  {
      filename = "__boblogistics__/graphics/entity/roboport/roboport-chargepad.png",
      priority = "medium",
      width = 32,
      height = 32,
      frame_count = 6,
      shift = {-0.5, 0.5},
      animation_speed = type/10,
      hr_version =
		{
        filename = ColorTIER_path.."/graphics/high-res/entity/roboport/roboport-chargepad-"..type..".png",
        priority = "medium",
        width = 67,
        height = 64,
        frame_count = 6,
        shift = {-0.5, 0.5},
        animation_speed = type/10,
		scale = 0.5
		}
	  },
	  {
      filename = "__boblogistics__/graphics/entity/roboport/roboport-chargepad.png",
      priority = "medium",
      width = 32,
      height = 32,
      frame_count = 6,
      shift = {0.5, 0.5},
      animation_speed = type/10,
      hr_version =
		{
        filename = ColorTIER_path.."/graphics/high-res/entity/roboport/roboport-chargepad-"..type..".png",
        priority = "medium",
        width = 67,
        height = 64,
        frame_count = 6,
        shift = {0.5, 0.5},
        animation_speed = type/10,
		scale = 0.5
		}
	  }
	}
	data.raw["roboport"][name]["base_patch"] =
    {
      filename = "__boblogistics__/graphics/entity/roboport/blank.png",
      width = 1,
      height = 1,
      frame_count = 1,
    }
    data.raw["roboport"][name]["door_animation_up"] =
    {
      filename = "__boblogistics__/graphics/entity/roboport/blank.png",
      width = 1,
      height = 1,
      frame_count = 1,
    }
    data.raw["roboport"][name]["door_animation_down"] =
    {
      filename = "__boblogistics__/graphics/entity/roboport/blank.png",
      width = 1,
      height = 1,
      frame_count = 1,
    }
    data.raw["roboport"][name]["recharging_animation "]=
    {
      filename = "__boblogistics__/graphics/entity/roboport/roboport-recharging.png",
      priority = "high",
      width = 37,
      height = 35,
      frame_count = 16,
      scale = 1.5,
      animation_speed = 0.5
    }
	end
end

function replaceLARGEROBOCHARGER(name,type)
	if data.raw["roboport"][name] then
	data.raw["roboport"][name]["base"] =
    {
      filename = "__boblogistics__/graphics/entity/roboport/blank.png",
      width = 1,
      height = 1,
    }
	data.raw["roboport"][name]["base_animation"]["layers"] =
	{
	  {
      filename = "__boblogistics__/graphics/entity/roboport/roboport-chargepad.png",
      priority = "medium",
      width = 32,
      height = 32,
      frame_count = 6,
      shift = {-1, 1},
      animation_speed = type/10,
      hr_version =
		{
        filename = ColorTIER_path.."/graphics/high-res/entity/roboport/roboport-chargepad-"..type..".png",
        priority = "medium",
        width = 67,
        height = 64,
        frame_count = 6,
        shift = {-1, 1},
        animation_speed = type/10,
		scale = 0.5
		}
	  },
	  {
      filename = "__boblogistics__/graphics/entity/roboport/roboport-chargepad.png",
      priority = "medium",
      width = 32,
      height = 32,
      frame_count = 6,
      shift = {0, 1},
      animation_speed = type/10,
      hr_version =
		{
        filename = ColorTIER_path.."/graphics/high-res/entity/roboport/roboport-chargepad-"..type..".png",
        priority = "medium",
        width = 67,
        height = 64,
        frame_count = 6,
        shift = {0, 1},
        animation_speed = type/10,
		scale = 0.5
		}
	  },
	  {
      filename = "__boblogistics__/graphics/entity/roboport/roboport-chargepad.png",
      priority = "medium",
      width = 32,
      height = 32,
      frame_count = 6,
      shift = {1, 1},
      animation_speed = type/10,
      hr_version =
		{
        filename = ColorTIER_path.."/graphics/high-res/entity/roboport/roboport-chargepad-"..type..".png",
        priority = "medium",
        width = 67,
        height = 64,
        frame_count = 6,
        shift = {1, 1},
        animation_speed = type/10,
		scale = 0.5
		}
	  },
	  {
      filename = "__boblogistics__/graphics/entity/roboport/roboport-chargepad.png",
      priority = "medium",
      width = 32,
      height = 32,
      frame_count = 6,
      shift = {-1, 0},
      animation_speed = type/10,
      hr_version =
		{
        filename = ColorTIER_path.."/graphics/high-res/entity/roboport/roboport-chargepad-"..type..".png",
        priority = "medium",
        width = 67,
        height = 64,
        frame_count = 6,
        shift = {-1, 0},
        animation_speed = type/10,
		scale = 0.5
		}
	  },
	  {
      filename = "__boblogistics__/graphics/entity/roboport/roboport-chargepad.png",
      priority = "medium",
      width = 32,
      height = 32,
      frame_count = 6,
      shift = {0, 0},
      animation_speed = type/10,
      hr_version =
		{
        filename = ColorTIER_path.."/graphics/high-res/entity/roboport/roboport-chargepad-"..type..".png",
        priority = "medium",
        width = 67,
        height = 64,
        frame_count = 6,
        shift = {0, 0},
        animation_speed = type/10,
		scale = 0.5
		}
	  },
	  {
      filename = "__boblogistics__/graphics/entity/roboport/roboport-chargepad.png",
      priority = "medium",
      width = 32,
      height = 32,
      frame_count = 6,
      shift = {1, 0},
      animation_speed = type/10,
      hr_version =
		{
        filename = ColorTIER_path.."/graphics/high-res/entity/roboport/roboport-chargepad-"..type..".png",
        priority = "medium",
        width = 67,
        height = 64,
        frame_count = 6,
        shift = {1, 0},
        animation_speed = type/10,
		scale = 0.5
		}
	  },
	  {
      filename = "__boblogistics__/graphics/entity/roboport/roboport-chargepad.png",
      priority = "medium",
      width = 32,
      height = 32,
      frame_count = 6,
      shift = {-1, -1},
      animation_speed = type/10,
      hr_version =
		{
        filename = ColorTIER_path.."/graphics/high-res/entity/roboport/roboport-chargepad-"..type..".png",
        priority = "medium",
        width = 67,
        height = 64,
        frame_count = 6,
        shift = {-1, -1},
        animation_speed = type/10,
		scale = 0.5
		}
	  },
	  {
      filename = "__boblogistics__/graphics/entity/roboport/roboport-chargepad.png",
      priority = "medium",
      width = 32,
      height = 32,
      frame_count = 6,
      shift = {-1, -1},
      animation_speed = type/10,
      hr_version =
		{
        filename = ColorTIER_path.."/graphics/high-res/entity/roboport/roboport-chargepad-"..type..".png",
        priority = "medium",
        width = 67,
        height = 64,
        frame_count = 6,
        shift = {0, -1},
        animation_speed = type/10,
		scale = 0.5
		}
	  },
	  {
      filename = "__boblogistics__/graphics/entity/roboport/roboport-chargepad.png",
      priority = "medium",
      width = 32,
      height = 32,
      frame_count = 6,
      shift = {-1, -1},
      animation_speed = type/10,
      hr_version =
		{
        filename = ColorTIER_path.."/graphics/high-res/entity/roboport/roboport-chargepad-"..type..".png",
        priority = "medium",
        width = 67,
        height = 64,
        frame_count = 6,
        shift = {1, -1},
        animation_speed = type/10,
		scale = 0.5
		}
      }
	}
	data.raw["roboport"][name]["base_patch"] =
    {
      filename = "__boblogistics__/graphics/entity/roboport/blank.png",
      width = 1,
      height = 1,
      frame_count = 1,
    }
    data.raw["roboport"][name]["door_animation_up"] =
    {
      filename = "__boblogistics__/graphics/entity/roboport/blank.png",
      width = 1,
      height = 1,
      frame_count = 1,
    }
    data.raw["roboport"][name]["door_animation_down"] =
    {
      filename = "__boblogistics__/graphics/entity/roboport/blank.png",
      width = 1,
      height = 1,
      frame_count = 1,
    }
    data.raw["roboport"][name]["recharging_animation "]=
    {
      filename = "__boblogistics__/graphics/entity/roboport/roboport-recharging.png",
      priority = "high",
      width = 37,
      height = 35,
      frame_count = 16,
      scale = 1.5,
      animation_speed = 0.5
    }
	end
end

----------------------------------------------------------------------------------------------------------------------

function replaceSTONEFURNACE(name)
	if data.raw["furnace"][name] then
	data.raw["furnace"][name]["animation"]["layers"] =
      {
        {
          filename = "__base__/graphics/entity/stone-furnace/stone-furnace.png",
          priority = "extra-high",
          width = 81,
          height = 64,
          frame_count = 1,
          shift = util.by_pixel(14.5, 2),
          hr_version =
          {
            filename = ColorTIER_path.."/graphics/high-res/entity/stone-furnace/stone-furnace.png",
            priority = "extra-high",
            width = 151,
            height = 146,
            frame_count = 1,
            shift = util.by_pixel(-0.25, 6),
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/stone-furnace/stone-furnace-shadow.png",
          priority = "extra-high",
          width = 81,
          height = 64,
          frame_count = 1,
          draw_as_shadow = true,
          shift = util.by_pixel(14.5, 2),
          hr_version =
          {
            filename = "__base__/graphics/entity/stone-furnace/hr-stone-furnace-shadow.png",
            priority = "extra-high",
            width = 164,
            height = 74,
            frame_count = 1,
            draw_as_shadow = true,
            shift = util.by_pixel(14.5, 13),
            scale = 0.5
          }
        }
      }
	end
end

function replaceSTEELFURNACE(name)
	if data.raw["furnace"][name] then
	data.raw["furnace"][name]["animation"]["layers"] =
	  {
        {
          filename = "__base__/graphics/entity/steel-furnace/steel-furnace.png",
          priority = "high",
          width = 85,
          height = 87,
          frame_count = 1,
          shift = util.by_pixel(-1.5, 1.5),
          hr_version =
          {
            filename = ColorTIER_path.."/graphics/high-res/entity/steel-furnace/steel-furnace.png",
            priority = "high",
            width = 171,
            height = 174,
            frame_count = 1,
            shift = util.by_pixel(-1.25, 2),
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/steel-furnace/steel-furnace-shadow.png",
          priority = "high",
          width = 139,
          height = 43,
          frame_count = 1,
          draw_as_shadow = true,
          shift = util.by_pixel(39.5, 11.5),
          hr_version =
          {
            filename = "__base__/graphics/entity/steel-furnace/hr-steel-furnace-shadow.png",
            priority = "high",
            width = 277,
            height = 85,
            frame_count = 1,
            draw_as_shadow = true,
            shift = util.by_pixel(39.25, 11.25),
            scale = 0.5
          }
        }
      }
	end
end

function replaceMIXINGSTONEFURNACE(name)
	if data.raw["assembling-machine"][name] then
	data.raw["assembling-machine"][name]["animation"]["layers"] =
      {
        {
          filename = "__base__/graphics/entity/stone-furnace/stone-furnace.png",
          priority = "extra-high",
          width = 81,
          height = 64,
          frame_count = 1,
          shift = util.by_pixel(14.5, 2),
          hr_version =
          {
            filename = ColorTIER_path.."/graphics/high-res/entity/stone-furnace/mixing-stone-furnace.png",
            priority = "extra-high",
            width = 151,
            height = 146,
            frame_count = 1,
            shift = util.by_pixel(-0.25, 6),
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/stone-furnace/stone-furnace-shadow.png",
          priority = "extra-high",
          width = 81,
          height = 64,
          frame_count = 1,
          draw_as_shadow = true,
          shift = util.by_pixel(14.5, 2),
          hr_version =
          {
            filename = "__base__/graphics/entity/stone-furnace/hr-stone-furnace-shadow.png",
            priority = "extra-high",
            width = 164,
            height = 74,
            frame_count = 1,
            draw_as_shadow = true,
            shift = util.by_pixel(14.5, 13),
            scale = 0.5
          }
        }
	   }
	end
end

function replaceASTEELFURNACE(name, picture)
	if data.raw["assembling-machine"][name] then
	data.raw["assembling-machine"][name]["animation"]["layers"] =
    {
		{
          filename = "__base__/graphics/entity/steel-furnace/steel-furnace.png",
          priority = "high",
          width = 85,
          height = 87,
          frame_count = 1,
          shift = util.by_pixel(-1.5, 1.5),
          hr_version = 
		  {
            filename = ColorTIER_path.."/graphics/high-res/entity/steel-furnace/"..picture..".png",
            priority = "high",
            width = 171,
            height = 174,
            frame_count = 1,
            shift = util.by_pixel(-1.25, 2),
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/steel-furnace/steel-furnace-shadow.png",
          priority = "high",
          width = 139,
          height = 43,
          frame_count = 1,
          draw_as_shadow = true,
          shift = util.by_pixel(39.5, 11.5),
          hr_version = {
            filename = "__base__/graphics/entity/steel-furnace/hr-steel-furnace-shadow.png",
            priority = "high",
            width = 277,
            height = 85,
            frame_count = 1,
            draw_as_shadow = true,
            shift = util.by_pixel(39.25, 11.25),
            scale = 0.5
          }
        }
	}
	end
end

function replaceCHEMICALSTONEFURNACE(name)
	if data.raw["assembling-machine"][name] then
	data.raw["assembling-machine"][name]["animation"] =
    {
      north =
      {
        filename = "__bobplates__/graphics/entity/stone-chemical-furnace/stone-chemical-furnace.png",
        priority = "extra-high",
        width = 94,
        height = 80,
        frame_count = 1,
        shift = {0.25, 0 },
		hr_version =
		{
			filename = ColorTIER_path.."/graphics/high-res/entity/stone-furnace/stone-chemical-furnace.png",
			priority = "extra-high",
			width = 188,
			height = 160,
			frame_count = 1,
			shift = {0.25, 0 },
			scale = 0.5
		},
        {
          filename = "__base__/graphics/entity/stone-furnace/stone-furnace-shadow.png",
          priority = "extra-high",
          width = 81,
          height = 64,
          frame_count = 1,
          draw_as_shadow = true,
          shift = util.by_pixel(14.5, 2),
          hr_version =
          {
            filename = "__base__/graphics/entity/stone-furnace/hr-stone-furnace-shadow.png",
            priority = "extra-high",
            width = 164,
            height = 74,
            frame_count = 1,
            draw_as_shadow = true,
            shift = util.by_pixel(14.5, 13),
            scale = 0.5
          }
        }
      },
      west =
      {
        filename = "__bobplates__/graphics/entity/stone-chemical-furnace/stone-chemical-furnace.png",
        x = 94,
        priority = "extra-high",
        width = 94,
        height = 80,
        frame_count = 1,
        shift = {0.25, 0 },
		hr_version =
		{
			filename = ColorTIER_path.."/graphics/high-res/entity/stone-furnace/stone-chemical-furnace.png",
			x = 188,
			priority = "extra-high",
			width = 188,
			height = 160,
			frame_count = 1,
			shift = {0.25, 0 },
			scale = 0.5
		},
        {
          filename = "__base__/graphics/entity/stone-furnace/stone-furnace-shadow.png",
          priority = "extra-high",
          width = 81,
          height = 64,
          frame_count = 1,
          draw_as_shadow = true,
          shift = util.by_pixel(14.5, 2),
          hr_version =
          {
            filename = "__base__/graphics/entity/stone-furnace/hr-stone-furnace-shadow.png",
            priority = "extra-high",
            width = 164,
            height = 74,
            frame_count = 1,
            draw_as_shadow = true,
            shift = util.by_pixel(14.5, 13),
            scale = 0.5
          }
        }
      },
      south =
      {
        x = 188,
        filename = "__bobplates__/graphics/entity/stone-chemical-furnace/stone-chemical-furnace.png",
        priority = "extra-high",
        width = 94,
        height = 80,
        frame_count = 1,
        shift = {0.25, 0 },
		hr_version =
		{
			filename = ColorTIER_path.."/graphics/high-res/entity/stone-furnace/stone-chemical-furnace.png",
			x = 376,
			priority = "extra-high",
			width = 188,
			height = 160,
			frame_count = 1,
			shift = {0.25, 0 },
			scale = 0.5
		},
        {
          filename = "__base__/graphics/entity/stone-furnace/stone-furnace-shadow.png",
          priority = "extra-high",
          width = 81,
          height = 64,
          frame_count = 1,
          draw_as_shadow = true,
          shift = util.by_pixel(14.5, 2),
          hr_version =
          {
            filename = "__base__/graphics/entity/stone-furnace/hr-stone-furnace-shadow.png",
            priority = "extra-high",
            width = 164,
            height = 74,
            frame_count = 1,
            draw_as_shadow = true,
            shift = util.by_pixel(14.5, 13),
            scale = 0.5
          }
        }
      },
      east =
      {
        x = 282,
        filename = "__bobplates__/graphics/entity/stone-chemical-furnace/stone-chemical-furnace.png",
        priority = "extra-high",
        width = 94,
        height = 80,
        frame_count = 1,
        shift = {0.25, 0 },
		hr_version =
			{
			filename = ColorTIER_path.."/graphics/high-res/entity/stone-furnace/stone-chemical-furnace.png",
			x = 564,
			priority = "extra-high",
			width = 188,
			height = 160,
			frame_count = 1,
			shift = {0.25, 0 },
			scale = 0.5
			}
        },
        {
          filename = "__base__/graphics/entity/stone-furnace/stone-furnace-shadow.png",
          priority = "extra-high",
          width = 81,
          height = 64,
          frame_count = 1,
          draw_as_shadow = true,
          shift = util.by_pixel(14.5, 2),
          hr_version =
          {
            filename = "__base__/graphics/entity/stone-furnace/hr-stone-furnace-shadow.png",
            priority = "extra-high",
            width = 164,
            height = 74,
            frame_count = 1,
            draw_as_shadow = true,
            shift = util.by_pixel(14.5, 13),
            scale = 0.5
          }
        }
    }
	end
end

function replaceELECTRICFURNACE(name, type)
	if data.raw["furnace"][name] then
	data.raw["furnace"][name]["animation"]["layers"] =
      {
        {
          filename = "__base__/graphics/entity/electric-furnace/electric-furnace-base.png",
          priority = "high",
          width = 129,
          height = 100,
          frame_count = 1,
          shift = {0.421875, 0},
          hr_version =
          {
            filename = ColorTIER_path.."/graphics/high-res/entity/electric-furnace/electric-furnace-"..type..".png",
            priority = "high",
            width = 239,
            height = 219,
            frame_count = 1,
            shift = util.by_pixel(0.75, 5.75),
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/electric-furnace/electric-furnace-shadow.png",
          priority = "high",
          width = 129,
          height = 100,
          frame_count = 1,
          shift = {0.421875, 0},
          draw_as_shadow = true,
          hr_version =
          {
            filename = "__base__/graphics/entity/electric-furnace/hr-electric-furnace-shadow.png",
            priority = "high",
            width = 227,
            height = 171,
            frame_count = 1,
            draw_as_shadow = true,
            shift = util.by_pixel(11.25, 7.75),
            scale = 0.5
          }
        }
      }
	data.raw["furnace"][name]["working_visualisations"] =
	{
      {
        animation =
        {
          filename = "__base__/graphics/entity/electric-furnace/electric-furnace-heater.png",
          priority = "high",
          width = 25,
          height = 15,
          frame_count = 12,
          animation_speed = 0.5,
          shift = {0.015625, 0.890625},
          hr_version =
          {
            filename = "__base__/graphics/entity/electric-furnace/hr-electric-furnace-heater.png",
            priority = "high",
            width = 60,
            height = 56,
            frame_count = 12,
            animation_speed = 0.5,
            shift = util.by_pixel(1.75, 32.75),
            scale = 0.5
          }
        },
        light = {intensity = 0.4, size = 6, shift = {0.0, 1.0}, color = {r = 1.0, g = 1.0, b = 1.0}}
      },
      {
        animation =
        {
          filename = "__base__/graphics/entity/electric-furnace/electric-furnace-propeller-1.png",
          priority = "high",
          width = 19,
          height = 13,
          frame_count = 4,
          animation_speed = 0.5,
          shift = {-0.671875, -0.640625},
          hr_version =
          {
            filename = "__base__/graphics/entity/electric-furnace/hr-electric-furnace-propeller-1.png",
            priority = "high",
            width = 37,
            height = 25,
            frame_count = 4,
            animation_speed = 0.5,
            shift = util.by_pixel(-20.5, -18.5),
            scale = 0.5
          }
        }
      },
      {
        animation =
        {
          filename = "__base__/graphics/entity/electric-furnace/electric-furnace-propeller-2.png",
          priority = "high",
          width = 12,
          height = 9,
          frame_count = 4,
          animation_speed = 0.5,
          shift = {0.0625, -1.234375},
          hr_version =
          {
            filename = "__base__/graphics/entity/electric-furnace/hr-electric-furnace-propeller-2.png",
            priority = "high",
            width = 23,
            height = 15,
            frame_count = 4,
            animation_speed = 0.5,
            shift = util.by_pixel(3.5, -38),
            scale = 0.5
          }
        }
      }
    }
	end
end

function replaceAELECTRICFURNACE(name, picture)
	if data.raw["assembling-machine"][name] then
	data.raw["assembling-machine"][name]["animation"]["layers"] =
      {
        {
          filename = "__base__/graphics/entity/electric-furnace/electric-furnace-base.png",
          priority = "high",
          width = 129,
          height = 100,
          frame_count = 1,
          shift = {0.421875, 0},
          hr_version =
          {
            filename = ColorTIER_path.."/graphics/high-res/entity/electric-furnace/"..picture..".png",
            priority = "high",
            width = 239,
            height = 219,
            frame_count = 1,
            shift = util.by_pixel(0.75, 5.75),
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/electric-furnace/electric-furnace-shadow.png",
          priority = "high",
          width = 129,
          height = 100,
          frame_count = 1,
          shift = {0.421875, 0},
          draw_as_shadow = true,
          hr_version =
          {
            filename = "__base__/graphics/entity/electric-furnace/hr-electric-furnace-shadow.png",
            priority = "high",
            width = 227,
            height = 171,
            frame_count = 1,
            draw_as_shadow = true,
            shift = util.by_pixel(11.25, 7.75),
            scale = 0.5
          }
        }
      }
	end
end

----------------------------------------------------------------------------------------------------------------------
if data.raw.container["brass-chest"] then
data.raw.container["brass-chest"]["picture"]["layers"] =
{
    {
      filename = "__boblogistics__/graphics/entity/chest/brass-chest.png",
      priority = "extra-high",
      width = 46,
      height = 32,
	  hr_version =
	  {
        filename = ColorTIER_path.."/graphics/high-res/entity/chest/brass-chest.png",
        priority = "extra-high",
        width = 68,
        height = 84,
		shift = {0, -0.1},
		scale = 0.5
	  }
    },
    {
      filename = "__base__/graphics/entity/wooden-chest/wooden-chest-shadow.png",
      priority = "extra-high",
      width = 52,
      height = 20,
      shift = util.by_pixel(10, 6.5),
      draw_as_shadow = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/wooden-chest/hr-wooden-chest-shadow.png",
        priority = "extra-high",
        width = 104,
        height = 40,
        shift = util.by_pixel(10, 6.5),
        draw_as_shadow = true,
        scale = 0.5
      }
    }
}
end

if data.raw.container["titanium-chest"] then
data.raw.container["titanium-chest"]["picture"]["layers"] =
{
    {
      filename = "__boblogistics__/graphics/entity/chest/titanium-chest.png",
      priority = "extra-high",
      width = 46,
      height = 32,
      shift = {0.21875, 0},
	  hr_version =
	  {
        filename = ColorTIER_path.."/graphics/high-res/entity/chest/titanium-chest.png",
        priority = "extra-high",
        width = 68,
        height = 84,
		shift = {0, -0.1},
		scale = 0.5
	  }
    },
    {
      filename = "__base__/graphics/entity/wooden-chest/wooden-chest-shadow.png",
      priority = "extra-high",
      width = 52,
      height = 20,
      shift = util.by_pixel(10, 6.5),
      draw_as_shadow = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/wooden-chest/hr-wooden-chest-shadow.png",
        priority = "extra-high",
        width = 104,
        height = 40,
        shift = util.by_pixel(10, 6.5),
        draw_as_shadow = true,
        scale = 0.5
      }
    }
}
end

function replaceLOGISTICCHESTS(name,name2,picture)
	if data.raw["logistic-container"][name] then
	data.raw["logistic-container"][name]["animation"] =
	{
	layers =
      {
        {
          filename = ColorTIER_path.."/graphics/high-res/entity/chest/chest-back.png",
          priority = "extra-high",
		  width = 68,
		  height = 84,
		  repeat_count = 7,
		  shift = {0, -0.1},
		  scale = 0.5,
          hr_version =
          {
            filename = ColorTIER_path.."/graphics/high-res/entity/chest/chest-back.png",
            priority = "extra-high",
			width = 68,
			height = 84,
			repeat_count = 7,
			shift = {0, -0.1},
			scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/logistic-chest/"..name2..".png",
          priority = "extra-high",
          width = 34,
          height = 38,
          frame_count = 7,
          shift = util.by_pixel(0, -5),
          hr_version =
          {
            filename = "__base__/graphics/entity/logistic-chest/hr-"..name2..".png",
            priority = "extra-high",
            width = 66,
            height = 72,
            frame_count = 7,
            shift = util.by_pixel(0, -5),
            scale = 0.5
          }
        },
        {
          filename = ColorTIER_path.."/graphics/high-res/entity/chest/"..picture.."-cap.png",
          priority = "extra-high",
		  width = 68,
		  height = 84,
		  repeat_count = 7,
		  shift = {0, -0.1},
		  scale = 0.5,
          hr_version =
          {
            filename = ColorTIER_path.."/graphics/high-res/entity/chest/"..picture.."-cap.png",
            priority = "extra-high",
			width = 68,
			height = 84,
			repeat_count = 7,
			shift = {0, -0.1},
			scale = 0.5
          }
        },
		{
			filename = "__base__/graphics/entity/wooden-chest/wooden-chest-shadow.png",
			priority = "extra-high",
			width = 52,
			height = 20,
			repeat_count = 7,
			shift = util.by_pixel(10, 6.5),
			draw_as_shadow = true,
			hr_version =
			{
			filename = "__base__/graphics/entity/wooden-chest/hr-wooden-chest-shadow.png",
			priority = "extra-high",
			width = 104,
			height = 40,
			repeat_count = 7,
			shift = util.by_pixel(10, 6.5),
			draw_as_shadow = true,
			scale = 0.5
			}
		}
      }
	}
	data.raw["logistic-container"][name]["picture"] = nil
	
	end
end

function replacePUMPJACKS(name,type)
	if data.raw["mining-drill"][name] then
	data.raw["mining-drill"][name]["base_picture"] =
    {
      sheets =
      {
        {
          filename = "__base__/graphics/entity/pumpjack/pumpjack-base.png",
          priority = "extra-high",
          width = 131,
          height = 137,
          shift = util.by_pixel(-2.5, -4.5),
          hr_version =
          {
            filename = ColorTIER_path.."/graphics/high-res/entity/pumpjack/pumpjack-base-"..type..".png",
            priority = "extra-high",
            width = 261,
            height = 273,
            shift = util.by_pixel(-2.25, -4.75),
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/pumpjack/pumpjack-base-shadow.png",
          priority = "extra-high",
          width = 110,
          height = 111,
          draw_as_shadow = true,
          shift = util.by_pixel(6, 0.5),
          hr_version =
          {
            filename = "__base__/graphics/entity/pumpjack/hr-pumpjack-base-shadow.png",
            width = 220,
            height = 220,
            scale = 0.5,
            draw_as_shadow = true,
            shift = util.by_pixel(6, 0.5)
          }
        }
      }
    }
	end
end

function replaceMININGDRILLS(name,type)
	if data.raw["mining-drill"][name] then
	data.raw["mining-drill"][name]["animations"] =
    {
      north =
	  {
        layers =
        {
          {
          priority = "high",
          filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-N.png",
          line_length = 8,
          width = 98,
          height = 113,
          frame_count = 64,
          animation_speed = type/2,
          direction_count = 1,
          shift = util.by_pixel(0, -8.5),
          run_mode = "forward-then-backward",
          hr_version =
			{
            priority = "high",
            filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-N.png",
            line_length = 8,
            width = 196,
            height = 226,
            frame_count = 64,
            animation_speed = type/2,
            direction_count = 1,
            shift = util.by_pixel(0, -8),
            run_mode = "forward-then-backward",
            scale = 0.5
			}
          },
          {
          priority = "high",
          filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-N.png",
          line_length = 8,
          width = 98,
          height = 113,
          frame_count = 64,
          animation_speed = type/2,
          direction_count = 1,
          shift = util.by_pixel(0, -8.5),
          run_mode = "forward-then-backward",
          hr_version =
			{
            priority = "high",
            filename = ColorTIER_path.."/graphics/high-res/entity/electric-mining-drill/electric-mining-drill-N-"..type..".png",
            line_length = 8,
            width = 196,
            height = 226,
            frame_count = 64,
            animation_speed = type/2,
            direction_count = 1,
            shift = util.by_pixel(0, -8),
            run_mode = "forward-then-backward",
            scale = 0.5
			}
          }
		}
	  },
      east =
	  {
        layers =
        {
          {
        priority = "high",
        filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-E.png",
        line_length = 8,
        width = 105,
        height = 98,
        frame_count = 64,
        animation_speed = type/2,
        direction_count = 1,
        shift = util.by_pixel(3.5, -1),
        run_mode = "forward-then-backward",
        hr_version =
        {
          priority = "high",
          filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-E.png",
          line_length = 8,
          width = 211,
          height = 197,
          frame_count = 64,
          animation_speed = type/2,
          direction_count = 1,
          shift = util.by_pixel(3.75, -1.25),
          run_mode = "forward-then-backward",
          scale = 0.5
        }
      },
	  {
        priority = "high",
        filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-E.png",
        line_length = 8,
        width = 105,
        height = 98,
        frame_count = 64,
        animation_speed = type/2,
        direction_count = 1,
        shift = util.by_pixel(3.5, -1),
        run_mode = "forward-then-backward",
        hr_version =
        {
          priority = "high",
          filename = ColorTIER_path.."/graphics/high-res/entity/electric-mining-drill/electric-mining-drill-E-"..type..".png",
          line_length = 8,
          width = 211,
          height = 197,
          frame_count = 64,
          animation_speed = type/2,
          direction_count = 1,
          shift = util.by_pixel(3.75, -1.25),
          run_mode = "forward-then-backward",
          scale = 0.5
			}
          }
		}
	  },
      south =
	  {
        layers =
        {
          {
        priority = "high",
        filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-S.png",
        line_length = 8,
        width = 98,
        height = 109,
        frame_count = 64,
        animation_speed = type/2,
        direction_count = 1,
        shift = util.by_pixel(0, -1.5),
        run_mode = "forward-then-backward",
        hr_version =
        {
          priority = "high",
          filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-S.png",
          line_length = 8,
          width = 196,
          height = 219,
          frame_count = 64,
          animation_speed = type/2,
          direction_count = 1,
          shift = util.by_pixel(0, -1.25),
          run_mode = "forward-then-backward",
          scale = 0.5
        }
      },
          {
        priority = "high",
        filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-S.png",
        line_length = 8,
        width = 98,
        height = 109,
        frame_count = 64,
        animation_speed = type/2,
        direction_count = 1,
        shift = util.by_pixel(0, -1.5),
        run_mode = "forward-then-backward",
        hr_version =
        {
          priority = "high",
          filename = ColorTIER_path.."/graphics/high-res/entity/electric-mining-drill/electric-mining-drill-S-"..type..".png",
          line_length = 8,
          width = 196,
          height = 219,
          frame_count = 64,
          animation_speed = type/2,
          direction_count = 1,
          shift = util.by_pixel(0, -1.25),
          run_mode = "forward-then-backward",
          scale = 0.5	  
			}
          }
		}
	  },
      west =
	  {
        layers =
        {
          {
        priority = "high",
        filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-W.png",
        line_length = 8,
        width = 105,
        height = 98,
        frame_count = 64,
        animation_speed = type/2,
        direction_count = 1,
        shift = util.by_pixel(-3.5, -1),
        run_mode = "forward-then-backward",
        hr_version =
        {
          priority = "high",
          filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-W.png",
          line_length = 8,
          width = 211,
          height = 197,
          frame_count = 64,
          animation_speed = type/2,
          direction_count = 1,
          shift = util.by_pixel(-3.75, -0.75),
          run_mode = "forward-then-backward",
          scale = 0.5
        }
      },
          {
        priority = "high",
        filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-W.png",
        line_length = 8,
        width = 105,
        height = 98,
        frame_count = 64,
        animation_speed = type/2,
        direction_count = 1,
        shift = util.by_pixel(-3.5, -1),
        run_mode = "forward-then-backward",
        hr_version =
        {
          priority = "high",
          filename = ColorTIER_path.."/graphics/high-res/entity/electric-mining-drill/electric-mining-drill-W-"..type..".png",
          line_length = 8,
          width = 211,
          height = 197,
          frame_count = 64,
          animation_speed = type/2,
          direction_count = 1,
          shift = util.by_pixel(-3.75, -0.75),
          run_mode = "forward-then-backward",
          scale = 0.5
			}
          }
		}
	  }
	}
	end
end

----------------------------------------------------------------------------------------------------------------------

function replaceSMALLSOLARPANELS(name,type)
	if data.raw["solar-panel"][name] then
	data.raw["solar-panel"][name]["picture"] =
    {
      filename = "__bobpower__/graphics/solar-panel/solar-panel-s.png",
      priority = "high",
      width = 71,
      height = 66,
      hr_version =
	  {
      filename = ColorTIER_path.."/graphics/high-res/entity/solar-panel/small-panel-"..type..".png",
      priority = "high",
      width = 142,
      height = 132,
	  scale = 0.5
	  }
    }
	end
end

function replaceMEDIUMSOLARPANELS(name,type)
	if data.raw["solar-panel"][name] then
	data.raw["solar-panel"]["solar-panel"]["overlay"] = nil
	data.raw["solar-panel"][name]["picture"] =
    {
      filename = "__bobpower__/graphics/solar-panel/solar-panel-2.png",
      priority = "high",
      width = 104,
      height = 97,
      hr_version =
	  {
      filename = ColorTIER_path.."/graphics/high-res/entity/solar-panel/medium-panel-"..type..".png",
      priority = "high",
      width = 208,
      height = 194,
	  scale = 0.5
	  }
    }
	
	end
end

function replaceLARGESOLARPANELS(name,type)
	if data.raw["solar-panel"][name] then
	data.raw["solar-panel"][name]["picture"] =
    {
      filename = "__bobpower__/graphics/solar-panel/solar-panel-l2.png",
      priority = "high",
      width = 136,
      height = 126,
      hr_version =
	  {
      filename = ColorTIER_path.."/graphics/high-res/entity/solar-panel/large-panel-"..type..".png",
      priority = "high",
      width = 272,
      height = 252,
	  scale = 0.5
	  }
    }
	end
end

function replaceLABS(name,picture)
	if data.raw["lab"][name] then
	data.raw["lab"][name]["on_animation"] =
    {
      layers =
      {
        {
          filename = "__base__/graphics/entity/lab/lab.png",
          width = 98,
          height = 87,
          frame_count = 33,
          line_length = 11,
          animation_speed = 1 / 3,
          shift = util.by_pixel(0, 1.5),
          hr_version =
          {
            filename = ColorTIER_path.."/graphics/high-res/entity/lab/"..picture..".png",
            width = 194,
            height = 174,
            frame_count = 33,
            line_length = 11,
            animation_speed = 1 / 3,
            shift = util.by_pixel(0, 1.5),
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/lab/lab-integration.png",
          width = 122,
          height = 81,
          frame_count = 1,
          line_length = 1,
          repeat_count = 33,
          animation_speed = 1 / 3,
          shift = util.by_pixel(0, 15.5),
          hr_version =
          {
            filename = "__base__/graphics/entity/lab/hr-lab-integration.png",
            width = 242,
            height = 162,
            frame_count = 1,
            line_length = 1,
            repeat_count = 33,
            animation_speed = 1 / 3,
            shift = util.by_pixel(0, 15.5),
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/lab/lab-shadow.png",
          width = 122,
          height = 68,
          frame_count = 1,
          line_length = 1,
          repeat_count = 33,
          animation_speed = 1 / 3,
          shift = util.by_pixel(13, 11),
          draw_as_shadow = true,
          hr_version =
          {
            filename = "__base__/graphics/entity/lab/hr-lab-shadow.png",
            width = 242,
            height = 136,
            frame_count = 1,
            line_length = 1,
            repeat_count = 33,
            animation_speed = 1 / 3,
            shift = util.by_pixel(13, 11),
            scale = 0.5,
            draw_as_shadow = true
          }
        }
      }
    }
	data.raw["lab"][name]["off_animation"] =
    {
      layers =
      {
        {
          filename = "__base__/graphics/entity/lab/lab.png",
          width = 98,
          height = 87,
          frame_count = 1,
          shift = util.by_pixel(0, 1.5),
          hr_version =
          {
            filename = ColorTIER_path.."/graphics/high-res/entity/lab/"..picture..".png",
            width = 194,
            height = 174,
            frame_count = 1,
            shift = util.by_pixel(0, 1.5),
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/lab/lab-integration.png",
          width = 122,
          height = 81,
          frame_count = 1,
          shift = util.by_pixel(0, 15.5),
          hr_version =
          {
            filename = "__base__/graphics/entity/lab/hr-lab-integration.png",
            width = 242,
            height = 162,
            frame_count = 1,
            shift = util.by_pixel(0, 15.5),
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/lab/lab-shadow.png",
          width = 122,
          height = 68,
          frame_count = 1,
          shift = util.by_pixel(13, 11),
          draw_as_shadow = true,
          hr_version =
          {
            filename = "__base__/graphics/entity/lab/hr-lab-shadow.png",
            width = 242,
            height = 136,
            frame_count = 1,
            shift = util.by_pixel(13, 11),
            draw_as_shadow = true,
            scale = 0.5
          }
        }
      }
	}
	end
end

function replaceRADARS(name, type)
		
	if data.raw["radar"][name] then
	data.raw["radar"][name]["pictures"] =
    {
      layers =
      {
        {
          filename = "__base__/graphics/entity/radar/radar.png",
          priority = "low",
          width = 98,
          height = 128,
          apply_projection = false,
          direction_count = 64,
          line_length = 8,
          shift = util.by_pixel(1, -16),
          hr_version =
          {
            filename = ColorTIER_path.."/graphics/high-res/entity/radar/radar-"..type..".png",
            priority = "low",
            width = 196,
            height = 254,
            apply_projection = false,
            direction_count = 64,
            line_length = 8,
            shift = util.by_pixel(1, -16),
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/radar/radar-shadow.png",
          priority = "low",
          width = 172,
          height = 94,
          apply_projection = false,
          direction_count = 64,
          line_length = 8,
          shift = util.by_pixel(39,3),
          draw_as_shadow = true,
          hr_version =
          {
            filename = "__base__/graphics/entity/radar/hr-radar-shadow.png",
            priority = "low",
            width = 343,
            height = 186,
            apply_projection = false,
            direction_count = 64,
            line_length = 8,
            shift = util.by_pixel(39.25,3),
            draw_as_shadow = true,
            scale = 0.5
          }
        }
      }
    }
	end
end

function replaceMINES(name)
		
	if data.raw["land-mine"][name] then
	data.raw["land-mine"][name].picture_safe = {filename=ColorTIER_path.."/graphics/high-res/entity/land-mine/hr-landmine.png", width=64, height = 64, scale=0.5}
	data.raw["land-mine"][name].picture_set = {filename=ColorTIER_path.."/graphics/high-res/entity/land-mine/hr-landmine-set.png", width=64, height = 64, scale=0.5}
	end
end

replaceMINES("land-mine")
replaceMINES("poison-mine")
replaceMINES("slowdown-mine")
replaceMINES("distractor-mine")


