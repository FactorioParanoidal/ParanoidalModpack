log("turrets.lua")
--[[check and import utils]]
if not heroturrets.defines then require ("prototypes.scripts.defines") end

--[[defines]]

--[[create local references]]
--[[util]]
local is_valid = heroturrets.util.is_valid
local print = heroturrets.util.print
local starts_with = heroturrets.util.starts_with
local ends_with = heroturrets.util.ends_with
local table_contains = heroturrets.util.table.contains
local is_valid_and_persistant = heroturrets.util.entity.is_valid_and_persistant
local distance = heroturrets.util.distance
local get_entities_around  = heroturrets.util.entity.get_entities_around
local parseCustomRankTable = heroturrets.util.parseCustomRankTable
local local_split = heroturrets.util.local_split
local local_trim = heroturrets.util.local_trim
local find_recipes_for = function(name, force)
	local p = prototypes.entity[name]
	local ret = {}
	if p~=nil then 
	table.insert(ret,p)
	end
	return ret
end

--heroturrets.util.recipe.find_recipes_for

--[[unitialized globals]]

--[[ensure globals]]
local multipliers = {}
multipliers["ammo-turret"] = settings.startup["heroturrets-setting-ammo-turret-kill-multiplier"].value
multipliers["fluid-turret"] = settings.startup["heroturrets-setting-fluid-turret-kill-multiplier"].value
multipliers["electric-turret"] = settings.startup["heroturrets-setting-electric-turret-kill-multiplier"].value
multipliers["artillery-turret"] = settings.startup["heroturrets-setting-artillery-turret-kill-multiplier"].value

local useCustomKillsTable = settings.startup["heroturrets-use-csv-kills"].value
local useCustomDamageTable = settings.startup["heroturrets-use-csv-damage"].value

local customKillsTable = settings.startup["heroturrets-csv-kill"].value
local customDamageTable = settings.startup["heroturrets-csv-damage"].value

local maxHealthOnRankUp = settings.startup["heroturrets-max-health-on-rank"].value

--- Build out priority target list for turrets that support it
---@param entity LuaEntity
local build_priority_targets = function(entity)
	local targets_Table = {}
	local index = 1

	while true do
		--check for a valid entity (was a issue that was brought up in the mod portal )
  		if not entity.valid then break end

		--only way to recursively call the priority list.
		---As soon as it is "Not Successful" (Out of Bounds error), then break the loop
  		local success, target = pcall(entity.get_priority_target, index)
  		if not success then break end
 		table.insert(targets_Table, target)
		index = index + 1
	end

	return targets_Table
end

local get_circuit_connections = function(entity)
	if not entity.valid then return {} end

	local current_wire_connections = entity.get_wire_connectors()
	local source_connections = {}

	for k,v in pairs(current_wire_connections) do
		if not v.valid then break end
		
		if v.connection_count > 0 and v.connections ~= nil then
			if v.wire_connector_id == defines.wire_connector_id.circuit_red then 
				source_connections.red = {}
				for _, connection in ipairs(v.connections) do
					table.insert(source_connections.red,connection)
				end
				elseif v.wire_connector_id == defines.wire_connector_id.circuit_green then
					source_connections.green = {}
					for _, connection in ipairs(v.connections) do
						table.insert(source_connections.green,connection)
					end
			end

		end
	  end
	  return source_connections
end

local build_circuit_connections = function(new_entity,source_connections)
	if next(source_connections) ~= nil  then
		local dest_connections = new_entity.get_wire_connectors(true) --sending true to initialize connecters
		for k,v in pairs(dest_connections) do
			if not v.valid then break end

			if v.wire_connector_id == defines.wire_connector_id.circuit_red then 
				if source_connections.red ~= nil then
					for _, connection in ipairs(source_connections.red) do
						if connection ~= nil then
							v.connect_to(connection.target)
						end
					end
				end
			elseif v.wire_connector_id == defines.wire_connector_id.circuit_green then
				if source_connections.green ~= nil then
					for _, connection in ipairs(source_connections.green) do
						if connection ~= nil then
							v.connect_to(connection.target)
						end
					end
				end
			end
		end
	end
end


