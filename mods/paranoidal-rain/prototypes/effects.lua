-- Sounds, steam, the fire marker and the pollution source name.
local MOD = "__paranoidal-rain__"
local EMPTY = "__core__/graphics/empty.png"
local smoke_animations = require("__base__.prototypes.entity.smoke-animations")

local function files(prefix, names, volume)
  local result = {}
  for _, name in ipairs(names) do
    result[#result + 1] = { filename = MOD .. "/sound/" .. prefix .. name .. ".ogg", volume = volume }
  end
  return result
end

local function numbered(prefix, count, volume, start)
  local names = {}
  for i = start or 1, count do names[#names + 1] = tostring(i) end
  return files(prefix, names, volume)
end

local function join(...)
  local result = {}
  for _, list in ipairs({ ... }) do
    for _, item in ipairs(list) do result[#result + 1] = item end
  end
  return result
end

data:extend({
  -- Thunder banks: Dynamic Rain thunder + Real Rain Mixkit layers (see CREDITS.md).
  {
    type = "sound",
    name = "prain-thunder-far",
    category = "world-ambient",
    variations = join(numbered("thunder/far-", 5, 0.9), numbered("thunder/far-mixkit-", 6, 0.85)),
  },
  {
    type = "sound",
    name = "prain-thunder-close",
    category = "world-ambient",
    audible_distance_modifier = 1.0,
    variations = join(numbered("thunder/close-", 5, 1), numbered("thunder/close-mixkit-", 4, 1)),
  },
  {
    type = "sound",
    name = "prain-thunder-roll",
    category = "world-ambient",
    variations = numbered("thunder/roll-mixkit-", 3, 0.72),
  },
  {
    type = "sound",
    name = "prain-lightning-crack",
    category = "world-ambient",
    priority = 0,
    variations = numbered("lightning/crack-", 3, 1),
  },
  {
    type = "sound",
    name = "prain-hiss",
    volume = 0.75,
    variations = numbered("misc/hiss-", 2, 0.75),
  },
  {
    type = "sound",
    name = "prain-wind-gust",
    category = "world-ambient",
    filename = MOD .. "/sound/misc/wind-gust.ogg",
    volume = 0.55,
  },
})

-- Steam where rain puts a fire out (same look as the start fires of zzzparanoidal-start-bnl).
data:extend({
  smoke_animations.trivial_smoke({ name = "prain-steam", color = { r = 0.95, g = 0.95, b = 0.95, a = 0.6 },
    duration = 480, fade_in_duration = 10, spread_duration = 480, start_scale = 0.8, end_scale = 3.2 }),
  smoke_animations.trivial_smoke({ name = "prain-steam-small", color = { r = 0.95, g = 0.95, b = 0.95, a = 0.5 },
    duration = 90, fade_in_duration = 5, spread_duration = 90, start_scale = 0.4, end_scale = 1.4 }),
})

local empty_animation = { filename = EMPTY, width = 1, height = 1, frame_count = 1, line_length = 1, animation_speed = 1 }

data:extend({
  -- Created by every fire prototype (data-final-fixes.lua): raises on_trigger_created_entity with the fire as source.
  {
    type = "explosion",
    name = "prain-fire-marker",
    flags = { "not-on-map", "placeable-off-grid" },
    hidden = true,
    selectable_in_game = false,
    animations = { empty_animation },
  },
  -- Source name for surface.pollute (production statistics show the rain as a pollution cleaner).
  {
    type = "simple-entity",
    name = "prain-pollution-cleaner",
    icon = "__base__/graphics/icons/fluid/water.png",
    icon_size = 64,
    hidden = true,
    hidden_in_factoriopedia = true,
    flags = { "not-on-map", "placeable-off-grid" },
    collision_box = { { 0, 0 }, { 0, 0 } },
    collision_mask = { layers = {} },
    selection_box = { { 0, 0 }, { 0, 0 } },
    selectable_in_game = false,
    picture = { filename = EMPTY, width = 1, height = 1 },
  },
})
