local BioInd = require('common')('Bio_Industries')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"
local ENTITYPATH = "__base__/graphics/entity/assembling-machine-2/"
local PIPEPATH = "__base__/graphics/entity/pipe-covers/"

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
                        width = 1,
                        height = 1,
                        shift = util.by_pixel(2.25, 13.5),
                        scale = 0.5,
                  }
                },
                east =
                {
                  filename = ENTITYPATH .. "assembling-machine-2-pipe-E.png",
                  priority = "extra-high",
                  width = 20,
                  height = 38,
                  shift = util.by_pixel(-25, 1),
                  hr_version = {
                        filename = ENTITYPATH .. "hr-assembling-machine-2-pipe-E.png",
                        priority = "extra-high",
                        width = 42,
                        height = 76,
                        shift = util.by_pixel(-24.5, 1),
                        scale = 0.5,
                  }
                },
                south =
                {
                  filename = ENTITYPATH .. "assembling-machine-2-pipe-S.png",
                  priority = "extra-high",
                  width = 44,
                  height = 31,
                  shift = util.by_pixel(0, -31.5),
                  hr_version = {
                        filename = ENTITYPATH .. "hr-assembling-machine-2-pipe-S.png",
                        priority = "extra-high",
                        width = 88,
                        height = 61,
                        shift = util.by_pixel(0, -31.25),
                        scale = 0.5,
                  }
                },
                west =
                {
                  filename = ENTITYPATH .. "assembling-machine-2-pipe-W.png",
                  priority = "extra-high",
                  width = 19,
                  height = 37,
                  shift = util.by_pixel(25.5, 1.5),
                  hr_version = {
                        filename = ENTITYPATH .. "hr-assembling-machine-2-pipe-W.png",
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
                  filename = PIPEPATH .. "pipe-cover-east.png",
                  priority = "extra-high",
                  width = 64,
                  height = 64,
                  hr_version =
                  {
                        filename = PIPEPATH .. "hr-pipe-cover-east.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                  }
                },
                south =
                {
                  filename = PIPEPATH .. "pipe-cover-south.png",
                  priority = "extra-high",
                  width = 64,
                  height = 64,
                  hr_version =
                  {
                        filename = PIPEPATH .. "hr-pipe-cover-south.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                  }
                },
                west =
                {
                  filename = PIPEPATH .. "pipe-cover-west.png",
                  priority = "extra-high",
                  width = 64,
                  height = 64,
                  hr_version =
                  {
                        filename = PIPEPATH .. "hr-pipe-cover-west.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                  }
                }
          }
        end
