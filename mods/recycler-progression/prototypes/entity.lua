local util = require("util")
local sounds = require("__base__.prototypes.entity.sounds")
local recycler_pictures = require("__quality__.prototypes.entity.recycler-pictures")
require("__core__.lualib.circuit-connector-sprites")
require("__core__.lualib.circuit-connector-generated-definitions")

-- Reusable working sound referencing vanilla recycler audio assets
local function recycler_working_sound()
  return {
    sound = {filename = "__quality__/sound/recycler/recycler-loop.ogg", volume = 0.7},
    sound_accents = {
      {sound = {variations = sound_variations("__quality__/sound/recycler/recycler-jaw-move", 5, 0.45), audible_distance_modifier = 0.2}, frame = 14},
      {sound = {variations = sound_variations("__quality__/sound/recycler/recycler-vox", 5, 0.2), audible_distance_modifier = 0.3}, frame = 20},
      {sound = {variations = sound_variations("__quality__/sound/recycler/recycler-mechanic", 3, 0.3), audible_distance_modifier = 0.3}, frame = 45},
      {sound = {variations = sound_variations("__quality__/sound/recycler/recycler-jaw-move", 5, 0.45), audible_distance_modifier = 0.2}, frame = 60},
      {sound = {variations = sound_variations("__quality__/sound/recycler/recycler-trash", 5, 0.6), audible_distance_modifier = 0.3}, frame = 61},
      {sound = {variations = sound_variations("__quality__/sound/recycler/recycler-jaw-shut", 6, 0.3), audible_distance_modifier = 0.6}, frame = 63},
    },
    max_sounds_per_prototype = 2,
    fade_in_ticks = 4,
    fade_out_ticks = 20
  }
end

-- Shared resistances identical to vanilla recycler
local recycler_resistances = {
  {type = "fire", percent = 80}
}

-- All recycler variants share the same physical footprint as the vanilla recycler
local collision_box = {{-0.7, -1.7}, {0.7, 1.7}}
local selection_box = {{-0.9, -1.85}, {0.9, 1.85}}

-- ---------------------------------------------------------------------------
-- Overlay shift tables
--
-- Each entry is util.by_pixel(x, y) for that direction.
-- Positive x = right, positive y = down (Factorio screen space).
-- All tiers share the same base sprite, so shifts are identical across tiers.
-- Collision Box:
--   Links:  -0.7 × 32 = -22 px
--   Rechts: +0.7 × 32 = +22 px
--   Oben:   -1.7 × 32 = -54 px
--   Unten:  +1.7 × 32 = +54 px
--   → Gesamt: 44 × 108 px ab Mitte
-- ---------------------------------------------------------------------------
local overlay_shifts = {
  N = util.by_pixel( 16.5, -75.5),
  E = util.by_pixel( 42.0, -20.5),
  S = util.by_pixel(-16,  12.5),
  W = util.by_pixel(-42.5, -44.5),
}

local overlay_shifts_flipped = {
  N = util.by_pixel(-16.5, -75.5),
  E = util.by_pixel( 43, -44.5),
  S = util.by_pixel( 15.5,  12.5),
  W = util.by_pixel(-42, -21),
}

-- ---------------------------------------------------------------------------
-- Overlay helper
--
-- Builds a working_visualisation entry with always_draw = true.
-- Each direction uses its own shift from the tables above.
--
-- Sprite files expected (one PNG per direction):
--   graphics/entity/<tier>/overlay-N.png   etc.
--   graphics/entity/<tier>/overlay-flipped-N.png   etc.
-- ---------------------------------------------------------------------------
local function make_overlay_vis(tier, flipped)
  local prefix = flipped and "overlay-flipped" or "overlay"
  local shifts = flipped and overlay_shifts_flipped or overlay_shifts
  local base   = "__recycler-progression__/graphics/entity/" .. tier .. "/"

  local function dir_sprite(direction)
    return {
      filename    = base .. prefix .. "-" .. direction .. ".png",
      frame_count = 1,
      width       = 26,
      height      = 26,
      shift       = shifts[direction],
      scale       = 0.5,
    }
  end

  return {
    always_draw     = true,
    north_animation = dir_sprite("N"),
    east_animation  = dir_sprite("E"),
    south_animation = dir_sprite("S"),
    west_animation  = dir_sprite("W"),
  }
end

-- Deepcopies the vanilla graphics_set and injects the tier overlay.
local function make_graphics_set(tier)
  local gs = util.table.deepcopy(recycler_pictures.graphics_set)
  if not gs.working_visualisations then
    gs.working_visualisations = {}
  end
  table.insert(gs.working_visualisations, make_overlay_vis(tier, false))
  return gs
end

-- Same for the flipped variant.
local function make_graphics_set_flipped(tier)
  local gs = util.table.deepcopy(recycler_pictures.graphics_set_flipped)
  if not gs.working_visualisations then
    gs.working_visualisations = {}
  end
  table.insert(gs.working_visualisations, make_overlay_vis(tier, true))
  return gs
end

-- ---------------------------------------------------------------------------

