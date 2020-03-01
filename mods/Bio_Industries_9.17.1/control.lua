--Bio_Industries Version   2.6.16

local QC_Mod = false
require ("util")
require ("libs/util_ext")
require ("stdlib/event/event")
require ("control_tree")
require ("control_bio_cannon")
require ("control_arboretum")


--------------------------------------------------------------------
local function On_Init()
	
	if global.Bio_Cannon_Table ~= nil then
		Event.register(defines.events.on_tick, function(event) end)
	end
	
	if global.bi == nil then
		global.bi = {}
		global.bi.tree_growing = {}
		global.bi.terrains = {}
	end
	
	
	global.bi.seed_bomb={}
	global.bi.seed_bomb["seedling"] = "seedling"
	global.bi.seed_bomb["seedling-2"] = "seedling-2"
	global.bi.seed_bomb["seedling-3"] = "seedling-3"
	
	-- Global table for bio farm
	if global.bi_bio_farm_table == nil then
		global.bi_bio_farm_table = {}
	end

	-- Global table for solar boiler
	if global.bi_solar_boiler_table == nil then
		global.bi_solar_boiler_table = {}
	end

	-- Global table for solar farm
	if global.bi_solar_farm_table == nil then
		global.bi_solar_farm_table = {}
	end
	
	-- Global table for power rail
	if global.bi_power_rail_table == nil then
		global.bi_power_rail_table = {}
	end
	
	-- Global table for arboretum
	if global.Arboretum_Table == nil then
		global.Arboretum_Table = {}
	end

	-- Global Prospect Chance
	if global.prospect_chance == nil  then
		global.prospect_chance = 0
	end
	
	-- Global Prospect Richness
	if global.prospect_richness == nil or global.prospect_richness == 0 then
		global.prospect_richness = 1
	end
	
	--- FARL Power rail compatibility
	if remote.interfaces.farl and remote.interfaces.farl.add_entity_to_trigger then
		remote.call("farl", "add_entity_to_trigger", "bi-straight-rail-power")
		remote.call("farl", "add_entity_to_trigger", "bi-curved-rail-power")
	end
	
	-- enable researched recipes
	for i, force in pairs(game.forces) do
		force.reset_technologies()
		force.reset_recipes()
	end

	
	
end


--------------------------------------------------------------------
local function regenerate_entity(ore)
  if game.entity_prototypes[ore] and game.entity_prototypes[ore].autoplace_specification then
    game.regenerate_entity(ore)
  end
end

remote.add_interface("Bio_Industries",
{
  Regenerate = function()
  
    regenerate_entity("bi-ground-water")
	--regenerate_entity("ground-water")
	
    for i, player in ipairs(game.players) do
      player.print("Bio Industries: All ores successfully regenerated!")
    end
  end
})


--------------------------------------------------------------------			 
local function On_Load()

	if global.Bio_Cannon_Table ~= nil then
		Event.register(defines.events.on_tick, function(event) end)
	end
	
	--- FARL Power rail compatibility
	if remote.interfaces.farl and remote.interfaces.farl.add_entity_to_trigger then
		remote.call("farl", "add_entity_to_trigger", "bi-straight-rail-power")
		remote.call("farl", "add_entity_to_trigger", "bi-curved-rail-power")
	end

end


