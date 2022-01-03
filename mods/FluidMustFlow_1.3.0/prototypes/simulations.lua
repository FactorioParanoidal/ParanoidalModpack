local simulations = {}

simulations.introduction = {
  init = [[
    game.surfaces[1].create_entities_from_blueprint_string({
      string = "0eNq9l9uSojAQht8l12SKhJP6KltTFmLLZBcDFRJrXYt33+ABT83YeDHeYIB86b+70x0ObFU5aIzSli0OTBW1btni14G1qtR51d+z+wbYgikLWxYwnW/70doVlju9BlOa2l9ZFzDlh3/ZQnQBbXq7zavqZqLsPgMG2iqr4GTEcbBfarddgfHkYX7rVq3Nraq1ZzZ1q45//Woew9OA7f0l82QNqvxa1c70vOizt+yBKQcmVFBYowoO2qvac+8SMJu8AGSJ+LrEWhk/7/jML7xymw2YZav+eaQIhx+yckRTI0fUCExNPDAb1QC3NT+H54kbfSQncPqRdAgpGUhKb5T2j3iP/AaU4aCUbBKfXVCe+eBZBJxRLeTze+7l9WUL1ipdtv17Z9QX5Ls9r1XVY8AUfs28hGPq+QT2d3LrjB9LT9zW635KbnkFeWsZpn72hnpJUT+frl7+uHoRXuW7bTO+kZ4kS4wmiLSIRJP00CSjoUHJ0Rtkms3xfQUFveZN7QtVX6zyPzBePiICPLmHF87sEGKIArEUFen0avTkhhgDZy8SYcBJNCtnY16snR1xYx9TDwwJqufjTRLhCipXhlO4MYbFoi7FHXY0gygoifX3sQQSeLuQ0T3E8t9OF3hvDM+WYZh4grckOQbJ5MyJv7ExfZHG54NMSCkNMiNvtuyyO0JKo5H0FibCUTJqMrmHCXELxs5SIbkdiktxGEnASEyusedNLF9LjuSUTTzHsFiMomh6baBY+7CJqlqXmHwy77p9dK25AX+a0BwvO5IMTekF46Icw2QTXJiSAzOj5+Ulx18fUgvj1vD2Mc1/ZB0/xhY3n34B24FpTz6eiTibyyyeJ3GWRF33H+iKo/I=",
      position = { -2, -1 },
    })
  ]],
}

simulations.auto_join = {
  init = [[
    global.player = game.create_test_player({ name = "foo" })
    global.character = global.player.character
    global.character.teleport({ 0, 3 })

    game.camera_player = global.player

    step_0 = function()
      game.camera_player_cursor_position = { 0, 3 }
      game.camera_player_cursor_direction = defines.direction.east
      target_cursor_position = { -5, -1 }
      script.on_nth_tick(1, function()
        local finished = game.move_cursor({ position = target_cursor_position })
        if finished then
          step_1()
        end
      end)
    end

    step_1 = function()
      global.character.cursor_stack.set_stack({ name = "duct-small", count = 10 })
      target_cursor_position = { 5, -1 }
      script.on_nth_tick(1, function()
        local finished = game.move_cursor({ position = target_cursor_position, speed = 0.1 })

        if global.player.can_build_from_cursor({ position = game.camera_player_cursor_position }) then
          global.player.build_from_cursor({
            position = game.camera_player_cursor_position,
            direction = defines.direction.east,
          })
        end

        if finished then
          step_2()
        end
      end)
    end

    step_2 = function()
      target_cursor_position = { 0, 3 }
      script.on_nth_tick(1, function()
        local finished = game.move_cursor({ position = target_cursor_position })
        if finished then
          finish()
        end
      end)
    end

    finish = function()
      global.finished_tick = game.tick

      script.on_nth_tick(1, function()
        if game.tick == global.finished_tick + 90 then
          for _, entity in pairs(game.surfaces[1].find_entities_filtered({ name = { "duct", "duct-long" } })) do
            entity.destroy()
          end
          step_0()
        end
      end)
    end

    step_0()

    -- Copy of control.lua

    --- Calculates the midpoint between two positions.
    --- @param pos_1 Position
    --- @param pos_2 Position
    --- @return Position
    local function get_midpoint(pos_1, pos_2)
      return {
        x = (pos_1.x + pos_2.x) / 2,
        y = (pos_1.y + pos_2.y) / 2,
      }
    end

    --- @param e on_built_entity|on_robot_built_entity|script_raised_built|script_raised_revive
    local function join_ducts(e)
      --- @type LuaEntity
      local entity = e.entity or e.created_entity
      if not entity or not entity.valid then
        return
      end

      -- Straight ducts only have one fluidbox
      for _, neighbour in pairs(entity.neighbours[1]) do
        if entity.name == neighbour.name then
          local direction = entity.direction
          local force = entity.force
          local last_user = entity.last_user
          local name = entity.name == "duct-small" and "duct" or "duct-long"
          local position = get_midpoint(entity.position, neighbour.position)
          local surface = entity.surface

          entity.destroy({ raise_destroy = true })
          neighbour.destroy({ raise_destroy = true })

          surface.create_entity({
            name = name,
            position = position,
            direction = direction,
            force = force,
            player = last_user,
            raise_built = true,
            create_build_effect_smoke = false,
          })

          -- Only do one join per build
          break
        end
      end
    end

    local event_filter = { { filter = "name", name = "duct-small" }, { filter = "name", name = "duct" } }

    script.on_event(defines.events.on_built_entity, join_ducts, event_filter)
    script.on_event(defines.events.on_robot_built_entity, join_ducts, event_filter)
    script.on_event(defines.events.script_raised_built, join_ducts, event_filter)
    script.on_event(defines.events.script_raised_revive, join_ducts, event_filter)
  ]],
}

