local this = {}
local util = scripts.util
local metatables = scripts.metatables

local type, rawget, rawset, pairs, ipairs = type, rawget, rawset, pairs, ipairs


function this.on_scripts_initialized()
    require("scripts.helpers.LuaControl")
    require("scripts.helpers.LuaEntity")
    require("scripts.helpers.LuaItemPrototype")
    require("scripts.helpers.LuaPlayer")
    require("scripts.helpers.LuaRecipe")
    require("scripts.helpers.Position")
    require("scripts.helpers.BoundingBox")
end


metatables.helpers = {
    __index = function(t, k)
        return this[k] or rawget(t, "__on")[k]
    end,
    __newindex = function(t, k, v)
        rawget(t, "__on")[k] = v
    end,
    __len = function(t)
        return #rawget(t, "__on")
    end,
}

function this.on(obj) -- wraps object in table with helper methods
    if type(obj) == "table" and not obj.__self and rawget(obj, "__on") then -- reapply metatable
        return metatables.use(obj, "helpers")
    else                                                         -- new metatable
        return metatables.use({ __on = obj }, "helpers")
    end
end
local _ = this.on

function this:toPlain()
    return rawget(self, "__on")
end

local conditions = {
    ["nil"] = function(obj) return obj == nil end,
    ["any"] = function(obj) return obj ~= nil end,
    ["string"] = function(obj) return type(obj) == "string" end,
    ["number"] = function(obj) return type(obj) == "number" end,
    ["table"] = function(obj) return type(obj) == "table" end,
    ["object"] = function(obj) return type(obj) == "table" and obj.__self end,
    ["empty"] = util.isEmpty,
    ["filled"] = util.isFilled,
    ["valid"] = util.isValid,
    ["valid stack"] = util.isValidStack,
    ["valid player"] = util.isValidPlayer,

    -- Custom type conditions
    ["crafting machine"] = util.isCraftingMachine,
    ["fuel"] = function(obj) return obj.object_name == "LuaItemStack" and obj.prototype.fuel_category ~= nil or obj.fuel_category ~= nil end,
    ["ammo"] = function(obj) return obj.type == "ammo" end,
}

local function applyNot(notModeActive, value)
    if notModeActive then
        return not value
    else
        return value
    end
end

function this:is(...)
    local isargs = {...}
    local obj = rawget(self, "__on")
    local notModeActive = false
    local result = true

    for __,condition in ipairs(isargs) do

        if condition == "not" then
            notModeActive = not notModeActive                -- toggle notModeActive

        else
            if type(condition) == "table" then               -- custom field check
                local value = obj
                for __,key in ipairs(condition) do
                    value = value[key]
                end

                local nestedIs = condition.is or condition.isnot -- nested Is check on custom field
                if condition.is ~= nil then 
                    value = type(nestedIs) == "table" and _(value):is(unpack(nestedIs)) or _(value):is(nestedIs)
                elseif condition.isnot ~= nil then
                    value = type(nestedIs) == "table" and _(value):isnot(unpack(nestedIs)) or _(value):isnot(nestedIs)
                end

                result = result and applyNot(notModeActive, value)

            elseif type(condition) == "function" then -- custom function
                result = result and applyNot(notModeActive, condition(obj))

            elseif conditions[condition] then       -- normal condition check
                result = result and applyNot(notModeActive, conditions[condition](obj))

            else                                    -- direct value check
                result = result and applyNot(notModeActive, obj == condition)
            end
            notModeActive = false

            -- early return if condition unmet
           if not result then return result end
        end
    end

    return result
end

function this:isnot(...)
    local isargs = {...}
    local obj = rawget(self, "__on")
    local notModeActive = false
    local result = true

    for __,condition in ipairs(isargs) do

        if condition == "not" then
            notModeActive = not notModeActive                -- toggle notModeActive

        else
            if type(condition) == "table" then               -- custom field check
                local value = obj
                for __,key in ipairs(condition) do
                    value = value[key]
                end

                local nestedIs = condition.is or condition.isnot -- nested Is check on custom field
                if condition.is ~= nil then 
                    value = type(nestedIs) == "table" and _(value):is(unpack(nestedIs)) or _(value):is(nestedIs)
                elseif condition.isnot ~= nil then
                    value = type(nestedIs) == "table" and _(value):isnot(unpack(nestedIs)) or _(value):isnot(nestedIs)
                end

                result = result and applyNot(notModeActive, value)

            elseif type(condition) == "function" then -- custom function
                result = result and applyNot(notModeActive, condition(obj))

            elseif conditions[condition] then       -- normal condition check
                result = result and applyNot(notModeActive, conditions[condition](obj))

            else                                    -- direct value check
                result = result and applyNot(notModeActive, obj == condition)
            end
            notModeActive = false

            -- early return if condition unmet
           if not result then return not result end
        end
    end

    return not result
end

function this:has(condition, ...)
    return self:is({is=condition, ...})
end

function this:hasnot(condition, ...)
    return self:isnot({is=condition, ...})
end

function this:each(func)
    local obj = rawget(self, "__on")
    local iter = metatables.uses(obj, "entityAsIndex") and util.epairs or pairs

    for k,v in iter(obj) do
        func(k, v)
    end

    return self
end

