function make_handlers ()
  local handlers = {}
  local max_id = 0
  
  for surface_index, surface in pairs (game.surfaces) do
    for chunk in surface.get_chunks() do
      max_id = max_id + 1
      local left_top = {x = chunk.x*32, y = chunk.y*32}
      local right_bottom = {x=left_top.x+32, y=left_top.y+32}
      table.insert (handlers, {surface = surface, left_top=left_top, right_bottom=right_bottom})
    end
    -- log ('amount'..amount)
  end
  global.handlers = handlers
  global.max_id = max_id
  return max_id
end

function on_tick()
  local max_pollution = 1000
  local id = global.id or 1
  local max_id = global.max_id or 0
  
  if id > max_id then
    max_id = make_handlers ()
    id = 1
      -- local time_to_live = 60*30
      -- local chunks_per_tick = math.ceil(max_id / (time_to_live))
      -- time_to_live = math.ceil(max_id / (chunks_per_tick)) + 1
      -- game.print ('max_id:'..max_id..' chunks_per_tick: '..chunks_per_tick..' time_to_live: '..time_to_live)
  end
  
  local time_to_live = 60*30
  local chunks_per_tick = math.ceil(max_id / (time_to_live))
  time_to_live = math.ceil(max_id / (chunks_per_tick)) + 1
  
  for i = 1, chunks_per_tick do -- by 3144 60 ups
    -- game.print ('id: '..id)
    if id <= max_id then
      local handler = global.handlers[id]
      local surface = handler.surface
      local position = handler.left_top
      local pollution = math.min (surface.get_pollution(position), max_pollution)
      if pollution > 0 then
        local color = (pollution/max_pollution) * 0.3
        local alpha = (pollution/max_pollution) * 0.8 -- 0.8 is pretty hard
        rendering.draw_rectangle{
          color={r=color, g=color, b=color, a=alpha},      
          filled=true,      
          left_top =   handler.left_top,      
          right_bottom=handler.right_bottom,
          time_to_live = (time_to_live),
          surface=surface} 
        -- game.print ('color: '..color..' alpha: '..alpha)
      end
    id = id + 1
    else

    end

  end
  global.id = id
  
  -- for surface_index, surface in pairs (game.surfaces) do
    -- local amount = 0
    -- for chunk in surface.get_chunks() do
      -- amount = amount + 1
      -- local position = {x = chunk.x*32, y = chunk.y*32}
      -- local pollution = math.min (surface.get_pollution(position), max_pollution)
      -- local color = (pollution/max_pollution) * 0.3
      -- local alpha = (pollution/max_pollution) * 0.8
      -- rendering.draw_rectangle{
        -- color={r=color, g=color, b=color, a=alpha},      
        -- filled=true,      
        -- left_top =   {x=position.x, y=position.y},      
        -- right_bottom={x=position.x+32, y=position.y+32},
        -- time_to_live = 2,
        -- surface=surface} 
    -- end
    -- log ('amount'..amount)
  -- end
end





script.on_event(defines.events.on_tick, on_tick)


-- script.on_init(try_init)

-- script.on_configuration_changed(try_init)

-- script.on_nth_tick(60, on_nth_tick)



-- on_nth_tick(tick, f)
-- Register a handler to run on nth tick(s).

-- Parameters
-- tick :: uint or array of uint: The nth-tick(s) to invoke the handler on. Passing nil will unregister all nth-tick handlers.
-- f :: function(NthTickEvent): The handler to run. Passing nil will unregister the handler for the provided ticks.




-- script.on_event(defines.events.on_built_entity, on_built_entity)
-- script.on_event(defines.events.on_robot_built_entity, on_built_entity)

-- script.on_event(defines.events.on_tick, on_tick)
-- script.on_nth_tick(600, on_nth_tick)


-- script.on_event(defines.events.on_player_rotated_entity, on_player_rotated_entity)

-- script.on_event(defines.events.on_player_mined_entity, on_player_mined_entity)
-- script.on_event(defines.events.on_robot_mined_entity, on_robot_mined_entity)

-- script.on_event(defines.events.on_entity_died, on_entity_died)






-- script.on_event(defines.events.on_tick, on_tick)
-- script.on_event(defines.events.on_player_driving_changed_state, on_player_driving_changed_state)

-- script.on_load(on_load)

-- script.on_event(defines.events.on_gui_click, on_Gui_Click)

-- script.on_event(defines.events.on_pre_player_mined_item, on_pre_player_mined_item)


-- script.on_event(defines.events.on_player_created, on_player_created)

