local data_util = require("data-util")
local function index_to_letter(index, starting_at)
  return string.char(string.byte(starting_at or "a", 1) - 1 + index)
end

--[[
old variants:
01 oaktapus
02 greypine
03 ash
04 scarecrow
05 specter
06 willow
07 mangrove
08 pear
09 baobab

reflection prep:
all trunks base must line up
shrink by factor of 5
split right
]]--

local tree_types =
{
  { -- tree-01
    --addHere-tree01 -- "fir"
    type_name = "01",
    locale = "fiir",
    -- drawing_box = {{-0.9, -3}, {0.9, 0.6}},
    drawing_box_vertical_extension = 3,
    negate_tint = { r = 80, g = 77, b = 61 },
    water_reflection_function = function (variation)
      return
      {
        pictures =
        {
          filename = "__base__/graphics/entity/tree/01/tree-01-reflection.png",
          priority = "extra-high",
          width = 28,
          height = 40,
          shift = util.by_pixel(0, 70),
          y = 40 * variation,
          variation_count = 4,
          scale = 5,
        },
        rotate = false,
        orientation_to_variation = false
      }
    end,
    variations = { -- tree-01
      { -- a
        trunk =
        {
          width = 140,
          height = 340,
          shift = util.by_pixel(2, -69),
          scale = 0.5
        },
        stump =
        {
          width = 76,
          height = 68,
          shift = util.by_pixel(-1, -1),
          scale = 0.5
        },
        shadow =
        {
          width = 324,
          height = 134,
          shift = util.by_pixel(61, -2),
          scale = 0.5
        },
        leaves =
        {
          width = 184,
          height = 306,
          shift = util.by_pixel(-1, -74),
          scale = 0.5,
        },
        normal =
        {
          width = 184,
          height = 290,
          shift = util.by_pixel(-0.5, -76),
          scale = 0.5
        },
      },
      { -- b
        trunk =
        {
          width = 132,
          height = 326,
          shift = util.by_pixel(4, -66),
          scale = 0.5
        },
        stump =
        {
          width = 72,
          height = 66,
          shift = util.by_pixel(0, -1),
          scale = 0.5
        },
        shadow =
        {
          width = 312,
          height = 126,
          shift = util.by_pixel(64, 0),
          scale = 0.5
        },
        leaves =
        {
          width = 182,
          height = 316,
          shift = util.by_pixel(1, -72),
          scale = 0.5
        },
       normal =
        {
          width = 180,
          height = 300,
          shift = util.by_pixel(2, -75),
          scale = 0.5
        },
      },
      { -- c
        trunk =
        {
          width = 136,
          height = 330,
          shift = util.by_pixel(-4, -68),
          scale = 0.5
        },
        stump =
        {
          width = 74,
          height = 62,
          shift = util.by_pixel(0, -1),
          scale = 0.5
        },
        shadow =
        {
          width = 306,
          height = 132,
          shift = util.by_pixel(59, 0),
          scale = 0.5
        },
        leaves =
        {
          width = 180,
          height = 308,
          shift = util.by_pixel(0, -72),
          scale = 0.5
        },
       normal =
        {
          width = 182,
          height = 306,
          shift = util.by_pixel(0.5, -70),
          scale = 0.5
        },
      },
      { -- d
        trunk =
        {
          width = 108,
          height = 324,
          shift = util.by_pixel(2, -67),
          scale = 0.5
        },
        stump =
        {
          width = 82,
          height = 68,
          shift = util.by_pixel(0, -3),
          scale = 0.5
        },
        shadow =
        {
          width = 288,
          height = 130,
          shift = util.by_pixel(59, -3),
          scale = 0.5
        },
        leaves =
        {
          width = 188,
          height = 310,
          shift = util.by_pixel(1, -72),
          scale = 0.5
        },
       normal =
        {
          width = 188,
          height = 286,
          shift = util.by_pixel(2, -75.5),
          scale = 0.5
        },
      },
      { -- e
        trunk =
        {
          width = 138,
          height = 324,
          shift = util.by_pixel(2, -66),
          scale = 0.5
        },
        stump =
        {
          width = 78,
          height = 62,
          shift = util.by_pixel(0, -1),
          scale = 0.5
        },
        shadow =
        {
          width = 314,
          height = 136,
          shift = util.by_pixel(67, 1),
          scale = 0.5
        },
        leaves =
        {
          width = 190,
          height = 300,
          shift = util.by_pixel(3, -71),
          scale = 0.5
        },
        normal =
        {
          width = 190,
          height = 280,
          shift = util.by_pixel(4, -68),
          scale = 0.5
        },
      },
      { -- f
        trunk =
        {
          width = 118,
          height = 326,
          shift = util.by_pixel(-4, -65),
          scale = 0.5
        },
        stump =
        {
          width = 76,
          height = 70,
          shift = util.by_pixel(0, -1),
          scale = 0.5
        },
        shadow =
        {
          width = 304,
          height = 140,
          shift = util.by_pixel(56, 1),
          scale = 0.5
        },
        leaves =
        {
          width = 190,
          height = 304,
          shift = util.by_pixel(-3, -67),
          scale = 0.5
        },
        normal =
        {
          width = 190,
          height = 278,
          shift = util.by_pixel(-2, -71),
          scale = 0.5
        },
      },
      { -- g
        trunk =
        {
          width = 142,
          height = 294,
          shift = util.by_pixel(-2, -59),
          scale = 0.5
        },
        stump =
        {
          width = 72,
          height = 62,
          shift = util.by_pixel(-1, -1),
          scale = 0.5
        },
        shadow =
        {
          width = 252,
          height = 130,
          shift = util.by_pixel(41, -2),
          scale = 0.5
        },
        leaves =
        {
          width = 184,
          height = 274,
          shift = util.by_pixel(-3, -61),
          scale = 0.5
        },
        normal =
        {
          width = 186,
          height = 248,
          shift = util.by_pixel(-2.5, -62),
          scale = 0.5
        },
      },
      { -- h
        trunk =
        {
          width = 116,
          height = 296,
          shift = util.by_pixel(4, -60),
          scale = 0.5
        },
        stump =
        {
          width = 70,
          height = 64,
          shift = util.by_pixel(-1, -2),
          scale = 0.5
        },
        shadow =
        {
          width = 266,
          height = 130,
          shift = util.by_pixel(55, -3),
          scale = 0.5
        },
        leaves =
        {
          width = 180,
          height = 282,
          shift = util.by_pixel(1, -63),
          scale = 0.5
        },
        normal =
        {
          width = 180,
          height = 244,
          shift = util.by_pixel(1.5, -61),
          scale = 0.5
        },
      },
      { -- i
        trunk =
        {
          width = 120,
          height = 244,
          shift = util.by_pixel(0, -49),
          scale = 0.5
        },
        stump =
        {
          width = 82,
          height = 68,
          shift = util.by_pixel(2, -5),
          scale = 0.5
        },
        shadow =
        {
          width = 228,
          height = 118,
          shift = util.by_pixel(50, 3),
          scale = 0.5
        },
        leaves =
        {
          width = 152,
          height = 234,
          shift = util.by_pixel(-2, -52),
          scale = 0.5
        },
        normal =
        {
          width = 152,
          height = 196,
          shift = util.by_pixel(-1.5, -56.5),
          scale = 0.5
        },
      },
      { -- j
        trunk =
        {
          width = 110,
          height = 250,
          shift = util.by_pixel(0, -50),
          scale = 0.5
        },
        stump =
        {
          width = 74,
          height = 74,
          shift = util.by_pixel(3, -6),
          scale = 0.5
        },
        shadow =
        {
          width = 212,
          height = 104,
          shift = util.by_pixel(50, -3),
          scale = 0.5
        },
        leaves =
        {
          width = 134,
          height = 228,
          shift = util.by_pixel(0, -51),
          scale = 0.5
        },
        normal =
        {
          width = 134,
          height = 194,
          shift = util.by_pixel(1.5, -58.5),
          scale = 0.5
        },
      },
      { -- k
        trunk =
        {
          width = 258,
          height = 224,
          shift = util.by_pixel(10, -13),
          scale = 0.5
        },
        stump =
        {
          width = 86,
          height = 78,
          shift = util.by_pixel(-9, 4),
          scale = 0.5
        },
        shadow =
        {
          width = 256,
          height = 212,
          shift = util.by_pixel(13, -13),
          scale = 0.5
        },
        leaves =
        {
          width = 250,
          height = 206,
          shift = util.by_pixel(10, -12),
          scale = 0.5
        },
        normal =
        {
          width = 186,
          height = 150,
          shift = util.by_pixel(26, -26),
          scale = 0.5
        },
      },
      { -- l
        trunk =
        {
          width = 620,
          height = 116,
          shift = util.by_pixel(32, 7),
          scale = 0.5
        },
        stump =
        {
          width = 396,
          height = 202,
          shift = util.by_pixel(88, 31),
          scale = 0.5
        },
        shadow =
        {
          width = 366,
          height = 94,
          shift = util.by_pixel(-29, 5),
          scale = 0.5
        },
        leaves =
        {
          width = 354,
          height = 114,
          shift = util.by_pixel(-31, 0),
          scale = 0.5
        },
        normal =
        {
          width = 240,
          height = 112,
          shift = util.by_pixel(-52.5, 1),
          scale = 0.5
        },
      }
    },
  },
  { -- tree-02
    --addHere-tree02 -- "sequoia"
    type_name = "02",
    locale = "seqnoia",
    -- drawing_box = {{-0.9, -3.9}, {0.9, 0.6}},
    drawing_box_vertical_extension = 3.9,
    negate_tint = { r = 80, g = 77, b = 61 },
    water_reflection_function = function (variation)
      return
      {
        pictures =
        {
          filename = "__base__/graphics/entity/tree/02/tree-02-reflection.png",
          priority = "extra-high",
          width = 28,
          height = 40,
          shift = util.by_pixel(5, 75),
          y = 40 * variation,
          variation_count = 4,
          scale = 5,
        },
        rotate = false,
        orientation_to_variation = false
      }
    end,
    variations = { -- tree-02
      { -- a
        trunk =
        {
          width = 162,
          height = 324,
          shift = util.by_pixel(1, -65),
          scale = 0.5
        },
        stump =
        {
          width = 88,
          height = 70,
          shift = util.by_pixel(2, -2),
          scale = 0.5
        },
        shadow =
        {
          width = 384,
          height = 130,
          shift = util.by_pixel(92, -2),
          scale = 0.5
        },
        leaves =
        {
          width = 184,
          height = 310,
          shift = util.by_pixel(0, -74),
          scale = 0.5
        },
       normal =
        {
          width = 186,
          height = 292,
          shift = util.by_pixel(0.5, -78),
          scale = 0.5
        },
      },
      { -- b
        trunk =
        {
          width = 150,
          height = 286,
          shift = util.by_pixel(-3, -59),
          scale = 0.5
        },
        stump =
        {
          width = 78,
          height = 60,
          shift = util.by_pixel(2, -3),
          scale = 0.5
        },
        shadow =
        {
          width = 372,
          height = 134,
          shift = util.by_pixel(86, 1),
          scale = 0.5
        },
        leaves =
        {
          width = 184,
          height = 274,
          shift = util.by_pixel(-2, -62),
          scale = 0.5
        },
        normal =
        {
          width = 184,
          height = 262,
          shift = util.by_pixel(-1, -64),
          scale = 0.5
        },
      },
      { -- c
        trunk =
        {
          width = 144,
          height = 280,
          shift = util.by_pixel(-4, -57),
          scale = 0.5
        },
        stump =
        {
          width = 78,
          height = 60,
          shift = util.by_pixel(2, -2),
          scale = 0.5
        },
        shadow =
        {
          width = 352,
          height = 128,
          shift = util.by_pixel(77, -2),
          scale = 0.5
        },
        leaves =
        {
          width = 178,
          height = 264,
          shift = util.by_pixel(-1, -62),
          scale = 0.5
        },
        normal =
        {
          width = 178,
          height = 244,
          shift = util.by_pixel(0, -66.5),
          scale = 0.5
        },
      },
      { -- d
        trunk =
        {
          width = 142,
          height = 336,
          shift = util.by_pixel(7, -70),
          scale = 0.5
        },
        stump =
        {
          width = 102,
          height = 80,
          shift = util.by_pixel(7, -6),
          scale = 0.5
        },
        shadow =
        {
          width = 402,
          height = 134,
          shift = util.by_pixel(94, -4),
          scale = 0.5
        },
        leaves =
        {
          width = 180,
          height = 330,
          shift = util.by_pixel(6, -75),
          scale = 0.5
        },
        normal =
        {
          width = 180,
          height = 302,
          shift = util.by_pixel(7, -82),
          scale = 0.5
        },
      },
      { -- e
        trunk =
        {
          width = 168,
          height = 286,
          shift = util.by_pixel(3, -57),
          scale = 0.5
        },
        stump =
        {
          width = 100,
          height = 78,
          shift = util.by_pixel(8, -5),
          scale = 0.5
        },
        shadow =
        {
          width = 410,
          height = 144,
          shift = util.by_pixel(96, 6),
          scale = 0.5
        },
        leaves =
        {
          width = 194,
          height = 276,
          shift = util.by_pixel(1, -63),
          scale = 0.5
        },
       normal =
        {
          width = 194,
          height = 272,
          shift = util.by_pixel(2, -64.5),
          scale = 0.5
        },
      },
      { -- f
        trunk =
        {
          width = 144,
          height = 310,
          shift = util.by_pixel(-10, -63),
          scale = 0.5
        },
        stump =
        {
          width = 96,
          height = 78,
          shift = util.by_pixel(6, -5),
          scale = 0.5
        },
        shadow =
        {
          width = 344,
          height = 130,
          shift = util.by_pixel(75, 0),
          scale = 0.5
        },
        leaves =
        {
          width = 184,
          height = 302,
          shift = util.by_pixel(-10, -68),
          scale = 0.5
        },
        normal =
        {
          width = 184,
          height = 292,
          shift = util.by_pixel(-9, -69.5),
          scale = 0.5
        },
      },
      { -- g
        trunk =
        {
          width = 168,
          height = 282,
          shift = util.by_pixel(6, -56),
          scale = 0.5
        },
        stump =
        {
          width = 78,
          height = 66,
          shift = util.by_pixel(0, -2),
          scale = 0.5
        },
        shadow =
        {
          width = 384,
          height = 122,
          shift = util.by_pixel(84, -4),
          scale = 0.5
        },
        leaves =
        {
          width = 198,
          height = 270,
          shift = util.by_pixel(5, -67),
          scale = 0.5
        },
        normal =
        {
          width = 196,
          height = 238,
          shift = util.by_pixel(6, -74.5),
          scale = 0.5
        },
      },
      { -- h
        trunk =
        {
          width = 182,
          height = 244,
          shift = util.by_pixel(-8, -47),
          scale = 0.5
        },
        stump =
        {
          width = 80,
          height = 66,
          shift = util.by_pixel(1, -2),
          scale = 0.5
        },
        shadow =
        {
          width = 306,
          height = 118,
          shift = util.by_pixel(69, 5),
          scale = 0.5
        },
        leaves =
        {
          width = 192,
          height = 234,
          shift = util.by_pixel(-7, -58),
          scale = 0.5
        },
        normal =
        {
          width = 190,
          height = 220,
          shift = util.by_pixel(-6, -60.5),
          scale = 0.5
        },
      },
      { -- i
        trunk =
        {
          width = 126,
          height = 206,
          shift = util.by_pixel(4, -38),
          scale = 0.5
        },
        stump =
        {
          width = 88,
          height = 74,
          shift = util.by_pixel(7, -5),
          scale = 0.5
        },
        shadow =
        {
          width = 262,
          height = 110,
          shift = util.by_pixel(61, 0),
          scale = 0.5
        },
        leaves =
        {
          width = 152,
          height = 194,
          shift = util.by_pixel(4, -48),
          scale = 0.5
        },
        normal =
        {
          width = 152,
          height = 194,
          shift = util.by_pixel(5, -47),
          scale = 0.5
        },
      },
      { -- j
        trunk =
        {
          width = 128,
          height = 194,
          shift = util.by_pixel(-8, -36),
          scale = 0.5
        },
        stump =
        {
          width = 84,
          height = 66,
          shift = util.by_pixel(5, -4),
          scale = 0.5
        },
        shadow =
        {
          width = 248,
          height = 108,
          shift = util.by_pixel(55, -1),
          scale = 0.5
        },
        leaves =
        {
          width = 152,
          height = 198,
          shift = util.by_pixel(-7, -47),
          scale = 0.5
        },
        normal =
        {
          width = 152,
          height = 200,
          shift = util.by_pixel(-6.5, -46.5),
          scale = 0.5
        },
      },
      { -- k
        trunk =
        {
          width = 234,
          height = 244,
          shift = util.by_pixel(6, -19),
          scale = 0.5
        },
        stump =
        {
          width = 138,
          height = 130,
          shift = util.by_pixel(1, 5),
          scale = 0.5
        },
        shadow =
        {
          width = 248,
          height = 262,
          shift = util.by_pixel(12, -19),
          scale = 0.5
        },
        leaves =
        {
          width = 216,
          height = 264,
          shift = util.by_pixel(13, -30),
          scale = 0.5
        },
        normal =
        {
          width = 214,
          height = 212,
          shift = util.by_pixel(14, -41.5),
          scale = 0.5
        },
      },
      { -- l
        trunk =
        {
          width = 410,
          height = 122,
          shift = util.by_pixel(-9, -7),
          scale = 0.5
        },
        stump =
        {
          width = 188,
          height = 100,
          shift = util.by_pixel(28, -12),
          scale = 0.5
        },
        shadow =
        {
          width = 418,
          height = 138,
          shift = util.by_pixel(-2, 1),
          scale = 0.5
        },
        leaves =
        {
          width = 404,
          height = 156,
          shift = util.by_pixel(-11, -6),
          scale = 0.5
        },
        normal =
        {
          width = 308,
          height = 156,
          shift = util.by_pixel(-35, -5.5),
          scale = 0.5
        },
      }
    },
  },
  { -- tree-03
    --addHere-tree03 -- "eucalyptus"
    type_name = "03",
    locale = "mewkaliptus",
    -- drawing_box = {{-0.9, -3.7}, {0.9, 0.6}},
    drawing_box_vertical_extension = 3.7,
    water_reflection_function = function (variation)
      return
      {
        pictures =
        {
          filename = "__base__/graphics/entity/tree/03/tree-03-reflection.png",
          priority = "extra-high",
          width = 44,
          height = 40,
          shift = util.by_pixel(10, 65),
          y = 40 * variation,
          variation_count = 4,
          scale = 5,
        },
        rotate = false,
        orientation_to_variation = false
      }
    end,
    variations = { -- tree-03
      { -- a
        trunk = {
          width = 264,
          height = 312,
          shift = util.by_pixel(-5, -56),
          scale = 0.5
        },
        stump = {
          width = 100,
          height = 80,
          shift = util.by_pixel(1, 2),
          scale = 0.5
        },
        shadow = {
          width = 300,
          height = 202,
          shift = util.by_pixel(61, -14),
          scale = 0.5
        },
        leaves = {
          width = 282,
          height = 304,
          shift = util.by_pixel(-8, -74),
          scale = 0.5
        },
        normal = {
          width = 284,
          height = 270,
          shift = util.by_pixel(-8, -82),
          scale = 0.5
        },
      },
      { -- b
        trunk = {
          width = 252,
          height = 314,
          shift = util.by_pixel(20, -58),
          scale = 0.5
        },
        stump = {
          width = 106,
          height = 84,
          shift = util.by_pixel(-4, 0),
          scale = 0.5
        },
        shadow = {
          width = 406,
          height = 230,
          shift = util.by_pixel(86, -11),
          scale = 0.5
        },
        leaves = {
          width = 342,
          height = 272,
          shift = util.by_pixel(22, -80),
          scale = 0.5
        },
        normal = {
          width = 344,
          height = 276,
          shift = util.by_pixel(22.5, -79.5),
          scale = 0.5
        },
      },
      { -- c
        trunk = {
          width = 268,
          height = 246,
          shift = util.by_pixel(-9, -43),
          scale = 0.5
        },
        stump = {
          width = 98,
          height = 78,
          shift = util.by_pixel(3, -1),
          scale = 0.5
        },
        shadow = {
          width = 646,
          height = 188,
          shift = util.by_pixel(-26, 9),
          scale = 0.5
        },
        leaves = {
          width = 314,
          height = 232,
          shift = util.by_pixel(-8, -48),
          scale = 0.5
        },
        normal = {
          width = 318,
          height = 234,
          shift = util.by_pixel(-8, -47.5),
          scale = 0.5
        },
      },
      { -- d
        trunk = {
          width = 142,
          height = 286,
          shift = util.by_pixel(7, -51),
          scale = 0.5
        },
        stump = {
          width = 96,
          height = 78,
          shift = util.by_pixel(-5, 1),
          scale = 0.5
        },
        shadow = {
          width = 318,
          height = 156,
          shift = util.by_pixel(66, 0),
          scale = 0.5
        },
        leaves = {
          width = 202,
          height = 254,
          shift = util.by_pixel(9, -67),
          scale = 0.5
        },
        normal = {
          width = 202,
          height = 230,
          shift = util.by_pixel(9.5, -72.5),
          scale = 0.5
        },
      },
      { -- e
        trunk = {
          width = 174,
          height = 250,
          shift = util.by_pixel(7, -47),
          scale = 0.5
        },
        stump = {
          width = 98,
          height = 74,
          shift = util.by_pixel(-3, -3),
          scale = 0.5
        },
        shadow = {
          width = 330,
          height = 132,
          shift = util.by_pixel(71, 1),
          scale = 0.5
        },
        leaves = {
          width = 234,
          height = 208,
          shift = util.by_pixel(8, -61),
          scale = 0.5
        },
        normal = {
          width = 238,
          height = 198,
          shift = util.by_pixel(8.5, -64),
          scale = 0.5
        },
      },
      { -- f
        trunk = {
          width = 158,
          height = 262,
          shift = util.by_pixel(-12, -49),
          scale = 0.5
        },
        stump = {
          width = 90,
          height = 66,
          shift = util.by_pixel(5, 0),
          scale = 0.5
        },
        shadow = {
          width = 224,
          height = 142,
          shift = util.by_pixel(48, -3),
          scale = 0.5
        },
        leaves = {
          width = 214,
          height = 232,
          shift = util.by_pixel(-13, -57),
          scale = 0.5
        },
        normal = {
          width = 216,
          height = 202,
          shift = util.by_pixel(-12, -63.5),
          scale = 0.5
        },
      },
      { -- g
        trunk = {
          width = 140,
          height = 240,
          shift = util.by_pixel(-9, -41),
          scale = 0.5
        },
        stump = {
          width = 88,
          height = 76,
          shift = util.by_pixel(0, 0),
          scale = 0.5
        },
        shadow = {
          width = 212,
          height = 136,
          shift = util.by_pixel(44, -5),
          scale = 0.5
        },
        leaves = {
          width = 188,
          height = 230,
          shift = util.by_pixel(1, -57),
          scale = 0.5
        },
       normal = {
          width = 186,
          height = 188,
          shift = util.by_pixel(1.5, -66.5),
          scale = 0.5
        },
      },
      { -- h
        trunk = {
          width = 174,
          height = 224,
          shift = util.by_pixel(2, -37),
          scale = 0.5
        },
        stump = {
          width = 88,
          height = 74,
          shift = util.by_pixel(-2, 0),
          scale = 0.5
        },
        shadow = {
          width = 258,
          height = 132,
          shift = util.by_pixel(55, -1),
          scale = 0.5
        },
        leaves = {
          width = 182,
          height = 200,
          shift = util.by_pixel(7, -43),
          scale = 0.5
        },
        normal = {
          width = 186,
          height = 154,
          shift = util.by_pixel(7.5, -54),
          scale = 0.5
        },
      },
      { -- i
        trunk = {
          width = 196,
          height = 202,
          shift = util.by_pixel(2, -34),
          scale = 0.5
        },
        stump = {
          width = 92,
          height = 80,
          shift = util.by_pixel(1, -3),
          scale = 0.5
        },
        shadow = {
          width = 218,
          height = 120,
          shift = util.by_pixel(48, 4),
          scale = 0.5
        },
        leaves = {
          width = 198,
          height = 178,
          shift = util.by_pixel(-1, -41),
          scale = 0.5
        },
        normal = {
          width = 190,
          height = 136,
          shift = util.by_pixel(-3.5, -50.5),
          scale = 0.5
        },
      },
      { -- j
        trunk = {
          width = 100,
          height = 188,
          shift = util.by_pixel(6, -34),
          scale = 0.5
        },
        stump = {
          width = 58,
          height = 52,
          shift = util.by_pixel(-2, 0),
          scale = 0.5
        },
        shadow = {
          width = 178,
          height = 110,
          shift = util.by_pixel(39, -2),
          scale = 0.5
        },
        leaves = {
          width = 112,
          height = 166,
          shift = util.by_pixel(6, -43),
          scale = 0.5
        },
        normal = {
          width = 114,
          height = 136,
          shift = util.by_pixel(6.5, -50.5),
          scale = 0.5
        },
      },
      { -- k
        trunk = {
          width = 92,
          height = 134,
          shift = util.by_pixel(8, -23),
          scale = 0.5
        },
        stump = {
          width = 52,
          height = 46,
          shift = util.by_pixel(-2, -1),
          scale = 0.5
        },
        shadow = {
          width = 170,
          height = 66,
          shift = util.by_pixel(38, 3),
          scale = 0.5
        },
        leaves = {
          width = 140,
          height = 126,
          shift = util.by_pixel(4, -32),
          scale = 0.5
        },
        normal = {
          width = 140,
          height = 104,
          shift = util.by_pixel(4.5, -36.5),
          scale = 0.5
        },
      },
      { -- l
        trunk = {
          width = 112,
          height = 166,
          shift = util.by_pixel(-9, -29),
          scale = 0.5
        },
        stump = {
          width = 62,
          height = 50,
          shift = util.by_pixel(3, 0),
          scale = 0.5
        },
        shadow = {
          width = 142,
          height = 90,
          shift = util.by_pixel(31, -5),
          scale = 0.5
        },
        leaves = {
          width = 154,
          height = 142,
          shift = util.by_pixel(-13, -42),
          scale = 0.5
        },
        normal = {
          width = 154,
          height = 122,
          shift = util.by_pixel(-12.5, -46),
          scale = 0.5
        },
      },
    },
  },
  { -- tree-04
    --addHere-tree04 -- "mahogany"
    type_name = "04",
    locale = "mahogangy",
    -- drawing_box = {{-0.9, -3.9}, {0.9, 0.6}},
    drawing_box_vertical_extension = 3.9,
    negate_tint = { r = 80, g = 77, b = 61 },
    water_reflection_function = function (variation)
      return
      {
        pictures =
        {
          filename = "__base__/graphics/entity/tree/04/tree-04-reflection.png",
          priority = "extra-high",
          width = 32,
          height = 40,
          shift = util.by_pixel(5, 65),
          y = 40 * variation,
          variation_count = 4,
          scale = 5,
        },
        rotate = false,
        orientation_to_variation = false
      }
    end,
    variations = { -- tree-04
      { -- a
        trunk =
        {
          width = 174,
          height = 316,
          shift = util.by_pixel(-4, -58),
          scale = 0.5
        },
        stump =
        {
          width = 112,
          height = 94,
          shift = util.by_pixel(3, -2),
          scale = 0.5
        },
        shadow =
        {
          width = 318,
          height = 130,
          shift = util.by_pixel(65, -5),
          scale = 0.5
        },
        leaves =
        {
          width = 216,
          height = 314,
          shift = util.by_pixel(-3, -67),
          scale = 0.5
        },
        normal =
        {
          width = 218,
          height = 248,
          shift = util.by_pixel(-2.5, -82),
          scale = 0.5
        },
      },
      { -- b
        trunk =
        {
          width = 142,
          height = 334,
          shift = util.by_pixel(5, -60),
          scale = 0.5
        },
        stump =
        {
          width = 118,
          height = 94,
          shift = util.by_pixel(-1, 0),
          scale = 0.5
        },
        shadow =
        {
          width = 308,
          height = 154,
          shift = util.by_pixel(68, -3),
          scale = 0.5
        },
        leaves =
        {
          width = 184,
          height = 302,
          shift = util.by_pixel(4, -72),
          scale = 0.5
        },
        normal =
        {
          width = 186,
          height = 246,
          shift = util.by_pixel(5, -84.5),
          scale = 0.5
        },
      },
      { -- c
        trunk =
        {
          width = 176,
          height = 328,
          shift = util.by_pixel(4, -60),
          scale = 0.5
        },
        stump =
        {
          width = 108,
          height = 88,
          shift = util.by_pixel(-3, 0),
          scale = 0.5
        },
        shadow =
        {
          width = 312,
          height = 134,
          shift = util.by_pixel(67, 2),
          scale = 0.5
        },
        leaves =
        {
          width = 208,
          height = 324,
          shift = util.by_pixel(2, -64),
          scale = 0.5
        },
        normal =
        {
          width = 208,
          height = 268,
          shift = util.by_pixel(2.5, -77),
          scale = 0.5
        },
      },
      { -- d
        trunk =
        {
          width = 216,
          height = 266,
          shift = util.by_pixel(2, -48),
          scale = 0.5
        },
        stump =
        {
          width = 96,
          height = 82,
          shift = util.by_pixel(1, -2),
          scale = 0.5
        },
        shadow =
        {
          width = 320,
          height = 158,
          shift = util.by_pixel(69, 0),
          scale = 0.5
        },
        leaves =
        {
          width = 230,
          height = 290,
          shift = util.by_pixel(-6, -64),
          scale = 0.5
        },
        normal =
        {
          width = 230,
          height = 250,
          shift = util.by_pixel(-5, -74),
          scale = 0.5
        },
      },
      { -- e
        trunk =
        {
          width = 158,
          height = 324,
          shift = util.by_pixel(-9, -62),
          scale = 0.5
        },
        stump =
        {
          width = 102,
          height = 84,
          shift = util.by_pixel(1, -2),
          scale = 0.5
        },
        shadow =
        {
          width = 274,
          height = 170,
          shift = util.by_pixel(61, -2),
          scale = 0.5
        },
        leaves =
        {
          width = 222,
          height = 280,
          shift = util.by_pixel(-4, -84),
          scale = 0.5
        },
        normal =
        {
          width = 222,
          height = 256,
          shift = util.by_pixel(-3, -88.5),
          scale = 0.5
        },
      },
      { -- f
        trunk =
        {
          width = 194,
          height = 332,
          shift = util.by_pixel(4, -62),
          scale = 0.5
        },
        stump =
        {
          width = 100,
          height = 84,
          shift = util.by_pixel(-2, 0),
          scale = 0.5
        },
        shadow =
        {
          width = 332,
          height = 156,
          shift = util.by_pixel(72, -4),
          scale = 0.5
        },
        leaves =
        {
          width = 224,
          height = 272,
          shift = util.by_pixel(11, -82),
          scale = 0.5
        },
        normal =
        {
          width = 222,
          height = 244,
          shift = util.by_pixel(12.5, -87),
          scale = 0.5
        },
      },
      { -- g
        trunk =
        {
          width = 178,
          height = 282,
          shift = util.by_pixel(-12, -53),
          scale = 0.5
        },
        stump =
        {
          width = 94,
          height = 86,
          shift = util.by_pixel(0, -4),
          scale = 0.5
        },
        shadow =
        {
          width = 296,
          height = 144,
          shift = util.by_pixel(56, -7),
          scale = 0.5
        },
        leaves =
        {
          width = 222,
          height = 258,
          shift = util.by_pixel(-11, -75),
          scale = 0.5
        },
        normal =
        {
          width = 222,
          height = 220,
          shift = util.by_pixel(-10.5, -83.5),
          scale = 0.5
        },
      },
      { -- h
        trunk =
        {
          width = 128,
          height = 284,
          shift = util.by_pixel(-2, -53),
          scale = 0.5
        },
        stump =
        {
          width = 96,
          height = 92,
          shift = util.by_pixel(2, -5),
          scale = 0.5
        },
        shadow =
        {
          width = 292,
          height = 152,
          shift = util.by_pixel(67, -8),
          scale = 0.5
        },
        leaves =
        {
          width = 202,
          height = 280,
          shift = util.by_pixel(8, -57),
          scale = 0.5
        },
        normal =
        {
          width = 204,
          height = 202,
          shift = util.by_pixel(8.5, -76),
          scale = 0.5
        },
      },
      { -- i
        trunk =
        {
          width = 92,
          height = 246,
          shift = util.by_pixel(7, -46),
          scale = 0.5
        },
        stump =
        {
          width = 82,
          height = 68,
          shift = util.by_pixel(3, -2),
          scale = 0.5
        },
        shadow =
        {
          width = 244,
          height = 128,
          shift = util.by_pixel(57, 7),
          scale = 0.5
        },
        leaves =
        {
          width = 140,
          height = 240,
          shift = util.by_pixel(6, -50),
          scale = 0.5
        },
        normal =
        {
          width = 138,
          height = 206,
          shift = util.by_pixel(7, -57),
          scale = 0.5
        },
      },
      { -- j
        trunk =
        {
          width = 98,
          height = 238,
          shift = util.by_pixel(-8, -47),
          scale = 0.5
        },
        stump =
        {
          width = 78,
          height = 66,
          shift = util.by_pixel(-3, -4),
          scale = 0.5
        },
        shadow =
        {
          width = 228,
          height = 122,
          shift = util.by_pixel(47, -6),
          scale = 0.5
        },
        leaves =
        {
          width = 140,
          height = 254,
          shift = util.by_pixel(-8, -55),
          scale = 0.5
        },
        normal =
        {
          width = 140,
          height = 210,
          shift = util.by_pixel(-7, -65),
          scale = 0.5
        },
      },
      { -- k
        trunk =
        {
          width = 406,
          height = 158,
          shift = util.by_pixel(-15, -11),
          scale = 0.5
        },
        stump =
        {
          width = 104,
          height = 108,
          shift = util.by_pixel(18, -2),
          scale = 0.5
        },
        shadow =
        {
          width = 410,
          height = 124,
          shift = util.by_pixel(-6, -8),
          scale = 0.5
        },
        leaves =
        {
          width = 414,
          height = 164,
          shift = util.by_pixel(-19, -19),
          scale = 0.5
        },
        normal =
        {
          width = 266,
          height = 144,
          shift = util.by_pixel(-55, -22),
          scale = 0.5
        },
      },
      { -- l
        trunk =
        {
          width = 312,
          height = 250,
          shift = util.by_pixel(4, -3),
          scale = 0.5
        },
        stump =
        {
          width = 108,
          height = 92,
          shift = util.by_pixel(-10, -15),
          scale = 0.5
        },
        shadow =
        {
          width = 366,
          height = 250,
          shift = util.by_pixel(25, 7),
          scale = 0.5
        },
        leaves =
        {
          width = 314,
          height = 240,
          shift = util.by_pixel(10, 1),
          scale = 0.5
        },
        normal =
        {
          width = 218,
          height = 186,
          shift = util.by_pixel(35, 15),
          scale = 0.5
        },
      }
    },
  },
  { -- tree-05
    --addHere-tree05 - "maple"
    type_name = "05",
    locale = "maypaple",
    -- drawing_box = {{-0.9, -3.5}, {0.9, 0.6}},
    drawing_box_vertical_extension = 3.5,
    negate_tint = { r = 80, g = 77, b = 61 },
    water_reflection_function = function (variation)
      return
      {
        pictures =
        {
          filename = "__base__/graphics/entity/tree/05/tree-05-reflection.png",
          priority = "extra-high",
          width = 32,
          height = 36,
          shift = util.by_pixel(5, 60),
          y = 36 * variation,
          variation_count = 4,
          scale = 5,
        },
        rotate = false,
        orientation_to_variation = false
      }
    end,
    variations = { -- tree-05
      { -- a
        trunk = {
          width = 144,
          height = 242,
          shift = util.by_pixel(13, -45),
          scale = 0.5
        },
        stump = {
          width = 88,
          height = 64,
          shift = util.by_pixel(-1, 0),
          scale = 0.5
        },
        shadow = {
          width = 322,
          height = 150,
          shift = util.by_pixel(62, -8),
          scale = 0.5
        },
        leaves = {
          width = 234,
          height = 258,
          shift = util.by_pixel(5, -60),
          scale = 0.5
        },
        normal = {
          width = 234,
          height = 216,
          shift = util.by_pixel(6, -71),
          scale = 0.5
        },
      },
      { -- b
        trunk = {
          width = 114,
          height = 226,
          shift = util.by_pixel(1, -40),
          scale = 0.5
        },
        stump = {
          width = 78,
          height = 68,
          shift = util.by_pixel(-1, 0),
          scale = 0.5
        },
        shadow = {
          width = 290,
          height = 166,
          shift = util.by_pixel(58, 1),
          scale = 0.5
        },
        leaves = {
          width = 222,
          height = 242,
          shift = util.by_pixel(6, -60),
          scale = 0.5
        },
       normal = {
          width = 222,
          height = 212,
          shift = util.by_pixel(6, -67.5),
          scale = 0.5
        },
      },
      { -- c
        trunk = {
          width = 122,
          height = 276,
          shift = util.by_pixel(-10, -54),
          scale = 0.5
        },
        stump = {
          width = 84,
          height = 64,
          shift = util.by_pixel(-1, -1),
          scale = 0.5
        },
        shadow = {
          width = 272,
          height = 162,
          shift = util.by_pixel(52, 3),
          scale = 0.5
        },
        leaves = {
          width = 224,
          height = 290,
          shift = util.by_pixel(-2, -65),
          scale = 0.5
        },
        normal = {
          width = 224,
          height = 256,
          shift = util.by_pixel(-2, -74),
          scale = 0.5
        },
      },
      { -- d
        trunk = {
          width = 120,
          height = 244,
          shift = util.by_pixel(4, -44),
          scale = 0.5
        },
        stump = {
          width = 78,
          height = 70,
          shift = util.by_pixel(1, 0),
          scale = 0.5
        },
        shadow = {
          width = 278,
          height = 168,
          shift = util.by_pixel(54, -2),
          scale = 0.5
        },
        leaves = {
          width = 202,
          height = 244,
          shift = util.by_pixel(5, -59),
          scale = 0.5
        },
        normal = {
          width = 200,
          height = 208,
          shift = util.by_pixel(6, -67),
          scale = 0.5
        },
      },
      { -- e
        trunk = {
          width = 106,
          height = 232,
          shift = util.by_pixel(0, -43),
          scale = 0.5
        },
        stump = {
          width = 80,
          height = 64,
          shift = util.by_pixel(0, -1),
          scale = 0.5
        },
        shadow = {
          width = 268,
          height = 144,
          shift = util.by_pixel(53, 2),
          scale = 0.5
        },
        leaves = {
          width = 236,
          height = 250,
          shift = util.by_pixel(-2, -57),
          scale = 0.5
        },
        normal = {
          width = 236,
          height = 206,
          shift = util.by_pixel(-2, -66.5),
          scale = 0.5
        },
      },
      { -- f
        trunk = {
          width = 112,
          height = 236,
          shift = util.by_pixel(-9, -43),
          scale = 0.5
        },
        stump = {
          width = 80,
          height = 68,
          shift = util.by_pixel(-1, -1),
          scale = 0.5
        },
        shadow = {
          width = 272,
          height = 168,
          shift = util.by_pixel(52, -1),
          scale = 0.5
        },
        leaves = {
          width = 194,
          height = 252,
          shift = util.by_pixel(-4, -54),
          scale = 0.5
        },
        normal = {
          width = 194,
          height = 212,
          shift = util.by_pixel(-3.5, -64),
          scale = 0.5
        },
      },
      { -- g
        trunk = {
          width = 86,
          height = 214,
          shift = util.by_pixel(0, -40),
          scale = 0.5
        },
        stump = {
          width = 64,
          height = 74,
          shift = util.by_pixel(0, -5),
          scale = 0.5
        },
        shadow = {
          width = 238,
          height = 164,
          shift = util.by_pixel(42, -5),
          scale = 0.5
        },
        leaves = {
          width = 178,
          height = 220,
          shift = util.by_pixel(0, -51),
          scale = 0.5
        },
        normal = {
          width = 176,
          height = 216,
          shift = util.by_pixel(1, -51),
          scale = 0.5
        },
      },
      { -- h
        trunk = {
          width = 144,
          height = 212,
          shift = util.by_pixel(7, -39),
          scale = 0.5
        },
        stump = {
          width = 72,
          height = 76,
          shift = util.by_pixel(0, -5),
          scale = 0.5
        },
        shadow = {
          width = 270,
          height = 122,
          shift = util.by_pixel(49, 0),
          scale = 0.5
        },
        leaves = {
          width = 228,
          height = 196,
          shift = util.by_pixel(6, -47),
          scale = 0.5
        },
        normal = {
          width = 228,
          height = 174,
          shift = util.by_pixel(6.5, -51),
          scale = 0.5
        },
      },
      { -- i
        trunk = {
          width = 70,
          height = 184,
          shift = util.by_pixel(-3, -34),
          scale = 0.5
        },
        stump = {
          width = 58,
          height = 60,
          shift = util.by_pixel(0, -3),
          scale = 0.5
        },
        shadow = {
          width = 214,
          height = 118,
          shift = util.by_pixel(40, -3),
          scale = 0.5
        },
        leaves = {
          width = 166,
          height = 200,
          shift = util.by_pixel(-5, -45),
          scale = 0.5
        },
        normal = {
          width = 166,
          height = 166,
          shift = util.by_pixel(-5, -53.5),
          scale = 0.5
        },
      },
      { -- j
        trunk = {
          width = 66,
          height = 162,
          shift = util.by_pixel(3, -29),
          scale = 0.5
        },
        stump = {
          width = 56,
          height = 62,
          shift = util.by_pixel(1, -4),
          scale = 0.5
        },
        shadow = {
          width = 192,
          height = 126,
          shift = util.by_pixel(41, 1),
          scale = 0.5
        },
        leaves = {
          width = 142,
          height = 184,
          shift = util.by_pixel(1, -41),
          scale = 0.5
        },
        normal = {
          width = 144,
          height = 164,
          shift = util.by_pixel(1.5, -45),
          scale = 0.5
        },
      },
      { -- k
        trunk = {
          width = 274,
          height = 176,
          shift = util.by_pixel(-17, 9),
          scale = 0.5
        },
        stump = {
          width = 110,
          height = 88,
          shift = util.by_pixel(24, -13),
          scale = 0.5
        },
        shadow = {
          width = 276,
          height = 160,
          shift = util.by_pixel(-13, 12),
          scale = 0.5
        },
        leaves = {
          width = 234,
          height = 162,
          shift = util.by_pixel(-29, 7),
          scale = 0.5
        },
        normal = {
          width = 170,
          height = 152,
          shift = util.by_pixel(-45, 9.5),
          scale = 0.5
        },
      },
      { -- l
        trunk = {
          width = 252,
          height = 186,
          shift = util.by_pixel(15, -22),
          scale = 0.5
        },
        stump = {
          width = 104,
          height = 70,
          shift = util.by_pixel(-21, 7),
          scale = 0.5
        },
        shadow = {
          width = 258,
          height = 186,
          shift = util.by_pixel(21, -18),
          scale = 0.5
        },
        leaves = {
          width = 252,
          height = 164,
          shift = util.by_pixel(15, -30),
          scale = 0.5
        },
        normal = {
          width = 158,
          height = 146,
          shift = util.by_pixel(34.5, -34.5),
          scale = 0.5
        },
      },
    }
  },
  { -- tree-06
    --addHere-tree06 -- "wyliki"
    type_name = "06",
    locale = "wyliki",
    -- drawing_box = {{-0.9, -3.5}, {0.9, 0.6}},
    drawing_box_vertical_extension = 3.5,
    water_reflection_function = function (variation)
      return
      {
        pictures =
        {
          filename = "__base__/graphics/entity/tree/06/tree-06-reflection.png",
          priority = "extra-high",
          width = 28,
          height = 32,
          shift = util.by_pixel(-5, 35),
          x = 28 * variation,
          variation_count = 1,
          scale = 5,
        },
        rotate = false,
        orientation_to_variation = false
      }
    end,
    variations = { -- tree-06
      { -- a
        trunk = {
          width = 140,
          height = 268,
          shift = util.by_pixel(7, -40),
          scale = 0.5
        },
        stump = {
          width = 118,
          height = 120,
          shift = util.by_pixel(0, -3),
          scale = 0.5
        },
        shadow = {
          width = 338,
          height = 148,
          shift = util.by_pixel(64, 1),
          scale = 0.5
        },
        leaves = {
          width = 132,
          height = 196,
          shift = util.by_pixel(11, -50),
          scale = 0.5
        },
      },
      { -- b
        trunk = {
          width = 168,
          height = 248,
          shift = util.by_pixel(8, -26),
          scale = 0.5
        },
        stump = {
          width = 124,
          height = 132,
          shift = util.by_pixel(0, 3),
          scale = 0.5
        },
        shadow = {
          width = 352,
          height = 116,
          shift = util.by_pixel(67, 12),
          scale = 0.5
        },
        leaves = {
          width = 172,
          height = 186,
          shift = util.by_pixel(9, -40),
          scale = 0.5
        },
      },
      { -- c
        trunk = {
          width = 198,
          height = 208,
          shift = util.by_pixel(0, -15),
          scale = 0.5
        },
        stump = {
          width = 122,
          height = 116,
          shift = util.by_pixel(-3, 8),
          scale = 0.5
        },
        shadow = {
          width = 352,
          height = 98,
          shift = util.by_pixel(65, 16),
          scale = 0.5
        },
        leaves = {
          width = 178,
          height = 162,
          shift = util.by_pixel(3, -29),
          scale = 0.5
        },
      },
      { -- d
        trunk = {
          width = 148,
          height = 244,
          shift = util.by_pixel(-16, -21),
          scale = 0.5
        },
        stump = {
          width = 120,
          height = 128,
          shift = util.by_pixel(-6, 8),
          scale = 0.5
        },
        shadow = {
          width = 308,
          height = 130,
          shift = util.by_pixel(43, 15),
          scale = 0.5
        },
        leaves = {
          width = 150,
          height = 180,
          shift = util.by_pixel(-15, -39),
          scale = 0.5
        },
      },
      { -- e
        trunk = {
          width = 154,
          height = 270,
          shift = util.by_pixel(-15, -33),
          scale = 0.5
        },
        stump = {
          width = 126,
          height = 106,
          shift = util.by_pixel(-8, 8),
          scale = 0.5
        },
        shadow = {
          width = 248,
          height = 146,
          shift = util.by_pixel(26, 7),
          scale = 0.5
        },
        leaves = {
          width = 136,
          height = 226,
          shift = util.by_pixel(-18, -48),
          scale = 0.5
        },
      },
      { -- f
        trunk = {
          width = 184,
          height = 268,
          shift = util.by_pixel(-17, -37),
          scale = 0.5
        },
        stump = {
          width = 122,
          height = 120,
          shift = util.by_pixel(-10, 0),
          scale = 0.5
        },
        shadow = {
          width = 326,
          height = 110,
          shift = util.by_pixel(42, -5),
          scale = 0.5
        },
        leaves = {
          width = 180,
          height = 230,
          shift = util.by_pixel(-19, -49),
          scale = 0.5
        },
      },
      { -- g
        trunk = {
          width = 194,
          height = 266,
          shift = util.by_pixel(-9, -36),
          scale = 0.5
        },
        stump = {
          width = 122,
          height = 126,
          shift = util.by_pixel(-7, -1),
          scale = 0.5
        },
        shadow = {
          width = 354,
          height = 100,
          shift = util.by_pixel(55, -7),
          scale = 0.5
        },
        leaves = {
          width = 178,
          height = 228,
          shift = util.by_pixel(-9, -47),
          scale = 0.5
        },
      },
      { -- h
        trunk = {
          width = 166,
          height = 258,
          shift = util.by_pixel(5, -36),
          scale = 0.5
        },
        stump = {
          width = 128,
          height = 114,
          shift = util.by_pixel(-5, 0),
          scale = 0.5
        },
        shadow = {
          width = 320,
          height = 146,
          shift = util.by_pixel(56, -7),
          scale = 0.5
        },
        leaves = {
          width = 144,
          height = 190,
          shift = util.by_pixel(13, -46),
          scale = 0.5
        },
      },
      { -- i
        trunk = {
          width = 152,
          height = 238,
          shift = util.by_pixel(-14, -21),
          scale = 0.5
        },
        stump = {
          width = 144,
          height = 126,
          shift = util.by_pixel(-12, 7),
          scale = 0.5
        },
        shadow = {
          width = 228,
          height = 148,
          shift = util.by_pixel(19, 13),
          scale = 0.5
        },
        leaves = {
          width = 132,
          height = 186,
          shift = util.by_pixel(-19, -37),
          scale = 0.5
        },
      },
      { -- j
        trunk = {
          width = 142,
          height = 232,
          shift = util.by_pixel(-12, -22),
          scale = 0.5
        },
        stump = {
          width = 134,
          height = 116,
          shift = util.by_pixel(-10, 7),
          scale = 0.5
        },
        shadow = {
          width = 256,
          height = 148,
          shift = util.by_pixel(26, 9),
          scale = 0.5
        },
        leaves = {
          width = 134,
          height = 182,
          shift = util.by_pixel(-15, -38),
          scale = 0.5
        },
      },
    },
  },
  { -- tree-07
    --addHere-tree07 -- "cedar"
    type_name = "07",
    locale = "cednar",
    -- drawing_box = {{-0.9, -3.5}, {0.9, 0.6}},
    drawing_box_vertical_extension = 3.5,
    negate_tint = { r = 80, g = 77, b = 61 },
    water_reflection_function = function (variation)
      return
      {
        pictures =
        {
          filename = "__base__/graphics/entity/tree/07/tree-07-reflection.png",
          priority = "extra-high",
          width = 40,
          height = 40,
          shift = util.by_pixel(0, 65),
          y = 40 * variation,
          variation_count = 4,
          scale = 5,
        },
        rotate = false,
        orientation_to_variation = false
      }
    end,
    variations = { -- tree-07
      { -- a
        trunk =
        {
          width = 174,
          height = 320,
          shift = util.by_pixel(-2, -60),
          scale = 0.5
        },
        stump =
        {
          width = 88,
          height = 88,
          shift = util.by_pixel(0, -2),
          scale = 0.5
        },
        shadow =
        {
          width = 350,
          height = 190,
          shift = util.by_pixel(64, -10),
          scale = 0.5
        },
        leaves =
        {
          width = 244,
          height = 336,
          shift = util.by_pixel(2, -67),
          scale = 0.5
        },
        normal =
        {
          width = 246,
          height = 290,
          shift = util.by_pixel(2.5, -78.5),
          scale = 0.5
        },
      },
      { -- b
        trunk =
        {
          width = 178,
          height = 306,
          shift = util.by_pixel(10, -58),
          scale = 0.5
        },
        stump =
        {
          width = 100,
          height = 86,
          shift = util.by_pixel(0, -3),
          scale = 0.5
        },
        shadow =
        {
          width = 368,
          height = 178,
          shift = util.by_pixel(71, -3),
          scale = 0.5
        },
        leaves =
        {
          width = 280,
          height = 296,
          shift = util.by_pixel(9, -62),
          scale = 0.5
        },
        normal =
        {
          width = 282,
          height = 250,
          shift = util.by_pixel(9.5, -72),
          scale = 0.5
        },
      },
      { -- c
        trunk =
        {
          width = 180,
          height = 300,
          shift = util.by_pixel(-10, -57),
          scale = 0.5
        },
        stump =
        {
          width = 98,
          height = 82,
          shift = util.by_pixel(1, -2),
          scale = 0.5
        },
        shadow =
        {
          width = 284,
          height = 174,
          shift = util.by_pixel(47, -2),
          scale = 0.5
        },
        leaves =
        {
          width = 270,
          height = 324,
          shift = util.by_pixel(-15, -68),
          scale = 0.5
        },
        normal =
        {
          width = 270,
          height = 304,
          shift = util.by_pixel(-14, -71),
          scale = 0.5
        },
      },
      { -- d
        trunk =
        {
          width = 172,
          height = 268,
          shift = util.by_pixel(-2, -49),
          scale = 0.5
        },
        stump =
        {
          width = 84,
          height = 76,
          shift = util.by_pixel(0, -1),
          scale = 0.5
        },
        shadow =
        {
          width = 290,
          height = 172,
          shift = util.by_pixel(68, 1),
          scale = 0.5
        },
        leaves =
        {
          width = 230,
          height = 290,
          shift = util.by_pixel(0, -66),
          scale = 0.5
        },
        normal =
        {
          width = 232,
          height = 248,
          shift = util.by_pixel(1, -76.5),
          scale = 0.5
        },
      },
      { -- e
        trunk =
        {
          width = 204,
          height = 286,
          shift = util.by_pixel(0, -53),
          scale = 0.5
        },
        stump =
        {
          width = 88,
          height = 78,
          shift = util.by_pixel(1, -1),
          scale = 0.5
        },
        shadow =
        {
          width = 318,
          height = 166,
          shift = util.by_pixel(69, -1),
          scale = 0.5
        },
        leaves =
        {
          width = 244,
          height = 292,
          shift = util.by_pixel(3, -63),
          scale = 0.5
        },
        normal =
        {
          width = 242,
          height = 238,
          shift = util.by_pixel(4, -75.5),
          scale = 0.5
        },
      },
      { -- f
        trunk =
        {
          width = 196,
          height = 280,
          shift = util.by_pixel(-3, -53),
          scale = 0.5
        },
        stump =
        {
          width = 82,
          height = 76,
          shift = util.by_pixel(0, -2),
          scale = 0.5
        },
        shadow =
        {
          width = 270,
          height = 188,
          shift = util.by_pixel(57, -5),
          scale = 0.5
        },
        leaves =
        {
          width = 256,
          height = 282,
          shift = util.by_pixel(-5, -74),
          scale = 0.5
        },
        normal =
        {
          width = 254,
          height = 264,
          shift = util.by_pixel(-4, -77),
          scale = 0.5
        },
      },
      { -- g
        trunk =
        {
          width = 180,
          height = 218,
          shift = util.by_pixel(8, -39),
          scale = 0.5
        },
        stump =
        {
          width = 86,
          height = 72,
          shift = util.by_pixel(0, -2),
          scale = 0.5
        },
        shadow =
        {
          width = 266,
          height = 154,
          shift = util.by_pixel(60, -2),
          scale = 0.5
        },
        leaves =
        {
          width = 222,
          height = 258,
          shift = util.by_pixel(10, -54),
          scale = 0.5
        },
        normal =
        {
          width = 222,
          height = 222,
          shift = util.by_pixel(10.5, -61),
          scale = 0.5
        },
      },
      { -- h
        trunk =
        {
          width = 166,
          height = 246,
          shift = util.by_pixel(-10, -42),
          scale = 0.5
        },
        stump =
        {
          width = 84,
          height = 76,
          shift = util.by_pixel(0, 0),
          scale = 0.5
        },
        shadow =
        {
          width = 288,
          height = 146,
          shift = util.by_pixel(47, 1),
          scale = 0.5
        },
        leaves =
        {
          width = 228,
          height = 242,
          shift = util.by_pixel(-10, -53),
          scale = 0.5
        },
        normal =
        {
          width = 226,
          height = 218,
          shift = util.by_pixel(-9, -57.5),
          scale = 0.5
        },
      },
      { -- i
        trunk =
        {
          width = 142,
          height = 204,
          shift = util.by_pixel(1, -35),
          scale = 0.5
        },
        stump =
        {
          width = 80,
          height = 72,
          shift = util.by_pixel(2, -2),
          scale = 0.5
        },
        shadow =
        {
          width = 222,
          height = 140,
          shift = util.by_pixel(48, -1),
          scale = 0.5
        },
        leaves =
        {
          width = 182,
          height = 218,
          shift = util.by_pixel(-1, -54),
          scale = 0.5
        },
        normal =
        {
          width = 184,
          height = 206,
          shift = util.by_pixel(-0.5, -56.5),
          scale = 0.5
        },
      },
      { -- j
        trunk =
        {
          width = 154,
          height = 198,
          shift = util.by_pixel(-2, -34),
          scale = 0.5
        },
        stump =
        {
          width = 80,
          height = 80,
          shift = util.by_pixel(1, -5),
          scale = 0.5
        },
        shadow =
        {
          width = 258,
          height = 126,
          shift = util.by_pixel(53, 0),
          scale = 0.5
        },
        leaves =
        {
          width = 200,
          height = 200,
          shift = util.by_pixel(2, -44),
          scale = 0.5
        },
        normal =
        {
          width = 202,
          height = 170,
          shift = util.by_pixel(2, -50.5),
          scale = 0.5
        },
      },
      { -- k
        trunk =
        {
          width = 226,
          height = 274,
          shift = util.by_pixel(3, -22),
          scale = 0.5
        },
        stump =
        {
          width = 120,
          height = 96,
          shift = util.by_pixel(-9, 11),
          scale = 0.5
        },
        shadow =
        {
          width = 264,
          height = 230,
          shift = util.by_pixel(20, -14),
          scale = 0.5
        },
        leaves =
        {
          width = 204,
          height = 198,
          shift = util.by_pixel(15, -43),
          scale = 0.5
        },
        normal =
        {
          width = 204,
          height = 184,
          shift = util.by_pixel(16, -46.5),
          scale = 0.5
        },
      },
      { -- l
        trunk =
        {
          width = 314,
          height = 124,
          shift = util.by_pixel(-26, 4),
          scale = 0.5
        },
        stump =
        {
          width = 104,
          height = 94,
          shift = util.by_pixel(3, -2),
          scale = 0.5
        },
        shadow =
        {
          width = 354,
          height = 156,
          shift = util.by_pixel(-24, 15),
          scale = 0.5
        },
        leaves =
        {
          width = 328,
          height = 144,
          shift = util.by_pixel(-31, 3),
          scale = 0.5
        },
        normal =
        {
          width = 242,
          height = 146,
          shift = util.by_pixel(-51, 3.5),
          scale = 0.5
        },
      }
    },
  },
  { -- tree-08
    --addHere-tree08 -- "beech"
    type_name = "08",
    locale = "beesh",
    -- drawing_box = {{-0.9, -3}, {0.9, 0.6}},
    drawing_box_vertical_extension = 3,
    negate_tint = { r = 80, g = 77, b = 61 },
    water_reflection_function = function (variation)
      return
      {
        pictures =
        {
          filename = "__base__/graphics/entity/tree/08/tree-08-reflection.png",
          priority = "extra-high",
          width = 36,
          height = 40,
          shift = util.by_pixel(0, 75),
          y = 40 * variation,
          variation_count = 4,
          scale = 5,
        },
        rotate = false,
        orientation_to_variation = false
      }
    end,
    variations = { -- tree-08
      { -- a
        trunk =
        {
          width = 210,
          height = 286,
          shift = util.by_pixel(-5, -58),
          scale = 0.5
        },
        stump =
        {
          width = 76,
          height = 70,
          shift = util.by_pixel(3, -4),
          scale = 0.5
        },
        shadow =
        {
          width = 310,
          height = 222,
          shift = util.by_pixel(71, 2),
          scale = 0.5
        },
        leaves =
        {
          width = 262,
          height = 282,
          shift = util.by_pixel(-6, -77),
          scale = 0.5
        },
        normal =
        {
          width = 260,
          height = 222,
          shift = util.by_pixel(-5, -91),
          scale = 0.5
        },
      },
      { -- b
        trunk =
        {
          width = 238,
          height = 276,
          shift = util.by_pixel(-3, -55),
          scale = 0.5
        },
        stump =
        {
          width = 76,
          height = 68,
          shift = util.by_pixel(1, -3),
          scale = 0.5
        },
        shadow =
        {
          width = 322,
          height = 178,
          shift = util.by_pixel(77, -5),
          scale = 0.5
        },
        leaves =
        {
          width = 322,
          height = 306,
          shift = util.by_pixel(-3, -70),
          scale = 0.5
        },
        normal =
        {
          width = 322,
          height = 206,
          shift = util.by_pixel(-2, -95),
          scale = 0.5
        },
      },
      { -- c
        trunk =
        {
          width = 210,
          height = 300,
          shift = util.by_pixel(3, -63),
          scale = 0.5
        },
        stump =
        {
          width = 72,
          height = 66,
          shift = util.by_pixel(1, -4),
          scale = 0.5
        },
        shadow =
        {
          width = 326,
          height = 228,
          shift = util.by_pixel(72, -2),
          scale = 0.5
        },
        leaves =
        {
          width = 252,
          height = 294,
          shift = util.by_pixel(6, -83),
          scale = 0.5
        },
        normal =
        {
          width = 254,
          height = 260,
          shift = util.by_pixel(6.5, -90),
          scale = 0.5
        },
      },
      { -- d
        trunk =
        {
          width = 166,
          height = 228,
          shift = util.by_pixel(1, -45),
          scale = 0.5
        },
        stump =
        {
          width = 74,
          height = 68,
          shift = util.by_pixel(4, -5),
          scale = 0.5
        },
        shadow =
        {
          width = 274,
          height = 170,
          shift = util.by_pixel(71, 7),
          scale = 0.5
        },
        leaves =
        {
          width = 214,
          height = 220,
          shift = util.by_pixel(0, -73),
          scale = 0.5
        },
        normal =
        {
          width = 216,
          height = 182,
          shift = util.by_pixel(0.5, -82),
          scale = 0.5
        },
      },
      { -- e
        trunk =
        {
          width = 172,
          height = 242,
          shift = util.by_pixel(-7, -49),
          scale = 0.5
        },
        stump =
        {
          width = 76,
          height = 62,
          shift = util.by_pixel(3, -4),
          scale = 0.5
        },
        shadow =
        {
          width = 296,
          height = 150,
          shift = util.by_pixel(65, 5),
          scale = 0.5
        },
        leaves =
        {
          width = 228,
          height = 210,
          shift = util.by_pixel(2, -71),
          scale = 0.5
        },
        normal =
        {
          width = 228,
          height = 166,
          shift = util.by_pixel(2.5, -79.5),
          scale = 0.5
        },
      },
      { -- f
        trunk =
        {
          width = 166,
          height = 272,
          shift = util.by_pixel(-3, -55),
          scale = 0.5
        },
        stump =
        {
          width = 70,
          height = 64,
          shift = util.by_pixel(-1, -3),
          scale = 0.5
        },
        shadow =
        {
          width = 274,
          height = 170,
          shift = util.by_pixel(63, -7),
          scale = 0.5
        },
        leaves =
        {
          width = 218,
          height = 294,
          shift = util.by_pixel(-2, -67),
          scale = 0.5
        },
        normal =
        {
          width = 216,
          height = 200,
          shift = util.by_pixel(-1, -90.5),
          scale = 0.5
        },
      },
      { -- g
        trunk =
        {
          width = 146,
          height = 222,
          shift = util.by_pixel(14, -43),
          scale = 0.5
        },
        stump =
        {
          width = 68,
          height = 56,
          shift = util.by_pixel(3, -2),
          scale = 0.5
        },
        shadow =
        {
          width = 272,
          height = 138,
          shift = util.by_pixel(64, -8),
          scale = 0.5
        },
        leaves =
        {
          width = 190,
          height = 192,
          shift = util.by_pixel(12, -71),
          scale = 0.5
        },
        normal =
        {
          width = 192,
          height = 164,
          shift = util.by_pixel(12.5, -77),
          scale = 0.5
        },
      },
      { -- h
        trunk =
        {
          width = 160,
          height = 190,
          shift = util.by_pixel(-10, -34),
          scale = 0.5
        },
        stump =
        {
          width = 62,
          height = 58,
          shift = util.by_pixel(-1, -1),
          scale = 0.5
        },
        shadow =
        {
          width = 224,
          height = 128,
          shift = util.by_pixel(53, 7),
          scale = 0.5
        },
        leaves =
        {
          width = 218,
          height = 174,
          shift = util.by_pixel(-9, -54),
          scale = 0.5
        },
        normal =
        {
          width = 218,
          height = 152,
          shift = util.by_pixel(-8.5, -58.5),
          scale = 0.5
        },
      },
      { -- i
        trunk =
        {
          width = 78,
          height = 176,
          shift = util.by_pixel(-2, -33),
          scale = 0.5
        },
        stump =
        {
          width = 68,
          height = 62,
          shift = util.by_pixel(2, -4),
          scale = 0.5
        },
        shadow =
        {
          width = 186,
          height = 102,
          shift = util.by_pixel(45, -5),
          scale = 0.5
        },
        leaves =
        {
          width = 130,
          height = 168,
          shift = util.by_pixel(3, -60),
          scale = 0.5
        },
        normal =
        {
          width = 128,
          height = 154,
          shift = util.by_pixel(4, -62.5),
          scale = 0.5
        },
      },
      { -- j
        trunk =
        {
          width = 88,
          height = 180,
          shift = util.by_pixel(3, -33),
          scale = 0.5
        },
        stump =
        {
          width = 64,
          height = 64,
          shift = util.by_pixel(3, -4),
          scale = 0.5
        },
        shadow =
        {
          width = 208,
          height = 100,
          shift = util.by_pixel(46, -2),
          scale = 0.5
        },
        leaves =
        {
          width = 162,
          height = 160,
          shift = util.by_pixel(3, -56),
          scale = 0.5
        },
        normal =
        {
          width = 162,
          height = 148,
          shift = util.by_pixel(4, -58.5),
          scale = 0.5
        },
      },
      { -- k
        trunk =
        {
          width = 300,
          height = 218,
          shift = util.by_pixel(-22, -24),
          scale = 0.5
        },
        stump =
        {
          width = 110,
          height = 78,
          shift = util.by_pixel(12, 0),
          scale = 0.5
        },
        shadow =
        {
          width = 320,
          height = 180,
          shift = util.by_pixel(-18, -16),
          scale = 0.5
        },
        leaves =
        {
          width = 308,
          height = 240,
          shift = util.by_pixel(-34, -35),
          scale = 0.5
        },
        normal =
        {
          width = 180,
          height = 188,
          shift = util.by_pixel(-66.5, -46.5),
          scale = 0.5
        },
      },
      { -- l
        trunk =
        {
          width = 274,
          height = 204,
          shift = util.by_pixel(25, 10),
          scale = 0.5
        },
        stump =
        {
          width = 102,
          height = 92,
          shift = util.by_pixel(-1, -1),
          scale = 0.5
        },
        shadow =
        {
          width = 324,
          height = 216,
          shift = util.by_pixel(42, 24),
          scale = 0.5
        },
        leaves =
        {
          width = 246,
          height = 198,
          shift = util.by_pixel(48, 9),
          scale = 0.5
        },
        normal =
        {
          width = 200,
          height = 108,
          shift = util.by_pixel(60, 28),
          scale = 0.5
        },
      }
    },
  },
  { -- tree-09 -- "baarell"
    --addHere-tree09
    type_name = "09",
    locale = "baarell",
    -- drawing_box = {{-0.9, -3.5}, {0.9, 0.6}},
    drawing_box_vertical_extension = 3.5,
    negate_tint = { r = 128, g = 124, b = 104},
    water_reflection_function = function (variation)
      return
      {
        pictures =
        {
          filename = "__base__/graphics/entity/tree/09/tree-09-reflection.png",
          priority = "extra-high",
          width = 44,
          height = 48,
          shift = util.by_pixel(5, 75),
          y = 48 * variation,
          variation_count = 4,
          scale = 5,
        },
        rotate = false,
        orientation_to_variation = false
      }
    end,
    variations = { -- tree-09
      { -- a
        trunk =
        {
          width = 308,
          height = 392,
          shift = util.by_pixel(0, -68),
          scale = 0.5
        },
        stump =
        {
          width = 182,
          height = 124,
          shift = util.by_pixel(-4, -1),
          scale = 0.5
        },
        shadow =
        {
          width = 458,
          height = 214,
          shift = util.by_pixel(86, 0),
          scale = 0.5
        },
        leaves =
        {
          width = 350,
          height = 390,
          shift = util.by_pixel(0, -78),
          scale = 0.5
        },
        normal =
        {
          width = 350,
          height = 294,
          shift = util.by_pixel(1, -102),
          scale = 0.5
        },
      },
      { -- b
        trunk =
        {
          width = 294,
          height = 390,
          shift = util.by_pixel(8, -69),
          scale = 0.5
        },
        stump =
        {
          width = 178,
          height = 124,
          shift = util.by_pixel(5, -2),
          scale = 0.5
        },
        shadow =
        {
          width = 374,
          height = 226,
          shift = util.by_pixel(82, 7),
          scale = 0.5
        },
        leaves =
        {
          width = 334,
          height = 368,
          shift = util.by_pixel(7, -88),
          scale = 0.5
        },
        normal =
        {
          width = 336,
          height = 306,
          shift = util.by_pixel(8, -102),
          scale = 0.5
        },
      },
      { -- c
        trunk =
        {
          width = 258,
          height = 392,
          shift = util.by_pixel(-3, -65),
          scale = 0.5
        },
        stump =
        {
          width = 144,
          height = 128,
          shift = util.by_pixel(-3, 1),
          scale = 0.5
        },
        shadow =
        {
          width = 364,
          height = 222,
          shift = util.by_pixel(73, -4),
          scale = 0.5
        },
        leaves =
        {
          width = 266,
          height = 408,
          shift = util.by_pixel(3, -78),
          scale = 0.5
        },
        normal =
        {
          width = 268,
          height = 356,
          shift = util.by_pixel(3.5, -89.5),
          scale = 0.5
        },
      },
      { -- d
        trunk =
        {
          width = 264,
          height = 348,
          shift = util.by_pixel(4, -56),
          scale = 0.5
        },
        stump =
        {
          width = 146,
          height = 140,
          shift = util.by_pixel(1, -4),
          scale = 0.5
        },
        shadow =
        {
          width = 344,
          height = 232,
          shift = util.by_pixel(80, -1),
          scale = 0.5
        },
        leaves =
        {
          width = 284,
          height = 308,
          shift = util.by_pixel(-1, -76),
          scale = 0.5
        },
        normal =
        {
          width = 282,
          height = 256,
          shift = util.by_pixel(0, -87.5),
          scale = 0.5
        },
      },
      { -- e
        trunk =
        {
          width = 252,
          height = 272,
          shift = util.by_pixel(10, -44),
          scale = 0.5
        },
        stump =
        {
          width = 126,
          height = 100,
          shift = util.by_pixel(-1, -1),
          scale = 0.5
        },
        shadow =
        {
          width = 306,
          height = 190,
          shift = util.by_pixel(73, 13),
          scale = 0.5
        },
        leaves =
        {
          width = 280,
          height = 264,
          shift = util.by_pixel(12, -56),
          scale = 0.5
        },
        normal =
        {
          width = 278,
          height = 224,
          shift = util.by_pixel(13, -65),
          scale = 0.5
        },
      },
      { -- f
        trunk =
        {
          width = 246,
          height = 286,
          shift = util.by_pixel(-19, -47),
          scale = 0.5
        },
        stump =
        {
          width = 132,
          height = 98,
          shift = util.by_pixel(4, 0),
          scale = 0.5
        },
        shadow =
        {
          width = 282,
          height = 184,
          shift = util.by_pixel(55, 8),
          scale = 0.5
        },
        leaves =
        {
          width = 260,
          height = 288,
          shift = util.by_pixel(-11, -58),
          scale = 0.5
        },
        normal =
        {
          width = 258,
          height = 254,
          shift = util.by_pixel(-9.5, -66.5),
          scale = 0.5
        },
      },
      { -- g
        trunk =
        {
          width = 240,
          height = 312,
          shift = util.by_pixel(-11, -52),
          scale = 0.5
        },
        stump =
        {
          width = 126,
          height = 104,
          shift = util.by_pixel(0, 0),
          scale = 0.5
        },
        shadow =
        {
          width = 310,
          height = 182,
          shift = util.by_pixel(55, -14),
          scale = 0.5
        },
        leaves =
        {
          width = 266,
          height = 296,
          shift = util.by_pixel(-13, -67),
          scale = 0.5
        },
        normal =
        {
          width = 266,
          height = 218,
          shift = util.by_pixel(-12.5, -85.5),
          scale = 0.5
        },
      },
      { -- h
        trunk =
        {
          width = 256,
          height = 312,
          shift = util.by_pixel(18, -52),
          scale = 0.5
        },
        stump =
        {
          width = 122,
          height = 102,
          shift = util.by_pixel(0, 1),
          scale = 0.5
        },
        shadow =
        {
          width = 296,
          height = 192,
          shift = util.by_pixel(75, -10),
          scale = 0.5
        },
        leaves =
        {
          width = 250,
          height = 292,
          shift = util.by_pixel(18, -64),
          scale = 0.5
        },
        normal =
        {
          width = 238,
          height = 216,
          shift = util.by_pixel(17, -83.5),
          scale = 0.5
        },
      }
    },
  },
  { -- tree-01
    --addHere-tree01
    type_name = "oaktapus",
    locale = "oaktapus",
    alien_biomes_texture = true,
    normals_match_leaves = true,
    -- drawing_box = {{-0.9, -3}, {0.9, 0.6}},
    drawing_box_vertical_extension = 3,
    water_reflection_function = function (variation)
      return
      {
        pictures =
        {
          filename = "__Alien-biomes-Reforged__/graphics/entity/tree/oaktapus/tree-oaktapus-reflection.png",
          priority = "extra-high",
          width = 148/4,
          height = 390/10,
          shift = util.by_pixel(0, 60),
          y = 390/10 * variation,
          variation_count = 4,
          scale = 5,
        },
        rotate = false,
        orientation_to_variation = false
      }
    end,
    variations = {
      { -- a
        trunk = {
          width = 354,
          height = 298,
          shift = util.by_pixel(30.5, -37.5),
          scale = 0.5
        },
        leaves = {
          width = 204,
          height = 231,
          shift = util.by_pixel(-10.5, -64.75),
          scale = 0.5
        },
      },
      { -- b
        trunk = {
          width = 358,
          height = 298,
          shift = util.by_pixel(50, -40),
          scale = 0.5
        },
        leaves = {
          width = 178,
          height = 215,
          shift = util.by_pixel(4, -69.25),
          scale = 0.5
        },
      },
      { -- c
        trunk = {
          width = 313,
          height = 291,
          shift = util.by_pixel(52.25, -33.75),
          scale = 0.5
        },
        leaves = {
          width = 190,
          height = 210,
          shift = util.by_pixel(6.5, -63.5),
          scale = 0.5
        },
      },
      { -- d
        trunk = {
          width = 351,
          height = 302,
          shift = util.by_pixel(55.25, -34.5),
          scale = 0.5
        },
        leaves = {
          width = 205,
          height = 212,
          shift = util.by_pixel(12.25, -62),
          scale = 0.5
        },
      },
      { -- e
        trunk = {
          width = 346,
          height = 281,
          shift = util.by_pixel(56.5, -34.75),
          scale = 0.5
        },
        leaves = {
          width = 212,
          height = 221,
          shift = util.by_pixel(17, -54.75),
          scale = 0.5
        },
      },
      { -- f
        trunk = {
          width = 350,
          height = 280,
          shift = util.by_pixel(42.5, -22),
          scale = 0.5
        },
        leaves = {
          width = 191,
          height = 203,
          shift = util.by_pixel(0.75, -45.75),
          scale = 0.5
        },
      },
      { -- g
        trunk = {
          width = 328,
          height = 301,
          shift = util.by_pixel(20.5, -23.75),
          scale = 0.5
        },
        leaves = {
          width = 193,
          height = 239,
          shift = util.by_pixel(-17.75, -49.75),
          scale = 0.5
        },
      },
      { -- h
        trunk = {
          width = 360,
          height = 288,
          shift = util.by_pixel(27, -32.5),
          scale = 0.5
        },
        leaves = {
          width = 216,
          height = 216,
          shift = util.by_pixel(-20, -59),
          scale = 0.5
        },
      },
      { -- i
        trunk = {
          width = 329,
          height = 323,
          shift = util.by_pixel(41.75, -21.25),
          scale = 0.5
        },
        leaves = {
          width = 177,
          height = 244,
          shift = util.by_pixel(0.75, -47),
          scale = 0.5
        },
      },
      { -- j
        trunk = {
          width = 264,
          height = 229,
          shift = util.by_pixel(35.5, -29.25),
          scale = 0.5
        },
        leaves = {
          width = 180,
          height = 179,
          shift = util.by_pixel(5, -52.25),
          scale = 0.5
        },
      },
    },
  },
  { -- tree-02
    --addHere-tree02
    type_name = "greypine",
    locale = "grepine",
    alien_biomes_texture = true,
    normals_match_leaves = true,
    -- drawing_box = {{-0.9, -3.9}, {0.9, 0.6}},
    drawing_box_vertical_extension = 3.9,
    water_reflection_function = function (variation)
      return
      {
        pictures =
        {
          filename = "__Alien-biomes-Reforged__/graphics/entity/tree/greypine/tree-greypine-reflection.png",
          priority = "extra-high",
          width = 132/4,
          height = 225/5,
          shift = util.by_pixel(0, 60),
          y = 225/5 * variation,
          variation_count = 4,
          scale = 5,
        },
        rotate = false,
        orientation_to_variation = false
      }
    end,
    variations = {
      { -- a
        trunk = {
          width = 448,
          height = 340,
          shift = util.by_pixel(61.5, -47.5),
          scale = 0.5
        },
        leaves = {
          width = 190,
          height = 261,
          shift = util.by_pixel(-4.5, -70.75),
          scale = 0.5
        },
      },
      { -- b
        trunk = {
          width = 558,
          height = 385,
          shift = util.by_pixel(32, -43.25),
          scale = 0.5
        },
        leaves = {
          width = 194,
          height = 285,
          shift = util.by_pixel(-6, -70.25),
          scale = 0.5
        },
      },
      { -- c
        trunk = {
          width = 499,
          height = 377,
          shift = util.by_pixel(69.25, -50.75),
          scale = 0.5
        },
        leaves = {
          width = 213,
          height = 309,
          shift = util.by_pixel(-3.25, -83.25),
          scale = 0.5
        },
      },
      { -- d
        trunk = {
          width = 541,
          height = 374,
          shift = util.by_pixel(90.25, -51),
          scale = 0.5
        },
        leaves = {
          width = 238,
          height = 309,
          shift = util.by_pixel(14, -70.25),
          scale = 0.5
        },
      },
      { -- e
        trunk = {
          width = 512,
          height = 381,
          shift = util.by_pixel(73.5, -46.25),
          scale = 0.5
        },
        leaves = {
          width = 207,
          height = 286,
          shift = util.by_pixel(-2.75, -73),
          scale = 0.5
        },
      },
    },
  },
  { -- tree-03
    --addHere-tree03
    type_name = "ash",
    locale = "vash",
    alien_biomes_texture = true,
    normals_match_leaves = true,
    -- drawing_box = {{-0.9, -3.7}, {0.9, 0.6}},
    drawing_box_vertical_extension = 3.7,
    water_reflection_function = function (variation)
      return
      {
        pictures =
        {
          filename = "__Alien-biomes-Reforged__/graphics/entity/tree/ash/tree-ash-reflection.png",
          priority = "extra-high",
          width = 136/4,
          height = 287/7,
          shift = util.by_pixel(0, 60),
          y = 287/7 * variation,
          variation_count = 4,
          scale = 5,
        },
        rotate = false,
        orientation_to_variation = false
      }
    end,
    variations = {
      { -- a
        trunk = {
          width = 487,
          height = 312,
          shift = util.by_pixel(72.75, -45),
          scale = 0.5
        },
        leaves = {
          width = 237,
          height = 195,
          shift = util.by_pixel(13.25, -75.75),
          scale = 0.5
        },
      },
      { -- b
        trunk = {
          width = 324,
          height = 246,
          shift = util.by_pixel(50, -39),
          scale = 0.5
        },
        leaves = {
          width = 157,
          height = 144,
          shift = util.by_pixel(12.75, -65),
          scale = 0.5
        },
      },
      { -- c
        trunk = {
          width = 387,
          height = 337,
          shift = util.by_pixel(59.75, -51.25),
          scale = 0.5
        },
        leaves = {
          width = 187,
          height = 178,
          shift = util.by_pixel(13.25, -91.5),
          scale = 0.5
        },
      },
      { -- d
        trunk = {
          width = 473,
          height = 337,
          shift = util.by_pixel(64.75, -53.75),
          scale = 0.5
        },
        leaves = {
          width = 204,
          height = 167,
          shift = util.by_pixel(0.5, -97.75),
          scale = 0.5
        },
      },
      { -- e
        trunk = {
          width = 516,
          height = 285,
          shift = util.by_pixel(59, -48.75),
          scale = 0.5
        },
        leaves = {
          width = 235,
          height = 167,
          shift = util.by_pixel(-6.75, -79.75),
          scale = 0.5
        },
      },
      { -- f
        trunk = {
          width = 427,
          height = 315,
          shift = util.by_pixel(48.75, -43.75),
          scale = 0.5
        },
        leaves = {
          width = 186,
          height = 201,
          shift = util.by_pixel(-8, -66.25),
          scale = 0.5
        },
      },
      { -- g
        trunk = {
          width = 352,
          height = 299,
          shift = util.by_pixel(40, -35.25),
          scale = 0.5
        },
        leaves = {
          width = 155,
          height = 212,
          shift = util.by_pixel(-5.25, -59),
          scale = 0.5
        },
      },
    },
  },
  { -- tree-04
    --addHere-tree04
    type_name = "scarecrow",
    locale = "scarecrow",
    alien_biomes_texture = true,
    normals_match_leaves = true,
    -- drawing_box = {{-0.9, -3.9}, {0.9, 0.6}},
    drawing_box_vertical_extension = 3.9,
    water_reflection_function = function (variation)
      return
      {
        pictures =
        {
          filename = "__Alien-biomes-Reforged__/graphics/entity/tree/scarecrow/tree-scarecrow-reflection.png",
          priority = "extra-high",
          width = 132/4,
          height = 344/8,
          shift = util.by_pixel(0, 60),
          y = 344/8 * variation,
          variation_count = 4,
          scale = 5,
        },
        rotate = false,
        orientation_to_variation = false
      }
    end,
    variations = {
      { -- a
        trunk = {
          width = 509,
          height = 340,
          shift = util.by_pixel(78.75, -49.5),
          scale = 0.5
        },
        leaves = {
          width = 197,
          height = 254,
          shift = util.by_pixel(0.25, -75.5),
          scale = 0.5
        },
      },
      { -- b
        trunk = {
          width = 463,
          height = 336,
          shift = util.by_pixel(70.25, -45.5),
          scale = 0.5
        },
        leaves = {
          width = 212,
          height = 280,
          shift = util.by_pixel(4, -67.5),
          scale = 0.5
        },
      },
      { -- c
        trunk = {
          width = 530,
          height = 353,
          shift = util.by_pixel(92.5, -47.25),
          scale = 0.5
        },
        leaves = {
          width = 197,
          height = 250,
          shift = util.by_pixel(2.25, -74.5),
          scale = 0.5
        },
      },
      { -- d
        trunk = {
          width = 545,
          height = 348,
          shift = util.by_pixel(88.75, -46.5),
          scale = 0.5
        },
        leaves = {
          width = 198,
          height = 248,
          shift = util.by_pixel(-6, -75),
          scale = 0.5
        },
      },
      { -- e
        trunk = {
          width = 492,
          height = 365,
          shift = util.by_pixel(63.5, -50.75),
          scale = 0.5
        },
        leaves = {
          width = 217,
          height = 273,
          shift = util.by_pixel(-7.75, -76.25),
          scale = 0.5
        },
      },
      { -- f
        trunk = {
          width = 520,
          height = 380,
          shift = util.by_pixel(86.5, -51),
          scale = 0.5
        },
        leaves = {
          width = 200,
          height = 246,
          shift = util.by_pixel(4, -87),
          scale = 0.5
        },
      },
      { -- g
        trunk = {
          width = 522,
          height = 352,
          shift = util.by_pixel(82.5, -36.25),
          scale = 0.5
        },
        leaves = {
          width = 199,
          height = 231,
          shift = util.by_pixel(-0.75, -69.75),
          scale = 0.5
        },
      },
      { -- h
        trunk = {
          width = 505,
          height = 340,
          shift = util.by_pixel(77.25, -35.5),
          scale = 0.5
        },
        leaves = {
          width = 206,
          height = 245,
          shift = util.by_pixel(0, -61.25),
          scale = 0.5
        },
      },
    },
  },
  { -- tree-05
    --addHere-tree05
    type_name = "specter",
    locale = "specter",
    alien_biomes_texture = true,
    normals_match_leaves = true,
    -- drawing_box = {{-0.9, -3.5}, {0.9, 0.6}},
    drawing_box_vertical_extension = 3.5,
    water_reflection_function = function (variation)
      return
      {
        pictures =
        {
          filename = "__Alien-biomes-Reforged__/graphics/entity/tree/specter/tree-specter-reflection.png",
          priority = "extra-high",
          width = 156/4,
          height = 351/9,
          shift = util.by_pixel(0, 60),
          y = 351/9 * variation,
          variation_count = 4,
          scale = 5,
        },
        rotate = false,
        orientation_to_variation = false
      }
    end,
    variations = {
      { -- a
        trunk = {
          width = 419,
          height = 284,
          shift = util.by_pixel(55.25, -33),
          scale = 0.5
        },
        leaves = {
          width = 233,
          height = 236,
          shift = util.by_pixel(-2.75, -56),
          scale = 0.5
        },
      },
      { -- b
        trunk = {
          width = 394,
          height = 259,
          shift = util.by_pixel(59.5, -29.25),
          scale = 0.5
        },
        leaves = {
          width = 210,
          height = 230,
          shift = util.by_pixel(-1.5, -49.5),
          scale = 0.5
        },
      },
      { -- c
        trunk = {
          width = 375,
          height = 276,
          shift = util.by_pixel(56.75, -33),
          scale = 0.5
        },
        leaves = {
          width = 232,
          height = 270,
          shift = util.by_pixel(7.5, -51),
          scale = 0.5
        },
      },
      { -- d
        trunk = {
          width = 412,
          height = 275,
          shift = util.by_pixel(57, -22.75),
          scale = 0.5
        },
        leaves = {
          width = 264,
          height = 260,
          shift = util.by_pixel(3, -35.5),
          scale = 0.5
        },
      },
      { -- e
        trunk = {
          width = 369,
          height = 258,
          shift = util.by_pixel(41.25, -19.5),
          scale = 0.5
        },
        leaves = {
          width = 240,
          height = 216,
          shift = util.by_pixel(-6, -39.5),
          scale = 0.5
        },
      },
      { -- f
        trunk = {
          width = 375,
          height = 291,
          shift = util.by_pixel(43.75, -36.25),
          scale = 0.5
        },
        leaves = {
          width = 250,
          height = 281,
          shift = util.by_pixel(0.5, -51.25),
          scale = 0.5
        },
      },
      { -- g
        trunk = {
          width = 362,
          height = 216,
          shift = util.by_pixel(54.5, -16.5),
          scale = 0.5
        },
        leaves = {
          width = 232,
          height = 201,
          shift = util.by_pixel(2, -33.25),
          scale = 0.5
        },
      },
      { -- h
        trunk = {
          width = 330,
          height = 240,
          shift = util.by_pixel(45.5, -17.5),
          scale = 0.5
        },
        leaves = {
          width = 221,
          height = 224,
          shift = util.by_pixel(7.75, -36),
          scale = 0.5
        },
      },
      { -- i
        trunk = {
          width = 352,
          height = 221,
          shift = util.by_pixel(39, -9.25),
          scale = 0.5
        },
        leaves = {
          width = 238,
          height = 220,
          shift = util.by_pixel(-1, -26.5),
          scale = 0.5
        },
      },
    },
  },
  { -- tree-06
    --addHere-tree06
    type_name = "willow",
    locale = "willu",
    alien_biomes_texture = true,
    normals_match_leaves = true,
    -- drawing_box = {{-0.9, -3.5}, {0.9, 0.6}},
    drawing_box_vertical_extension = 3.5,
    water_reflection_function = function (variation)
      return
      {
        pictures =
        {
          filename = "__Alien-biomes-Reforged__/graphics/entity/tree/willow/tree-willow-reflection.png",
          priority = "extra-high",
          width = 30,
          height = 35,
          shift = util.by_pixel(0, 35),
          x = 30 * variation,
          variation_count = 1,
          scale = 5,
        },
        rotate = false,
        orientation_to_variation = false
      }
    end,
    variations = {
      { -- a
        trunk = {
          width = 356,
          height = 289,
          shift = util.by_pixel(59.5, -33.75),
          scale = 0.5
        },
        leaves = {
          width = 133,
          height = 195,
          shift = util.by_pixel(19.25, -46.75),
          scale = 0.5
        },
      },
      { -- b
        trunk = {
          width = 375,
          height = 258,
          shift = util.by_pixel(61.25, -23),
          scale = 0.5
        },
        leaves = {
          width = 170,
          height = 186,
          shift = util.by_pixel(18, -37),
          scale = 0.5
        },
      },
      { -- c
        trunk = {
          width = 403,
          height = 214,
          shift = util.by_pixel(52.25, -12.5),
          scale = 0.5
        },
        leaves = {
          width = 178,
          height = 158,
          shift = util.by_pixel(11, -25.5),
          scale = 0.5
        },
      },
      { -- d
        trunk = {
          width = 343,
          height = 259,
          shift = util.by_pixel(34.25, -16.75),
          scale = 0.5
        },
        leaves = {
          width = 150,
          height = 178,
          shift = util.by_pixel(-6.5, -36),
          scale = 0.5
        },
      },
      { -- e
        trunk = {
          width = 280,
          height = 287,
          shift = util.by_pixel(18, -28.25),
          scale = 0.5
        },
        leaves = {
          width = 137,
          height = 224,
          shift = util.by_pixel(-10.25, -44.5),
          scale = 0.5
        },
      },
      { -- f
        trunk = {
          width = 371,
          height = 272,
          shift = util.by_pixel(30.75, -36),
          scale = 0.5
        },
        leaves = {
          width = 177,
          height = 228,
          shift = util.by_pixel(-10.25, -45.5),
          scale = 0.5
        },
      },
      { -- g
        trunk = {
          width = 402,
          height = 268,
          shift = util.by_pixel(43, -35),
          scale = 0.5
        },
        leaves = {
          width = 177,
          height = 228,
          shift = util.by_pixel(-0.75, -44),
          scale = 0.5
        },
      },
      { -- h
        trunk = {
          width = 347,
          height = 258,
          shift = util.by_pixel(49.25, -34.5),
          scale = 0.5
        },
        leaves = {
          width = 143,
          height = 190,
          shift = util.by_pixel(21.25, -43),
          scale = 0.5
        },
      },
      { -- i
        trunk = {
          width = 253,
          height = 259,
          shift = util.by_pixel(12.75, -14.75),
          scale = 0.5
        },
        leaves = {
          width = 129,
          height = 185,
          shift = util.by_pixel(-10.25, -33.75),
          scale = 0.5
        },
      },
      { -- j
        trunk = {
          width = 272,
          height = 253,
          shift = util.by_pixel(22, -16.75),
          scale = 0.5
        },
        leaves = {
          width = 133,
          height = 182,
          shift = util.by_pixel(-6.25, -35),
          scale = 0.5
        },
      },
    },
  },
  { -- tree-07
    --addHere-tree07
    type_name = "mangrove",
    locale = "margrove",
    alien_biomes_texture = true,
    normals_match_leaves = true,
    -- drawing_box = {{-0.9, -3.5}, {0.9, 0.6}},
    drawing_box_vertical_extension = 3.5,
    water_reflection_function = function (variation)
      return
      {
        pictures =
        {
          filename = "__Alien-biomes-Reforged__/graphics/entity/tree/mangrove/tree-mangrove-reflection.png",
          priority = "extra-high",
          width = 140/4,
          height = 312/8,
          shift = util.by_pixel(0, 60),
          y = 312/8 * variation,
          variation_count = 4,
          scale = 5,
        },
        rotate = false,
        orientation_to_variation = false
      }
    end,
    variations = {
      { -- a
        trunk = {
          width = 362,
          height = 244,
          shift = util.by_pixel(39 + 24, -20.5),
          scale = 0.5
        },
        leaves = {
          width = 402/3,
          height = 166,
          shift = util.by_pixel(-26 + 24, -42),
          scale = 0.5
        },
      },
      { -- b
        trunk = {
          width = 335,
          height = 239,
          shift = util.by_pixel(14.75 + 24, -35.75),
          scale = 0.5
        },
        leaves = {
          width = 438/3,
          height = 192,
          shift = util.by_pixel(-41 + 24, -50),
          scale = 0.5
        },
      },
      { -- c
        trunk = {
          width = 334,
          height = 256,
          shift = util.by_pixel(9 + 24, -46.5),
          scale = 0.5
        },
        leaves = {
          width = 480/3,
          height = 220,
          shift = util.by_pixel(-42 + 24, -56),
          scale = 0.5
        },
      },
      { -- d
        trunk = {
          width = 368,
          height = 314,
          shift = util.by_pixel(25.5 + 24, -47.5),
          scale = 0.5
        },
        leaves = {
          width = 540/3,
          height = 254,
          shift = util.by_pixel(-28 + 24, -65),
          scale = 0.5
        },
      },
      { -- e
        trunk = {
          width = 405,
          height = 286,
          shift = util.by_pixel(48.25 + 24, -54.5),
          scale = 0.5
        },
        leaves = {
          width = 450/3,
          height = 268,
          shift = util.by_pixel(-17 + 24, -61),
          scale = 0.5
        },
      },
      { -- f
        trunk = {
          width = 435,
          height = 270,
          shift = util.by_pixel(56.75 + 24, -49),
          scale = 0.5
        },
        leaves = {
          width = 504/3,
          height = 240,
          shift = util.by_pixel(-3 + 24, -57),
          scale = 0.5
        },
      },
      { -- g
        trunk = {
          width = 426,
          height = 240,
          shift = util.by_pixel(55.5 + 24, -36),
          scale = 0.5
        },
        leaves = {
          width = 480/3,
          height = 200,
          shift = util.by_pixel(-9 + 24, -46),
          scale = 0.5
        },
      },
      { -- h
        trunk = {
          width = 397,
          height = 243,
          shift = util.by_pixel(50.25 + 24, -21.25),
          scale = 0.5
        },
        leaves = {
          width = 444/3,
          height = 174,
          shift = util.by_pixel(-20 + 24, -40),
          scale = 0.5
        },
      },
    },
  },
  { -- tree-08
    --addHere-tree08
    type_name = "pear",
    locale = "pearch",
    alien_biomes_texture = true,
    normals_match_leaves = true,
    -- drawing_box = {{-0.9, -3}, {0.9, 0.6}},
    drawing_box_vertical_extension = 3,
    water_reflection_function = function (variation)
      return
      {
        pictures =
        {
          filename = "__Alien-biomes-Reforged__/graphics/entity/tree/pear/tree-pear-reflection.png",
          priority = "extra-high",
          width = 116/4,
          height = 180/5,
          shift = util.by_pixel(0, 60),
          y = 180/5 * variation,
          variation_count = 4,
          scale = 5,
        },
        rotate = false,
        orientation_to_variation = false
      }
    end,
    variations = {
      { -- a
        trunk = {
          width = 399,
          height = 279,
          shift = util.by_pixel(55.75, -33.75),
          scale = 0.5
        },
        leaves = {
          width = 188,
          height = 141,
          shift = util.by_pixel(0.5, -70.75),
          scale = 0.5
        },
      },
      { -- b
        trunk = {
          width = 426,
          height = 277,
          shift = util.by_pixel(57.5, -30.25),
          scale = 0.5
        },
        leaves = {
          width = 205,
          height = 142,
          shift = util.by_pixel(2.25, -68.5),
          scale = 0.5
        },
      },
      { -- c
        trunk = {
          width = 377,
          height = 271,
          shift = util.by_pixel(65.75, -35.75),
          scale = 0.5
        },
        leaves = {
          width = 152,
          height = 152,
          shift = util.by_pixel(6.5, -68),
          scale = 0.5
        },
      },
      { -- d
        trunk = {
          width = 424,
          height = 267,
          shift = util.by_pixel(62.5, -38.75),
          scale = 0.5
        },
        leaves = {
          width = 187,
          height = 162,
          shift = util.by_pixel(0.25, -68.5),
          scale = 0.5
        },
      },
      { -- e
        trunk = {
          width = 416,
          height = 295,
          shift = util.by_pixel(55, -33.25),
          scale = 0.5
        },
        leaves = {
          width = 189,
          height = 166,
          shift = util.by_pixel(-5.75, -70),
          scale = 0.5
        },
      },
    },
  },
  { -- tree-09
    --addHere-tree09
    type_name = "baobab",
    locale = "maobab",
    alien_biomes_texture = true,
    normals_match_leaves = true,
    -- drawing_box = {{-0.9, -3.5}, {0.9, 0.6}},
    drawing_box_vertical_extension = 3.5,
    water_reflection_function = function (variation)
      return
      {
        pictures =
        {
          filename = "__Alien-biomes-Reforged__/graphics/entity/tree/baobab/tree-baobab-reflection.png",
          priority = "extra-high",
          width = 148/4,
          height = 200/5,
          shift = util.by_pixel(0, 60),
          y = 200/5 * variation,
          variation_count = 4,
          scale = 5,
        },
        rotate = false,
        orientation_to_variation = false
      }
    end,
    variations = {
      { -- a
        trunk = {
          width = 487,
          height = 340,
          shift = util.by_pixel(66.25, -36.5),
          scale = 0.5
        },
        leaves = {
          width = 244,
          height = 204,
          shift = util.by_pixel(5, -72.5),
          scale = 0.5
        },
      },
      { -- b
        trunk = {
          width = 415,
          height = 300,
          shift = util.by_pixel(53.25, -35.5),
          scale = 0.5
        },
        leaves = {
          width = 197,
          height = 172,
          shift = util.by_pixel(-2.25, -68.5),
          scale = 0.5
        },
      },
      { -- c
        trunk = {
          width = 476,
          height = 333,
          shift = util.by_pixel(56.5, -37.25),
          scale = 0.5
        },
        leaves = {
          width = 225,
          height = 189,
          shift = util.by_pixel(-8.25, -73.75),
          scale = 0.5
        },
      },
      { -- d
        trunk = {
          width = 338,
          height = 233,
          shift = util.by_pixel(46, -31.75),
          scale = 0.5
        },
        leaves = {
          width = 179,
          height = 126,
          shift = util.by_pixel(4.75, -59.5),
          scale = 0.5
        },
      },
      { -- e
        trunk = {
          width = 403,
          height = 315,
          shift = util.by_pixel(63.25, -38.25),
          scale = 0.5
        },
        leaves = {
          width = 205,
          height = 206,
          shift = util.by_pixel(12.25, -67),
          scale = 0.5
        },
      },
    },
  },
  { -- tree-conifer-01
    -- x positive moves image right
    -- y positive moves image down
    type_name = "conifer-01",
    locale = "konifa",
    alien_biomes_texture = true,
    normals_match_leaves = true,
    -- drawing_box = {{-1, -9}, {1, 0.8}},
    drawing_box_vertical_extension = 9,
    water_reflection_function = function (variation)
      return
      {
        pictures =
        {
          filename = "__Alien-biomes-Reforged__/graphics/entity/tree/conifer-01/tree-conifer-01-reflection.png",
          priority = "extra-high",
          width = 180/4,
          height = 189/3,
          shift = util.by_pixel(0, 100),
          y = 189/3 * variation,
          variation_count = 4,
          scale = 5,
        },
        rotate = false,
        orientation_to_variation = false
      }
    end,
    variations = {
      { -- a
        trunk = {
          width = 1498/5*2,
          height = 226*2,
          shift = util.by_pixel(81, -62),
          scale = 0.5
        },
        leaves = {
          width = 339/3*2,
          height = 164*2,
          shift = util.by_pixel(11, -84),
          scale = 0.5
        },
      },
      { -- b
        trunk = {
          width = 540/4*2,
          height = 152*2,
          shift = util.by_pixel(18, -48),
          scale = 0.5
        },
        leaves = {
          width = 279/3*2,
          height = 134*2,
          shift = util.by_pixel(0, -66),
          scale = 0.5
        },
      },
      { -- c
        trunk = {
          width = 1400/4*2,
          height = 321*2,
          shift = util.by_pixel(90, -88),
          scale = 0.5
        },
        leaves = {
          width = 534/3*2,
          height = 258*2,
          shift = util.by_pixel(4, -123),
          scale = 0.5
        },
      },
    },
  },
  { -- tree-palm
    -- x positive moves image right
    -- y positive moves image down
    type_name = "palm",
    locale = "parm",
    alien_biomes_texture = true,
    normals_match_leaves = true,
    -- drawing_box = {{-0.9, -5.9}, {0.9, 0.8}},
    drawing_box_vertical_extension = 5.9,
    water_reflection_function = function (variation)
      return
      {
        pictures =
        {
          filename = "__Alien-biomes-Reforged__/graphics/entity/tree/palm/tree-palm-reflection.png",
          priority = "extra-high",
          width = 116/4,
          height = 144/4,
          shift = util.by_pixel(0, 60),
          y = 144/4 * variation,
          variation_count = 4,
          scale = 5,
        },
        rotate = false,
        orientation_to_variation = false
      }
    end,
    variations = {
      { -- a
        trunk =
        {
          width = 60,
          height = 168,
          shift = util.by_pixel(0, -31),
          scale = 0.5
        },
        shadow =
        {
          width = 976/4,
          height = 114,
          shift = util.by_pixel(58, 10),
          scale = 0.5
        },
        leaves =
        {
          width = 432/3,
          height = 114,
          shift = util.by_pixel(-2, -65),
          scale = 0.5
        }
      },
      { -- b
        trunk =
        {
          width = 64,
          height = 218,
          shift = util.by_pixel(2, -40),
          scale = 0.5
        },
        shadow =
        {
          width = 1000/4,
          height = 118,
          shift = util.by_pixel(58, 0),
          scale = 0.5
        },
        leaves =
        {
          width = 546/3,
          height = 118,
          shift = util.by_pixel(-8, -92),
          scale = 0.5
        }
      },
      { -- c
        trunk =
        {
          width = 66,
          height = 210,
          shift = util.by_pixel(0, -38),
          scale = 0.5
        },
        shadow =
        {
          width = 1008/4,
          height = 124,
          shift = util.by_pixel(58, 0),
          scale = 0.5
        },
        leaves =
        {
          width = 486/3,
          height = 124,
          shift = util.by_pixel(10, -92),
          scale = 0.5
        }
      },
      { -- d
        trunk =
        {
          width = 78,
          height = 198,
          shift = util.by_pixel(0, -33),
          scale = 0.5
        },
        shadow =
        {
          width = 896/4,
          height = 126,
          shift = util.by_pixel(58, -1),
          scale = 0.5
        },
        leaves =
        {
          width = 486/3,
          height = 126,
          shift = util.by_pixel(-1, -85),
          scale = 0.5
        }
      },
    },
  },
  { -- tree-medusa-01
    type_name = "medusa-01",
    locale = "medusa",
    alien_biomes_texture = true,
    -- drawing_box = {{-0.9, -3.9}, {0.9, 0.6}},
    drawing_box_vertical_extension = 3.9,
    water_reflection_function = function (variation)
      return
      {
        pictures =
        {
          filename = "__Alien-biomes-Reforged__/graphics/entity/tree/medusa-01/tree-medusa-01-reflection.png",
          priority = "extra-high",
          width = 30,
          height = 31,
          shift = util.by_pixel(0, 35),
          x = 30 * variation,
          variation_count = 1,
          scale = 5,
        },
        rotate = false,
        orientation_to_variation = false
      }
    end,
    variations = {
      { -- a
        trunk = {
          frame_count = 2,
          width = 254,
          height = 100*2,
          shift = util.by_pixel(30, -22),
          scale = 0.5
        },
        leaves = {
          frame_count = 1,
          width = 67*2,
          height = 57*2,
          shift = util.by_pixel(0, -44),
          scale = 0.5
        },
      },
      { -- b
        trunk = {
          frame_count = 2,
          width = 302,
          height = 110*2,
          shift = util.by_pixel(16, -31),
          scale = 0.5
        },
        leaves = {
          frame_count = 1,
          width = 87*2,
          height = 59*2,
          shift = util.by_pixel(-16, -58),
          scale = 0.5
        },
      },
      { -- c
        trunk = {
          frame_count = 2,
          width = 232,
          height = 110*2,
          shift = util.by_pixel(24, -10),
          scale = 0.5
        },
        leaves = {
          frame_count = 1,
          width = 72*2,
          height = 74*2,
          shift = util.by_pixel(2, -28),
          scale = 0.5
        },
      },
      { -- d
        trunk = {
          frame_count = 2,
          width = 236,
          height = 110*2,
          shift = util.by_pixel(30, -40),
          scale = 0.5
        },
        leaves = {
          frame_count = 1,
          width = 59*2,
          height = 65*2,
          shift = util.by_pixel(0, -62),
          scale = 0.5
        },
      },
      { -- e
        trunk = {
          frame_count = 2,
          width = 200,
          height = 110*2,
          shift = util.by_pixel(28, -36),
          scale = 0.5
        },
        leaves = {
          frame_count = 1,
          width = 65*2,
          height = 81*2,
          shift = util.by_pixel(10, -51),
          scale = 0.5
        },
      },
    },
  },
}