local local_replace_turret = function(entity,recipe)	
	local s = entity.surface
	local p = entity.position
	local f = entity.force
	local h = entity.health
	local mh = entity.max_health
	local k = entity.kills
	local dd = entity.damage_dealt
	local d = entity.direction
	local o = entity.orientation
	local q = entity.quality

	--- Get priority targeting information
	
	local ignore_Unprioritised_targets = nil
	if(entity.type ~= "artillery-turret") then
		if entity.ignore_unprioritised_targets ~= nil then
			ignore_Unprioritised_targets =  entity.ignore_unprioritised_targets 
		end
	end


	---get control behavior for circuit control
	local control_behavior = entity.get_control_behavior()
    local controlBehaviorData = nil
	if control_behavior ~=  nil then
		if(entity.type == "artillery-turret") then
			 controlBehaviorData = {
				--inherited behaviors
				circuit_enable_disable = control_behavior.circuit_enable_disable,
				circuit_condition = control_behavior.circuit_condition,
				connect_to_logistic_network = control_behavior.connect_to_logistic_network,
				logistic_condition = control_behavior.logistic_condition,

				--Artillery specific
				read_ammo = control_behavior.read_ammo
			}
		else
			controlBehaviorData = {
				--inherited behaviors
				circuit_enable_disable = control_behavior.circuit_enable_disable,
				circuit_condition = control_behavior.circuit_condition,
				connect_to_logistic_network = control_behavior.connect_to_logistic_network,
				logistic_condition = control_behavior.logistic_condition,

				--turret specific
				set_priority_list = control_behavior.set_priority_list,
				set_ignore_unlisted_targets = control_behavior.set_ignore_unlisted_targets,
				ignore_unlisted_targets_condition = control_behavior.ignore_unlisted_targets_condition,
				read_ammo = control_behavior.read_ammo
			}
		end
	end

	--- build out target list
	local targets_Table = build_priority_targets(entity)
	
	--Build out connections 
	--TODO : Check for no connections...
	local source_connections = get_circuit_connections(entity)

	local fluid = {}
	if entity.fluidbox ~= nil then 
	  for k = 1, #entity.fluidbox do fb = entity.fluidbox[k]
		if fb ~=nil and fb.name ~= nil then
			table.insert(fluid,fb)
		end
	  end
	end
	local i = entity.get_inventory(defines.inventory.turret_ammo)
	local c = nil
	if i ~= nil then 
		c = i.get_contents()		
	end
	if  entity.can_be_destroyed() ~= true or 
		entity.destroy({raise_destroy = true}) ~= true then return end
	
	local new_entity = s.create_entity{name=recipe.name, position=p, force = f, direction = d, orientation = o, raise_built = true,quality = q,ignore_unprioritised_targets = ignore_Unprioritised_targets}
	if new_entity == nil then return end -- error shouldn't happen

	if not maxHealthOnRankUp then 
		if h ~= mh then new_entity.health = h end
	end

	new_entity.kills = k
	new_entity.damage_dealt = dd

	local inv = new_entity.get_inventory(defines.inventory.turret_ammo)
	if inv ~= nil and c ~= nil then
		for index, inv_typetable in pairs(c) do
			inv.insert{name=inv_typetable.name,count=inv_typetable.count,quality = inv_typetable.quality}
		end
	end

	if fluid ~=nil then
		for k = 1, #fluid do fb = fluid[k]
			--Commenting out for now until I can get a fix for the whole fluid network being drained
			--new_entity.fluidbox[k] = fb
		end
	end
	--build out the target priority list in the new turret entity
	if targets_Table ~= nil then
		for index, priority_target in pairs(targets_Table) do
			new_entity.set_priority_target(index,priority_target)
		end
	end
	
	if ignore_Unprioritised_targets ~= nil then
		new_entity.ignore_unprioritised_targets =  ignore_Unprioritised_targets 
	end
	--rebuild circuit network connections
	build_circuit_connections(new_entity,source_connections)
	
	-- build out circuit behavior if present
	if(controlBehaviorData ~= nil) then
		local new_control_behavior = new_entity.get_or_create_control_behavior()

		--inherited behaviors
		new_control_behavior.circuit_enable_disable = controlBehaviorData.circuit_enable_disable
		new_control_behavior.circuit_condition = controlBehaviorData.circuit_condition
		new_control_behavior.connect_to_logistic_network = controlBehaviorData.connect_to_logistic_network
		new_control_behavior.logistic_condition = controlBehaviorData.logistic_condition
		new_control_behavior.read_ammo = controlBehaviorData.read_ammo

		if(new_entity.type ~= "artillery-turret") then
			--turret specific behaviors
			new_control_behavior.set_priority_list = controlBehaviorData.set_priority_list
			new_control_behavior.set_ignore_unlisted_targets = controlBehaviorData.set_ignore_unlisted_targets
			new_control_behavior.ignore_unlisted_targets_condition = controlBehaviorData.ignore_unlisted_targets_condition
		end

	end

end

local turret_types = {"ammo-turret", "fluid-turret","electric-turret","artillery-turret"}


