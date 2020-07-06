local replacement_table = {
  ['offshore-pump'] = 'burner-offshore-pump',
  ['burner-offshore-pump-placeholder'] = 'burner-offshore-pump',
  ['electric-offshore-pump-placeholder'] = 'electric-offshore-pump',
  ['electric-modular-offshore-pump-placeholder'] = 'electric-modular-offshore-pump'
  }


function on_built_entity (event)
  local ent = event.created_entity or event.entity
  local name = ent.name
  
  local bop_name = replacement_table[name]
  if not bop_name then return else end
  
  local surface = ent.surface

  surface.create_entity{name=bop_name, position=ent.position, direction=ent.direction, force=ent.force, fast_replace=true, spill=false, raise_built=true, create_build_effect_smoke=false}

  ent.destroy()
end

script.on_event(defines.events.on_built_entity, on_built_entity)
script.on_event(defines.events.on_robot_built_entity, on_built_entity)

-- script.on_event(defines.events.on_trigger_created_entity, on_built_entity)
-- script.on_event(defines.events.on_entity_spawned, on_built_entity)