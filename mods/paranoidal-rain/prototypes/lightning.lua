-- Lightning strikes on Factorio 2.0 without Space Age.
--
-- [2.0] The engine lightning (LightningPrototype, LuaSurface::execute_lightning) is marked "Space Age" in the 2.0
-- prototype API and needs the space_travel feature flag, which would change the whole game. So in 2.0 a strike is
-- drawn and applied by scripts/lightning.lua with the prototypes below: a bolt beam from the sky, the Space Age
-- impact flash and ground streamers (graphics and sounds copied from __space-age__, owned by every player of the
-- build), a light and a camera shake. The Dynamic Rain engine variant for 2.1 is kept commented out in
-- scripts/lightning.lua and data-final-fixes.lua.
local MOD = "__paranoidal-rain__"
local EMPTY = "__core__/graphics/empty.png"

local function by_pixel(x, y) return { x / 32, y / 32 } end

local function beam(name, width)
  local proto = table.deepcopy(data.raw.beam["electric-beam-no-sound"])
  proto.name = name
  proto.action = nil
  proto.random_target_offset = false
  proto.target_offset = { 0, 0 }
  proto.width = width
  proto.hidden = true
  proto.hidden_in_factoriopedia = true
  return proto
end

local impact_sound = {}
for i = 1, 5 do
  impact_sound[i] = { filename = MOD .. "/sound/lightning/impact-" .. i .. ".ogg", min_volume = 0.4, max_volume = 0.9 }
end

local function glow_explosion(name, file, width, height, shift, line_length, extra)
  local proto = {
    type = "explosion",
    name = name,
    flags = { "not-on-map", "placeable-off-grid" },
    hidden = true,
    hidden_in_factoriopedia = true,
    selectable_in_game = false,
    animations = {
      {
        filename = MOD .. "/graphics/lightning/" .. file,
        width = width,
        height = height,
        shift = shift,
        line_length = line_length,
        frame_count = 36,
        animation_speed = 1,
        scale = 0.5,
        draw_as_glow = true,
      },
    },
  }
  for key, value in pairs(extra or {}) do proto[key] = value end
  return proto
end

local list = {
  beam("prain-lightning-bolt", 1.5),
  beam("prain-lightning-chain", 0.5),
  glow_explosion("prain-lightning-impact", "lightning-explosion.png", 390, 318, by_pixel(0.5, -8), 4, {
    light = { intensity = 5, size = 50, color = { 0.1, 0.15, 1 } },
    light_intensity_factor_initial = 1,
    light_intensity_factor_final = 0,
    light_size_factor_initial = 1,
    light_size_factor_final = 0.3,
    sound = {
      variations = impact_sound,
      aggregation = { max_count = 3, remove = true, count_already_playing = true },
      audible_distance_modifier = 2.25,
    },
    created_effect = {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {
          {
            type = "camera-effect",
            duration = 20,
            ease_in_duration = 10,
            ease_out_duration = 7,
            delay = 0,
            strength = 0.75,
            full_strength_max_distance = 10,
            max_distance = 70,
          },
          {
            type = "create-trivial-smoke",
            smoke_name = "fire-smoke-without-glow",
            offsets = { { 0, -0.5 } },
            offset_deviation = { { -0.5, -0.5 }, { 0.5, 0.5 } },
            speed = { 0, -0.5 },
            initial_height = 0.5,
            speed_from_center = 0.008,
            speed_from_center_deviation = 0.015,
            only_when_visible = true,
          },
        },
      },
    },
  }),
  glow_explosion("prain-lightning-streamer-1", "lightning-streamer-1.png", 166, 256, by_pixel(-9.5, -37), 6),
  glow_explosion("prain-lightning-streamer-2", "lightning-streamer-3.png", 270, 166, by_pixel(34, -22), 6),
  glow_explosion("prain-lightning-streamer-3", "lightning-streamer-5.png", 140, 256, by_pixel(7, -8.5), 6),
  glow_explosion("prain-lightning-streamer-4", "lightning-streamer-7.png", 264, 168, by_pixel(-35, -23), 6),
}

-- Fire lit by a strike: not put out by rain (scripts/fire.lua skips it), only by a fire safety turret or time.
local fire = table.deepcopy(data.raw.fire["fire-flame"])
fire.name = "prain-lightning-fire"
fire.initial_lifetime = 600
fire.localised_name = { "entity-name.prain-lightning-fire" }
list[#list + 1] = fire

-- A strike into an electric pole: a huge load for 3 s browns the network out (Dynamic Rain).
list[#list + 1] = {
  type = "electric-energy-interface",
  name = "prain-lightning-load",
  icon = "__base__/graphics/icons/signal/signal-lightning.png",
  icon_size = 64,
  hidden = true,
  hidden_in_factoriopedia = true,
  flags = { "not-on-map", "placeable-off-grid", "not-blueprintable", "not-deconstructable", "not-flammable",
    "not-in-kill-statistics" },
  selectable_in_game = false,
  gui_mode = "none",
  collision_box = { { 0, 0 }, { 0, 0 } },
  selection_box = { { 0, 0 }, { 0, 0 } },
  collision_mask = { layers = {} },
  picture = { filename = EMPTY, width = 1, height = 1 },
  energy_source = {
    type = "electric",
    buffer_capacity = "20GJ",
    input_flow_limit = "1000GW",
    output_flow_limit = "0W",
    usage_priority = "primary-input",
    drain = "0W",
    render_no_power_icon = false,
    render_no_network_icon = false,
  },
  energy_production = "0W",
  energy_usage = "1000GW",
}

data:extend(list)
