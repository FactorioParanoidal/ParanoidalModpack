local BioInd = require('common')('Bio_Industries')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"


function assembler2pipepicturesCokery()
  return
  {
    north =
    {
      filename = ICONPATH .. "empty.png",
      priority = "extra-high",
      width = 1,
      height = 1,
      shift = util.by_pixel(2.5, 14),
      hr_version = {
        filename = ICONPATH .. "empty.png",
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
      filename = ICONPATH .. "empty.png",
      priority = "extra-high",
      width = 1,
      height = 1,
      shift = util.by_pixel(0, -31.5),
      hr_version = {
        filename = ICONPATH .. "empty.png",
        priority = "extra-high",
        width = 1,
        height = 1,
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
      filename = ICONPATH .. "empty.png",
      priority = "extra-high",
      width = 1,
      height = 1,
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
      filename = ICONPATH .. "empty.png",
      priority = "extra-high",
      width = 1,
      height = 1,
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
      filename = ICONPATH .. "empty.png",
      priority = "extra-high",
      width = 1,
      height = 1,
      hr_version =
      {
        filename = ICONPATH .. "empty.png",
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
      filename = ICONPATH .. "empty.png",
      priority = "extra-high",
      width = 1,
      height = 1,
      hr_version =
      {
        filename = ICONPATH .. "empty.png",
        priority = "extra-high",
        width = 1,
        height = 1,
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


function assembler2pipepicturesBioreactor()
  return
  {
    north =
    {
      filename = ICONPATH .. "empty.png",
      priority = "extra-high",
      width = 1,
      height = 1,
      shift = util.by_pixel(2.5, 14),
      hr_version = {
        filename = ICONPATH .. "empty.png",
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



function pipecoverspicturesBioreactor()
  return {
    north =
    {
      filename = ICONPATH .. "empty.png",
      priority = "extra-high",
      width = 1,
      height = 1,
      hr_version =
      {
        filename = ICONPATH .. "empty.png",
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


function BioFarm_Pipe_Connectors_Left()
  return
  {
    north =
    {
      filename = "__Bio_Industries__/graphics/entities/biofarm/pipe_connections/Bio_Farm-pipe-N_l.png",
      priority = "extra-high",
      width = 51,
      height = 35,
          shift = {0.25, 1},
      hr_version = {
        filename = "__Bio_Industries__/graphics/entities/biofarm/pipe_connections/Bio_Farm-pipe-N_l.png",
        priority = "extra-high",
        width = 51,
        height = 35,
        shift = {0.25, 1},
      }
    },
    east =
    {
      filename = "__Bio_Industries__/graphics/entities/biofarm/pipe_connections/Bio_Farm-pipe-E_l.png",
      priority = "extra-high",
      width = 18,
      height = 48,
      shift = {-1, -0.25},
      hr_version = {
        filename = "__Bio_Industries__/graphics/entities/biofarm/pipe_connections/Bio_Farm-pipe-E_l.png",
        priority = "extra-high",
        width = 18,
        height = 48,
        shift = {-1, -0.25},
      }
    },
    south =
    {
      filename = "__Bio_Industries__/graphics/entities/biofarm/pipe_connections/Bio_Farm-pipe-S_l.png",
      priority = "extra-high",
      width = 49,
      height = 25,
      shift = {0.5, -1},
      hr_version = {
        filename = "__Bio_Industries__/graphics/entities/biofarm/pipe_connections/Bio_Farm-pipe-S_l.png",
        priority = "extra-high",
        width = 49,
        height = 25,
        shift = {0.5, -1},
      }
    },
    west =
    {
      filename = "__Bio_Industries__/graphics/entities/biofarm/pipe_connections/Bio_Farm-pipe-W_l.png",
      priority = "extra-high",
      width = 16,
      height = 51,
      shift = {0.5, 0.5},
      hr_version = {
        filename = "__Bio_Industries__/graphics/entities/biofarm/pipe_connections/Bio_Farm-pipe-W_l.png",
        priority = "extra-high",
        width = 16,
        height = 51,
        shift = {0.5, 0.5},
      }
    }
  }
end


function bio_farm_pipe_pictures()
  return
  {
    north =
    {
      filename = "__base__/graphics/entity/assembling-machine-3/assembling-machine-3-pipe-N.png",
      priority = "extra-high",
      width = 35,
      height = 18,
      shift = util.by_pixel(2.5, 14),
      hr_version = {
        filename = "__base__/graphics/entity/assembling-machine-3/hr-assembling-machine-3-pipe-N.png",
        priority = "extra-high",
        width = 71,
        height = 38,
        shift = util.by_pixel(2.25, 13.5),
        scale = 0.5,
      }
    },
    east =
    {
      filename = ICONPATH .. "empty.png",
      priority = "extra-high",
      width = 1,
      height = 1,
      hr_version = {
        filename = ICONPATH .. "empty.png",
        priority = "extra-high",
                width = 1,
                height = 1,
      }
    },
    south =
    {
      filename = "__base__/graphics/entity/assembling-machine-3/assembling-machine-3-pipe-S.png",
      priority = "extra-high",
      width = 44,
      height = 31,
      shift = util.by_pixel(0, -31.5),
      hr_version = {
        filename = "__base__/graphics/entity/assembling-machine-3/hr-assembling-machine-3-pipe-S.png",
        priority = "extra-high",
        width = 88,
        height = 61,
        shift = util.by_pixel(0, -31.25),
        scale = 0.5,
      }
    },
    west =
    {
      filename = ICONPATH .. "empty.png",
      priority = "extra-high",
      width = 1,
      height = 1,
      hr_version = {
        filename = ICONPATH .. "empty.png",
        priority = "extra-high",
                width = 1,
                height = 1,
      }
    }
  }
end

bio_farm_pipe_covers_pictures = function()
  return {
    north =
    {
      layers = {
        {
          filename = "__base__/graphics/entity/pipe-covers/pipe-cover-north.png",
          priority = "extra-high",
          width = 64,
          height = 64,
          hr_version =
          {
            filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-north.png",
            priority = "extra-high",
            width = 128,
            height = 128,
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/pipe-covers/pipe-cover-north-shadow.png",
          priority = "extra-high",
          width = 64,
          height = 64,
          draw_as_shadow = true,
          hr_version =
          {
            filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-north-shadow.png",
            priority = "extra-high",
            width = 128,
            height = 128,
            scale = 0.5,
            draw_as_shadow = true
          }
        },
      },
    },
    east =
    {
      layers =
      {
        {
          filename = "__base__/graphics/entity/pipe-covers/pipe-cover-east.png",
          priority = "extra-high",
          width = 64,
          height = 64,
                  shift = {-0.22, 0},
          hr_version =
          {
            filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-east.png",
            priority = "extra-high",
            width = 128,
            height = 128,
                        shift = {-0.22, 0},
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/pipe-covers/pipe-cover-east-shadow.png",
          priority = "extra-high",
          width = 64,
          height = 64,
                  shift = {-0.22, 0},
          draw_as_shadow = true,
          hr_version =
          {
            filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-east-shadow.png",
            priority = "extra-high",
            width = 128,
            height = 128,
            scale = 0.5,
                        shift = {-0.22, 0},
            draw_as_shadow = true
          }
        },
      },
    },
    south =
    {
      layers =
      {
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
        {
          filename = "__base__/graphics/entity/pipe-covers/pipe-cover-south-shadow.png",
          priority = "extra-high",
          width = 64,
          height = 64,
          draw_as_shadow = true,
          hr_version =
          {
            filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-south-shadow.png",
            priority = "extra-high",
            width = 128,
            height = 128,
            scale = 0.5,
            draw_as_shadow = true
          }
        },
      },
    },
    west =
    {
      layers =
      {
        {
          filename = "__base__/graphics/entity/pipe-covers/pipe-cover-west.png",
          priority = "extra-high",
          width = 64,
          height = 64,
                  shift = {0.2, 0},
          hr_version =
          {
            filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-west.png",
            priority = "extra-high",
            width = 128,
            height = 128,
                        shift = {0.2, 0},
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/pipe-covers/pipe-cover-west-shadow.png",
          priority = "extra-high",
          width = 64,
          height = 64,
                  shift = {0.2, 0},
          draw_as_shadow = true,
          hr_version =
          {
            filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-west-shadow.png",
            priority = "extra-high",
            width = 128,
            height = 128,
            scale = 0.5,
                        shift = {0.2, 0},
            draw_as_shadow = true
          }
        },
      },
    }
  }
end




--[[
function BioFarm_Pipe_Connectors_Right()
  return
  {
    north =
    {
      filename = "__Bio_Industries__/graphics/entities/biofarm/pipe_connections/Bio_Farm-pipe-N_r.png",
      priority = "extra-high",
      width = 51,
      height = 35,
      --shift = util.by_pixel(2.5, 14),
          shift = {-4, -4},
      hr_version = {
        filename = "__Bio_Industries__/graphics/entities/biofarm/pipe_connections/Bio_Farm-pipe-N_r.png",
        priority = "extra-high",
        width = 51,
        height = 35,
        shift = {0.5, 0.5},
      }
    },
    east =
    {
      filename = "__Bio_Industries__/graphics/entities/biofarm/pipe_connections/Bio_Farm-pipe-E_r.png",
      priority = "extra-high",
      width = 18,
      height = 48,
      shift = {-0.5, 0.5},
      hr_version = {
        filename = "__Bio_Industries__/graphics/entities/biofarm/pipe_connections/Bio_Farm-pipe-E_r.png",
        priority = "extra-high",
        width = 18,
        height = 48,
        shift = {-0.5, 0.5},
      }
    },
    south =
    {
      filename = "__Bio_Industries__/graphics/entities/biofarm/pipe_connections/Bio_Farm-pipe-S_r.png",
      priority = "extra-high",
      width = 49,
      height = 25,
      shift = {0.5, -0.5},
      hr_version = {
        filename = "__Bio_Industries__/graphics/entities/biofarm/pipe_connections/Bio_Farm-pipe-S_r.png",
        priority = "extra-high",
        width = 49,
        height = 25,
        shift = {0.5, -0.5},
      }
    },
    west =
    {
      filename = "__Bio_Industries__/graphics/entities/biofarm/pipe_connections/Bio_Farm-pipe-W_r.png",
      priority = "extra-high",
      width = 16,
      height = 51,
      shift = {-0.5, -0.5},
      hr_version = {
        filename = "__Bio_Industries__/graphics/entities/biofarm/pipe_connections/Bio_Farm-pipe-W_r.png",
        priority = "extra-high",
        width = 16,
        height = 51,
        shift = {-0.5, -0.5},
      }
    }
  }
end
]]
