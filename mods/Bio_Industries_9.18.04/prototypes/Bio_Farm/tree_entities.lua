--[[

Big thanks to OwnlyMe and his "Robot Tree Farm" code!
https://mods.factorio.com/mod/robot_tree_farm
License:	CC BY-SA 4.0

]]


--[[
data:extend(
{  
  {
    type = "particle",
    name = "wooden-particle",
    flags = {"not-on-map"},
    life_time = 180,
    mining_particle_frame_speed = 1,
    pictures =
    {
      --woodenC
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-01.png",
        line_length = 4,
        width = 9,
        height = 7,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-01.png",
          line_length = 4,
          width = 17,
          height = 16,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-02.png",
        line_length = 4,
        width = 2,
        height = 5,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-02.png",
          line_length = 4,
          width = 4,
          height = 9,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-03.png",
        line_length = 4,
        width = 6,
        height = 7,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-03.png",
          line_length = 4,
          width = 10,
          height = 14,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-04.png",
        line_length = 4,
        width = 5,
        height = 5,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-04.png",
          line_length = 4,
          width = 8,
          height = 11,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-05.png",
        line_length = 4,
        width = 6,
        height = 7,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-05.png",
          line_length = 4,
          width = 14,
          height = 13,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-06.png",
        line_length = 4,
        width = 7,
        height = 6,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-06.png",
          line_length = 4,
          width = 14,
          height = 12,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-07.png",
        line_length = 4,
        width = 6,
        height = 5,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-07.png",
          line_length = 4,
          width = 11,
          height = 10,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-08.png",
        line_length = 4,
        width = 8,
        height = 6,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-08.png",
          line_length = 4,
          width = 17,
          height = 14,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-09.png",
        line_length = 4,
        width = 7,
        height = 8,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-09.png",
          line_length = 4,
          width = 14,
          height = 16,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-10.png",
        line_length = 4,
        width = 5,
        height = 9,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-10.png",
          line_length = 4,
          width = 11,
          height = 20,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-11.png",
        line_length = 4,
        width = 10,
        height = 9,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-11.png",
          line_length = 4,
          width = 21,
          height = 18,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-12.png",
        line_length = 4,
        width = 6,
        height = 16,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-12.png",
          line_length = 4,
          width = 14,
          height = 32,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-13.png",
        line_length = 4,
        width = 7,
        height = 9,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-13.png",
          line_length = 4,
          width = 14,
          height = 18,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-14.png",
        line_length = 4,
        width = 7,
        height = 12,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-14.png",
          line_length = 4,
          width = 12,
          height = 24,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-15.png",
        line_length = 4,
        width = 7,
        height = 10,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-15.png",
          line_length = 4,
          width = 14,
          height = 19,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-16.png",
        line_length = 4,
        width = 12,
        height = 6,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-16.png",
          line_length = 4,
          width = 24,
          height = 12,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-17.png",
        line_length = 4,
        width = 12,
        height = 7,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-17.png",
          line_length = 4,
          width = 25,
          height = 15,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-18.png",
        line_length = 4,
        width = 11,
        height = 11,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-18.png",
          line_length = 4,
          width = 22,
          height = 23,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-19.png",
        line_length = 4,
        width = 16,
        height = 15,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-19.png",
          line_length = 4,
          width = 32,
          height = 29,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-20.png",
        line_length = 4,
        width = 9,
        height = 14,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-20.png",
          line_length = 4,
          width = 17,
          height = 29,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-21.png",
        line_length = 4,
        width = 8,
        height = 16,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-21.png",
          line_length = 4,
          width = 15,
          height = 32,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-22.png",
        line_length = 4,
        width = 17,
        height = 9,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-22.png",
          line_length = 4,
          width = 34,
          height = 19,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-23.png",
        line_length = 4,
        width = 17,
        height = 22,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-23.png",
          line_length = 4,
          width = 34,
          height = 43,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-24.png",
        line_length = 4,
        width = 19,
        height = 16,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-24.png",
          line_length = 4,
          width = 38,
          height = 33,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-25.png",
        line_length = 4,
        width = 23,
        height = 25,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-25.png",
          line_length = 4,
          width = 45,
          height = 50,
          frame_count = 16,
          scale = 0.5
        }
      }
    },
    shadows =
    {
      --woodenS
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-shadow-01.png",
        line_length = 4,
        width = 9,
        height = 7,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-shadow-01.png",
          line_length = 4,
          width = 17,
          height = 16,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-shadow-02.png",
        line_length = 4,
        width = 2,
        height = 5,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-shadow-02.png",
          line_length = 4,
          width = 4,
          height = 9,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-shadow-03.png",
        line_length = 4,
        width = 6,
        height = 7,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-shadow-03.png",
          line_length = 4,
          width = 10,
          height = 14,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-shadow-04.png",
        line_length = 4,
        width = 5,
        height = 5,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-shadow-04.png",
          line_length = 4,
          width = 8,
          height = 11,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-shadow-05.png",
        line_length = 4,
        width = 6,
        height = 7,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-shadow-05.png",
          line_length = 4,
          width = 14,
          height = 13,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-shadow-06.png",
        line_length = 4,
        width = 7,
        height = 6,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-shadow-06.png",
          line_length = 4,
          width = 14,
          height = 12,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-shadow-07.png",
        line_length = 4,
        width = 6,
        height = 5,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-shadow-07.png",
          line_length = 4,
          width = 11,
          height = 10,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-shadow-08.png",
        line_length = 4,
        width = 8,
        height = 6,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-shadow-08.png",
          line_length = 4,
          width = 17,
          height = 14,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-shadow-09.png",
        line_length = 4,
        width = 7,
        height = 8,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-shadow-09.png",
          line_length = 4,
          width = 14,
          height = 16,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-shadow-10.png",
        line_length = 4,
        width = 5,
        height = 9,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-shadow-10.png",
          line_length = 4,
          width = 11,
          height = 20,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-shadow-11.png",
        line_length = 4,
        width = 10,
        height = 9,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-shadow-11.png",
          line_length = 4,
          width = 21,
          height = 18,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-shadow-12.png",
        line_length = 4,
        width = 6,
        height = 16,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-shadow-12.png",
          line_length = 4,
          width = 14,
          height = 32,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-shadow-13.png",
        line_length = 4,
        width = 7,
        height = 9,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-shadow-13.png",
          line_length = 4,
          width = 14,
          height = 18,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-shadow-14.png",
        line_length = 4,
        width = 7,
        height = 12,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-shadow-14.png",
          line_length = 4,
          width = 12,
          height = 24,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-shadow-15.png",
        line_length = 4,
        width = 7,
        height = 10,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-shadow-15.png",
          line_length = 4,
          width = 14,
          height = 19,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-shadow-16.png",
        line_length = 4,
        width = 12,
        height = 6,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-shadow-16.png",
          line_length = 4,
          width = 24,
          height = 12,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-shadow-17.png",
        line_length = 4,
        width = 12,
        height = 7,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-shadow-17.png",
          line_length = 4,
          width = 25,
          height = 15,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-shadow-18.png",
        line_length = 4,
        width = 11,
        height = 11,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-shadow-18.png",
          line_length = 4,
          width = 22,
          height = 23,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-shadow-19.png",
        line_length = 4,
        width = 16,
        height = 15,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-shadow-19.png",
          line_length = 4,
          width = 32,
          height = 29,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-shadow-20.png",
        line_length = 4,
        width = 9,
        height = 14,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-shadow-20.png",
          line_length = 4,
          width = 17,
          height = 29,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-shadow-21.png",
        line_length = 4,
        width = 8,
        height = 16,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-shadow-21.png",
          line_length = 4,
          width = 15,
          height = 32,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-shadow-22.png",
        line_length = 4,
        width = 17,
        height = 9,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-shadow-22.png",
          line_length = 4,
          width = 34,
          height = 19,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-shadow-23.png",
        line_length = 4,
        width = 17,
        height = 22,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-shadow-23.png",
          line_length = 4,
          width = 34,
          height = 43,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-shadow-24.png",
        line_length = 4,
        width = 19,
        height = 16,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-shadow-24.png",
          line_length = 4,
          width = 38,
          height = 33,
          frame_count = 16,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/wooden-particle/wooden-particle-shadow-25.png",
        line_length = 4,
        width = 23,
        height = 25,
        frame_count = 16,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/wooden-particle/hr-wooden-particle-shadow-25.png",
          line_length = 4,
          width = 45,
          height = 50,
          frame_count = 16,
          scale = 0.5
        }
      }
    }
  },



  
  {
    type = "particle",
    name = "branch-particle",
    flags = {"not-on-map"},
    life_time = 1200,
    pictures =
    {
      --branchC
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-01.png",
        line_length = 4,
        width = 34,
        height = 32,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-01.png",
          line_length = 4,
          width = 66,
          height = 64,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-02.png",
        line_length = 4,
        width = 44,
        height = 54,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-02.png",
          line_length = 4,
          width = 87,
          height = 107,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-03.png",
        line_length = 4,
        width = 60,
        height = 60,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-03.png",
          line_length = 4,
          width = 121,
          height = 119,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-04.png",
        line_length = 4,
        width = 13,
        height = 28,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-04.png",
          line_length = 4,
          width = 26,
          height = 57,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-05.png",
        line_length = 4,
        width = 27,
        height = 21,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-05.png",
          line_length = 4,
          width = 53,
          height = 40,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-06.png",
        line_length = 4,
        width = 32,
        height = 24,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-06.png",
          line_length = 4,
          width = 64,
          height = 46,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-07.png",
        line_length = 4,
        width = 33,
        height = 35,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-07.png",
          line_length = 4,
          width = 65,
          height = 69,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-08.png",
        line_length = 4,
        width = 14,
        height = 29,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-08.png",
          line_length = 4,
          width = 27,
          height = 60,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-09.png",
        line_length = 4,
        width = 26,
        height = 32,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-09.png",
          line_length = 4,
          width = 52,
          height = 64,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-10.png",
        line_length = 4,
        width = 27,
        height = 28,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-10.png",
          line_length = 4,
          width = 53,
          height = 55,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-11.png",
        line_length = 4,
        width = 25,
        height = 33,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-11.png",
          line_length = 4,
          width = 49,
          height = 64,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-12.png",
        line_length = 4,
        width = 32,
        height = 28,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-12.png",
          line_length = 4,
          width = 64,
          height = 56,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-13.png",
        line_length = 4,
        width = 25,
        height = 18,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-13.png",
          line_length = 4,
          width = 50,
          height = 35,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-14.png",
        line_length = 4,
        width = 27,
        height = 19,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-14.png",
          line_length = 4,
          width = 54,
          height = 37,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-15.png",
        line_length = 4,
        width = 12,
        height = 14,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-15.png",
          line_length = 4,
          width = 23,
          height = 30,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-16.png",
        line_length = 4,
        width = 12,
        height = 13,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-16.png",
          line_length = 4,
          width = 25,
          height = 27,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-17.png",
        line_length = 4,
        width = 31,
        height = 29,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-17.png",
          line_length = 4,
          width = 62,
          height = 59,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-18.png",
        line_length = 4,
        width = 29,
        height = 34,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-18.png",
          line_length = 4,
          width = 57,
          height = 67,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-19.png",
        line_length = 4,
        width = 38,
        height = 40,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-19.png",
          line_length = 4,
          width = 76,
          height = 79,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-20.png",
        line_length = 4,
        width = 28,
        height = 24,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-20.png",
          line_length = 4,
          width = 56,
          height = 48,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-21.png",
        line_length = 4,
        width = 23,
        height = 24,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-21.png",
          line_length = 4,
          width = 46,
          height = 47,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-22.png",
        line_length = 4,
        width = 14,
        height = 19,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-22.png",
          line_length = 4,
          width = 26,
          height = 37,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-23.png",
        line_length = 4,
        width = 35,
        height = 14,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-23.png",
          line_length = 4,
          width = 70,
          height = 26,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-24.png",
        line_length = 4,
        width = 14,
        height = 18,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-24.png",
          line_length = 4,
          width = 28,
          height = 37,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-25.png",
        line_length = 4,
        width = 22,
        height = 21,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-25.png",
          line_length = 4,
          width = 44,
          height = 41,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-26.png",
        line_length = 4,
        width = 13,
        height = 22,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-26.png",
          line_length = 4,
          width = 25,
          height = 42,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-27.png",
        line_length = 4,
        width = 36,
        height = 17,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-27.png",
          line_length = 4,
          width = 70,
          height = 33,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-28.png",
        line_length = 4,
        width = 17,
        height = 14,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-28.png",
          line_length = 4,
          width = 34,
          height = 29,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-29.png",
        line_length = 4,
        width = 26,
        height = 25,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-29.png",
          line_length = 4,
          width = 51,
          height = 50,
          frame_count = 8,
          scale = 0.5
        }
      }
    },
    shadows =
    {
      --branchS
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-01.png",
        line_length = 4,
        width = 34,
        height = 32,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-01.png",
          line_length = 4,
          width = 66,
          height = 64,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-02.png",
        line_length = 4,
        width = 44,
        height = 54,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-02.png",
          line_length = 4,
          width = 87,
          height = 107,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-03.png",
        line_length = 4,
        width = 60,
        height = 60,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-03.png",
          line_length = 4,
          width = 121,
          height = 119,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-04.png",
        line_length = 4,
        width = 13,
        height = 28,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-04.png",
          line_length = 4,
          width = 26,
          height = 57,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-05.png",
        line_length = 4,
        width = 27,
        height = 21,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-05.png",
          line_length = 4,
          width = 53,
          height = 40,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-06.png",
        line_length = 4,
        width = 32,
        height = 24,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-06.png",
          line_length = 4,
          width = 64,
          height = 46,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-07.png",
        line_length = 4,
        width = 33,
        height = 35,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-07.png",
          line_length = 4,
          width = 65,
          height = 69,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-08.png",
        line_length = 4,
        width = 14,
        height = 29,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-08.png",
          line_length = 4,
          width = 27,
          height = 60,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-09.png",
        line_length = 4,
        width = 26,
        height = 32,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-09.png",
          line_length = 4,
          width = 52,
          height = 64,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-10.png",
        line_length = 4,
        width = 27,
        height = 28,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-10.png",
          line_length = 4,
          width = 53,
          height = 55,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-11.png",
        line_length = 4,
        width = 25,
        height = 33,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-11.png",
          line_length = 4,
          width = 49,
          height = 64,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-12.png",
        line_length = 4,
        width = 32,
        height = 28,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-12.png",
          line_length = 4,
          width = 64,
          height = 56,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-13.png",
        line_length = 4,
        width = 25,
        height = 18,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-13.png",
          line_length = 4,
          width = 50,
          height = 35,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-14.png",
        line_length = 4,
        width = 27,
        height = 19,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-14.png",
          line_length = 4,
          width = 54,
          height = 37,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-15.png",
        line_length = 4,
        width = 12,
        height = 14,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-15.png",
          line_length = 4,
          width = 23,
          height = 30,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-16.png",
        line_length = 4,
        width = 12,
        height = 13,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-16.png",
          line_length = 4,
          width = 25,
          height = 27,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-17.png",
        line_length = 4,
        width = 31,
        height = 29,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-17.png",
          line_length = 4,
          width = 62,
          height = 59,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-18.png",
        line_length = 4,
        width = 29,
        height = 34,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-18.png",
          line_length = 4,
          width = 57,
          height = 67,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-19.png",
        line_length = 4,
        width = 38,
        height = 40,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-19.png",
          line_length = 4,
          width = 76,
          height = 79,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-20.png",
        line_length = 4,
        width = 28,
        height = 24,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-20.png",
          line_length = 4,
          width = 56,
          height = 48,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-21.png",
        line_length = 4,
        width = 23,
        height = 24,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-21.png",
          line_length = 4,
          width = 46,
          height = 47,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-22.png",
        line_length = 4,
        width = 14,
        height = 19,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-22.png",
          line_length = 4,
          width = 26,
          height = 37,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-23.png",
        line_length = 4,
        width = 35,
        height = 14,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-23.png",
          line_length = 4,
          width = 70,
          height = 26,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-24.png",
        line_length = 4,
        width = 14,
        height = 18,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-24.png",
          line_length = 4,
          width = 28,
          height = 37,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-25.png",
        line_length = 4,
        width = 22,
        height = 21,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-25.png",
          line_length = 4,
          width = 44,
          height = 41,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-26.png",
        line_length = 4,
        width = 13,
        height = 22,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-26.png",
          line_length = 4,
          width = 25,
          height = 42,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-27.png",
        line_length = 4,
        width = 36,
        height = 17,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-27.png",
          line_length = 4,
          width = 70,
          height = 33,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-28.png",
        line_length = 4,
        width = 17,
        height = 14,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-28.png",
          line_length = 4,
          width = 34,
          height = 29,
          frame_count = 8,
          scale = 0.5
        }
      },
      {
        filename = "__Bio_Industries__/graphics/entities/branch-particle/branch-particle-shadow-29.png",
        line_length = 4,
        width = 26,
        height = 25,
        frame_count = 8,
        hr_version =
        {
          filename = "__Bio_Industries__/graphics/entities/branch-particle/hr-branch-particle-shadow-29.png",
          line_length = 4,
          width = 51,
          height = 50,
          frame_count = 8,
          scale = 0.5
        }
      }
    }
  },

 
  {
    type = "leaf-particle",
    name = "leaf-particle",
    flags = {"not-on-map"},
    life_time = 180,
    movement_modifier = 0.9,
    pictures =
    {
      {
        filename = "__Bio_Industries__/graphics/entities/leaf-particle/leaf-particle-01.png",
        width = 6,
        height = 6,
        frame_count = 8
      },
      {
        filename = "__Bio_Industries__/graphics/entities/leaf-particle/leaf-particle-02.png",
        width = 6,
        height = 4,
        frame_count = 8
      },
      {
        filename = "__Bio_Industries__/graphics/entities/leaf-particle/leaf-particle-03.png",
        width = 8,
        height = 5,
        frame_count = 8
      },
      {
        filename = "__Bio_Industries__/graphics/entities/leaf-particle/leaf-particle-04.png",
        width = 6,
        height = 6,
        frame_count = 8
      },
      {
        filename = "__Bio_Industries__/graphics/entities/leaf-particle/leaf-particle-05.png",
        width = 6,
        height = 5,
        frame_count = 8
      },
      {
        filename = "__Bio_Industries__/graphics/entities/leaf-particle/leaf-particle-06.png",
        width = 6,
        height = 4,
        frame_count = 8
      },
      {
        filename = "__Bio_Industries__/graphics/entities/leaf-particle/leaf-particle-07.png",
        width = 6,
        height = 6,
        frame_count = 8
      },
      {
        filename = "__Bio_Industries__/graphics/entities/leaf-particle/leaf-particle-08.png",
        width = 4,
        height = 7,
        frame_count = 8
      }
    },
    shadows =
    {
      {
        filename = "__Bio_Industries__/graphics/entities/leaf-particle/leaf-particle-01-shadow.png",
        width = 6,
        height = 6,
        frame_count = 8
      },
      {
        filename = "__Bio_Industries__/graphics/entities/leaf-particle/leaf-particle-02-shadow.png",
        width = 6,
        height = 4,
        frame_count = 8
      },
      {
        filename = "__Bio_Industries__/graphics/entities/leaf-particle/leaf-particle-03-shadow.png",
        width = 8,
        height = 5,
        frame_count = 8
      },
      {
        filename = "__Bio_Industries__/graphics/entities/leaf-particle/leaf-particle-04-shadow.png",
        width = 6,
        height = 6,
        frame_count = 8
      },
      {
        filename = "__Bio_Industries__/graphics/entities/leaf-particle/leaf-particle-05-shadow.png",
        width = 6,
        height = 5,
        frame_count = 8
      },
      {
        filename = "__Bio_Industries__/graphics/entities/leaf-particle/leaf-particle-06-shadow.png",
        width = 6,
        height = 4,
        frame_count = 8
      },
      {
        filename = "__Bio_Industries__/graphics/entities/leaf-particle/leaf-particle-07-shadow.png",
        width = 6,
        height = 6,
        frame_count = 8
      },
      {
        filename = "__Bio_Industries__/graphics/entities/leaf-particle/leaf-particle-08-shadow.png",
        width = 4,
        height = 7,
        frame_count = 8
      }
    }
  },



}
)
]]

