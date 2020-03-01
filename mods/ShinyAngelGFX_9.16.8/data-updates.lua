
--Template
if data.raw["electric-pole"]["medium-electric-pole-8"] then 
if data.raw[""][""] then 
	data.raw["item"][""].icon = ""
	data.raw[""][""].icon = ""
	data.raw[""][""].pictures["filename"] = "" 
 end
 end

if data.raw["assembling-machine"]["steam-cracker"] then 
if data.raw["storage-tank"]["storage-tank-2"] then 
	data.raw["item"]["storage-tank-2"].subgroup = "angels-fluid-control"
	data.raw["item"]["storage-tank-2"].order = "a"
	data.raw["item"]["storage-tank"].subgroup = "angels-fluid-control"
	data.raw["item"]["storage-tank"].order = "a"
end
if data.raw["storage-tank"]["storage-tank-3"] then 
	data.raw["item"]["storage-tank-3"].subgroup = "angels-fluid-control"
	data.raw["item"]["storage-tank-3"].order = "a"
end
if data.raw["storage-tank"]["storage-tank-4"] then 
	data.raw["item"]["storage-tank-4"].subgroup = "angels-fluid-control"
	data.raw["item"]["storage-tank-4"].order = "a"
end
end

if data.raw["assembling-machine"]["electro-whinning-cell"] then
	iconset("electro-whinning-cell","","-1")
	iconset("electro-whinning-cell","-2","-2")
	iconset("electro-whinning-cell","-3","-3")
	
	data.raw["assembling-machine"]["electro-whinning-cell"]["animation"].filename = "__ShinyAngelGFX__/graphics/entity/electro-whinning-cell/electro-whinning-cell-1.png"
	data.raw["assembling-machine"]["electro-whinning-cell-2"]["animation"].filename = "__ShinyAngelGFX__/graphics/entity/electro-whinning-cell/electro-whinning-cell-2.png"
	data.raw["assembling-machine"]["electro-whinning-cell-3"]["animation"].filename = "__ShinyAngelGFX__/graphics/entity/electro-whinning-cell/electro-whinning-cell-3.png"
	
end


if data.raw["assembling-machine"]["algae-farm"] then
	iconset("algae-farm","","-1")
	iconset("algae-farm","-2","-2")

	data.raw["assembling-machine"]["algae-farm"].animation = {
		layers = {{
		filename = "__angelsbioprocessing__/graphics/entity/algae-farm/algae-farm.png",
        width = 288,
        height = 288,
		line_length = 6,
        frame_count = 36,
        shift = {0, 0},
    	animation_speed = 0.4
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/algae-farm/algae-farm-o1.png",
        width = 288,
        height = 288,
		line_length = 6,
        frame_count = 36,
        shift = {0, 0},
    	animation_speed = 0.4
	}}}	
end

if data.raw["assembling-machine"]["algae-farm-2"] then
	
	data.raw["assembling-machine"]["algae-farm-2"].animation = {
		layers = {{
		filename = "__angelsbioprocessing__/graphics/entity/algae-farm/algae-farm.png",
        width = 288,
        height = 288,
		line_length = 6,
        frame_count = 36,
        shift = {0, 0},
    	animation_speed = 0.4
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/algae-farm/algae-farm-o2.png",
        width = 288,
        height = 288,
		line_length = 6,
        frame_count = 36,
        shift = {0, 0},
    	animation_speed = 0.4
	}}}	
end


if data.raw["assembling-machine"]["ore-powderizer-3"] then
	iconset("ore-powderizer","","-1")
	iconset("ore-powderizer","-2","-2")
	iconset("ore-powderizer","-3","-3")

	data.raw["assembling-machine"]["ore-powderizer"]["animation"].filename = "__ShinyAngelGFX__/graphics/entity/ore-powderizer/ore-powderizer-lr-1.png"
	data.raw["assembling-machine"]["ore-powderizer-2"]["animation"].filename = "__ShinyAngelGFX__/graphics/entity/ore-powderizer/ore-powderizer-lr-2.png"
	data.raw["assembling-machine"]["ore-powderizer-3"]["animation"].filename = "__ShinyAngelGFX__/graphics/entity/ore-powderizer/ore-powderizer-lr-3.png"
	data.raw["assembling-machine"]["ore-powderizer"]["animation"].hr_version.filename = "__ShinyAngelGFX__/graphics/entity/ore-powderizer/ore-powderizer-hr-1.png"
	data.raw["assembling-machine"]["ore-powderizer-2"]["animation"].hr_version.filename = "__ShinyAngelGFX__/graphics/entity/ore-powderizer/ore-powderizer-hr-2.png"
	data.raw["assembling-machine"]["ore-powderizer-3"]["animation"].hr_version.filename = "__ShinyAngelGFX__/graphics/entity/ore-powderizer/ore-powderizer-hr-3.png"
	
end


if data.raw["assembling-machine"]["angels-chemical-plant-4"] then
	iconset("angels-chemical-plant","","-1")
	iconset("angels-chemical-plant","-2","-2")
	iconset("angels-chemical-plant","-3","-3")
	iconset("angels-chemical-plant","-4","-4")
	data.raw["assembling-machine"]["angels-chemical-plant"]["animation"].filename = "__ShinyAngelGFX__/graphics/entity/chemical-plant/chemical-plant-1.png"
	data.raw["assembling-machine"]["angels-chemical-plant-2"]["animation"].filename = "__ShinyAngelGFX__/graphics/entity/chemical-plant/chemical-plant-2.png"
	data.raw["assembling-machine"]["angels-chemical-plant-3"]["animation"].filename = "__ShinyAngelGFX__/graphics/entity/chemical-plant/chemical-plant-3.png"
	data.raw["assembling-machine"]["angels-chemical-plant-4"]["animation"].filename = "__ShinyAngelGFX__/graphics/entity/chemical-plant/chemical-plant-4.png"
end


 
if data.raw["assembling-machine"]["assembling-machine-1"] then
if data.raw["assembling-machine"]["steam-cracker"] then 
if data.raw["assembling-machine"]["steam-cracker"] then 
	iconset("steam-cracker","","-1")
	data.raw["assembling-machine"]["steam-cracker"].animation = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/steam-cracker/steam-cracker.png",
		priority = "extra-high",
        width = 512,
        height = 512,
		scale = 0.5,
        frame_count = 1,
        shift = {0.5, -0.5}
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/steam-cracker/steam-cracker-1.png",
		priority = "extra-high",
        width = 512,
        height = 512,
		scale = 0.5,
        frame_count = 1,
        shift = {0.5, -0.5}
	}}}
	data.raw["assembling-machine"]["steam-cracker"].fluid_boxes = {
		{
        production_type = "input",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {1, 3} }}
      },
      {
        production_type = "input",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, 3} }}
      },
      {
        production_type = "output",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {1, -3} }}
      },
      {
        production_type = "output",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-1, -3} }}
      }
    }
end
 
 if data.raw["assembling-machine"]["steam-cracker-2"] then 
	iconset("steam-cracker","-2","-2")
	-- {
		-- {
			-- icon = "__ShinyAngelGFX__/graphics/icons/steam-cracker-2.png",
		-- },
		-- {
			-- icon = "__ShinyAngelGFX__/graphics/icons/num_2.png",
		-- }
	-- }
	-- data.raw["assembling-machine"]["steam-cracker-2"].icons = {
		-- {
			-- icon = "__ShinyAngelGFX__/graphics/icons/steam-cracker-2.png",
		-- },
		-- {
			-- icon = "__ShinyAngelGFX__/graphics/icons/num_2.png",
		-- }
	-- }
end
 
 
 if data.raw["assembling-machine"]["steam-cracker-3"] then 
	iconset("steam-cracker","-3","-3")
	data.raw["assembling-machine"]["steam-cracker-3"].animation = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/steam-cracker/steam-cracker.png",
		priority = "extra-high",
        width = 512,
        height = 512,
		scale = 0.5,
        frame_count = 1,
        shift = {0.5, -0.5}
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/steam-cracker/steam-cracker-3.png",
		priority = "extra-high",
        width = 512,
        height = 512,
		scale = 0.5,
        frame_count = 1,
        shift = {0.5, -0.5}
	}}}	
	data.raw["assembling-machine"]["steam-cracker-3"].fluid_boxes = {
		{
        production_type = "input",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {1, 3} }}
      },
      {
        production_type = "input",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, 3} }}
      },
      {
        production_type = "output",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {1, -3} }}
      },
      {
        production_type = "output",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-1, -3} }}
      }
    }
 end
 
 if data.raw["assembling-machine"]["steam-cracker-4"] then 
	iconset("steam-cracker","-4","-4")
	data.raw["assembling-machine"]["steam-cracker-4"].animation = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/steam-cracker/steam-cracker.png",
		priority = "extra-high",
        width = 512,
        height = 512,
		scale = 0.5,
        frame_count = 1,
        shift = {0.5, -0.5}
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/steam-cracker/steam-cracker-4.png",
		priority = "extra-high",
        width = 512,
        height = 512,
		scale = 0.5,
        frame_count = 1,
        shift = {0.5, -0.5}
		}}}
	data.raw["assembling-machine"]["steam-cracker-4"].fluid_boxes = {
		{
        production_type = "input",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {1, 3} }}
      },
      {
        production_type = "input",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, 3} }}
      },
      {
        production_type = "output",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {1, -3} }}
      },
      {
        production_type = "output",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-1, -3} }}
      }
    }
    -- pipe_covers = pipecoverspictures2()
    
end
end
 

