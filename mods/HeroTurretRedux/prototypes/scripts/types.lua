--todo check entity creation ammo_category = "cannon-shell" if so record max dist and update ammo
log("Creating Types")
if not heroturrets.defines then require ("prototypes.scripts.defines") end

require ("prototypes.scripts.util") 
heroturrets.util = get_utils()

local starts_with  = heroturrets.util.starts_with
local ends_with  = heroturrets.util.ends_with
local get_name_for = heroturrets.util.get_name_for
local table_contains = heroturrets.util.table.contains
local table_remove = heroturrets.util.table.remove
local create_icon = heroturrets.util.create_icon
local convert_to_string = heroturrets.util.convert_to_string
local name_is_excluded = require("compatibility").turret_name_is_excluded
local recipes_of = heroturrets.util.recipe.find_recipes_for
local parseCustomRankTable = heroturrets.util.parseCustomRankTable
local local_split = heroturrets.util.local_split
local local_trim = heroturrets.util.local_trim

local tech = data.raw["technology"]
--over all buff
local useCustomPercentageBuffTable = settings.startup["heroturrets-use-csv-buff"].value
local customBuffsTableString = settings.startup["heroturrets-csv-buff"].value

--health buff
local useCustomHealthBuffTable = settings.startup["heroturrets-use-csv-health-buff"].value
local customHealthBuffsTableString = settings.startup["heroturrets-csv-health-buff"].value

--range buff
local useCustomRangeBuffTable = settings.startup["heroturrets-use-csv-range-buff"].value
local customRangeBuffsTableString = settings.startup["heroturrets-csv-range-buff"].value

--Cooldown buff
local useCustomCooldownBuffTable = settings.startup["heroturrets-use-csv-firerate-buff"].value
local customCooldownBuffTable = settings.startup["heroturrets-csv-firerate-buff"].value

--Attack Speed
local useCustomAttackSpeedBuffTable = settings.startup["heroturrets-use-csv-attack-speed-buff"].value
local customAttackSpeedBuffTable = settings.startup["heroturrets-csv-attack-speed-buff"].value

--Rotation
local useCustomTurretRotationBuffTable = settings.startup["heroturrets-use-csv-turret-rotation-buff"].value
local customTurretRotationBuffTable = settings.startup["heroturrets-csv-turret-rotation-buff"].value

local rankBuffsTable = nil
local healthBuffsTable = nil
local rangeBuffsTable = nil
local cooldownBuffsTable = nil
local attackSpeedBuffsTable = nil
local turretRotationBuffsTable = nil

local types_with_items = {}
for category, prototypes in pairs(data.raw) do
  local name, prototype = next(prototypes)
  if name and prototype ~= nil and prototype.stack_size then table.insert(types_with_items, category) end
end


local item_list = nil

local local_get_item = function(name)
    if item_list == nil then
		item_list = {}
		for _, category in pairs(types_with_items) do
			for name,item in pairs(data.raw[category]) do
				if item.place_result ~= nil then
					local placed = item.place_result
					if item_list[placed] then
						--log("item entity place collision: "..name.." "..placed)
						if placed == name then
							item_list[placed] = item
						end						
					else
						item_list[placed] = item
					end
				end
			end
		end
	end
    --end honk
	return item_list[name]
    end

local is_animated = function(entity)
    -- FORTHEKING --- MIGHT NEED TO ADD
   if not entity or not entity.graphics_set or not entity.graphics_set.base_visualisation then
        return false
    else 
        return true
    end
end

local is_animated_nesw = function(entity)   
    --skip for tesla turrets
    if entity.graphics_set.base_visualisation.animation == nil then
        return false
    end
    local directions = {"north", "east", "south", "west"}
    for _, dir in ipairs(directions) do
        if (entity.graphics_set.base_visualisation.animation[dir] and entity.graphics_set.base_visualisation.animation[dir].layers) then
            return true
        end
    end
    return false

end
local is_base_nesw = function(entity)
    if not entity or not entity.base_picture then return false end

    local directions = {"north", "east", "south", "west"}
    for _, dir in ipairs(directions) do
        if not (entity.base_picture[dir] and entity.base_picture[dir].layers) then
            return false
        end
    end
    return true
end

local is_unkown_nesw = function(entity)
	if entity == nil then return false end
    local left = nil        
    local top = nil

    local box = entity.drawing_box
    if box == nil then box = entity.selection_box end
    if box == nil then box = entity.collision_box end

    if (entity.type == "ammo-turret" or entity.type == "electric-turret" or entity.type == "fluid-turret") and entity.base_picture == nil and box ~= nil then   
        return true
    end
    return false
end

-- added "layer" as an optional paramter. Only used to calculate repeat count for animations
local get_badge = function(rank,top,left,rc,layer) --added 
    if(layer ~= nil) then
        rc = (layer.repeat_count or 1) * (layer.frame_count or 1)
    end

    local tint = {r=1.0,g=1.0,b=1.0,a=1}
    if rank > 8 then
        tint = {r=1.0,g=0.5,b=0.15,a=1}
        rank = rank - 8
    elseif rank > 4 then 
        tint = {r=1.0,g=0.15,b=0.15,a=1}
        rank = rank - 4
    end
    local img = {
                    filename = "__HeroTurretRedux__/graphics/entity/turret/hero-"..rank.."-base.png",
                    priority = "high",
                    width = 23,
                    height = 24,
                    direction_count = 1,
                    frame_count = 1,
                    repeat_count = rc,
                    shift = util.by_pixel((left)*-1,top+(24/3)),
                    tint = tint,
                    hr_version =
                    {
                        filename = "__HeroTurretRedux__/graphics/entity/turret/hr-hero-"..rank.."-base.png",
                        priority = "high",
                        line_length = 1,
                        width = 46,
                        height = 48,
                        frame_count = 1,
                        direction_count = 1,
                        repeat_count = rc,
                        shift = util.by_pixel((left)*-1,top+(48/3)),
                        tint = tint,
                        scale = 0.5
                    }
                }
    return img