local COLLISION_BOX = {{-0.1, -0.1}, {0.1, 0.1}}
local TREE_LEVELS = 4
local extend={}

for i=1,TREE_LEVELS do
	local wooden = table.deepcopy(data.raw["optimized-particle"]["wooden-particle"])
	wooden.name="bio-"..wooden.name.."-"..i
	for _, pic in pairs(wooden.pictures) do
		pic.scale = (pic.scale or 1)/TREE_LEVELS*i
		pic.hr_version.scale = (pic.hr_version.scale or 1)/TREE_LEVELS*i
	end
	for _, pic in pairs(wooden.shadows) do
		pic.scale = (pic.scale or 1)/TREE_LEVELS*i
		pic.hr_version.scale = (pic.hr_version.scale or 1)/TREE_LEVELS*i
	end
	local branch = table.deepcopy(data.raw["optimized-particle"]["branch-particle"])
	branch.name="bio-"..branch.name.."-"..i
	for _, pic in pairs(branch.pictures) do
		pic.scale = (pic.scale or 1)/TREE_LEVELS*i
		pic.hr_version.scale = (pic.hr_version.scale or 1)/TREE_LEVELS*i
	end
	for _, pic in pairs(branch.shadows) do
		pic.scale = (pic.scale or 1)/TREE_LEVELS*i
		pic.hr_version.scale = (pic.hr_version.scale or 1)/TREE_LEVELS*i
	end
	local leaf = table.deepcopy(data.raw["optimized-particle"]["leaf-particle"])
	--local leaf = table.deepcopy(data.raw["leaf-particle"]["leaf-particle"])
	leaf.name="bio-"..leaf.name.."-"..i
	for _, pic in pairs(leaf.pictures) do
		pic.scale = (pic.scale or 1)/TREE_LEVELS*math.max(2,i)
		--pic.hr_version.scale = (pic.hr_version.scale or 1)/TREE_LEVELS*i
	end
	for _, pic in pairs(leaf.shadows) do
		pic.scale = (pic.scale or 1)/TREE_LEVELS*math.max(2,i)
		--pic.hr_version.scale = (pic.hr_version.scale or 1)/TREE_LEVELS*i
	end
	data:extend({wooden, branch, leaf})
