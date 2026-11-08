local hit_effects = require ("__base__.prototypes.entity.hit-effects")
local sounds = require ("__base__.prototypes.entity.sounds")
local decorative_trigger_effects = require("__base__.prototypes.decorative.decorative-trigger-effects")
local simulations = require("__space-age__.prototypes.factoriopedia-simulations")

local base_decorative_sprite_priority = "extra-high"
local decal_tile_layer = 255

local function combine_tint(table_1, table_2)
  local t1 = table_1[1]-(1-table_2[1])
  local t2 = table_1[2]-(1-table_2[2])
  local t3 = table_1[3]-(1-table_2[3])
  return {t1,t2,t3}
end
local vulcanus_base_tint = {1,1,1}

local green_hairy_tint = {.85,.6,.7}
local brown_hairy_tint = {.7,.7,.7}
local brown_carpet_tint = {1,.9,1}
local red_pita_tint = {.8,.75,.75}
local tintable_rock_tint = {0.2588, 0.2588, 0.2588}
local sulfur_rock_tint = {0.788, 0.627, 0.167} --{0.968, 0.807, 0.247}
local tungsten_rock_tint = {.7,.7,.7}

green_hairy_tint = combine_tint(vulcanus_base_tint, green_hairy_tint)
brown_hairy_tint = combine_tint(vulcanus_base_tint, brown_hairy_tint)
brown_carpet_tint = combine_tint(vulcanus_base_tint, brown_carpet_tint)
red_pita_tint =  combine_tint(vulcanus_base_tint, red_pita_tint)
tintable_rock_tint = combine_tint(vulcanus_base_tint, tintable_rock_tint)
tungsten_rock_tint = combine_tint(vulcanus_base_tint, tungsten_rock_tint)

