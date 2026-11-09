if not settings.startup["sp-enable-dock"].value then
  return
end
local item_sounds = require("__base__.prototypes.item_sounds")
local sounds = require("__base__.prototypes.entity.sounds")
local hit_effects = require ("__base__.prototypes.entity.hit-effects")

local circuit_connections = require "circuit-connections"

data:extend{
  {
    type = "item",
    name = "sp-spidertron-dock",
    icon = "__SpidertronPatrols__/graphics/icons/spidertron-dock.png",
    icon_size = 64,
    stack_size = 50,
    place_result = "sp-spidertron-dock",
    order = "b[personal-transport]-c[spidertron]-c[[dock]",  -- '[[' ensures that it is ordered before all spidertron-logistics items
    subgroup = "transport",
    inventory_move_sound = item_sounds.metal_chest_inventory_move,
    pick_sound = item_sounds.metal_chest_inventory_pickup,
    drop_sound = item_sounds.metal_chest_inventory_move,
  },
  {
    type = "recipe",
    name = "sp-spidertron-dock",
    ingredients = {
      {type="item", name="steel-chest", amount=4},
      {type="item", name="bulk-inserter", amount=4},
    },
    energy_required = 4,
    results = {{type="item", name="sp-spidertron-dock", amount=1}},
    enabled = false
  },
  {
    type = "proxy-container",
    name = "sp-spidertron-dock",
    localised_name = {"entity-name.sp-spidertron-dock", SPIDERTRON_NAME_CAPITALISED},
    localised_description = {"entity-description.sp-spidertron-dock", SPIDERTRON_NAME},
    icon = "__SpidertronPatrols__/graphics/icons/spidertron-dock.png",
    icon_size = 64,
    picture = {
      layers = {
        {
          filename = "__SpidertronPatrols__/graphics/entity/spidertron-dock-closed.png",
          height = 199,
          width = 207,
          priority = "high",
          scale = 0.5,
        },
        {
          draw_as_shadow = true,
          filename = "__base__/graphics/entity/artillery-turret/artillery-turret-base-shadow.png",
          height = 149,
          width = 277,
          shift = {0.5625, 0.5},
          priority = "high",
          scale = 0.5,
        },
      }
    },
    direction_count = 1,
    circuit_connector = {circuit_connector_definitions["artillery-turret"]},
    circuit_wire_max_distance = default_circuit_wire_max_distance,
    max_health = 600,
    minable = {mining_time = 1, result = "sp-spidertron-dock"},
    placeable_by = {item = "sp-spidertron-dock", count = 1},
    corpse = "artillery-turret-remnants",
    dying_explosion = "assembling-machine-3-explosion",  -- artillery-turret-explosion is too tall
    damaged_trigger_effect = hit_effects.entity(),
    vehicle_impact_sound = sounds.generic_impact,
    close_sound = {
      filename = "__base__/sound/metallic-chest-close.ogg",
      volume = 0.6
    },
    open_sound = {
      filename = "__base__/sound/metallic-chest-open.ogg",
      volume = 0.6
    },
    collision_box = {{-1.1, -1.1}, {1.1, 1.1}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    tile_width = 3,
    tile_height = 3,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    ---@diagnostic disable-next-line: assign-type-mismatch
    squeak_behaviour = false,  -- Stops squeak through from further reducing the collision box
    ---@diagnostic disable-next-line: assign-type-mismatch
    se_allow_in_space = true,
  },
  {
    type = "animation",
    name = "sp-spidertron-dock-port-animation",
    filename = "__SpidertronPatrols__/graphics/entity/dock-port-animation.png",
    priority = "medium",
    width = 97,
    height = 79,
    frame_count = 16,
    animation_speed = 0.5,
    --shift = {0.015625, -0.890625},
    scale = 0.5,
  },
  {
    type = "sprite",
    name = "sp-spidertron-dock-port-open",
    filename = "__SpidertronPatrols__/graphics/entity/dock-port-open.png",
    priority = "medium",
    width = 97,
    height = 79,
    scale = 0.5,
  }
}

-- TODO sounds
--[[
  sounds.roboport_door_open,
  sounds.roboport_door_close
]]
