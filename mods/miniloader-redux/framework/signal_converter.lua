--------------------------------------------------------------------------------
-- Signal conversion functions
--------------------------------------------------------------------------------

---@class framework.SignalConverter
local SignalConverter = {
    supports_quality = {
        item = 'item-with-quality',
        entity = 'entity-with-quality',
        recipe = 'recipe-with-quality',
        equipment = 'equipment-with-quality',
    },
    signal_id_type = { -- https://lua-api.factorio.com/latest/concepts/SignalIDType.html
        virtual = 'virtual_signal',
        ['space-location'] = 'space_location',
        ['asteroid-chunk'] = 'asteroid_chunk',
    }
}

---@param signal Signal
---@return string
function SignalConverter:signal_to_sprite_name(signal)
    assert(signal)

    local signal_type = signal.signal.type or 'item'                                 -- see https://lua-api.factorio.com/latest/concepts/SignalID.html
    local sprite_type = signal_type == 'virtual' and 'virtual-signal' or signal_type -- see https://lua-api.factorio.com/latest/concepts/SpritePath.html

    return ('%s/%s'):format(sprite_type, signal.signal.name)
end

---@param signal Signal
---@return LuaPrototypeBase
function SignalConverter:signal_to_prototype(signal)
    assert(signal)

    local signal_type = signal.signal.type or 'item' -- see https://lua-api.factorio.com/latest/concepts/SignalID.html
    local signal_id_type = self.signal_id_type[signal_type] and self.signal_id_type[signal_type]
        or signal_type                               -- see https://lua-api.factorio.com/latest/classes/LuaPrototypes.html

    assert(prototypes[signal_id_type], ('prototype [%s] does not exist'):format(signal_id_type))
    assert(prototypes[signal_id_type][signal.signal.name], ('prototype [%s][%s] does not exist'):format(signal_id_type, signal.signal.name))
    return prototypes[signal_id_type][signal.signal.name]
end

---@param signal Signal
---@return ElemID
function SignalConverter:signal_to_elem_id(signal)
    assert(signal)
    local signal_type = signal.signal.type or 'item' -- see https://lua-api.factorio.com/latest/concepts/SignalID.html

    ---@type ElemID
    local result = {
        type = signal_type,
        name = signal.signal.name,
    }

    if signal_type == 'virtual' then
        result.type = 'signal'
        result.signal_type = signal_type
    elseif signal.signal.quality then
        if self.supports_quality[result.type] then result.type = self.supports_quality[result.type] end
        result.quality = signal.signal.quality
    end

    return result
end

---@param filter LogisticFilter
---@return string
function SignalConverter:logistic_filter_to_sprite_name(filter)
    assert(filter)

    local filter_type = filter.value.type or 'item'                                  -- see https://lua-api.factorio.com/latest/concepts/SignalID.html
    local sprite_type = filter_type == 'virtual' and 'virtual-signal' or filter_type -- see https://lua-api.factorio.com/latest/concepts/SpritePath.html

    return ('%s/%s'):format(sprite_type, filter.value.name)
end

---@param filter LogisticFilter
---@return LuaPrototypeBase
function SignalConverter:logistic_filter_to_prototype(filter)
    assert(filter)

    local filter_type = filter.value.type or 'item' -- see https://lua-api.factorio.com/latest/concepts/SignalID.html
    local type = self.signal_id_type[filter_type] and self.signal_id_type[filter_type]
        or filter_type                              -- see https://lua-api.factorio.com/latest/classes/LuaPrototypes.html

    assert(prototypes[type], ('prototype [%s] does not exist'):format(type))
    assert(prototypes[type][filter.value.name], ('prototype [%s][%s] does not exist'):format(type, filter.value.name))
    return prototypes[type][filter.value.name]
end

---@param filter LogisticFilter
---@return ElemID
function SignalConverter:logistic_filter_to_elem_id(filter)
    assert(filter)

    local filter_type = filter.value.type or 'item' -- see https://lua-api.factorio.com/latest/concepts/SignalID.html

    ---@type ElemID
    local result = {
        type = filter_type,
        name = filter.value.name,
    }

    if filter_type == 'virtual' then
        result.type = 'signal'
        result.signal_type = filter_type ---@diagnostic disable-line: inject-field
    elseif filter.value.quality then
        if self.supports_quality[result.type] then result.type = self.supports_quality[result.type] end
        result.quality = filter.value.quality
    end

    return result
end

---@param signal Signal
---@return LogisticFilter
function SignalConverter:signal_to_logistic_filter(signal)
    local type = signal.signal.type or 'item'
    local quality = signal.signal.quality or 'normal'

    ---@type LogisticFilter
    local filter = {
        value = {
            type = type,
            name = signal.signal.name,
            quality = quality,
        },
        min = signal.count,
    }

    return filter
end

return SignalConverter
