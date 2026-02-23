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
    
local local_inner_table_clone = function(t,c,e,a)  
    local meta = getmetatable(t)
      local tbl = { }
      for k, v in pairs(t) do
          if type(v) == "table" then
        local i = local_table_index_of(e,v)
        if i ~= nil then
          tbl[k] = a[i]
        else
          table.insert(e,v)
          local nt = c(v,c,e,a)
          table.insert(a,nt)
          tbl[k] = nt
        end
          else
              tbl[k] = v
          end
      end
    setmetatable(tbl, meta)
      return tbl
end
local local_table_clone = function (t)
    if type(t) ~= "table" then return t end	
    return local_inner_table_clone(t,local_inner_table_clone,{},{})	
end

local local_create_icon = function(base_icons, new_icons, options)
    if type(base_icons) ~= "table" then return base_icons end
    if type(options) ~= "table" then options = { } end
    local icon = nil
    if not options.rescale then options.rescale = 1 end
    if not options.origin then options.origin = {0,0} end
    if not new_icons then
        if options.from ~= nil and type(options.from) == "table" then
            if options.from.icons then new_icons = options.from.icons
            elseif options.from.icon then new_icons = {{icon = options.from.icon}}
            else error("Table given had no icons.") end
            for _, icon in pairs(new_icons) do
                if not icon.icon_size then
                    if options.from.icon_size then
                        icon.icon_size = options.from.icon_size
                    else
                        icon.icon_size = 64 -- Default to 64 (Factorio standard size)
                        log("Warning: Missing icon_size for " .. tostring(icon.icon) .. ". Defaulting to 64.")
                    end
                end
            end
        else
            error("Couldn't build icons: no icons and no table to build from.")
        end
    end
    local icons = local_table_clone(new_icons)
    for _, icon in pairs(base_icons) do
        if not icon.scale then icon.scale = 1 end
        if icon.shift ~= nil and type(icon.shift) ~= "table" then
            icon.shift = {0,0}
        end
        if not icon.shift then icon.shift = {0,0} end
    end
    if options.type == nil or options.type == "recipe" then
        for _, icon in pairs(icons) do
            if not icon.icon_size then icon.icon_size = 32 end
        end
    end
    local extra_scale
    for _, icon in pairs(icons) do
        if not icon.scale then icon.scale = 1 end
        if icon.shift ~= nil and type(icon.shift) ~= "table" then
            icon.shift = {0,0} 
        end
        if (not icon.shift) or (not icon.shift[1]) then icon.shift = {0,0} end
        extra_scale = 1
        if base_icons[1] then
            if (base_icons[1].icon_size* base_icons[1].scale) ~= (icon.icon_size* icon.scale) then
              extra_scale = (base_icons[1].icon_size * base_icons[1].scale) / (icon.icon_size)
            end
        else
            if (icons[1].icon_size* icons[1].scale) ~= (icon.icon_size* icon.scale) then
                extra_scale = (icons[1].icon_size * icons[1].scale) / (icon.icon_size)
            end
        end

        icon.shift[1] = icon.shift[1] / icon.scale
        icon.shift[2] = icon.shift[2] / icon.scale
        icon.scale = icon.scale * options.rescale * extra_scale
        icon.shift[1] = icon.shift[1] * icon.scale + options.origin[1] * icon.scale * icon.icon_size
        icon.shift[2] = icon.shift[2] * icon.scale + options.origin[2] * icon.scale * icon.icon_size
    end
    for _, icon in pairs(icons) do
        table.insert(base_icons, icon)
    end
    for i=1, #base_icons do 
        if type(base_icons[i].shift) ~= table then base_icons[i].shift = {0,0} end
    end
    return base_icons
end

local local_is_int = function(n) return (type(n) == "number") and(math.floor(n) == n) end


local local_table_remove = function(tble, value)
    local new_table = { }
    if tble ~= nil then
        if local_is_int(value) == true then
            table.remove(tble, value)
        else
            for k, v in next, table do 
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
        create_icon = local_create_icon,
        recipe = {
            find_recipes_for = local_find_recipes_for
        },
        parseCustomRankTable =local_parseCustomRankTable,
        local_split = local_split,
        local_trim = local_trim
    }
end