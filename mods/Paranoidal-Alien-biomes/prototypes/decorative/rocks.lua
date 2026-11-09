local util = require('data-util')

local any = alien_biomes.require_tag
local all = alien_biomes.require_tags
local list = alien_biomes.list_tiles
local tiles = alien_biomes.all_tiles

local tints = {
  tan = {193,162,127},
  white = {255,255,255},
  grey = {177,183,187},
  black = {135,135,135},
  purple = {169,177,239},
  red = {185,107,105},
  violet = {165,107,161},
  dustyrose = {180,148,137},
  cream = {234,216,179},
  brown = {162,117,88},
  beige = {178,164,138},
  aubergine = {126,115,156}
}
for _, tint in pairs(tints) do
  local tint2 = {}
  tint2.a = 1
  tint2.r = tint[1]/255
  tint2.g = tint[2]/255
  tint2.b = tint[3]/255
  tints[_] = tint2
end
for _, tint in pairs(tints) do
  if _ ~= "tan" then
    local fade = 0.5
    if _ == "white" or _ == "black" then
      fade = 0.2
    end
    -- step 20% towards normal rock color for other rocks (becuase cliff colours are locked)
    tint.r = tint.r * (1 - fade) + tints["tan"].r * fade
    tint.g = tint.g * (1 - fade) + tints["tan"].g * fade
    tint.b = tint.b * (1 - fade) + tints["tan"].b * fade
  end
end

-- NOISE LAYERS
-- data:extend({
--   {
--     type = "noise-layer",
--     name = "mud-decal"
--   },
--   {
--     type = "noise-layer",
--     name = "stone-decal"
--   }
-- })

-- SHARED GRASS
data.raw['optimized-decorative']['cracked-mud-decal'].autoplace =
{
  order = "a[doodad]-b[decal]",
  tile_restriction = list(any(tiles(), {'grass'})),
  probability_expression = "max_probability * sharpness_filter",
  local_expressions = {
    max_probability = 0.01,
    sharpness_filter = "ab_sharpness_function(peaks_expr, 0.3)",
    peaks_expr = "influence_modifier + peak1_expr",
    peak1_expr = "peak1_noise_expression",
    peak1_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.9, seed0=map_seed, seed1='mud-decal', octaves=octaves-2, input_scale=1, output_scale=1}",
    octaves = "8 - log2(var('control:moisture:frequency'))",
    influence_modifier = "0.5 - quantile - 0.3",
    quantile = -0,
  },
  -- max_probability = 0.01,
  -- peaks = {
  --   {
  --     influence = 1,
  --     noise_layer = "mud-decal",
  --     noise_octaves_difference = -2,
  --     noise_persistence = 0.9
  --   }
  -- },
  -- sharpness = 0.3,
}

data.raw["optimized-decorative"]["dark-mud-decal"].autoplace = {
  order = "a[doodad]-b[decal]",
  tile_restriction = list(any(tiles(), {'grass', 'dirt'})),
  probability_expression = "max_probability * sharpness_filter",
  local_expressions = {
    max_probability = 0.01,
    sharpness_filter = "ab_sharpness_function(peaks_expr, 0.3)",
    peaks_expr = "influence_modifier + peak1_expr",
    peak1_expr = "peak1_noise_expression",
    peak1_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.9, seed0=map_seed, seed1='mud-decal', octaves=octaves-2, input_scale=1, output_scale=1}",
    octaves = "8 - log2(var('control:moisture:frequency'))",
    influence_modifier = "0.5 - quantile - 0.3",
    quantile = 0.4,
  },
  -- max_probability = 0.01,
  -- peaks = {
  --   {
  --     influence = 1,
  --     noise_layer = "mud-decal",
  --     noise_octaves_difference = -2,
  --     noise_persistence = 0.9
  --   },
  -- },
  -- sharpness = 0.3,
}

-- ROCKS