if data.raw["assembling-machine"]["separator"] then  
 if data.raw["assembling-machine"]["separator"] then 
	iconset("separator","","-1")
	data.raw["assembling-machine"]["separator"].animation = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/separator/separator.png",
		priority = "extra-high",
        width = 224,
        height = 224,
        frame_count = 1,
        shift = {0, 0},
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/separator/separator-1.png",
		priority = "extra-high",
        width = 224,
        height = 224,
        frame_count = 1,
        shift = {0, 0},
	}}}
	data.raw["assembling-machine"]["separator"].fluid_boxes =
    {
      {
        production_type = "input",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, 3} }}
      },
      {
        production_type = "output",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {0, -3} }}
      },
	  {
        production_type = "output",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-2, -3} }}
      },
	  {
        production_type = "output",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {2, -3} }}
      }
    }
 end
 
 
 if data.raw["assembling-machine"]["separator-2"] then 
	iconset("separator","-2","-2")
	data.raw["assembling-machine"]["separator-2"].animation = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/separator/separator.png",
		priority = "extra-high",
        width = 224,
        height = 224,
        frame_count = 1,
        shift = {0, 0},
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/separator/separator-2.png",
		priority = "extra-high",
        width = 224,
        height = 224,
        frame_count = 1,
        shift = {0, 0},
	}}}
	data.raw["assembling-machine"]["separator-2"].fluid_boxes =
    {
      {
        production_type = "input",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, 3} }}
      },
      {
        production_type = "output",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {0, -3} }}
      },
	  {
        production_type = "output",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-2, -3} }}
      },
	  {
        production_type = "output",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {2, -3} }}
      }
    }
 end
 
 
 if data.raw["assembling-machine"]["separator-3"] then 
	iconset("separator","-3","-3")
	data.raw["assembling-machine"]["separator-3"].animation = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/separator/separator.png",
		priority = "extra-high",
        width = 224,
        height = 224,
        frame_count = 1,
        shift = {0, 0},
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/separator/separator-3.png",
		priority = "extra-high",
        width = 224,
        height = 224,
        frame_count = 1,
        shift = {0, 0},
	}}}
	data.raw["assembling-machine"]["separator-3"].fluid_boxes =
    {
      {
        production_type = "input",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, 3} }}
      },
      {
        production_type = "output",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {0, -3} }}
      },
	  {
        production_type = "output",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-2, -3} }}
      },
	  {
        production_type = "output",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {2, -3} }}
      }
    }
 end
 
 
 if data.raw["assembling-machine"]["separator-4"] then 
	iconset("separator","-4","-4")
	data.raw["assembling-machine"]["separator-4"].animation = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/separator/separator.png",
		priority = "extra-high",
        width = 224,
        height = 224,
        frame_count = 1,
        shift = {0, 0},
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/separator/separator-4.png",
		priority = "extra-high",
        width = 224,
        height = 224,
        frame_count = 1,
        shift = {0, 0},
	}}}
	data.raw["assembling-machine"]["separator-4"].fluid_boxes =
    {
      {
        production_type = "input",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, 3} }}
      },
      {
        production_type = "output",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {0, -3} }}
      },
	  {
        production_type = "output",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-2, -3} }}
      },
	  {
        production_type = "output",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {2, -3} }}
      }
    }
 end
 end
  
 if data.raw["assembling-machine"]["gas-refinery-small"] then
 if data.raw["assembling-machine"]["gas-refinery-small"] then 
	iconset("gas-refinery-small","","-1")
	data.raw["assembling-machine"]["gas-refinery-small"].animation = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/gas-refinery/gas-refinery-small.png",
        width = 512,
        height = 512,
		scale = 0.5,
        frame_count = 1,
		line_length = 1,
        shift = {0.5, -0.5}
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/gas-refinery/gas-refinery-small-1.png",
        width = 512,
        height = 512,
		scale = 0.5,
        frame_count = 1,
		line_length = 1,
        shift = {0.5, -0.5}
		}}}
		data.raw["assembling-machine"]["gas-refinery-small"].fluid_boxes =
    {
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, 3} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-2, -3} }}
      },
	  {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {0, -3} }}
      },
	  {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {2, -3} }}
      }
    }
end
 
 if data.raw["assembling-machine"]["gas-refinery-small-2"] then 
	iconset("gas-refinery-small","-2","-2")
	
end
 
 
if data.raw["assembling-machine"]["gas-refinery-small-3"] then 
	iconset("gas-refinery-small","-3","-3")
	data.raw["assembling-machine"]["gas-refinery-small-3"].animation = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/gas-refinery/gas-refinery-small.png",
        width = 512,
        height = 512,
		scale = 0.5,
        frame_count = 1,
		line_length = 1,
        shift = {0.5, -0.5}
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/gas-refinery/gas-refinery-small-3.png",
        width = 512,
        height = 512,
		scale = 0.5,
        frame_count = 1,
		line_length = 1,
        shift = {0.5, -0.5}
		}}}
		data.raw["assembling-machine"]["gas-refinery-small-3"].fluid_boxes =
    {
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, 3} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-2, -3} }}
      },
	  {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {0, -3} }}
      },
	  {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {2, -3} }}
      }
    }
end


if data.raw["assembling-machine"]["gas-refinery-small-4"] then 
	iconset("gas-refinery-small","-4","-4")
	data.raw["assembling-machine"]["gas-refinery-small-4"].animation = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/gas-refinery/gas-refinery-small.png",
        width = 512,
        height = 512,
		scale = 0.5,
        frame_count = 1,
		line_length = 1,
        shift = {0.5, -0.5}
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/gas-refinery/gas-refinery-small-4.png",
        width = 512,
        height = 512,
		scale = 0.5,
        frame_count = 1,
		line_length = 1,
        shift = {0.5, -0.5}
		}}}
		
		data.raw["assembling-machine"]["gas-refinery-small-4"].fluid_boxes =
    {
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, 3} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-2, -3} }}
      },
	  {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {0, -3} }}
      },
	  {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {2, -3} }}
      }
    }
end
end
 
if data.raw["assembling-machine"]["gas-refinery"] then
if data.raw["assembling-machine"]["gas-refinery"] then  
	iconset("gas-refinery","","-1")
	data.raw["assembling-machine"]["gas-refinery"].animation = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/gas-refinery/gas-refinery.png",
        width = 704,
        height = 704,
		scale = 0.5,
        frame_count = 1,
		line_length = 1,
        shift = {1, -1},
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/gas-refinery/gas-refinery-1.png",
        width = 704,
        height = 704,
		scale = 0.5,
        frame_count = 1,
		line_length = 1,
        shift = {1, -1},
		}}}
		data.raw["assembling-machine"]["gas-refinery"].fluid_boxes =
    {
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, 4} }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {1, 4} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-3, -4} }}
      },
	  {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-1, -4} }}
      },
	  {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {1, -4} }}
      },
	  {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {3, -4} }}
      }
    }
end
 
 
if data.raw["assembling-machine"]["gas-refinery-2"] then 
	iconset("gas-refinery","-2","-2")
	data.raw["assembling-machine"]["gas-refinery-2"].animation = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/gas-refinery/gas-refinery.png",
        width = 704,
        height = 704,
		scale = 0.5,
        frame_count = 1,
		line_length = 1,
        shift = {1, -1},
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/gas-refinery/gas-refinery-2.png",
        width = 704,
        height = 704,
		scale = 0.5,
        frame_count = 1,
		line_length = 1,
        shift = {1, -1},
		}}}
		data.raw["assembling-machine"]["gas-refinery-2"].fluid_boxes =
    {
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, 4} }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {1, 4} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-3, -4} }}
      },
	  {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-1, -4} }}
      },
	  {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {1, -4} }}
      },
	  {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {3, -4} }}
      }
    }
end
 

if data.raw["assembling-machine"]["gas-refinery-3"] then 
	iconset("gas-refinery","-3","-3")
	data.raw["assembling-machine"]["gas-refinery-3"].animation = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/gas-refinery/gas-refinery.png",
        width = 704,
        height = 704,
		scale = 0.5,
        frame_count = 1,
		line_length = 1,
        shift = {1, -1},
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/gas-refinery/gas-refinery-3.png",
        width = 704,
        height = 704,
		scale = 0.5,
        frame_count = 1,
		line_length = 1,
        shift = {1, -1},
		}}}
	data.raw["assembling-machine"]["gas-refinery-3"].fluid_boxes =
    {
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, 4} }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {1, 4} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-3, -4} }}
      },
	  {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-1, -4} }}
      },
	  {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {1, -4} }}
      },
	  {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {3, -4} }}
      }
    }
		
end


if data.raw["assembling-machine"]["gas-refinery-4"] then 
	iconset("gas-refinery","-4","-4")
	data.raw["assembling-machine"]["gas-refinery-4"].animation = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/gas-refinery/gas-refinery.png",
        width = 704,
        height = 704,
		scale = 0.5,
        frame_count = 1,
		line_length = 1,
        shift = {1, -1},
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/gas-refinery/gas-refinery-4.png",
        width = 704,
        height = 704,
		scale = 0.5,
        frame_count = 1,
		line_length = 1,
        shift = {1, -1},
		}}}
		data.raw["assembling-machine"]["gas-refinery-4"].fluid_boxes =
    {
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, 4} }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {1, 4} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-3, -4} }}
      },
	  {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-1, -4} }}
      },
	  {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {1, -4} }}
      },
	  {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {3, -4} }}
      }
    }
