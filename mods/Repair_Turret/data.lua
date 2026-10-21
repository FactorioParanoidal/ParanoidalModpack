-- Repair Turret, Paranoidal fork 9.x.
-- One visible container (1 slot for repair packs) + one hidden electric-energy-interface created by control.lua.
-- No roboport, no logistic network, no construction: repair only.
local util = require("util")
local C = require("shared")

local path = "__Repair_Turret__/graphics/"
local watts = function(w) return string.format("%dkW", math.floor(w / 1000)) end
local joules = function(j) return string.format("%dkJ", math.floor(j / 1000)) end

local collision_box = {{-0.7, -0.7}, {0.7, 0.7}}
local selection_box = {{-1, -1}, {1, 1}}
local icon = path .. "repairturret64.png"

-- Static tower (container picture). Original shifts were relative to {0, -1}.
local base_picture =
{
  layers =
  {
    {filename = path .. "repair_turret.png", width = 140, height = 260, shift = {0, -1}, scale = 0.5},
    {
      filename = path .. "repair_turretglotint.png", width = 120, height = 120,
      shift = {0, 10 / 32 - 1}, scale = 0.5, draw_as_glow = true,
      tint = {r = 0.9, g = 0.5, b = 0, a = 0.5}
    },
    {filename = path .. "repair_turretglo.png", width = 120, height = 120, shift = {0, 10 / 32 - 1}, scale = 0.5, draw_as_glow = true},
    {filename = path .. "repair_turretsh.png", width = 530, height = 92, shift = {98 / 32, 48 / 32 - 1}, scale = 0.5, draw_as_shadow = true},
    {
      filename = path .. "repair_turretmsk.png", flags = {"mask"}, width = 120, height = 120,
      shift = {0, 15 / 32 - 1}, scale = 0.5, tint = {r = 0, g = 1, b = 0, a = 0.5}
    },
  }
}

-- Rotating head, drawn by the hidden energy entity (placed eei_offset lower).
local dy = -1 - C.eei_offset
local head_animation =
{
  layers =
  {
    {
      filename = path .. "turret.png", priority = "medium", width = 124, height = 164,
      line_length = 8, frame_count = 8, animation_speed = 0.4, shift = {0, -63 / 32 + dy}, scale = 0.5
    },
    {
      filename = path .. "turretglo.png", priority = "medium", width = 124, height = 164,
      line_length = 8, frame_count = 8, animation_speed = 0.4, shift = {0, -63 / 32 + dy}, scale = 0.5,
      draw_as_glow = true
    },
    {
      filename = path .. "turretsh.png", width = 202, height = 92,
      line_length = 8, frame_count = 8, animation_speed = 0.4, shift = {164 / 32, 48 / 32 + dy}, scale = 0.5,
      draw_as_shadow = true
    },
  }
}

local steel_chest = data.raw.container["steel-chest"]

local turret =
{
  type = "container",
  name = C.turret,
  icon = icon,
  icon_size = 64,
  flags = {"placeable-player", "player-creation", "not-rotatable"},
  minable = {mining_time = 0.5, result = C.turret},
  max_health = 500,
  corpse = "repair-turret-remnants",
  dying_explosion = "medium-explosion",
  resistances =
  {
    {type = "fire", percent = 60},
    {type = "impact", percent = 30},
  },
  collision_box = collision_box,
  selection_box = selection_box,
  inventory_size = 1,
  quality_affects_inventory_size = false,
  picture = base_picture,
  -- The repair area depends on research, so control.lua draws it on hover instead of radius_visualisation_specification.
  circuit_wire_max_distance = 0,
  open_sound = steel_chest and steel_chest.open_sound or nil,
  close_sound = steel_chest and steel_chest.close_sound or nil,
}

local energy =
{
  type = "electric-energy-interface",
  name = C.energy,
  localised_name = {"entity-name." .. C.turret},
  icon = icon,
  icon_size = 64,
  flags =
  {
    "not-blueprintable", "not-deconstructable", "not-on-map", "placeable-off-grid", "not-flammable",
    "no-copy-paste", "not-upgradable", "not-in-kill-statistics", "not-rotatable", "not-repairable",
    "hide-alt-info", "not-in-made-in"
  },
  hidden = true,
  hidden_in_factoriopedia = true,
  selectable_in_game = false,
  allow_copy_paste = false,
  max_health = 500,
  collision_box = collision_box,
  collision_mask = {layers = {}},
  selection_box = selection_box,
  gui_mode = "none",
  energy_source =
  {
    type = "electric",
    usage_priority = "secondary-input",
    buffer_capacity = joules(C.min_buffer), -- raised per force by control.lua
    input_flow_limit = watts(C.max_power),
    output_flow_limit = "0W",
  },
  energy_usage = watts(C.idle_power),
  energy_production = "0W",
  continuous_animation = true,
  animation = head_animation,
}

