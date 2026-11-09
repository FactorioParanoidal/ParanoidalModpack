local simulations = {}

local insert_fuel_function = [[
  local function insert_fuel_into_vehicle(vehicle)
    local burner = vehicle.burner
    if burner then
      local fuel_categories = burner.fuel_categories
      for fuel_category, _ in pairs(fuel_categories) do
        local fuel_items = prototypes.get_item_filtered{{filter = "fuel-category", ["fuel-category"] = fuel_category}}
        for fuel_item, _ in pairs(fuel_items) do
          local burner_inventory = vehicle.get_inventory(defines.inventory.fuel)
          burner_inventory.insert{name = fuel_item, count = 1000}
        end
      end
    end
  end
]]

simulations.spidertron_patrols = {
  mods = {"SpidertronEnhancements", "SpidertronPatrols"},
  init_update_count = 10,
  init = insert_fuel_function .. [[
    game.simulation.camera_alt_info = true
    game.simulation.camera_zoom = 1
    game.surfaces[1].build_checkerboard{{-22, -11}, {22, 11}}

    local surface = game.surfaces[1]

    -- spiderling name is dynamically replaced when this sim is used by other tips items
    local spidertron_name = prototypes.entity["sp-spiderling"] and "sp-spiderling" or "spidertron"
    local spidertron_ghost = surface.create_entity{name = "entity-ghost", inner_name = spidertron_name, position = {-11, 0}, force = "player"}
    spidertron_ghost.tags = {spidertron_patrol_data = {hide_gui = false, waypoints = {
      {position = {x = -11, y = 0}, type = "none"},
      {position = {x = -5, y = 4}, type = "none"},
      {position = {x = 5, y = 4}, type = "none"},
      {position = {x = 11, y = 0}, type = "none"},
      {position = {x = 5, y = -3}, type = "none"},
      {position = {x = -5, y = -3}, type = "none"},
    }}}
    local _, spidertron = spidertron_ghost.revive{raise_revive = true}
    spidertron.color = {1, 0.5, 1, 0.5}
    remote.call("SpidertronPatrols", "set_on_patrol", spidertron, true)
    insert_fuel_into_vehicle(spidertron)

    local spidertron_ghost2 = surface.create_entity{name = "entity-ghost", inner_name = "spidertron", position = {15, -5}, force = "player"}
    spidertron_ghost2.tags = {spidertron_patrol_data = {hide_gui = false, waypoints = {
      {position = {x = 15, y = -5}, type = "none"},
      {position = {x = 15, y = 6}, type = "none"},
      {position = {x = -15, y = 6}, type = "none"},
      {position = {x = -15, y = -5}, type = "none"},
    }}}
    local _, spidertron2 = spidertron_ghost2.revive{raise_revive = true}
    spidertron2.color = {0.9, 1, 0, 0.5}
    remote.call("SpidertronPatrols", "set_on_patrol", spidertron2, true)
    insert_fuel_into_vehicle(spidertron2)
  ]]
}

simulations.dock = {
  mods = {"SpidertronEnhancements", "SpidertronPatrols"},
  init_update_count = 20,
  init = insert_fuel_function .. [[
    game.surfaces[1].create_entities_from_blueprint_string
    {
      string = "0eNrNmOtu2yAUgN+F37gyYDuXV6miiNjHGSoBC3C3LMq7D2ylaVe3A9YfjRQpAfOdC+cmX9BBjjAYoRzaXpBotbJo+3hBVhwVl2FN8ROgLeq5dYUzXNlBG1ccQDp0xUioDn6hLbnihTN2KOwgOjDOaFV0un16dYRedxiBcsIJmGVOf857NZ4OYDwT3zhC9UL5raL9AdYhjAZt/TGtgiyPKlYPNUZn/4M+1JOE+fm9BeeEOtrwnIGTfob96PekAwPdXjg4+a2eSwsYzcuzJjf9HYAsBskdeKGtHoOXSFlidNJdeIC7QgKfVHpxxO4afPGXLTTDFvZNbWH4TUxIzf0NLxjSvDajEwbaebfCyJ2HcF6PbhhDGL2TUaXJoDkyavxZbL+XVb29mNfSFuhNLp3G0FeJdJak+zqRTpPom1x6lGdImeuaOPy9Kh1G+VQIZX15W4xN8iGY0CUyTSezODKLJROWSK7SyZHeSMxOUifFIElMT5KW/GSVi48LwnWuc+LwiRlKmiTn0DIXH6U9JXG9IzjxH/1JqA9aB6VpMmiODBY9M5DN/8wMzoywOLNUGQrQr1SgzpiayHedAJu0kYbkjDR0lTt1kKjUWuf21jh89mQQhWdleoMlUc2KkfQ2GEmmuZU+ziUst0/F4avcSh+Hr9OqMMmowqzJKILkC4sgu6e0HQ/W8UniQsiWk2yyyFhHMZpPCPfUBOndZ0RbgAJzPPtg93b0vIUFpWbH+8D2edH3YPZW/IapgN4+4SXAT38joeo+eltr7JWtd341+CUk1Mv7CYyefXWe6HVDN9VmU/tvRdZe4z+MOItI",
      position = {-2, 2}
    }
    -- Above command doesn't raise events, so place docks and spidertron-with-patrol-tags separately
    local surface = game.surfaces[1]
    
    local spidertron_name = prototypes.entity["sp-spiderling"] and "sp-spiderling" or "spidertron"
    local spidertron_ghost = surface.create_entity{name = "entity-ghost", inner_name = spidertron_name, position = {4, 0}, force = "player"}
    spidertron_ghost.tags = {spidertron_patrol_data = {hide_gui = false, waypoints = {{item_condition_info = {condition = 4, count = 200, elem = {name = "steel-plate", quality = "normal"}}, position = {x = -6.3, y = 0.3}, type = "item-count"}, {position = {x = 5.3, y = 0.3}, type = "empty-inventory"}}}}
    local _, spidertron = spidertron_ghost.revive{raise_revive = true}
    remote.call("SpidertronPatrols", "set_on_patrol", spidertron, true)
    insert_fuel_into_vehicle(spidertron)

    surface.create_entity{name = "sp-spidertron-dock", position = {-6, 0}, force = "player", raise_built = true}
    surface.create_entity{name = "sp-spidertron-dock", position = {5, 0}, force = "player", raise_built = true}

    game.simulation.camera_alt_info = true
    game.simulation.camera_position = {0, 0.5}

    game.forces.player.bulk_inserter_capacity_bonus = 11
  ]]
}