end
local get_rampant_badge = function(rank,top,left,rc,dc)
    local tint = {r=1.0,g=1.0,b=1.0,a=1}
    if rank > 8 then
        tint = {r=1.0,g=0.5,b=0.15,a=1}
        rank = rank - 8
    elseif rank > 4 then 
        tint = {r=1.0,g=0.15,b=0.15,a=1}
        rank = rank - 4
    end
    local img = {
                    filename = "__HeroTurretRedux__/graphics/entity/turret/hero-"..rank.."-base.png",
                    priority = "high",
                    width = 23,
                    height = 24,
                    direction_count = dc,
                    frame_count = 1,
                    repeat_count = rc,
                    shift = util.by_pixel((left)*-1,top+(24/3)),
                    tint = tint,
                    hr_version =
                    {
                        filename = "__HeroTurretRedux__/graphics/entity/turret/hr-hero-"..rank.."-base.png",
                        priority = "high",
                        line_length = 1,
                        width = 46,
                        height = 48,
                        frame_count = 1,
                        direction_count = dc,
                        repeat_count = rc,
                        shift = util.by_pixel((left)*-1,top+(48/3)),
                        tint = tint,
                        scale = 0.5
                    }
                }
    return img
end


--[[
   Update as military upgrades effect adds 
      {
        type = "turret-attack",
        turret_id = "flamethrower-turret",
        modifier = x
      } 
      note the turret-id
]]
local update_fluid_turret_tech = function(entity, name,rank)
    log("Updating tech for refined flammables" .. " for "..entity.name)
    for _, tech in pairs(tech) do
        if tech.name:match("^refined%-flammables%-") and tech.effects then            
            local effect = nil
            for _, eff in pairs(tech.effects) do
                if eff.type == "turret-attack" and eff.turret_id == entity.name then
                    effect = table.deepcopy(eff)
                end
            end
            if effect ~= nil then 
                log("Adding tech for "..tech.name .. " for "..entity.name)
                table.insert(tech.effects, {type="turret-attack", turret_id = name, modifier = effect.modifier*(1+(0.25*rank)) })
            else
                log("Missing tech for "..tech.name .. " for "..entity.name)
            end
        end
    end
    end

local update_ammo_turret_tech_old = function(entity, name, rank)
    log("Updating tech for physical projectile damage")
    for _, tech in pairs(tech) do
        if tech.name:match("^physical%-projectile%-damage%-") and tech.effects then
            local effect = nil
            for _, eff in pairs(tech.effects) do
                if eff.type == "turret-attack" and eff.turret_id == entity.name then
                    effect = table.deepcopy(eff)
                end
            end
            if effect ~= nil then 
                log("Adding tech for "..tech.name .. " for "..entity.name)
                table.insert(tech.effects, {type="turret-attack", turret_id = name, modifier = effect.modifier*(1+(0.25*rank))})
            else 
                log("Missing tech for "..tech.name .. " for "..entity.name)
            end
        end
    end
    end

 local update_ammo_turret_tech = function(entity, name,rank)
    for _, tech in pairs(tech) do
        if tech.effects then
            local effect = nil
            for _, eff in pairs(tech.effects) do
                if eff.type == "turret-attack" then
                    if eff.turret_id == entity.name then
                        effect = eff
                    elseif eff.turret_id == name then
                        effect = nil
                    end
                end
            end
            if effect ~= nil then
                table.insert(tech.effects, {type="turret-attack", turret_id = name, modifier = effect.modifier*(1+(0.25*rank))})
            end
        end
    end
end

local local_create_turret_with_tags = function(turret)
    local name_with_tags = turret.item.name.."-with-tags"
    
    local item_with_tags = table.deepcopy(turret.item)
    item_with_tags.type = "item-with-tags"
    item_with_tags.hidden_in_factoriopedia = true
    item_with_tags.name = name_with_tags
    item_with_tags.localised_name = turret.item.localised_name
    item_with_tags.localised_description = turret.item.localised_desc
    item_with_tags.localised_description = turret.item.localised_desc
    item_with_tags.order = ((turret.item.order or "[")..turret.item.name.."]")..".tag"
    turret.entity.minable.result = name_with_tags
    data:extend({item_with_tags})
end

