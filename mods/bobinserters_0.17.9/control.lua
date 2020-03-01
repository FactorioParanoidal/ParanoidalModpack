require("mod-gui")

if not bobmods then bobmods = {} end
if not bobmods.inserters then bobmods.inserters = {} end
if not bobmods.logistics then bobmods.logistics = {} end
if not bobmods.logistics.inserters then bobmods.logistics.inserters = {} end
if not bobmods.math then bobmods.math = {} end

function bobmods.math.mod(number, div)
  if number < 0 then
    local newnumber = 0 - number
    local mod = newnumber % div
    return 0 - mod
  else
    return number % div
  end
end

function bobmods.math.floor(number)
  local num
  if number < 0 then
    num = number - 0.1
  else
    num = number + 0.1
  end
  return math.floor (num - bobmods.math.mod(num, 1))
end

function bobmods.math.round(number)
  local num
  if number < 0 then
    num = number - 0.5
  else
    num = number + 0.5
  end
  return math.floor (num - bobmods.math.mod(num, 1))
end

function bobmods.math.offset(number)
  local num = bobmods.math.mod(number, 1)
  if num < 0 then
    if num > -0.5 then
      return num
    else
      return num + 1
    end
  else
    if num < 0.5 then
      return num
    else
      return num - 1
    end
  end
end



bobmods.inserters.long_technology = "long-inserters-1"
bobmods.inserters.long2_technology = "long-inserters-2"
bobmods.inserters.near_technology = "near-inserters"
bobmods.inserters.more_technology = "more-inserters-1"
bobmods.inserters.more2_technology = "more-inserters-2"
bobmods.inserters.offset = 0.2

bobmods.inserters.range1_4way = {
  table = {
    {x = 0, y = -1},
    {x = 1, y = 0},
    {x = 0, y = 1},
    {x = -1, y = 0}
  },
  steps = 4
}

bobmods.inserters.range1_8way = {
  table = {
    {x = 0, y = -1},
    {x = 1, y = -1},
    {x = 1, y = 0},
    {x = 1, y = 1},
    {x = 0, y = 1},
    {x = -1, y = 1},
    {x = -1, y = 0},
    {x = -1, y = -1}
  },
  steps = 8
}


bobmods.inserters.range2_4way = {
  table = {
    {x = 0, y = -2},
    {x = 2, y = 0},
    {x = 0, y = 2},
    {x = -2, y = 0}
  },
  steps = 4
}

bobmods.inserters.range2_8way = {
  table = {
    {x = 0, y = -2},
    {x = 2, y = -2},
    {x = 2, y = 0},
    {x = 2, y = 2},
    {x = 0, y = 2},
    {x = -2, y = 2},
    {x = -2, y = 0},
    {x = -2, y = -2}
  },
  steps = 8
}

bobmods.inserters.range2_16way = {
  table = {
    {x = 0, y = -2},
    {x = 1, y = -2},
    {x = 2, y = -2},
    {x = 2, y = -1},
    {x = 2, y = 0},
    {x = 2, y = 1},
    {x = 2, y = 2},
    {x = 1, y = 2},
    {x = 0, y = 2},
    {x = -1, y = 2},
    {x = -2, y = 2},
    {x = -2, y = 1},
    {x = -2, y = 0},
    {x = -2, y = -1},
    {x = -2, y = -2}, 
    {x = -1, y = -2}
  },
  steps = 16
}


bobmods.inserters.range3_4way = {
  table = {
    {x = 0, y = -3},
    {x = 3, y = 0},
    {x = 0, y = 3},
    {x = -3, y = 0}
  },
  steps = 4
}

bobmods.inserters.range3_8way = {
  table = {
    {x = 0, y = -3},
    {x = 3, y = -3},
    {x = 3, y = 0},
    {x = 3, y = 3},
    {x = 0, y = 3},
    {x = -3, y = 3},
    {x = -3, y = 0},
    {x = -3, y = -3}
  },
  steps = 8
}

bobmods.inserters.range3_24way = {
  table = {
    {x = 0, y = -3},
    {x = 1, y = -3},
    {x = 2, y = -3},
    {x = 3, y = -3},
    {x = 3, y = -2},
    {x = 3, y = -1},
    {x = 3, y = 0},
    {x = 3, y = 1},
    {x = 3, y = 2},
    {x = 3, y = 3},
    {x = 2, y = 3},
    {x = 1, y = 3},
    {x = 0, y = 3},
    {x = -1, y = 3},
    {x = -2, y = 3},
    {x = -3, y = 3},
    {x = -3, y = 2},
    {x = -3, y = 1},
    {x = -3, y = 0},
    {x = -3, y = -1},
    {x = -3, y = -2}, 
    {x = -3, y = -3}, 
    {x = -2, y = -3}, 
    {x = -1, y = -3}
  },
  steps = 24
}


bobmods.inserters.positions = {
  {x = -2, y = -2}, 
  {x = -1, y = -2},
  {x = 0, y = -2},
  {x = 1, y = -2},
  {x = 2, y = -2},

  {x = -2, y = -1},
  {x = -1, y = -1},
  {x = 0, y = -1},
  {x = 1, y = -1},
  {x = 2, y = -1},

  {x = -2, y = 0},
  {x = -1, y = 0},
  {x = 0, y = 0},
  {x = 1, y = 0},
  {x = 2, y = 0},

  {x = -2, y = 1},
  {x = -1, y = 1},
  {x = 0, y = 1},
  {x = 1, y = 1},
  {x = 2, y = 1},

  {x = -2, y = 2},
  {x = -1, y = 2},
  {x = 0, y = 2},
  {x = 1, y = 2},
  {x = 2, y = 2},


  {x = -3, y = -3},
  {x = -2, y = -3},
  {x = -1, y = -3},
  {x = 0, y = -3},
  {x = 1, y = -3},
  {x = 2, y = -3},
  {x = 3, y = -3},

  {x = -3, y = -2},
  {x = 3, y = -2},

  {x = -3, y = -1},
  {x = 3, y = -1},

  {x = -3, y = 0},
  {x = 3, y = 0},

  {x = -3, y = 1},
  {x = 3, y = 1},

  {x = -3, y = 2},
  {x = 3, y = 2},

  {x = -3, y = 3},
  {x = -2, y = 3},
  {x = -1, y = 3},
  {x = 0, y = 3},
  {x = 1, y = 3},
  {x = 2, y = 3},
  {x = 3, y = 3}
}

bobmods.inserters.offset_positions = {
  {x = -bobmods.inserters.offset, y = -bobmods.inserters.offset},
  {x = 0, y = -bobmods.inserters.offset},
  {x = bobmods.inserters.offset, y = -bobmods.inserters.offset},

  {x = -bobmods.inserters.offset, y = 0},
  {x = 0, y = 0},
  {x = bobmods.inserters.offset, y = 0},

  {x = -bobmods.inserters.offset, y = bobmods.inserters.offset},
  {x = 0, y = bobmods.inserters.offset},
  {x = bobmods.inserters.offset, y = bobmods.inserters.offset}
}




bobmods.logistics.inserters.range1 = {
  pickup = {
    {x = 0, y = -1},
    {x = 1, y = 0},
    {x = 0, y = 1},
    {x = -1, y = 0}
  },
  drop = {
    {x = 0, y = 1},
    {x = -1, y = 0},
    {x = 0, y = -1},
    {x = 1, y = 0}
  }
}

bobmods.logistics.inserters.range2 = {
  pickup = {
    {x = 0, y = -2},
    {x = 2, y = 0},
    {x = 0, y = 2},
    {x = -2, y = 0}
  },
  drop = {
    {x = 0, y = 2},
    {x = -2, y = 0},
    {x = 0, y = -2},
    {x = 2, y = 0}
  },
}


bobmods.logistics.inserters.offset_positions = {
  near = {
    {x = 0, y = -bobmods.inserters.offset},
    {x = bobmods.inserters.offset, y = 0},
    {x = 0, y = bobmods.inserters.offset},
    {x = -bobmods.inserters.offset, y = 0}
  },
  far = {
    {x = 0, y = bobmods.inserters.offset},
    {x = -bobmods.inserters.offset, y = 0},
    {x = 0, y = -bobmods.inserters.offset},
    {x = bobmods.inserters.offset, y = 0}
  }
}





function bobmods.inserters.create_global_table_basic()
  if not global then global = {} end
  if not global.bobmods then global.bobmods = {} end
  if not global.bobmods.inserters then global.bobmods.inserters = {} end
  if not global.bobmods.inserters.blacklist then global.bobmods.inserters.blacklist = {} end
