log("Hero Turrets Util (Whipped up from Liborio utils)")

local local_starts_with = function(str, start) return str ~=nil and start ~=nil and str:sub(1, #start) == start end
local local_ends_with = function(str, ending) return str ~=nil and ending ~=nil and (ending == "" or str:sub(-#ending) == ending) end
local local_index_of = function(str, f_str) return string.find(str, f_str, 1, true) end
local local_distance = function(x1, y1, x2, y2) 
    local x, y = x1-x2, y1-y2
    return math.sqrt(x*x+y*y)
    end
local local_is_valid = function(entity) return type(entity)=="table" or type(entity) == "userdata" end


local local_convert_to_string = function (arg)
	ToString = function(arg)
		local res=""
		if type(arg)=="table" then
			res="{"
			for k,v in pairs(arg) do
				res=res.. tostring(k).." = ".. ToString(v) ..","
			end
			res=res.."}"
		else
			res=tostring(arg)
		end
		return res
	end
	return ToString(arg) 
end

local local_get_name_for = function(item, prefix, suffix)
        local result
        if prefix == nil and suffix == nil then suffix = "" end
        if type(item) == "string" then item = { localised_name = item } end
        if item.localised_name then
            if type(item.localised_name) == "table" then
                result = item.localised_name[1]
            else
                result = item.localised_name
                if prefix ~= nil then
                    if suffix ~= nil then
                        return {"recipe-name.concatenationstrings",prefix,result,suffix} 	
                    else
                        return {"recipe-name.concatenationstring",prefix,result} 
                    end
                elseif suffix ~= nil then
                    return {"recipe-name.concatenationstring",result,suffix} 				
                else
                    return {"recipe-name.defaultstring",result} 
                end
            end
    
        elseif item.place_result then
            result = 'entity-name.'..item.place_result
        elseif item.placed_as_equipment_result then
            result = 'equipment-name.'..item.placed_as_equipment_result
        else
            result = 'item-name.'..item.name
        end
        if prefix ~= nil then
            if suffix ~= nil then
                return { "recipe-name.concatenationstrings",prefix,{ result},suffix} 	
            else
                return {"recipe-name.concatenationstring",prefix,{result}} 
            end
        elseif suffix ~= nil then
            return {"recipe-name.concatenationstring",{result},suffix} 				
        else
            return {"recipe-name.defaultstring",{result}} 
        end
end

local local_table_index_of = function(table, value)
        for k, v in pairs(table) do 
            if v == value then
                return k
            end
        end return nil
end
    
    --Table local funcs
local local_table_contains = function(table, value) return local_table_index_of(table, value) ~= nil end
    
local local_is_int = function(n) return (type(n) == "number") and(math.floor(n) == n) end


local local_table_remove = function(tble, value)
    local new_table = { }
    if tble ~= nil then
        if local_is_int(value) == true then
            table.remove(tble, value)
        else
            for k, v in next, tble do 
                if v ~= value then
                    table.insert(new_table, v)
                end

            end
        end
    end
    tble = new_table
    return tble
end
-- Entity

local local_get_entity_size = function(entity)
	if entity == nil then return {1,1} end	
	if entity.prototype.selection_box ~= nil then
        local size = {
                entity.prototype.selection_box["right_bottom"]["x"] - entity.prototype.selection_box["left_top"]["x"],
                entity.prototype.selection_box["right_bottom"]["y"] - entity.prototype.selection_box["left_top"]["y"]}
		if entity.direction == 0 or entity.direction == 4 then return size end
		return { size[2],size[1]}
	end
	return {1,1} 
end

local local_get_entities_around = function(entity, tiles_away, findtype, name)
    local wh = local_get_entity_size(entity)
    local w,h = 0.5 * wh[1], 0.5 * wh[2]
	local entities = nil
	if type(tiles_away) == "number" then w = w + tiles_away h = h + tiles_away
    elseif type(tiles_away) == "string" then w = w + tonumber(tiles_away) h = h + tonumber(tiles_away) end
    entities = entity.surface.find_entities_filtered{area = {{entity.position.x-w, entity.position.y-h}, {entity.position.x+w, entity.position.y+h}}, type = findtype, name = name}
	for i, ent in pairs(entities) do	
		if ent == entity then
            table.remove(entities, i)
			break
		end
    end
	return entities
end

local local_is_valid_and_persistant = function(entity)
    if not (entity and entity.valid) then return false end
    if not local_is_valid(entity) then return false end
    if not entity.to_be_deconstructed then return false end
    return not entity.to_be_deconstructed(entity.force)
  end

-- previously was "local_find_recipes_for"... but it was overwritten by one below. Not sure what it is used for
local local_find_recipes_for_force = function(name, force)
    if force == nil then force = game.players[1].force end
    local recipes = { }
        for _,r in pairs(force.recipes) do
        if r.name == name then 
            table.insert(recipes,r)
        end
    end
    return recipes
end

local local_find_recipes_for = function(name, force)
---@diagnostic disable-next-line: assign-type-mismatch
    local p = data.raw[name]
    local ret = {}
    if p~=nil then 
    table.insert(ret,p)
    end
    return ret
end

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
        if #n_str > 0 and #n_str < 26 and local_table_contains(t,n_str) == false then
            table.insert(t, n_str)
        end
    end
    return t
end

---Parses out the custom csv table. If it returns nil, then use the default damage table 
local local_parseCustomRankTable = function(csvString)
	local custom = local_split(csvString,",")
	local rankTable = {}


	local success = true
	for _,v in pairs(custom) do
		local num = tonumber(v)
		if num ~= nil then 
			table.insert(rankTable,math.abs(num))
		else
			success = false 
		end	
	end

	if not success then return nil end

	return rankTable
end


-- Rank names: one definition for the data stage (prototypes) and the runtime (kill tables).
-- Names of 26+ bytes are dropped by local_split, as in heroturrets 9.1.11 (Beta 8).
local local_get_rank_names = function()
    local names = {"Private 1st Class","Corporal","Sergeant","General","Field Marshal","Supreme Commander"}
    if settings.startup["heroturrets-use-csv"].value ~= true then return names end
    local custom_string = local_trim(settings.startup["heroturrets-csv-names"].value or "")
    if #custom_string == 0 then return names end
    local custom = local_split(custom_string, ",")
    if #custom == 0 then return names end
    for i = #custom, 13, -1 do table.remove(custom, i) end
    return custom
end

function get_utils()
    return {
        starts_with = local_starts_with,
        ends_with = local_ends_with,
        distance = local_distance,
        convert_to_string = local_convert_to_string,
        is_valid = local_is_valid,
        entity = {
            is_valid_and_persistant = local_is_valid_and_persistant,
            get_entities_around = local_get_entities_around
        },
        table = {
            index_of = local_index_of,
            contains = local_table_contains,
            remove = local_table_remove
        },
        get_name_for = local_get_name_for,
        recipe = {
            find_recipes_for = local_find_recipes_for
        },
        parseCustomRankTable =local_parseCustomRankTable,
        local_split = local_split,
        local_trim = local_trim,
        get_rank_names = local_get_rank_names
    }
end