local item =
{
  type = "item",
  name = C.turret,
  icon = icon,
  icon_size = 64,
  localised_description = {"entity-description." .. C.turret},
  subgroup = "defensive-structure",
  order = "b[turret]-az[repair-turret]",
  place_result = C.turret,
  stack_size = 20,
}

-- Default recipe; Paranoidal overrides it in zzzparanoidal/tweaks/recipe/repair-turret.lua.
local recipe =
{
  type = "recipe",
  name = C.turret,
  enabled = false,
  energy_required = 30,
  ingredients =
  {
    {type = "item", name = "iron-gear-wheel", amount = 100},
    {type = "item", name = "electronic-circuit", amount = 25},
    {type = "item", name = "electric-engine-unit", amount = 15},
    {type = "item", name = "stone-brick", amount = 100},
  },
  results = {{type = "item", name = C.turret, amount = 1}},
}

local technology =
{
  type = "technology",
  name = C.turret,
  icon = path .. "repairturret256.png",
  icon_size = 256,
  effects = {{type = "unlock-recipe", recipe = C.turret}},
  prerequisites = {"gun-turret"},
  unit =
  {
    count = 250,
    ingredients = {{"automation-science-pack", 1}},
    time = 30,
  },
  order = "a-j-b[repair-turret]",
}

-- Upgrade branches. Effects are applied by control.lua from the researched levels.
local packs =
{
  "automation-science-pack", "logistic-science-pack", "chemical-science-pack",
  "production-science-pack", "utility-science-pack",
}
local pack_tech = {nil, "logistic-science-pack", "chemical-science-pack", "production-science-pack", "utility-science-pack"}
local base_icon = path .. "repairturret256.png"
local upgrades = {}

local function branch(prefix, levels, key, icons, value, order)
  local previous_tier = 1
  for i, level in ipairs(levels) do
    local count, time, tier = level[1], level[2], level[3]
    local ingredients = {}
    for p = 1, tier do ingredients[p] = {packs[p], 1} end
    local prerequisites = {i == 1 and C.turret or (prefix .. (i - 1))}
    if tier > 1 and (i == 1 or tier ~= previous_tier) then
      prerequisites[#prerequisites + 1] = pack_tech[tier]
    end
    previous_tier = tier
    upgrades[#upgrades + 1] =
    {
      type = "technology",
      name = prefix .. i, -- like vanilla upgrades: locale key without the -N suffix, level shown by the engine
      icons = icons,
      upgrade = true,
      effects = {{type = "nothing", effect_description = {"modifier-description." .. key, value}}},
      prerequisites = prerequisites,
      unit = {count = count, ingredients = ingredients, time = time},
      order = "a-j-b[repair-turret]-" .. order .. string.format("%02d", i),
    }
  end
end

branch(C.speed_tech, C.speed_levels, "repair-turret-speed",
  util.technology_icon_constant_speed(base_icon), tostring(math.floor(C.speed_bonus * 100 + 0.5)), "a")
branch(C.beams_tech, C.beams_levels, "repair-turret-beams",
  util.technology_icon_constant_followers(base_icon), "1", "b")
branch(C.range_tech, C.range_levels, "repair-turret-range",
  util.technology_icon_constant_range(base_icon), "1", "c")
data:extend(upgrades)

-- Visual only: no damage, the heal is applied by control.lua.
local beam = util.table.deepcopy(data.raw.beam["electric-beam"])
beam.name = C.beam
beam.localised_name = {"entity-name." .. C.turret}
beam.action = nil
beam.action_triggered_automatically = false
beam.damage_interval = 10000
beam.hidden = true
beam.hidden_in_factoriopedia = true

local function tint_sprites(t, tint)
  for _, v in pairs(t) do
    if type(v) == "table" then
      if v.width and v.height and (v.filename or v.filenames or v.stripes) then
        v.tint = tint
      end
      tint_sprites(v, tint)
    end
  end
end
tint_sprites(beam, {r = 0.1, g = 1, b = 0.1})

local remnants =
{
  type = "corpse",
  name = "repair-turret-remnants",
  icon = path .. "repairturret128.png",
  icon_size = 128,
  flags = {"placeable-neutral", "building-direction-8-way", "not-on-map"},
  hidden_in_factoriopedia = true,
  subgroup = "transport-remnants",
  order = "a-k-a",
  selection_box = selection_box,
  selectable_in_game = false,
  time_before_removed = 60 * 60 * 15,
  final_render_layer = "remnants",
  remove_on_tile_placement = false,
  animation =
  {
    layers =
    {
      {
        filename = path .. "hr-repairturretrem.png",
        line_length = 1, width = 192, height = 192, frame_count = 1, direction_count = 4, scale = 0.5,
      },
      {
        filename = path .. "hr-repairturretremmsk.png",
        line_length = 1, width = 128, height = 128, frame_count = 1, direction_count = 4, scale = 0.5,
        tint = {r = 0, g = 1, b = 0, a = 0.5},
      },
    }
  }
}

data:extend{turret, energy, item, recipe, technology, beam, remnants}