--------------------------------------------------------------------
local function On_Config_Change()

	
	if global.Bio_Cannon_Table ~= nil then
		Event.register(defines.events.on_tick, function(event) end)
	end
	
	if global.bi == nil then
		global.bi = {}
		global.bi.tree_growing = {}
		global.bi.terrains = {}
	end

		
	global.bi.seed_bomb={}
	global.bi.seed_bomb["seedling"] = "seedling"
	global.bi.seed_bomb["seedling-2"] = "seedling-2"
	global.bi.seed_bomb["seedling-3"] = "seedling-3"


	-- Global table for bio farm
	if global.bi_bio_farm_table == nil then
		global.bi_bio_farm_table = {}
	end

	-- Global table for solar boiler
	if global.bi_solar_boiler_table == nil then
		global.bi_solar_boiler_table = {}
	end

	-- Global table for solar farm
	if global.bi_solar_farm_table == nil then
		global.bi_solar_farm_table = {}
	end
	
	-- Global table for power rail
	if global.bi_power_rail_table == nil then
		global.bi_power_rail_table = {}
	end
	
	-- Global table for arboretum
	if global.Arboretum_Table == nil then
		global.Arboretum_Table = {}
	end

	

	-- Global Prospect Chance
	if global.prospect_chance == nil then
		global.prospect_chance = 0
	end
	
	-- Global Prospect Richness
	if global.prospect_richness == nil or global.prospect_richness == 0 then
		global.prospect_richness = 1
	end

	--- FARL Power rail compatibility
	if remote.interfaces.farl and remote.interfaces.farl.add_entity_to_trigger then
		remote.call("farl", "add_entity_to_trigger", "bi-straight-rail-power")
		remote.call("farl", "add_entity_to_trigger", "bi-curved-rail-power")
	end
	
	-- enable researched recipes
	for i, force in pairs(game.forces) do
		for _, tech in pairs(force.technologies) do
			if tech.researched then
				for _, effect in pairs(tech.effects) do
					if effect.type == "unlock-recipe" then          
						force.recipes[effect.recipe].enabled = true
					end
				end
			end
		end
	end
	
end


--------------------------------------------------------------------
--- Used for some compatibility with Angels Mods
script.on_event(defines.events.on_player_joined_game, function(event)
   local player = game.players[event.player_index]
   local force = player.force
   local techs = force.technologies
   
	if settings.startup["angels-use-angels-barreling"] and settings.startup["angels-use-angels-barreling"].value then
      techs['fluid-handling'].researched = false
      techs['bi_tech_fertiliser'].reload()
      local _t = techs['angels-fluid-barreling'].researched
      techs['angels-fluid-barreling'].researched = false
      techs['angels-fluid-barreling'].researched = _t
   end
   
end)


---------------------------------------------
script.on_event(defines.events.on_trigger_created_entity, function(event)
	--- Used for Seed-bomb 
	local ent=event.entity
	local surface = ent.surface
	local position = ent.position
	
	-- Basic
    if global.bi.seed_bomb[ent.name] == "seedling" then
		writeDebug("Seed Bomb Activated - Basic")
		seed_planted_trigger (event)

	
	-- Standard
    elseif global.bi.seed_bomb[ent.name] == "seedling-2" then
		writeDebug("Seed Bomb Activated - Standard")
		local terrain_name_s
		if game.active_mods["alien-biomes"] then 
			terrain_name_s = "vegetation-green-grass-3"
		else
			terrain_name_s = "grass-3"
		end

		writeDebug(terrain_name_s)
		
		surface.set_tiles{{name=terrain_name_s, position=position}}
		seed_planted_trigger (event)


		
	-- Advanced
    elseif global.bi.seed_bomb[ent.name] == "seedling-3" then
		writeDebug("Seed Bomb Activated - Advanced")
		local terrain_name_a
		if game.active_mods["alien-biomes"] then 
			terrain_name_a = "vegetation-green-grass-1"
		else
			terrain_name_a = "grass-1"
		end	
		writeDebug(terrain_name_a)	
		
		surface.set_tiles{{name=terrain_name_a, position=position}}
		seed_planted_trigger (event)

    end


	
end)


