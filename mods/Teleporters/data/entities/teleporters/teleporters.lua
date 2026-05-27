local path = util.path("data/entities/teleporters/")
local teleporter = util.copy(data.raw["land-mine"]["land-mine"])
local names = require("shared")
local name = names.entities.teleporter
local localised_name = {name}

teleporter.name = name
teleporter.localised_name = localised_name
teleporter.trigger_radius = 1
teleporter.timeout = 5 * 60
teleporter.max_health = 200
--teleporter.shooting_cursor_size = 0
teleporter.dying_explosion = nil
teleporter.action =
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "create-sticker",
        sticker = names.entities.teleporter_sticker,
        trigger_created_entity = true
      }
    }
  }
}
teleporter.force_die_on_attack = false
teleporter.trigger_force = "all"
--teleporter.create_ghost_on_death = false
teleporter.order = name
teleporter.picture_safe =
{
  filename = path.."hr-teleporter-closed.png",
  priority = "medium",
  width = 160,
  height = 160,
  scale = 0.5,
}
teleporter.picture_set =
{
  filename = path.."hr-teleporter-open.png",
  priority = "medium",
  width = 160,
  height = 160,
  scale = 0.5,
}
teleporter.picture_set_enemy =
{
  filename = path.."hr-teleporter-open.png",
  priority = "medium",
  width = 160,
  height = 160,
  scale = 0.5,
}
teleporter.minable = {result = name, mining_time = 3}
teleporter.flags =
{
  --"not-blueprintable",
  "placeable-neutral",
  "placeable-player",
  "player-creation",
  "not-upgradable"
}
teleporter.collision_box = {{-1, -1},{1, 1}}
teleporter.selection_box = {{-1, -1},{1, 1}}
teleporter.map_color = {r = 0.5, g = 1, b = 1}


local sticker =
{
  type = "sticker",
  name = names.entities.teleporter_sticker,
  --icon = "__base__/graphics/icons/slowdown-sticker.png",
  flags = {},
  animation = util.empty_sprite(),
  duration_in_ticks = 1,
  --target_movement_modifier = 1
}


local teleporter_item = util.copy(data.raw.item["land-mine"])
teleporter_item.name = name
teleporter_item.localised_name = localised_name
teleporter_item.place_result = name
teleporter_item.icon = path.."teleporter-icon.png"
teleporter_item.icon_size = 64
teleporter_item.icon_mipmaps = 0
teleporter_item.subgroup = "circuit-network"


local fire = require("data/tf_util/tf_fire_util")

local teleporter_explosion = util.copy(data.raw.explosion.explosion)
teleporter_explosion.name = "teleporter-explosion"
teleporter_explosion.animations = fire.create_fire_pictures({scale = 1, animation_speed = 0.3})
teleporter_explosion.sound =
{
  filename = path.."teleporter-explosion.ogg",
  volume = 0.45
}

local teleporter_explosion_2 = util.copy(teleporter_explosion)
teleporter_explosion_2.name = "teleporter-explosion-no-sound"
teleporter_explosion_2.sound = nil

local recipe = {
  type = "recipe",
  name = name,
  localised_name = localised_name,
  enabled = false,
  ingredients =
  {
    {type = "item", name = "steel-plate", amount = 45},
    {type = "item", name = "advanced-circuit", amount = 20},
    {type = "item", name = "battery", amount = 25},
  },
  energy_required = 5,
  results = {{type = "item", name = name, amount = 1}}
}

local technology =
{
  type = "technology",
  name = name,
  localised_name = localised_name,
  localised_description = "",
  icon_size = 256,
  icon = path.."teleporter-technology.png",
  effects =
  {
    {
      type = "unlock-recipe",
      recipe = name
    }
  },
  unit =
  {
    count = 500,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"chemical-science-pack", 1},
    },
    time = 30
  },
  prerequisites = {"advanced-circuit", "battery"},
  order = "y-a"
}

local hotkey_name = require"shared".hotkeys.focus_search
local hotkey =
{
  type = "custom-input",
  name = hotkey_name,
  linked_game_control = "focus-search",
  key_sequence = "Control + F"
}

data:extend
{
  teleporter,
  teleporter_item,
  teleporter_explosion,
  teleporter_explosion_2,
  recipe,
  technology,
  hotkey,
  sticker
}
