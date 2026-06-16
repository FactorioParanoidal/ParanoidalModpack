require('__kry_stdlib__/stdlib/core') -- Calling core up here to setup any required global stuffs

if _G.remote and _G.script then
    error('Settings Module can only be required outside of the control stage', 2)
end

local Table = require('__kry_stdlib__/stdlib/utils/table') --[[@as StdLib.Utils.Table]]

local Setting = {
    __class = "Setting"
}
setmetatable(Setting, Setting)

local setting_types = {
    "bool-setting",
    "int-setting",
    "double-setting",
    "string-setting",
    "color-setting",
}

local function find_setting_prototype(name)
    if not data or not data.raw then return nil, nil end

    for _, setting_type in pairs(setting_types) do
        local raw_type = data.raw[setting_type]
        if raw_type and raw_type[name] then
            return raw_type[name], setting_type
        end
    end

    return nil, nil
end

--- Is this a valid setting object?
--- @param type string? [opt] if present, is the setting this type?
--- @return boolean
function Setting:is_valid(type)
    if type then
        return rawget(self, "valid") == type or false
    else
        return rawget(self, "valid") and true or false
    end
end

--- Force a setting value and hide it from the settings UI.
--- Only works during settings phase, when _raw is a setting prototype.
--- @param value boolean|number|string|table
--- @return self
function Setting:force_hidden(value)
    if self:is_valid() and self._raw then
        self._raw.forced_value = value
        self._raw.hidden = true
    end

    return self
end

--- Returns a startup setting object.
--- @param name string
--- @return table
function Setting:get(name)
    local raw
    local valid

    -- data phase: resolved startup setting value
    if settings and settings.startup and settings.startup[name] then
        raw = settings.startup[name]
        valid = "startup"

    -- settings phase: setting prototype definition
    else
        raw, valid = find_setting_prototype(name)
    end

    local new = {
        name = name,
        _raw = raw,
        valid = raw and valid or false
    }

    setmetatable(new, self._object_mt)
    return new
end

Setting.__call = Setting.get

Setting._object_mt = {
    __index = function(t, k)
        local raw = rawget(t, "_raw")

        if k == "value" then
            if not raw then return nil end

            -- data phase
            if raw.value ~= nil then
                return raw.value
            end

            -- settings phase
            if raw.forced_value ~= nil then
                return raw.forced_value
            end

            return raw.default_value
        end

        if raw and raw[k] ~= nil then
            return raw[k]
        end

        return Setting[k]
    end,

    __call = function(t, ...)
        return t:__call(...)
    end
}

return Setting