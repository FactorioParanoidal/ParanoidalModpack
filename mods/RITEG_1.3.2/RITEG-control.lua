-- local E = 40 -- GJ
-- local P = 600 -- kW
local mod_name = "__RITEG__"
local ln_2 = 0.69314718
local rtg_names_list = {'RITEG-1', 'RITEG-cyan'}
local RTG_prop = 
  {
    ['RITEG-1'] = {energy = 40*10^9}, -- 40 GJ
    ['RITEG-cyan'] = {energy = 200*10^9} -- 200 GJ
  }

function add_glow (entity)
  rendering.draw_light 
    {
      -- sprite = "riteg_glow", -- not nice :(
      sprite = "utility/light_small",
      surface = entity.surface,
      target = entity
    }
end

script.on_configuration_changed(function(data)
  update_settings ()
  -- update_recipes ()
  add_all_rtgs_to_table ()
  
end)

script.on_init(function(data)
  try_init ()
  update_settings ()
  update_recipes ()
end)

-- call update_settings when on_runtime_mod_setting_changed
script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  update_settings ()
  update_ritegs ()
end)



function try_init ()
  if not global then global = {} end
  if not global.rtgs then global.rtgs = {} end
  if not global.tick_id then global.tick_id = 1 end
  if not global.total_rtgs then global.total_rtgs = 0 end
end

function update_settings ()
  global.threshold = settings.global[mod_name.."autodeconstruct-health-threshold"].value
end

function update_ritegs ()
  for i, rtg in pairs (global.rtgs) do
    local entity = rtg.entity
	if entity and entity.valid then -- added in 1.3.1
		local max_health = entity.prototype.max_health
		rtg.health_threshold = max_health * global.threshold/100
	else
		-- do nothing
	end
  end
end

function update_recipes ()
  for i, force in pairs (game.forces) do
    force.reset_technology_effects()
  end
end

function add_all_rtgs_to_table ()
local tick = game.tick
  for i, surface in pairs (game.surfaces) do
    for j, rtg_name in pairs (rtg_names_list) do
      local found_entities = surface.find_entities_filtered{name=rtg_name}
      for k, entity in pairs (found_entities) do
        local rtg = make_rtg_prototype {name = rtg_name, tick = tick, entity = entity}
        
        add_glow (entity)
        table.insert(global.rtgs, rtg)
        
        global.total_rtgs = global.total_rtgs + 1
      end
    end
  end
  -- log('global.total_rtgs = ' .. global.total_rtgs)
end

function make_rtg_prototype (data)
  local entity = data.entity
  local max_health = entity.prototype.max_health
  local rtg = {name = data.name, 
  first_tick = data.tick,
  first_energy = RTG_prop[data.name].energy, -- 40 GJ
  entity = entity,
  first_power = entity.health*10^3, -- 600 kW
  health_threshold = max_health * global.threshold/100,
  pause_to_tick = data.tick+120
  
  }
  rtg.half_life = rtg.first_energy * ln_2 / rtg.first_power
  rtg.power = power_of_RITEG(rtg)
  
  log ('starting power: ' .. rtg.power*60 .. ' half life: '..rtg.half_life .. ' starting energy: '..rtg.first_energy)
  return rtg
end


-- added in 0.2.15

script.on_event(defines.events.on_player_mined_entity, function(event)
  for j, rtg_name in pairs (rtg_names_list) do
    if	(event.entity.name == rtg_name) then 
      onMinedHandler(event) 
    end
  end
end)

script.on_event(defines.events.on_robot_mined_entity, function(event)
  for j, rtg_name in pairs (rtg_names_list) do
    if	(event.entity.name == rtg_name) then 
      onMinedHandler(event) 
    end
  end
end)

function onMinedHandler (event)
  local entity = event.entity
  if entity and entity.valid then
    local buffer = event.buffer
    for i = 1, #buffer do
      local item_stack = buffer[i]
      local health = item_stack.health
      -- game.print (i .. ' health: ' .. health)
      item_stack.health = 1
    end
  end
end

-- /added in 0.2.15