--------------------------------------------------------------------
local function On_Built(event)
    local entity = event.created_entity
   	local surface = entity.surface
	local force = entity.force
	local position = entity.position
   
	--- Seedling planted
	if entity.valid and entity.name == "seedling" then
		seed_planted (event)
	end

	
    --- Bio Farm has been built
	if entity.valid and entity.name == "bi-bio-farm" then
	writeDebug("Bio Farm has been built")
		   
		local b_farm = entity
		local pole_name = "bi-bio-farm-electric-pole"  
		local panel_name = "bi-bio-farm-solar-panel"  
		local lamp_name = "bi-bio-farm-light"      
		  
		local create_pole = surface.create_entity({name = pole_name, position = position, force = force}) -- Hidden Power Pole
		local create_panel = surface.create_entity({name = panel_name, position = position, force = force}) -- Hidden Solar Paner
		local create_lamp = surface.create_entity({name = lamp_name, position = position, force = force}) -- Hidden Lamp
		  
		create_pole.minable = false
		create_pole.destructible = false
		create_panel.minable = false
		create_panel.destructible = false
		create_lamp.minable = false
		create_lamp.destructible = false
		
		-- Group Multiple Entities Together
		global.bi_bio_farm_table[b_farm.unit_number] = {base=b_farm, pole=create_pole, panel=create_panel, lamp=create_lamp}

	end

	
	--- Bio Solar Boiler / Solar Plant has been built
	if entity.valid and entity.name == "bi-solar-boiler-panel" then
	writeDebug("Bio Solar Boiler has been built")
		   
		local solar_plant = entity
		local boiler_solar = "bi-solar-boiler"   		
		local sm_pole_name = "bi-hidden-power-pole"  
		
		local create_solar_boiler = surface.create_entity({name = boiler_solar, position = position, force = force}) -- Hidden Solar Paner
		local create_sm_pole = surface.create_entity({name = sm_pole_name, position = position, force = force}) -- Hidden Power Pole
		
		create_solar_boiler.minable = false
		create_solar_boiler.destructible = false	
 		create_sm_pole.minable = false
		create_sm_pole.destructible = false
		
		-- Group Multiple Entities Together
		global.bi_solar_boiler_table[solar_plant.unit_number] = {base=solar_plant, boiler=create_solar_boiler, pole=create_sm_pole}		
		
	end
	
	
    --- Solar Farm has been built
	if entity.valid and entity.name == "bi-bio-solar-farm" then
	writeDebug("Bio Solar Farm has been built")
		   
		local solar_farm = entity	
		local sm_pole_name = "bi-hidden-power-pole"  
	
		local create_sm_pole = surface.create_entity({name = sm_pole_name, position = position, force = force}) -- Hidden Power Pole
			
 		create_sm_pole.minable = false
		create_sm_pole.destructible = false
		
		-- Group Multiple Entities Together
		global.bi_solar_farm_table[solar_farm.unit_number] = {base=solar_farm, pole=create_sm_pole}		
		
	end

	
	--- Bio Cannon has been built
	if entity.valid and entity.name == "bi-bio-cannon-area" then
	
	
	local New_Bio_Cannon
	local New_Bio_CannonR
	
	writeDebug("Bio Cannon has been built")				

		New_Bio_Cannon  = surface.create_entity({name = "bi-bio-cannon", position = position, direction = event.created_entity.direction, force = force}) -- New Cannon, the first was just used for Radius overlay
		New_Bio_CannonR = surface.create_entity({name = "Bio_Cannon_r", position = position, direction = event.created_entity.direction, force = force}) -- Hidden Radar

		New_Bio_Cannon.health = event.created_entity.health
		
		-- Remove the "Overlay" Entity
		event.created_entity.destroy()
	
		
		New_Bio_CannonR.operable = false
		New_Bio_CannonR.destructible = false
		New_Bio_CannonR.minable = false
		
		if global.Bio_Cannon_Table == nil then
			global.Bio_Cannon_Table = {}
			Event.register(defines.events.on_tick, function(event) end)
		end

		-- Group Multiple Entities Together
		table.insert(global.Bio_Cannon_Table, {New_Bio_Cannon,New_Bio_CannonR,0})
		
	end

	
    --- Arboretum has been built
	if entity.valid and entity.name == "bi-arboretum-area" then
	writeDebug("Arboretum has been built")
		   
		local arboretum_new = "bi-arboretum"
		local radar_name = "bi-arboretum-radar"  
		local pole_name = "bi-hidden-power-pole"
		
		local create_arboretum = surface.create_entity({name = arboretum_new, position = position, direction = entity.direction, force = force})  -- New Arboretum, the first was just used for Radius overlay
		
		local position_c = {position.x - 3.5, position.y + 3.5}
		local create_radar = surface.create_entity({name = radar_name, position = position_c, direction = entity.direction, force = force}) -- Hidden Radar


		create_radar.minable = false
		create_radar.destructible = false

		
		-- Remove the "Overlay" Entity
		event.created_entity.destroy()
		
		-- Group Multiple Entities Together
		global.Arboretum_Table[create_arboretum.unit_number] = {inventory=create_arboretum, radar=create_radar}

	end


	-- Power Rail
	if (entity.valid and entity.name == "bi-straight-rail-power") or (entity.valid and entity.name == "bi-curved-rail-power") then
	writeDebug("Power Rail has been built")
			   
		local rail_track = entity
		local pole_name = "bi-rail-hidden-power-pole"  			
		local create_rail_pole = surface.create_entity({name = pole_name, position = position, force = force}) -- Create Hidden Power Pole
				
		create_rail_pole.minable = false
		create_rail_pole.destructible = false 

		-- Group Multiple Entities Together Together
		global.bi_power_rail_table[rail_track.unit_number] = {base=rail_track, pole=create_rail_pole}		
		
		
		if global.bi_power_rail_table[rail_track.unit_number].pole.valid then
			
			local radius = 5		
			local area = {{position.x - radius, position.y - radius}, {position.x + radius, position.y + radius}}
			local power_rail_poles = {}
			power_rail_poles = surface.find_entities_filtered{area = area, name="bi-rail-hidden-power-pole", force = force}

			if power_rail_poles ~= nil and  #power_rail_poles >= 1 then 				
				
				for i=1, #power_rail_poles do
				
					for _,neighbour in pairs(power_rail_poles[i].neighbours.copper) do					
						if neighbour.name == "bi-rail-hidden-power-pole" or neighbour.name == "bi-power-to-rail-pole" then						
							writeDebug(i.. " Hidden Power Rail Pole found")
							power_rail_poles[i].connect_neighbour(neighbour)						
						else					
							writeDebug(i.. " Hidden Power Rail Pole found")
							power_rail_poles[i].disconnect_neighbour(neighbour)
						end
									
					end
					
				end
			
			end


		end

	end


	--- Disconnect any other power lines from the rail-hidden-power pole
	if entity.valid and entity.type == "electric-pole" then
		
		if entity.name ~= "bi-rail-hidden-power-pole" and entity.name ~= "bi-power-to-rail-pole" then
			
			for _,neighbour in pairs(entity.neighbours.copper) do

				if neighbour.name == "bi-rail-hidden-power-pole" then
					entity.disconnect_neighbour(neighbour)
				end
			
			end
	
		end
		
	end
	
	