end 
end
 
 
if data.raw["assembling-machine"]["advanced-chemical-plant"] then 
if data.raw["assembling-machine"]["advanced-chemical-plant"] then 
	iconset("advanced-chemical-plant","","-1")
	data.raw["assembling-machine"]["advanced-chemical-plant"].animation = {
		layers = {{ 
		filename = "__angelspetrochem__/graphics/entity/advanced-chemical-plant/advanced-chemical-plant.png",
        width = 224,
        height = 224,
        frame_count = 16,
		line_length = 4,
		animation_speed = 0.5,
        shift = {0, 0},
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/advanced-chemical-plant/advanced-chemical-plant-1.png",
        width = 224,
        height = 224,
        frame_count = 16,
		line_length = 4,
		animation_speed = 0.5,
        shift = {0, 0},
		}}}
	data.raw["assembling-machine"]["advanced-chemical-plant"].fluid_boxes =
    {
      {
        production_type = "input",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {2, 3} }}
      },
	  {
        production_type = "input",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, 3} }}
      },
	  {
        production_type = "input",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-2, 3} }}
      },
      {
        production_type = "output",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-2, -3} }}
      },
	  {
        production_type = "output",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {0, -3} }}
      },
	  {
        production_type = "output",
		--pipe_picture = floatationpipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {2, -3} }}
      },
	  --off_when_no_fluid_recipe = true
    }
end


if data.raw["assembling-machine"]["advanced-chemical-plant-2"] then 
	iconset("advanced-chemical-plant","-2","-2")
	
end
end


if data.raw["assembling-machine"]["angels-air-filter"] then
if data.raw["assembling-machine"]["angels-air-filter"] then  
	iconset("angels-air-filter","","-1")
	data.raw["assembling-machine"]["angels-air-filter"].animation = {
		layers = {{ 
		filename = "__angelspetrochem__/graphics/entity/air-filter/air-filter.png",
        width = 256,
        height = 256,
        frame_count = 36,
		line_length = 6,
        shift = {0.5, -0.5},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/air-filter/air-filter-1.png",
        width = 256,
        height = 256,
        frame_count = 36,
		line_length = 6,
        shift = {0.5, -0.5},
		animation_speed = 0.5
		}}}
	data.raw["assembling-machine"]["angels-air-filter"].fluid_boxes =
    {
      {
        production_type = "input",
		pipe_picture = electrolyserpictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, -3} }}
      },
	  {
        production_type = "output",
		pipe_picture = electrolyserpictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {0, 3} }}
      },
    }
end


if data.raw["assembling-machine"]["angels-air-filter-2"] then 
	iconset("angels-air-filter","-2","-2")
	data.raw["assembling-machine"]["angels-air-filter-2"].animation = {
		layers = {{ 
		filename = "__angelspetrochem__/graphics/entity/air-filter/air-filter.png",
        width = 256,
        height = 256,
        frame_count = 36,
		line_length = 6,
        shift = {0.5, -0.5},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/air-filter/air-filter-2.png",
        width = 256,
        height = 256,
        frame_count = 36,
		line_length = 6,
        shift = {0.5, -0.5},
		animation_speed = 0.5
		}}}
	data.raw["assembling-machine"]["angels-air-filter-2"].fluid_boxes =
    {
      {
        production_type = "input",
		pipe_picture = electrolyserpictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, -3} }}
      },
	  {
        production_type = "output",
		pipe_picture = electrolyserpictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {0, 3} }}
      },
    }
end
end


if data.raw["assembling-machine"]["angels-electrolyser"] then
if data.raw["assembling-machine"]["angels-electrolyser"] then  
	iconset("angels-electrolyser","","-1")
	data.raw["assembling-machine"]["angels-electrolyser"].animation = {
	north = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/electrolyser/electrolyser-north.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/electrolyser/electrolyser-north-1.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		}}},
	east = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/electrolyser/electrolyser-east.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/electrolyser/electrolyser-east-1.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		}}},
	south = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/electrolyser/electrolyser-north.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/electrolyser/electrolyser-north-1.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		}}},
	west = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/electrolyser/electrolyser-east.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/electrolyser/electrolyser-east-1.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		}}}
		}
		data.raw["assembling-machine"]["angels-electrolyser"].fluid_boxes =
    {
      {
        production_type = "input",
		pipe_picture = electrolyserpictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-2, -3} }}
      },
      {
        production_type = "input",
		pipe_picture = electrolyserpictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {2, -3} }}
      },
	  {
        production_type = "output",
		pipe_picture = electrolyserpictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-2, 3} }}
      },
	  {
        production_type = "output",
		pipe_picture = electrolyserpictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {2, 3} }}
      }
    }
end
		

		if data.raw["assembling-machine"]["angels-electrolyser-2"] then 
	iconset("angels-electrolyser","-2","-2")
	data.raw["assembling-machine"]["angels-electrolyser-2"].animation = {
	north = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/electrolyser/electrolyser-north.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/electrolyser/electrolyser-north-2.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		}}},
	east = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/electrolyser/electrolyser-east.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/electrolyser/electrolyser-east-2.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		}}},
	south = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/electrolyser/electrolyser-north.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/electrolyser/electrolyser-north-2.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		}}},
	west = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/electrolyser/electrolyser-east.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/electrolyser/electrolyser-east-2.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		}}}
		}
		data.raw["assembling-machine"]["angels-electrolyser-2"].fluid_boxes =
    {
      {
        production_type = "input",
		pipe_picture = electrolyserpictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-2, -3} }}
      },
      {
        production_type = "input",
		pipe_picture = electrolyserpictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {2, -3} }}
      },
	  {
        production_type = "output",
		pipe_picture = electrolyserpictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-2, 3} }}
      },
	  {
        production_type = "output",
		pipe_picture = electrolyserpictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {2, 3} }}
      }
    }
end


if data.raw["assembling-machine"]["angels-electrolyser-3"] then 
	iconset("angels-electrolyser","-3","-3")
	data.raw["assembling-machine"]["angels-electrolyser-3"].animation = {
	north = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/electrolyser/electrolyser-north.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/electrolyser/electrolyser-north-3.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		}}},
	east = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/electrolyser/electrolyser-east.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/electrolyser/electrolyser-east-3.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		}}},
	south = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/electrolyser/electrolyser-north.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/electrolyser/electrolyser-north-3.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		}}},
	west = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/electrolyser/electrolyser-east.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/electrolyser/electrolyser-east-3.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		}}}
		}
		data.raw["assembling-machine"]["angels-electrolyser-3"].fluid_boxes =
    {
      {
        production_type = "input",
		pipe_picture = electrolyserpictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-2, -3} }}
      },
      {
        production_type = "input",
		pipe_picture = electrolyserpictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {2, -3} }}
      },
	  {
        production_type = "output",
		pipe_picture = electrolyserpictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-2, 3} }}
      },
	  {
        production_type = "output",
		pipe_picture = electrolyserpictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {2, 3} }}
      }
    }
end


if data.raw["assembling-machine"]["angels-electrolyser-4"] then 
	iconset("angels-electrolyser","-4","-4")
	data.raw["assembling-machine"]["angels-electrolyser-4"].animation = {
	north = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/electrolyser/electrolyser-north.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/electrolyser/electrolyser-north-4.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		}}},
	east = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/electrolyser/electrolyser-east.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/electrolyser/electrolyser-east-4.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		}}},
	south = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/electrolyser/electrolyser-north.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/electrolyser/electrolyser-north-4.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		}}},
	west = {
		layers = {{
		filename = "__angelspetrochem__/graphics/entity/electrolyser/electrolyser-east.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/electrolyser/electrolyser-east-4.png",
        width = 224,
        height = 224,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		animation_speed = 0.5
		}}}
		}
	data.raw["assembling-machine"]["angels-electrolyser-4"].fluid_boxes =
    {
      {
        production_type = "input",
		pipe_picture = electrolyserpictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-2, -3} }}
      },
      {
        production_type = "input",
		pipe_picture = electrolyserpictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {2, -3} }}
      },
	  {
        production_type = "output",
		pipe_picture = electrolyserpictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-2, 3} }}
      },
	  {
        production_type = "output",
		pipe_picture = electrolyserpictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {2, 3} }}
      }
    }
end
end


if data.raw["assembling-machine"]["liquifier"] then 
if data.raw["assembling-machine"]["liquifier"] then
	iconset("liquifier","","-1")
	data.raw["assembling-machine"]["liquifier"].animation = {
		filename = "__ShinyAngelGFX__/graphics/entity/liquifier/liquifier-1.png",
        width = 160,
        height = 160,
		line_length = 10,
        frame_count = 30,
        shift = {0, 0},
		animation_speed = 0.5,
		}
end


if data.raw["assembling-machine"]["liquifier-2"] then 
	iconset("liquifier","-2","-2")
	
end


if data.raw["assembling-machine"]["liquifier-3"] then 
	iconset("liquifier","-3","-3")
	data.raw["assembling-machine"]["liquifier-3"].animation = {
		filename = "__ShinyAngelGFX__/graphics/entity/liquifier/liquifier-3.png",
        width = 160,
        height = 160,
		line_length = 10,
        frame_count = 30,
        shift = {0, 0},
		animation_speed = 0.5,
		}
end


if data.raw["assembling-machine"]["liquifier-4"] then 
	iconset("liquifier","-4","-4")
	data.raw["assembling-machine"]["liquifier-4"].animation = {
		filename = "__ShinyAngelGFX__/graphics/entity/liquifier/liquifier-4.png",
        width = 160,
        height = 160,
		line_length = 10,
        frame_count = 30,
        shift = {0, 0},
		animation_speed = 0.5,
		}
end
end


if data.raw["assembling-machine"]["washing-plant"] then 
	iconset("washing-plant","","-1")
end
	
	
if data.raw["assembling-machine"]["washing-plant-2"] then 
	iconset("washing-plant","-2","-2")
	data.raw["assembling-machine"]["washing-plant-2"].animation = {
		layers = {{
		filename = "__angelsrefining__/graphics/entity/washing-plant/washing-plant.png",
        width = 224,
        height = 224,
		line_length = 5,
        frame_count = 25,
        shift = {0, 0},
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/washing-plant/washing-plant-2.png",
        width = 224,
        height = 224,
		line_length = 5,
        frame_count = 25,
        shift = {0, 0},
		}}}
	data.raw["assembling-machine"]["washing-plant-2"].fluid_boxes =
    {
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, 3} }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {3, 0} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {0, -3} }}
      },
    }