end


function bobmods.inserters.create_global_table(player_index)
  bobmods.inserters.create_global_table_basic()
  if not global.bobmods.inserters[player_index] then global.bobmods.inserters[player_index] = {} end

  if not global.bobmods.logistics then global.bobmods.logistics = {} end
  if not global.bobmods.logistics[player_index] then global.bobmods.logistics[player_index] = {} end

  if not global.bobmods.logistics[player_index].enabled then global.bobmods.logistics[player_index].enabled = false end
  if not global.bobmods.logistics[player_index].long_in then global.bobmods.logistics[player_index].long_in = false end
  if not global.bobmods.logistics[player_index].long_out then global.bobmods.logistics[player_index].long_out = false end
  if not global.bobmods.logistics[player_index].near then global.bobmods.logistics[player_index].near = false end
  if not global.bobmods.logistics[player_index].show then global.bobmods.logistics[player_index].show = false end

  if not global.bobmods.logistics[player_index].enabled2 then global.bobmods.logistics[player_index].enabled2 = false end
  if not global.bobmods.logistics[player_index].pickup then global.bobmods.logistics[player_index].pickup = 18 end
  if not global.bobmods.logistics[player_index].drop then global.bobmods.logistics[player_index].drop = 8 end
  if not global.bobmods.logistics[player_index].offset then global.bobmods.logistics[player_index].offset = 2 end
end



script.on_event("bob-inserter-pickup-rotate", function(event)
  local player = game.players[event.player_index]
  local entity = player.selected
  if
    entity
    and entity.type == "inserter"
    and player.can_reach_entity(entity)
    and not global.bobmods.inserters.blacklist[entity.name]
  then
    bobmods.inserters.rotate_pickup(entity, player)
  end
end)

script.on_event("bob-inserter-pickup-range", function(event)
  local player = game.players[event.player_index]
  local entity = player.selected
  if
    entity
    and entity.type == "inserter"
    and player.can_reach_entity(entity)
    and not global.bobmods.inserters.blacklist[entity.name]
  then
    bobmods.inserters.pickup_range(entity, player)
  end
end)

script.on_event("bob-inserter-drop-range", function(event)
  local player = game.players[event.player_index]
  local entity = player.selected
  if
    entity
    and entity.type == "inserter"
    and player.can_reach_entity(entity)
    and not global.bobmods.inserters.blacklist[entity.name]
  then
    bobmods.inserters.drop_range(entity, player)
  end
end)

script.on_event("bob-inserter-long", function(event)
  local player = game.players[event.player_index]
  local entity = player.selected
  if
    entity
    and entity.type == "inserter"
    and player.can_reach_entity(entity)
    and not global.bobmods.inserters.blacklist[entity.name]
  then
    bobmods.inserters.long_range(entity, player)
  end
end)

script.on_event("bob-inserter-near", function(event)
  local player = game.players[event.player_index]
  local entity = player.selected
  if
    entity
    and entity.type == "inserter"
    and player.can_reach_entity(entity)
    and not global.bobmods.inserters.blacklist[entity.name]
  then
    bobmods.inserters.near_range(entity, player)
  end
end)

script.on_event("bob-inserter-open-gui", function(event)
  local player = game.players[event.player_index]
    local entity = player.selected
    if
      entity
      and entity.type == "inserter"
      and player.can_reach_entity(entity)
      and not global.bobmods.inserters.blacklist[entity.name]
    then
      global.bobmods.inserters[event.player_index].position = "center"
      bobmods.inserters.open_gui(entity, player)
    else
      bobmods.inserters.delete_gui(event.player_index)
    end
end)

script.on_event(defines.events.on_gui_opened, function(event)
  local player = game.players[event.player_index]
    if
      event.gui_type == defines.gui_type.entity
      and event.entity.type == "inserter"
      and not global.bobmods.inserters.blacklist[event.entity.name]
    then
      global.bobmods.inserters[event.player_index].position = "left"
      bobmods.inserters.open_gui(event.entity, player)
    else
      if not (event.gui_type == defines.gui_type.custom and event.element.name == "bob_inserter_gui") then
        bobmods.inserters.delete_gui(event.player_index)
      end
    end
end)


script.on_event(defines.events.on_gui_closed, function(event)
-- this is checking for what GUI was just told to close. as we want to delete only when closing my GUI, or when closing the inserters GUI IF not opening mine.
  if
    ( -- closing the vanilla inserters GUI while not opening bob's inserters GUI
      global.bobmods.inserters[event.player_index].position == "left"
      and event.gui_type == defines.gui_type.entity
      and event.entity.type == "inserter"
    )
    or
    ( -- Closing bob's inserters GUI
      global.bobmods.inserters[event.player_index].position == "center"
      and event.gui_type == defines.gui_type.custom
      and event.element and event.element.valid --the GUI actually exists.
      and event.element.name == "bob_inserter_gui"
    )
  then
    bobmods.inserters.delete_gui(event.player_index)
  end
end)


script.on_event(defines.events.on_gui_checked_state_changed, function(event)
  local player = game.players[event.player_index]
  local entity = global.bobmods.inserters[event.player_index].entity

  if event.element.valid then
    if entity and entity.valid and player.can_reach_entity(entity) then
      if event.element.parent.name == "bob_inserter_gui_pickup" then
        bobmods.inserters.gui_pickup_click(entity, event.element)
      elseif event.element.parent.name == "bob_inserter_gui_drop" then
        bobmods.inserters.gui_drop_click(entity, event.element)
      elseif event.element.parent.name == "bob_inserter_gui_drop_offset" then
        bobmods.inserters.gui_offset_click(entity, event.element)
      end
    else
      bobmods.inserters.delete_gui(event.player_index)
    end
  end

  if event.element.valid then
    if event.element.name == "bob_logistics_inserter_enabled" then
      global.bobmods.logistics[event.player_index].enabled = event.element.state
      if event.element.state then
        global.bobmods.logistics[event.player_index].enabled2 = false
      end
      bobmods.logistics.create_gui(event.player_index)
    elseif event.element.name == "bob_logistics_inserter_long_in" then
      global.bobmods.logistics[event.player_index].long_in = event.element.state
    elseif event.element.name == "bob_logistics_inserter_long_out" then
      global.bobmods.logistics[event.player_index].long_out = event.element.state
    elseif event.element.name == "bob_logistics_inserter_near" then
      global.bobmods.logistics[event.player_index].near = event.element.state

    elseif event.element.name == "bob_logistics_inserter_enabled2" then
      global.bobmods.logistics[event.player_index].enabled2 = event.element.state
      if event.element.state then
        global.bobmods.logistics[event.player_index].enabled = false
      end
      bobmods.logistics.create_gui(event.player_index)


    elseif remote.interfaces.bobinserters and string.sub(event.element.name, 1, 6) == "button" then
      if event.element.parent.name == "bob_logistics_pickup" then
        local i = string.gsub(event.element.name, "button", "") + 0
        remote.call("bobinserters", "draw_button_position_check", {gui = event.element.parent, position = i})
        global.bobmods.logistics[event.player_index].pickup = i 
      elseif event.element.parent.name == "bob_logistics_drop" then
        local i = string.gsub(event.element.name, "button", "") + 0
        remote.call("bobinserters", "draw_button_position_check", {gui = event.element.parent, position = i})
        global.bobmods.logistics[event.player_index].drop = i 
      elseif event.element.parent.name == "bob_logistics_offset" then
        local i = string.gsub(event.element.name, "button", "") + 0
        remote.call("bobinserters", "draw_button_offset_check", {gui = event.element.parent, position = i})
        global.bobmods.logistics[event.player_index].offset = i 
      end
    end
  end
end)

script.on_event(defines.events.on_gui_click, function(event)
  local player = game.players[event.player_index]
  local entity = global.bobmods.inserters[event.player_index].entity
  if event.element.valid then
    if entity and entity.valid and player.can_reach_entity(entity) then
      if event.element.name == "bob_inserter_gui_close" then
        bobmods.inserters.delete_gui(event.player_index)
      end
    else
      bobmods.inserters.delete_gui(event.player_index)
    end
  end

  if event.element.valid and event.element.name == "bob_logistics_inserter_button" then
    if global.bobmods.logistics[event.player_index].show then
      global.bobmods.logistics[event.player_index].show = false
    else
      global.bobmods.logistics[event.player_index].show = true
    end
    bobmods.logistics.show_gui_options(event.player_index)
  end
end)