end


--------------------------------------------------------------------
local function On_Remove(event)
	
	local entity = event.entity	
	
	--- Bio Farm has been removed	
 	if entity.valid and entity.name == "bi-bio-farm" then
	writeDebug("Bio Farm has been removed")	

		if global.bi_bio_farm_table[entity.unit_number] then
			global.bi_bio_farm_table[entity.unit_number].pole.destroy()	
			global.bi_bio_farm_table[entity.unit_number].panel.destroy()
			global.bi_bio_farm_table[entity.unit_number].lamp.destroy()
			global.bi_bio_farm_table[entity.unit_number] = nil
		end	

		local pos_hash = cantor(entity.position.x,entity.position.y)
        local entity_group = getGroup_entities(pos_hash)
        if entity_group then
            for ix, vx in ipairs(entity_group) do
                if vx == entity then
                    --vx.destroy()
                else
                    vx.destroy()
                end
            end
        end
        ungroup_entities(pos_hash)
	end
		
			
	--- Bio Solar Farm has been removed
   	if entity.valid and entity.name == "bi-bio-solar-farm" then
	writeDebug("Solar Farm has been removed")
		
		if global.bi_solar_farm_table[entity.unit_number] then
			global.bi_solar_farm_table[entity.unit_number].pole.destroy()
			global.bi_solar_farm_table[entity.unit_number] = nil
		end
		
		local pos_hash = cantor(entity.position.x,entity.position.y)
		local entity_group = getGroup_entities(pos_hash)

		if entity_group then
			for ix, vx in ipairs(entity_group) do
				if vx == entity then
					--vx.destroy()
				else
					vx.destroy()
				end
			end
		end
		
		ungroup_entities(pos_hash)
					
	end


	--- Bio Solar Boiler has been removed
   	if entity.valid and entity.name == "bi-solar-boiler-panel" then
	writeDebug("Solar Boiler has been removed")
	
		if global.bi_solar_boiler_table[entity.unit_number] then
			global.bi_solar_boiler_table[entity.unit_number].boiler.destroy()	
			global.bi_solar_boiler_table[entity.unit_number].pole.destroy()
			global.bi_solar_boiler_table[entity.unit_number] = nil
		end
		
		local pos_hash = cantor(entity.position.x,entity.position.y)
		local entity_group = getGroup_entities(pos_hash)

		if entity_group then
			for ix, vx in ipairs(entity_group) do
				if vx == entity then
					--vx.destroy()
				else
					vx.destroy()
				end
			end
		end
		
		ungroup_entities(pos_hash)
			
	end
			

	--- Power Rail has been removed
   	if (entity.valid and entity.name == "bi-straight-rail-power") or (entity.valid and entity.name == "bi-curved-rail-power") then
	writeDebug("Power-Rail has been removed")
	
		if global.bi_power_rail_table[entity.unit_number] then	
			global.bi_power_rail_table[entity.unit_number].pole.destroy()	
			global.bi_power_rail_table[entity.unit_number] = nil
		end
			
		local pos_hash = cantor(entity.position.x,entity.position.y)
        local entity_group = getGroup_entities(pos_hash)
        if entity_group then
            for ix, vx in ipairs(entity_group) do
                if vx == entity then
                    --vx.destroy()
                else
                    vx.destroy()
                end
            end
        end
		
        ungroup_entities(pos_hash)
		
	end

	
	--- Arboretum has been removed
   	if entity.valid and entity.name == "bi-arboretum" then
	writeDebug("Arboretum has been removed")	
		
		if global.Arboretum_Table[entity.unit_number] then
			global.Arboretum_Table[entity.unit_number].radar.destroy()
			global.Arboretum_Table[entity.unit_number] = nil
		end
		
	end


	
	--- Seedling Removed
	if entity.valid and entity.name == "seedling" then
	writeDebug("Seedling has been removed")
	
		for k, v in pairs(global.bi.tree_growing) do
			if v.position.x == entity.position.x and v.position.y == entity.position.y then
				table.remove(global.bi.tree_growing, k)
				return
			end
		end

	end	
	
	