end



if data.raw["assembling-machine"]["hydro-plant"] then 
if data.raw["assembling-machine"]["hydro-plant"] then 
	iconset("hydro-plant","","-1")
	data.raw["assembling-machine"]["hydro-plant"].animation = {
	layers = {{
		filename = "__angelsrefining__/graphics/entity/hydro-plant/1hydro-plant.png",
		priority = "extra-high",
        width = 288,
        height = 288,
        frame_count = 25,
		line_length = 5,
        shift = {0, 0},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/hydro-plant/1hydro-plant-1.png",
		priority = "extra-high",
        width = 288,
        height = 288,
        frame_count = 25,
		line_length = 5,
        shift = {0, 0},
		animation_speed = 0.5
		}}}
		data.raw["assembling-machine"]["hydro-plant"].fluid_boxes =
    {
      {
        production_type = "input",
		pipe_picture = hydropipepicturesb(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-2, -4} }}
      },
	  {
        production_type = "output",
		pipe_picture = hydropipepictures2b(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {2, 4} }}
      },
	  {
        production_type = "output",
		pipe_picture = hydropipepicturesb(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-2, 4} }}
      },
    }
end


if data.raw["assembling-machine"]["hydro-plant-2"] then 
	iconset("hydro-plant","-2","-2")
	data.raw["assembling-machine"]["hydro-plant-2"].animation = {
	layers = {{
		filename = "__angelsrefining__/graphics/entity/hydro-plant/1hydro-plant.png",
		priority = "extra-high",
        width = 288,
        height = 288,
        frame_count = 25,
		line_length = 5,
        shift = {0, 0},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/hydro-plant/1hydro-plant-2.png",
		priority = "extra-high",
        width = 288,
        height = 288,
        frame_count = 25,
		line_length = 5,
        shift = {0, 0},
		animation_speed = 0.5
		}}}
	data.raw["assembling-machine"]["hydro-plant-2"].fluid_boxes =
    {
      {
        production_type = "input",
		pipe_picture = hydropipepicturesb(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-2, -4} }}
      },
	  {
        production_type = "output",
		pipe_picture = hydropipepictures2b(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {2, 4} }}
      },
	  {
        production_type = "output",
		pipe_picture = hydropipepicturesb(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-2, 4} }}
      },
    }
end
end


if data.raw["assembling-machine"]["ore-processing-machine"] then
if data.raw["assembling-machine"]["ore-processing-machine"] then  
	iconset("ore-processing-machine","","-1")
	data.raw["assembling-machine"]["ore-processing-machine"].animation = {
	layers = {{
		filename = "__angelssmelting__/graphics/entity/ore-processing-machine/ore-processing-machine.png",
        width = 160,
        height = 160,
        frame_count = 25,
		line_length = 5,
        shift = {0, 0},
		animation_speed = 0.5,
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/ore-processing-machine/ore-processing-machine-1.png",
        width = 160,
        height = 160,
        frame_count = 25,
		line_length = 5,
        shift = {0, 0},
		animation_speed = 0.5,
		}}}
		end
		
if data.raw["assembling-machine"]["ore-processing-machine-2"] then 
	iconset("ore-processing-machine","-2","-2")
	data.raw["assembling-machine"]["ore-processing-machine-2"].animation = {
	layers = {{
		filename = "__angelssmelting__/graphics/entity/ore-processing-machine/ore-processing-machine.png",
        width = 160,
        height = 160,
        frame_count = 25,
		line_length = 5,
        shift = {0, 0},
		animation_speed = 0.5,
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/ore-processing-machine/ore-processing-machine-2.png",
        width = 160,
        height = 160,
        frame_count = 25,
		line_length = 5,
        shift = {0, 0},
		animation_speed = 0.5,
		}}}
end
		
		
if data.raw["assembling-machine"]["ore-processing-machine-3"] then 
	iconset("ore-processing-machine","-3","-3")
	data.raw["assembling-machine"]["ore-processing-machine-3"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/ore-processing-machine/ore-processing-machine.png",
        width = 160,
        height = 160,
        frame_count = 25,
		line_length = 5,
        shift = {0, 0},
		animation_speed = 0.5,
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/ore-processing-machine/ore-processing-machine-3.png",
        width = 160,
        height = 160,
        frame_count = 25,
		line_length = 5,
        shift = {0, 0},
		animation_speed = 0.5,
		}}}
end

if data.raw["assembling-machine"]["ore-processing-machine-4"] then 
	iconset("ore-processing-machine","-4","-4")
	data.raw["assembling-machine"]["ore-processing-machine-4"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/ore-processing-machine/ore-processing-machine.png",
        width = 160,
        height = 160,
        frame_count = 25,
		line_length = 5,
        shift = {0, 0},
		animation_speed = 0.5,
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/ore-processing-machine/ore-processing-machine-4.png",
        width = 160,
        height = 160,
        frame_count = 25,
		line_length = 5,
        shift = {0, 0},
		animation_speed = 0.5,
		}}}
end
end



if data.raw["assembling-machine"]["pellet-press"] then 
if data.raw["assembling-machine"]["pellet-press"] then 
	iconset("pellet-press","","-1")
	data.raw["assembling-machine"]["pellet-press"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/pellet-press/pellet-press.png",
        width = 160,
        height = 160,
		line_length = 10,
        frame_count = 60,
        shift = {0, 0},
		animation_speed = 0.5,
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/pellet-press/pellet-press-1.png",
        width = 160,
        height = 160,
		line_length = 10,
        frame_count = 60,
        shift = {0, 0},
		animation_speed = 0.5,
		}}}
end

if data.raw["assembling-machine"]["pellet-press-2"] then 
	iconset("pellet-press","-2","-2")
	data.raw["assembling-machine"]["pellet-press-2"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/pellet-press/pellet-press.png",
        width = 160,
        height = 160,
		line_length = 10,
        frame_count = 60,
        shift = {0, 0},
		animation_speed = 0.5,
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/pellet-press/pellet-press-2.png",
        width = 160,
        height = 160,
		line_length = 10,
        frame_count = 60,
        shift = {0, 0},
		animation_speed = 0.5,
		}}}
end

if data.raw["assembling-machine"]["pellet-press-3"] then 
	iconset("pellet-press","-3","-3")
	data.raw["assembling-machine"]["pellet-press-3"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/pellet-press/pellet-press.png",
        width = 160,
        height = 160,
		line_length = 10,
        frame_count = 60,
        shift = {0, 0},
		animation_speed = 0.5,
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/pellet-press/pellet-press-3.png",
        width = 160,
        height = 160,
		line_length = 10,
        frame_count = 60,
        shift = {0, 0},
		animation_speed = 0.5,
		}}}
end

if data.raw["assembling-machine"]["pellet-press-4"] then 
	iconset("pellet-press","-4","-4")
	data.raw["assembling-machine"]["pellet-press-4"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/pellet-press/pellet-press.png",
        width = 160,
        height = 160,
		line_length = 10,
        frame_count = 60,
        shift = {0, 0},
		animation_speed = 0.5,
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/pellet-press/pellet-press-4.png",
        width = 160,
        height = 160,
		line_length = 10,
        frame_count = 60,
        shift = {0, 0},
		animation_speed = 0.5,
		}}}
end
end


if data.raw["assembling-machine"]["casting-machine"] then 
if data.raw["assembling-machine"]["casting-machine"] then 
	iconset("casting-machine","","-1")
	data.raw["assembling-machine"]["casting-machine"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/casting-machine/casting-machine2.png",
        width = 224,
        height = 224,
		line_length = 7,
        frame_count = 49,
        shift = {0, 0},
		animation_speed = 0.5,
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/casting-machine/casting-machine2-1.png",
        width = 224,
        height = 224,
		line_length = 7,
        frame_count = 49,
        shift = {0, 0},
		animation_speed = 0.5,
		}}}
		data.raw["assembling-machine"]["casting-machine"].fluid_boxes =
    {
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {1, 2} }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-2, 1} }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, -2} }}
      }
    }
		
end



if data.raw["assembling-machine"]["casting-machine-2"] then 
	iconset("casting-machine","-2","-2")
	data.raw["assembling-machine"]["casting-machine-2"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/casting-machine/casting-machine2.png",
        width = 224,
        height = 224,
		line_length = 7,
        frame_count = 49,
        shift = {0, 0},
		animation_speed = 0.5,
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/casting-machine/casting-machine2-2.png",
        width = 224,
        height = 224,
		line_length = 7,
        frame_count = 49,
        shift = {0, 0},
		animation_speed = 0.5,
		}}}
		data.raw["assembling-machine"]["casting-machine-2"].fluid_boxes =
    {
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {1, 2} }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-2, 1} }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, -2} }}
      }
    }
		
end

if data.raw["assembling-machine"]["casting-machine-3"] then 
	iconset("casting-machine","-3","-3")
	data.raw["assembling-machine"]["casting-machine-3"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/casting-machine/casting-machine2.png",
        width = 224,
        height = 224,
		line_length = 7,
        frame_count = 49,
        shift = {0, 0},
		animation_speed = 0.5,
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/casting-machine/casting-machine2-3.png",
        width = 224,
        height = 224,
		line_length = 7,
        frame_count = 49,
        shift = {0, 0},
		animation_speed = 0.5,
		}}}
		data.raw["assembling-machine"]["casting-machine-3"].fluid_boxes =
    {
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {1, 2} }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-2, 1} }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, -2} }}
      }
    }
		
