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
local find_recipes_for = function(name, force)
	local p = game.entity_prototypes[name]
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

local local_replace_turret = function(entity,recipe)	
	local s = entity.surface
	local p = entity.position
	local f = entity.force
	local h = entity.health
	local mh = entity.prototype.max_health
	local k = entity.kills
	local dd = entity.damage_dealt
	local d = entity.direction
	local o = entity.orientation

	local fluid = {}
	if entity.fluidbox ~= nil then 
	  for k = 1, #entity.fluidbox do fb = entity.fluidbox[k]
		if fb ~=nil and fb.name ~= nil then
			table.insert(fluid,{name = fb.name, amount = fb.amount, temperature = fb.temperature})
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
	
	local new_entity = s.create_entity{name=recipe.name, position=p, force = f, direction = d, orientation = o, raise_built = true}
	if new_entity == nil then return end -- error shouldn't happen
	if h ~= mh then new_entity.health = h end
	new_entity.kills = k
	new_entity.damage_dealt = dd
	local inv = new_entity.get_inventory(defines.inventory.turret_ammo)
	if inv ~= nil and c ~= nil then
		for name, count in pairs(c) do
			inv.insert{name=name,count=count}
		end
	end
	if fluid ~=nil then
		for k = 1, #fluid do fb = fluid[k]
			new_entity.fluidbox[k] = {name = fb.name, amount = fb.amount, temperature = fb.temperature}
		end
	end

	end

local turret_types = {"ammo-turret", "fluid-turret","electric-turret","artillery-turret"}

local local_trim = function(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end
local local_split = function(inputstr, sep)
        if sep == nil then
            sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            local n_str = local_trim(str)
            if #n_str > 0 and #n_str < 26 and table_contains(t,n_str) == false then
                table.insert(t, n_str)
            end
        end
        return t
end

local local_get_names = function()
    local names = {"Private 1st Class","Corporal","Sergeant","General"}
    if  settings.startup["heroturrets-use-csv"].value ~= true then return names end
    local custom_string = settings.startup["heroturrets-csv-names"].value 
    if custom_string == nil then return names end
    custom_string = local_trim(custom_string)
    if #custom_string == 0 then return names end
    local custom = local_split(custom_string,",")
    if #custom < 4 then return names end
    return custom
end

local damage_table = nil
local local_get_damage_table = function()
	if damage_table ~= nil then return damage_table end

	if ranks == 4 then
		damage_table = {
			heroturrets.defines.turret_levelup_damage_one,
			heroturrets.defines.turret_levelup_damage_two,
			heroturrets.defines.turret_levelup_damage_three,
			heroturrets.defines.turret_levelup_damage_four
		}
	else		
		damage_table = {}
		local diff = (heroturrets.defines.turret_levelup_damage_four-heroturrets.defines.turret_levelup_damage_one)/#local_get_names()
		local current = heroturrets.defines.turret_levelup_damage_one
		for k=1, #local_get_names()-1 do
			table.insert(damage_table,current)
			current = math.floor(current + diff)
		end
		table.insert(damage_table,heroturrets.defines.turret_levelup_damage_four)
	end
	return damage_table 
end

local kill_table = nil
local local_get_kill_table = function()
	if kill_table ~= nil then return kill_table end
	local ranks = #local_get_names()
	if ranks == 4 then
		kill_table = {
			heroturrets.defines.turret_levelup_kills_one,
			heroturrets.defines.turret_levelup_kills_two,
			heroturrets.defines.turret_levelup_kills_three,
			heroturrets.defines.turret_levelup_kills_four
		}
	else
		kill_table = {}
		log("Building kill table")
		local diff = (heroturrets.defines.turret_levelup_kills_four-heroturrets.defines.turret_levelup_kills_one)/#local_get_names()
		local current = heroturrets.defines.turret_levelup_kills_one
		for k=1, #local_get_names()-1 do
			table.insert(kill_table,current)
			current = math.floor(current + diff)
		end
		table.insert(kill_table,heroturrets.defines.turret_levelup_kills_four)
	end
	log(serpent.block(kill_table))
	return kill_table 
end

local rank_count = nil
local local_turret_added = function(entity,event)	
	if is_valid(entity) ~= true then return end	
	local multiplier = multipliers[entity.type]
	if multiplier == nil then multiplier = 1 end	

	if table_contains(turret_types,entity.type)  ~= true then return end    
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
	if settings.startup["heroturrets-kill-counter"].value == "Exact" and is_valid(event.stack) and event.stack.type == "item-with-tags" and event.stack.get_tag("kills") ~= nil then
		entity.kills = event.stack.get_tag("kills")
		if settings.startup["heroturrets-damage-counter"].value == "On" and event.stack.get_tag("damage_dealt") ~= nil  then
			entity.damage_dealt = event.stack.get_tag("damage_dealt")
		end		
	else
		if rank_count == nil then rank_count = #local_get_names() end
		for k = 1, rank_count do
			if starts_with(entity.name,"hero-turret-"..k) then
				local dmg = entity.damage_dealt
				if dgm == nil then dgm = 0 end
				local kills = entity.kills
				if kills == nil then kills = 0 end
				entity.kills = math.max(local_get_kill_table()[k]*multiplier, kills)
				entity.damage_dealt = math.max(local_get_damage_table()[k]*multiplier, dmg)
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
	
	if event ~= nil and is_valid(event.cause) == true and table_contains(turret_types,event.cause.type) and event.cause.kills ~=nil then						
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
			if #event.buffer == 1 and entity.kills==0 then
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
					item.set_tag("kills", entity.kills)
					item.custom_description = entity.kills .. " Kills"
					if settings.startup["heroturrets-damage-counter"].value == "On" and entity.damage_dealt ~=nil then
						item.set_tag("damage_dealt", entity.damage_dealt)
					end					
				end
			else
				for k=#event.buffer, 1, -1 do item = event.buffer[k]
					if item.type == "item-with-tags" then 			
						item.set_tag("kills", entity.kills)
						item.custom_description = entity.kills .. " Kills"
						if settings.startup["heroturrets-damage-counter"].value == "On" and entity.damage_dealt ~=nil then
							item.set_tag("damage_dealt", entity.damage_dealt)
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