function this:where(...)
    local args = {...}
    local func = args[#args]
    local obj = rawget(self, "__on")
    local iter = metatables.uses(obj, "entityAsIndex") and util.epairs or pairs

    -- user passed anonymouse iterator function to where() directly (as last argument)
    if #args > 1 and type(func) == "function" then
        args[#args] = nil

        for k,v in iter(obj) do
            if _(v or k):is(unpack(args)) then
                func(k, v)
            end 
        end

        return self

    else  -- or only filter out results and return table
        local result = {}
            
        for k,v in iter(obj) do
            if _(v or k):is(...) then
                result[k] = v
            end
        end

        return _(result)
    end
end

function this:unless(...) -- wherenot
    local args = {...}
    local func = args[#args]
    local obj = rawget(self, "__on")
    local iter = metatables.uses(obj, "entityAsIndex") and util.epairs or pairs

    if #args > 1 and type(func) == "function" then -- if user passed anonymouse function to where() directly (as last argument)
        args[#args] = nil

        for k,v in iter(obj) do
            if _(v or k):isnot(unpack(args)) then
                func(k, v)
            end 
        end

        return self

    else  -- else only filter out results
        local result = {}
            
        for k,v in iter(obj) do
            if _(v or k):isnot(...) then
                result[k] = v
            end
        end

        return _(result)
    end
end

function this:wherekey(...)
    local args = {...}
    local func = args[#args]
    local obj = rawget(self, "__on")
    local iter = metatables.uses(obj, "entityAsIndex") and util.epairs or pairs

    -- user passed anonymouse iterator function to where() directly (as last argument)
    if #args > 1 and type(func) == "function" then
        args[#args] = nil

        for k,v in iter(obj) do
            if _(k):is(unpack(args)) then
                func(k, v)
            end 
        end

        return self

    else  -- or only filter out results and return table
        local result = {}
            
        for k,v in iter(obj) do
            if _(k):is(...) then
                result[k] = v
            end
        end

        return _(result)
    end
end

function this:unlesskey(...) -- wherenot
    local args = {...}
    local func = args[#args]
    local obj = rawget(self, "__on")
    local iter = metatables.uses(obj, "entityAsIndex") and util.epairs or pairs

    if #args > 1 and type(func) == "function" then -- if user passed anonymouse function to where() directly (as last argument)
        args[#args] = nil

        for k,v in iter(obj) do
            if _(k):isnot(unpack(args)) then
                func(k, v)
            end 
        end

        return self

    else  -- else only filter out results
        local result = {}
            
        for k,v in iter(obj) do
            if _(k):isnot(...) then
                result[k] = v
            end
        end

        return _(result)
    end
end



function this:wherehas(condition, ...)
    local args = {...}
    local count = #args
    local func = args[count]
    args.is = condition

    if count > 1 and type(func) == "function" then
        args[count] = nil
        return self:where(args, func) 
    else
        return self:where(args) 
    end
end

function this:unlesshas(condition, ...)
    local args = {...}
    local count = #args
    local func = args[count]
    args.is = condition

    if count > 1 and type(func) == "function" then
        args[count] = nil
        return self:unless(args, func) 
    else
        return self:unless(args) 
    end
end

function this:contains(value) -- table contains value
    local obj = rawget(self, "__on")
    local iter = metatables.uses(obj, "entityAsIndex") and util.epairs or pairs

    for k,v in iter(obj) do
        if v == value then
            return true
        end
    end

    return false
end

function this:set(values)
    local obj = rawget(self, "__on")
    values = rawget(values, "__on") or values

    for k,v in pairs(values) do
        obj[k] = v    
    end

    return self
end

function this:map(func)
    local obj = rawget(self, "__on")
    local iter = metatables.uses(obj, "entityAsIndex") and util.epairs or pairs
    local result = {}

    for k,v in iter(obj) do
        local k2,v2 = func(k,v)
        if k2 == nil then
            result[#result + 1] = v2
        else
            result[k2] = v2
        end
    end

    return _(result)
end

function this:toArray()
    return self:map(function(k,v)
        return nil, v
    end)
end

function this:keys()
    return self:map(function(k)
        return nil, k
    end)
end

function this:sort(...)
    local obj = rawget(self, "__on")

    table.sort(obj, ...)

    return self
end

function this:sum(key)
    local obj = rawget(self, "__on")
    local iter = metatables.uses(obj, "entityAsIndex") and util.epairs or pairs
    local result = 0

    if type(key) == "function" then
        for k,v in iter(obj) do
            result = result + key(k,v)
        end
        
    else
        for k,v in iter(obj) do
            result = result + v[key]
        end
    end

    return result
end

function this:groupBy(key)
    local obj = rawget(self, "__on")
    local iter = metatables.uses(obj, "entityAsIndex") and util.epairs or pairs
    local result = {}

    if type(key) == "function" then
        for k,v in iter(obj) do
            local value = key(k,v)
            if value ~= nil then
                result[value] = result[value] or {}
                if type(k) == "number" then
                    result[value][#result[value] + 1] = v
                else
                    result[value][k] = v
                end
            end
        end
        
    else
        for k,v in iter(obj) do
            local value = v[key]
            if value ~= nil then
                result[value] = result[value] or {}
                if type(k) == "number" then
                    result[value][#result[value] + 1] = v
                else
                    result[value][k] = v
                end
            end
        end
    end
    
    return _(result)
end

return this