-- get base rocks
local base_rocks_list = require("rocks-base")
local base_rocks = {}
for _, rock in pairs(base_rocks_list) do
  base_rocks[rock.name] = rock
end

-- Get the nauvis planet entity specification
local nauvis = data.raw.planet.nauvis
local nauvis_entity_settings
local nauvis_deco_settings
if    nauvis
  and nauvis.map_gen_settings
  and nauvis.map_gen_settings.autoplace_settings
then
  if nauvis.map_gen_settings.autoplace_settings.entity then
    nauvis_entity_settings = nauvis.map_gen_settings.autoplace_settings.entity.settings
  end
  if nauvis.map_gen_settings.autoplace_settings.decorative then
    nauvis_deco_settings = nauvis.map_gen_settings.autoplace_settings.decorative.settings
  end
end

-- make a new colored rock from a base rock and restrict to certain biome tiles by tag
local make_rock = function(name, base_names, tile_restriction, multiplier, color)
  if table_size(tile_restriction) > 0 then
    if color == nil then color = name end
    for _, base_name in pairs(base_names) do
      local rock = table.deepcopy(base_rocks[base_name])
      rock.name = base_name .. '-' .. name
      rock.autoplace.tile_restriction = tile_restriction
      if rock.autoplace.coverage then rock.autoplace.coverage = rock.autoplace.coverage * multiplier end
      if rock.autoplace.max_probability then rock.autoplace.max_probability = rock.autoplace.max_probability * multiplier end
      if    rock.autoplace.local_expressions
        and rock.autoplace.local_expressions.max_probability
      then
        rock.autoplace.local_expressions.max_probability = rock.autoplace.local_expressions.max_probability * multiplier
      end

      if rock.icon then
        rock.icons = {{
          icon = rock.icon,
          icon_size = rock.icon_size,
          tint = tints[color]
        }}
        rock.icon = nil
        rock.icon_size = nil
      elseif rock.icons then
        for _, icon in pairs(rock.icons) do
          icon.tint = tints[color]
        end
      end

      -- replace still required for dunes
      if base_name == 'sand-dune-decal' then
        local dune_matrices = require("prototypes/tint-matrices").dunes
        for _, pic in pairs(rock.pictures) do
          local idx = pic.filename and pic.filename:match("sand%-dune%-decal%-(%d+)%.png$")
          local m = idx and dune_matrices[idx]
          if m and m.tints[color] then
            pic.filename = m.file
            pic.tint = m.tints[color]
          else
            pic.filename = util.replace(pic.filename, '|color|', color)
          end
        end
      else
          for _, pic in pairs(rock.pictures) do
            pic.tint = tints[color]
          end
      end

      --rock.localised_name = {"alien-biomes.doublestring", {"alien-biomes.".. color}, {"entity-name.rock"} }
      rock.localised_name = {"entity-name.rock"}
      -- volcanic has generally more rocks
      data:extend({rock})
      if rock.type == "simple-entity" and nauvis_entity_settings then
        nauvis_entity_settings[rock.name] = {}
      end
      if rock.type == "optimized-decorative" and nauvis_deco_settings then
        nauvis_deco_settings[rock.name] = {}
      end
    end
  end
end

-- main rocks
make_rock(
  'tan',
  {
    'huge-rock',
    'big-rock',
    'medium-rock',
    'small-rock',
    'tiny-rock'
  },
  list(any(any(tiles(),
    {'dirt', 'grass'}), -- land types
    {
      'dustyrose',-- dirt
      'green', 'turquoise' -- grass
    }
  )),
  1
)

-- main rocks
make_rock(
  'dustyrose',
  {
    'huge-rock',
    'big-rock',
    'medium-rock',
    'small-rock',
    'tiny-rock'
  },
  list(any(tiles(),{'dirt-dustyrose', 'grass-violet'})),
  1
)

make_rock(
  'cream',
  {
    'huge-rock',
    'big-rock',
    'medium-rock',
    'small-rock',
    'tiny-rock'
  },
  list(any(any(tiles(),
    {'dirt', 'grass'}), -- land types
    {
      'cream',-- dirt
      'yellow' -- grass
    }
  )),
  1
)

