--- PlanetsLib.objects
-- Aliases: PlanetsLib.rro
-- Designed to simplify table manipulation, with preventing crashes when applying functions en masse the first priority.
-- This library abstracts away object references, asserting that two tables with identical contents are equal to each other.
-- This library has been bundled with PlanetsLib to make it easier to port features from MeteorSwarm's mods to PlanetsLib.
-- @author MeteorSwarm
-- @module PlanetsLib.objects
-- @pragma nostrip


local Public = {}
---Checks if two objects are identical. ie returns true if {"space-science-pack",1} and {"space-science-pack",1} are compared from different object references. 
-- Special string "_any" always returns true if compared with anything else.
function Public.deep_equals(table1, table2)
    if table1 == table2 and table1 == "_any" then
        error("Two compared objects should not both contain '_any'.")
    end
    if table1 == table2 or table1 == "_any" or table2 == "_any" then return true end
    if type(table1) ~= "table" or type(table2) ~= "table" then return false end
    for key, value in pairs(table1) do
        if not Public.deep_equals(value, table2[key]) then return false end
    end
    for key in pairs(table2) do
        if table1[key] == nil then return false end
    end
    return true
end

---Removes object from list.
-- Special string "_any" always returns true if compared with anything else.
function Public.remove(list, objectToRemove) 
    if list then
        for i = #list, 1, -1 do -- Iterate backward to avoid index shifting
            if Public.deep_equals(list[i] , objectToRemove) then
                table.remove(list, i)
                break -- Exit the loop once the object is found and removed
            end
        end
    end
end

---Replaces object in list with another object
function Public.replace(list, objectToRemove, replacementObject) 
    if list then
        for i = #list, 1, -1 do -- Iterate backward to avoid index shifting
            if Public.deep_equals(list[i] , objectToRemove) then
                if replacementObject ~= nil and not Public.contains(list,replacementObject) then
                    list[i] = replacementObject -- Replace the object
                else
                    table.remove(list, i) -- Remove the object if no replacement is provided
                end
                break -- Exit the loop after replacing or removing
            end
        end
    end
end

---Searches a list for all items where `item[field] == name`, and replaces `name` with `new_name`.
function Public.replace_field(list,field,name,new_name) 
    for i = #list, 1, -1 do -- Iterate backward to avoid index shifting
        if Public.deep_equals(list[i][field], name) then
                list[i][field] = new_name -- Replace the object
                break
        end
    end
end

---Searches a list for all items where `item.name == name`, and replaces `name` with `new_name`.
function Public.replace_name(list,name,new_name) 
    for i = #list, 1, -1 do -- Iterate backward to avoid index shifting
        if Public.deep_equals(list[i].name, name) then
                list[i].name = new_name -- Replace the object
                break
        end
    end
end

---Check if object exists in list.
function Public.contains(list,object) 
    --local contains = false
    if list == nil then return false end
    for _,item in pairs(list) do -- Iterate forward
        if Public.deep_equals(item , object) then
            return true
            
            end
            
    end
    return false
end

---Adds object to list if it doesn't already exist. 
-- @param list table
-- @param objectToAdd object
function Public.soft_insert(list,objectToAdd) 
    if list == nil then list = {} end
    if Public.contains(list,objectToAdd) == false then
        table.insert(list,objectToAdd)
    end

end

---Adds fields of `new` to `old`, replacing overlapping fields.
-- Special argument "_nil"(or "nil"), when added to "new", deletes the equivalent field in "old" without replacing it with anything.
-- @param old table
-- @param new table
-- @return old table
function Public.merge(old, new)
    old = util.table.deepcopy(old)

    for k, v in pairs(new) do
        if v == "nil" or v == "_nil" then
            old[k] = nil
        else
            old[k] = v
        end
    end

    return old
end

--- Returns a concatenation of the contents of two tables.
-- @param first table
-- @param second table
function Public.get_concatenation(first,second)
    local first_l = #first
    local second_l = #second
    local out = table.deepcopy(first)
    local out_second = table.deepcopy(second)
    for i=1,second_l do
        out[first_l+i] = out_second[i]
    end
    return out
end



return Public