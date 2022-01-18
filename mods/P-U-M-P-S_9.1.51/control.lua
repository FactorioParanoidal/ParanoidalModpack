---------------------
---- control.lua ----
---------------------

-- Set entity table
local entity_table =
{
	["offshore-pump-0-placeholder"] = "offshore-pump-0",
	["offshore-pump-1-placeholder"] = "offshore-pump-1",
	["offshore-pump-2-placeholder"] = "offshore-pump-2",
	["offshore-pump-3-placeholder"] = "offshore-pump-3",
	["offshore-pump-4-placeholder"] = "offshore-pump-4",
	["seafloor-pump-placeholder"] = "seafloor-pump",
	["ground-water-pump-placeholder"] = "ground-water-pump"
}

-- Entity control function 
function on_built_entity(event)

	-- Boilers start with 10 water [checks for correct input fluid]
	if settings.global["osm-pumps-boiler-start-water"].value == true then
		if event.created_entity.type == "boiler" then
			for _, fluidbox in pairs(event.created_entity.prototype.fluidbox_prototypes) do

				local filter = fluidbox.filter
				local production_type = fluidbox.production_type

				if (filter and filter.name == "water") and (production_type and production_type == "input-output") then
					event.created_entity.insert_fluid({name = "water", amount = 10})
				end
			end
		end
	end

	-- Replace placeholder with actual entity
	if event.created_entity.type == "offshore-pump" then
		local placeholder = event.created_entity or event.entity
		local placeholder_name = placeholder.name
		local surface = placeholder.surface
		local position = placeholder.position
		local direction = placeholder.direction
		local force = placeholder.force
		local name = entity_table[placeholder_name]
		if not name then return else end

		placeholder.destroy()
		surface.create_entity
		{
			name = name,
			position = position,
			direction = direction,
			force = force,
			fast_replace = true,
			spill = false,
			raise_built = true,
			create_build_effect_smoke = false
		}
	end
end

script.on_event(defines.events.on_built_entity, on_built_entity)
script.on_event(defines.events.on_robot_built_entity, on_built_entity)

-- Rebuild offshore pumps on load to prevent pipe detachment on settings change
script.on_configuration_changed(function(data)
	for _, surface in pairs (game.surfaces, entity_table) do

		local offshore_pumps = surface.find_entities_filtered{name = entity_table}

		for _, pump in pairs (offshore_pumps) do

			local name = pump.name
			local position = pump.position
			local direction = pump.direction
			local force = pump.force
			if not name then return else end

			pump.destroy()
			surface.create_entity
			{
				name = name,
				position = position,
				direction = direction,
				force = force,
				fast_replace = true,
				spill = false,
				raise_built = true,
				create_build_effect_smoke = false
			}
		end
	end
end)