make_rock(
  'brown',
  {
    'huge-rock',
    'big-rock',
    'medium-rock',
    'small-rock',
    'tiny-rock'
  },
  list(any(any(tiles(),
    {'dirt', 'grass'}), -- land types
    {
      'brown',-- dirt
      'orange' -- grass
    }
  )),
  1
)

make_rock(
  'beige',
  {
    'huge-rock',
    'big-rock',
    'medium-rock',
    'small-rock',
    'tiny-rock'
  },
  list(any(any(tiles(),
    {'dirt', 'grass'}), -- land types
    {
      'beige',-- dirt
      'olive' -- grass
    }
  )),
  1
)

make_rock(
  'red',
  {
    'huge-rock',
    'big-rock',
    'medium-rock',
    'small-rock',
    'tiny-rock'
  },
  list(any(any(tiles(),
    {'dirt', 'grass'}), -- land types
    {
      'red',  -- dirt or grass
    }
  )),
  1
)

make_rock(
  'violet',
  {
    'huge-rock',
    'big-rock',
    'medium-rock',
    'small-rock',
    'tiny-rock'
  },
  list(any(tiles(),{'dirt-violet'})),
  1
)

make_rock(
  'purple',
  {
    'huge-rock',
    'big-rock',
    'medium-rock',
    'small-rock',
    'tiny-rock'
  },
  list(any(tiles(),{'dirt-purple'})),
  1
)

make_rock(
  'aubergine',
  {
    'huge-rock',
    'big-rock',
    'medium-rock',
    'small-rock',
    'tiny-rock'
  },
  list(any(tiles(),{'dirt-aubergine', 'grass-mauve'})),
  1
)

make_rock(
  'black',
  {
    'huge-rock',
    'big-rock',
    'medium-rock',
    'small-rock',
    'tiny-rock'
  },
  list(any(any(tiles(),
    {'dirt', 'volcanic'}), -- land types
    {'black', 'volcanic' }
  )),
  1
)

make_rock(
  'grey',
  {
    'huge-rock',
    'big-rock',
    'medium-rock',
    'small-rock',
    'tiny-rock'
  },
  list(any(tiles(),{'dirt-grey', 'grass-blue', 'grass-turquoise'})),
  1
)

make_rock(
  'white',
  {
    'huge-rock',
    'big-rock',
    'medium-rock',
    'small-rock',
    'tiny-rock'
  },
  list(any(any(tiles(),
    {'dirt', 'frozen'}), -- land types
    {
      'white', -- dirt
      'snow',
    }
  )),
  1
)

-- non-sand shared decals
make_rock(
  'tan',
  { 'stone-decal' },
  list(any(any(tiles(),
    {'dirt', 'grass'}), -- land types
    {
      'tan', 'brown', 'cream', 'beige', 'dustyrose',-- dirt
      'green', 'olive', 'turquoise', 'yellow', 'orange', 'purple' -- grass
    }
  )),
  1
)

make_rock(
  'red',
  { 'stone-decal' },
  list(any(any(tiles(),
    {'dirt', 'grass'}), -- land types
    {
      'red', 'violet', -- dirt
      'red', 'violet', -- grass
    }
  )),
  1
)

make_rock(
  'purple',
  { 'stone-decal' },
  list(any(any(tiles(),
    {'dirt', 'grass'}), -- land types
    {
      'purple', 'aubergine', -- dirt
      'purple', -- grass
    }
  )),
  1
)

make_rock(
  'black',
  { 'stone-decal' },
  list(any(any(tiles(),
    {'dirt'}), -- land types
    {'black'}
  )),
  1
)

make_rock(
  'white',
  { 'stone-decal' },
  list(any(any(tiles(),
    {'dirt', 'grass', 'frozen'}), -- land types
    {
      'white', 'grey', -- dirt
      'blue', 'mauve', -- grass
      'snow',
    }
  )),
  1
)

