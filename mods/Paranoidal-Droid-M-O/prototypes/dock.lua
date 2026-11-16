local shared = require("shared")
local hit_effects = require("__base__.prototypes.entity.hit-effects")
local item_sounds = require("__base__.prototypes.item_sounds")

-- The Sweepbot's charging station (Klaudia's renders, recoloured): one 3x3 tile frame per direction at 64 px a tile, a
-- shadow half a tile wider on the right and a glow layer for its lamps. Shifted down so the base's front edge meets the
-- footprint's.
local path = shared.mod .. "/graphics/entity/droid-m-o-dock/"
local shifts = {north = {0, 0.13}, east = {0, 0.28}, south = {0, 0.13}, west = {0, 0.28}}
local max_charging_power = shared.charging_power * (1 + shared.charging_bonus * shared.charging_levels)
local directions = {"north", "east", "south", "west"}

local function dock_picture(direction)
  local file = path .. "dock-" .. direction
  local shift = shifts[direction]
  return
  {
    layers =
    {
      {filename = file .. ".png", width = 192, height = 192, shift = shift, scale = 0.5},
      {filename = file .. "-shadow.png", width = 224, height = 192, shift = {shift[1] + 0.25, shift[2]}, scale = 0.5,
       draw_as_shadow = true},
      -- Its ready lamp and charge meter.
      {filename = file .. "-glow.png", width = 192, height = 192, shift = shift, scale = 0.5, draw_as_glow = true,
       blend_mode = "additive"}
    }
  }
end

local pictures = {}
-- The port's floor plate is drawn by the script under entities, so the parked bot is never drawn under it.
local ports = {}
for _, direction in pairs(directions) do
  pictures[direction] = dock_picture(direction)
  ports[#ports + 1] =
  {
    type = "sprite",
    name = shared.dock .. "-port-" .. direction,
    filename = path .. "port-" .. direction .. ".png",
    width = 192,
    height = 192,
    shift = shifts[direction],
    scale = 0.5
  }
end
data:extend(ports)

-- The sparks round the contacts while it charges him: the roboport's, smaller.
local sparks = table.deepcopy(data.raw.roboport.roboport.recharging_animation)
sparks.type = "animation"
sparks.name = shared.charging
sparks.scale = (sparks.scale or 1) * 0.6
data:extend{sparks}


data:extend
{
  {
    type = "electric-energy-interface",
    name = shared.dock,
    icon = shared.mod .. "/graphics/icons/droid-m-o-dock.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.2, result = shared.dock},
    max_health = 150,
    corpse = "small-remnants",
    dying_explosion = "accumulator-explosion",
    damaged_trigger_effect = hit_effects.entity(),
    impact_category = "metal",
    collision_box = {{-0.9, -0.4}, {0.9, 0.4}},
    selection_box = {{-1, -0.5}, {1, 0.5}},
    -- Over the bot parked on its port, so the whole dock can be mined, rotated and picked.
    selection_priority = 51,
    -- Leaves out the player layer, so the bot (and the player) can drive onto the port.
    collision_mask = {layers = {floor = true, object = true, meltable = true, water_tile = true, is_lower_object = true}},
    -- The port has to be on paved floor, where the bot can drive.
    tile_buildability_rules =
    {
      {area = {{0.05, -0.45}, {0.95, 0.45}}, colliding_tiles = {layers = {[shared.unpaved] = true}}}
    },
    gui_mode = "none",
    allow_copy_paste = false,
    -- The script takes what the bot charges from the buffer: half a second of it at the fastest research allows.
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      buffer_capacity = max_charging_power / 2 .. "J",
      input_flow_limit = max_charging_power .. "W",
      output_flow_limit = "0W"
    },
    energy_production = "0W",
    energy_usage = "0W",
    pictures = pictures,
    -- Marks the port while the dock is in the cursor: the plate itself is drawn by the script once it's built.
    radius_visualisation_specification =
    {
      sprite = {filename = path .. "port-marker.png", size = 64},
      distance = 0.5,
      offset = {0.5, 0},
      draw_in_cursor = true,
      draw_on_selection = false
    }
  },
  {
    type = "item",
    name = shared.dock,
    icon = shared.mod .. "/graphics/icons/droid-m-o-dock.png",
    subgroup = "logistic-network",
    order = "z[droid-m-o]",
    inventory_move_sound = item_sounds.roboport_inventory_move,
    pick_sound = item_sounds.roboport_inventory_pickup,
    drop_sound = item_sounds.roboport_inventory_move,
    place_result = shared.dock,
    stack_size = 10
  },
  {
    type = "recipe",
    name = shared.dock,
    enabled = false,
    energy_required = 5,
    ingredients =
    {
      -- data-updates.lua swaps in Bob's basic circuit board where it exists.
      {type = "item", name = "electronic-circuit", amount = 6},
      {type = "item", name = "iron-gear-wheel", amount = 8},
      {type = "item", name = "iron-plate", amount = 10},
      {type = "item", name = "copper-cable", amount = 6}
    },
    results = {{type = "item", name = shared.dock, amount = 1}}
  }
}