end


--------------------------------------------------------------------
local function On_Death(event)

	local entity = event.entity
	
	--- Bio Farm has been destroyed	
 	if entity.valid and entity.name == "bi-bio-farm" then
	writeDebug("Bio Farm has been destroyed")	

		if global.bi_bio_farm_table[entity.unit_number] then
			global.bi_bio_farm_table[entity.unit_number].pole.destroy()	
			global.bi_bio_farm_table[entity.unit_number].panel.destroy()
			global.bi_bio_farm_table[entity.unit_number].lamp.destroy()
			global.bi_bio_farm_table[entity.unit_number] = nil
		end	

		local pos_hash = cantor(entity.position.x,entity.position.y)
        local entity_group = getGroup_entities(pos_hash)
        if entity_group then
            for ix, vx in ipairs(entity_group) do
                if vx == entity then
                    --vx.destroy()
                else
                    vx.destroy()
                end
            end
        end
		
        ungroup_entities(pos_hash)
		
	end

	
	--- Bio Solar Farm has been destroyed
   	if entity.valid and entity.name == "bi-bio-solar-farm" then
	writeDebug("Solar Farm has been destroyed")
		
		if global.bi_solar_farm_table[entity.unit_number] then
			global.bi_solar_farm_table[entity.unit_number].pole.destroy()
			global.bi_solar_farm_table[entity.unit_number] = nil
		end
		
		local pos_hash = cantor(entity.position.x,entity.position.y)
		local entity_group = getGroup_entities(pos_hash)

		if entity_group then
			for ix, vx in ipairs(entity_group) do
				if vx == entity then
					--vx.destroy()
				else
					vx.destroy()
				end
			end
		end
		
		ungroup_entities(pos_hash)
		
	end


	--- Bio Solar Boiler has been destroyed
   	if entity.valid and entity.name == "bi-solar-boiler-panel" then
	writeDebug("Solar Boiler has been destroyed")
	
		if global.bi_solar_boiler_table[entity.unit_number] then
			global.bi_solar_boiler_table[entity.unit_number].boiler.destroy()	
			global.bi_solar_boiler_table[entity.unit_number].pole.destroy()
			global.bi_solar_boiler_table[entity.unit_number] = nil
		end
		
		local pos_hash = cantor(entity.position.x,entity.position.y)
		local entity_group = getGroup_entities(pos_hash)

		if entity_group then
			for ix, vx in ipairs(entity_group) do
				if vx == entity then
					--vx.destroy()
				else
					vx.destroy()
				end
			end
		end
		
		ungroup_entities(pos_hash)
			
	end
	
	
	--- Power Rail has been destroyed
   	if (entity.valid and entity.name == "bi-straight-rail-power") or (entity.valid and entity.name == "bi-curved-rail-power") then
	writeDebug("Power-Rail has been destroyed")
	
		if global.bi_power_rail_table[entity.unit_number] then	
			global.bi_power_rail_table[entity.unit_number].pole.destroy()	
			global.bi_power_rail_table[entity.unit_number] = nil
		end
			
		local pos_hash = cantor(entity.position.x,entity.position.y)
        local entity_group = getGroup_entities(pos_hash)
        if entity_group then
            for ix, vx in ipairs(entity_group) do
                if vx == entity then
                    --vx.destroy()
                else
                    vx.destroy()
                end
            end
        end
		
        ungroup_entities(pos_hash)
		
	end
	
	
	--- Arboretum has been removed
   	if entity.valid and entity.name == "bi-arboretum" then
	writeDebug("Arboretum has been removed")	
		
		if global.Arboretum_Table[entity.unit_number] then
			global.Arboretum_Table[entity.unit_number].radar.destroy()
			global.Arboretum_Table[entity.unit_number] = nil
		end
		
	end

	
	--- Seedling destroyed
	if entity.valid and entity.name == "seedling" then
	writeDebug("Seedling has been destroyed")
	
		for k, v in pairs(global.bi.tree_growing) do
			if v.position.x == entity.position.x and v.position.y == entity.position.y then
				table.remove(global.bi.tree_growing, k)
				return
			end
		end

	end	

	
