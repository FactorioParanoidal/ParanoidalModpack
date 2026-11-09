--- remove-replace-object
-- Usually imported as "rro".
-- Designed to simplify table manipulation, with preventing crashes when applying functions en masse the first priority.
-- @author MeteorSwarm
-- @module lib.remove-replace-object
-- @pragma nostrip



local rro = {}
rro.predicates = require('lib.predicates')
---Checks if two objects are identical. ie returns true if {"space-science-pack",1} and {"space-science-pack",1} are compared from different object references. 
-- Special string "_any" always returns true if compared with anything else.
function rro.deep_equals(table1, table2)
    if table1 == table2 and table1 == "_any" then
        error("Two compare statements should not both contain '_any'.")
    end
    if table1 == table2 or table1 == "_any" or table2 == "_any" then return true end
    
    --If one element is in form of {"_{compare_symbol}",{number}}, this is a comparison operator. They are not looking for equality, they are a comparison.
    --Example: deep_equals({property = "gravity" , min = 1, max = nil},{property = "gravity" , min = {"<=",1}, max = "_any"}) = true
    local flagged
    local other
    -- if type(table1) == "table" and type(table[1]) == "string" and string.find(table1[1], "_") then flagged = table1 other = table2 end
    -- if type(table2) == "table" and type(table[1]) == "string" and string.find(table1[1], "_") then flagged = table2 other = table1 end
    
    -- if flagged then
    --     if type(other) ~= "number" then
    --         goto continue
    --     end
    --     if flagged[1] == "_<" then
    --         return other < flagged[2]
    --     elseif flagged[1] == "_<=" then
    --         return other <= flagged[2]
    --     else
    --         error("flagged variable wrongly set.")
    --     end
    -- end
    -- ::continue::
    if type(table1) == "function" then flagged = table1 other = table2 end
    if type(table2) == "function" then flagged = table2 other = table1 end
    --Passed function should be in form of function(other) -> boolean
    if flagged then
        return flagged(other)
    end

    if type(table1) ~= "table" or type(table2) ~= "table" then return false end

    for key, value in pairs(table1) do
        if not rro.deep_equals(value, table2[key]) then return false end
    end
    for key in pairs(table2) do
        if table1[key] == nil then return false end
    end
    return true
end

---Removes object from list
function rro.remove(list, objectToRemove) 
    if list then
        for i = #list, 1, -1 do -- Iterate backward to avoid index shifting
            if rro.deep_equals(list[i] , objectToRemove) then
                table.remove(list, i)
                break -- Exit the loop once the object is found and removed
            end
        end
    end
end

function rro.replace_no_duplicates(list, objectToRemove, replacementObject)
    rro.replace(list, objectToRemove, replacementObject,true) 
end

---Replaces object in list with another object
function rro.replace(list, objectToRemove, replacementObject,no_duplicates) 
    if replacementObject == nil then
        error("Use rro.remove instead of rro.replace.")
    end
    if list then
        for i = #list, 1, -1 do -- Iterate backward to avoid index shifting
            if rro.deep_equals(list[i] , objectToRemove) then
                if type(replacementObject) == "table" then
                    for j,object in pairs(replacementObject) do
                        if type(replacementObject[j]) == "function" then --If replacementObject entry is a function, replace the function with the function's return value with other_value as input.
                            local other_value = list[i][j]
                            replacementObject[j] = replacementObject[j](other_value)
                        end
                    end
                end
                if replacementObject ~= nil then
                    if type(replacementObject) == "function" then
                        list[i] = replacementObject(table.deepcopy(list[i]))
                    elseif rro.contains(list, replacementObject) and no_duplicates then
                        table.remove(list, i) -- Remove the object if the replacement is already in the list, to avoid duplicates
                    else
                        list[i] = replacementObject -- Replace the object
                    end

                else
                    table.remove(list, i) -- Remove the object if no replacement is provided
                end
                break -- Exit the loop after replacing or removing
            end
        end
    end
end

--- Similar to rro.replace, but acts recursively within subobjects.
function rro.deep_replace(list, objectToRemove, replacementObject,gsub,excluded_fields)
    if gsub == nil then gsub = false end
    if list then
        for i,item in pairs(list) do -- Can also be a dictionary
            if rro.contains(excluded_fields,i) then goto continue end
            if type(item) == "string" and type(objectToRemove) == "string" and gsub then
                item = string.gsub(item,objectToRemove,replacementObject)
            
            elseif rro.deep_equals(list[i] , objectToRemove) then
                if type(replacementObject) == "function" then
                    list[i] = replacementObject(list[i])
                elseif replacementObject ~= nil and not rro.contains(list,replacementObject) then
                    list[i] = replacementObject -- Replace the object
                else
                    list[i] = nil -- Remove the object if no replacement is provided
                end
                --break -- Don't exit the loop after replacing or removing
            elseif type(list[i]) == "table" then
                rro.deep_replace(list[i],objectToRemove, replacementObject, excluded_fields)
            end
            ::continue::
        end
    end


end


function rro.deep_gsub(list, objectToRemove, replacementObject)
    rro.deep_replace(list, objectToRemove, replacementObject,true)

end

---Searches a list for all items where `item[field] == name`, and replaces `name` with `new_name`.
function rro.replace_field(list,field,name,new_name) 
    for i = #list, 1, -1 do -- Iterate backward to avoid index shifting
        if list[i][field] == name then
                list[i][field] = new_name -- Replace the object
                break
        end
    end
