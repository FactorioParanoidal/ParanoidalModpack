local config = {}
local prefix = 'additional-paste-settings-'

for k, v in pairs(settings.global) do
    if string.sub(k, 1, #prefix) == prefix then
        config[string.sub(k, #prefix + 1)] = v.value
    end
end

local function settings_changed(e)
    if string.sub(e.setting, 1, #prefix) ~= prefix then return end
    if e.setting_type == "runtime-per-user" then return end

    local key = string.sub(e.setting, #prefix + 1)
    config[key] = settings.global[e.setting].value
end

script.on_event(defines.events.on_runtime_mod_setting_changed, settings_changed)

return config
