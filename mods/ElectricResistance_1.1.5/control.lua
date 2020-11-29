

script.on_configuration_changed(function(data)
	for i, surface in pairs (game.surfaces) do
		local resistors = surface.find_entities_filtered{name="hidden-electric-resistance"}
		for j, resistor in pairs (resistors) do
--			surface.find_entity("", position)
			local count = surface.count_entities_filtered{position=resistor.position, type="electric-pole"}
			if count == 0 then
				resistor.destroy() -- 1.0.2
			elseif resistor.destructible then
				resistor.destructible = false
			end
		end
	end
end)

script.on_init(function(data)
	local n = 0
	for i, surface in pairs (game.surfaces) do
		local entities = surface.find_entities_filtered({type="electric-pole"})
		for j, entity in pairs (entities) do
			add_resistor(entity)
		end
		n=n+#entities
	end
	game.print ('[Electric Resistance]: added ' .. n .. ' resistors')
end)


script.on_event(defines.events.on_robot_mined_entity, function(event)
	
end)

function add_resistor(entity)
	local surface = entity.surface
--	local position = entity.position
--	create_entity{name=…, position=…, direction=…, force=…, target=…, source=…, fast_replace=…, player=…, spill=…, raise_built=…, create_build_effect_smoke=…}
	local resistor = surface.create_entity{name="hidden-electric-resistance",
		position = entity.position,
		force = entity.force,
		create_build_effect_smoke=false
	}
	resistor.destructible = false -- added in 1.0.4
end

function on_built_entity (entity)
	if entity.type == "electric-pole" then
		add_resistor(entity)
	end
end


script.on_event(defines.events.on_built_entity, function(event)
	on_built_entity (event.created_entity)
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
	on_built_entity (event.created_entity)
end)

-- added in 1.0.5
script.on_event(defines.events.script_raised_built, function(event)
	on_built_entity (event.entity) -- why not created_entity, devs?
end)


function on_mined_entity (entity)
--	if entity.valid 
	if entity and entity.type == "electric-pole" then
		local surface = entity.surface
		local resistor = surface.find_entity("hidden-electric-resistance", entity.position)
		if resistor then	
			resistor.destroy()
		end
	end
end

script.on_event(defines.events.on_player_mined_entity, function(event)
--	game.print('on_player_mined_entity')
	on_mined_entity (event.entity)
end)

script.on_event(defines.events.on_robot_mined_entity, function(event) -- changed in 1.0.3
--	game.print('on_robot_mined_entity')
	on_mined_entity (event.entity)
end)

script.on_event(defines.events.on_entity_died, function(event)
--	game.print('on_entity_died')
	on_mined_entity (event.entity)
end)

-- added in 1.0.5
script.on_event(defines.events.script_raised_destroy, function(event)
--	game.print('on_entity_died')
	on_mined_entity (event.entity)
end)


