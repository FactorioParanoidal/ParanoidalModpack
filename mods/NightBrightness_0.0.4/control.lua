-- /c game.print (' dusk:'..game.player.surface.dusk ..' evening'..game.player.surface.evening ..' morning'..game.player.surface.morning .. ' dawn '..game.player.surface.dawn )
-- 0.25 0.45 0.55 0.75

function get_season (digit_season)
 if digit_season < 0.125 then return 'summer' end
 if digit_season >= 0.125 and digit_season < (0.125+0.25) then return 'fall' end
 if digit_season >= (0.125+0.25) and digit_season < (0.125+0.5) then return 'winter' end
 if digit_season >= (0.125+0.5) and digit_season < (0.125+0.75) then return 'spring' end
 if digit_season >= (0.125+0.75) then return 'summer' end
end

function change_day_parameters (surface, new_dp)
  if global.debug then
    if not (new_dp.dusk < surface.evening) then game.print ('dusk broken') end
    if not ((surface.dusk < new_dp.evening)and(new_dp.evening < surface.morning)) then game.print ('evening broken') end
    if not ((surface.evening < new_dp.morning)and(new_dp.morning < surface.dawn)) then  game.print ('morning broken') end
    if not (surface.morning < new_dp.dawn) then game.print ('dawn broken') end
  end
  surface.dusk    = 0.00001
  surface.evening = 0.00002
  surface.morning = 0.00003
  surface.dawn    = 0.00004
  surface.dawn    = new_dp.dawn
  surface.morning = new_dp.morning
  surface.evening = new_dp.evening
  surface.dusk    = new_dp.dusk
end

function on_nth_tick()
  
  local surface = game.surfaces['nauvis']
  local daytime = surface.daytime
  
  local last_daytime = global.last_daytime or 0
  if daytime < last_daytime then
    
    -- new day, the middle of the day
    local day = global.day or 1
    local period = global.period or 16
    local year_day = (day%period)
    local digit_season = (year_day/period)
    local season = get_season (digit_season)
    local last_season = global.season or '1'
    if not (season == last_season) and (period > 31) then
      game.print ('Now is '..season)
    end
    global.season = season
    
    local phase = math.cos ((day/period)*(2*math.pi))
    local min_brightness = global.middle_value + global.spread_value * phase
    
    local day_parameters = global.day_parameters or {dusk = 1/6, evening = 2/6, morning = 4/6, dawn = 5/6, tilt = (1/6-0.01)}
    local tilt = day_parameters.tilt * phase
    local dusk = day_parameters.dusk + tilt
    local evening = day_parameters.evening + tilt
    local morning = day_parameters.morning - tilt
    local dawn = day_parameters.dawn - tilt
    local new_day_parameters = {dusk=dusk, evening=evening, morning=morning, dawn=dawn}
    
    local solar_power_multiplier_spread = global.solar_power_multiplier_spread or 0.25
    local max_solar_power_multiplier = 1
    solar_power_multiplier = (max_solar_power_multiplier - solar_power_multiplier_spread) + solar_power_multiplier_spread * phase
    
    if global.debug then
      game.print ('day: '.. day .. ' year_day: '.. year_day .. ' digit_season: ' .. digit_season .. ' season: ' .. season)
      game.print ('min_brightness: '..min_brightness..' dusk: '..dusk ..' evening: '..evening ..' morning: '..morning .. ' dawn: '..dawn..' solar_power_multiplier: '..solar_power_multiplier)
    end
    surface.min_brightness = min_brightness
    
    -- surface.dusk = dusk
    -- surface.evening = evening
    -- surface.morning = morning
    -- surface.dawn = dawn
    change_day_parameters (surface, new_day_parameters)
    
    -- it must be in the night, just set up global, making no changing
    global.solar_power_multiplier = solar_power_multiplier

    global.day = day + 1
  elseif daytime > 0.5 and last_daytime < 0.5 then
    -- half day, it's midnight in Factorio
    local solar_power_multiplier = global.solar_power_multiplier or 1
    if global.debug then
      -- game.print ('daytime: ' ..daytime.. ' last_daytime: '..last_daytime)
        game.print ('solar_power_multiplier: '.. solar_power_multiplier)
    end
    surface.solar_power_multiplier = solar_power_multiplier or 1
  end
  global.last_daytime = daytime
end




-- force.clear_chart(surface)
-- Erases chart data for this force.

-- Parameters
-- surface :: SurfaceSpecification (optional): Which surface to erase chart data for or if not provided all surfaces charts are erased.

-- force.unchart_chunk(position, surface)
-- Parameters
-- position :: ChunkPosition: The chunk position to unchart.
-- surface :: SurfaceSpecification: Surface to unchart on.



-- get_chunks() → LuaChunkIterator
-- Get an iterator going over every chunk on this surface


script.on_nth_tick(1200, on_nth_tick)

function update_settings ()
  -- global.threshold = settings.global[mod_name.."autodeconstruct-health-threshold"].value
  --min_brightness = 0
  --max_brightness = 0.15 -- 0.15 is vanilla in Factorio 0.17.9
  local max_brightness = settings.global['max_night_brightness_percent'].value / 100
  local min_brightness = settings.global['min_night_brightness_percent'].value / 100
  local period = settings.global['night_brightness_period_days'].value
  global.debug = settings.global['nb_debug'].value
  
  -- local day_parameters = {dusk = 1/6, evening = 2/6, morning = 4/6, dawn = 5/6, tilt = (1/6-0.01)} -- no days in winter, no nights in sommer
  local day_parameters = {dusk = 0.2, evening = 0.3, morning = 0.7, dawn = 0.8, tilt = 0.15}
  global.day_parameters = day_parameters
  
  global.solar_power_multiplier_spread = 0.25
  
  global.middle_value = (max_brightness + min_brightness)/2
  global.spread_value = (max_brightness - min_brightness)/2
  global.period = period -- days
  global.day = 0 -- start from 0 for new game, it's maximum value
end

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  update_settings ()
end)

script.on_configuration_changed(function(data)
  update_settings ()
end)

script.on_init(function(data)
  update_settings ()
end)

-- on_nth_tick(tick, f)
-- Register a handler to run on nth tick(s).

-- Parameters
-- tick :: uint or array of uint: The nth-tick(s) to invoke the handler on. Passing nil will unregister all nth-tick handlers.
-- f :: function(NthTickEvent): The handler to run. Passing nil will unregister the handler for the provided ticks.

-- script.on_init(try_init)
-- script.on_configuration_changed(try_init)


-- script.on_event(defines.events.on_built_entity, on_built_entity)
-- script.on_event(defines.events.on_robot_built_entity, on_built_entity)

-- script.on_event(defines.events.on_tick, on_tick)


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