script.on_event(defines.events.on_player_rotated_entity, function(event)
  local player = game.players[event.player_index]
  local entity = global.bobmods.inserters[event.player_index].entity
  if entity == event.entity and player.can_reach_entity(entity) then
    if global.bobmods.inserters[player.index].gui and global.bobmods.inserters[player.index].gui.valid then
      bobmods.inserters.refresh_position_checkboxes(entity, player)
    end
  end
end)


script.on_event(defines.events.on_tick, function(event)
  if game.tick % 20 == 0 then
    if global and global.bobmods and global.bobmods.inserters then
      for i, player in pairs(game.connected_players) do
        if global.bobmods.inserters[player.index] then
          local entity = global.bobmods.inserters[player.index].entity
          if entity and (not entity.valid or not player.can_reach_entity(entity)) then
            bobmods.inserters.delete_gui(player.index)
          end
        else
          bobmods.inserters.create_global_table(player.index) -- Create for this specific online player.
        end
      end
    else
      for index, player in pairs(game.players) do -- Create for all if there are none.
        bobmods.inserters.create_global_table(index)
      end
    end
  end
end)


script.on_configuration_changed(function(event)
  for i, player in pairs(game.players) do
    bobmods.inserters.create_global_table(player.index)
    if player.gui.center.bob_inserter_gui then player.gui.center.bob_inserter_gui.destroy() end
    bobmods.inserters.delete_gui(player.index)
    bobmods.logistics.create_gui_button(player.index)
    player.gui.center.visible = true
  end
end)

script.on_init(function(event)
  for i, player in pairs(game.players) do
    bobmods.inserters.create_global_table(player.index)
    bobmods.logistics.create_gui_button(player.index)
  end
end)

script.on_event(defines.events.on_player_created, function(event)
  bobmods.inserters.create_global_table(event.player_index)
  bobmods.logistics.create_gui_button(event.player_index)
end)

script.on_event(defines.events.on_player_joined_game, function(event)
  bobmods.inserters.create_global_table(event.player_index)
  bobmods.logistics.create_gui_button(event.player_index)
end)

script.on_event(defines.events.on_research_finished, function(event)
  if event.research.name == bobmods.inserters.long_technology or
    event.research.name == bobmods.inserters.long2_technology or
    event.research.name == bobmods.inserters.near_technology or
    event.research.name == bobmods.inserters.more_technology or
    event.research.name == bobmods.inserters.more2_technology then
    for i, player in pairs(event.research.force.players) do
      local entity = global.bobmods.inserters[player.index].entity
      if entity and entity.valid and player.can_reach_entity(entity) then
        bobmods.inserters.open_gui(entity, player)
      end
      bobmods.logistics.show_gui_options(player.index)
    end
  end
end)


script.on_event(defines.events.on_built_entity, function(event)
  local player = game.players[event.player_index]
  local entity = event.created_entity
  if
    (
      entity.type == "inserter"
      and not event.revived
      and not global.bobmods.inserters.blacklist[entity.name]
    )
    or
    (
      entity.type == "entity-ghost"
      and entity.ghost_type == "inserter"
      and not (player.cursor_stack and player.cursor_stack.valid and player.cursor_stack.valid_for_read and (player.cursor_stack.type == "blueprint" or player.cursor_stack.type == "blueprint-book"))
      and not global.bobmods.inserters.blacklist[entity.ghost_name]
    )
  then
    bobmods.logistics.set_positions(entity, event.player_index)
  end
end)


function bobmods.logistics.create_gui_button(player_index)
  local player = game.players[player_index]

  -- remove legacy GUI
  if player.gui.top.bob_logistics_inserter_gui then
    player.gui.top.bob_logistics_inserter_gui.destroy()
  end

  -- remove legacy button
  if player.gui.top.bob_logistics_inserter_button then
    player.gui.top.bob_logistics_inserter_button.destroy()
  end

  if mod_gui.get_button_flow(player).bob_logistics_inserter_button then
    mod_gui.get_button_flow(player).bob_logistics_inserter_button.destroy()
  end

  mod_gui.get_button_flow(player).add{type = "sprite-button", name = "bob_logistics_inserter_button", tooltip = {"gui.bob-inserter-open-gui"}, sprite = "item/fast-inserter", style = "mod_gui_button"}
end


function bobmods.logistics.show_gui_options(player_index)
  local player = game.players[player_index]

  if player.gui.left.bob_logistics_inserter_gui then
    player.gui.left.bob_logistics_inserter_gui.destroy()
  end

  if global.bobmods.logistics[player_index].show then
    bobmods.logistics.create_gui(player_index)
  end
end


function bobmods.logistics.set_positions(entity, player_index)
  local enabled = global.bobmods.logistics[player_index].enabled
  if enabled then
    local force = game.players[player_index].force
    local direction = (entity.direction / 2) + 1

    local long_unlocked = tech_unlocked(force, bobmods.inserters.long_technology)
    local more_unlocked = tech_unlocked(force, bobmods.inserters.more_technology)
    local near_unlocked = tech_unlocked(force, bobmods.inserters.near_technology)

    local long_in = global.bobmods.logistics[player_index].long_in
    local long_out = global.bobmods.logistics[player_index].long_out
    local near = global.bobmods.logistics[player_index].near

    local pickup_position = {x = entity.pickup_position.x - entity.position.x, y = entity.pickup_position.y - entity.position.y}
    local drop_full_position = {x = entity.drop_position.x - entity.position.x, y = entity.drop_position.y - entity.position.y}
    local drop_position = {x = bobmods.math.round(drop_full_position.x), y = bobmods.math.round(drop_full_position.y)}
    local drop_offset = bobmods.inserters.normalise_tile_offset({x = bobmods.math.offset(drop_full_position.x), y = bobmods.math.offset(drop_full_position.y)})

    if long_unlocked then
      if more_unlocked then
        if long_in then
          pickup_position = bobmods.logistics.set_range(pickup_position, 2)
        else
          pickup_position = bobmods.logistics.set_range(pickup_position, 1)
        end
        if long_out then
          drop_position = bobmods.logistics.set_range(drop_position, 2)
        else
          drop_position = bobmods.logistics.set_range(drop_position, 1)
        end
      else
        if long_in then
          pickup_position = bobmods.logistics.set_range(pickup_position, 2)
          drop_position = bobmods.logistics.set_range(drop_position, 2)
        else
          pickup_position = bobmods.logistics.set_range(pickup_position, 1)
          drop_position = bobmods.logistics.set_range(drop_position, 1)
        end
      end
    end

    if near_unlocked then
      if near then
        drop_offset = bobmods.logistics.set_range(drop_position, -bobmods.inserters.offset)
      else
        drop_offset = bobmods.logistics.set_range(drop_position, bobmods.inserters.offset)
      end
    end


    entity.drop_position = {entity.position.x + drop_position.x + drop_offset.x, entity.position.y + drop_position.y + drop_offset.y}
    entity.pickup_position = {entity.position.x + pickup_position.x, entity.position.y + pickup_position.y}
  end
  if global.bobmods.logistics[player_index].enabled2 and remote.interfaces.bobinserters then
    local pickup_position = remote.call("bobinserters", "get_position", {position = global.bobmods.logistics[player_index].pickup})
    local drop_position = remote.call("bobinserters", "get_position", {position = global.bobmods.logistics[player_index].drop})
    local drop_offset = remote.call("bobinserters", "get_offset", {position = global.bobmods.logistics[player_index].offset})

-- All the jiggery to make drop offset work right
    local near_unlocked = tech_unlocked(game.players[player_index].force, bobmods.inserters.near_technology)

    if not near_unlocked then
      local old_drop_full_position = {x = entity.drop_position.x - entity.position.x, y = entity.drop_position.y - entity.position.y}
      local tile_position = {x = bobmods.math.round(old_drop_full_position.x), y = bobmods.math.round(old_drop_full_position.y)}
      local tile_offset = bobmods.inserters.normalise_tile_offset({x = bobmods.math.offset(old_drop_full_position.x), y = bobmods.math.offset(old_drop_full_position.y)})