script.on_event(defines.events.on_built_entity, function(event)
  for j, rtg_name in pairs (rtg_names_list) do
    if	(event.created_entity.name == rtg_name) then 
      onBuildHandler(event) 
    end
  end
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
  for j, rtg_name in pairs (rtg_names_list) do
    if	(event.created_entity.name == rtg_name) then 
      onBuildHandler(event) 
    end
  end
end)

function onBuildHandler(event) 
  local tick = game.tick  
  local entity = event.created_entity
  local rtg_name = entity.name
  local rtg = make_rtg_prototype {name = rtg_name, tick = tick, entity = entity}
  
  add_glow (entity)
  table.insert(global.rtgs, rtg)
  
  global.total_rtgs = global.total_rtgs + 1
  -- game.print ('Total RITEGs: '..global.total_rtgs)
end

function remove_rtg(tick_id)
  table.remove(global.rtgs, tick_id)
  global.total_rtgs = global.total_rtgs - 1
  -- game.print('['..tick_id..'/'..global.total_rtgs..'] '..'RITEG was deleted')
end

function autodeconstruct_rtg (entity)
  entity.order_deconstruction(entity.force)
end

function replace_rtg (entity)
  entity.surface.create_entity{name='entity-ghost', position=entity.position, force=entity.force, inner_name = entity.name}
end

script.on_event(defines.events.on_tick, function(event)
  if global.total_rtgs == 0 then return end
  local tick_id = global.tick_id
  if tick_id > global.total_rtgs then
    tick_id = 1
  end
  local rtg = global.rtgs[tick_id]
  if not (rtg and rtg.entity.valid)  then
    remove_rtg(tick_id)
    return
  end

  local tick = game.tick
  local pause_to_tick = rtg.pause_to_tick or 0
  if tick >= pause_to_tick then
    -- do all stuff
  else
    -- pause
    -- game.print ('['..tick_id..'] '..'Pause: '..(pause_to_tick-tick))
    return
  end
  
  local power = power_of_RITEG(rtg)
  local entity = rtg.entity
  entity.power_production = power
  rtg.power = power
  
  local power_was = rtg.power_was or (entity.health*(50/3))-- 1000/60=50/3 is 10000 Joule/tick (it's 600 000 Watt or 600 kW) divide thrue 600 Watt
  
  if power_was > power then 
    local last_update_tick = rtg.last_update_tick or (tick-1)
    local pause = tick - last_update_tick
    rtg.last_update_tick = tick
    rtg.pause_to_tick = tick+pause
    -- game.print ('['..tick_id..'] pause: '..pause)
    rtg.power_was = math.floor(power)
    local health_was = math.floor(power/(50/3))
    if entity.health > health_was then
      entity.health = health_was
    end
  end
  
  --new code
  local threshold_health = rtg.health_threshold or 60 -- health
  if entity.health < threshold_health then
    -- game.print ('RITEG replacing')
    -- game.print ('rtg.entity.health '..entity.health)
    -- game.print ('threshold_health '..threshold_health)
    
    autodeconstruct_rtg (entity)
    replace_rtg (entity)

    remove_rtg(tick_id)
    return
  end
  -- end of new code
  
  global.tick_id = tick_id + 1
end)

function power_of_RITEG(rtg)
  return rtg['first_power'] / (2^((game.tick-rtg.first_tick)/(rtg.half_life * 60)))/60
end

function remaining_energy (rtg)
  -- E = P_0 * t_HL / (ln(2))
end

function half_life (rtg)
  return rtg['first_energy'] * ln_2 / rtg['first_power']
end


        
-- {name = rtg_name, 
-- first_tick = tick, 
-- -- first_energy = 40*10^9, -- 40 GJ
-- first_energy = RTG_prop[rtg_name].energy, -- 40 GJ
-- -- first_power = 600*10^3, -- 600 kW
-- first_power = entity.health*10^3, -- 600 kW
-- entity = entity}
-- rtg['half_life'] = E * ln_2 / P
-- rtg['half_life'] = rtg['first_energy'] * ln_2 / rtg['first_power']
-- rtg['power'] = power_of_RITEG(rtg)