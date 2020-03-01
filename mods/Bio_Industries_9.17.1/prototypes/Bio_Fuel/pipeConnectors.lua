-- if settings.startup["BI_Bio_Infinite_Fluids"] and settings.startup["BI_Bio_Infinite_Fluids"].value == true then

	--[[
	function pipecoverspictures()
	  return
	  {
		north =
		{
		  filename = "__base__/graphics/entity/assembling-machine-2/assembling-machine-2-pipe-N.png",
		  priority = "extra-high",
		  width = 35,
		  height = 18,
		  shift = util.by_pixel(2.5, 14),
		  hr_version = {
			filename = "__base__/graphics/entity/assembling-machine-2/hr-assembling-machine-2-pipe-N.png",
			priority = "extra-high",
			width = 71,
			height = 38,
			shift = util.by_pixel(2.25, 13.5),
			scale = 0.5,
		  }
		},
		east =
		{
		  filename = "__base__/graphics/entity/assembling-machine-2/assembling-machine-2-pipe-E.png",
		  priority = "extra-high",
		  width = 20,
		  height = 38,
		  shift = util.by_pixel(-25, 1),
		  hr_version = {
			filename = "__base__/graphics/entity/assembling-machine-2/hr-assembling-machine-2-pipe-E.png",
			priority = "extra-high",
			width = 42,
			height = 76,
			shift = util.by_pixel(-24.5, 1),
			scale = 0.5,
		  }
		},
		south =
		{
		  filename = "__base__/graphics/entity/assembling-machine-2/assembling-machine-2-pipe-S.png",
		  priority = "extra-high",
		  width = 44,
		  height = 31,
		  shift = util.by_pixel(0, -31.5),
		  hr_version = {
			filename = "__base__/graphics/entity/assembling-machine-2/hr-assembling-machine-2-pipe-S.png",
			priority = "extra-high",
			width = 88,
			height = 61,
			shift = util.by_pixel(0, -31.25),
			scale = 0.5,
		  }
		},
		west =
		{
		  filename = "__base__/graphics/entity/assembling-machine-2/assembling-machine-2-pipe-W.png",
		  priority = "extra-high",
		  width = 19,
		  height = 37,
		  shift = util.by_pixel(25.5, 1.5),
		  hr_version = {
			filename = "__base__/graphics/entity/assembling-machine-2/hr-assembling-machine-2-pipe-W.png",
			priority = "extra-high",
			width = 39,
			height = 73,
			shift = util.by_pixel(25.75, 1.25),
			scale = 0.5,
		  }
		}
	  }
	end

	]]
