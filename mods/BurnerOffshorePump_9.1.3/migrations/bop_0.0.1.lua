 -- here can be code, that simulates this entity replacing:  ["offshore-pump", "burner-offshore-pump"]
 
log ('bop 0.0.2 migration')

local replacement_table = {
  ['offshore-pump'] = 'burner-offshore-pump',
  -- ['electric-offshore-pump-placeholder'] = 'electric-offshore-pump'
  }

local amount = 0  
  
for i, surface in pairs (game.surfaces) do
  local entities = surface.find_entities_filtered{name='offshore-pump'}
  for j, ent in pairs (entities) do
    surface.create_entity{name='burner-offshore-pump', position=ent.position, direction=ent.direction, force=ent.force, fast_replace=true, spill=false, raise_built=true, create_build_effect_smoke=false}
    ent.destroy()
    amount = amount + 1
  end
  
  -- local entities = surface.find_entities_filtered{name={'bop-offshore-pump', 'burner-offshore-pump'}} -- was "burner-offshore-pump", it means that migration.json was earlier
  
  -- local entities = surface.find_entities_filtered{name='burner-offshore-pump'}
  -- for j, ent in pairs (entities) do
    -- -- log (ent.name)
    -- ent.set_recipe('bop-make-water-120')
  -- end
end

log ('ready: '..amount)