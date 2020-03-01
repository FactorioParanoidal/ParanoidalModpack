local this = {}
local util = scripts.util
local metatables = scripts.metatables

local type, rawget, rawset, pairs, ipairs = type, rawget, rawset, pairs, ipairs


function this.on_scripts_initialized()
    require("scripts.helpers.LuaControl")
    require("scripts.helpers.LuaEntity")
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
    local checkMode = "condition"
    local result = true

    for __,condition in ipairs(isargs) do

        if condition == "not" then
            notModeActive = not notModeActive                -- toggle notModeActive

        elseif type(condition) == "table" then               -- custom field check
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

        elseif conditions[condition] then       -- normal condition check
            result = result and applyNot(notModeActive, conditions[condition](obj)) 

        else                                    -- direct value check
            result = result and applyNot(notModeActive, obj == condition) 
        end

         -- early return if condition not met
        if not result then return result end
    end

    return result
end

function this:isnot(...)
    return self:is("not", ...)
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

    if #args > 1 and type(func) == "function" then -- if user passed anonymouse function to where() directly (as last argument)
        args[#args] = nil

        for k,v in iter(obj) do
            if _(v or k):is(unpack(args)) then
                func(k, v)
            end 
        end

        return self

    else  -- else only filter out results
        local result = {}
            
        for k,v in iter(obj) do
            if _(v or k):is(...) then
                result[k] = v
            end
        end

        return _(result)
    end
end

function this:unless(...)
    return self:where("not", ...) 
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

function this:set(values)
    local obj = rawget(self, "__on")

    for k,v in pairs(values) do
        obj[k] = v    
    end

    return self
end

return this