--[[
	function assembler2pipepicturesCokery()
	  return
	  {
		north =
		{
		  filename = "__Bio_Industries__/graphics/icons/empty.png",
		  priority = "extra-high",
		  width = 35,
		  height = 18,
		  shift = util.by_pixel(2.5, 14),
		  hr_version = {
			filename = "__Bio_Industries__/graphics/icons/empty.png",
			priority = "extra-high",
			width = 71,
			height = 38,
			shift = util.by_pixel(2.25, 13.5),
			scale = 0.5,
		  }
		},
		east =
		{
		  filename = "__base__/graphics/entity/assembling-machine-2/assembling-machine-2-pipe-E.png",
		  priority = "extra-high",
		  width = 20,
		  height = 38,
		  shift = util.by_pixel(-25, 1),
		  hr_version = {
			filename = "__base__/graphics/entity/assembling-machine-2/hr-assembling-machine-2-pipe-E.png",
			priority = "extra-high",
			width = 42,
			height = 76,
			shift = util.by_pixel(-24.5, 1),
			scale = 0.5,
		  }
		},
		south =
		{
		  filename = "__Bio_Industries__/graphics/icons/empty.png",
		  priority = "extra-high",
		  width = 44,
		  height = 31,
		  shift = util.by_pixel(0, -31.5),
		  hr_version = {
			filename = "__Bio_Industries__/graphics/icons/empty.png",
			priority = "extra-high",
			width = 88,
			height = 61,
			shift = util.by_pixel(0, -31.25),
			scale = 0.5,
		  }
		},
		west =
		{
		  filename = "__base__/graphics/entity/assembling-machine-2/assembling-machine-2-pipe-W.png",
		  priority = "extra-high",
		  width = 19,
		  height = 37,
		  shift = util.by_pixel(25.5, 1.5),
		  hr_version = {
			filename = "__base__/graphics/entity/assembling-machine-2/hr-assembling-machine-2-pipe-W.png",
			priority = "extra-high",
			width = 39,
			height = 73,
			shift = util.by_pixel(25.75, 1.25),
			scale = 0.5,
		  }
		}
	  }
	end


	function assembler2pipepicturesCokery()
	  return
	  {
		north =
		{
		  filename = "__Bio_Industries__/graphics/icons/empty.png",
		  priority = "extra-high",
		  width = 32,
		  height = 32,
		  shift = {0.09375, 0.4375}
		},
		east =
		{
		  filename = "__base__/graphics/entity/assembling-machine-2/pipe-east.png",
		  priority = "extra-high",
		  width = 41,
		  height = 40,
		  shift = {-0.71875, 0}
		},
		south =
		{
		  filename = "__Bio_Industries__/graphics/icons/empty.png",
		  priority = "extra-high",
		  width = 32,
		  height = 32,
		  shift = {0.0625, -1}
		},
		west =
		{
		  filename = "__base__/graphics/entity/assembling-machine-2/pipe-west.png",
		  priority = "extra-high",
		  width = 41,
		  height = 40,
		  shift = {0.78125, 0.03125}
		}
	  }
	end


	function pipecoverspicturesCokery()
	  return {
		north =
		{
		  filename = "__Bio_Industries__/graphics/icons/empty.png",
		  priority = "extra-high",
		  width = 64,
		  height = 64,
		  hr_version =
		  {
			filename = "__Bio_Industries__/graphics/icons/empty.png",
			priority = "extra-high",
			width = 128,
			height = 128,
			scale = 0.5
		  }
		},
		east =
		{
		  filename = "__base__/graphics/entity/pipe-covers/pipe-cover-east.png",
		  priority = "extra-high",
		  width = 64,
		  height = 64,
		  hr_version =
		  {
			filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-east.png",
			priority = "extra-high",
			width = 128,
			height = 128,
			scale = 0.5
		  }
		},
		south =
		{
		  filename = "__Bio_Industries__/graphics/icons/empty.png",
		  priority = "extra-high",
		  width = 64,
		  height = 64,
		  hr_version =
		  {
			filename = "__Bio_Industries__/graphics/icons/empty.png",
			priority = "extra-high",
			width = 128,
			height = 128,
			scale = 0.5
		  }
		},
		west =
		{
		  filename = "__base__/graphics/entity/pipe-covers/pipe-cover-west.png",
		  priority = "extra-high",
		  width = 64,
		  height = 64,
		  hr_version =
		  {
			filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-west.png",
			priority = "extra-high",
			width = 128,
			height = 128,
			scale = 0.5
		  }
		}
	  }
	end
]]

	function assembler2pipepicturesBioreactor()
	  return
	  {
		north =
		{
		  filename = "__Bio_Industries__/graphics/icons/empty.png",
		  priority = "extra-high",
		  width = 1,
		  height = 1,
		  shift = util.by_pixel(2.5, 14),
		  hr_version = {
			filename = "__Bio_Industries__/graphics/icons/empty.png",
			priority = "extra-high",
			width = 1,
			height = 1,
			shift = util.by_pixel(2.25, 13.5),
			scale = 0.5,
		  }
		},
		east =
		{
		  filename = "__base__/graphics/entity/assembling-machine-2/assembling-machine-2-pipe-E.png",
		  priority = "extra-high",
		  width = 20,
		  height = 38,
		  shift = util.by_pixel(-25, 1),
		  hr_version = {
			filename = "__base__/graphics/entity/assembling-machine-2/hr-assembling-machine-2-pipe-E.png",
			priority = "extra-high",
			width = 42,
			height = 76,
			shift = util.by_pixel(-24.5, 1),
			scale = 0.5,
		  }
		},
		south =
		{
		  filename = "__base__/graphics/entity/assembling-machine-2/assembling-machine-2-pipe-S.png",
		  priority = "extra-high",
		  width = 44,
		  height = 31,
		  shift = util.by_pixel(0, -31.5),
		  hr_version = {
			filename = "__base__/graphics/entity/assembling-machine-2/hr-assembling-machine-2-pipe-S.png",
			priority = "extra-high",
			width = 88,
			height = 61,
			shift = util.by_pixel(0, -31.25),
			scale = 0.5,
		  }
		},
		west =
		{
		  filename = "__base__/graphics/entity/assembling-machine-2/assembling-machine-2-pipe-W.png",
		  priority = "extra-high",
		  width = 19,
		  height = 37,
		  shift = util.by_pixel(25.5, 1.5),
		  hr_version = {
			filename = "__base__/graphics/entity/assembling-machine-2/hr-assembling-machine-2-pipe-W.png",
			priority = "extra-high",
			width = 39,
			height = 73,
			shift = util.by_pixel(25.75, 1.25),
			scale = 0.5,
		  }
		}
	  }
	end



	function pipecoverspicturesBioreactor()
	  return {
		north =
		{
		  filename = "__Bio_Industries__/graphics/icons/empty.png",
		  priority = "extra-high",
		  width = 1,
		  height = 1,
		  hr_version =
		  {
			filename = "__Bio_Industries__/graphics/icons/empty.png",
			priority = "extra-high",
			width = 1,
			height = 1,
			scale = 0.5
		  }
		},
		east =
		{
		  filename = "__base__/graphics/entity/pipe-covers/pipe-cover-east.png",
		  priority = "extra-high",
		  width = 64,
		  height = 64,
		  hr_version =
		  {
			filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-east.png",
			priority = "extra-high",
			width = 128,
			height = 128,
			scale = 0.5
		  }
		},
		south =
		{
		  filename = "__base__/graphics/entity/pipe-covers/pipe-cover-south.png",
		  priority = "extra-high",
		  width = 64,
		  height = 64,
		  hr_version =
		  {
			filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-south.png",
			priority = "extra-high",
			width = 128,
			height = 128,
			scale = 0.5
		  }
		},
		west =
		{
		  filename = "__base__/graphics/entity/pipe-covers/pipe-cover-west.png",
		  priority = "extra-high",
		  width = 64,
		  height = 64,
		  hr_version =
		  {
			filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-west.png",
			priority = "extra-high",
			width = 128,
			height = 128,
			scale = 0.5
		  }
		}
	  }
	end


--end