--this part is duplicated from previous scripts, maybe convert to a function?
      local new_offset = {x = tile_offset.x, y = tile_offset.y}

      if (tile_position.x > 0 and drop_position.x < 0) or (tile_position.x < 0 and drop_position.x > 0) then
        new_offset.x = 0 - tile_offset.x
      elseif tile_position.x == 0 and drop_position.x ~= 0 then
        if (drop_position.x > 0 and tile_position.y > 0) or (drop_position.x < 0 and tile_position.y < 0) then
          new_offset.x = tile_offset.y
        else
          new_offset.x = 0 - tile_offset.y
        end
      elseif tile_position.x ~= 0 and drop_position.x == 0 then
        new_offset.x = 0
      end

      if (tile_position.y > 0 and drop_position.y < 0) or (tile_position.y < 0 and drop_position.y > 0) then
        new_offset.y = 0 - tile_offset.y
      elseif tile_position.y == 0 and drop_position.y ~= 0 then
        if (drop_position.y > 0 and tile_position.x > 0) or (drop_position.y < 0 and tile_position.x < 0) then
          new_offset.y = tile_offset.x
        else
          new_offset.y = 0 - tile_offset.x
        end
      elseif tile_position.y ~= 0 and drop_position.y == 0 then
        new_offset.y = 0
      end

      drop_offset = new_offset
    end
-- Jiggery ends here.

    local direction = (entity.direction / 2) + 1

    if direction == 3 then -- 3 is up, because inserters are backwards.
      entity.drop_position = {entity.position.x + drop_position.x + drop_offset.x, entity.position.y + drop_position.y + drop_offset.y}
      entity.pickup_position = {entity.position.x + pickup_position.x, entity.position.y + pickup_position.y}
    elseif direction == 4 then
      entity.drop_position = {entity.position.x - drop_position.y - drop_offset.y, entity.position.y + drop_position.x + drop_offset.x}
      entity.pickup_position = {entity.position.x - pickup_position.y, entity.position.y + pickup_position.x}
    elseif direction == 1 then
      entity.drop_position = {entity.position.x - drop_position.x - drop_offset.x, entity.position.y - drop_position.y - drop_offset.y}
      entity.pickup_position = {entity.position.x - pickup_position.x, entity.position.y - pickup_position.y}
    elseif direction == 2 then
      entity.drop_position = {entity.position.x + drop_position.y + drop_offset.y, entity.position.y - drop_position.x - drop_offset.x}
      entity.pickup_position = {entity.position.x + pickup_position.y, entity.position.y - pickup_position.x}
    end
  end
end


function bobmods.inserters.delete_gui(player_index)
  local globtable = global.bobmods.inserters[player_index]
  if globtable then
    if globtable.gui and globtable.gui.valid then globtable.gui.destroy() end
    globtable.entity = nil
    globtable.gui = nil
    globtable.pickup = nil
    globtable.drop = nil
    globtable.offset = nil
  end
end


function get_pickup_position(entity)
  return {x = entity.pickup_position.x - entity.position.x, y = entity.pickup_position.y - entity.position.y}
end

function set_pickup_position(entity, newpos)
  entity.pickup_position = {entity.position.x + newpos.x, entity.position.y + newpos.y}
end

function get_drop_position(entity)
  return {x = entity.drop_position.x - entity.position.x, y = entity.drop_position.y - entity.position.y}
end

function set_drop_position(entity, newpos)
  entity.drop_position = {entity.position.x + newpos.x, entity.position.y + newpos.y}
end


function check_position(pos1, pos2)
  local pos = {}
  pos.x = pos1.x - pos2.x
  pos.y = pos1.y - pos2.y
  if pos.x < 0 then pos.x = 0 - pos.x end
  if pos.y < 0 then pos.y = 0 - pos.y end
  if pos.x < 0.1 and pos.y < 0.1 then
    return true
  else
    return false
  end
end

function bobmods.inserters.normalise_tile_offset(tile_offset)
  local new_offset = {x = 0, y = 0}
  if tile_offset.x > 0 then new_offset.x = bobmods.inserters.offset end
  if tile_offset.x < 0 then new_offset.x = -bobmods.inserters.offset end
  if tile_offset.y > 0 then new_offset.y = bobmods.inserters.offset end
  if tile_offset.y < 0 then new_offset.y = -bobmods.inserters.offset end
  return new_offset
end


function bobmods.logistics.set_range(position_in, range)
  local position = {x = 0, y = 0}
  if position_in.x > 0.1 then
    position.x = range
  elseif position_in.x < -0.1 then
    position.x = -range
  else
    position.x = 0
  end
  if position_in.y > 0.1 then
    position.y = range
  elseif position_in.y < -0.1 then
    position.y = -range
  else
    position.y = 0
  end
  return position
end


function tech_unlocked(force, tech)
  if force.technologies[tech] then
    return force.technologies[tech].researched
  end
end


function bobmods.inserters.rotate_pickup(entity, player)
  local more_unlocked = tech_unlocked(player.force, bobmods.inserters.more_technology)
  local more2_unlocked = tech_unlocked(player.force, bobmods.inserters.more2_technology)
  local rotation = 1
  local position = {table = {}, steps = 0}
  local pickup_position = get_pickup_position(entity)

  -- Decide which position table to use
  if pickup_position.x > 2.1 or pickup_position.x < -2.1 or pickup_position.y > 2.1 or pickup_position.y < -2.1 then
    if more2_unlocked then
      position = bobmods.inserters.range3_24way
    elseif more_unlocked then
      position = bobmods.inserters.range3_8way
    else
      position = bobmods.inserters.range3_4way
    end
  elseif pickup_position.x > 1.1 or pickup_position.x < -1.1 or pickup_position.y > 1.1 or pickup_position.y < -1.1 then
    if more2_unlocked then
      position = bobmods.inserters.range2_16way
    elseif more_unlocked then
      position = bobmods.inserters.range2_8way
    else
      position = bobmods.inserters.range2_4way
    end
  else
    if more_unlocked then
      position = bobmods.inserters.range1_8way
    else
      position = bobmods.inserters.range1_4way
    end
  end

  -- Find current rotation
  for i, new_position in ipairs(position.table) do
    if check_position(pickup_position, new_position) then
      rotation = i
    end
  end
  -- Rotate
  rotation = rotation + 1
  if rotation > position.steps then rotation = rotation - position.steps end

  set_pickup_position(entity, position.table[rotation])
  entity.direction = entity.direction -- set direction to force update

  if entity == global.bobmods.inserters[player.index].entity then
    bobmods.inserters.refresh_position_checkboxes(entity, player)
  end
end

function bobmods.inserters.pickup_range(entity, player)
  local long_unlocked = tech_unlocked(player.force, bobmods.inserters.long_technology)
  local long2_unlocked = tech_unlocked(player.force, bobmods.inserters.long2_technology)
  local pickup_position = get_pickup_position(entity)
  local islong = false
  local islong2 = false

  if pickup_position.x > 2.1 or pickup_position.x < -2.1 or pickup_position.y > 2.1 or pickup_position.y < -2.1 then
    islong2 = true
  elseif pickup_position.x > 1.1 or pickup_position.x < -1.1 or pickup_position.y > 1.1 or pickup_position.y < -1.1 then
    islong = true
  end

  if long_unlocked or long2_unlocked then
    if islong2 then
      pickup_position.x = bobmods.math.floor(pickup_position.x / 3)
      pickup_position.y = bobmods.math.floor(pickup_position.y / 3)
    elseif islong then
      if long2_unlocked then
        pickup_position.x = bobmods.math.floor(pickup_position.x * 1.5)
        pickup_position.y = bobmods.math.floor(pickup_position.y * 1.5)
      else
        pickup_position.x = bobmods.math.floor(pickup_position.x / 2)
        pickup_position.y = bobmods.math.floor(pickup_position.y / 2)
      end
    else
      pickup_position.x = bobmods.math.floor(pickup_position.x * 2)
      pickup_position.y = bobmods.math.floor(pickup_position.y * 2)
    end
    set_pickup_position(entity, pickup_position)
    entity.direction = entity.direction -- set direction to force update
    if entity == global.bobmods.inserters[player.index].entity then
      bobmods.inserters.refresh_position_checkboxes(entity, player)
    end
  end
end


