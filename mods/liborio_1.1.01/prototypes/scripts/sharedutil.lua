log("LIBORIO SHAREDUTIL")
require("prototypes.scripts.defines")

if not liborio.log_enable then liborio.log_enable = true end

local biome_types = {
    {name = "basic", factor = 1},
    {name = "water", factor = 1.5},
    {name = "desert", factor = 0.5},
    {name = "sand", factor = 0.5},
    {name = "snow", factor = 0.75},
    {name = "ice", factor = 0.75},
    {name = "volcanic", factor = 0.25}} 

local non_pollutant = {
    { name= "water", polutant = true},
    { name= "fish-oil", polutant = true},
    { name= "steam", polutant = true}} 


local local_get_biomes = function() return biome_types end
local local_is_pollutant = function(surface)
	for _, v in ipairs(non_pollutant) do  
		if v.name == surface then return not v.polutant end
	end
	return true 
	end 

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
	return ToString(arg, "  ") 
	end

local local_log = function(arg) if liborio.log_enable == true then log(local_convert_to_string(arg)) end end
local local_log_disable = function() liborio.log_enable = false end
local local_log_enable = function() liborio.log_enable = true end
local local_is_logging = function() return liborio.log_enable end

local local_is_int = function(n) return (type(n) == "number") and(math.floor(n) == n) end

local local_starts_with = function(str, start) return str ~=nil and start ~=nil and str:sub(1, #start) == start end
local local_ends_with = function(str, ending) return str ~=nil and ending ~=nil and (ending == "" or str:sub(-#ending) == ending) end
local local_index_of = function(str, f_str) return string.find(str, f_str, 1, true) end

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

local local_is_dictionary = function(d)
	for k, v in pairs(d) do 
		return type(k) == "string" and type(v)=="number"
	end
	return false
	end
local local_to_dictionary = function(tble,get_name,get_count)
    local cret = { }
    for _, x in pairs(tble) do cret[get_name(x)]= get_count(x) end
    return cret
	end
local local_aggrigate_content_with_name_count = function(cx1, cx2)
    local function add_from(tble, name)
        local cnt = 0
	    if tble == nil then return 0 end
	    if name == nil then return 0 end
	    for x= 1, #tble do local y = tble[x]
		    if y.name == name then cnt = cnt + y.count end
        end
	    return cnt
    end
    if cx1 == nil then return cx2 end
	if cx2 == nil then return cx1 end
    local c1 = cx1
    local c2 = cx2
    if #c1<#c2 then
	    c1 = cx2
        c2 = cx1
    end
    local ret = { }
    for k=1, #c1 do local v = c1[k]		
	    local found = false
	    for j=1, #ret do local z = ret[j]
		    if z.name == v.name then
                found = true
			    break
		    end
        end
	    if found == false then
            local c = v.count + add_from(c2, v.name)
            table.insert(ret,{name =v.name,count=c})
	    end
    end
	return ret
    end
local local_aggrigate_content_as_table = function(cx1, cx2)
	local to_table = function(z)
		local tbl = {}
		for k, v in pairs(z) do 
			table.insert(tbl,{name=k,count=v})
		end
    return tbl
		end
	if local_is_dictionary(cx1) then cx1 = to_table(cx1) end
	if local_is_dictionary(cx2) then cx2 = to_table(cx2) end
	return local_aggrigate_content_with_name_count(cx1,cx2)
	end
local local_aggrigate_content_as_dictionary = function(cx1, cx2)
	if local_is_dictionary(cx1) and local_is_dictionary(cx2) then 
		local dic = {}
		for k, v in pairs(cx1) do 
			dic[k]=v
		end
		for k, v in pairs(cx2) do 
			if dic[k] ~= nil then
				dic[k] = dic[k] + v
			else
				dic[k]=v
			end
		end
		return dic
	end
	local tbl = local_aggrigate_content_as_table(cx1,cx2)
	return local_to_dictionary(tbl,
		function(i) return i.name end,
		function(j) return j.count end)
	end
  
local local_distance_squared = function(x1, y1, x2, y2)
  local x, y = x1-x2, y1-y2
  return (x*x+y*y)
end

local local_distance = function(x1, y1, x2, y2) 
  local x, y = x1-x2, y1-y2
  return math.sqrt(x*x+y*y)
  end

local local_table_length = function(table)
    local count = 0
	for k, v in next, table do count = count + 1 end
	return count
	end
local local_table_index_of = function(table, value)
	for k, v in pairs(table) do 
		if v == value then
			return k
        end
    end return nil
	end
local local_table_contains = function(table, value) return local_table_index_of(table, value) ~= nil end
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
local local_table_remove_all = function(tbl, remove)
	for i,j in pairs(remove) do
		tbl = local_table_remove(tbl, j)
    end
	return tbl
    end
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

local local_opposite_direction = function(direction)
	if direction == defines.direction.north then return defines.direction.south end
	if direction == defines.direction.northeast then return defines.direction.southwest end
	if direction == defines.direction.east then return defines.direction.west end
	if direction == defines.direction.southeast then return defines.direction.northwest end
	if direction == defines.direction.south then return defines.direction.north end
	if direction == defines.direction.southwest then return defines.direction.northeast end
	if direction == defines.direction.west then return defines.direction.east end
	if direction == defines.direction.northwest then return defines.direction.southeast end
	return direction
    end

liborio.convert_to_string = local_convert_to_string
liborio.log = local_log
liborio.log_disable = local_log_disable
liborio.log_enable = local_log_enable
liborio.is_logging = local_is_logging
liborio.is_int = local_is_int
liborio.starts_with = local_starts_with
liborio.ends_with = local_ends_with
liborio.get_name_for = local_get_name_for
liborio.table = {
	index_of = local_index_of,
	is_dictionary = local_is_dictionary,
	to_dictionary = local_to_dictionary,	
	length = local_table_length,
	index_of = local_table_index_of,
	remove = local_table_remove,
	contains = local_table_contains,
	table_clone = local_table_clone,
	aggrigate_content_with_name_count = local_aggrigate_content_with_name_count,
	aggrigate_content_as_table = local_aggrigate_content_as_table,
	aggrigate_content_as_dictionary = local_aggrigate_content_as_dictionary
}
liborio.opposite_direction = local_opposite_direction
liborio.tech = {}
liborio.entity = {}
liborio.recipe = {}
liborio.fluid = {}
liborio.signal = {}

liborio.distance = local_distance
liborio.distance_squared = local_distance_squared
liborio.is_pollutant = local_is_pollutant
liborio.get_biomes = local_get_biomes

if remote ~= nil then
	require("utilcontrol")
else 
	require("utildata")
end