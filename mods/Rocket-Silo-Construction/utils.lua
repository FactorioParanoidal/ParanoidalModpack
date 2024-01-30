-- funcoes 

function ifthen( cond, val1, val2 )
	if cond then
		return val1
	else
		return val2
	end
end

function Log(what)
game.write_file("mylog.log", serpent.block(what), true)
end

function dLog(what)
log(serpent.block(what))
end

function get_random_pos_near(pos,dist)
return {x=pos.x+math.random(-dist,dist),y=pos.y+math.random(-dist,dist)}
end

--------------------------------------------------------------------------------------
function add_list(list, obj)
	-- to avoid duplicates...
	for i, obj2 in pairs(list) do
		if obj2 == obj then
			return(false)
		end
	end
	table.insert(list,obj)
	return(true)
end

--------------------------------------------------------------------------------------
function del_list(list, obj)
	for i, obj2 in pairs(list) do
		if obj2 == obj then
			table.remove( list, i )
			return(true)
		end
	end
	return(false)
end

--------------------------------------------------------------------------------------
function in_list(list, obj)
	for k, obj2 in pairs(list) do
		if obj2 == obj then
			return(k)
		end
	end
	return(nil)
end


--------------------------------------------------------------------------------------
function concat_lists(list1, list2)
	-- add list2 into list1 , do not avoid duplicates...
	for i, obj in pairs(list2) do
		table.insert(list1,obj)
	end
end




function Sort_a_Table(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end



function is_in_table (tab, val)
    for index, value in pairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function update_science_pack_amount(technology, amount)
  if data.raw.technology[technology] then
	local new ={}	
	for i, ingredient in pairs(data.raw.technology[technology].unit.ingredients) do
		table.insert (new,{ingredient[1], ingredient[2] + amount})
    end
	data.raw.technology[technology].unit.ingredients = new
	end
end


function change_science_pack_amount(technology, pack, amount)
  if data.raw.technology[technology] then
	for i, ingredient in pairs(data.raw.technology[technology].unit.ingredients) do
		if ingredient[1]==pack then ingredient[2]=amount end
		end
	end
end


function add_new_science_pack(technology, pack, amount)
  if data.raw.technology[technology] and data.raw.tool[pack] then
    local addit = true
    for i, ingredient in pairs(data.raw.technology[technology].unit.ingredients) do
      if ingredient[1] == pack or ingredient.name == pack then addit = false end
    end
    if addit then table.insert(data.raw.technology[technology].unit.ingredients,{pack, amount}) end
  else
    if not data.raw.technology[technology] then
      log("Technology " .. technology .. " does not exist.")
    end
    if not data.raw.tool[pack] then
      log("Science pack " .. new .. " does not exist.")
    end
  end
end

function remove_science_pack(technology, pack)
  if data.raw.technology[technology] and data.raw.tool[pack] then
	local ingredients = table.deepcopy(data.raw.technology[technology].unit.ingredients)
    for i=#ingredients,1,-1 do
		local ingredient = ingredients[i]
        if ingredient[1] == pack or ingredient.name == pack then table.remove(data.raw.technology[technology].unit.ingredients,i) end
    end
	end
end

function remove_raw_ingredient(raw, name)
  if raw then
    for i=#raw,1,-1 do 
      if raw[i][1] == name or raw[i].name == name then table.remove(raw,i) end
    end
	end
end

function get_localized_name(name)
local lname = ''
if game.item_prototypes[name]   then lname = game.item_prototypes[name].localised_name
 elseif game.equipment_prototypes[name]    then lname = game.equipment_prototypes[name].localised_name  
 elseif game.entity_prototypes[name] then lname = game.entity_prototypes[name].localised_name end
return  lname 
end