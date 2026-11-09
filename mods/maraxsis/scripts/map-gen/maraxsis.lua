maraxsis.on_event(maraxsis.events.on_init(), function()
    game.planets["maraxsis"].reset_map_gen_settings()
    game.planets["maraxsis-trench"].reset_map_gen_settings()
    maraxsis.sync_trench_map_seed()
end)

maraxsis.on_event(maraxsis.events.on_init(), function()
	storage.coral_animations = storage.coral_animations or {}
end)

maraxsis.on_event(defines.events.on_chunk_generated, function(event)
	local surface = event.surface
	local surface_name = surface.name
	if not maraxsis_constants.MARAXSIS_SURFACES[surface_name] then return end

	local chunkpos = event.position
	local x = chunkpos.x * 32 + 16
	local y = chunkpos.y * 32 + 16

	local fancy_water = surface.create_entity {
		name = "maraxsis-water-shader",
		position = {x, y},
		create_build_effect_smoke = false
	}
	fancy_water.disabled_by_script = true
	fancy_water.destructible = false
	fancy_water.minable_flag = false
end)

local function cliff_created(event)
	local old_cliff = event.target_entity
	local surface = old_cliff.surface
	local position = old_cliff.position
	local force_index = old_cliff.force_index
	local cliff_orientation = old_cliff.cliff_orientation

	old_cliff.destroy()

	local tile_at = surface.get_tile(position)
	if tile_at.name == "out-of-map" then return end

	surface.create_entity {
		name = "cliff-maraxsis",
		position = position,
		cliff_orientation = cliff_orientation,
		force = force_index,
		create_build_effect_smoke = false
	}
end

local function coral_created(event)
	local coral = event.target_entity
	local surface = coral.surface
	local position = coral.position
	local force_index = coral.force_index

	local coral_animation = {0, 0}
	for i = 1, 2 do
		local new_coral = surface.create_entity {
			name = "maraxsis-coral-animation",
			position = maraxsis.randomize_position(position, 0.75),
			force = force_index,
			create_build_effect_smoke = false
		}
		new_coral.disabled_by_script = true
		new_coral.destructible = false
		new_coral.minable_flag = false
		coral_animation[i] = new_coral
	end

	if coral_animation[1].graphics_variation == coral_animation[2].graphics_variation then
		coral_animation[2].graphics_variation = (coral_animation[1].graphics_variation % 7) + 1
	end

	-- create polycephalum-slime decorative
	surface.create_decoratives {
		check_collision = false,
		decoratives = {
			{
				amount = 1,
				name = "polycephalum-slime",
				position = maraxsis.randomize_position(position, 0.75),
			}
		}
	}

	local registration_number = script.register_on_object_destroyed(coral)
	storage.coral_animations[registration_number] = coral_animation
end

maraxsis.on_event(defines.events.on_object_destroyed, function(event)
	local coral_animation = storage.coral_animations[event.registration_number]
	if not coral_animation then return end

	for _, entity in pairs(coral_animation) do
		entity.destroy()
	end
end)

maraxsis.on_event(defines.events.on_script_trigger_effect, function(event)
	local effect_id = event.effect_id
	if effect_id == "maraxsis-cliff-created" then
		cliff_created(event)
	elseif effect_id == "maraxsis-coral-created" then
		coral_created(event)
	end
end)
