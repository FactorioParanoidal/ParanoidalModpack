-- Paranoidal 9.0.0: the 1.1 tile transition templates were removed. In 2.x their field "transition" does
-- not exist and ground_to_out_of_map_transition is nil, so the crater tiles always used the transitions
-- inherited from nuclear-ground; the sand layer overrides were rewritten by Alien Biomes later anyway.
local nuclear_shallow = table.deepcopy(data.raw["tile"]["nuclear-ground"])
nuclear_shallow.name = "nuclear-shallow"
nuclear_shallow.collision_mask =
  {layers = {
    -- Player collides only with player-layer and train-layer,
    -- this can have any tile collision masks it doesn't matter for being walkable by player but not buildable.
    -- Having water-tile prevents placing paths, ground-tile prevents placing landfill.
    -- Not sure what other side effects could different combinations of tile masks cause.
    water_tile = true,
    --"ground-tile",
    resource = true,
    item = true,
    object = true,
    doodad = true}
  }
nuclear_shallow.transition_merges_with_tile = "water"
nuclear_shallow.walking_speed_modifier = 0.7
nuclear_shallow.layer = 10
nuclear_shallow.map_color={r=46, g=38, b=33}
nuclear_shallow.empty_transitions = false

data:extend{nuclear_shallow}

local nuclear_crater = table.deepcopy(data.raw["tile"]["nuclear-ground"])
nuclear_crater.name = "nuclear-crater"
nuclear_crater.collision_mask =
  {layers = {
    water_tile = true,
    resource = true,
    item = true,
    player = true,
    doodad = true}
  }
nuclear_crater.transition_merges_with_tile = "water"
nuclear_crater.layer = 9
nuclear_crater.map_color={r=43, g=35, b=31}
nuclear_shallow.empty_transitions = false

data:extend{nuclear_crater}

local nuclear_shallow_water_in_crater = table.deepcopy(data.raw["tile"]["water-mud"])
nuclear_shallow_water_in_crater.name = "nuclear-crater-shallow-fill"
nuclear_shallow_water_in_crater.walking_speed_modifier = 1
nuclear_shallow_water_in_crater.autoplace = nil
nuclear_shallow_water_in_crater.collision_mask =
  {layers = {
    water_tile = true,
    resource = true,
    item = true,
    player = true,
    doodad = true}
  }

data:extend{nuclear_shallow_water_in_crater}



local nuclear_deep = table.deepcopy(data.raw["tile"]["nuclear-ground"])
nuclear_deep.name = "nuclear-deep"
nuclear_deep.collision_mask =
  {layers = {
    water_tile = true,
    resource = true,
    item = true,
    player = true,
    doodad = true}
  }
nuclear_deep.transition_merges_with_tile = "water"
nuclear_deep.layer = 8
nuclear_deep.map_color={r=39, g=31, b=28}
nuclear_deep.transitions = nil;

data:extend{nuclear_deep}


local nuclear_shallow_water_in_deep = table.deepcopy(data.raw["tile"]["water-mud"])
nuclear_shallow_water_in_deep.name = "nuclear-deep-shallow-fill"
nuclear_shallow_water_in_deep.autoplace = nil
nuclear_shallow_water_in_deep.walking_speed_modifier = 1
nuclear_shallow_water_in_deep.collision_mask =
  {layers = {
    water_tile = true,
    resource = true,
    item = true,
    player = true,
    doodad = true}
  }
data:extend{nuclear_shallow_water_in_deep}

local nuclear_water_in_deep = table.deepcopy(data.raw["tile"]["water"])
nuclear_water_in_deep.name = "nuclear-deep-fill"
nuclear_water_in_deep.autoplace = nil
nuclear_water_in_deep.collision_mask =
  {layers = {
    water_tile = true,
    resource = true,
    item = true,
    player = true,
    doodad = true}
  }
data:extend{nuclear_water_in_deep}

local nuclear_high = table.deepcopy(data.raw["tile"]["nuclear-ground"])
nuclear_high.name = "nuclear-high"
nuclear_high.minable = {mining_time = 0.1, result = "stone"}
nuclear_high.can_be_part_of_blueprint = true
nuclear_high.collision_mask =
  {layers = {
    -- Player collides only with player-layer and train-layer,
    -- this can have any tile collision masks it doesn't matter for being walkable by player but not buildable.
    -- Having water-tile prevents placing paths, ground-tile prevents placing landfill.
    -- Not sure what other side effects could different combinations of tile masks cause.
    ground_tile = true,
    item = true,
    player = true,
    object = true,
    doodad = true}
  }
nuclear_high.transition_merges_with_tile = "water"
nuclear_high.layer = 128
nuclear_high.map_color={r=53, g=43, b=39}
nuclear_shallow.empty_transitions = false

data:extend{nuclear_high}


data:extend{{
  type = "item",
  name = "nuclear-crater-mound",
  icon = "__base__/graphics/icons/stone.png",
  icon_size = 64, icon_mipmaps = 4,
  subgroup = "terrain",
  order = "c[nuclear-crater-mound]",
  stack_size = 100,
  place_as_tile =
  {
    result = "nuclear-high",
    condition_size = 6,
    condition =
    {
      layers = {
      water_tile = true,
      ground_tile = true,
      item = true,
      player = true,
      object = true,
      doodad = true}
    }
  }
}}
data.raw["tile"]["nuclear-deep"].allowed_neighbors = {};
data.raw["tile"]["nuclear-deep-shallow-fill"].allowed_neighbors = {};
data.raw["tile"]["nuclear-deep-fill"].allowed_neighbors = {};
data.raw["tile"]["nuclear-crater"].allowed_neighbors = {};
data.raw["tile"]["nuclear-crater-shallow-fill"].allowed_neighbors = {};
data.raw["tile"]["nuclear-shallow"].allowed_neighbors = {};