local local_get_names = function()
    local names = {"Private 1st Class","Corporal","Sergeant","General","Field Marshal","Supreme Commander"}
    if  settings.startup["heroturrets-use-csv"].value ~= true then return names end
    local custom_string = settings.startup["heroturrets-csv-names"].value 
    if custom_string == nil then return names end
    custom_string = local_trim(custom_string)
    if #custom_string == 0 then return names end
    local custom = local_split(custom_string,",")
    if #custom < 6 then return names end
    return custom
end


local get_Custom_Damage_Table = function()
	if useCustomDamageTable then
		local customString = local_trim(customDamageTable) 

		if customString == 0 then return nil end
		return parseCustomRankTable(customString)		
    
	end 
end

local get_Custom_Kill_Table = function()
	if useCustomKillsTable then
		local customString = local_trim(customKillsTable) 

		if customString == 0 then return nil end

    	return parseCustomRankTable(customString)		
	end 
end


local damage_table = nil

--- Calculates Damage / Kills table based on the highest and lowest rank values, then distrbutes the integral across the number of ranks
---@param rankTable any
---@param lowValue uint32
---@param highValue uint32
local calculate_Rank_Table = function(rankTable,lowValue,highValue)
	local diff = (highValue-lowValue)/#local_get_names()

	--return an empty table to go to the next. The high rank "value" was lower than the low rank "value". Use the default in this case
	if diff <= 0 then
		return
	end

	local current = lowValue
	for k=1, #local_get_names()-1 do
		table.insert(rankTable,current)
		current = math.floor(current + diff)
	end
	table.insert(rankTable,highValue)
end

