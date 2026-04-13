local rro = {}

function rro.deep_equals(table1, table2) --Checks if two objects are identical. ie returns true if {"space-science-pack",1} and {"space-science-pack",1} are compared from different object references
    if table1 == table2 then return true end
    if type(table1) ~= "table" or type(table2) ~= "table" then return false end
    for key, value in pairs(table1) do
        if not rro.deep_equals(value, table2[key]) then return false end
    end
    for key in pairs(table2) do
        if table1[key] == nil then return false end
    end
    return true
end

function rro.remove(list, objectToRemove) --Removes object from list
    for i = #list, 1, -1 do -- Iterate backward to avoid index shifting
        if rro.deep_equals(list[i] , objectToRemove) then
            table.remove(list, i)
            break -- Exit the loop once the object is found and removed
        end
    end
end

function rro.replace(list, objectToRemove, replacementObject) --Replaces object in list with another object
    if list then
        for i = #list, 1, -1 do -- Iterate backward to avoid index shifting
            if rro.deep_equals(list[i] , objectToRemove) then
                if replacementObject ~= nil then
                    list[i] = replacementObject -- Replace the object
                else
                    table.remove(list, i) -- Remove the object if no replacement is provided
                end
                break -- Exit the loop after replacing or removing
            end
        end
    end
end

function rro.replace_name(list,name,new_name) 
    for i = #list, 1, -1 do -- Iterate backward to avoid index shifting
        if list[i].name == name then
                list[i].name = new_name -- Replace the object
                break
        end
    end
end

function rro.contains(list,object) --Check if object exists in list.
    --local contains = false
    for _,item in pairs(list) do -- Iterate forward
        if rro.deep_equals(item , object) then
            return true
            
            end
            
    end
    return false
end

function rro.soft_insert(list,objectToAdd) --Adds object to list if it doesn't already exist. 
    if rro.contains(list,objectToAdd) == false then
        table.insert(list,objectToAdd)
    end

end

function rro.merge(old, new)
    old = util.table.deepcopy(old)

    for k, v in pairs(new) do
        if v == "nil" then
            old[k] = nil
        else
            old[k] = v
        end
    end

    return old
end

function rro.ammend(old, new)
    old = rro.merge(old, new)
end






return rro