simulations.spidertron_automation = {
  mods = {"SpidertronEnhancements", "SpidertronPatrols"},
  init = insert_fuel_function .. [[
    require("__core__/lualib/story")
    player = game.simulation.create_test_player{name = "big k"}
    player.teleport({0, 2.5})
    game.simulation.camera_player = player
    game.simulation.camera_alt_info = true
    game.simulation.camera_zoom = 1
    game.surfaces[1].build_checkerboard{{-22, -11}, {22, 11}}
    game.simulation.camera_player_cursor_position = player.position

    spider = game.surfaces[1].create_entity{name = "spidertron", position = {-8, 1.5}, force = "player", create_build_effect_smoke = false}
    spider.color = {1, 1, 1, 0.5}
    insert_fuel_into_vehicle(spider)

    local story_table =
    {
      {
        {
          name = "start",
          condition = story_elapsed_check(0.5),
        },
        {
          condition = function() return game.simulation.move_cursor({position = {spider.position.x, spider.position.y - 1.5}}) end,
          action = function() game.simulation.control_press{control = "spidertron-enhancements-spidertron-patrol-pipette", notify = true} end
        },
        { condition = story_elapsed_check(0.5) },
        {
          condition = function() return game.simulation.move_cursor({position = {11, 6.5}}) end,
          action = function() game.simulation.control_press{control = "use-item", notify = true} end
        },
        { condition = story_elapsed_check(0.5) },
        {
          condition = function() return game.simulation.move_cursor({position = {11, -6.5}, speed = 0.35}) end,
          action = function() game.simulation.control_press{control = "use-item", notify = true} end
        },
        { condition = story_elapsed_check(0.5) },
        {
          condition = function() return game.simulation.move_cursor({position = {-11, -6.5}, speed = 0.35}) end,
          action = function() game.simulation.control_press{control = "use-item", notify = true} end
        },
        { condition = story_elapsed_check(0.5) },
        {
          condition = function() return game.simulation.move_cursor({position = {-16, 8.5}, speed = 0.35}) end,
          action = function() game.simulation.control_press{control = "use-item", notify = true} end
        },
        { condition = story_elapsed_check(1.5) },
        {
          condition = function() return game.simulation.move_cursor({position = {-11, 6.5}, speed = 0.35}) end,
          action = function() game.simulation.control_press{control = "sp-replace-previous-waypoint", notify = true} end
        },
        { condition = story_elapsed_check(1.5) },
        {
          condition = function() return game.simulation.move_cursor({position = {0, 0}}) end,
          action = function() game.simulation.control_press{control = "sp-toggle-spidertron-automatic-manual", notify = true} end
        },
        {
          condition = story_elapsed_check(11),
          action = function() game.simulation.control_press{control = "sp-toggle-spidertron-automatic-manual", notify = true} end
        },
        {
          condition = story_elapsed_check(2),
          action = function() game.simulation.control_press{control = "sp-delete-all-waypoints", notify = true} end
        },
        {
          condition = story_elapsed_check(1),
          action = function()
            player.clear_cursor()
            story_jump_to(storage.story, "start")
          end
        }
      }
    }
    tip_story_init(story_table)
  ]]
}

simulations.aircraft = {
  mods = {"SpidertronEnhancements", "SpidertronPatrols", "lex-aircraft"},
  init_update_count = simulations.dock.init_update_count,
  init = simulations.dock.init:gsub("sp%-spiderling", "lex-flying-cargo")
}

simulations.submarine = {
  mods = {"SpidertronEnhancements", "SpidertronPatrols", "maraxsis"},
  planet = "maraxsis",
  init_update_count = simulations.dock.init_update_count,
  init = simulations.dock.init:gsub("sp%-spiderling", "maraxsis-diesel-submarine")
}

return simulations