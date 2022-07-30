---@class Setting
---@field name string
---@field type string

---@class Config
---@field setting Setting[]

local config = {} ---@type Config

local prefix = 'additional-paste-settings-'

for k, v in pairs(settings.global) do
    if string.sub(k, 1, #prefix) == prefix then
        config[string.sub(k, #prefix + 1)] = v.value
    end
end

---@param event on_runtime_mod_setting_changed
local function settings_changed(event)
    if string.sub(event.setting, 1, #prefix) ~= prefix then return end
    if event.setting_type == "runtime-per-user" then return end

    local key = string.sub(event.setting, #prefix + 1)
    config[key] = settings.global[event.setting].value
end

script.on_event(defines.events.on_runtime_mod_setting_changed, settings_changed)

return config