end


----------------Radars Scanning Function, used by Terraformer (Arboretum)  -----------------------------
script.on_event(defines.events.on_sector_scanned, function(event)
	
	---- Each time a Arboretum-Radar scans a sector  ----	
	if event.radar.name == "bi-arboretum-radar" then
		
		local num = (event.radar.unit_number-1) --< Unit number of arboretum assembler
		
		--writeDebug("The Radar Unit # is: "..event.radar.unit_number)
		--writeDebug("The num (Asembler) Unit # is: "..num)

		if game.active_mods["omnimatter_fluid"] then 
			Get_Arboretum_Recipe_omnimatter_fluid(global.Arboretum_Table[num], event) 
		else
			Get_Arboretum_Recipe(global.Arboretum_Table[num], event) 
		end	
		
		
		
	end

	
end)


----- Solar Mat stuff
--------------------------------------------------------------------
local function Solar_Mat (event, surface)

	for i, vv in ipairs(event.tiles) do
		local position = vv.position
		local currentTilename = surface.get_tile(position.x,position.y).name
		
		if currentTilename == "bi-solar-mat" then
			writeDebug("Solar Mat has been built")
				
			if event.force ~= nil then
				local force = event.force
				writeDebug(force)
			else
				local force = "player"
				writeDebug(force)
			end	
		
			local solar_mat = surface.get_tile(position.x,position.y)
			local sm_pole_name = "bi-musk-mat-pole"  
			local sm_panel_name = "bi-musk-mat-solar-panel"  
			  
			local create_sm_pole = surface.create_entity({name = sm_pole_name, position = {position.x + 0.5, position.y + 0.5}, force = force})
			local create_sm_panel = surface.create_entity({name = sm_panel_name, position = {position.x + 0.5, position.y + 0.5}, force = force})
			  
			create_sm_pole.minable = false
			create_sm_pole.destructible = false
			create_sm_panel.minable = false
			create_sm_panel.destructible = false
		
		else	
		
			local radius = 0.5
			local area = {{position.x - radius, position.y - radius}, {position.x + radius, position.y + radius}}
			writeDebug("NOT Solar Mat")
			--local entities = surface.find_entities(area)
			--local entity1 = entities[1]
			local entity1 = {}
			entity1 = surface.find_entities_filtered{area=area, name="bi-musk-mat-pole", limit=1}
			
						
			if entity1 ~= nil then 		
				writeDebug(entity1.name)	
				for _, o in pairs(surface.find_entities_filtered({area = area, name = "bi-musk-mat-pole"})) do o.destroy() end	

				--writeDebug("bi-musk-mat-pole Removed")
			else
				--writeDebug("bi-musk-mat-pole not found")				
			end
				
			--- Remove the Hidden Solar Panel						
			--local entity2 = entities[1]
			local entity2 = {}
			entity2 = surface.find_entities_filtered{area=area, name="bi-musk-mat-solar-panel", limit=1}	
			
			if entity2 ~= nil then 
				writeDebug(entity2.name)		
				for _, o in pairs(surface.find_entities_filtered({area = area, name = "bi-musk-mat-solar-panel"})) do o.destroy() end	

				--writeDebug("bi-musk-mat-solar-panel Removed")
			else
				--writeDebug("bi-musk-mat-solar-panel not found")				
			end


			
		end
	end	