end

if data.raw["assembling-machine"]["casting-machine-4"] then 
	iconset("casting-machine","-4","-4")
	data.raw["assembling-machine"]["casting-machine-4"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/casting-machine/casting-machine2.png",
        width = 224,
        height = 224,
		line_length = 7,
        frame_count = 49,
        shift = {0, 0},
		animation_speed = 0.5,
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/casting-machine/casting-machine2-4.png",
        width = 224,
        height = 224,
		line_length = 7,
        frame_count = 49,
        shift = {0, 0},
		animation_speed = 0.5,
		}}}
		data.raw["assembling-machine"]["casting-machine-4"].fluid_boxes =
    {
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {1, 2} }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-2, 1} }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, -2} }}
      }
    }
		
end
end


if data.raw["assembling-machine"]["blast-furnace"] then 
if data.raw["assembling-machine"]["blast-furnace"] then 
	iconset("blast-furnace","","-1")
	data.raw["assembling-machine"]["blast-furnace"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/blast-furnace/blast-furnace.png",
        width = 224,
        height = 224,
		line_length = 5,
        frame_count = 25,
        shift = {0, 0},
		animation_speed = 0.75
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/blast-furnace/blast-furnace-1.png",
        width = 224,
        height = 224,
		line_length = 5,
        frame_count = 25,
        shift = {0, 0},
		animation_speed = 0.75
		}}}
	data.raw["assembling-machine"]["blast-furnace"].fluid_boxes =
    {
	off_when_no_fluid_recipe = true,
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, 3} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {0, -3} }}
      }
    }
		
end



if data.raw["assembling-machine"]["blast-furnace-2"] then 
	iconset("blast-furnace","-2","-2")
	data.raw["assembling-machine"]["blast-furnace-2"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/blast-furnace/blast-furnace.png",
        width = 224,
        height = 224,
		line_length = 5,
        frame_count = 25,
        shift = {0, 0},
		animation_speed = 0.75
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/blast-furnace/blast-furnace-2.png",
        width = 224,
        height = 224,
		line_length = 5,
        frame_count = 25,
        shift = {0, 0},
		animation_speed = 0.75
		}}}
	data.raw["assembling-machine"]["blast-furnace-2"].fluid_boxes =
    {
	off_when_no_fluid_recipe = true,
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, 3} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {0, -3} }}
      }
    }
		
end


if data.raw["assembling-machine"]["blast-furnace-3"] then 
	iconset("blast-furnace","-3","-3")
	data.raw["assembling-machine"]["blast-furnace-3"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/blast-furnace/blast-furnace.png",
        width = 224,
        height = 224,
		line_length = 5,
        frame_count = 25,
        shift = {0, 0},
		animation_speed = 0.75
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/blast-furnace/blast-furnace-3.png",
        width = 224,
        height = 224,
		line_length = 5,
        frame_count = 25,
        shift = {0, 0},
		animation_speed = 0.75
		}}}
	data.raw["assembling-machine"]["blast-furnace-3"].fluid_boxes =
    {
	off_when_no_fluid_recipe = true,
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, 3} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {0, -3} }}
      }
    }
		
end


if data.raw["assembling-machine"]["blast-furnace-4"] then 
	iconset("blast-furnace","-4","-4")
	data.raw["assembling-machine"]["blast-furnace-4"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/blast-furnace/blast-furnace.png",
        width = 224,
        height = 224,
		line_length = 5,
        frame_count = 25,
        shift = {0, 0},
		animation_speed = 0.75
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/blast-furnace/blast-furnace-4.png",
        width = 224,
        height = 224,
		line_length = 5,
        frame_count = 25,
        shift = {0, 0},
		animation_speed = 0.75
		}}}
	data.raw["assembling-machine"]["blast-furnace-4"].fluid_boxes =
    {
	off_when_no_fluid_recipe = true,
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, 3} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {0, -3} }}
      }
    }
		
end
end


if data.raw["assembling-machine"]["induction-furnace"] then 
if data.raw["assembling-machine"]["induction-furnace"] then 
	iconset("induction-furnace","","-1")
	data.raw["assembling-machine"]["induction-furnace"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/induction-furnace/induction-furnace.png",
        width = 224,
        height = 256,
		line_length = 6,
        frame_count = 36,
        shift = {0, -0.5},
		animation_speed = 0.2,
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/induction-furnace/induction-furnace-1.png",
        width = 224,
        height = 256,
		line_length = 6,
        frame_count = 36,
        shift = {0, -0.5},
		animation_speed = 0.2,
		}}}
data.raw["assembling-machine"]["induction-furnace"].fluid_boxes =
    {
      
      {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {2, -3} }}
      }
    }
		
end


if data.raw["assembling-machine"]["induction-furnace-2"] then 
	iconset("induction-furnace","-2","-2")
	data.raw["assembling-machine"]["induction-furnace-2"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/induction-furnace/induction-furnace.png",
        width = 224,
        height = 256,
		line_length = 6,
        frame_count = 36,
        shift = {0, -0.5},
		animation_speed = 0.2,
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/induction-furnace/induction-furnace-2.png",
        width = 224,
        height = 256,
		line_length = 6,
        frame_count = 36,
        shift = {0, -0.5},
		animation_speed = 0.2,
		}}}
data.raw["assembling-machine"]["induction-furnace-2"].fluid_boxes =
    {
      
      {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {2, -3} }}
      }
    }
		
end


if data.raw["assembling-machine"]["induction-furnace-3"] then 
	iconset("induction-furnace","-3","-3")
	data.raw["assembling-machine"]["induction-furnace-3"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/induction-furnace/induction-furnace.png",
        width = 224,
        height = 256,
		line_length = 6,
        frame_count = 36,
        shift = {0, -0.5},
		animation_speed = 0.2,
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/induction-furnace/induction-furnace-3.png",
        width = 224,
        height = 256,
		line_length = 6,
        frame_count = 36,
        shift = {0, -0.5},
		animation_speed = 0.2,
		}}}
data.raw["assembling-machine"]["induction-furnace-3"].fluid_boxes =
    {
      
      {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {2, -3} }}
      }
    }
		
end


if data.raw["assembling-machine"]["induction-furnace-4"] then 
	iconset("induction-furnace","-4","-4")
	data.raw["assembling-machine"]["induction-furnace-4"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/induction-furnace/induction-furnace.png",
        width = 224,
        height = 256,
		line_length = 6,
        frame_count = 36,
        shift = {0, -0.5},
		animation_speed = 0.2,
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/induction-furnace/induction-furnace-4.png",
        width = 224,
        height = 256,
		line_length = 6,
        frame_count = 36,
        shift = {0, -0.5},
		animation_speed = 0.2,
		}}}
data.raw["assembling-machine"]["induction-furnace-4"].fluid_boxes =
    {
      
      {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {2, -3} }}
      }
    }
		
end
end


if data.raw["assembling-machine"]["angels-chemical-furnace"] then
if data.raw["assembling-machine"]["angels-chemical-furnace"] then 
	iconset("angels-chemical-furnace","","-1")
	data.raw["assembling-machine"]["angels-chemical-furnace"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/chemical-furnace/chemical-furnace.png",
        width = 224,
        height = 224,
		line_length = 6,
        frame_count = 36,
        shift = {0, 0},
		animation_speed = 0.75
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/chemical-furnace/chemical-furnace-1.png",
        width = 224,
        height = 224,
		line_length = 6,
        frame_count = 36,
        shift = {0, 0},
		animation_speed = 0.75
		}}}
data.raw["assembling-machine"]["angels-chemical-furnace"].fluid_boxes =
    {
	off_when_no_fluid_recipe = true,
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, 3} }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {1, 3} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-1, -3} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {1, -3} }}
      }
    }
		
end


if data.raw["assembling-machine"]["angels-chemical-furnace-2"] then 
	iconset("angels-chemical-furnace","-2","-2")
	data.raw["assembling-machine"]["angels-chemical-furnace-2"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/chemical-furnace/chemical-furnace.png",
        width = 224,
        height = 224,
		line_length = 6,
        frame_count = 36,
        shift = {0, 0},
		animation_speed = 0.75
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/chemical-furnace/chemical-furnace-2.png",
        width = 224,
        height = 224,
		line_length = 6,
        frame_count = 36,
        shift = {0, 0},
		animation_speed = 0.75
		}}}
data.raw["assembling-machine"]["angels-chemical-furnace-2"].fluid_boxes =
    {
	off_when_no_fluid_recipe = true,
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, 3} }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {1, 3} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-1, -3} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {1, -3} }}
      }
    }
		
end


if data.raw["assembling-machine"]["angels-chemical-furnace-3"] then 
	iconset("angels-chemical-furnace","-3","-3")
	data.raw["assembling-machine"]["angels-chemical-furnace-3"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/chemical-furnace/chemical-furnace.png",
        width = 224,
        height = 224,
		line_length = 6,
        frame_count = 36,
        shift = {0, 0},
		animation_speed = 0.75
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/chemical-furnace/chemical-furnace-3.png",
        width = 224,
        height = 224,
		line_length = 6,
        frame_count = 36,
        shift = {0, 0},
		animation_speed = 0.75
		}}}
data.raw["assembling-machine"]["angels-chemical-furnace-3"].fluid_boxes =
    {
	off_when_no_fluid_recipe = true,
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, 3} }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {1, 3} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-1, -3} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {1, -3} }}
      }
    }
		
end