data:extend({

  -- ============================================================
  -- Recycler 1  (AM1-tier: crafting_speed 0.125, 0 module slots)
  -- ============================================================
  {
    type = "furnace",
    name = "recycler-1",
    icon = "__recycler-progression__/graphics/icons/recycler-1.png",
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    fast_transfer_modules_into_module_slots_only = true,
    minable = {mining_time = 0.2, result = "recycler-1"},
    circuit_wire_max_distance = furnace_circuit_wire_max_distance,
    circuit_connector = circuit_connector_definitions["recycler"],
    circuit_connector_flipped = circuit_connector_definitions["recycler-flipped"],
    max_health = 200,
    fast_replaceable_group = "recycler",
    next_upgrade = "recycler-2",
    vector_to_place_result = {-0.5, -2.3},
    dying_explosion = "recycler-explosion",
    corpse = "recycler-remnants",
    impact_category = "metal",
    working_sound = recycler_working_sound(),
    open_sound = sounds.metal_large_open,
    close_sound = sounds.metal_large_close,
    resistances = recycler_resistances,
    collision_box = collision_box,
    selection_box = selection_box,
    crafting_categories = {"recycling", "recycling-or-hand-crafting"},
    result_inventory_size = 12,
    energy_usage = "45kW",
    crafting_speed = 0.125,
    source_inventory_size = 1,
    custom_input_slot_tooltip_key = "recycler-input-slot-tooltip",
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = {pollution = 0.5}
    },
    module_slots = 0,
    icon_draw_specification = {shift = {0, -0.55}},
    cant_insert_at_source_message_key = "inventory-restriction.cant-be-recycled",
    use_mirroring        = true,
    graphics_set         = make_graphics_set("recycler-1"),
    graphics_set_flipped = make_graphics_set_flipped("recycler-1"),
  },

  -- ============================================================
  -- Recycler 2  (AM2-tier: crafting_speed 0.25, 2 module slots)
  -- ============================================================
  {
    type = "furnace",
    name = "recycler-2",
    icon = "__recycler-progression__/graphics/icons/recycler-2.png",
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    fast_transfer_modules_into_module_slots_only = true,
    minable = {mining_time = 0.2, result = "recycler-2"},
    circuit_wire_max_distance = furnace_circuit_wire_max_distance,
    circuit_connector = circuit_connector_definitions["recycler"],
    circuit_connector_flipped = circuit_connector_definitions["recycler-flipped"],
    max_health = 250,
    fast_replaceable_group = "recycler",
    next_upgrade = "recycler-3",
    vector_to_place_result = {-0.5, -2.3},
    dying_explosion = "recycler-explosion",
    corpse = "recycler-remnants",
    impact_category = "metal",
    working_sound = recycler_working_sound(),
    open_sound = sounds.metal_large_open,
    close_sound = sounds.metal_large_close,
    resistances = recycler_resistances,
    collision_box = collision_box,
    selection_box = selection_box,
    crafting_categories = {"recycling", "recycling-or-hand-crafting"},
    result_inventory_size = 12,
    energy_usage = "90kW",
    crafting_speed = 0.25,
    source_inventory_size = 1,
    custom_input_slot_tooltip_key = "recycler-input-slot-tooltip",
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = {pollution = 1}
    },
    module_slots = 2,
    allowed_effects = {"consumption", "speed", "pollution", "quality"},
    icon_draw_specification = {shift = {0, -0.55}},
    icons_positioning = {
      {inventory_index = defines.inventory.furnace_modules, shift = {0, 0.2}}
    },
    cant_insert_at_source_message_key = "inventory-restriction.cant-be-recycled",
    use_mirroring        = true,
    graphics_set         = make_graphics_set("recycler-2"),
    graphics_set_flipped = make_graphics_set_flipped("recycler-2"),
  },

  -- ============================================================
  -- Recycler 3  (AM3-tier: crafting_speed 0.375, 3 module slots)
  -- ============================================================
  {
    type = "furnace",
    name = "recycler-3",
    icon = "__recycler-progression__/graphics/icons/recycler-3.png",
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    fast_transfer_modules_into_module_slots_only = true,
    minable = {mining_time = 0.2, result = "recycler-3"},
    circuit_wire_max_distance = furnace_circuit_wire_max_distance,
    circuit_connector = circuit_connector_definitions["recycler"],
    circuit_connector_flipped = circuit_connector_definitions["recycler-flipped"],
    max_health = 300,
    fast_replaceable_group = "recycler",
    next_upgrade = "recycler",
    vector_to_place_result = {-0.5, -2.3},
    dying_explosion = "recycler-explosion",
    corpse = "recycler-remnants",
    impact_category = "metal",
    working_sound = recycler_working_sound(),
    open_sound = sounds.metal_large_open,
    close_sound = sounds.metal_large_close,
    resistances = recycler_resistances,
    collision_box = collision_box,
    selection_box = selection_box,
    crafting_categories = {"recycling", "recycling-or-hand-crafting"},
    result_inventory_size = 12,
    energy_usage = "135kW",
    crafting_speed = 0.375,
    source_inventory_size = 1,
    custom_input_slot_tooltip_key = "recycler-input-slot-tooltip",
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = {pollution = 1.5}
    },
    module_slots = 3,
    allowed_effects = {"consumption", "speed", "pollution", "quality"},
    icon_draw_specification = {shift = {0, -0.55}},
    icons_positioning = {
      {inventory_index = defines.inventory.furnace_modules, shift = {0, 0.2}}
    },
    cant_insert_at_source_message_key = "inventory-restriction.cant-be-recycled",
    use_mirroring        = true,
    graphics_set         = make_graphics_set("recycler-3"),
    graphics_set_flipped = make_graphics_set_flipped("recycler-3"),
  },

})