function bobmods.inserters.drop_range(entity, player)
  local long_unlocked = tech_unlocked(player.force, bobmods.inserters.long_technology)
  local long2_unlocked = tech_unlocked(player.force, bobmods.inserters.long2_technology)

  local drop_position = get_drop_position(entity)
  local tile_position = {x = bobmods.math.round(drop_position.x), y = bobmods.math.round(drop_position.y)}
  local tile_offset = bobmods.inserters.normalise_tile_offset({x = bobmods.math.offset(drop_position.x), y = bobmods.math.offset(drop_position.y)})

  local islong = false
  local islong2 = false
  local dolong = false

  if tile_position.x > 2.1 or tile_position.x < -2.1 or tile_position.y > 2.1 or tile_position.y < -2.1 then
    islong2 = true
  elseif tile_position.x > 1.1 or tile_position.x < -1.1 or tile_position.y > 1.1 or tile_position.y < -1.1 then
    islong = true
  end

  if long_unlocked or long2_unlocked then
    if near_unlocked then
      if tile_position.x > 0 and tile_offset.x > 0 then
        dolong = true
      elseif tile_position.x < 0 and tile_offset.x < 0 then
        dolong = true
      elseif tile_position.y > 0 and tile_offset.y > 0 then
        dolong = true
      elseif tile_position.y < 0 and tile_offset.y < 0 then
        dolong = true
      end
    else
      dolong = true
    end
  end

  if dolong then
    if islong2 then
      tile_position.x = bobmods.math.floor(tile_position.x / 3)
      tile_position.y = bobmods.math.floor(tile_position.y / 3)
    elseif islong then
      if long2_unlocked then
        tile_position.x = bobmods.math.floor(tile_position.x * 1.5)
        tile_position.y = bobmods.math.floor(tile_position.y * 1.5)
      else
        tile_position.x = bobmods.math.floor(tile_position.x / 2)
        tile_position.y = bobmods.math.floor(tile_position.y / 2)
      end
    else
      tile_position.x = bobmods.math.floor(tile_position.x * 2)
      tile_position.y = bobmods.math.floor(tile_position.y * 2)
    end
  end

  drop_position.x = tile_position.x + tile_offset.x
  drop_position.y = tile_position.y + tile_offset.y
  set_drop_position(entity, drop_position)
  entity.direction = entity.direction -- set direction to force update
  if entity == global.bobmods.inserters[player.index].entity then
    bobmods.inserters.refresh_position_checkboxes(entity, player)
  end
end

function bobmods.inserters.long_range(entity, player)
  local long_unlocked = tech_unlocked(player.force, bobmods.inserters.long_technology)
  local long2_unlocked = tech_unlocked(player.force, bobmods.inserters.long2_technology)

  local pickup_position = get_pickup_position(entity)
  local drop_position = get_drop_position(entity)
  local tile_position = {x = bobmods.math.round(drop_position.x), y = bobmods.math.round(drop_position.y)}
  local tile_offset = bobmods.inserters.normalise_tile_offset({x = bobmods.math.offset(drop_position.x), y = bobmods.math.offset(drop_position.y)})

  local islong = false
  local islong2 = false

  if pickup_position.x > 2.1 or pickup_position.x < -2.1 or pickup_position.y > 2.1 or pickup_position.y < -2.1 then
    islong2 = true
  elseif pickup_position.x > 1.1 or pickup_position.x < -1.1 or pickup_position.y > 1.1 or pickup_position.y < -1.1 then
    islong = true
  end

  if long_unlocked or long2_unlocked then
    if islong2 then
      pickup_position = bobmods.logistics.set_range(pickup_position, 1)
      tile_position = bobmods.logistics.set_range(tile_position, 1)
    elseif islong then
      if long2_unlocked then
        pickup_position = bobmods.logistics.set_range(pickup_position, 3)
        tile_position = bobmods.logistics.set_range(tile_position, 3)
      else
        pickup_position = bobmods.logistics.set_range(pickup_position, 1)
        tile_position = bobmods.logistics.set_range(tile_position, 1)
      end
    else
      pickup_position = bobmods.logistics.set_range(pickup_position, 2)
      tile_position = bobmods.logistics.set_range(tile_position, 2)
    end
  end

  drop_position.x = tile_position.x + tile_offset.x
  drop_position.y = tile_position.y + tile_offset.y
  set_drop_position(entity, drop_position)
  set_pickup_position(entity, pickup_position)
  entity.direction = entity.direction -- set direction to force update
  if entity == global.bobmods.inserters[player.index].entity then
    bobmods.inserters.refresh_position_checkboxes(entity, player)
  end
end


function bobmods.inserters.near_range(entity, player)
  local near_unlocked = tech_unlocked(player.force, bobmods.inserters.near_technology)

  local drop_position = get_drop_position(entity)
  local tile_position = {x = bobmods.math.round(drop_position.x), y = bobmods.math.round(drop_position.y)}
  local tile_offset = bobmods.inserters.normalise_tile_offset({x = bobmods.math.offset(drop_position.x), y = bobmods.math.offset(drop_position.y)})

  if near_unlocked then
    if (tile_offset.x == 0 and tile_offset.y == 0) or
      (tile_offset.x == 0 and tile_position.x ~= 0) or
      (tile_offset.y == 0 and tile_position.y ~= 0) then
      tile_offset = bobmods.inserters.normalise_tile_offset({x = tile_position.x, y = tile_position.y})
    else
      if tile_position.x ~= 0 then tile_offset.x = 0 - tile_offset.x end
      if tile_position.y ~= 0 then tile_offset.y = 0 - tile_offset.y end
    end

    if (tile_position.y ~= 0 and tile_position.x ~= 0)
    and (
      (((tile_position.x > 0 and tile_offset.x < 0) or (tile_offset.x > 0 and tile_position.x < 0)) and  -- x near
      ((tile_position.y > 0 and tile_offset.y > 0) or (tile_offset.y < 0 and tile_position.y < 0)))   -- y far
    or
      (((tile_position.x > 0 and tile_offset.x > 0) or (tile_offset.x < 0 and tile_position.x < 0)) and  -- x far
      ((tile_position.y > 0 and tile_offset.y < 0) or (tile_offset.y > 0 and tile_position.y < 0))) -- y near
    ) then
      tile_offset = bobmods.inserters.normalise_tile_offset({x = tile_position.x, y = tile_position.y})
    end
  end

  drop_position.x = tile_position.x + tile_offset.x
  drop_position.y = tile_position.y + tile_offset.y
  set_drop_position(entity, drop_position)
  entity.direction = entity.direction -- set direction to force update
  if entity == global.bobmods.inserters[player.index].entity then
    bobmods.inserters.refresh_position_checkboxes(entity, player)
  end
end


function bobmods.logistics.create_gui(player_index)
  local player = game.players[player_index]
  local long_unlocked = tech_unlocked(game.players[player_index].force, bobmods.inserters.long_technology)
  local more_unlocked = tech_unlocked(game.players[player_index].force, bobmods.inserters.more_technology)
  local near_unlocked = tech_unlocked(game.players[player_index].force, bobmods.inserters.near_technology)

  if player.gui.left.bob_logistics_inserter_gui then
    player.gui.left.bob_logistics_inserter_gui.destroy()
  end

  local gui = player.gui.left.add({type = "frame", name = "bob_logistics_inserter_gui", direction = "vertical"})
  gui.add({type = "table", name = "table", column_count = 1, style = "bob_table"})

  if long_unlocked or near_unlocked then
    gui.table.add({type = "checkbox", name = "bob_logistics_inserter_enabled", state = global.bobmods.logistics[player_index].enabled, caption = {"gui.bob-logistics-enabled"}})
  end
  if global.bobmods.logistics[player_index].enabled then
    if long_unlocked then
      if more_unlocked then
        gui.table.add({type = "checkbox", name = "bob_logistics_inserter_long_in", state = global.bobmods.logistics[player_index].long_in, caption = {"gui.bob-logistics-pickup"}})
        gui.table.add({type = "checkbox", name = "bob_logistics_inserter_long_out", state = global.bobmods.logistics[player_index].long_out, caption = {"gui.bob-logistics-drop"}})
      else
        gui.table.add({type = "checkbox", name = "bob_logistics_inserter_long_in", state = global.bobmods.logistics[player_index].long_in, caption = {"gui.bob-logistics-long"}})
      end
    end
    if near_unlocked then
      gui.table.add({type = "checkbox", name = "bob_logistics_inserter_near", state = global.bobmods.logistics[player_index].near, caption = {"gui.bob-logistics-near"}})
    end
  end

  if remote.interfaces.bobinserters then
    gui.table.add({type = "checkbox", name = "bob_logistics_inserter_enabled2", state = global.bobmods.logistics[player_index].enabled2, caption = {"gui.bob-logistics-enabled2"}})
    if global.bobmods.logistics[player_index].enabled2 then
      remote.call("bobinserters", "draw_gui", {player_index = player_index, gui = gui, name = "bob_logistics", pickup = global.bobmods.logistics[player_index].pickup, drop = global.bobmods.logistics[player_index].drop, offset = global.bobmods.logistics[player_index].offset})
    end
  end
end