if data.raw["assembling-machine"]["angels-chemical-furnace-4"] then 
	iconset("angels-chemical-furnace","-4","-4")
	data.raw["assembling-machine"]["angels-chemical-furnace-4"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/chemical-furnace/chemical-furnace.png",
        width = 224,
        height = 224,
		line_length = 6,
        frame_count = 36,
        shift = {0, 0},
		animation_speed = 0.75
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/chemical-furnace/chemical-furnace-4.png",
        width = 224,
        height = 224,
		line_length = 6,
        frame_count = 36,
        shift = {0, 0},
		animation_speed = 0.75
		}}}
data.raw["assembling-machine"]["angels-chemical-furnace-4"].fluid_boxes =
    {
	off_when_no_fluid_recipe = true,
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, 3} }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {1, 3} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-1, -3} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {1, -3} }}
      }
    }
		
end
end


if data.raw["assembling-machine"]["sintering-oven"] then 
if data.raw["assembling-machine"]["sintering-oven"] then 
	iconset("sintering-oven","","-1")
	data.raw["assembling-machine"]["sintering-oven"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/sintering-oven/sintering-oven.png",
        width = 256,
        height = 256,
		line_length = 5,
        frame_count = 25,
        shift = {0.5, -0.5},
		animation_speed = 0.5,
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/sintering-oven/sintering-oven-1.png",
        width = 256,
        height = 256,
		line_length = 5,
        frame_count = 25,
        shift = {0.5, -0.5},
		animation_speed = 0.5,
		}}}
end


if data.raw["assembling-machine"]["sintering-oven-2"] then 
	iconset("sintering-oven","-2","-2")
	data.raw["assembling-machine"]["sintering-oven-2"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/sintering-oven/sintering-oven.png",
        width = 256,
        height = 256,
		line_length = 5,
        frame_count = 25,
        shift = {0.5, -0.5},
		animation_speed = 0.5,
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/sintering-oven/sintering-oven-2.png",
        width = 256,
        height = 256,
		line_length = 5,
        frame_count = 25,
        shift = {0.5, -0.5},
		animation_speed = 0.5,
		}}}
end


if data.raw["assembling-machine"]["sintering-oven-3"] then 
	iconset("sintering-oven","-3","-3")
	data.raw["assembling-machine"]["sintering-oven-3"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/sintering-oven/sintering-oven.png",
        width = 256,
        height = 256,
		line_length = 5,
        frame_count = 25,
        shift = {0.5, -0.5},
		animation_speed = 0.5,
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/sintering-oven/sintering-oven-3.png",
        width = 256,
        height = 256,
		line_length = 5,
        frame_count = 25,
        shift = {0.5, -0.5},
		animation_speed = 0.5,
		}}}
end
end

if data.raw["assembling-machine"]["sintering-oven-4"] then 
	iconset("sintering-oven","-4","-4")
	data.raw["assembling-machine"]["sintering-oven-4"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/sintering-oven/sintering-oven.png",
        width = 256,
        height = 256,
		line_length = 5,
        frame_count = 25,
        shift = {0.5, -0.5},
		animation_speed = 0.5,
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/sintering-oven/sintering-oven-4.png",
        width = 256,
        height = 256,
		line_length = 5,
        frame_count = 25,
        shift = {0.5, -0.5},
		animation_speed = 0.5,
		}}}
end

if data.raw["assembling-machine"]["powder-mixer"] then 
if data.raw["assembling-machine"]["powder-mixer"] then 
	iconset("powder-mixer","","-1")
	data.raw["assembling-machine"]["powder-mixer"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/powder-mixer/powder-mixer.png",
        width = 256,
        height = 256,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		scale = 0.5,
		animation_speed = 0.5,
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/powder-mixer/powder-mixer-1.png",
        width = 256,
        height = 256,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		scale = 0.5,
		animation_speed = 0.5,
		}}}
end		



if data.raw["assembling-machine"]["powder-mixer-2"] then 
	iconset("powder-mixer","-2","-2")
	data.raw["assembling-machine"]["powder-mixer-2"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/powder-mixer/powder-mixer.png",
        width = 256,
        height = 256,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		scale = 0.5,
		animation_speed = 0.5,
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/powder-mixer/powder-mixer-2.png",
        width = 256,
        height = 256,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		scale = 0.5,
		animation_speed = 0.5,
		}}}
end		


if data.raw["assembling-machine"]["powder-mixer-3"] then 
	iconset("powder-mixer","-3","-3")
	data.raw["assembling-machine"]["powder-mixer-3"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/powder-mixer/powder-mixer.png",
        width = 256,
        height = 256,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		scale = 0.5,
		animation_speed = 0.5,
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/powder-mixer/powder-mixer-3.png",
        width = 256,
        height = 256,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		scale = 0.5,
		animation_speed = 0.5,
		}}}
end		


if data.raw["assembling-machine"]["powder-mixer-4"] then 
	iconset("powder-mixer","-4","-4")
	data.raw["assembling-machine"]["powder-mixer-4"].animation = {
	layers = {{
filename = "__angelssmelting__/graphics/entity/powder-mixer/powder-mixer.png",
        width = 256,
        height = 256,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		scale = 0.5,
		animation_speed = 0.5,
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/powder-mixer/powder-mixer-4.png",
        width = 256,
        height = 256,
        frame_count = 36,
		line_length = 6,
        shift = {0, 0},
		scale = 0.5,
		animation_speed = 0.5,
		}}}
end		
end		
end		

if data.raw["assembling-machine"]["burner-ore-crusher"] then	
if settings.startup["usecolorbars"].value == true then
	-- data.raw["assembling-machine"]["burner-ore-crusher"].icons = {
		-- {
			-- icon = "__angelsrefining__/graphics/icons/ore-crusher-burner.png",
		-- },
		-- {
			-- icon = "__ShinyAngelGFX__/graphics/icons/num-0.png",
		-- }
	-- }
	-- data.raw["recipe"]["burner-ore-crusher"].icons = {
		-- {
			-- icon = "__angelsrefining__/graphics/icons/ore-crusher-burner.png",
		-- },
		-- {
			-- icon = "__ShinyAngelGFX__/graphics/icons/num-0.png",
		-- }
	-- }
	data.raw["item"]["burner-ore-crusher"].icons = {
		{
			icon = "__angelsrefining__/graphics/icons/ore-crusher-burner.png",
		},
		{
			icon = "__ShinyAngelGFX__/graphics/icons/num-0.png",
		}
	}
	else
	-- data.raw["assembling-machine"]["burner-ore-crusher"].icons = {
		-- {
			-- icon = "__angelsrefining__/graphics/icons/ore-crusher-burner.png",
		-- }}
	-- data.raw["recipe"]["burner-ore-crusher"].icons = {
		-- {
			-- icon = "__angelsrefining__/graphics/icons/ore-crusher-burner.png",
		-- }}
	data.raw["item"]["burner-ore-crusher"].icons = {
		{
			icon = "__angelsrefining__/graphics/icons/ore-crusher-burner.png",
		}}
end
end
		
		
if data.raw["assembling-machine"]["ore-crusher"] then 
	iconsetspec("ore-crusher","","-1")
	data.raw["assembling-machine"]["ore-crusher"].animation = {
	layers = {{
filename = "__angelsrefining__/graphics/entity/ore-crusher/1ore-crusher.png",
        priority = "extra-high",
        width = 128,
        height = 128,
        frame_count = 16,
		line_length = 4,
        shift = {0.45, -0.25},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/ore-crusher/1ore-crusher-1.png",
        priority = "extra-high",
        width = 128,
        height = 128,
        frame_count = 16,
		line_length = 4,
        shift = {0.45, -0.25},
		animation_speed = 0.5
		}}}
end



if data.raw["assembling-machine"]["ore-crusher-2"] then 
	iconsetspec("ore-crusher","-2","-2")
	data.raw["assembling-machine"]["ore-crusher-2"].animation = {
	layers = {{
filename = "__angelsrefining__/graphics/entity/ore-crusher/1ore-crusher.png",
        priority = "extra-high",
        width = 128,
        height = 128,
        frame_count = 16,
		line_length = 4,
        shift = {0.45, -0.25},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/ore-crusher/1ore-crusher-2.png",
        priority = "extra-high",
        width = 128,
        height = 128,
        frame_count = 16,
		line_length = 4,
        shift = {0.45, -0.25},
		animation_speed = 0.5
		}}}
end


if data.raw["assembling-machine"]["ore-crusher-3"] then 
	iconsetspec("ore-crusher","-3","-3")
	data.raw["assembling-machine"]["ore-crusher-3"].animation = {
	layers = {{
filename = "__angelsrefining__/graphics/entity/ore-crusher/1ore-crusher.png",
        priority = "extra-high",
        width = 128,
        height = 128,
        frame_count = 16,
		line_length = 4,
        shift = {0.45, -0.25},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/ore-crusher/1ore-crusher-3.png",
        priority = "extra-high",
        width = 128,
        height = 128,
        frame_count = 16,
		line_length = 4,
        shift = {0.45, -0.25},
		animation_speed = 0.5
		}}}
end



if data.raw["assembling-machine"]["ore-sorting-facility"] then 
	iconsetspec("ore-sorting-facility","","-1")
	data.raw["assembling-machine"]["ore-sorting-facility"].animation = {
	layers = {{
filename = "__angelsrefining__/graphics/entity/ore-sorting-facility/1ore-sorting-facility.png",
        priority = "extra-high",
        width = 256,
        height = 256,
        frame_count = 40,
		line_length = 8,
        shift = {0.5, 0},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/ore-sorting-facility/1ore-sorting-facility-1.png",
        priority = "extra-high",
        width = 256,
        height = 256,
        frame_count = 40,
		line_length = 8,
        shift = {0.5, 0},
		animation_speed = 0.5
		}}}
end