end


---Searches a list for all items where `item[field] == name`, and replaces `name` with `new_name`.
function rro.deep_replace_field(list,field,replacementObject) 
    if gsub == nil then gsub = false end
    if list then
        for i,item in pairs(list) do -- Can also be a dictionary
            if i == field then
                if type(replacementObject) == "function" then
                    list[i] = replacementObject(list[i])
                elseif replacementObject ~= nil and not rro.contains(list,replacementObject) then
                    list[i] = replacementObject -- Replace the object
                else
                    list[i] = nil -- Remove the object if no replacement is provided
                end
                --break -- Don't exit the loop after replacing or removing
            elseif type(list[i]) == "table" then
                rro.deep_replace_field(list[i],field, replacementObject)
            end
        end
    end
end


function rro.cut_paste_items(list_from,list_to,objectToMove) 
    if list_from then
        for i = #list_from, 1, -1 do -- Iterate backward to avoid index shifting
            if rro.deep_equals(list_from[i] , objectToMove) then
                table.insert(list_to,list_from[i])
                table.remove(list_from, i) -- Remove the object if no replacement is provided
            end
        end
    end
end

rro.cut_paste = rro.cut_paste_items

---Searches a list for all items where `item.name == name`, and replaces `name` with `new_name`.
function rro.replace_name(list,name,new_name) 
    for i = #list, 1, -1 do -- Iterate backward to avoid index shifting
        if list[i].name == name then
                list[i].name = new_name -- Replace the object
                break
        end
    end
end

---Check if object exists in list.
function rro.contains(list,object) 
    --local contains = false
    if list == nil then return false end
    for _,item in pairs(list) do -- Iterate forward
        if rro.deep_equals(item , object) then
            return true
            
            end
            
    end
    return false
end

--Checks if any objects in one list exist in another list.
function rro.contains_any(list1,list2)
    if not list2 then return false end
    for _,object in pairs(list2) do
        if rro.contains(list1,object) then
            return true
        end
    end
    return false


end

function rro.contains_all(list,object_list)
    for _,object in pairs(object_list) do
        if not rro.contains(list,object) then
            return false
        end
    end
    return true


end


---More powerful version of contains that returns the found object. This functionality is not added to the original contains to avoid unintended consequences.
function rro.find_contains(list,object) 
    --local contains = false
    if list == nil then return false end
    for _,item in pairs(list) do -- Iterate forward
        if rro.deep_equals(item , object) then
            return item
            
            end
            
    end
    return false
end

---Check if string.find(string,list[i]) returns a value for any i in list
function rro.find_many(string,list) 
    --local contains = false
    if list == nil then return false end
    for _,item in pairs(list) do -- Iterate forward
        if string.find(string,item) then
            return true
            
            end
            
    end
    return false
end



---Adds object to list if it doesn't already exist. 
-- @param list table
-- @param objectToAdd object
function rro.soft_insert(list,objectToAdd) 
    if list == nil then list = {} end
    if rro.contains(list,objectToAdd) == false then
        table.insert(list,objectToAdd)
    end

end

---Adds fields of `new` to `old`, replacing overlapping fields.
-- @param old table
-- @param new table
-- @return old table
function rro.merge(old, new)
    old = util.table.deepcopy(old)

    for k, v in pairs(new) do
        if type(v) == "function" then
            old[k] = v(old[k])
        elseif v == "_nil" then
            old[k] = nil
        else
            old[k] = v
        end
    end

    return old
end

-- Drop-in replacement for utils.merge
function rro.util_merge(args)
    return rro.merge(args[1],args[2])
end

function rro.ammend(old, new)
    old = rro.merge(old, new)
end

--- Returns a concatenation of the contents of two tables.
-- @param first table
-- @param second table
function rro.get_concatenation(first,second)
    local first_l = #first
    local second_l = #second
    local out = table.deepcopy(first)
    local out_second = table.deepcopy(second)
    for i=1,second_l do
        out[first_l+i] = out_second[i]
    end
    return out
end

--- Attempts to find an object in a complex object, and returns nil if any level in the search returns nil
-- @param table table
-- @param crawl_list table
function rro.safe_find(table,crawl_list)
    if table == nil then return nil end
    local out = table
    for i,layer in ipairs(crawl_list) do
        out= out[layer]
        if out == nil then return nil end
    end

    return out
end

rro.safe_get = rro.safe_find


--- Copies fields specified in "fields" from "table_from" to "table_to"
-- @param table_to table
-- @param table_from table
-- @param fields table
-- @param deepcopy boolean (Default true)
function rro.copy_fields(table_to,table_from,fields,deepcopy)
    if deepcopy == nil then deepcopy = true end

    for _,field in pairs(fields) do
        if deepcopy then
            table_to[field] = table.deepcopy(table_from[field]) or table_to[field]
        else
            table_to[field] = table_from[field] or table_to[field]
        end
    end


end

function rro.count(table,predicate)
    local i = 0
    for _,entry in pairs(table) do
        if predicate(entry) == true then
            i = i + 1
        end
    end
    return i

end

--Returns keys of table
function rro.keys(table)
    local out = {}
    local n = 0
    for key,value in pairs(table) do
        n=n+1
        out[n] = key
    end

    return out
end

function rro.range(first, last)
    local t = {}
    for i = first, last do
        t[#t + 1] = i
    end
    return t
end


return rro