function bobmods.inserters.open_gui(entity, player)
  bobmods.inserters.delete_gui(player.index)

  local globtable = global.bobmods.inserters[player.index]
  globtable.entity = entity

  local long_unlocked = tech_unlocked(player.force, bobmods.inserters.long_technology)
  local long2_unlocked = tech_unlocked(player.force, bobmods.inserters.long2_technology)
  local more_unlocked = tech_unlocked(player.force, bobmods.inserters.more_technology)
  local more2_unlocked = tech_unlocked(player.force, bobmods.inserters.more2_technology)
  local near_unlocked = tech_unlocked(player.force, bobmods.inserters.near_technology)

  local pickup_position = get_pickup_position(entity)
  local drop_position = get_drop_position(entity)
  local tile_position = {x = bobmods.math.round(drop_position.x), y = bobmods.math.round(drop_position.y)}
  local tile_offset = bobmods.inserters.normalise_tile_offset({x = bobmods.math.offset(drop_position.x), y = bobmods.math.offset(drop_position.y)})

  local isshort = false
  local islong = false
  local islong2 = false

  if pickup_position.x > 2.1 or pickup_position.x < -2.1 or pickup_position.y > 2.1 or pickup_position.y < -2.1 then
    islong2 = true
  elseif pickup_position.x > 1.1 or pickup_position.x < -1.1 or pickup_position.y > 1.1 or pickup_position.y < -1.1 then
    islong = true
  else
    isshort = true
  end
  if tile_position.x > 2.1 or tile_position.x < -2.1 or tile_position.y > 2.1 or tile_position.y < -2.1 then
    islong2 = true
  elseif tile_position.x > 1.1 or tile_position.x < -1.1 or tile_position.y > 1.1 or tile_position.y < -1.1 then
    islong = true
  else
    isshort = true
  end


  if globtable.position == "left" then
    globtable.gui = player.gui.left.add({type = "frame", name = "bob_inserter_gui", direction = "vertical", caption = {"gui.bob-inserter-gui"}})
  else
    globtable.gui = player.gui.center.add({type = "frame", name = "bob_inserter_gui", direction = "vertical", caption = {"gui.bob-inserter-gui"}})
    player.opened = globtable.gui
  end
  local gui = globtable.gui

  if globtable.position == "center" then
    gui.add({type = "label", name = "entity_name", caption = {"entity-name." .. entity.name}})
  end

  if near_unlocked then
    gui.add({type = "table", name = "main_table", column_count = 5, style = "bob_table"})
  else
    gui.add({type = "table", name = "main_table", column_count = 3, style = "bob_table"})
  end

  if globtable.position == "center" then
    gui.add({type = "flow", name = "button_flow", style = "bob_button_flow"})
    gui.button_flow.add({type = "frame", name = "filler", style = "bob_button_filler"})
    gui.button_flow.add({type = "button", name = "bob_inserter_gui_close", style = "confirm_button", caption = {"gui.close"}})
  end

  gui.main_table.add({type = "table", name = "pickup", column_count = 1, style = "bob_table"})
  gui.main_table.add({type = "label", name = "spacer1", caption = "     " })
  gui.main_table.add({type = "table", name = "drop", column_count = 1, style = "bob_table"})
  if near_unlocked then
    gui.main_table.add({type = "label", name = "spacer2", caption = "     " })
    gui.main_table.add({type = "table", name = "drop_offset", column_count = 1, style = "bob_table"})
    gui.main_table.drop_offset.add({type = "label", name = "entity_name", caption = {"gui.bob-inserter-offset"}})
    globtable.offset = gui.main_table.drop_offset.add({type = "table", name = "bob_inserter_gui_drop_offset", column_count = 3, style = "bob_table"})
    bobmods.inserters.draw_offset_grid(gui.main_table.drop_offset.bob_inserter_gui_drop_offset, tile_offset)
  end

  gui.main_table.pickup.add({type = "label", name = "entity_name", caption = {"gui.bob-inserter-pickup"}})
  gui.main_table.drop.add({type = "label", name = "entity_name", caption = {"gui.bob-inserter-drop"}})

  local column_count = 5

  if long2_unlocked or islong2 then
    column_count = 7
  elseif long_unlocked or islong then
    column_count = 5
  else
    column_count = 3
  end

  globtable.pickup = gui.main_table.pickup.add({type = "table", name = "bob_inserter_gui_pickup", column_count = column_count, style = "bob_table"})
  globtable.drop = gui.main_table.drop.add({type = "table", name = "bob_inserter_gui_drop", column_count = column_count, style = "bob_table"})

  bobmods.inserters.draw_button_grid(gui.main_table.pickup.bob_inserter_gui_pickup, pickup_position, "bob_inserter_checkbox_pickup", long_unlocked, more_unlocked, islong, long2_unlocked, more2_unlocked, islong2, isshort)
  bobmods.inserters.draw_button_grid(gui.main_table.drop.bob_inserter_gui_drop, tile_position, "bob_inserter_checkbox_drop", long_unlocked, more_unlocked, islong, long2_unlocked, more2_unlocked, islong2, isshort)
end


function bobmods.inserters.draw_offset_grid(gui, position)
  gui.add({type = "checkbox", name = "button1", state = false, style = "bob_inserter_checkbox_small"})
  gui.add({type = "checkbox", name = "button2", state = false, style = "bob_inserter_checkbox_small"})
  gui.add({type = "checkbox", name = "button3", state = false, style = "bob_inserter_checkbox_small"})
  gui.add({type = "checkbox", name = "button4", state = false, style = "bob_inserter_checkbox_small"})
  gui.add({type = "checkbox", name = "button5", state = false, style = "bob_inserter_checkbox_small"})
  gui.add({type = "checkbox", name = "button6", state = false, style = "bob_inserter_checkbox_small"})
  gui.add({type = "checkbox", name = "button7", state = false, style = "bob_inserter_checkbox_small"})
  gui.add({type = "checkbox", name = "button8", state = false, style = "bob_inserter_checkbox_small"})
  gui.add({type = "checkbox", name = "button9", state = false, style = "bob_inserter_checkbox_small"})

  bobmods.inserters.draw_button_offset_check(gui, position)
end

