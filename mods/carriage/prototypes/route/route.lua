require "route_pictures"

local route_8shifts_vector = function(dx, dy)
  return
  {
    { dx,  dy },
    { -dx, dy },
    { -dy, dx },
    { -dy, -dx },
    { -dx, -dy },
    { dx,  -dy },
    { dy,  -dx },
    { dy,  dx }
  }
end

local function invincible()
  return {
    {
      type = "physical",
      percent = 100
    },
    {
      type = "explosion",
      percent = 100
    },
    {
      type = "acid",
      percent = 100
    },
    {
      type = "fire",
      percent = 100
    }
  }
end

local function route_collision_mask()
  return { layers = { object = true, rail = true } }
end


-- mapcolor doesn't work yet on rails for some reason
data:extend({
  {
    type = "legacy-straight-rail",
    name = "legacy-straight-route",
    icon = GRAPHICSPATH .. "icon/route.png",
    icon_size = 64,
    flags = { "placeable-neutral", "player-creation", "building-direction-8-way" },
    hidden_in_factoriopedia = true,
    resistances = invincible(),
    minable = { mining_time = 0.2 },
    max_health = 200,
    corpse = nil,
    collision_box = { { -1.01, -0.95 }, { 1.01, 0.95 } },
    selection_box = { { -1.7, -0.8 }, { 1.7, 0.8 } },
    collision_mask = route_collision_mask(),
    tile_buildability_rules = {
      {
        area = { { -0.95, -0.95 }, { 0.95, 0.95 } },
        required_tiles = { layers = { ground_tile = true } },
        remove_on_collision = true
      }
    },
    pictures = legacy_route_pictures("straight_rail"),
    placeable_by = { item = "route", count = 1 },
    localised_description = { "item-description.route" },
  },
  {
    type = "legacy-curved-rail",
    name = "legacy-curved-route",
    icon = GRAPHICSPATH .. "icon/route.png",
    icon_size = 64,
    flags = { "placeable-neutral", "player-creation", "building-direction-8-way" },
    hidden_in_factoriopedia = true,
    resistances = invincible(),
    minable = { mining_time = 0.2 },
    max_health = 200,
    corpse = nil,
    collision_box = { { -1, -2 }, { 1, 3.1 } },
    selection_box = { { -1.7, -0.8 }, { 1.7, 0.8 } },
    collision_mask = route_collision_mask(),
    tile_buildability_rules = {
      {
        area = { { -0.95, -1.95 }, { 0.95, 2.95 } },
        required_tiles = { layers = { ground_tile = true } },
        remove_on_collision = true
      }
    },
    pictures = legacy_route_pictures("curved_rail"),
    placeable_by = { item = "route", count = 1 },
    localised_description = { "item-description.route" },
  },
  {
    type = "straight-rail",
    name = "straight-route",
    order = "a[ground-rail]-a[straight-rail]",
    icon = GRAPHICSPATH .. "icon/route.png",
    collision_box = { { -1, -1 }, { 1, 1 } },     -- has custommly generated box, but the prototype needs something that is used to generate building smokes
    collision_mask = route_collision_mask(),
    tile_buildability_rules = {
      {
        area = { { -0.95, -0.95 }, { 0.95, 0.95 } },
        required_tiles = { layers = { ground_tile = true } },
        remove_on_collision = true
      }
    },
    flags = { "placeable-neutral", "player-creation", "building-direction-8-way" },
    resistances = invincible(),
    minable = { mining_time = 0.2 },
    max_health = 200,
    corpse = nil,
    selection_box = { { -1.7, -0.8 }, { 1.7, 0.8 } },
    pictures = new_route_pictures("straight"),
    placeable_by = { item = "route", count = 1 },
    extra_planner_goal_penalty = -4,
    factoriopedia_alternative = "straight-route"
  },
  {
    type = "half-diagonal-rail",
    name = "half-diagonal-route",
    order = "a[ground-rail]-b[half-diagonal-rail]",
    deconstruction_alternative = "straight-route",
    icon = GRAPHICSPATH .. "icon/route.png",
    collision_box = { { -0.75, -2.236 }, { 0.75, 2.236 } },     -- has custommly generated box, but the prototype needs something that is used to generate building smokes
    collision_mask = route_collision_mask(),
    tile_buildability_rules = {
      {
        area = { { -0.75, -2.236 }, { 0.75, 2.236 } },
        required_tiles = { layers = { ground_tile = true } },
        remove_on_collision = true
      }
    },
    tile_height = 2,
    extra_planner_goal_penalty = -4,
    flags = { "placeable-neutral", "player-creation", "building-direction-8-way" },
    resistances = invincible(),
    minable = { mining_time = 0.2 },
    max_health = 200,
    selection_box = { { -1.7, -0.8 }, { 1.7, 0.8 } },
    pictures = new_route_pictures("half-diagonal"),
    placeable_by = { item = "route", count = 1 },
    extra_planner_penalty = 0,
    factoriopedia_alternative = "straight-route"
  },
  {
    type = "curved-rail-a",
    name = "curved-route-a",
    order = "a[ground-rail]-c[curved-rail-a]",
    deconstruction_alternative = "straight-route",
    icon = GRAPHICSPATH .. "icon/route.png",
    collision_box = { { -0.75, -2.516 }, { 0.75, 2.516 } },     -- has custommly generated box, but the prototype needs something that is used to generate building smokes
    collision_mask = route_collision_mask(),
    tile_buildability_rules = {
      {
        area = { { -0.75, -2.516 }, { 0.75, 2.516 } },
        required_tiles = { layers = { ground_tile = true } },
        remove_on_collision = true
      }
    },
    flags = { "placeable-neutral", "player-creation", "building-direction-8-way" },
    resistances = invincible(),
    minable = { mining_time = 0.2 },
    max_health = 200,
    selection_box = { { -1.7, -0.8 }, { 1.7, 0.8 } },
    pictures = new_route_pictures("curved-a"),
    placeable_by = { item = "route", count = 2 },
    extra_planner_penalty = 0.5,
    deconstruction_marker_positions = route_8shifts_vector(-0.248, -0.533),
    factoriopedia_alternative = "straight-route"
  },
  {
    type = "curved-rail-b",
    name = "curved-route-b",
    order = "a[ground-rail]-d[curved-rail-b]",
    deconstruction_alternative = "straight-route",
    icon = GRAPHICSPATH .. "icon/route.png",
    collision_box = { { -0.75, -2.441 }, { 0.75, 2.441 } },     -- has custommly generated box, but the prototype needs something that is used to generate building smokes
    collision_mask = route_collision_mask(),
    tile_buildability_rules = {
      {
        area = { { -0.75, -2.441 }, { 0.75, 2.441 } },
        required_tiles = { layers = { ground_tile = true } },
        remove_on_collision = true
      }
    },
    flags = { "placeable-neutral", "player-creation", "building-direction-8-way" },
    resistances = invincible(),
    minable = { mining_time = 0.2 },
    max_health = 200,
    selection_box = { { -1.7, -0.8 }, { 1.7, 0.8 } },
    pictures = new_route_pictures("curved-b"),
    placeable_by = { item = "route", count = 2 },
    extra_planner_penalty = 0.5,
    deconstruction_marker_positions = route_8shifts_vector(-0.309, -0.155),
    factoriopedia_alternative = "straight-route"
  },
})
