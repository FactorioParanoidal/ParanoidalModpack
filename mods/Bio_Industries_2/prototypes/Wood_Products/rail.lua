require("prototypes.Wood_Products.rail-pictures-wood")

local BioInd = require('common')('Bio_Industries_2')
local ICONPATH_E = BioInd.modRoot .. "/graphics/icons/entity/"
local item_sounds = require("__base__.prototypes.item_sounds")
local hit_effects = require("__base__.prototypes.entity.hit-effects")
local tile_sounds = require("__base__.prototypes.tile.tile-sounds")

data:extend({
  ---- ITEM
  {
    type = "rail-planner",
    name = "bi-rail-wood",
    icons = { { icon = ICONPATH_E .. "rail-wood.png", icon_size = 64, } },
    localised_name = { "item-name.bi-rail-wood" },
    subgroup = "train-transport",
    order = "a[rail]-0[rail]",
    inventory_move_sound = item_sounds.train_inventory_move,
    pick_sound = item_sounds.train_inventory_pickup,
    drop_sound = item_sounds.train_inventory_move,
    place_result = "bi-straight-rail-wood",
    stack_size = 100,
    rails = {
      "bi-straight-rail-wood",
      "bi-curved-rail-a-wood",
      "bi-curved-rail-b-wood",
      "bi-half-diagonal-rail-wood"
    },
    manual_length_limit = 22.5   -- 2*(Curved-A) + 2*(Curved-B) + their planner penalty + margin
  },

  ---- Recipe
  {
    type = "recipe",
    name = "bi-rail-wood",
    localised_name = { "entity-name.bi-rail-wood" },
    localised_description = { "entity-description.bi-rail-wood" },
    icons = { { icon = ICONPATH_E .. "rail-wood.png", icon_size = 64, } },
    enabled = false,
    ingredients = {
      { type = "item", name = "wood",        amount = 6 },
      { type = "item", name = "stone",       amount = 1 },
      { type = "item", name = "steel-plate", amount = 1 },
      { type = "item", name = "iron-stick",  amount = 1 },
    },
    results = { { type = "item", name = "bi-rail-wood", amount = 2 } },
    main_product = "",
    requester_paste_multiplier = 4,
    --~ always_show_made_in = true,
    --~ allow_decomposition = false,
    allow_as_intermediate = false,   -- Added for 0.18.34/1.1.4
    always_show_made_in = false,     -- Changed for 0.18.34/1.1.4
    allow_decomposition = true,      -- Changed for 0.18.34/1.1.4
    subgroup = "transport",
    order = "a[train-system]-a[rail]",
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries",
  },
  {
    type = "recipe",
    name = "bi-rail-wood-to-concrete",
    icons = { { icon = ICONPATH_E .. "rail-wood-to-concrete.png", icon_size = 64, } },
    enabled = false,
    ingredients = {
      { type = "item", name = "bi-rail-wood", amount = 2 },
      { type = "item", name = "stone-brick",  amount = 6 },

    },
    results = { { type = "item", name = "rail", amount = 2 } }
  },


  --- Entity

  {
    type = "straight-rail",
    name = "bi-straight-rail-wood",
    order = "a[ground-rail]-a[bi-straight-rail-wood]",
    icon = ICONPATH_E .. "straight-rail-wood.png",
    localised_name = { "entity-name.bi-straight-rail-wood" },
    collision_box = { { -1, -1 }, { 1, 1 } },   -- has custommly generated box, but the prototype needs something that is used to generate building smokes
    flags = { "placeable-neutral", "player-creation", "building-direction-8-way" },
    minable = { mining_time = 0.2, result = "bi-rail-wood", count = 1 },
    max_health = 200,
    corpse = "straight-rail-remnants",
    dying_explosion = {
      name = "rail-explosion"
    },
    resistances = {
      {
        type = "fire",
        percent = 100
      },
      {
        type = "acid",
        percent = 80
      }
    },
    -- collision box is hardcoded for rails as to avoid unexpected changes in the way rail blocks are merged
    selection_box = { { -1.7, -0.8 }, { 1.7, 0.8 } },
    damaged_trigger_effect = hit_effects.wall(),
    pictures = new_rail_pictures_wood("straight"),
    placeable_by = { item = "bi-rail-wood", count = 1 },
    walking_sound = tile_sounds.walking.rails,
    extra_planner_goal_penalty = -4,
    factoriopedia_alternative = "straight-rail",
    -- for upgrade planer (fast rail change wood/iron)
    next_upgrade = "straight-rail",
    fast_replaceable_group = "straight-rail",
  },

  {
    type = "half-diagonal-rail",
    name = "bi-half-diagonal-rail-wood",
    order = "a[ground-rail]-b[bi-half-diagonal-rail-wood]",
    deconstruction_alternative = "bi-straight-rail-wood",
    icon = ICONPATH_E .. "curved-rail-wood.png",
    localised_name = { "entity-name.bi-half-diagonal-rail-wood" },
    collision_box = { { -0.75, -2.236 }, { 0.75, 2.236 } },   -- has custommly generated box, but the prototype needs something that is used to generate building smokes
    tile_height = 2,
    extra_planner_goal_penalty = -4,
    flags = { "placeable-neutral", "player-creation", "building-direction-8-way" },
    minable = { mining_time = 0.2, result = "bi-rail-wood", count = 2 },
    max_health = 200,
    corpse = "half-diagonal-rail-remnants",
    dying_explosion = {
      {
        name = "rail-explosion",
        offset = { 0.9, 2.2 }
      },
      {
        name = "rail-explosion"
      },
      {
        name = "rail-explosion",
        offset = { -1.2, -2 }
      }
    },
    resistances = {
      {
        type = "fire",
        percent = 100
      },
      {
        type = "acid",
        percent = 80
      }
    },
    -- collision box is hardcoded for rails as to avoid unexpected changes in the way rail blocks are merged
    selection_box = { { -1.7, -0.8 }, { 1.7, 0.8 } },
    damaged_trigger_effect = hit_effects.wall(),
    pictures = new_rail_pictures_wood("half-diagonal"),
    placeable_by = { item = "bi-rail-wood", count = 2 },
    walking_sound = tile_sounds.walking.rails,
    extra_planner_penalty = 0,
    factoriopedia_alternative = "straight-rail",
    -- for upgrade planer (fast rail change wood/iron)
    next_upgrade = "half-diagonal-rail",
    fast_replaceable_group = "half-diagonal-rail",
  },
  {
    type = "curved-rail-a",
    name = "bi-curved-rail-a-wood",
    order = "a[ground-rail]-c[bi-curved-rail-a-wood]",
    deconstruction_alternative = "bi-straight-rail-wood",
    icon = ICONPATH_E .. "curved-rail-wood.png",
    localised_name = { "entity-name.bi-curved-rail-a-wood" },
    collision_box = { { -0.75, -2.516 }, { 0.75, 2.516 } },   -- has custommly generated box, but the prototype needs something that is used to generate building smokes
    flags = { "placeable-neutral", "player-creation", "building-direction-8-way" },
    minable = { mining_time = 0.2, result = "bi-rail-wood", count = 3 },
    max_health = 200,
    corpse = "curved-rail-a-remnants",
    dying_explosion = {
      {
        name = "rail-explosion",
        offset = { 0.9, 2.2 }
      },
      {
        name = "rail-explosion"
      },
      {
        name = "rail-explosion",
        offset = { -1.2, -2 }
      }
    },
    resistances = {
      {
        type = "fire",
        percent = 100
      },
      {
        type = "acid",
        percent = 80
      }
    },
    -- collision box is hardcoded for rails as to avoid unexpected changes in the way rail blocks are merged
    selection_box = { { -1.7, -0.8 }, { 1.7, 0.8 } },
    damaged_trigger_effect = hit_effects.wall(),
    pictures = new_rail_pictures_wood("curved-a"),
    placeable_by = { item = "bi-rail-wood", count = 3 },
    walking_sound = tile_sounds.walking.rails,
    extra_planner_penalty = 0.5,
    deconstruction_marker_positions = rail_8shifts_vector(-0.248, -0.533),
    factoriopedia_alternative = "straight-rail",
    -- for upgrade planer (fast rail change wood/iron)
    next_upgrade = "curved-rail-a",
    fast_replaceable_group = "curved-rail-a",
  },
  {
    type = "curved-rail-b",
    name = "bi-curved-rail-b-wood",
    order = "a[ground-rail]-d[bi-curved-rail-b-wood]",
    deconstruction_alternative = "bi-straight-rail-wood",
    icon = ICONPATH_E .. "curved-rail-wood.png",
    localised_name = { "entity-name.bi-curved-rail-b-wood" },
    collision_box = { { -0.75, -2.441 }, { 0.75, 2.441 } },   -- has custommly generated box, but the prototype needs something that is used to generate building smokes
    flags = { "placeable-neutral", "player-creation", "building-direction-8-way" },
    minable = { mining_time = 0.2, result = "bi-rail-wood", count = 3 },
    max_health = 200,
    corpse = "curved-rail-b-remnants",
    dying_explosion = {
      {
        name = "rail-explosion",
        offset = { 0.9, 2.2 }
      },
      {
        name = "rail-explosion"
      },
      {
        name = "rail-explosion",
        offset = { -1.2, -2 }
      }
    },
    resistances = {
      {
        type = "fire",
        percent = 100
      },
      {
        type = "acid",
        percent = 80
      }
    },
    -- collision box is hardcoded for rails as to avoid unexpected changes in the way rail blocks are merged
    selection_box = { { -1.7, -0.8 }, { 1.7, 0.8 } },
    damaged_trigger_effect = hit_effects.wall(),
    pictures = new_rail_pictures_wood("curved-b"),
    placeable_by = { item = "bi-rail-wood", count = 3 },
    walking_sound = tile_sounds.walking.rails,
    extra_planner_penalty = 0.5,
    deconstruction_marker_positions = rail_8shifts_vector(-0.309, -0.155),
    factoriopedia_alternative = "straight-rail",
    -- for upgrade planer (fast rail change wood/iron)
    next_upgrade = "curved-rail-b",
    fast_replaceable_group = "curved-rail-b",
  },
})