simulations.endpoints = {
  init = [[
    game.camera_alt_info = true
    game.surfaces[1].create_entities_from_blueprint_string({
      string = "0eNq9lsFymzAQht9FZ8ggEMH2oS/SyTACFqIpSIwk0roe3r0rnBK7Fo3sQ7gwQsu3C79+aU+k6icYtZCWHE5E1Eoacvh+IkZ0kvfumT2OQA5EWBhIRCQf3KiZahubgfc9mSMiZAO/yIHOLxEBaYUVcKYsg2Mpp6ECjQHr+9BDbbWoY5Cgu2OM+UG3vAZMMSqDBCVdcqTGu4gc8UYTzFRNbQu6NOI3UmiyXnN0kyxdk5mpMpYvyE36DuESRPdaqUm74rMXDzMLYtJkg5n6mGxlCtkKiVPxKEbPj6DpU34G50/57CHlK8kBYqviTqtJNv9DMT/qObQolOUvKkNUtMaXBqwVsjMu8J31k6PKjgG6xoS8g2VN4MrCJ9xO2o2RNqjGhXMb98CNJb4Ki+CPjffXFTZC4+Jb5p894F04ON8Epx7w/grswbFLnAfg1tWF/zyE7P39z4uh9NrLvZLdLTAJ56UhPBbOy655KABuFBtCFF6sT1zKHvAI/Vdd5iPnn8j7wUs25H3AdMmXeo4+YLokxHN0F+qNrX+3v9+1SYhp02vP4XnVxKPC48odWfwHbJqQBrDv8GAI7g4LhuDudyD9XOmU3UF1m1RgsfmWTGqyfp2oX6eIYA9kterLCl75m1DaxddC15OwJc41K6QV2tjyplNq+0k0H63S2YDzwsWWwTVarEgSNx5GjhZ0Gcg3NJxrn5Y263DRlUXkDbQ517ajrNinBdvnrMizef4DWc0xtg==",
      position = { 0, -4 },
    })

    for _, duct in pairs(game.surfaces[1].find_entities_filtered({
      area = { left_top = { x = -7, y = 0 }, right_bottom = { x = 7, y = 4 } },
      name = "duct-long",
    })) do
      local fluidbox = duct.fluidbox
      local capacity = fluidbox.get_capacity(1)
      fluidbox[1] = { name = "water", amount = capacity * 0.5 }
    end
  ]],
}

simulations.non_return_duct = {
  init = [[
    -- game.camera_alt_info = true
    game.surfaces[1].create_entities_from_blueprint_string({
      string = "0eNrFlu2uoyAQhu+F33IiqLV6K5uTBnXqsqtg+DjZbuO9L9gT0w9Maf+siTEIPvM674xyRs1gYVJcGFSfEW+l0Kj+cUaa94IN/p45TYBqxA2MKEGCjX7U2dZgPbJhQHOCuOjgD6rJnMQ9CKLDk3QxsbTGsN9wBaHzZ4JAGG44XKQsg9NB2LEB5aKsLBigNYq3jgeqP2EHBHVkLbhwk9SOIIUX4qh4n6CTu1QuUGOPR1AHzf86CEnXw6u/i0XXWNo22rCFuAkvHVwA73820iqvPfsMMLMoJkk3mDTEzFcmF0cu3BSe+BTKA0k/iguZfhRL1i/rDxqM4aLXfuE3awKj5AB2xD3TngWqdYFZD4sLzld3hxmr3Jg66ig7/xgzeACmDZoDSotVqReIjcS9klZ0AanVrdKOK2f3Mr8LgHfx4GITTAPgcqt23elL95Gff9Ofs/e37EGKPuRZNK9aeUIKrMB5I7BHP1JpNNSX4rVKg39Z0YbLNvzqeYhKnn0THuC7eMn0jYYg/6UhSPZGR5CYjiD5Gy1BYlqCFKEfwVYxpPfIYDnE92/5WhbKaPB9KTzLwj62yAi5BodQ1W1CW6u+YCuh5Lk0mr7ZXDFs8rJTaYxRlL5uVBrjE81e9slz/T5k2bvUV3ukBH2B0pdQe5KXFS3zqsjLIpvnf1ZWDVM=",
      position = { -1, -3 },
    })

    for _, duct in pairs(game.surfaces[1].find_entities_filtered({ name = { "duct-small", "duct", "duct-long", "duct-t-junction" } })) do
      local fluidbox = duct.fluidbox
      local capacity = fluidbox.get_capacity(1)
      fluidbox[1] = { name = "petroleum-gas", amount = capacity * 0.8 }
    end
  ]],
}

return simulations
