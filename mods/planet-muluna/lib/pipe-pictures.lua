local Public = {}


function Public.vacuumheatingtowerpipepictures()
  return
  {
    north =
    {
      filename = "__muluna-graphics__/graphics/entity/assembling-machine-3/assembling-machine-3-pipe-N.png",
      priority = "extra-high",
      width = 71,
      height = 38,
      shift = util.by_pixel(2.25, 13.5),
      scale = 0.000000000001
    },
    east =
    {
      filename = "__muluna-graphics__/graphics/entity/assembling-machine-3/assembling-machine-3-pipe-E.png",
      priority = "extra-high",
      width = 42,
      height = 76,
      shift = util.by_pixel(-24.5, 1),
      scale = 0.5
    },
    south =
    {
      filename = "__muluna-graphics__/graphics/entity/assembling-machine-3/assembling-machine-3-pipe-S.png",
      priority = "extra-high",
      width = 88,
      height = 61,
      shift = util.by_pixel(0, -31.25),
      scale = 0.5
    },
    west =
    {
      filename = "__muluna-graphics__/graphics/entity/assembling-machine-3/assembling-machine-3-pipe-W.png",
      priority = "extra-high",
      width = 39,
      height = 73,
      shift = util.by_pixel(25.75, 1.25),
      scale = 0.5
    }
  }
end

function Public.greenhouse_pipe_pictures()
  return
  {
    north =
    {
      filename = "__muluna-graphics__/graphics/entity/assembling-machine-3/assembling-machine-3-pipe-N.png",
      priority = "extra-high",
      width = 71,
      height = 38,
      shift = util.by_pixel(2.25, 13.5),
      scale = 0.000000000001
    },
    east =
    {
      filename = "__muluna-graphics__/graphics/entity/assembling-machine-3/assembling-machine-3-pipe-E.png",
      priority = "extra-high",
      width = 42,
      height = 76,
      shift = util.by_pixel(-24.5, 1),
      scale = 0.5
    },
    south =
    {
      filename = "__muluna-graphics__/graphics/entity/assembling-machine-3/assembling-machine-3-pipe-S.png",
      priority = "extra-high",
      width = 88,
      height = 61,
      shift = util.by_pixel(0, -31.25),
      scale = 0.5
    },
    west =
    {
      filename = "__muluna-graphics__/graphics/entity/assembling-machine-3/assembling-machine-3-pipe-W.png",
      priority = "extra-high",
      width = 39,
      height = 73,
      shift = util.by_pixel(25.75, 1.25),
      scale = 0.5
    }
  }
end

function Public.advanced_boiler_pipe_pictures() 
    return Public.greenhouse_pipe_pictures()
end

function Public.vacuumheatingtowerpipepictures()
  return
  {
    north =
    {
      filename = "__muluna-graphics__/graphics/pipe_covers/long/pipe-NN.png",
      priority = "extra-high",
      width = 71,
      height = 38,
      shift = util.by_pixel(2.25, 13.5),
      scale = 0.5,
      draw_as_shadow = true,
    },
    east =
    {
      filename = "__muluna-graphics__/graphics/pipe_covers/cut/pipe-E.png",
      priority = "extra-high",
      width = 42,
      height = 76,
      shift = util.by_pixel(-24.5, 1),
      scale = 0.5
    },
    south =
    {
      filename = "__muluna-graphics__/graphics/pipe_covers/cut/pipe-S.png",
      priority = "extra-high",
      width = 88,
      height = 61,
      shift = util.by_pixel(0, -31.25),
      scale = 0.5
    },
    west =
    {
      filename = "__muluna-graphics__/graphics/pipe_covers/cut/pipe-W.png",
      priority = "extra-high",
      width = 39,
      height = 73,
      shift = util.by_pixel(25.75, 1.25),
      scale = 0.5
    }
  }
end


return Public