---------------------
---- control.lua ----
---------------------

local control_core = {}

function control_core.init_globals()
	-- Set on_first_tick() trigger state
	storage.first_tick_trigger = true

	storage.technologies = {}
	storage.recipes = {}
	storage.items = {}
	storage.fluids = {}
	storage.entities = {}
	storage.resources = {}
	storage.forces = {}
	storage.players = {}

	for _, technology in pairs(prototypes.technology) do
		if technology.valid and technology.order == "OSM-removed" then
			storage.technologies[technology.name] = {}
		end
	end

	for _, item in pairs(prototypes.item) do
		if item.valid and (item.subgroup.name == "OSM-removed" or item.subgroup.name == "OSM-placeholder") then
			storage.items[item.name] = {}
			storage.items[item.name].type = item.type
		end
	end

	for _, fluid in pairs(prototypes.fluid) do
		if fluid.valid and (fluid.subgroup.name == "OSM-removed" or fluid.subgroup.name == "OSM-placeholder") then
			storage.fluids[fluid.name] = {}
		end
	end

	for _, entity in pairs(prototypes.entity) do
		if entity.valid and (entity.subgroup.name == "OSM-removed" or entity.subgroup.name == "OSM-placeholder") then
			if entity.type == "resource" then
				storage.resources[entity.name] = {}
			else
				storage.entities[entity.name] = {}
				storage.entities[entity.name].type = entity.type
			end
		end
	end

end

function control_core.init_script(stage)
	log("----------------------------------------------------------------------")
	log("--- Initializing control functions at stage: " .. stage)
	log("")

	local debug_mode = settings.startup["OSM-debug-mode"].value
	local tech_index = {}
	local technology_index = 0
	local recipe_index = 0
	local item_index = 0
	local fluid_index = 0
	local entity_index = 0
	local resource_index = 0

	if OSM.debug_mode then
		-- Techs
		if storage.technologies then
			for i, technology in pairs(storage.technologies) do
				technology_index = technology_index + 1
			end
			if technology_index > 0 then
				log("Info: Found " .. technology_index .. " disabled technologies!")
			end
		end

		-- Recipes
		if storage.recipes then
			for i, recipe in pairs(storage.recipes) do
				recipe_index = recipe_index + 1
			end
			if recipe_index > 0 then
				log("Info: Found " .. recipe_index .. " disabled recipes!")
			end
		end

		-- Items
		if storage.items then
			for i, item in pairs(storage.items) do
				item_index = item_index + 1
			end
			if item_index > 0 then
				log("Info: Found " .. item_index .. " disabled items!")
			end
		end

		-- Fluids
		if storage.fluids then
			for i, fluid in pairs(storage.fluids) do
				fluid_index = fluid_index + 1
			end
			if fluid_index > 0 then
				log("Info: Found " .. fluid_index .. " disabled fluids!")
			end
		end

		-- Resources
		if storage.resources then
			for i, resource in pairs(storage.resources) do
				resource_index = resource_index + 1
			end
			if resource_index > 0 then
				log("Info: Found " .. resource_index .. " disabled resources!")
			end
		end

		-- Entities
		if storage.entities then
			for i, entity in pairs(storage.entities) do
				entity_index = entity_index + 1
			end
			if entity_index > 0 then
				log("Info: Found " .. entity_index .. " disabled entities!")
			end
		end
	end

	if stage == "on_load" then
		goto skip
	end

	-- Reset technologies and recipes
	log("Info: Cleaning up technology tree and recipes...")

	for _, force in pairs(game.forces) do
		for _, technology in pairs(prototypes.technology) do
			if force.technologies[technology.name] and technology.valid and technology.order == "OSM-removed" then
				local forceTechnology = force.technologies[technology.name]
				if forceTechnology.enabled then
					forceTechnology.enabled = false
				end
				if forceTechnology.researched then
					forceTechnology.researched = false
				end
				forceTechnology.saved_progress = 0
				if force.current_research == technology.name then
					force.cancel_current_research()
				end

				tech_index[technology.name] = technology.name
			end
		end

		force.reset_technologies()
		force.reset_technology_effects()
		force.reset_recipes()
	end

	for _, tech in pairs(tech_index) do
		log(
			"Info: Technology: "
				.. '"'
				.. tech
				.. '"'
				.. " has been unresearched for all forces because a mod disabled it!"
		)
	end

	::skip::

	-- Init on first tick
	script.on_event(defines.events.on_tick, OSM.PP.on_first_tick)

	log("")
	log("--- Stage " .. stage .. " complete! Waiting for first tick...")
	log("----------------------------------------------------------------------")
	log("")
end

function control_core.on_first_tick(stage)
	if storage.first_tick_trigger then
		storage.first_tick_trigger = false

		log("----------------------------------------------------------------------")
		log("--- Initializing control functions on_first_tick...")
		log("")

		-- Wash player inventories
		log("Cleaning up players inventories...")

		for _, player in pairs(game.players) do
			if player and player.valid then
				for item_name, _ in pairs(storage.items) do
					local item_count = player.get_item_count(item_name) or 0
					local action = ""

					if item_count > 0 then
						if not debug_mode then
							player.remove_item({ name = item_name, count = item_count })
							action = "removed from:"
						else
							action = "found in:"
						end
						log(
							"Info: Disabled item: "
								.. '"'
								.. item_name
								.. '"'
								.. " "
								.. action
								.. " player inventory! Player: "
								.. '"'
								.. player.name
								.. '"'
								.. "  Amount: "
								.. item_count
						)
					end
				end
			end
		end

		-- Send disabled resources to shadow realm!
		log("Cleaning up world surfaces...")

		for _, surface in pairs(game.surfaces) do
			local resource_count = 0

			for resource, _ in pairs(storage.resources) do
				for _, entity in pairs(surface.find_entities_filtered({ name = resource })) do
					resource_count = resource_count + 1
					entity.destroy()
				end
				if resource_count > 0 then
					log(
						"Info: Disabled resource: "
							.. '"'
							.. resource
							.. '"'
							.. " removed from world's surface! Surface: "
							.. '"'
							.. surface.name
							.. '"'
							.. " Amount: "
							.. resource_count
					)
				end
			end
		end
	else -- Unregister on_first_tick()
		script.on_event(defines.events.on_tick, nil)

		log("")
		log("----------------------------------------------------------------------")
		log("--- I'M DONE!")
		log("----------------------------------------------------------------------")
	end
end

return control_core