-- Return nil if it cannot build the table
local custom_buff_table_builder = function(csvString,type,names)
    -- start custom buff parsing
    local customString = local_trim(csvString) 
    -- if string is empty, return the default 
    if customString == nil or customString == '' then
        return nil
    end

    local parsedBuffsTable =  parseCustomRankTable(customString)
    
    if parsedBuffsTable == nil or next(parsedBuffsTable) == nil then
        log("Could not parse custom buffs csv values, using default buffs. Was the custom buffs table: ".. type)
        return nil
    end
    --if they are equal, build out the table then return the current requested rank
    local customRankBuffsTable = {}
    if #parsedBuffsTable == #names then
        for j = 1, #names do
            local buff = math.min(10, parsedBuffsTable[j] / 100)
            table.insert(customRankBuffsTable,buff)
        end

        if next(customRankBuffsTable) then
            return customRankBuffsTable
        end

        return nil
    end

    --if they are not equal, get the last buff and use it to build out a buff table
    local customBuffHighestValue = math.min(10,parsedBuffsTable[#parsedBuffsTable] / 100)
    for j = 1, #names do
        local buff = customBuffHighestValue * (j / #names)

        table.insert(customRankBuffsTable,buff)
    end
    if next(customRankBuffsTable) then
            return customRankBuffsTable
    end

    return nil
end

   local function as_array(x)
  if type(x) ~= "table" then return nil end
  if x[1] ~= nil then return x end      -- already an array
  return { x }                          -- single table -> array
end

local function ensure_layers(anim)
  if not anim then return nil end
  if anim.layers then return anim.layers end

  -- Convert single animation into layered form
  local single = anim
  anim = { layers = { single } }
  return anim.layers, anim
end

local local_get_names = function()
    local names = {"Private 1st Class","Corporal","Sergeant","General","Field Marshal","Supreme Commander"}
    if  settings.startup["heroturrets-use-csv"].value ~= true then return names end
    local custom_string = settings.startup["heroturrets-csv-names"].value 
    if custom_string == nil then return names end
    custom_string = local_trim(custom_string)
    if #custom_string == 0 then return names end
    local custom = local_split(custom_string,",")
    -- if #custom < 6 then return names end Don't care about this anymore. Fixed the scaling for buffs
    if #custom > 12 then
        for i = #custom, 12 + 1, -1 do
            table.remove(custom, i)
            log("Removing custom name as there were more than 12 custom names")
        end
    end
    return custom
end

--overall buffs
local get_buffs_for_Rank = function(rank)
    if rankBuffsTable then return rankBuffsTable[rank] end
    rankBuffsTable = {}

    local names = local_get_names()

    --build defualt table first. Will also be returned in case the something goes wrong with the customBuffs table
    for j = 1, #names do
        local buff = 0
        if settings.startup["heroturrets-use-csv"].value == true then                           
            buff = 0.60 * (j / #names)       
        elseif j <= 4 then
            -- For ranks 1 to 4: linearly scale up to a 50% bonus.
            buff = 0.50 * (j / 4)
        else
            -- For ranks above 4: linearly scale from 50% (at rank 4)
            -- to 60% (at the final rank).
            buff = 0.50 + ((j - 4) / (#names - 4)) * 0.10
        end

        table.insert(rankBuffsTable,buff)
    end

    if useCustomPercentageBuffTable == false then
        return rankBuffsTable[rank] 
    end

    -- start custom buff parsing
    local customBuffTable = custom_buff_table_builder(customBuffsTableString,"Overall Buffs",names)
    
    if customBuffTable ~= nil and next(customBuffTable) then
        rankBuffsTable = customBuffTable
    end
    

    return rankBuffsTable[rank]
end

--health buffs
local get_health_buffs_for_Rank = function(rank)
    if useCustomHealthBuffTable == false then return nil end

    if healthBuffsTable then return healthBuffsTable[rank] end
    
    healthBuffsTable = {}

    local names = local_get_names()

    --if something goes wrong, use the rankBuffsTable, so initailize it first

    --should already be built, but if not build it
    if rankBuffsTable == nil then
        get_buffs_for_Rank(1)
    end

    ---@diagnostic disable-next-line: need-check-nil
    healthBuffsTable = rankBuffsTable


    -- start custom buff parsing
    local customBuffTable = custom_buff_table_builder(customHealthBuffsTableString,"Health Buffs",names)
    
    if customBuffTable ~= nil and next(customBuffTable) then
        healthBuffsTable = customBuffTable
    end
    
    
        ---@diagnostic disable-next-line: need-check-nil
    return healthBuffsTable[rank]
end

--range buffs
local get_range_buffs_for_Rank = function(rank)
    if useCustomRangeBuffTable == false then return nil end

    if rangeBuffsTable then return rangeBuffsTable[rank] end
    
    rangeBuffsTable = {}

    local names = local_get_names()

    --if something goes wrong, use the rankBuffsTable, so initailize it first

    --should already be built, but if not build it
    if rankBuffsTable == nil then
        get_buffs_for_Rank(1)
    end

    ---@diagnostic disable-next-line: need-check-nil
    rangeBuffsTable = rankBuffsTable


    -- start custom buff parsing
    local customBuffTable = custom_buff_table_builder(customRangeBuffsTableString,"Range Buffs",names)
    
    if customBuffTable ~= nil and next(customBuffTable) then
        rangeBuffsTable = customBuffTable
    end
    
    
    ---@diagnostic disable-next-line: need-check-nil
    return rangeBuffsTable[rank]
end

--Cooldown
local get_cooldown_buffs_for_Rank = function(rank)
    if useCustomCooldownBuffTable == false then return nil end

    if cooldownBuffsTable then return cooldownBuffsTable[rank] end
    
    cooldownBuffsTable = {}

    local names = local_get_names()

    --if something goes wrong, use the rankBuffsTable, so initailize it first

    --should already be built, but if not build it
    if rankBuffsTable == nil then
        get_buffs_for_Rank(1)
    end

    ---@diagnostic disable-next-line: need-check-nil
    --rankbuffstable should always be built before cooldown_buffs_for_ranks
    cooldownBuffsTable = rankBuffsTable


    -- start custom buff parsing
    local customBuffTable = custom_buff_table_builder(customCooldownBuffTable,"Range Buffs",names)
    
    if customBuffTable ~= nil and next(customBuffTable) then
        cooldownBuffsTable = customBuffTable
    end
    
    
        ---@diagnostic disable-next-line: need-check-nil
    return cooldownBuffsTable[rank]
end


local get_attack_speed_buffs_For_Rank = function(rank)
    if useCustomAttackSpeedBuffTable == false then return nil end

    if attackSpeedBuffsTable then return attackSpeedBuffsTable[rank] end
    
    attackSpeedBuffsTable = {}

    local names = local_get_names()

    --if something goes wrong, use the rankBuffsTable, so initailize it first

    --should already be built, but if not build it
    if rankBuffsTable == nil then
        get_buffs_for_Rank(1)
    end

    ---@diagnostic disable-next-line: need-check-nil
    --rankbuffstable should always be built before cooldown_buffs_for_ranks
    attackSpeedBuffsTable = rankBuffsTable


    -- start custom buff parsing
    local customBuffTable = custom_buff_table_builder(customAttackSpeedBuffTable,"Range Buffs",names)
    
    if customBuffTable ~= nil and next(customBuffTable) then
        attackSpeedBuffsTable = customBuffTable
    end
    
    
        ---@diagnostic disable-next-line: need-check-nil
    return attackSpeedBuffsTable[rank]
end

local get_turret_rotation_buffs_For_Rank = function(rank)
    if useCustomTurretRotationBuffTable == false then return nil end

    if turretRotationBuffsTable then return turretRotationBuffsTable[rank] end
    
    turretRotationBuffsTable = {}

    local names = local_get_names()

    --if something goes wrong, use the rankBuffsTable, so initailize it first

    --should already be built, but if not build it
    if rankBuffsTable == nil then
        get_buffs_for_Rank(1)
    end

    ---@diagnostic disable-next-line: need-check-nil
    --rankbuffstable should always be built before cooldown_buffs_for_ranks
    turretRotationBuffsTable = rankBuffsTable


    -- start custom buff parsing
    local customBuffTable = custom_buff_table_builder(customTurretRotationBuffTable,"Range Buffs",names)
    
    if customBuffTable ~= nil and next(customBuffTable) then
        turretRotationBuffsTable = customBuffTable
    end
    
    
        ---@diagnostic disable-next-line: need-check-nil
    return turretRotationBuffsTable[rank]
end


local cannon_ammo_ranges = {}
local local_create_turret = function(turret,rank,rank_string,mod,custom_buff_modifier_percent)
        local tint = {r=1.0,g=1.0,b=1.0,a=1.0}
        local ir = rank
        if ir > 8 then
            tint = {r=1.0,g=0.5,b=0.15,a=1.0}
            ir = ir - 8
        elseif ir > 4 then 
            tint = {r=1.0,g=0.15,b=0.15,a=1.0}
            ir = ir - 4
        end

        local base_icon = 
		{   
           {
            icon = "__HeroTurretRedux__/graphics/icons/hero-"..ir.."-icon.png",
			icon_size = 64,
            icon_mipmaps = 4,
            tint = tint
           }
		}

        local localised_name = get_name_for(turret.item,""," "..rank_string)
        local localised_desc = get_name_for(turret.item,""," "..rank_string)
        local new_icon = create_icon(base_icon, nil, {from = turret.item})
        local rev = {}
        for i=#new_icon, 1, -1 do
	        rev[#rev+1] = new_icon[i]
        end
        new_icon = rev
        local item_name = "hero-turret-"..rank.."-for-"..turret.item.name
        local entity_name = "hero-turret-"..rank.."-for-"..turret.entity.name
        local recipe_name = "hero-turret-"..rank.."-for-"..turret.recipe.name
        log("Creating "..entity_name)
        local name_with_tags = item_name.."-with-tags"
        
        local place_name = "hero-turret-"..rank.."-for-"..turret.item.place_result
        local mine_name = item_name
        local place_name_with_tags = item_name
        local mine_name_with_tags = name_with_tags
        if settings.startup["heroturrets-allow-artillery-turrets"].value == false and turret.entity.type == "artillery-turret" then
            place_name = turret.item.place_result --turret.entity.name
            place_name_with_tags = turret.item.name
            mine_name = turret.item.name
            mine_name_with_tags = turret.item.name
        end

        local item = {
            type = "item",
            name = item_name,
            localised_name = localised_name,
            localised_description = localised_desc,
            icon = false,
            icons = new_icon,
            icon_size = 64,
            --hide_from_player_crafting = true,

            subgroup = turret.item.subgroup,
            order = ((turret.item.order or "[")..turret.item.name.."]").."["..rank.."]",
            place_result = place_name,            
            stack_size = turret.item.stack_size or 1,
            hidden_in_factoriopedia = true
        }
        
        local item_with_tags = {
            type = "item-with-tags",
            name = name_with_tags,
            localised_name = localised_name,
            localised_description = localised_desc,
            icon = false,
            icons = new_icon,
            icon_size = 64,
            --hide_from_player_crafting = true,
            subgroup = turret.item.subgroup,
            order = ((turret.item.order or "[")..turret.item.name.."]").."["..rank.."].tag",
            place_result = place_name,
            stack_size = turret.item.stack_size or 1,
            hidden_in_factoriopedia = true
        }
        
        local recipe = nil
        --if turret.recipe ~= nil  then
            recipe = {
                type = "recipe",
                name = recipe_name,
                localised_name = localised_name,
                localised_description = localised_desc,
                icon = false,
                icons = new_icon,
                icon_size = 64,
                enabled = false,
                energy = turret.recipe.energy,
                category = turret.recipe.category,
                subgroup = turret.recipe.subgroup,
                hide_from_player_crafting = true,
                hidden_in_factoriopedia = true,
                ingredients =
                {   
                    {type = "item", name = turret.item.name, amount = 1}, -- ✅ Corrected format
                },
                results = {
                    {type = "item", name = turret.item.name, amount = 1}
                }
            }
       -- end

         --- get any custom modifiers
        local max_health_custom_mod = mod
        if get_health_buffs_for_Rank(rank) ~= nil then max_health_custom_mod = 1 + (get_health_buffs_for_Rank(rank) * custom_buff_modifier_percent) end

        local range_custom_mod = mod
        if get_range_buffs_for_Rank(rank) ~= nil then range_custom_mod = 1 + (get_range_buffs_for_Rank(rank) * custom_buff_modifier_percent) end

        local cooldown_custom_mod = mod
        if get_cooldown_buffs_for_Rank(rank) ~= nil then cooldown_custom_mod = 1 + (get_cooldown_buffs_for_Rank(rank) * custom_buff_modifier_percent) end

        local attack_speed_custom_mod = mod
        if get_attack_speed_buffs_For_Rank(rank) ~= nil then attack_speed_custom_mod = 1 + (get_attack_speed_buffs_For_Rank(rank) * custom_buff_modifier_percent) end

        local turret_rotation_custom_mod = mod
        if get_turret_rotation_buffs_For_Rank(rank) ~= nil then turret_rotation_custom_mod = 1 + (get_turret_rotation_buffs_For_Rank(rank) * custom_buff_modifier_percent) end


        


        local entity = table.deepcopy(turret.entity)
        entity.name = entity_name
        entity.max_health = (math.floor((entity.max_health*max_health_custom_mod)/10)*10)
        if entity.rotation_speed ~= nil then entity.rotation_speed = entity.rotation_speed*turret_rotation_custom_mod end
        if entity.preparing_speed ~= nil then entity.preparing_speed = entity.preparing_speed* attack_speed_custom_mod end
        if entity.attacking_speed ~= nil then entity.attacking_speed = entity.attacking_speed * attack_speed_custom_mod end
        if entity.prepare_range ~= nil then entity.prepare_range = entity.prepare_range * range_custom_mod end
        if entity.turret_rotation_speed ~= nil then entity.turret_rotation_speed = entity.turret_rotation_speed * turret_rotation_custom_mod end
        if entity.manual_range_modifier ~= nil then entity.manual_range_modifier = entity.manual_range_modifier*range_custom_mod end
        if entity.turn_after_shooting_cooldown ~= nil then 
            entity.turn_after_shooting_cooldown = (entity.turn_after_shooting_cooldown / cooldown_custom_mod)
            entity.turn_after_shooting_cooldown = math.min(180,math.max(entity.turn_after_shooting_cooldown,10))
        end

        local m_range = nil
        if entity.attack_parameters ~= nil then
            -- Fortheking55 -- 03/30/2025 Changed from entity.attack_parameters.cooldown * (1 - (mod - 1)) 
            if entity.attack_parameters.cooldown ~= nil then entity.attack_parameters.cooldown = (entity.attack_parameters.cooldown / cooldown_custom_mod) end

            --fix for railguns not being useless... just skip their range
            if turret.item.name ~= "railgun-turret" then
                if entity.attack_parameters.range ~= nil then entity.attack_parameters.range = entity.attack_parameters.range * range_custom_mod end                  
            end

            --TODO : Fix this to work for the beam turret
            --for "beam" type projectile laser turrets, make sure the ammo can reach (modular turrets beam turret)
            --make sure the beam can AT LEAST go to the range
            ---if  entity.attack_parameters.ammo_type and entity.attack_parameters.type
            ---    and entity.attack_parameters.type == "projectile" 
            ---    and entity.attack_parameters.ammo_type.category == "laser" and entity.attack_parameters.range and entity.attack_parameters.ammo_type.action
            ---    and  entity.attack_parameters.ammo_type.action.type and entity.attack_parameters.ammo_type.action.type == "line" then
            ---        if entity.attack_parameters.range > entity.attack_parameters.ammo_type.action.range  then
            ---            entity.attack_parameters.ammo_type.action.range = entity.attack_parameters.range
            ---        end
            ---    end

            --if entity.attack_parameters.min_range ~= nil then entity.attack_parameters.min_range = entity.attack_parameters.min_range * (1-(mod-1)) end
			if entity.attack_parameters.ammo_type ~= nil and entity.attack_parameters.ammo_type.action ~= nil then
                if entity.attack_parameters.ammo_type.action.action_delivery ~= nil  and entity.attack_parameters.ammo_type.action.action_delivery.max_length ~= nil then
                    entity.attack_parameters.ammo_type.action.action_delivery.max_length  = entity.attack_parameters.ammo_type.action.action_delivery.max_length  * range_custom_mod
                    m_range = entity.attack_parameters.ammo_type.action.action_delivery.max_length
                    
                    if entity.attack_parameters.ammo_category ~= nil then                       
                        if cannon_ammo_ranges[entity.attack_parameters.ammo_category] == nil then
                            cannon_ammo_ranges[entity.attack_parameters.ammo_category] = m_range
                        elseif cannon_ammo_ranges[entity.attack_parameters.ammo_category]<m_range then
                            cannon_ammo_ranges[entity.attack_parameters.ammo_category] = m_range
                        end
                    elseif entity.attack_parameters.ammo_categories ~= nil then
                        for i=1, #entity.attack_parameters.ammo_categories do
                            local c = entity.attack_parameters.ammo_categories[i]
                            if cannon_ammo_ranges[c] == nil then
                                cannon_ammo_ranges[c] = m_range
                            elseif cannon_ammo_ranges[c]<m_range then
                                cannon_ammo_ranges[c] = m_range
                            end
                        end
                    end
                end
                if entity.attack_parameters.ammo_type.action.action_delivery ~= nil  and entity.attack_parameters.ammo_type.action.action_delivery.max_range ~= nil then
                    entity.attack_parameters.ammo_type.action.action_delivery.max_range  = entity.attack_parameters.ammo_type.action.action_delivery.max_range  * range_custom_mod
                    m_range = entity.attack_parameters.ammo_type.action.action_delivery.max_range
                    if entity.attack_parameters.ammo_category ~= nil then                       
                        if cannon_ammo_ranges[entity.attack_parameters.ammo_category] == nil then
                            cannon_ammo_ranges[entity.attack_parameters.ammo_category] = m_range
                        elseif cannon_ammo_ranges[entity.attack_parameters.ammo_category]<m_range then
                            cannon_ammo_ranges[entity.attack_parameters.ammo_category] = m_range
                        end
                    elseif entity.attack_parameters.ammo_categories ~= nil then
                        for i=1, #entity.attack_parameters.ammo_categories do
                            local c = entity.attack_parameters.ammo_categories[i]
                            if cannon_ammo_ranges[c] == nil then
                                cannon_ammo_ranges[c] = m_range
                            elseif cannon_ammo_ranges[c]<m_range then
                                cannon_ammo_ranges[c] = m_range
                            end
                        end
                    end
                end
            elseif entity.attack_parameters.ammo_category ~= nil and entity.attack_parameters.range ~= nil then
                if cannon_ammo_ranges[entity.attack_parameters.ammo_category] == nil then
                    cannon_ammo_ranges[entity.attack_parameters.ammo_category] = entity.attack_parameters.range
                elseif cannon_ammo_ranges[entity.attack_parameters.ammo_category]<entity.attack_parameters.range then
                    cannon_ammo_ranges[entity.attack_parameters.ammo_category] = entity.attack_parameters.range
                end
            elseif entity.attack_parameters.ammo_categories ~= nil and entity.attack_parameters.range ~= nil then
                for i=1, #entity.attack_parameters.ammo_categories do
                    local c = entity.attack_parameters.ammo_categories[i]
                    if cannon_ammo_ranges[c] == nil then
                        cannon_ammo_ranges[c] = entity.attack_parameters.range
                    elseif cannon_ammo_ranges[c]<entity.attack_parameters.range then
                        cannon_ammo_ranges[c] = entity.attack_parameters.range
                    end
                end
            end
        end
        --artillery turrets hit this
        if entity.gun ~= nil then
            local gun = table.deepcopy(data.raw["gun"][entity.gun])
            if gun then -- added a check to see  if "gun" is not nil
                if gun.attack_parameters ~= nil then
                    local gun_name = "hero-turret-gun-"..rank.."-for-" ..entity.gun
                    if gun.attack_parameters.cooldown ~= nil then gun.attack_parameters.cooldown = (gun.attack_parameters.cooldown / cooldown_custom_mod)  end
                    if gun.attack_parameters.range ~= nil then gun.attack_parameters.range = gun.attack_parameters.range * range_custom_mod end
                    gun.name = gun_name
                    gun.localised_name = localised_name
                    gun.localised_description = localised_desc
                   -- log("NEW_______________________________________")
                   -- log(serpent.block(gun))
                   --  log("FROM______________________________________")
                   --  log(serpent.block(data.raw["gun"][entity.gun]))

---@diagnostic disable-next-line: assign-type-mismatch
                    data:extend({gun})
                    entity.gun = gun_name
                end
            else
                log("Gun was not present in the data.raw for entity"..entity_name)
            end
        end
        entity.localised_name = localised_name
        entity.localised_description = localised_desc
        entity.hidden_in_factoriopedia = true
        
        local left = nil        
        local top = nil

        local box = entity.drawing_box
        if box == nil then box = entity.selection_box end
        if box == nil then box = entity.collision_box end
        if box ~= nil then
             local left_top = {}
             if box[1] ~= nil then left_top =  box[1] else left_top = box["left_top"] end

             left = (math.abs(left_top[1])*32)/2
             top = (math.abs(left_top[2])*32)/2
        end
        
        if is_animated(entity) then
            if is_animated_nesw(entity) then
                local directions = {"north", "north_east","east", "south-east","south","north_west", "south-west","west"}
                for _, dir in ipairs(directions) do
                    if not (entity.graphics_set.base_visualisation.animation[dir] and entity.graphics_set.base_visualisation.animation[dir].layers) then
                        --goto the ::continue:: lable if the direction doesn't exist. Some turrets only contain true cardinal directions
                         goto continue
                    end
                   
                   local badge = get_badge(rank,top,left,1,entity.graphics_set.base_visualisation.animation[dir].layers)

                   table.insert(entity.graphics_set.base_visualisation.animation[dir].layers,badge)
                   ::continue::
                end
            --dirty check for tesla-turret
            elseif entity.fast_replaceable_group == "tesla-turret" then
                for _, v in ipairs(entity.graphics_set.base_visualisation) do  -- Use ipairs because base_visualisation is an indexed table
                    if type(v) == "table" and v.animation then
                        local badge = nil
                        for _, layer in ipairs(v.animation.layers) do 
                            badge = get_badge(rank,top,left,1,layer)
                            break
                        end
                        table.insert(v.animation.layers,badge)

                        ---removed in favor of new calculation 
                        --if _ == 1 then
                        --    table.insert(v.animation.layers,get_badge(rank,top,left,30)) 
                        --elseif _ == 2 then
                        --    table.insert(v.animation.layers,get_badge(rank,top,left,200)) 
                        --elseif _ == 3 then
                        --    table.insert(v.animation.layers,get_badge(rank,top,left,30)) 
                        --end
                    end
                end
            else
             local gs = entity.graphics_set
             local bvs = gs and as_array(gs.base_visualisation)

             if not bvs then
               log("WARNING: Missing base_visualisation in " .. entity.name)
             else
               for i = 1, #bvs do
                 local vis = bvs[i]
                 if not (vis and vis.animation) then
                   log("WARNING: Missing animation in base_visualisation["..i.."] of " .. entity.name)
                 else
                   local layers, replacement = ensure_layers(vis.animation)
                   if replacement then vis.animation = replacement end
                
                   if not layers then
                     log("WARNING: Unhandled animation format in base_visualisation["..i.."] of " .. entity.name)
                   else
                     local badge = get_badge(rank, top, left, 1, layers)
                     table.insert(layers, badge)
                   end
                 end
               end
             end
            end


        --for base aritillery  
        elseif is_base_nesw(entity) then
			local base_picture = entity.base_picture
			for _, direction in pairs({"north", "east", "south", "west"}) do
				local layer = base_picture[direction].layers[1]
				local new_left = left or (layer.size or layer.width)/2
				local new_top = top or (layer.size or layer.height)/2
				local badge = get_badge(rank,new_top,new_left,1)
				badge.repeat_count = (layer.repeat_count or 1) * (layer.frame_count or 1)
				badge.hr_version.repeat_count = badge.repeat_count

				table.insert(base_picture[direction].layers, badge)
			end
        --- Rampant Arsenal Compatability Badge -- WIP  ---
        elseif  false then 
        -- elseif string.find(entity.name,"-rampant-arsenal",1,true) and not string.find(entity.name,"-lite-artillery",1,true)  then

            
            for _, animation in pairs({"folded_animation", "folding_animation", "preparing_animation", "prepared_animation"}) do
                --local layer_one = entity[animation].layers[1]
                --left = layer_one.width/2
                --top = layer_one.height/2 
                ---log("Checking sprite layer ")
                ---log("Filename: " .. (layer_one.filename or "N/A"))
                ---log("Width: " .. (layer_one.width or "N/A") .. ", Height: " .. (layer_one.height or "N/A"))
                ---log("Frame count: " .. (layer_one.frame_count or "N/A"))
                if entity[animation] and entity[animation].layers and entity[animation].layers[1] then
                    local layer_one = entity[animation].layers[1]
                    local badge = get_rampant_badge(rank, top, left, layer_one.frame_count,layer_one.direction_count)
                    table.insert(entity[animation].layers, badge)
                else
                    log("WARNING: Missing animation layer in " .. entity.name .. " for " .. animation)
                end
            end
            
        elseif is_unkown_nesw(entity) and left ~=nil and top ~= nil then
            ---Leaving for historical reason. Can probably be removed
            entity.base_picture = {
                layers = {
                    get_badge(rank,top,left,1)
				}
			}
        else
			local layer_one = entity.base_picture.layers[1]
            if left == nil then left = layer_one.width/2 end
            if top == nil then top = layer_one.height/2 end

			local badge_i = (#entity.base_picture.layers) + 1
			local badge = get_badge(rank,top,left,1)
			--entity.base_picture.layers[badge_i] = get_badge(rank,top,left,entity.base_picture.layers[1].repeat_count or 1)
			entity.base_picture.layers[badge_i] = badge
			badge.repeat_count = (layer_one.repeat_count or 1) * (layer_one.frame_count or 1)
			badge.hr_version.repeat_count = badge.repeat_count
        end

		if entity_name == item.place_result then
			if turret.entity.fast_replaceable_group == nil then
				turret.entity.fast_replaceable_group = turret.entity.name
				entity.fast_replaceable_group = turret.entity.name
				if settings.startup["heroturrets-allow-artillery-turrets"].value == false and turret.entity.type == "artillery-turret" then

				else
					if turret.entity.next_upgrade == nil then turret.entity.next_upgrade = entity_name end
				end
			else
				if settings.startup["heroturrets-allow-artillery-turrets"].value == false and turret.entity.type == "artillery-turret" then
				else
					if turret.entity.next_upgrade == nil then turret.entity.next_upgrade = entity_name end
				end
			end
		else
			turret.entity.next_upgrade = nil
			log("mismatched entity and item place result, no next upgrade: "..entity_name)
		end
        if entity.type == "ammo-turret" then update_ammo_turret_tech(turret.entity, entity_name, rank) end
        if entity.type == "fluid-turret" then update_fluid_turret_tech(turret.entity, entity_name, rank) end

		local to_extend = {recipe,entity}
		if not data.raw[item.type][item.name] then table.insert(to_extend, item) end
        if settings.startup["heroturrets-kill-counter"].value == "Exact" then   
            entity.minable.result = mine_name_with_tags
			table.insert(to_extend, item_with_tags)
        elseif settings.startup["heroturrets-kill-counter"].value == "Disable" then
            entity.minable.result = turret.item.name
        else
            entity.minable.result = mine_name
        end
		data:extend(to_extend)
   end




local local_get_recipe = function(name)
	-- shortcut to recipe named the same, if possible
    local r = data.raw["recipe"][name]
    if r == nil then
        for name,recipe in pairs(data.raw["recipe"]) do	
            if (not recipe.results) and (recipe.results == name) then
				r = recipe
				break
			end
        end

		if not r then
			-- REALLY try to find a recipe
			-- recycling will cause a problem...
			local recipes = recipes_of(name)
			if recipes then r = recipes[1] end
		end
    end
    return r
	end



local initializeLocalBuffTables = function()
    --just sending in a 1 for now to fill the tables
    --main buff
    get_buffs_for_Rank(1)
    get_health_buffs_for_Rank(1)
    get_range_buffs_for_Rank(1)
    get_cooldown_buffs_for_Rank(1)
    get_attack_speed_buffs_For_Rank(1)
    get_turret_rotation_buffs_For_Rank(1)

end

local local_create_turrets = function()  --personal-laser-defense-equipment  "active-defense-equipment"
    local turret_types = {"ammo-turret", "fluid-turret","electric-turret", "artillery-turret"} --"active-defense-equipment"} --, "artillery-wagon"}
    local guns = {}
    for at = 1, #turret_types do local tt = turret_types[at]
        for name, entity in pairs(data.raw[tt]) do	
            local left = nil        
            local top = nil

            local box = entity.drawing_box
            if box == nil then box = entity.selection_box end
            if box == nil then box = entity.collision_box end
            if box ~= nil then          
             local left_top = {}
             if box[1] ~= nil then left_top =  box[1] else left_top = box["left_top"] end

             left = (math.abs(left_top[1])*32)/2
             top = (math.abs(left_top[2])*32)/2
            end
            --[[if entity ~= nil and entity.name ~= nil and entity.type == "active-defense-equipment" and entity.name == "personal-laser-defense-equipment" then
                local recipe = local_get_recipe(entity.name)
                if recipe == nil then log("Missing recipie") end
                local item = local_get_item(entity.name)       
                if item == nil then log("Missing item") end
                if recipe == nil and item ~= nil then recipe = data.raw["recipe"][item.name] end
                if recipe ~= nil and item ~= nil and entity.minable.result ==  item.name then
                    table.insert(guns,
                    {
                        item = item,
                        entity = entity,
                        recipe = recipe,
					})
                end

            else]]
            if entity ~= nil and entity.name ~= nil and entity.type ~= "active-defense-equipment"                   
					and not name_is_excluded(entity.name)
					and entity.subgroup~="enemies"
					and (is_base_nesw(entity) or (entity.base_picture ~= nil and entity.base_picture.layers ~= nil) or (is_unkown_nesw(entity) and left ~=nil and top ~= nil)) -- or (entity.cannon_base_pictures ~= nil and entity.cannon_base_pictures.layers ~= nil and entity.cannon_base_pictures.layers[1].direction_count == 256))
					and entity.max_health ~= nil and entity.max_health > 1 --Fortheking55 -- 03/16/2025 Added check for max_health being nil to support the laser walls mod (and support any others that have nil max health) 
					and entity.minable ~= nil and entity.minable.result ~= nil
				then
                
				local one_mining_result = entity.minable.result
				local recipe = local_get_recipe(entity.name)
				if recipe == nil then
					log("Missing simple recipie for "..entity.name)
					if one_mining_result then
						recipe = local_get_recipe(one_mining_result)
						if recipe == nil then
							log("Missing complex recipie for "..one_mining_result)
						end
					end
				end
				local item = local_get_item(entity.name)
				if item == nil then
					log("Missing simple item")
					if one_mining_result then
						log("\n\tMining result mismatch in "..entity.name.." no item and mining result: "..one_mining_result)
						--item = one_mining_result
					end
				else
					if item.name ~= one_mining_result then
						log("\n\tMining result mismatch in "..entity.name..": item: "..item.name.." minable.result: "..tostring(entity.minable.result))
						--item = one_mining_result
					end
				end
				local bypass = false
                local doNotSkip = true
				if one_mining_result == "obelisk-of-light" then
					item = local_get_item(one_mining_result)
					bypass = true
				end

                --concentrated solar mod skip until fixed
                if one_mining_result == "chcs-solar-laser-tower" then
					item = local_get_item(one_mining_result)
					doNotSkip = false
				end
                --zues wrath turret mod skip until fixed
                if one_mining_result == "zeus-wrath-zeus-turret" then
					item = local_get_item(one_mining_result)
					doNotSkip = false
				end
                
				--if entity.name == "shotgun-ammo-turret-rampant-arsenal" then
				if recipe ~= nil and item ~= nil and (bypass or entity.minable.result ==  item.name) and doNotSkip then
					table.insert(guns,
					{
						item = item,
						entity = entity,
						recipe = recipe,
					})
                else 
                    log(entity.name.." skipped as a HeroTurret ")
				end
            end
        end
    end

    --Modifier buffs -- damage range etc
    local custom_buff_modifier_percent = 1 + (settings.startup["heroturrets-setting-level-buff-modifier"].value/100)
    for k = 1, #guns do local item = guns[k]
        if settings.startup["heroturrets-kill-counter"].value == "Exact" then     
            local_create_turret_with_tags(item)
        end

        local names = local_get_names()

        initializeLocalBuffTables()

        for j = 1, #names do

            local buff = get_buffs_for_Rank(j)
            -- 'custom_buff_modifier_percent' is defined as: 1 + ((user entered value, default 0)/100)
            local damage_multiplier = 1 + buff * custom_buff_modifier_percent
            local_create_turret(item, j, names[j], damage_multiplier,custom_buff_modifier_percent)

        end

    end

    
end




--not used
local local_update_ammo_ranges = function()    

end

if data ~= nil and (data_final_fixes == true or data_updates == true) then
   local_create_turrets()
   local_update_ammo_ranges()
end