function bobmods.inserters.draw_button_grid(gui, position, style, long, more, islong, long2, more2, islong2, isshort)
  if long2 or islong2 then
    if more then
      gui.add({type = "checkbox", name = "button26", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank26", state = false, style = "bob_inserter_blank"})
    end
    if more2 then
      gui.add({type = "checkbox", name = "button27", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank27", state = false, style = "bob_inserter_blank"})
    end
    if more2 then
      gui.add({type = "checkbox", name = "button28", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank28", state = false, style = "bob_inserter_blank"})
    end
    gui.add({type = "checkbox", name = "button29", state = false, style = style})
    if more2 then
      gui.add({type = "checkbox", name = "button30", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank30", state = false, style = "bob_inserter_blank"})
    end
    if more2 then
      gui.add({type = "checkbox", name = "button31", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank31", state = false, style = "bob_inserter_blank"})
    end
    if more then
      gui.add({type = "checkbox", name = "button32", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank32", state = false, style = "bob_inserter_blank"})
    end
  end

  if long2 or islong2 then
    if more2 then
      gui.add({type = "checkbox", name = "button33", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank33", state = false, style = "bob_inserter_blank"})
    end
  end
  if long2 or islong2 or long or islong then
    if more and (long or islong) then
      gui.add({type = "checkbox", name = "button1", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank1", state = false, style = "bob_inserter_blank"})
    end
    if more2 and (long or islong) then
      gui.add({type = "checkbox", name = "button2", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank2", state = false, style = "bob_inserter_blank"})
    end
    if long or islong then 
      gui.add({type = "checkbox", name = "button3", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank3", state = false, style = "bob_inserter_blank"})
    end
    if more2 and (long or islong) then
      gui.add({type = "checkbox", name = "button4", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank4", state = false, style = "bob_inserter_blank"})
    end
    if more and (long or islong) then
      gui.add({type = "checkbox", name = "button5", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank5", state = false, style = "bob_inserter_blank"})
    end
  end
  if long2 or islong2 then
    if more2 then
      gui.add({type = "checkbox", name = "button34", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank34", state = false, style = "bob_inserter_blank"})
    end
  end

  if long2 or islong2 then
    if more2 then
      gui.add({type = "checkbox", name = "button35", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank35", state = false, style = "bob_inserter_blank"})
    end
  end
  if long2 or islong2 or long or islong then
    if more2 and (long or islong) then
      gui.add({type = "checkbox", name = "button6", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank6", state = false, style = "bob_inserter_blank"})
    end
  end
  if more and (long or long2 or isshort) then
    gui.add({type = "checkbox", name = "button7", state = false, style = style})
  else
    gui.add({type = "checkbox", name = "blank7", state = false, style = "bob_inserter_blank"})
  end
  if long or long2 or isshort then
    gui.add({type = "checkbox", name = "button8", state = false, style = style})
  else
    gui.add({type = "checkbox", name = "blank8", state = false, style = "bob_inserter_blank"})
  end
  if more and (long or long2 or isshort) then
    gui.add({type = "checkbox", name = "button9", state = false, style = style})
  else
    gui.add({type = "checkbox", name = "blank9", state = false, style = "bob_inserter_blank"})
  end
  if long2 or islong2 or long or islong then
    if more2 and (long or islong) then
      gui.add({type = "checkbox", name = "button10", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank10", state = false, style = "bob_inserter_blank"})
    end
  end
  if long2 or islong2 then
    if more2 then
      gui.add({type = "checkbox", name = "button36", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank36", state = false, style = "bob_inserter_blank"})
    end
  end

  if long2 or islong2 then
    gui.add({type = "checkbox", name = "button37", state = false, style = style})
  end
  if long2 or islong2 or long or islong then
    if long or islong then
      gui.add({type = "checkbox", name = "button11", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank11", state = false, style = "bob_inserter_blank"})
    end
  end
  if long or long2 or isshort then
    gui.add({type = "checkbox", name = "button12", state = false, style = style})
  else
    gui.add({type = "checkbox", name = "blank12", state = false, style = "bob_inserter_blank"})
  end
  gui.add({type = "checkbox", name = "middle", state = false, style = "bob_inserter_middle"})
  if long or long2 or isshort then
    gui.add({type = "checkbox", name = "button14", state = false, style = style})
  else
    gui.add({type = "checkbox", name = "blank14", state = false, style = "bob_inserter_blank"})
  end
  if long2 or islong2 or long or islong then
    if long or islong then
      gui.add({type = "checkbox", name = "button15", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank15", state = false, style = "bob_inserter_blank"})
    end
  end
  if long2 or islong2 then
    gui.add({type = "checkbox", name = "button38", state = false, style = style})
  end

  if long2 or islong2 then
    if more2 then
      gui.add({type = "checkbox", name = "button39", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank39", state = false, style = "bob_inserter_blank"})
    end
  end
  if long2 or islong2 or long or islong then
    if more2 and (long or islong) then
      gui.add({type = "checkbox", name = "button16", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank16", state = false, style = "bob_inserter_blank"})
    end
  end
  if more and (long or long2 or isshort) then
    gui.add({type = "checkbox", name = "button17", state = false, style = style})
  else
    gui.add({type = "checkbox", name = "blank17", state = false, style = "bob_inserter_blank"})
  end
  if long or long2 or isshort then
    gui.add({type = "checkbox", name = "button18", state = false, style = style})
  else
    gui.add({type = "checkbox", name = "blank18", state = false, style = "bob_inserter_blank"})
  end
  if more and (long or long2 or isshort)  then
    gui.add({type = "checkbox", name = "button19", state = false, style = style})
  else
    gui.add({type = "checkbox", name = "blank19", state = false, style = "bob_inserter_blank"})
  end
  if long2 or islong2 or long or islong then
    if more2 and (long or islong) then
      gui.add({type = "checkbox", name = "button20", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank20", state = false, style = "bob_inserter_blank"})
    end
  end
  if long2 or islong2 then
    if more2 then
      gui.add({type = "checkbox", name = "button40", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank40", state = false, style = "bob_inserter_blank"})
    end
  end

  if long2 or islong2 then
    if more2 then
      gui.add({type = "checkbox", name = "button41", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank41", state = false, style = "bob_inserter_blank"})
    end
  end
  if long2 or islong2 or long or islong then
    if more and (long or islong) then
      gui.add({type = "checkbox", name = "button21", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank21", state = false, style = "bob_inserter_blank"})
    end
    if more2 and (long or islong) then
      gui.add({type = "checkbox", name = "button22", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank22", state = false, style = "bob_inserter_blank"})
    end
    if long or islong then
      gui.add({type = "checkbox", name = "button23", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank23", state = false, style = "bob_inserter_blank"})
    end
    if more2 and (long or islong) then
      gui.add({type = "checkbox", name = "button24", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank24", state = false, style = "bob_inserter_blank"})
    end
    if more and (long or islong) then
      gui.add({type = "checkbox", name = "button25", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank25", state = false, style = "bob_inserter_blank"})
    end
  end
  if long2 or islong2 then
    if more2 then
      gui.add({type = "checkbox", name = "button42", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank42", state = false, style = "bob_inserter_blank"})
    end
  end

  if long2 or islong2 then
    if more then
      gui.add({type = "checkbox", name = "button43", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank43", state = false, style = "bob_inserter_blank"})
    end
    if more2 then
      gui.add({type = "checkbox", name = "button44", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank44", state = false, style = "bob_inserter_blank"})
    end
    if more2 then
      gui.add({type = "checkbox", name = "button45", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank45", state = false, style = "bob_inserter_blank"})
    end
    gui.add({type = "checkbox", name = "button46", state = false, style = style})
    if more2 then
      gui.add({type = "checkbox", name = "button47", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank47", state = false, style = "bob_inserter_blank"})
    end
    if more2 then
      gui.add({type = "checkbox", name = "button48", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank48", state = false, style = "bob_inserter_blank"})
    end
    if more then
      gui.add({type = "checkbox", name = "button49", state = false, style = style})
    else
      gui.add({type = "checkbox", name = "blank49", state = false, style = "bob_inserter_blank"})
    end
  end

  bobmods.inserters.draw_button_position_check(gui, position)
end


function bobmods.inserters.draw_button_position_check(gui, position)
  for i, new_position in ipairs(bobmods.inserters.positions) do
    if gui["button" .. i] then
      gui["button" .. i].state = false
      if check_position(position, new_position) then
        gui["button" .. i].state = true
      end
    end
  end
end

function bobmods.inserters.draw_button_offset_check(gui, position)
  for i, new_position in ipairs(bobmods.inserters.offset_positions) do
    if gui["button" .. i] then
      gui["button" .. i].state = false
      if check_position(position, new_position) then
        gui["button" .. i].state = true
      end
    end
  end
end

function bobmods.inserters.refresh_position_checkboxes(entity, player)
  local pickup_position = get_pickup_position(entity)
  local drop_position = get_drop_position(entity)
  local tile_position = {x = bobmods.math.round(drop_position.x), y = bobmods.math.round(drop_position.y)}
  local tile_offset = bobmods.inserters.normalise_tile_offset({x = bobmods.math.offset(drop_position.x), y = bobmods.math.offset(drop_position.y)})

  if global.bobmods.inserters[player.index].pickup then
    bobmods.inserters.draw_button_position_check(global.bobmods.inserters[player.index].pickup, pickup_position)
  end
  if global.bobmods.inserters[player.index].drop then
    bobmods.inserters.draw_button_position_check(global.bobmods.inserters[player.index].drop, tile_position)
  end
  if global.bobmods.inserters[player.index].offset then
    bobmods.inserters.draw_button_offset_check(global.bobmods.inserters[player.index].offset, tile_offset)
  end
end



function  bobmods.inserters.gui_pickup_click(entity, element)
  local pickup_position = get_pickup_position(entity)
  for i, new_position in ipairs(bobmods.inserters.positions) do
    if element.name == "button" .. i then
      pickup_position = new_position
      set_pickup_position(entity, pickup_position)
      entity.direction = entity.direction -- set direction to force update
    end
  end
  bobmods.inserters.draw_button_position_check(element.parent, pickup_position)
end

function  bobmods.inserters.gui_drop_click(entity, element)
  local drop_position = get_drop_position(entity)
  local tile_position = {x = bobmods.math.round(drop_position.x), y = bobmods.math.round(drop_position.y)}
  local tile_offset = {x = bobmods.math.offset(drop_position.x), y = bobmods.math.offset(drop_position.y)}
  for i, new_position in ipairs(bobmods.inserters.positions) do
    if element.name == "button" .. i then

      local new_offset = {x = tile_offset.x, y = tile_offset.y}

      if (tile_position.x > 0 and new_position.x < 0) or (tile_position.x < 0 and new_position.x > 0) then
        new_offset.x = 0 - tile_offset.x
      elseif tile_position.x == 0 and new_position.x ~= 0 then
        if (new_position.x > 0 and tile_position.y > 0) or (new_position.x < 0 and tile_position.y < 0) then
          new_offset.x = tile_offset.y
        else
          new_offset.x = 0 - tile_offset.y
        end
      elseif tile_position.x ~= 0 and new_position.x == 0 then
        new_offset.x = 0
      end

      if (tile_position.y > 0 and new_position.y < 0) or (tile_position.y < 0 and new_position.y > 0) then
        new_offset.y = 0 - tile_offset.y
      elseif tile_position.y == 0 and new_position.y ~= 0 then
        if (new_position.y > 0 and tile_position.x > 0) or (new_position.y < 0 and tile_position.x < 0) then
          new_offset.y = tile_offset.x
        else
          new_offset.y = 0 - tile_offset.x
        end
      elseif tile_position.y ~= 0 and new_position.y == 0 then
        new_offset.y = 0
      end

      tile_position = new_position
      tile_offset = bobmods.inserters.normalise_tile_offset(new_offset)

      drop_position.x = tile_position.x + tile_offset.x
      drop_position.y = tile_position.y + tile_offset.y
      set_drop_position(entity, drop_position)
      entity.direction = entity.direction -- set direction to force update
    end
  end
  bobmods.inserters.refresh_position_checkboxes(entity, game.players[element.player_index])
end

function  bobmods.inserters.gui_offset_click(entity, element)
  local drop_position = get_drop_position(entity)
  local tile_position = {x = bobmods.math.round(drop_position.x), y = bobmods.math.round(drop_position.y)}
  local tile_offset = bobmods.inserters.normalise_tile_offset({x = bobmods.math.offset(drop_position.x), y = bobmods.math.offset(drop_position.y)})

  for i, new_position in ipairs(bobmods.inserters.offset_positions) do
    if element.name == "button" .. i then
      tile_offset = bobmods.inserters.offset_positions[i]
      drop_position.x = tile_position.x + tile_offset.x
      drop_position.y = tile_position.y + tile_offset.y
      set_drop_position(entity, drop_position)
      entity.direction = entity.direction -- set direction to force update
    end
  end
  bobmods.inserters.draw_button_offset_check(element.parent, tile_offset)
end

remote.add_interface("bobinserters", {
--[[
This function will draw the inserters grid GUI as used in the GUI added by this mod in any GUI you choose. This mod will not respond to those buttons being pressed.
This function takes the following variables:
gui: The GUI element to draw this GUI inside of.
name: The name prefix for the main 3 tables.
player_index: obvious
pickup: the index in table bobmods.inserters.positions to define the pickup location.
drop: the index in table bobmods.inserters.positions to define the drop location.
offset: the index in table bobmods.inserters.offset_positions to define the offset location within the drop tile.
]]--
  draw_gui = function(data)
    local long_unlocked = tech_unlocked(game.players[data.player_index].force, bobmods.inserters.long_technology)
    local long2_unlocked = tech_unlocked(game.players[data.player_index].force, bobmods.inserters.long2_technology)
    local more_unlocked = tech_unlocked(game.players[data.player_index].force, bobmods.inserters.more_technology)
    local more2_unlocked = tech_unlocked(game.players[data.player_index].force, bobmods.inserters.more2_technology)
    local near_unlocked = tech_unlocked(game.players[data.player_index].force, bobmods.inserters.near_technology)

    local isshort = false
    local islong = false
    local islong2 = false

    local pickup_position = bobmods.inserters.positions[data.pickup]
    local drop_position = bobmods.inserters.positions[data.drop]
    local offset_position = bobmods.inserters.offset_positions[data.offset]

    if pickup_position.x > 2.1 or pickup_position.x < -2.1 or pickup_position.y > 2.1 or pickup_position.y < -2.1 then
      islong2 = true
    elseif pickup_position.x > 1.1 or pickup_position.x < -1.1 or pickup_position.y > 1.1 or pickup_position.y < -1.1 then
      islong = true
    else
      isshort = true
    end
    if drop_position.x > 2.1 or drop_position.x < -2.1 or drop_position.y > 2.1 or drop_position.y < -2.1 then
      islong2 = true
    elseif drop_position.x > 1.1 or drop_position.x < -1.1 or drop_position.y > 1.1 or drop_position.y < -1.1 then
      islong = true
    else
      isshort = true
    end


    if near_unlocked then
      data.gui.add({type = "table", name = "main_table", column_count = 5, style = "bob_table"})
    else
      data.gui.add({type = "table", name = "main_table", column_count = 3, style = "bob_table"})
    end

    data.gui.main_table.add({type = "table", name = "pickup", column_count = 1, style = "bob_table"})
    data.gui.main_table.add({type = "label", name = "spacer1", caption = "     " })
    data.gui.main_table.add({type = "table", name = "drop", column_count = 1, style = "bob_table"})

    data.gui.main_table.pickup.add({type = "label", name = "entity_name", caption = {"gui.bob-inserter-pickup"}})
    data.gui.main_table.drop.add({type = "label", name = "entity_name", caption = {"gui.bob-inserter-drop"}})

    local column_count = 5
    if long2_unlocked or islong2 then
      column_count = 7
    elseif long_unlocked or islong then
      column_count = 5
    else
      column_count = 3
    end

    local gui_pickup = data.gui.main_table.pickup.add({type = "table", name = data.name .. "_pickup", column_count = column_count, style = "bob_table"})
    local gui_drop = data.gui.main_table.drop.add({type = "table", name = data.name .. "_drop", column_count = column_count, style = "bob_table"})

    bobmods.inserters.draw_button_grid(gui_pickup, pickup_position, "bob_inserter_checkbox_pickup", long_unlocked, more_unlocked, islong, long2_unlocked, more2_unlocked, islong2, isshort)
    bobmods.inserters.draw_button_grid(gui_drop, drop_position, "bob_inserter_checkbox_drop", long_unlocked, more_unlocked, islong, long2_unlocked, more2_unlocked, islong2, isshort)

    if near_unlocked then
      data.gui.main_table.add({type = "label", name = "spacer2", caption = "     " })
      data.gui.main_table.add({type = "table", name = "offset", column_count = 1, style = "bob_table"})
      data.gui.main_table.offset.add({type = "label", name = "entity_name", caption = {"gui.bob-inserter-offset"}})
      local gui_offset = data.gui.main_table.offset.add({type = "table", name = data.name .. "_offset", column_count = 3, style = "bob_table"})
      bobmods.inserters.draw_offset_grid(gui_offset, offset_position)
    end
  end,

--[[
This function will refresh the GUI checkboxes, designed to refresh a drawn GUI grid after you click one of it's buttons.
This function takes the following variables:
gui: the GUI table that the buttons are drawn inside of.
position: the index in table bobmods.inserters.positions to define the pickup/drop location.
]]--
  draw_button_position_check = function(data)
    bobmods.inserters.draw_button_position_check(data.gui, bobmods.inserters.positions[data.position])
  end,

--[[
This function will refresh the GUI checkboxes, designed to refresh a drawn GUI grid after you click one of it's buttons.
This function takes the following variables:
gui: the GUI table that the buttons are drawn inside of.
position: the index in table bobmods.inserters.offset_positions to define the offset location.
]]--
  draw_button_offset_check = function(data)
    bobmods.inserters.draw_button_offset_check(data.gui, bobmods.inserters.offset_positions[data.position])
  end,

--[[
This function will take the value position in the bobmods.inserters.positions table, and return the coordinates.
]]--
  get_position = function(data)
    return bobmods.inserters.positions[data.position]
  end,

--[[
This function will take the value position in the bobmods.inserters.offset_positions table, and return the coordinates.
]]--
  get_offset = function(data)
    return bobmods.inserters.offset_positions[data.position]
  end,

--[[
Pass this function the name of an inserter, and it will be ignored.
EG: remote.call("bobinserters", "blacklist_inserter", "burner-inserter") will blacklist the burner inserter.
]]--
  blacklist_inserter = function(data)
    bobmods.inserters.create_global_table_basic()
    global.bobmods.inserters.blacklist[data] = true
  end,
--[[
Pass this function a table of names of inserters, and they will be ignored.
EG: remote.call("bobinserters", "blacklist_inserters", {"burner-inserter"}) will blacklist the burner inserter.
]]--
  blacklist_inserters = function(data)
    bobmods.inserters.create_global_table_basic()
    for i, inserter in pairs(data) do
      global.bobmods.inserters.blacklist[inserter] = true
    end
  end
}
)


