local OV = angelsmods.functions.OV

clowns.functions.replace_ing = function(name,old,new,kind)
  --check if correct, fail otherwise
  local continue = true
  if not data.raw.recipe[name] or not (kind == "res" or kind == "ing") or not type(name) == "string" or not type(new) == "string" or not type(old) == "string" then
    continue = false
    return
  end
  if data.raw.recipe[name] then
    if kind == "res" then
      list = data.raw.recipe[name].results
      if not list then
        list = data.raw.recipe[name].normal.results
      end
    elseif kind == "ing" then
      list = data.raw.recipe[name].ingredients
      if not list then
        list = data.raw.recipe[name].normal.ingredients
      end
    end
  end
  if continue == true  and list then
    for i, item in pairs(list) do
      if item.name then
        if item.name == old then
          item.name = new
        elseif type(item[1]) == "string" and item[1] == old then
          item[1] = new
        end
      end
    end
  end
  return list
end

clowns.functions.add_to_table = function(name,new,kind)
  --check if correct, fail otherwise
  local continue = true
  if not data.raw.recipe[name] or not (kind == "res" or kind == "ing") or not type(name) == "string" or not type(new) == "table" then
    continue = false
    return
  end
  if data.raw.recipe[name] then
    if kind == "res" then
      list = data.raw.recipe[name].results
      if not list then
        list = data.raw.recipe[name].normal.results
        if data.raw.recipe[name].expensive.results then
          expensive=data.raw.recipe[name].expensive.results
        end
      end
    elseif kind == "ing" then
      list = data.raw.recipe[name].ingredients
      if not list then
        list = data.raw.recipe[name].normal.ingredients
        if data.raw.recipe[name].expensive.ingredients then
          expensive=data.raw.recipe[name].expensive.ingredients
        end
      end
    end
  end
  if continue == true  and list then
    list = table.insert(list,new)
  end
  if continue == true and expensive then
    expensive = table.insert(expensive,new)
  end
  return
end



--lifted from industries...
clowns.functions.pre_req_repl = function(techname, old_tech, new_tech1, new_tech2) -- tech prerequisite replacements
  OV.remove_prereq(techname, old_tech)
  OV.add_prereq(techname, new_tech1)
  if new_tech2 then
    OV.add_prereq(techname, new_tech2)
  end
end

clowns.functions.remove_res = function(name, to_rem, kind)
  local temp = data.raw.recipe[name]
  if temp then --terminate if recipe does not exist
    local keys, list = {},{}
    if temp.kind then
      keys[#keys+1] = temp.kind
    end
    if temp.normal and temp.normal.kind then
      keys[#keys+1] = temp.normal.kind
    end
    if temp.expensive and temp.expensive.kind then
      keys[#keys+1] = temp.expensive.kind
    end
    --local list=data.raw.recipe[name].kind or data.raw.recipe[name].normal.kind
    for i,list in pairs(keys) do
      index=""
      if list then
        for i,ing in pairs(list) do
          if ing.name == to_rem or (ing.name and ing[1] == to_rem) then
            index=i
          end
        end
        
      end
    end
    table.remove(list,index) -- remove after loop, not while in it.
  end
end