local tree_models = {}
-- expand variations
for tree_index, tree_type in pairs(tree_types) do
  local type_name = tree_type.type_name
  local tree_variations = {}  -- expanded versions
  local i = 1
  -- lock letter
  for variation_index, variation in ipairs(tree_type.variations) do
    variation.variation_letter = index_to_letter(variation_index)
    variation.real_variation_index = variation_index
  end
  -- make sure there are at least 7 variations by duplicating earlier ones
  -- that way if more textures are added later there will be at least 7 in already generated areas
  while #tree_type.variations < 7 do
    i = i + 1
    table.insert(tree_type.variations, table.deepcopy(tree_type.variations[i]))
  end
  for variation_index, variation in ipairs(tree_type.variations) do
    local variation_letter = variation.variation_letter
    local path_start = tree_type.alien_biomes_texture and "__Alien-biomes-Reforged__" or "__base__"
    local variation_path = type_name .. "/tree-" .. type_name .. "-" .. variation_letter
    local newTree = {
      trunk =
      {
        filename = path_start.."/graphics/entity/tree/" .. variation_path .. "-trunk.png",
        flags = { "mipmap" },
        width = variation.trunk.width,
        height =  variation.trunk.height,
        frame_count = variation.trunk.frame_count or 4,
        shift = variation.trunk.shift,
        scale = variation.trunk.scale or 1,
      },
      leaves =
      {
        filename = path_start.."/graphics/entity/tree/" .. variation_path .. "-leaves.png",
        flags = { "mipmap" },
        width = variation.leaves.width,
        height = variation.leaves.height,
        frame_count = variation.leaves.frame_count or 3,
        shift = variation.leaves.shift,
        scale = variation.leaves.scale or 1,
      },
      leaf_generation =
      {
        type = "create-particle",
        particle_name = "leaf-particle",
        offset_deviation = {{-0.5, -0.5}, {0.5, 0.5}},
        initial_height = 2,
        initial_height_deviation = 1,
        speed_from_center = 0.01
      },
      branch_generation =
      {
        type = "create-particle",
        particle_name = "branch-particle",
        offset_deviation = {{-0.5, -0.5}, {0.5, 0.5}},
        initial_height = 2,
        initial_height_deviation = 2,
        speed_from_center = 0.01,
        frame_speed = 0.1,
        repeat_count = 15
      }
    }
    if variation.normal then
      newTree.normal =
      {
        filename = "__base__/graphics/entity/tree/" .. variation_path .. "-normal.png",
        width = variation.normal.width,
        height = variation.normal.height,
        frame_count = 3,
        shift = variation.normal.shift,
        scale = variation.normal.scale or 1,
      }
    elseif tree_type.normals_match_leaves then
      newTree.normal = table.deepcopy(newTree.leaves)
      newTree.normal.filename = path_start.."/graphics/entity/tree/" .. variation_path .. "-normal.png"
      newTree.normal.flags = nil
    end
    if tree_type.water_reflection_function then
      newTree.water_reflection = tree_type.water_reflection_function(variation.real_variation_index - 1)
    end
    if variation.shadow then
      -- note: old trees had shadow baked into the trunk texture

      newTree.trunk.frame_count = variation.trunk.frame_count or 1

      newTree.trunk.frame_count = variation.trunk.frame_count or 1
      newTree.shadow = {
        draw_as_shadow = true,
        filename = path_start.."/graphics/entity/tree/" .. variation_path .. "-shadow.png",
        flags = { "mipmap", "shadow" },
        frame_count = variation.shadow.frame_count or 4,
        width = variation.shadow.width,
        height = variation.shadow.height,
        shift = variation.shadow.shift,
        scale = variation.shadow.scale or 1,
        disable_shadow_distortion_beginning_at_frame = 2,
      }
    else
      newTree.shadow = table.deepcopy(newTree.trunk)
      newTree.shadow.draw_as_shadow = true
      newTree.shadow.flags = { "mipmap", "shadow" }
      newTree.shadow.disable_shadow_distortion_beginning_at_frame = 2
      data_util.replace_filenames_recursive(newTree.shadow, "trunk", "shadow")
    end

    tree_variations[#tree_variations + 1] = newTree
  end
  tree_type.tree_variations = tree_variations
  tree_models[type_name] = tree_type
end

return tree_models
