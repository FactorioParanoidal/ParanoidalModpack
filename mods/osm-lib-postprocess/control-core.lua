---------------------
---- control.lua ----
---------------------

local control_core = {}

function control_core.init_globals()

	-- Set on_first_tick() trigger state
	global.first_tick_trigger = true

	global.technologies = {}
	global.recipes = {}
	global.items = {}
	global.fluids = {}
	global.entities = {}
	global.resources = {}
	global.forces = {}
	global.players = {}
	global.active_mods = -1

	for _, technology in pairs(game.technology_prototypes) do
		if technology.valid and technology.order == "OSM-removed" then 
			global.technologies[technology.name] = {}
		end
	end
	
	for _, item in pairs(game.item_prototypes) do
		if item.valid and (item.subgroup.name == "OSM-removed" or item.subgroup.name == "OSM-placeholder") then
			global.items[item.name] = {}
			global.items[item.name].type = item.type
		end
	end

	for _, fluid in pairs(game.fluid_prototypes) do
		if fluid.valid and (fluid.subgroup.name == "OSM-removed" or fluid.subgroup.name == "OSM-placeholder") then
			global.fluids[fluid.name] = {}
		end
	end
	
	for _, entity in pairs(game.entity_prototypes) do
		if entity.valid and (entity.subgroup.name == "OSM-removed" or entity.subgroup.name == "OSM-placeholder") then
			if entity.type == "resource" then
				global.resources[entity.name] = {}
			else
				global.entities[entity.name] = {}
				global.entities[entity.name].type = entity.type
			end
		end
	end
	
	for _, _ in pairs(game.active_mods) do
		global.active_mods = global.active_mods+1
	end

end

function control_core.init_script(stage)

	log("----------------------------------------------------------------------")
	log("--- Initializing control functions at stage: "..stage)
	log("")
	
	local debug_mode = settings.startup["OSM-debug-mode"].value
	local tech_index = {}
	local technology_index = 0
	local recipe_index = 0
	local item_index = 0
	local fluid_index = 0
	local entity_index = 0
	local resource_index = 0
	
	if global.active_mods then
		log("Info: Found "..global.active_mods.." mods installed!")
	end
	
	if OSM.debug_mode then
	
		-- Techs
		if global.technologies then
			for i, technology in pairs(global.technologies) do
				technology_index=technology_index+1
			end
			if technology_index > 0 then
				log("Info: Found "..technology_index.." disabled technologies!")
			end
		end
	
		-- Recipes
		if global.recipes then
			for i, recipe in pairs(global.recipes) do
				recipe_index=recipe_index+1
			end
			if recipe_index > 0 then
				log("Info: Found "..recipe_index.." disabled recipes!")
			end
		end
		
		-- Items
		if global.items then
			for i, item in pairs(global.items) do
				item_index=item_index+1
			end
			if item_index > 0 then
				log("Info: Found "..item_index.." disabled items!")
			end
		end
	
		-- Fluids
		if global.fluids then
			for i, fluid in pairs(global.fluids) do
				fluid_index=fluid_index+1
			end
			if fluid_index > 0 then
				log("Info: Found "..fluid_index.." disabled fluids!")
			end
		end
	
		-- Resources
		if global.resources then
			for i, resource in pairs(global.resources) do
				resource_index=resource_index+1
			end
			if resource_index > 0 then
				log("Info: Found "..resource_index.." disabled resources!")
			end
		end
	
		-- Entities
		if global.entities then
			for i, entity in pairs(global.entities) do
				entity_index=entity_index+1
			end
			if entity_index > 0 then
				log("Info: Found "..entity_index.." disabled entities!")
			end
		end
	end

	if stage == "on_load" then goto skip end

	-- Reset technologies and recipes
	log("Info: Cleaning up technology tree and recipes...")

	for _, force in pairs(game.forces) do
		for _, technology in pairs(game.technology_prototypes) do
			if force.technologies[technology.name] and technology.valid and technology.order == "OSM-removed" then
				if force.technologies[technology.name].enabled then force.technologies[technology.name].enabled = false end
				if force.technologies[technology.name].researched then force.technologies[technology.name].researched = false end
				if force.get_saved_technology_progress(technology.name) then force.set_saved_technology_progress(technology.name, nil) end
				if force.current_research == technology.name then force.cancel_current_research() end

				tech_index[technology.name] = technology.name
			end
		end

		force.reset_technologies()
		force.reset_technology_effects()
		force.reset_recipes()
	end
	
	for _, tech in pairs(tech_index) do
		log("Info: Technology: "..'"'..tech..'"'.." has been unresearched for all forces because a mod disabled it!")
	end

	::skip::

	-- Init on first tick
	script.on_event(defines.events.on_tick, OSM.PP.on_first_tick)

	log("")
	log("--- Stage "..stage.." complete! Waiting for first tick...")
	log("----------------------------------------------------------------------")
	log("")
end

function control_core.on_first_tick(stage)

	if global.first_tick_trigger then
	
		global.first_tick_trigger = false
	
		log("----------------------------------------------------------------------")
		log("--- Initializing control functions on_first_tick...")
		log("")

		-- Wash player inventories
		log("Cleaning up players inventories...")
	
		for _, player in pairs(game.players) do
			if player and player.valid then
				for item_name, _ in pairs(global.items) do
	
					local item_count = player.get_item_count(item_name) or 0
					local action = ""
	
					if item_count > 0 then
						if not debug_mode then
							player.remove_item({name=item_name, count=item_count})
							action = "removed from:"
						else
							action = "found in:"
						end		
						log("Info: Disabled item: "..'"'..item_name..'"'.." "..action.." player inventory! Player: "..'"'..player.name..'"'.."  Amount: "..item_count)
					end
				end
			end
		end
		
		-- Send disabled resources to shadow realm!
		log("Cleaning up world surfaces...")

		for _, surface in pairs(game.surfaces) do
		
			local resource_count = 0
		
			for resource, _ in pairs(global.resources) do
				for _, entity in pairs(surface.find_entities_filtered{name=resource}) do
					resource_count=resource_count+1
					entity.destroy()
				end
				if resource_count > 0 then
					log("Info: Disabled resource: "..'"'..resource..'"'.." removed from world's surface! Surface: "..'"'..surface.name..'"'.." Amount: "..resource_count)
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