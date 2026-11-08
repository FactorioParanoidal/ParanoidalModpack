local moshine_briefing =
{
  init_update_count = 200,
  planet = "moshine",
  mute_wind_sounds = false,
  init =
  [[
    require("__core__/lualib/story")
    game.simulation.camera_position = {0, 1.5}

    for x = -11, 10, 1 do
      for y = -4, 6 do
        game.surfaces[1].set_tiles{{position = {x, y}, name = "moshine-sand"}}
      end
    end

    for x = -11, 10, 1 do
      for y = 1, 6 do
        game.surfaces[1].set_tiles{{position = {x, y}, name = "moshine-dunes"}}
      end
    end

    for x = 2, 10, 1 do
      for y = -4, 0 do
        game.surfaces[1].set_tiles{{position = {x, y}, name = "moshine-dust"}}
      end
    end

    for x = 0, 10, 1 do
      for y = 0, 6 do
        game.surfaces[1].set_tiles{{position = {x, y}, name = "moshine-rock"}}
      end
    end

    for x = 2, 10, 1 do
      for y = -4, 0 do
        game.surfaces[1].set_tiles{{position = {x, y}, name = "moshine-rock"}}
      end
    end

    for x = -11, -8, 1 do
      for y = -4, 6 do
        game.surfaces[1].set_tiles{{position = {x, y}, name = "moshine-lava"}}
      end
    end

    for k, position in pairs ({{-8, -4}, {-7, -4},
                               {-7, -3}, {-6, -3},
                               {-7, -2}, {-6, -2},
                               {-8, -1}, {-7, -1},
                               {-8, 0}, {-7, 0},
                               {-9, 1}, {-8, 1},
                               {-9, 2}, {-8, 2}, {-7, 2},
                               {-9, 3}, {-8, 3}, {-7, 3},
                               {-10, 4}, {-9, 4}, {-8, 4}, {-7, 4},
                               {-10, 5}, {-9, 5}, {-8, 5}, {-7, 5},
                               {-10, 6}, {-9, 6}, {-8, 6}}) do
      game.surfaces[1].set_tiles{{position = position, name = "moshine-hot-swamp"}}
    end

    game.surfaces[1].create_entity{name="fulgoran-data-source", position = {3, -1}}
    game.surfaces[1].create_entity{name="steam-geyser", position = {8, 2}}
    game.surfaces[1].create_entity{name="steam-geyser", position = {4, 4}}

    for x = 5.5, 10.5, 1 do
      for y = -4, 4, 1 do
        game.surfaces[1].create_entity{name = "multi-ore", amount = 10, position = {x, y}}
      end
    end

    game.surfaces[1].create_entity{name = "multi-ore", amount = 10, position = {3, 6}}
    game.surfaces[1].create_entity{name = "multi-ore", amount = 10, position = {5, 5}}
    game.surfaces[1].create_entity{name = "cliff-moshine", position = {-1 ,-6}, cliff_orientation = "north-to-south"}
    game.surfaces[1].create_entity{name = "cliff-moshine", position = {-1 ,-1}, cliff_orientation = "north-to-east"}

  ]]
}

data:extend({
  {
    type = "tips-and-tricks-item",
    name = "moshine-briefing",
    tag = "[planet=moshine]",
    category = "space-age",
    order = "e-e",
    trigger =
    {
      type = "research",
      technology = "planet-discovery-moshine"
    },
    skip_trigger =
    {
      type = "change-surface",
      surface = "moshine"
    },
    simulation = moshine_briefing
  },
})