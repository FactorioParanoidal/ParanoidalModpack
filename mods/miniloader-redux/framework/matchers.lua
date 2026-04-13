--------------------------------------------------------------------------------
-- functions to write / create event matchers
--------------------------------------------------------------------------------
assert(script)

local Is = require('stdlib.utils.is')
local table = require('stdlib.utils.table')

--- A function that matches a given entity. Returns true or false.
---@alias framework.event_matcher.MatcherFunction fun(entity: LuaEntity?, context: any?): boolean

--- A function that extract a given attribute or value from an entity. Returns a value or nil.
---@alias framework.event_matcher.ExtractFunction fun(entity:LuaEntity?, context: any?): any?

--- A function that matches an arbitrary event and returns true or false.
---@alias framework.event_matcher.MatchEventFunction fun(ev: EventData, context: any?): boolean

---@class framework.EventMatchers
---@field NAME_EXTRACTOR framework.event_matcher.ExtractFunction
---@field GHOST_NAME_EXTRACTOR framework.event_matcher.ExtractFunction
---@field CREATION_EVENTS defines.events[]
---@field PRE_DELETION_EVENTS defines.events[]
---@field DELETION_EVENTS defines.events[]
local Matchers = {
    ---@type framework.event_matcher.ExtractFunction
    NAME_EXTRACTOR = function(entity) return entity and entity.name end,
    ---@type framework.event_matcher.ExtractFunction
    GHOST_NAME_EXTRACTOR = function(entity) return entity and entity.type == 'entity-ghost' and entity.ghost_name end,
    ---@type framework.event_matcher.ExtractFunction
    TYPE_EXTRACTOR = function(entity) return entity and entity.type end,

    CREATION_EVENTS = {
        defines.events.on_built_entity,
        defines.events.on_robot_built_entity,
        defines.events.on_space_platform_built_entity,
        defines.events.script_raised_built,
        defines.events.script_raised_revive,
    },
    PRE_DELETION_EVENTS = {
        defines.events.on_pre_player_mined_item,
        defines.events.on_robot_pre_mined,
        defines.events.on_space_platform_pre_mined,
    },
    DELETION_EVENTS = {
        defines.events.on_player_mined_entity,
        defines.events.on_robot_mined_entity,
        defines.events.on_space_platform_mined_entity,
        defines.events.script_raised_destroy,
    },
}

--------------------------------------------------------------------------------
-- entity event matcher management
--------------------------------------------------------------------------------


--- Creates a matcher function.
---
---@param values string|string[] One or more values to match.
---@param extract_function framework.event_matcher.ExtractFunction
---@param invert boolean? - Invert the matching condition. `false` if omitted.
---@return framework.event_matcher.MatcherFunction
function Matchers:createMatcherFunction(values, extract_function, invert)
    assert(values)
    if type(values) ~= 'table' then values = { values } end

    invert = invert or false

    local value_map = table.array_to_dictionary(values, true)

    return function(entity, context)
        if not (entity and entity.valid) then return false end -- invalid is always not a match
        local match = value_map[extract_function(entity, context)] or false

        return (match and not invert) or (not match and invert) -- discrete XOR ...
    end
end

--- Wraps a matcher function to provide an event based matcher that can be used with
--- the event library. This method matches *either* event.entity or event.source / event.destination
---@param matcher_function framework.event_matcher.MatcherFunction
---@return framework.event_matcher.MatchEventFunction
function Matchers:createEventEntityMatcher(matcher_function)
    return function(event, context)
        if not event then return false end
        -- move / clone events

        ---@diagnostic disable undefined-field
        if event.source and event.destination then
            return matcher_function(event.source, context) and matcher_function(event.destination, context)
        else
            return matcher_function(event.entity, context)
        end
        ---@diagnostic enable undefined-field
    end
end

--------------------------------------------------------------------------------
-- common API
--------------------------------------------------------------------------------

--- Returns a matcher for a specific attribute in an Event entity. The entity
--- must be present as `event.entity`.
--- This is the most common matcher function.
---
---@param attribute string The entity attribute name to match.
---@param values string|string[] One or more values to match.
---@param invert boolean? If `true`, invert the match. `false` if absent.
---@return framework.event_matcher.MatchEventFunction
function Matchers:matchEventEntity(attribute, values, invert)
    local matcher_function = self:createMatcherFunction(values, function(entity)
        return entity and entity[attribute]
    end, invert)

    return self:createEventEntityMatcher(matcher_function)
end

--- Returns a matcher for a specific attribute in an Event entity. It also
--- enforces that the entity is a ghost. The entity must be present as `event.entity`.
---
---@param attribute string The entity attribute to match.
---@param values string|string[] One or more values to match.
---@param invert boolean? If true, invert the match.
---@return framework.event_matcher.MatchEventFunction
function Matchers:matchEventEntityAsGhost(attribute, values, invert)
    local matcher_function = self:createMatcherFunction(values, function(entity)
        return entity and entity.type == 'entity-ghost' and entity[attribute]
    end, invert)

    return self:createEventEntityMatcher(matcher_function)
end

--- Returns a matcher for the entity name.
---
---@param values string|string[] One or more values to match.
---@param invert boolean? If `true`, invert the match. `false` if absent.
---@return framework.event_matcher.MatchEventFunction
function Matchers:matchEventEntityName(values, invert)
    local matcher_function = self:createMatcherFunction(values, self.NAME_EXTRACTOR, invert)
    return self:createEventEntityMatcher(matcher_function)
end

--- Returns a matcher for the entity ghost name.
---
---@param values string|string[] One or more values to match.
---@param invert boolean? If `true`, invert the match. `false` if absent.
---@return framework.event_matcher.MatchEventFunction
function Matchers:matchEventEntityGhostName(values, invert)
    local matcher_function = self:createMatcherFunction(values, self.GHOST_NAME_EXTRACTOR, invert)
    return self:createEventEntityMatcher(matcher_function)
end

--- Returns an event entity matching function for an arbitrary attribute extractor.
---
---@param extract_function framework.event_matcher.ExtractFunction Function called for any entity, needs to return a value or nil
---@param values string|string[] One or more values to match by the function return value.
---@param invert boolean? If true, invert the match.
---@return framework.event_matcher.MatchEventFunction
function Matchers:matchEventEntityByAttribute(extract_function, values, invert)
    local matcher_function = self:createMatcherFunction(values, extract_function, invert)
    return self:createEventEntityMatcher(matcher_function)
end

return Matchers
