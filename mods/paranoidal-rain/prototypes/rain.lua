-- Rain drops, splashes, puddles and the rain sound source.
-- A drop is an invisible explosion ("spawner") whose created_smoke (EntityPrototype::created_smoke) launches a
-- trivial smoke with a rain sprite; the smoke is drawn only where a player can see it (only_when_visible).
-- Layers (front, middle, mist), wind buckets, splashes and puddles come from Real Rain; the sprites too.
local MOD = "__paranoidal-rain__"
local EMPTY = "__core__/graphics/empty.png"

local empty_animation = { filename = EMPTY, width = 1, height = 1, frame_count = 1, line_length = 1, animation_speed = 1 }

local function smoke(name, file, frame, duration, fade, start_scale, end_scale)
  return {
    type = "trivial-smoke",
    name = name,
    animation = {
      filename = MOD .. "/graphics/rain/" .. file,
      width = 256,
      height = 256,
      frame_count = 1,
      x = (frame % 2) * 256,
      y = math.floor(frame / 2) * 256,
      animation_speed = 1,
    },
    duration = duration,
    spread_duration = 8,
    fade_in_duration = fade,
    fade_away_duration = fade,
    start_scale = start_scale,
    end_scale = end_scale,
    affected_by_wind = false,
    movement_slow_down_factor = 1,
    show_when_smoke_off = true,
    cyclic = true,
  }
end

local function spawner(name, smoke_name, speed_x, speed_y, height, speed_mult, center_dev)
  return {
    type = "explosion",
    name = name,
    icon = EMPTY,
    icon_size = 1,
    flags = { "not-on-map", "placeable-off-grid" },
    collision_box = { { 0, 0 }, { 0, 0 } },
    collision_mask = { layers = {} },
    selectable_in_game = false,
    hidden = true,
    animations = { empty_animation },
    created_smoke = {
      type = "create-trivial-smoke",
      smoke_name = smoke_name,
      speed = { x = speed_x, y = speed_y },
      initial_height = height,
      speed_multiplier = speed_mult,
      speed_multiplier_deviation = 0.1,
      speed_from_center = 0.01,
      speed_from_center_deviation = center_dev,
      only_when_visible = true,
    },
  }
end

local list = {}
for frame = 0, 3 do
  local n = frame + 1
  list[#list + 1] = smoke("prain-front-" .. n, "rain-streaks.png", frame, 26, 4, 0.62, 0.62)
  list[#list + 1] = smoke("prain-mid-" .. n, "rain-streaks.png", frame, 36, 6, 0.42, 0.42)
  list[#list + 1] = smoke("prain-mist-" .. n, "rain-mist.png", frame, 48, 8, 0.54, 0.54)
  list[#list + 1] = smoke("prain-splash-" .. n, "rain-splash.png", frame, 28, 5, 0.35, 0.55)
  list[#list + 1] = smoke("prain-ripple-" .. n, "rain-ripple.png", frame, 34, 6, 0.42, 0.9)
  list[#list + 1] = smoke("prain-puddle-" .. n, "rain-ripple.png", frame, 54, 9, 0.34, 0.75)
end

-- Horizontal speed of the drops by wind bucket (scripts/visual.lua picks the bucket).
local WIND = { left = -0.18, straight = -0.06, right = 0.08, gust = -0.32 }
for n = 1, 4 do
  for wind, x in pairs(WIND) do
    list[#list + 1] = spawner("prain-drop-front-" .. n .. "-" .. wind, "prain-front-" .. n, x, 0.62, 1.2, 2.3, 0.02)
    list[#list + 1] = spawner("prain-drop-mid-" .. n .. "-" .. wind, "prain-mid-" .. n, x * 0.7, 0.42, 1.1, 1.55, 0.025)
    list[#list + 1] = spawner("prain-drop-mist-" .. n .. "-" .. wind, "prain-mist-" .. n, x * 0.45, 0.26, 1.0, 1.05, 0.035)
  end
  list[#list + 1] = spawner("prain-drop-splash-" .. n, "prain-splash-" .. n, 0, 0.02, 0.05, 0.15, 0.08)
  list[#list + 1] = spawner("prain-drop-ripple-" .. n, "prain-ripple-" .. n, 0, 0, 0.03, 0.08, 0.04)
  list[#list + 1] = spawner("prain-drop-puddle-" .. n, "prain-puddle-" .. n, 0, 0, 0.03, 0.05, 0.03)
end
data:extend(list)

-- Rain sound: a hidden programmable speaker playing a seamless loop (Dynamic Rain). One per surface and force.
local speaker = table.deepcopy(data.raw["programmable-speaker"]["programmable-speaker"])
speaker.name = "prain-sound-source"
speaker.hidden = true
speaker.hidden_in_factoriopedia = true
speaker.flags = { "not-on-map", "placeable-off-grid", "not-selectable-in-game", "not-blueprintable", "not-deconstructable",
  "not-in-kill-statistics" }
speaker.selectable_in_game = false
speaker.minable = nil
speaker.placeable_by = nil
speaker.next_upgrade = nil
speaker.fast_replaceable_group = nil
speaker.selection_box = nil
speaker.collision_box = nil
speaker.collision_mask = { layers = {} }
speaker.sprite = { filename = EMPTY, width = 1, height = 1 }
speaker.energy_source = { type = "void" }
speaker.energy_usage_per_tick = "1W"
speaker.maximum_polyphony = 1
speaker.circuit_connector = nil
speaker.circuit_wire_max_distance = 0
speaker.draw_copper_wires = false
speaker.draw_circuit_wires = false
speaker.instruments = {
  {
    name = "paranoidal-rain",
    notes = {
      {
        name = "rain",
        cyclic_sound = {
          begin_sound = { filename = MOD .. "/sound/rain/heavy-rain-start.ogg", volume = 0.5, category = "world-ambient" },
          middle_sound = { filename = MOD .. "/sound/rain/heavy-rain.ogg", volume = 0.5, category = "world-ambient" },
        },
      },
    },
  },
}
data:extend({ speaker })