end

--global.bi.trees = {}

for id, prototype in pairs(data.raw.tree) do

	if prototype.variations then


		for i=1,TREE_LEVELS do
			local tree = table.deepcopy(prototype)		
			tree.name = "bio-tree-"..tree.name.."-"..i
			if i < (TREE_LEVELS-1) then
				tree.localised_name = "Sapling"
			else
				tree.localised_name = "Young Tree"
			end
			tree.max_health = math.floor(50*i/TREE_LEVELS)
			tree.flags = {"placeable-neutral", "breaths-air"}
			tree.collision_mask = {"item-layer", "object-layer", "player-layer", "water-tile", "layer-13"}
			tree.autoplace = nil
			tree.selection_box = {{-0.9/TREE_LEVELS*i, -2.2/TREE_LEVELS*i}, {0.9/TREE_LEVELS*i, 0.6/TREE_LEVELS*i}}
			tree.collision_box = COLLISION_BOX
			tree.minable.mining_particle = "bio-wooden-particle-"..i
			tree.minable.mining_time = 0.25
			tree.minable.count = nil
			tree.minable.results = {}

			if i < (TREE_LEVELS) then
				table.insert(tree.minable.results,{
					name = "seedling",
					probability = i/4,
					amount = 1,					
				})
			else
				table.insert(tree.minable.results,{
					name = "wood",
					amount = 1,
					probability = 1
				})
			end

			
			for var_id, variation in pairs(tree.variations) do

					variation.trunk.scale = (variation.trunk.scale or 1) * i / TREE_LEVELS
					if variation.trunk.shift then
						variation.trunk.shift[1]=variation.trunk.shift[1]/TREE_LEVELS*i
						variation.trunk.shift[2]=variation.trunk.shift[2]/TREE_LEVELS*i
					end
					
					if variation.trunk.hr_version then
						variation.trunk.hr_version.scale = (variation.trunk.hr_version.scale or 1) * i / TREE_LEVELS
						
						if variation.trunk.hr_version.shift then
							variation.trunk.hr_version.shift[1]=(variation.trunk.hr_version.shift[1] or 0)/TREE_LEVELS*i
							variation.trunk.hr_version.shift[2]=(variation.trunk.hr_version.shift[2] or 0)/TREE_LEVELS*i
						
						end
					end
					
					if i <= TREE_LEVELS /10 then
						variation.trunk={layers={{
						filename = "__Bio_Industries__/graphics/icons/Seedling_a.png",
						priority = "extra-high",
						width = 32,
						height = 32,
						scale = 0.5,
						frame_count = (variation.trunk.frame_count or 1),
						tint= {r=0.7-0.5*i/(TREE_LEVELS/10),g=0.7-0.5*i/(TREE_LEVELS/10),b=0.7-0.5*i/(TREE_LEVELS/10),a=0.7-0.5*i/(TREE_LEVELS/10)},
						},variation.trunk}}			
					end
					
					variation.leaves.scale = (variation.leaves.scale or 1) * i / TREE_LEVELS
					if variation.leaves.shift then
						variation.leaves.shift[1]=(variation.leaves.shift[1] or 0)/TREE_LEVELS*i
						variation.leaves.shift[2]=(variation.leaves.shift[2] or 0)/TREE_LEVELS*i
					end
					
					if variation.leaves.hr_version then
						variation.leaves.hr_version.scale = (variation.leaves.hr_version.scale or 1) * i / TREE_LEVELS
						if variation.leaves.hr_version.shift then
							variation.leaves.hr_version.shift[1]=(variation.leaves.hr_version.shift[1] or 0)/TREE_LEVELS*i
							variation.leaves.hr_version.shift[2]=(variation.leaves.hr_version.shift[2] or 0)/TREE_LEVELS*i
						end
					end
					
					variation.leaf_generation.scale = (variation.leaf_generation.scale or 1) * i / TREE_LEVELS
					variation.leaf_generation.offset_deviation = {{-0.5, -0.5}, {0.5, 0.5}}
					variation.leaf_generation.initial_height = 2/TREE_LEVELS*i
					variation.leaf_generation.initial_height_deviation = 1/TREE_LEVELS*i
					variation.leaf_generation.entity_name = "bio-leaf-particle-"..i
					variation.branch_generation.scale = (variation.branch_generation.scale or 1) * i / TREE_LEVELS
					variation.branch_generation.offset_deviation = {{0.5*i/TREE_LEVELS,0.5*i/TREE_LEVELS},{0.5*i/TREE_LEVELS,0.5*i/TREE_LEVELS}}
					variation.branch_generation.initial_height = 2/TREE_LEVELS*i
					variation.branch_generation.initial_height_deviation = 2/TREE_LEVELS*i
					variation.branch_generation.entity_name = "bio-branch-particle-"..i
					variation.shadow.scale = (variation.shadow.scale or 1) * i / TREE_LEVELS
					
					if variation.shadow.shift then
						variation.shadow.shift[1]=(variation.shadow.shift[1] or 0)/TREE_LEVELS*i
						variation.shadow.shift[2]=(variation.shadow.shift[2] or 0)/TREE_LEVELS*i
					end
					
					if variation.shadow.hr_version then
						variation.shadow.hr_version.scale = (variation.shadow.hr_version.scale or 1) * i / TREE_LEVELS
						if variation.shadow.hr_version.shift then
							variation.shadow.hr_version.shift[1]=(variation.shadow.hr_version.shift[1] or 0)/TREE_LEVELS*i
							variation.shadow.hr_version.shift[2]=(variation.shadow.hr_version.shift[2] or 0)/TREE_LEVELS*i
						end
					end
			end
			
			
			local stump = table.deepcopy(data.raw.corpse[tree.remains_when_mined])
			
			if stump then
			
				stump.name = "bio-tree-"..stump.name.."-"..i
				stump.time_before_removed = 60*5
				
				tree.remains_when_mined = stump.name
				tree.corpse = stump.name
				table.insert(extend, tree)
				
				for _, variation in pairs(stump.animation) do
					variation.scale = (variation.scale or 1) * i / TREE_LEVELS
					variation.hr_version = nil
					variation.shift[1]=variation.shift[1]/TREE_LEVELS*i
					variation.shift[2]=variation.shift[2]/TREE_LEVELS*i

				end

				table.insert(extend, stump)
			
			end
			
			
		end
	end
end

data:extend(extend)