local local_get_damage_table = function()
	--if already initialized, use what is currently there
	if damage_table ~= nil then
		 return damage_table 
     end
	 --build out a damage table link this first, in case the customDamageTable fails to parse or doesn't have enough values
	 damage_table = {}
	 calculate_Rank_Table(damage_table,heroturrets.defines.turret_levelup_damage_one,heroturrets.defines.turret_levelup_damage_six)

	local ranks = #local_get_names()
	if useCustomDamageTable then
		local customDamageTable = get_Custom_Damage_Table()

		--if it IS nil, use the previously calculated rank table 
		if customDamageTable ~= nil then
			if #customDamageTable == ranks then
				damage_table = customDamageTable
				--if they aren't equal, try to build out the rank table with the given values
			else
				--last "Rank" Value (should be the high one)
				local customHighValue = customDamageTable[#customDamageTable]
				--first "Rank" Value (should be the high one)
				local customLowValue = customDamageTable[1]
				local tempRankTable = {}
				calculate_Rank_Table(tempRankTable,customLowValue,customHighValue)
				--if tempRankTable is empty, just use the original table
				if next(tempRankTable) ~= nil then
					log("Not enough custom damage values, caculating damage table based on the first and last custom values present.")
					damage_table = tempRankTable
				else
					log("Could not use Custom Damage ranking values, as the lowest rank value is greater than the highest")
				end
				
			end	
		else
			log("Could not use Custom Damage ranking values as some appear to be invalid.")
		end
	-- the "default" Rankings
    elseif ranks == 6 then
		damage_table = {
			heroturrets.defines.turret_levelup_damage_one,
			heroturrets.defines.turret_levelup_damage_two,
			heroturrets.defines.turret_levelup_damage_three,
			heroturrets.defines.turret_levelup_damage_four,
			heroturrets.defines.turret_levelup_damage_five,
			heroturrets.defines.turret_levelup_damage_six
		}		
	end
	return damage_table 
end

local kill_table = nil
local local_get_kill_table = function()
	--if already initialized, use what is currently there
	if kill_table ~= nil then 
		return kill_table 
	end
    --build out a kills table link this first, in case the customkillTable fails to parse or doesn't have enough values
	kill_table = {}
	log("Building kill table")
	calculate_Rank_Table(kill_table,heroturrets.defines.turret_levelup_kills_one,heroturrets.defines.turret_levelup_kills_six)

	local ranks = #local_get_names()
	if useCustomKillsTable then
		local customKillsTable = get_Custom_Kill_Table()

            --if it IS nil, use the previously calculated rank table 
            if customKillsTable ~= nil then
                if #customKillsTable == ranks then
                    kill_table = customKillsTable
                    --if they aren't equal, try to build out the rank table with the given values
                else
                    --last "Rank" Value (should be the high one)
                    local customHighValue = customKillsTable[#customKillsTable]
                    --first "Rank" Value (should be the high one)
                    local customLowValue = customKillsTable[1]
                    local tempRankTable = {}
                    calculate_Rank_Table(tempRankTable,customLowValue,customHighValue)
                    --if tempRankTable is empty, just use the original table
                    if next(tempRankTable) ~= nil then
                        log("Not enough custom Kill values, caculating Kill table based on the first and last custom values present.")
                        kill_table = tempRankTable
                    else
                        log("Could not use Custom Kill ranking values, as the lowest rank value is greater than the highest")
                    end
                    
                end	
            else
                log("Could not use Custom Kill ranking values as some appear to be invalid.")
            end
    elseif ranks == 6 then
		kill_table = {
			heroturrets.defines.turret_levelup_kills_one,
			heroturrets.defines.turret_levelup_kills_two,
			heroturrets.defines.turret_levelup_kills_three,
			heroturrets.defines.turret_levelup_kills_four,
			heroturrets.defines.turret_levelup_kills_five,
			heroturrets.defines.turret_levelup_kills_six,
		}
	else

	end
	log(serpent.block(kill_table))
	return kill_table 
end

local rank_count = nil
local local_turret_added = function(entity,event)	
	if is_valid(event.entity) ~= true then return end	
	if table_contains(turret_types,event.entity.type)  ~= true then return end    
	
	local multiplier = multipliers[event.entity.type]
	if multiplier == nil then multiplier = 1 end	

	
	--[[
		local levelup_four = heroturrets.defines.turret_levelup_kills_four * multiplier
		local levelup_three = heroturrets.defines.turret_levelup_kills_three * multiplier
		local levelup_two = heroturrets.defines.turret_levelup_kills_two * multiplier
		local levelup_one = heroturrets.defines.turret_levelup_kills_one * multiplier
		local levelup_damage_four = heroturrets.defines.turret_levelup_damage_four * multiplier
		local levelup_damage_three = heroturrets.defines.turret_levelup_damage_three * multiplier
		local levelup_damage_two = heroturrets.defines.turret_levelup_damage_two * multiplier
		local levelup_damage_one = heroturrets.defines.turret_levelup_damage_one * multiplier
	]]
	if settings.startup["heroturrets-kill-counter"].value == "Exact" and is_valid(event.tags)and event.tags.kills ~= nil then
		event.entity.kills = event.tags.kills
		if settings.startup["heroturrets-damage-counter"].value == "On" and event.tags.damage_dealt ~= nil  then
			event.entity.damage_dealt = event.tags.damage_dealt
		end		
	else
		if rank_count == nil then rank_count = #local_get_names() end
		for k = 1, rank_count do
			if starts_with(event.entity.name,"hero-turret-"..k) then
				local dmg = event.entity.damage_dealt
				if dgm == nil then dgm = 0 end
				local kills = event.entity.kills
				if kills == nil then kills = 0 end
				event.entity.kills = math.min(4294967295,math.max(local_get_kill_table()[k]*multiplier, kills))
				event.entity.damage_dealt = math.max(local_get_damage_table()[k]*multiplier, dmg)
			end
		end
	end 
	--[[
		elseif starts_with(entity.name,"hero-turret-4") == true then
			local dmg = entity.damage_dealt
			if dgm == nil then dgm = 0 end
			local kills = entity.kills
			if kills == nil then kills = 0 end

			entity.kills = math.max(levelup_four, kills)
			entity.damage_dealt = math.max(levelup_damage_four, dmg)
		elseif starts_with(entity.name,"hero-turret-3") == true then
			local dmg = entity.damage_dealt
			if dgm == nil then dgm = 0 end
			local kills = entity.kills
			if kills == nil then kills = 0 end

			entity.kills = math.max(levelup_three, kills)
			entity.damage_dealt = math.max(levelup_damage_three, dgm)
		elseif starts_with(entity.name,"hero-turret-2") == true then		
			local dmg = entity.damage_dealt
			if dgm == nil then dgm = 0 end
			local kills = entity.kills
			if kills == nil then kills = 0 end
			entity.kills = math.max(levelup_two, kills)
			entity.damage_dealt = math.max(levelup_damage_two, dgm)
		elseif starts_with(entity.name,"hero-turret-1") == true then
			local dmg = entity.damage_dealt
			if dgm == nil then dgm = 0 end
			local kills = entity.kills
			if kills == nil then kills = 0 end

			entity.kills = math.max(levelup_one, kills)
			entity.damage_dealt = math.max(levelup_damage_one, dgm)
		end
	]]
	end

local local_turret_removed = function(entity,event)	
	
	if event ~= nil and event.cause ~= nil and table_contains(turret_types,event.cause.type) and event.cause.kills ~=nil then						
		if settings.startup["heroturrets-allow-artillery-turrets"].value == false and event.cause.type == "artillery-turret" then return end
		
		local multiplier = multipliers[event.cause.type]
		if multiplier == nil then return end

		--[[
			local levelup_four = heroturrets.defines.turret_levelup_kills_four * multiplier
			local levelup_three = heroturrets.defines.turret_levelup_kills_three * multiplier
			local levelup_two = heroturrets.defines.turret_levelup_kills_two * multiplier
			local levelup_one = heroturrets.defines.turret_levelup_kills_one * multiplier
			local levelup_damage_four = heroturrets.defines.turret_levelup_damage_four * multiplier
			local levelup_damage_three = heroturrets.defines.turret_levelup_damage_three * multiplier
			local levelup_damage_two = heroturrets.defines.turret_levelup_damage_two * multiplier
			local levelup_damage_one = heroturrets.defines.turret_levelup_damage_one * multiplier
		]]
			
			if rank_count == nil then rank_count = #local_get_names() end			
			for k = rank_count, 1, -1 do
				if event.cause.kills >= ((local_get_kill_table()[k]*multiplier) - 1) or (settings.startup["heroturrets-allow-damage"].value == "Enabled" and event.cause.damage_dealt >= local_get_damage_table()[k]*multiplier) then		
					
					if starts_with(event.cause.name,"hero-turret") == true then
						--is a hero turret
						if starts_with(event.cause.name,"hero-turret-"..k) then
							--nothing to do
						else
							local new_name = event.cause.name:gsub("hero%-turret%-"..k.."%-for%-", "")
							for j = k-1, 1, -1 do
								new_name = new_name:gsub("hero%-turret%-"..j.."%-for%-", "")
							end
							local ug = find_recipes_for("hero-turret-"..k.."-for-"..new_name,event.cause.force)					
							if #ug ~= 0 then
								local_replace_turret(event.cause,ug[1])
								return
							end
						end
					else
						
						--find upgrade
						local ug = find_recipes_for("hero-turret-"..k.."-for-"..event.cause.name,event.cause.force)
						if #ug ~= 0 then
							local_replace_turret(event.cause,ug[1])
							return
						end
					end
				end
			end
	elseif settings.startup["heroturrets-kill-counter"].value == "Disable" then
		--do nothing		
	else if settings.startup["heroturrets-kill-counter"].value == "Exact" and event ~= nil and is_valid(event.entity) and is_valid(event.buffer) and table_contains(turret_types,event.entity.type) and event.entity.kills ~= nil and event.entity.kills > 0 then	
			if #event.buffer == 1 and event.entity.kills==0 then
				local item = event.buffer[1]
				local standard_item = item.name:sub(1,#item.name-#"-with-tags")
				local stack = {
					name = standard_item,
					count = item.count,
					health = item.health,
					ammo = item.ammo
				}
				if event.buffer.can_set_stack(stack) then
					event.buffer.set_stack(stack)
				elseif item.type == "item-with-tags" then 			
					item.set_tag("kills", event.entity.kills)
					item.custom_description = event.entity.kills .. " Kills"
					if settings.startup["heroturrets-damage-counter"].value == "On" and event.entity.damage_dealt ~=nil then
						item.set_tag("damage_dealt", event.entity.damage_dealt)
					end					
				end
			else
				for k=#event.buffer, 1, -1 do item = event.buffer[k]
					if item.type == "item-with-tags" then 			
						item.set_tag("kills", event.entity.kills)
						item.custom_description = event.entity.kills .. " Kills"
						if settings.startup["heroturrets-damage-counter"].value == "On" and event.entity.damage_dealt ~=nil then
							item.set_tag("damage_dealt", event.entity.damage_dealt)
						end		
					end
				end
			end		
		end
	end
	end

local local_on_post_entity_died = function(event)
	if settings.global["heroturrets-allow-ghost-rank"].value then return end
	if event.ghost ~= nil then	
		local fstr = event.ghost.ghost_name :match("^hero%-turret%-%d%-for%-")
		if fstr ~=nil then
			local base_entity = event.ghost.ghost_name:sub(#fstr+1)
			local force = event.ghost.force
			local direction = event.ghost.direction
			local position = event.ghost.position
			local surface = event.ghost.surface
			event.ghost.destroy()
			surface.create_entity{name = "entity-ghost", inner_name = base_entity, force = force, position = position, direction = direction}
		end
	end
	end


local control = {
	on_removed = local_turret_removed,
	on_added = local_turret_added,
	on_post_entity_died = local_on_post_entity_died
}

heroturrets.register_script(control)