end


local function Player_Tile_Built(event)

	local player = game.players[event.player_index]
	local surface = player and player.surface


	if event.tiles then Solar_Mat (event, surface) end

	
end

	
local function Robot_Tile_Built(event)


	local robot = event.robot
	local surface = robot.surface
	
	-- fix #2 Error while running event Bio_Industries::on_robot_built_tile
	if surface == nil then
		return
	end
	
	if event.tiles then Solar_Mat (event, surface) end

end


--------------------------------------------------------------------
local function solar_mat_removed_at(surface, position)
   local radius = 0.5
   local area = {{position.x - radius, position.y - radius}, {position.x + radius, position.y + radius}}
   local n = 0
   for _,o in next,surface.find_entities_filtered{name='bi-musk-mat-pole',area=area} or {}
      do o.destroy() n = n+1 end
   --writedebug(string.format('%g bi-musk-mat-poles removed',n))
   for _,o in next,surface.find_entities_filtered{name='bi-musk-mat-solar-panel',area=area} or {}
      do o.destroy() n = n+1 end
   --writedebug(string.format('bi-musk-mat-solar-panel',n))
   end

local function Player_Tile_Remove(event)
   local player = game.players[event.player_index]
   if event.item_stack.name == 'bi-solar-mat' and player.mining_state.mining then
     -- writedebug(string.format('%g solar mats removed',event.item_stack.count))
      return solar_mat_removed_at(player.surface, player.mining_state.position)
      end
   end

