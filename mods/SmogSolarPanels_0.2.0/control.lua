local max_smog = 1000
local powers = {90, 70, 30, 10, 1}

script.on_init(function(data)
  global = {}
  global.panels = {}
  global.empty_panels_table = true
  global.last_panel = 0
  
  for i, surface in pairs (game.surfaces) do
    local entities = surface.find_entities_filtered{type = 'solar-panel'}
    if entities then
      for j, entity in pairs (entities) do 
        add_to_table(entity)
      end
    end
  end
end)


script.on_event(defines.events.on_built_entity, function(event)
  local entity = event.created_entity
  if entity.type == 'solar-panel' then
    add_to_table(entity)
  end
end)


script.on_event(defines.events.on_robot_built_entity, function(event)
  local entity = event.created_entity
  if entity.type == 'solar-panel' then
    add_to_table(entity)
  end
end)


function add_to_table(entity)
  local panel = {entity = entity, power = 100, orig_name = entity.name}
  table.insert (global.panels, panel)
  global.empty_panels_table = false
end


script.on_event(defines.events.on_tick, function(event)
  if global.empty_panels_table then return end
  local next_panel = global.last_panel + 1
  if not (global.panels[next_panel]) then
    global.last_panel = 0
    return
  end
  global.last_panel = next_panel
  local panel = global.panels[next_panel]
  
  local entity = panel.entity
  if not (entity.valid) then
    table.remove (global.panels, next_panel)
    global.last_panel = next_panel - 1
    if #global.panels == 0 then
      global.empty_panels_table = true
    end
    return
  end
  
  local force = entity.force
  
  local surface = entity.surface
  local position = entity.position
  local transp_p = (100-math.floor(100*surface.get_pollution(position)/max_smog)) -- in percents
  local power_p = 100
  for i, p in pairs (powers) do
    if transp_p < p then
      power_p = p
    end
  end
  if panel.power == power_p then -- nothing to replace
    return
  end
  
  if power_p == 100 then
    entity.destroy()
    
    local new_entity = surface.create_entity{name=panel.orig_name, position=position, force=force, fast_replace=false, spill=false}
    global.panels[next_panel] = {entity = new_entity, power = 100, orig_name = panel.orig_name}
    return
  end
  
  local new_name = 'ssp-'..panel.orig_name..'-'..power_p
  if not (game.entity_prototypes[new_name]) then
    table.remove (global.panels, next_panel)
    global.last_panel = next_panel - 1
    if #global.panels == 0 then
      global.empty_panels_table = true
    end
    return
  end
  
  
  entity.destroy()
  local new_entity = surface.create_entity{name=new_name, position=position, force=force, fast_replace=false, spill=false} -- can't fast replace!
  
  global.panels[next_panel] = {entity = new_entity, power = power_p, orig_name = panel.orig_name}
end)


























