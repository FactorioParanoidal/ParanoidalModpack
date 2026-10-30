local S = require("shared")
local item_sounds = require("__base__.prototypes.item_sounds")
local hit_effects = require("__base__.prototypes.entity.hit-effects")

local G = "__PickupTower-reforged__/graphics/"
local COUNT = #S.tiers

local function icons(tier)
  local list = {{icon = G .. "icons/pickup-tower.png", icon_size = 128}}
  if reskins and reskins.lib and reskins.lib.tiers then
    return reskins.lib.tiers.add_tier_labels_to_icons(tier, list)
  end
  return list
end

local PREFIXES = {{1e9, "giga"}, {1e6, "mega"}, {1e3, "kilo"}}
local function watts(value)
  for _, p in ipairs(PREFIXES) do
    if value >= p[1] then
      local n = value / p[1]
      return {"", (n % 1 == 0) and string.format("%d", n) or string.format("%.2f", n):gsub("0+$", ""),
        {"si-prefix-symbol-" .. p[2]}, {"si-unit-symbol-watt"}}
    end
  end
  return {"", tostring(value), {"si-unit-symbol-watt"}}
end

local function description(spec)
  return {"",
    {"entity-description.pickup-tower"},
    {"pickup-tower.radius", tostring(spec.radius), tostring(spec.radius * 2)},
    {"pickup-tower.interval", {"time-symbol-seconds", tostring(spec.interval)}},
    {"pickup-tower.power", watts(spec.power)},
    {"pickup-tower.circuit"},
  }
end

-- Passive provider chest under the tower; the overlay repeats for each lid frame.
local function chest_animation()
  local source = data.raw["logistic-container"]["passive-provider-chest"]
  local layers = table.deepcopy(source.animation.layers)
  local frames = layers[1].frame_count or 1
  layers[#layers + 1] = {
    filename = G .. "entity/pickup-tower-base.png",
    priority = "medium",
    width = 320,
    height = 320,
    repeat_count = frames,
    shift = {0.85, -1.1},
    scale = 0.5,
  }
  return {layers = layers}, source
end

local RESISTANCES = {{type = "fire", percent = 90}, {type = "impact", percent = 60}}

local list = {}
local animation, provider = chest_animation()

for tier, spec in ipairs(S.tiers) do
  local name = S.tower(tier)
  local tier_icons = icons(tier)
  local desc = description(spec)

  list[#list + 1] = {
    type = "item",
    name = name,
    icons = tier_icons,
    localised_description = desc,
    subgroup = "storage",
    order = "i[pickup-tower]-" .. tier,
    inventory_move_sound = item_sounds.metal_large_inventory_move,
    pick_sound = item_sounds.metal_large_inventory_pickup,
    drop_sound = item_sounds.metal_large_inventory_move,
    place_result = name,
    stack_size = 50,
    weight = 10 * kg * (2 ^ tier),
  }

  list[#list + 1] = {
    type = "logistic-container",
    name = name,
    icons = tier_icons,
    localised_description = desc,
    logistic_mode = "passive-provider",
    flags = {"placeable-player", "player-creation"},
    minable = {mining_time = 0.5, result = name},
    fast_replaceable_group = "pickup-tower",
    next_upgrade = tier < COUNT and S.tower(tier + 1) or nil,
    max_health = 350,
    corpse = "medium-remnants",
    dying_explosion = "medium-explosion",
    resistances = RESISTANCES,
    collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
    selection_box = {{-0.7, -0.7}, {0.7, 0.7}},
    selection_priority = 60,
    damaged_trigger_effect = hit_effects.entity(),
    inventory_size = 40,
    impact_category = "metal",
    open_sound = {filename = "__base__/sound/metallic-chest-open.ogg", volume = 0.65},
    close_sound = {filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7},
    animation = animation,
    animation_sound = provider.animation_sound,
    opened_duration = provider.opened_duration,
    radius_visualisation_specification = {
      sprite = {
        filename = G .. "entity/pickup-tower-radius.png",
        priority = "medium",
        width = 64,
        height = 64,
        scale = 0.5,
        tint = {r = 0.5, g = 0.2, b = 0.2, a = 1},
      },
      distance = spec.radius,
    },
    circuit_connector = circuit_connector_definitions["chest"],
    circuit_wire_max_distance = default_circuit_wire_max_distance,
  }

  -- Hidden upper part: power consumer, rotating picture and the pickup timer (one sector scan per interval).
  -- Normal quality only; it charts nothing beyond its own chunk and joins no radar network.
  local energy = spec.power * spec.interval
  list[#list + 1] = {
    type = "radar",
    name = S.radar(tier),
    icons = tier_icons,
    localised_name = {"entity-name." .. name},
    localised_description = desc,
    hidden = true,
    flags = {"not-blueprintable", "not-deconstructable", "not-upgradable", "placeable-off-grid", "not-on-map",
      "no-copy-paste", "not-repairable", "not-in-kill-statistics", "not-in-made-in"},
    create_ghost_on_death = false,
    allow_copy_paste = false,
    max_health = 350,
    resistances = RESISTANCES,
    collision_mask = {layers = {}},
    collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
    selection_box = {{-1, -1}, {1, 1}},
    selection_priority = 40,
    drawing_box_vertical_extension = 1.5,
    energy_source = {type = "electric", usage_priority = "secondary-input"},
    energy_usage = spec.power .. "W",
    energy_per_sector = energy .. "J",
    energy_per_nearby_scan = energy .. "J",
    max_distance_of_sector_revealed = 0,
    max_distance_of_nearby_sector_revealed = 0,
    connects_to_other_radars = false,
    is_military_target = false,
    pictures = {
      layers = {{
        filename = G .. "entity/pickup-tower-sheet.png",
        priority = "high",
        width = 320,
        height = 320,
        direction_count = 16,
        line_length = 4,
        shift = {0.85, -1.1},
        scale = 0.5,
      }},
    },
    working_sound = {
      sound = {filename = "__base__/sound/radar.ogg", volume = 0.8},
      max_sounds_per_type = 3,
      use_doppler_shift = false,
    },
  }
end

data:extend(list)

require("prototypes.progression")