-- shared decals
make_rock(
  'tan',
  { 'sand-decal' },
  list(any(any(tiles(),
    {'dirt', 'sand', 'grass'}), -- land types
    {
      'tan', 'brown', 'cream', 'beige', 'dustyrose',-- dirt
      'green', 'olive', 'turquoise', 'yellow', 'orange', 'purple' -- grass
    }
  )),
  1
)

make_rock(
  'red',
  { 'sand-decal' },
  list(any(any(tiles(),
    {'dirt', 'sand', 'grass'}), -- land types
    {
      'red', 'violet', -- dirt
      'red', 'violet', -- grass
    }
  )),
  1
)

make_rock(
  'purple',
  { 'sand-decal' },
  list(any(any(tiles(),
    {'dirt', 'sand', 'grass'}), -- land types
    {
      'purple', 'aubergine', -- dirt
      'purple', -- grass
    }
  )),
  1
)

make_rock(
  'black',
  { 'sand-decal' },
  list(any(any(tiles(),
    {'dirt', 'sand', 'volcanic'}), -- land types
    {'black', 'volcanic' }
  )),
  2
)

make_rock(
  'white',
  { 'sand-decal' },
  list(any(any(tiles(),
    {'dirt', 'sand', 'grass', 'frozen'}), -- land types
    {
      'white', 'grey', -- dirt
      'blue', 'mauve', -- grass
      'snow',
    }
  )),
  2
)

-- sandy rocks and decals
make_rock(
  'tan',
  {
    'sand-big-rock',
    'sand-medium-rock',
    'sand-small-rock',
  },
  list(any(any(tiles(),
    {'sand'}), -- land types
    {
      'tan', 'brown', 'cream', 'beige' -- dirt
    }
  )),
  1
)

make_rock(
  'red',
  {
    'sand-big-rock',
    'sand-medium-rock',
    'sand-small-rock',
  },
  list(any(any(tiles(),
    {'sand'}), -- land types
    {
      'red', 'violet', 'dustyrose', -- dirt
    }
  )),
  1
)

make_rock(
  'purple',
  {
    'sand-big-rock',
    'sand-medium-rock',
    'sand-small-rock',
  },
  list(any(any(tiles(),
    {'sand'}), -- land types
    {
      'purple', 'aubergine', -- dirt
    }
  )),
  1
)

make_rock(
  'black',
  {
    'sand-big-rock',
    'sand-medium-rock',
    'sand-small-rock',
  },
  list(any(any(tiles(),
    {'sand'}), -- land types
    {'black' }
  )),
  1
)

make_rock(
  'white',
  {
    'sand-big-rock',
    'sand-medium-rock',
    'sand-small-rock',
  },
  list(any(any(tiles(),
    {'sand'}), -- land types
    {
      'white', 'grey', -- dirt
    }
  )),
  1
)

-- dune
for color, data in pairs(alien_biomes.spec.mineral.axes) do
  make_rock(color, {'sand-dune-decal'}, list(any(any(tiles(),{'sand'}), {color} )), 4 )
end

-- volcanic
local volcanic_tiles = list(any(tiles(), {'volcanic'} ))
make_rock(
  'volcanic',
  {
    'huge-rock',
    'big-rock',
    'medium-rock',
    'small-rock',
    'tiny-rock',
    'sand-decal',
    'stone-decal'
  },
  volcanic_tiles,
  2,
  "black"
)
if data.raw['simple-entity']['huge-rock-volcanic'] then
  data.raw['simple-entity']['huge-rock-volcanic'].autoplace = {
    tile_restriction = volcanic_tiles,
    probability_expression = "random_penalty{x=x,y=y,seed=map_seed,source=(max_probability * sharpness_filter), amplitude=penalty}",
    local_expressions = {
      max_probability = 1,
      penalty = 0.6,
      sharpness_filter = "ab_sharpness_function(peaks_expr, 0)",
      peaks_expr = "influence_modifier + peak1_expr + peak2_expr",
      peak1_expr = "0.4 * peak1_noise_expression",
      peak1_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.8, seed0=map_seed, seed1='grass1', octaves=octaves-4, input_scale=1, output_scale=1}",
      peak2_expr = -0.2,
      octaves = "8 - log2(var('control:rocks:frequency'))",
      influence_modifier = "0.5 - quantile + 0.2",
      quantile = 0.75,
    },
    -- random_probability_penalty = 0.6,
    -- peaks = {
    --   { influence = -0.2 },
    --   { noise_layer = "grass1", influence = 0.4, noise_persistance = 0.8, noise_octaves_difference = -4},
    -- }
  }