if data.raw["assembling-machine"]["ore-sorting-facility-2"] then 
	iconsetspec("ore-sorting-facility","-2","-2")
	data.raw["assembling-machine"]["ore-sorting-facility-2"].animation = {
	layers = {{
filename = "__angelsrefining__/graphics/entity/ore-sorting-facility/1ore-sorting-facility.png",
        priority = "extra-high",
        width = 256,
        height = 256,
        frame_count = 40,
		line_length = 8,
        shift = {0.5, 0},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/ore-sorting-facility/1ore-sorting-facility-2.png",
        priority = "extra-high",
        width = 256,
        height = 256,
        frame_count = 40,
		line_length = 8,
        shift = {0.5, 0},
		animation_speed = 0.5
		}}}
end

if data.raw["assembling-machine"]["ore-sorting-facility-3"] then 
	iconsetspec("ore-sorting-facility","-3","-3")
	data.raw["assembling-machine"]["ore-sorting-facility-3"].animation = {
	layers = {{
filename = "__angelsrefining__/graphics/entity/ore-sorting-facility/1ore-sorting-facility.png",
        priority = "extra-high",
        width = 256,
        height = 256,
        frame_count = 40,
		line_length = 8,
        shift = {0.5, 0},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/ore-sorting-facility/1ore-sorting-facility-3.png",
        priority = "extra-high",
        width = 256,
        height = 256,
        frame_count = 40,
		line_length = 8,
        shift = {0.5, 0},
		animation_speed = 0.5
		}}}
end

if data.raw["assembling-machine"]["ore-sorting-facility-4"] then 
	iconsetspec("ore-sorting-facility","-4","-4")
	data.raw["assembling-machine"]["ore-sorting-facility-4"].animation = {
	layers = {{
filename = "__angelsrefining__/graphics/entity/ore-sorting-facility/1ore-sorting-facility.png",
        priority = "extra-high",
        width = 256,
        height = 256,
        frame_count = 40,
		line_length = 8,
        shift = {0.5, 0},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/ore-sorting-facility/1ore-sorting-facility-4.png",
        priority = "extra-high",
        width = 256,
        height = 256,
        frame_count = 40,
		line_length = 8,
        shift = {0.5, 0},
		animation_speed = 0.5
		}}}
end





if data.raw["assembling-machine"]["ore-floatation-cell"] then 
	iconsetspec("ore-floatation-cell","","-1")
	data.raw["assembling-machine"]["ore-floatation-cell"].animation = {
	layers = {{
filename = "__angelsrefining__/graphics/entity/ore-floatation-cell/1ore-floatation-cell.png",
        priority = "extra-high",
        width = 192,
        height = 192,
        frame_count = 16,
		line_length = 4,
        shift = {0.45, 0.7},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/ore-floatation-cell/1ore-floatation-cell-1.png",
        priority = "extra-high",
        width = 192,
        height = 192,
        frame_count = 16,
		line_length = 4,
        shift = {0.45, 0.7},
		animation_speed = 0.5
		}}}
data.raw["assembling-machine"]["ore-floatation-cell"].fluid_boxes =
    {
      {
        production_type = "input",
		pipe_picture = floatationpipepicturesb(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, 3} }}
      },
      {
        production_type = "output",
		pipe_picture = floatationpipepicturesb(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {0, -3} }}
      }
    }
end


if data.raw["assembling-machine"]["ore-floatation-cell-2"] then 
	iconsetspec("ore-floatation-cell","-2","-2")
	data.raw["assembling-machine"]["ore-floatation-cell-2"].animation = {
	layers = {{
filename = "__angelsrefining__/graphics/entity/ore-floatation-cell/1ore-floatation-cell.png",
        priority = "extra-high",
        width = 192,
        height = 192,
        frame_count = 16,
		line_length = 4,
        shift = {0.45, 0.7},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/ore-floatation-cell/1ore-floatation-cell-2.png",
        priority = "extra-high",
        width = 192,
        height = 192,
        frame_count = 16,
		line_length = 4,
        shift = {0.45, 0.7},
		animation_speed = 0.5
		}}}
data.raw["assembling-machine"]["ore-floatation-cell-2"].fluid_boxes =
    {
      {
        production_type = "input",
		pipe_picture = floatationpipepicturesb(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, 3} }}
      },
      {
        production_type = "output",
		pipe_picture = floatationpipepicturesb(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {0, -3} }}
      }
    }
end


if data.raw["assembling-machine"]["ore-floatation-cell-3"] then 
	iconsetspec("ore-floatation-cell","-3","-3")
	data.raw["assembling-machine"]["ore-floatation-cell-3"].animation = {
	layers = {{
filename = "__angelsrefining__/graphics/entity/ore-floatation-cell/1ore-floatation-cell.png",
        priority = "extra-high",
        width = 192,
        height = 192,
        frame_count = 16,
		line_length = 4,
        shift = {0.45, 0.7},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/ore-floatation-cell/1ore-floatation-cell-3.png",
        priority = "extra-high",
        width = 192,
        height = 192,
        frame_count = 16,
		line_length = 4,
        shift = {0.45, 0.7},
		animation_speed = 0.5
		}}}
data.raw["assembling-machine"]["ore-floatation-cell-3"].fluid_boxes =
    {
      {
        production_type = "input",
		pipe_picture = floatationpipepicturesb(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, 3} }}
      },
      {
        production_type = "output",
		pipe_picture = floatationpipepicturesb(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {0, -3} }}
      }
    }
end



if data.raw["assembling-machine"]["ore-leaching-plant"] then 
	iconsetspec("ore-leaching-plant","","-1")
	data.raw["assembling-machine"]["ore-leaching-plant"].animation = {
	layers = {{
filename = "__angelsrefining__/graphics/entity/ore-leaching-plant/1ore-leaching-plant.png",
        priority = "extra-high",
        width = 192,
        height = 192,
        frame_count = 1,
        shift = {0.4, -0.14},
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/ore-leaching-plant/1ore-leaching-plant-1.png",
        priority = "extra-high",
        width = 192,
        height = 192,
        frame_count = 1,
        shift = {0.4, -0.14},
		}}}
data.raw["assembling-machine"]["ore-leaching-plant"].fluid_boxes =
    {
      {
        production_type = "input",
		pipe_picture = leachingpipepicturesb(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {1, 3} }}
      },
	  {
        production_type = "output",
		pipe_picture = leachingpipepicturesb(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-1, -3} }}
      },
    }
end


if data.raw["assembling-machine"]["ore-leaching-plant-2"] then 
	iconsetspec("ore-leaching-plant","-2","-2")
	data.raw["assembling-machine"]["ore-leaching-plant-2"].animation = {
	layers = {{
filename = "__angelsrefining__/graphics/entity/ore-leaching-plant/1ore-leaching-plant.png",
        priority = "extra-high",
        width = 192,
        height = 192,
        frame_count = 1,
        shift = {0.4, -0.14},
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/ore-leaching-plant/1ore-leaching-plant-2.png",
        priority = "extra-high",
        width = 192,
        height = 192,
        frame_count = 1,
        shift = {0.4, -0.14},
		}}}
data.raw["assembling-machine"]["ore-leaching-plant-2"].fluid_boxes =
    {
      {
        production_type = "input",
		pipe_picture = leachingpipepicturesb(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {1, 3} }}
      },
	  {
        production_type = "output",
		pipe_picture = leachingpipepicturesb(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-1, -3} }}
      },
    }
end


if data.raw["assembling-machine"]["ore-leaching-plant-3"] then 
	iconsetspec("ore-leaching-plant","-3","-3")
	data.raw["assembling-machine"]["ore-leaching-plant-3"].animation = {
	layers = {{
filename = "__angelsrefining__/graphics/entity/ore-leaching-plant/1ore-leaching-plant.png",
        priority = "extra-high",
        width = 192,
        height = 192,
        frame_count = 1,
        shift = {0.4, -0.14},
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/ore-leaching-plant/1ore-leaching-plant-3.png",
        priority = "extra-high",
        width = 192,
        height = 192,
        frame_count = 1,
        shift = {0.4, -0.14},
		}}}
data.raw["assembling-machine"]["ore-leaching-plant-3"].fluid_boxes =
    {
      {
        production_type = "input",
		pipe_picture = leachingpipepicturesb(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {1, 3} }}
      },
	  {
        production_type = "output",
		pipe_picture = leachingpipepicturesb(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {-1, -3} }}
      },
    }
end


if data.raw["assembling-machine"]["ore-refinery"] then 
	iconsetspec("ore-refinery","","-1")
	data.raw["assembling-machine"]["ore-refinery"].animation = {
	layers = {{
filename = "__angelsrefining__/graphics/entity/ore-refinery/1ore-refinery.png",
        width = 256,
        height = 256,
        frame_count = 16,
		line_length = 4,
		animation_speed = 0.5,
        shift = {0.5, -0.5},
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/ore-refinery/1ore-refinery-1.png",
        width = 256,
        height = 256,
        frame_count = 16,
		line_length = 4,
		animation_speed = 0.5,
        shift = {0.5, -0.5},
		}}}
end	
		
		
		
if data.raw["assembling-machine"]["ore-refinery-2"] then 
	iconsetspec("ore-refinery","-2","-2")
	data.raw["assembling-machine"]["ore-refinery-2"].animation = {
	layers = {{
filename = "__angelsrefining__/graphics/entity/ore-refinery/1ore-refinery.png",
        width = 256,
        height = 256,
        frame_count = 16,
		line_length = 4,
		animation_speed = 0.5,
        shift = {0.5, -0.5},
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/ore-refinery/1ore-refinery-2.png",
        width = 256,
        height = 256,
        frame_count = 16,
		line_length = 4,
		animation_speed = 0.5,
        shift = {0.5, -0.5},
		}}}
end	



