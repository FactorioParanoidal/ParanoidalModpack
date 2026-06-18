local function make_pipe_covers(tint)
  return {
    east = {
      layers = {
        {
          filename = "__aai-loaders__/graphics/entity/assembling-machine/assembling-machine-pipe-E.png",
          height = 76,
          priority = "extra-high",
          scale = 0.5,
          shift = { -0.765625, 0.03125 },
          width = 42,
        },
        tint and {
          filename = "__aai-loaders__/graphics/entity/assembling-machine/assembling-machine-pipe-E-mask.png",
          height = 76,
          priority = "extra-high",
          scale = 0.5,
          shift = { -0.765625, 0.03125 },
          width = 42,
          tint = tint,
        } or nil
      }
    },
    north = {
      layers = {
        {
          filename = "__aai-loaders__/graphics/entity/assembling-machine/assembling-machine-pipe-N.png",
          height = 38,
          priority = "extra-high",
          scale = 0.5,
          shift = { 0.0703125, 0.421875 },
          width = 71,
        },
        --[[tint and {
          filename = "__aai-loaders__/graphics/entity/assembling-machine/assembling-machine-pipe-N-mask.png",
          height = 38,
          priority = "extra-high",
          scale = 0.5,
          shift = { 0.0703125, 0.421875 },
          width = 71,
          tint = tint,
        } or nil]]
      }
    },
    south = {
      layers = {
        {
          filename = "__aai-loaders__/graphics/entity/assembling-machine/assembling-machine-pipe-S.png",
          height = 61,
          priority = "extra-high",
          scale = 0.5,
          shift = { 0, -0.9765625 + 5/64 },
          width = 88,
        },
        tint and {
          filename = "__aai-loaders__/graphics/entity/assembling-machine/assembling-machine-pipe-S-mask.png",
          height = 61,
          priority = "extra-high",
          scale = 0.5,
          shift = { 0, -0.9765625 + 5/64 },
          width = 88,
          tint = tint,
        } or nil
      }
    },
    west = {
      layers = {
        {
          filename = "__aai-loaders__/graphics/entity/assembling-machine/assembling-machine-pipe-W.png",
          height = 73,
          priority = "extra-high",
          scale = 0.5,
          shift = { 0.8046875, 0.0390625 },
          width = 39,
        },
        tint and {
          filename = "__aai-loaders__/graphics/entity/assembling-machine/assembling-machine-pipe-W-mask.png",
          height = 73,
          priority = "extra-high",
          scale = 0.5,
          shift = { 0.8046875, 0.0390625 },
          width = 39,
          tint = tint,
        } or nil
      }
    }
  }
end
if settings.startup["aai-loaders-fit-assemblers"].value == true then
  for _, prototype in pairs(data.raw["assembling-machine"]) do
    if string.find(prototype.name, "assembling-machine-", 1, true) then
      for _, layer in pairs(prototype.graphics_set.animation.layers) do
        if layer.scale == 1 or layer.scale == nil then
          layer.scale = (layer.scale or 1) * 1.08
        end
      end
      if prototype.fluid_boxes then
        for _, fluid_box in pairs(prototype.fluid_boxes) do
          if type(fluid_box) == "table" and fluid_box.pipe_picture then
            if prototype.name == "assembling-machine-2" then
              fluid_box.pipe_picture = make_pipe_covers({r = 90/255, g = 158/255, b = 235/255})
            elseif prototype.name == "assembling-machine-3" then
              fluid_box.pipe_picture = make_pipe_covers({r = 205/255, g = 220/255, b = 54/255})
            else
              fluid_box.pipe_picture = make_pipe_covers()
            end
          end
        end
      end
    end
  end
end