end
if data.raw['simple-entity']['big-rock-volcanic'] then
  data.raw['simple-entity']['big-rock-volcanic'].autoplace = {
    tile_restriction = volcanic_tiles,
    probability_expression = "random_penalty{x=x,y=y,seed=map_seed,source=(max_probability * sharpness_filter), amplitude=penalty}",
    local_expressions = {
      max_probability = 1,
      penalty = 0.6,
      sharpness_filter = "ab_sharpness_function(peaks_expr, 0)",
      peaks_expr = "influence_modifier + peak1_expr + peak2_expr",
      peak1_expr = "0.4 * peak1_noise_expression",
      peak1_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.8, seed0=map_seed, seed1='grass1', octaves=octaves-4, input_scale=1, output_scale=1}",
      peak2_expr = -0.1,
      octaves = "8 - log2(var('control:rocks:frequency'))",
      influence_modifier = "0.5 - quantile + 0.1",
      quantile = 0.7,
    },
    -- random_probability_penalty = 0.6, 
    -- peaks = {
    --   { influence = -0.1 },
    --   { noise_layer = "grass1", influence = 0.4, noise_persistance = 0.8, noise_octaves_difference = -4},
    -- }
  }
end
if data.raw['optimized-decorative']['medium-rock-volcanic'] then
data.raw['optimized-decorative']['medium-rock-volcanic'].autoplace = {
  tile_restriction = volcanic_tiles,
  probability_expression = "random_penalty{x=x,y=y,seed=map_seed,source=(max_probability * sharpness_filter), amplitude=penalty}",
  local_expressions = {
    max_probability = 1,
    penalty = 0.2,
    sharpness_filter = "ab_sharpness_function(peaks_expr, 0)",
    peaks_expr = "influence_modifier + peak1_expr + peak2_expr",
    peak1_expr = "0.4 * peak1_noise_expression",
    peak1_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.8, seed0=map_seed, seed1='grass1', octaves=octaves-4, input_scale=1, output_scale=1}",
    peak2_expr = 0.4,
    octaves = "8 - log2(var('control:rocks:frequency'))",
    influence_modifier = "0.5 - quantile - 0.4",
    quantile = 0.2,
  },
  -- random_probability_penalty = 0.2, 
  -- peaks = {
  --   { influence = 0.4 },
  --   { noise_layer = "grass1", influence = 0.4, noise_persistance = 0.8, noise_octaves_difference = -4},
  -- }
}
end
if data.raw['optimized-decorative']['small-rock-volcanic'] then
data.raw['optimized-decorative']['small-rock-volcanic'].autoplace = {
  tile_restriction = volcanic_tiles,
  probability_expression = "random_penalty{x=x,y=y,seed=map_seed,source=(max_probability * sharpness_filter), amplitude=penalty}",
  local_expressions = {
    max_probability = 1,
    penalty = 0.25,
    sharpness_filter = "ab_sharpness_function(peaks_expr, 0)",
    peaks_expr = "influence_modifier + peak1_expr + peak2_expr",
    peak1_expr = "0.4 * peak1_noise_expression",
    peak1_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.8, seed0=map_seed, seed1='grass1', octaves=octaves-4, input_scale=1, output_scale=1}",
    peak2_expr = 0.45,
    octaves = "8 - log2(var('control:rocks:frequency'))",
    influence_modifier = "0.5 - quantile - 0.45",
    quantile = 0.02,
  },
  -- random_probability_penalty = 0.25, 
  -- peaks = {
  --   { influence = 0.45 },
  --   { noise_layer = "grass1", influence = 0.4, noise_persistance = 0.8, noise_octaves_difference = -4},
  -- }
}
end
if data.raw['optimized-decorative']['tiny-rock-volcanic'] then
data.raw['optimized-decorative']['tiny-rock-volcanic'].autoplace = {
  tile_restriction = volcanic_tiles,
  probability_expression = "random_penalty{x=x,y=y,seed=map_seed,source=(max_probability * sharpness_filter), amplitude=penalty}",
  local_expressions = {
    max_probability = 1,
    penalty = 0.25,
    sharpness_filter = "ab_sharpness_function(peaks_expr, 0)",
    peaks_expr = "influence_modifier + peak1_expr + peak2_expr",
    peak1_expr = "0.4 * peak1_noise_expression",
    peak1_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.8, seed0=map_seed, seed1='grass1', octaves=octaves-4, input_scale=1, output_scale=1}",
    peak2_expr = 0.5,
    octaves = "8 - log2(var('control:rocks:frequency'))",
    influence_modifier = "0.5 - quantile - 0.5",
    quantile = -0.02,
  },
  -- random_probability_penalty = 0.25,
  -- peaks = {
  --   { influence = 0.5 },
  --   { noise_layer = "grass1", influence = 0.4, noise_persistance = 0.8, noise_octaves_difference = -4},
  -- }
}
end
if data.raw['optimized-decorative']['sand-decal-volcanic'] then
data.raw['optimized-decorative']['sand-decal-volcanic'].autoplace = {
  tile_restriction = volcanic_tiles,
  probability_expression = "max_probability * sharpness_filter",
  local_expressions = {
    max_probability = 0.3,
    sharpness_filter = "ab_sharpness_function(peaks_expr, 0)",
    peaks_expr = "influence_modifier + peak1_expr + peak2_expr",
    peak1_expr = "0.1 * peak1_noise_expression",
    peak1_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.8, seed0=map_seed, seed1='dirt-1', octaves=octaves-4, input_scale=1, output_scale=1}",
    peak2_expr = 0.2,
    octaves = "8 - log2(var('control:rocks:frequency'))",
    influence_modifier = "0.5 - quantile - 0.2",
    quantile = -0.1,
  },
  -- max_probability = 0.3,
  -- peaks = {
  --   { influence = 0.2 },
  --   { noise_layer = "dirt-1", influence = 0.1, noise_persistance = 0.8, noise_octaves_difference = -4},
  -- }
}
end
if data.raw['optimized-decorative']['stone-decal-volcanic'] then
data.raw['optimized-decorative']['stone-decal-volcanic'].autoplace = {
  tile_restriction = volcanic_tiles,
  probability_expression = "max_probability * sharpness_filter",
  local_expressions = {
    max_probability = 0.3,
    sharpness_filter = "ab_sharpness_function(peaks_expr, 0)",
    peaks_expr = "influence_modifier + peak1_expr + peak2_expr",
    peak1_expr = "0.1 * peak1_noise_expression",
    peak1_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.8, seed0=map_seed, seed1='grass1', octaves=octaves-4, input_scale=1, output_scale=1}",
    peak2_expr = 0.2,
    octaves = "8 - log2(var('control:rocks:frequency'))",
    influence_modifier = "0.5 - quantile - 0.2",
    quantile = -0.1,
  },
  -- max_probability = 0.3,
  -- peaks = {
  --   { influence = 0.2 },
  --   { noise_layer = "dirt-2", influence = 0.1, noise_persistance = 0.8, noise_octaves_difference = -4},
  -- }
}
end