data:extend({
  {
    name = "moshine-rock-decal-large",
    type = "optimized-decorative",
    order = "a[vulcanus]-b[decorative]-b[sand]",
    collision_box = {{-1.5, -1.5}, {1.5, 1.5}},
    collision_mask = {layers={water_tile=true, doodad=true}, colliding_with_tiles_only=true},
    render_layer = "decals",
    tile_layer =  decal_tile_layer -1,
    walking_sound = sounds.pebble,
    autoplace = {
      order = "d[ground-surface]-f[cracked-rock]-b[cold]",
      probability_expression = "vulcanus_rock_decal_large"
    },
    pictures = get_decal_pictures("__Moshine-assets__/graphics/decorative/vulcanus-rock-decal/vulcanus-rock-decal-", "large-", 256, 5)
  },
  




  --- TINTABLE ROCKS
  --- BIG ROCKS
  {
    name = "moshine-huge-volcanic-rock",
    type = "simple-entity",
    flags = {"placeable-neutral", "placeable-off-grid"},
    icon = "__Moshine__/graphics/icons/huge-volcanic-rock.png",
    subgroup = "grass",
    order = "r[decorative]-l[rock]-f[huge-volcanic-rock]",
    collision_box = {{-1.5, -1.1}, {1.5, 1.1}},
    selection_box = {{-1.7, -1.3}, {1.7, 1.3}},
    damaged_trigger_effect = hit_effects.rock(),
    dying_trigger_effect = decorative_trigger_effects.huge_rock(),
    minable =
    {
      mining_particle = "stone-particle",
      mining_time = 3,
      results =
      {
        {type = "item", name = "stone", amount_min = 3, amount_max = 10},
        {type = "item", name = "iron-ore", amount_min = 5, amount_max = 20},
        {type = "item", name = "calcite", amount_min = 3, amount_max = 15},
      },
    },
    map_color = {129, 105, 78},
    count_as_rock_for_filtered_deconstruction = true,
    mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
    impact_category = "stone",
    render_layer = "object",
    max_health = 2000,
    resistances =
    {
      {
        type = "fire",
        percent = 100
      }
    },
    autoplace = {
      --control = "rocks",
      order = "r[landscape]-c[rock]-a[huge]",
      probability_expression = "vulcanus_rock_huge"
    },
    pictures =
    {
      {
        filename = "__Moshine-assets__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-05.png",
        width = 201,
        height = 179,
        scale = 0.5,
        shift = {0.25, 0.0625},
        tint = tungsten_rock_tint
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-06.png",
        width = 233,
        height = 171,
        scale = 0.5,
        shift = {0.429688, 0.046875},
        tint = tungsten_rock_tint
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-07.png",
        width = 240,
        height = 192,
        scale = 0.5,
        shift = {0.398438, 0.03125},
        tint = tungsten_rock_tint
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-08.png",
        width = 219,
        height = 175,
        scale = 0.5,
        shift = {0.148438, 0.132812},
        tint = tungsten_rock_tint
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-09.png",
        width = 240,
        height = 208,
        scale = 0.5,
        shift = {0.3125, 0.0625},
        tint = tungsten_rock_tint
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-10.png",
        width = 243,
        height = 190,
        scale = 0.5,
        shift = {0.1875, 0.046875},
        tint = tungsten_rock_tint
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-11.png",
        width = 249,
        height = 185,
        scale = 0.5,
        shift = {0.398438, 0.0546875},
        tint = tungsten_rock_tint
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-12.png",
        width = 273,
        height = 163,
        scale = 0.5,
        shift = {0.34375, 0.0390625},
        tint = tungsten_rock_tint
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-13.png",
        width = 275,
        height = 175,
        scale = 0.5,
        shift = {0.273438, 0.0234375},
        tint = tungsten_rock_tint
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-14.png",
        width = 241,
        height = 215,
        scale = 0.5,
        shift = {0.195312, 0.0390625},
        tint = tungsten_rock_tint
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-15.png",
        width = 318,
        height = 181,
        scale = 0.5,
        shift = {0.523438, 0.03125},
        tint = tungsten_rock_tint
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-16.png",
        width = 217,
        height = 224,
        scale = 0.5,
        shift = {0.0546875, 0.0234375},
        tint = tungsten_rock_tint
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-17.png",
        width = 332,
        height = 228,
        scale = 0.5,
        shift = {0.226562, 0.046875},
        tint = tungsten_rock_tint
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-18.png",
        width = 290,
        height = 243,
        scale = 0.5,
        shift = {0.195312, 0.0390625},
        tint = tungsten_rock_tint
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-19.png",
        width = 349,
        height = 225,
        scale = 0.5,
        shift = {0.609375, 0.0234375},
        tint = tungsten_rock_tint
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-20.png",
        width = 287,
        height = 250,
        scale = 0.5,
        shift = {0.132812, 0.03125},
        tint = tungsten_rock_tint
      }
    }
  },
  --- SMALL CRATERS
  {
    name = "moshine-crater-small",
    type = "optimized-decorative",
    order = "a[vulcanus]-b[decorative]",
    collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
    collision_mask = {layers={water_tile=true}, colliding_with_tiles_only=true},
    render_layer = "decals",
    tile_layer = decal_tile_layer,
    walking_sound = sounds.pebble,
    autoplace = {
      order = "d[ground-surface]-e[crater]-a[small]",
      probability_expression = "crater_small"
    },
    pictures = get_decal_pictures("__Moshine-assets__/graphics/decorative/vulcanus-crater/vulcanus-crater-", "", 128, 20)
  },
  --- LARGE CRATERS
  {
    name = "moshine-crater-large",
    type = "optimized-decorative",
    order = "a[vulcanus]-b[decorative]",
    collision_box = {{-2.5, -2.5}, {2.5, 2.5}},
    collision_mask = {layers={water_tile=true}, colliding_with_tiles_only=true},
    render_layer = "decals",
    tile_layer = decal_tile_layer,
    walking_sound = sounds.pebble,
    autoplace = {
      order = "d[ground-surface]-e[crater]-a[large]",
      probability_expression = "crater_large"
    },
    pictures = get_decal_pictures("__Moshine-assets__/graphics/decorative/vulcanus-crater/vulcanus-crater-", "huge-", 512, 14)
  },






  {
    name = "moshine-snow-drift-decal",
    type = "optimized-decorative",
    order = "b[decorative]-b[red-desert-decal]",
    collision_box = {{-3.375, -2.3125}, {3.25, 2.3125}},
    collision_mask = {layers={water_tile=true}, colliding_with_tiles_only=true},
    render_layer = "decals",
    tile_layer = 255,
    autoplace =
    {
      order = "d[decal]-c",
      probability_expression = "min(1, random_penalty{x = x, y = y, seed = 1, source = 1, amplitude = 1/0.1} + 0.3 -aquilo_high_frequency_peaks / 2)"
    },
    pictures =
    {
      --lightDecal
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-00.png",
        width = 400,
        height = 299,
        shift = util.by_pixel(4.5, -2.25),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-01.png",
        width = 419,
        height = 320,
        shift = util.by_pixel(-0.75, 2),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-02.png",
        width = 417,
        height = 287,
        shift = util.by_pixel(-1.25, 1.25),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-03.png",
        width = 421,
        height = 298,
        shift = util.by_pixel(-0.25, 5.5),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-04.png",
        width = 396,
        height = 302,
        shift = util.by_pixel(6, 4),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-05.png",
        width = 408,
        height = 295,
        shift = util.by_pixel(-2.5, 7.75),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-06.png",
        width = 417,
        height = 317,
        shift = util.by_pixel(-1.25, 3.25),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-07.png",
        width = 419,
        height = 312,
        shift = util.by_pixel(0.75, 2.5),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-08.png",
        width = 413,
        height = 317,
        shift = util.by_pixel(-2.25, 2.25),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-09.png",
        width = 403,
        height = 310,
        shift = util.by_pixel(0.25, 1.5),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-10.png",
        width = 411,
        height = 307,
        shift = util.by_pixel(-0.75, 1.75),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-11.png",
        width = 421,
        height = 295,
        shift = util.by_pixel(-0.25, -0.75),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-12.png",
        width = 420,
        height = 280,
        shift = util.by_pixel(-0.5, -7),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-13.png",
        width = 403,
        height = 311,
        shift = util.by_pixel(0.75, 3.25),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-14.png",
        width = 418,
        height = 304,
        shift = util.by_pixel(0, 2),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-15.png",
        width = 398,
        height = 284,
        shift = util.by_pixel(-3.5, 6.5),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-16.png",
        width = 406,
        height = 313,
        shift = util.by_pixel(4, 0.25),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-17.png",
        width = 420,
        height = 294,
        shift = util.by_pixel(0.5, 4.5),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-18.png",
        width = 379,
        height = 289,
        shift = util.by_pixel(0.25, 5.75),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-19.png",
        width = 401,
        height = 311,
        shift = util.by_pixel(-5.25, 1.25),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-20.png",
        width = 418,
        height = 315,
        shift = util.by_pixel(0.5, 1.25),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-21.png",
        width = 418,
        height = 154,
        shift = util.by_pixel(1, 3),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-22.png",
        width = 421,
        height = 270,
        shift = util.by_pixel(-0.25, 1),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-23.png",
        width = 403,
        height = 290,
        shift = util.by_pixel(2.25, -2.5),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-24.png",
        width = 418,
        height = 315,
        shift = util.by_pixel(-0.5, 2.25),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-25.png",
        width = 414,
        height = 310,
        shift = util.by_pixel(-2, 4),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-26.png",
        width = 403,
        height = 306,
        shift = util.by_pixel(-3.75, 5),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-27.png",
        width = 416,
        height = 303,
        shift = util.by_pixel(1, 0.25),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-28.png",
        width = 422,
        height = 311,
        shift = util.by_pixel(0, 2.25),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/snow-drift-decal/snow-drift-decal-29.png",
        width = 406,
        height = 292,
        shift = util.by_pixel(-3.5, 2),
        scale = 0.5
      }
    }
  },

  scaled_cliff(
    {
      mod_name = "__Moshine-assets__",
      name = "cliff-moshine",
      map_color = {59, 45, 37},
      suffix = "moshine",
      subfolder = "moshine",
      scale = 1.0,
      has_lower_layer = true,
      sprite_size_multiplier = 2,
      factoriopedia_simulation = {
        planet = "moshine",
        hide_factoriopedia_gradient = true,
        init =
        [[
          game.simulation.camera_position = {0, 2.5}
          for x = -8, 8, 1 do
            for y = -3, 4 do
              game.surfaces[1].set_tiles{{position = {x, y}, name = "volcanic-soil-dark"}}
            end
          end
          for x = -8, 8, 4 do
            game.surfaces[1].create_entity{name = "cliff-moshine", position = {x, 0}, cliff_orientation = "west-to-east"}
          end
        ]]
      }
    }
  ),


  {
    name = "moshine-barnacles-decal",
    type = "optimized-decorative",
    order = "b[decorative]-b[red-desert-decal]",
    collision_box = {{-3.375, -2.3125}, {3.25, 2.3125}},
    -- don't collide with water so can overlap shallows, but tile restricturion means it cannot be placed directly on shallows
    collision_mask = {layers={doodad=true}, colliding_with_tiles_only=true, not_colliding_with_itself=true},
    render_layer = "decals",
    tile_layer = decal_tile_layer - 1,
    autoplace = {
      tile_restriction = gleba_land_tiles,
      probability_expression = "grpi(0.2) + gleba_select(gleba_barnacles - clamp(gleba_decorative_knockout, 0, 1), 0.2, 2, 0.1, 0, 1)"
    },
    pictures =
    {
      --lightDecal
      {
        filename = "__Moshine-assets__/graphics/decorative/barnacles-decal/barnacles-decal-00.png",
        width = 400,
        height = 299,
        shift = util.by_pixel(4.5, -2.25),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/barnacles-decal/barnacles-decal-01.png",
        width = 419,
        height = 320,
        shift = util.by_pixel(-0.75, 2),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/barnacles-decal/barnacles-decal-02.png",
        width = 417,
        height = 287,
        shift = util.by_pixel(-1.25, 1.25),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/barnacles-decal/barnacles-decal-03.png",
        width = 421,
        height = 298,
        shift = util.by_pixel(-0.25, 5.5),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/barnacles-decal/barnacles-decal-04.png",
        width = 396,
        height = 302,
        shift = util.by_pixel(6, 4),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/barnacles-decal/barnacles-decal-05.png",
        width = 408,
        height = 295,
        shift = util.by_pixel(-2.5, 7.75),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/barnacles-decal/barnacles-decal-06.png",
        width = 417,
        height = 317,
        shift = util.by_pixel(-1.25, 3.25),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/barnacles-decal/barnacles-decal-07.png",
        width = 419,
        height = 312,
        shift = util.by_pixel(0.75, 2.5),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/barnacles-decal/barnacles-decal-08.png",
        width = 413,
        height = 317,
        shift = util.by_pixel(-2.25, 2.25),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/barnacles-decal/barnacles-decal-09.png",
        width = 403,
        height = 310,
        shift = util.by_pixel(0.25, 1.5),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/barnacles-decal/barnacles-decal-10.png",
        width = 411,
        height = 307,
        shift = util.by_pixel(-0.75, 1.75),
        scale = 0.5
      },
      {
        filename = "__Moshine-assets__/graphics/decorative/barnacles-decal/barnacles-decal-11.png",
        width = 421,
        height = 295,
        shift = util.by_pixel(-0.25, -0.75),
        scale = 0.5
      },
    }
  },





})



