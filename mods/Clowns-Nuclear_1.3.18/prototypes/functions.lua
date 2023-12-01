local OV = mods["angelsrefining"] and angelsmods.functions.OV or clowns.functions

clowns.functions.replace_ing = function(name,old,new,kind)
  --check if correct, fail otherwise
  local continue = true
  local new_name=""
  local new_amount=0
  if type(new)=="table" then
    new_name = new.name or new[1]
    new_amount = new.amount or new[2]
  elseif type(new)=="string" then
    new_name=new
  end
  if not data.raw.recipe[name] or not (kind == "res" or kind == "ing") or not type(name) == "string" or not type(new_name) == "string" or not type(old) == "string" then
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
      if item.name and item.name == old then
        item.name = new_name
      elseif type(item[1]) == "string" and item[1] == old then
        item[1] = new_name
      end
      if new_amount ~= 0 then
        if item.amount then
          item.amount=new_amount
        elseif item[2] then
          item[2]=new_amount
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

clowns.functions.remove_unlock = function(techname, recipe)
  local tech_top = data.raw.technology[techname].effects
  for i,tech in pairs(tech_top) do
    if tech.recipe == recipe then
      table.remove(tech_top,i)
      break
    end
  end
end

clowns.functions.add_unlock = function(techname, rec)
  local tech_top = data.raw.technology[techname].effects
  local to_add = true
  for i,tech in pairs(tech_top) do
    if tech.recipe == rec then
      to_add=false
      break
    end
  end
  if to_add == true then
    table.insert(tech_top,{type = "unlock-recipe",recipe = rec})
  end
end

clowns.functions.remove_prereq = function(techname,prereq)
  local tech_top = data.raw.technology[techname].prerequisites
  for i, tech in pairs(tech_top) do
    if tech == prereq then
      table.remove(tech_top,i)
      break
    end
  end
end

clowns.functions.add_prereq = function(techname,prereq)
  --sanity check
  local tech_top = data.raw.technology[techname].prerequisites
  local to_add = true
  for i, tech in pairs(tech_top) do
    if tech == prereq then
      to_add=false
      break
    end
  end
  if to_add == true then
    table.insert(tech_top,prereq)
  end
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
  --convert shorthand to long-form
  if kind == "res" then
    kind = "results"
  elseif kind == "ing" then
    kind = "ingredients"
  end
  local temp = data.raw.recipe[name]
  if temp then --terminate if recipe does not exist
    local keys, list = {},{}
    if temp[kind] then
      keys["reg"] = temp[kind]
    end
    if temp.normal and temp.normal[kind] then
      keys["normal"] = temp.normal[kind]
    end
    if temp.expensive and temp.expensive[kind] then
      keys["expensive"] = temp.expensive[kind]
    end
    for q,list in pairs(keys) do
      index=""
      if list then
        for i,ing in pairs(list) do
          if ing.name == to_rem or ing[1] == to_rem then
            --index=i
            if q=="reg" then 
              table.remove(temp[kind],i)
            else
              table.remove(temp[q][kind],i)
            end
          end
        end
      end
    end
  end
end