local function Robot_Tile_Remove(event)
   local robot = event.robot 
   if event.item_stack.name == 'bi-solar-mat' then
     -- writedebug(string.format('%g solar mats removed',event.item_stack.count))
      return solar_mat_removed_at(robot.surface,robot.position)
      end
   end
--------------------------------------------------------------------

--------------------------------------------
--[[
Event.register(defines.events.on_tick, function(event)	


	if game.tick % 60 == 0  then

		writeDebug("prospect_chance: " .. global.prospect_chance)
		global.prospect_chance = global.prospect_chance + 1
		writeDebug("prospect_richness: " .. global.prospect_richness)

	end
	

end)
]]


---------------------------------------------
script.on_event(defines.events.on_research_finished, function(event)

	local research = event.research.name

	if research == "bi-tech-bio-inf-prospecting-1" then

	global.prospect_chance = global.prospect_chance + 1
	global.prospect_richness = global.prospect_richness * 1.05
	
		
		writeDebug("prospect_chance: " .. global.prospect_chance)
		writeDebug("prospect_richness: " .. global.prospect_richness)
	end
	
  
end)


script.on_load(On_Load)
script.on_configuration_changed(On_Config_Change)
script.on_init(On_Init)


local build_events = {defines.events.on_built_entity, defines.events.on_robot_built_entity}
script.on_event(build_events, On_Built)

local pre_remove_events = {defines.events.on_pre_player_mined_item, defines.events.on_robot_pre_mined}
script.on_event(pre_remove_events, On_Remove)

local death_events = {defines.events.on_entity_died}
script.on_event(death_events, On_Death)

local player_build_event = {defines.events.on_player_built_tile}
script.on_event(player_build_event, Player_Tile_Built)

local robot_build_event = {defines.events.on_robot_built_tile}
script.on_event(robot_build_event, Robot_Tile_Built)

local remove_events = {defines.events.on_player_mined_item}
script.on_event(remove_events, Player_Tile_Remove)

local remove_events = {defines.events.on_robot_mined}
script.on_event(remove_events, Robot_Tile_Remove)


-------------------- For Testing --------------

--[[
if QC_Mod == true then  

	script.on_event(defines.events.on_player_created, function(event)
	local iteminsert = game.players[event.player_index].insert
	iteminsert{name="bi-bio-solar-farm", count=5}
	iteminsert{name="bi-burner-pump", count=5}
	iteminsert{name="pumpjack", count=5}
	iteminsert{name="medium-electric-pole", count=5}
	iteminsert{name="lab", count=5}
	iteminsert{name="automation-science-pack", count=500}
	iteminsert{name="logistic-science-pack", count=500}
	iteminsert{name="chemical-science-pack", count=500}
	iteminsert{name="utility-science-pack", count=500}
	iteminsert{name="pipe", count=50}
	iteminsert{name="iron-gear-wheel", count=50}
	iteminsert{name="pellet-coke", count=50}	
	iteminsert{name="iron-plate", count=50}	
	iteminsert{name="copper-plate", count=50}		
	
	end)

end
]]

--------------------------------------------------------------------
--- DeBug Messages 
--------------------------------------------------------------------
function writeDebug(message)
	if QC_Mod == true then 
		for i, player in pairs(game.players) do
			player.print(tostring(message))
		end
	end
end