local rocks = {
  ["moshine-big-fulgora-rock"] = data.raw["simple-entity"]["big-sand-rock"],
  ["moshine-medium-fulgora-rock"] = data.raw["optimized-decorative"]["medium-sand-rock"],
  ["moshine-small-fulgora-rock"] = data.raw["optimized-decorative"]["small-sand-rock"],
  ["moshine-tiny-fulgora-rock"] = data.raw["optimized-decorative"]["tiny-rock"]
}
local i = 0
for name, original in pairs(rocks) do
  i = i + 1
  local rock = table.deepcopy(original)
  rock.name = name
  if name == "moshine-big-fulgora-rock" then
    rock.order = "r[decorative]-l[rock]-j[ruin]-a[" .. name .. "]"
    rock.icon = "__Moshine__/graphics/icons/" .. name .. ".png"
  end
  for j, picture in pairs(rock.pictures) do
    picture.filename = "__Moshine-assets__/graphics/decorative/fulgora-rock/" .. name .. "-".. string.format("%02d", j) ..".png"
  end
  rock.autoplace = {
    order = "r[rock]-" .. i,
    probability_expression = "(1 - fulgora_oil_mask) * (fulgora_natural_mask + fulgora_mesa)\z
                              * min(" ..(0.1 * i - 0.05)..",\z
                                    0.3 * " .. i .. " - 2.4 + fulgora_rock - 0.5 * fulgora_mix_oil + 0.7 * fulgora_basis_oil)"
  }
  data:extend({rock})
end