if data.raw["assembling-machine"]["salination-plant"] then 
	iconset("salination-plant","","-1")
	data.raw["assembling-machine"]["salination-plant"].animation = {
	layers = {{
filename = "__angelsrefining__/graphics/entity/salination-plant/salination-plant.png",
        priority = "extra-high",
        width = 288,
        height = 320,
        frame_count = 36,
		line_length = 6,
        shift = {0, -0.5},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/salination-plant/salination-plant-1.png",
        priority = "extra-high",
        width = 288,
        height = 320,
        frame_count = 36,
		line_length = 6,
        shift = {0, -0.5},
		animation_speed = 0.5
		}}}
data.raw["assembling-machine"]["salination-plant"].fluid_boxes =
    {
      {
        production_type = "input",
		pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, -4} }}
      },
	  {
        production_type = "output",
		pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {1, 4} }}
      },
    }
end


if data.raw["assembling-machine"]["salination-plant-2"] then 
	iconset("salination-plant","-2","-2")
	data.raw["assembling-machine"]["salination-plant-2"].animation = {
	layers = {{
filename = "__angelsrefining__/graphics/entity/salination-plant/salination-plant.png",
        priority = "extra-high",
        width = 288,
        height = 320,
        frame_count = 36,
		line_length = 6,
        shift = {0, -0.5},
		animation_speed = 0.5
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/salination-plant/salination-plant-2.png",
        priority = "extra-high",
        width = 288,
        height = 320,
        frame_count = 36,
		line_length = 6,
        shift = {0, -0.5},
		animation_speed = 0.5
		}}}
data.raw["assembling-machine"]["salination-plant-2"].fluid_boxes =
    {
      {
        production_type = "input",
		pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, -4} }}
      },
	  {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {1, 4} }}
      },
    }
end



if data.raw["assembling-machine"]["filtration-unit"] then 
	iconset("filtration-unit","","-1")
end



if data.raw["assembling-machine"]["filtration-unit-2"] then 
	iconset("filtration-unit","-2","-2")
	data.raw["assembling-machine"]["filtration-unit-2"].animation = {
	layers = {{
filename = "__angelsrefining__/graphics/entity/filtration-unit/filtration-unit.png",
        width = 224,
        height = 224,
        frame_count = 1,
        shift = {0, -0.2}
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/filtration-unit/filtration-unit-2.png",
        width = 224,
        height = 224,
        frame_count = 1,
        shift = {0, -0.2}
		}}}
	data.raw["assembling-machine"]["filtration-unit-2"].fluid_boxes =
    {
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
		pipe_picture = filtrationpipepictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {1, 3} }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
		pipe_picture = filtrationpipepictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, 3} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
		pipe_picture = filtrationpipepictures(),
        base_level = 1,
        pipe_connections = {{ position = {1, -3} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures2(),
		pipe_picture = filtrationpipepictures(),
        base_level = 1,
        pipe_connections = {{ position = {-1, -3} }}
      }
    }
end





if data.raw["assembling-machine"]["crystallizer"] then 
	iconset("crystallizer","","-1")
	data.raw["assembling-machine"]["crystallizer"].animation = {
	layers = {{
filename = "__angelsrefining__/graphics/entity/crystallizer/crystallizer.png",
        width = 192,
        height = 192,
        frame_count = 1,
        shift = {0.5, -0.5}
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/crystallizer/crystallizer-1.png",
        width = 192,
        height = 192,
        frame_count = 1,
        shift = {0.5, -0.5}
		}}}
	data.raw["assembling-machine"]["crystallizer"].fluid_boxes =
    {
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
		pipe_picture = crystallizerpipepicturesb(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, 3} }}
      },
    }
end



if data.raw["assembling-machine"]["crystallizer-2"] then 
	iconset("crystallizer","-2","-2")
	data.raw["assembling-machine"]["crystallizer-2"].animation = {
	layers = {{
filename = "__angelsrefining__/graphics/entity/crystallizer/crystallizer.png",
        width = 192,
        height = 192,
        frame_count = 1,
        shift = {0.5, -0.5}
		},{
		filename = "__ShinyAngelGFX__/graphics/entity/crystallizer/crystallizer-2.png",
        width = 192,
        height = 192,
        frame_count = 1,
        shift = {0.5, -0.5}
		}}}
	data.raw["assembling-machine"]["crystallizer-2"].fluid_boxes =
    {
      {
        production_type = "input",
        pipe_covers = pipecoverspictures2(),
		pipe_picture = crystallizerpipepicturesb(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, 3} }}
      },
	}
end



if data.raw["assembling-machine"]["strand-casting-machine"] then 
	iconset("strand-casting-machine","","-1")
	data.raw["assembling-machine"]["strand-casting-machine"].animation ={
        width = 448,
        height = 448,
        frame_count = 24,
		animation_speed = 0.5,
		scale = 0.5,
		shift = {0, 0},
		stripes = {
			{
				filename = "__ShinyAngelGFX__/graphics/entity/strand-casting-machine/strand-casting-1y.png",
				width_in_frames = 4,
				height_in_frames = 3,
			},
			{
				filename = "__ShinyAngelGFX__/graphics/entity/strand-casting-machine/strand-casting-2y.png",
				width_in_frames = 4,
				height_in_frames = 3,
			},	
		}
    }
	data.raw["assembling-machine"]["strand-casting-machine"].fluid_boxes =
    {
      {
        production_type = "input",
        --pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, 3} }}
      },
      {
        production_type = "input",
        --pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {1, 3} }}
      },
      {
        production_type = "input",
        --pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, -3} }}
      },
      {
        production_type = "output",
        --pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {1, -3} }}
      }
    }
end


if data.raw["assembling-machine"]["strand-casting-machine-2"] then 
	iconset("strand-casting-machine","-2","-2")
	data.raw["assembling-machine"]["strand-casting-machine-2"].animation ={
        width = 448,
        height = 448,
        frame_count = 24,
		animation_speed = 0.5,
		scale = 0.5,
		shift = {0, 0},
		stripes = {
			{
				filename = "__ShinyAngelGFX__/graphics/entity/strand-casting-machine/strand-casting-1r.png",
				width_in_frames = 4,
				height_in_frames = 3,
			},
			{
				filename = "__ShinyAngelGFX__/graphics/entity/strand-casting-machine/strand-casting-2r.png",
				width_in_frames = 4,
				height_in_frames = 3,
			},	
		}
    }
	data.raw["assembling-machine"]["strand-casting-machine-2"].fluid_boxes =
    {
      {
        production_type = "input",
        --pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, 3} }}
      },
      {
        production_type = "input",
        --pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {1, 3} }}
      },
      {
        production_type = "input",
        --pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, -3} }}
      },
      {
        production_type = "output",
        --pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {1, -3} }}
      }
    }
end


if data.raw["assembling-machine"]["strand-casting-machine-3"] then 
	iconset("strand-casting-machine","-3","-3")
	data.raw["assembling-machine"]["strand-casting-machine-3"].animation ={
        width = 448,
        height = 448,
        frame_count = 24,
		animation_speed = 0.5,
		scale = 0.5,
		shift = {0, 0},
		stripes = {
			{
				filename = "__ShinyAngelGFX__/graphics/entity/strand-casting-machine/strand-casting-1b.png",
				width_in_frames = 4,
				height_in_frames = 3,
			},
			{
				filename = "__ShinyAngelGFX__/graphics/entity/strand-casting-machine/strand-casting-2b.png",
				width_in_frames = 4,
				height_in_frames = 3,
			},	
		}
    }
	data.raw["assembling-machine"]["strand-casting-machine-3"].fluid_boxes =
    {
      {
        production_type = "input",
        --pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, 3} }}
      },
      {
        production_type = "input",
        --pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {1, 3} }}
      },
      {
        production_type = "input",
        --pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, -3} }}
      },
      {
        production_type = "output",
        --pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {1, -3} }}
      }
    }
end


if data.raw["assembling-machine"]["strand-casting-machine-4"] then 
	iconset("strand-casting-machine","-4","-4")
	data.raw["assembling-machine"]["strand-casting-machine-4"].animation ={
        width = 448,
        height = 448,
        frame_count = 24,
		animation_speed = 0.5,
		scale = 0.5,
		shift = {0, 0},
		stripes = {
			{
				filename = "__ShinyAngelGFX__/graphics/entity/strand-casting-machine/strand-casting-1p.png",
				width_in_frames = 4,
				height_in_frames = 3,
			},
			{
				filename = "__ShinyAngelGFX__/graphics/entity/strand-casting-machine/strand-casting-2p.png",
				width_in_frames = 4,
				height_in_frames = 3,
			},	
		}
    }
	data.raw["assembling-machine"]["strand-casting-machine-4"].fluid_boxes =
    {
      {
        production_type = "input",
        --pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, 3} }}
      },
      {
        production_type = "input",
        --pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {1, 3} }}
      },
      {
        production_type = "input",
        --pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, -3} }}
      },
      {
        production_type = "output",
        --pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures2(),
        base_level = 1,
        pipe_connections = {{ position = {1, -3} }}
      }
    }
end


 
if data.raw["assembling-machine"]["oil-refinery-2"] then 
	iconset("oil-refinery","-2","-2")
end

if data.raw["assembling-machine"]["oil-refinery-3"] then 
	iconset("oil-refinery","-3","-3")
end

if data.raw["assembling-machine"]["oil-refinery-4"] then 
	iconset("oil-refinery","-4","-4")
end

if data.raw["assembling-machine"]["chemical-plant-2"] then 
	iconset("chemical-plant","-2","-2")
end

if data.raw["assembling-machine"]["chemical-plant-3"] then 
	iconset("chemical-plant","-3","-3")
end

if data.raw["assembling-machine"]["chemical-plant-4"] then 
	iconset("chemical-plant","-4","-4")
end













