--------------------------------------------------------------------------------
-- Utility functions
--------------------------------------------------------------------------------

local util = require('util')


---@class FrameworkTools
---@field STATUS_TABLE table<defines.entity_status, string>
---@field STATUS_SPRITES table<defines.entity_status, string>
---@field STATUS_NAMES table<defines.entity_status, string>
---@field STATUS_LEDS table<string, string>
local Tools = {
    STATUS_LEDS = {},
    STATUS_TABLE = {},
    STATUS_NAMES = {},
    STATUS_SPRITES = {},

    copy = util.copy -- allow `tools.copy`
}

--------------------------------------------------------------------------------
-- entity_status led and caption
--------------------------------------------------------------------------------

Tools.STATUS_LEDS = {
    RED = 'utility/status_not_working',
    GREEN = 'utility/status_working',
    YELLOW = 'utility/status_yellow',
}

Tools.STATUS_TABLE = {
    [defines.entity_status.working] = 'GREEN',
    [defines.entity_status.normal] = 'GREEN',
    [defines.entity_status.no_power] = 'RED',
    [defines.entity_status.low_power] = 'YELLOW',
    [defines.entity_status.disabled_by_control_behavior] = 'RED',
    [defines.entity_status.disabled_by_script] = 'RED',
    [defines.entity_status.marked_for_deconstruction] = 'RED',
    [defines.entity_status.disabled] = 'RED',
}

for name, idx in pairs(defines.entity_status) do
    Tools.STATUS_NAMES[idx] = 'entity-status.' .. string.gsub(name, '_', '-')
end

for status, led in pairs(Tools.STATUS_TABLE) do
    Tools.STATUS_SPRITES[status] = Tools.STATUS_LEDS[led]
end

--------------------------------------------------------------------------------
-- consistent entity key generation
--------------------------------------------------------------------------------

---@alias framework.tools.EntityKey string

---@param entity LuaEntity?
---@return string?
function Tools:getName(entity)
    if not (entity and entity.valid) then return nil end
    return entity.type == 'entity-ghost' and entity.ghost_name or entity.name
end

---@param position MapPosition
---@param surface_index number?
---@param name string?
---@return framework.tools.EntityKey
function Tools:createEntityKey(position, surface_index, name)
    surface_index = surface_index or 0
    if name then return ('%2.2f:%2.2f:%d:%s'):format(position.x, position.y, surface_index, name) end

    return ('%2.2f:%2.2f:%d'):format(position.x, position.y, surface_index)
end

---@param blueprint_entity BlueprintEntity
---@param surface_index number?
---@return framework.tools.EntityKey
function Tools:createEntityKeyFromBlueprintEntity(blueprint_entity, surface_index)
    return self:createEntityKey(blueprint_entity.position, surface_index or 0, blueprint_entity.name)
end

---@param entity LuaEntity
---@param surface_index number?
---@return framework.tools.EntityKey?
function Tools:createEntityKeyFromEntity(entity, surface_index)
    local name = self:getName(entity)
    if not name then return nil end
    return self:createEntityKey(entity.position, surface_index and surface_index or entity.surface_index, name)
end

return Tools
