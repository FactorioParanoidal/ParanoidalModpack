require ("demo-pipecovers")
require ("assemblerpipes")

local burnerMiner = data.raw["mining-drill"]["burner-mining-drill"]

burnerMiner.input_fluid_box =
    {
      production_type = "input",
      pipe_picture = assembler2pipepictures(),
      pipe_covers = pipecoverspictures(),
      base_area = 1,
      height = 1,
      base_level = -1,
      pipe_connections =
      {
        { position = {0.5, 1.5} },
      }
    }
	
--[[	
burnerMiner.output_fluid_box =
	{
	  base_area = 1,
      height = 1,
      base_level = 1,
      pipe_picture = assembler2pipepictures(),
      pipe_covers = pipecoverspictures(),
      pipe_connections =
      {
        { position = {0.5, 1.5} },
      }
    }

]]

data:extend{burnerMiner}