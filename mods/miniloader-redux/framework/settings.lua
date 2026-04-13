----------------------------------------------------------------------------------------------------
-- framework settings support -- inspired by flib
----------------------------------------------------------------------------------------------------

local table = require('stdlib.utils.table')

----------------------------------------------------------------------------------------------------

---@enum FrameworkSettings.name
local setting_types = {
    startup = 'startup',
    runtime = 'runtime',
    player = 'player',
}

--- Access to all mod settings
---@class FrameworkSettings
local FrameworkSettings = {
}

---@type table<FrameworkSettings.name, FrameworkSettingsProvider>
local settings_table = {
    startup = {
        values = nil,
        definitions = { debug_mode = { key = Framework.PREFIX .. 'debug-mode', value = false } },
        load_value = function(name) return settings.startup[name] end,
        get_values = function(self) return self.values end,
        init_values = function(self)
            self.values = {}
            return self.values
        end,
        clear = function(self) self.values = nil end,
    },

    runtime = {
        values = nil,
        definitions = {},
        load_value = function(name) return settings.global[name] end,
        store_value = function(name, value) settings.global[name] = { value = value } end,
        get_values = function(self) return self.values end,
        init_values = function(self)
            self.values = {}
            return self.values
        end,
        clear = function(self) self.values = nil end,
    },

    player = {
        values = {},
        definitions = {},
        load_value = function(name, player_index)
            if player_index then
                return settings.get_player_settings(player_index)[name]
            else
                return settings.player_default[name]
            end
        end,
        store_value = function(name, value, player_index)
            if player_index then
                game.players[player_index].mod_settings[name] = { value = value }
            else
                settings.player_default[name] = { value = value }
            end
        end,
        get_values = function(self, player_index)
            local index = player_index or 'default'
            return self.values[index]
        end,
        init_values = function(self, player_index)
            local index = player_index or 'default'
            self.values[index] = {}
            return self.values[index]
        end,
        clear = function(self, player_index)
            if player_index then
                self.values[player_index] = {}
            else
                self.values = {}
            end
        end,
    },
}

--- Add setting definitions of the given setting_type to the corresponding table
---@param definitions table<FrameworkSettings.name, FrameworkSettingsGroup>
---@return self FrameworkSettings
function FrameworkSettings:add_defaults(definitions)
    for key in pairs(setting_types) do
        if settings_table[key].definitions then
            table.merge(settings_table[key].definitions, definitions[key])
            settings_table[key]:clear()
        end
    end

    return self
end

--- Access the mod's settings
---@param setting_type FrameworkSettings.name Setting setting_type. Valid values are "startup", "runtime" and "player"
---@param player_index integer? The current player index.
---@return table<string, FrameworkSettingValue?> result
function FrameworkSettings:get_settings(setting_type, player_index)
    local settings_group = settings_table[setting_type]

    local values = settings_group:get_values(player_index)
    if values then return values end

    values = settings_group:init_values(player_index)

    for key, setting_def in pairs(settings_group.definitions) do
        local setting = settings_group.load_value(setting_def.key, player_index)
        values[key] = (setting and (setting.value ~= nil) and setting.value) or setting_def.value
    end

    Framework.logger:debugf("Loaded '%s' settings: %s", setting_type, serpent.line(settings_group:get_values()))
    return values
end

---@param setting_type FrameworkSettings.name Setting setting_type. Valid values are "startup", "runtime" and "player"
---@param name string
---@param value FrameworkSettingValue
---@param player_index integer? The current player index.
function FrameworkSettings:set_setting(setting_type, name, value, player_index)
    local settings_group = settings_table[setting_type]
    if settings_group.store_value then
        settings_group.store_value(name, value, player_index)
        settings_group:clear(player_index)
    end
end

--- Flushes all cached settings.
--- The next access to a setting will reload them from the game.
function FrameworkSettings:flush()
    settings_table.player:clear()
    settings_table.runtime:clear()
    settings_table.startup:clear()
end

--- Access the startup settings.
---@return table<string, FrameworkSettingValue?> result
function FrameworkSettings:startup_settings()
    return self:get_settings('startup')
end

--- Access a single startup setting.
---@param name string
---@return FrameworkSettingValue? result
function FrameworkSettings:startup_setting(name)
    return self:startup_settings()[name]
end

--- Access the runtime settings.
---@return table<string, FrameworkSettingValue?> result
function FrameworkSettings:runtime_settings()
    return self:get_settings('runtime')
end

--- Access a single runtime setting.
---@param name string
---@param new_value FrameworkSettingValue?
---@return FrameworkSettingValue? result
function FrameworkSettings:runtime_setting(name, new_value)
    local value = self:runtime_settings()[name]
    if new_value ~= nil then
        self:set_setting('runtime', name, new_value)
    end
    return value
end

--- Access the player settings. If no player index is given, use the default player settings in settings.player.
---@param player_index integer? The current player index.
---@return table<string, FrameworkSettingValue?> result
function FrameworkSettings:player_settings(player_index)
    return self:get_settings('player', player_index)
end

--- Access a single player settings. If no player index is given, use the default player settings in settings.player.
---@param name string
---@param player_index integer? The current player index.
---@param new_value FrameworkSettingValue?
---@return FrameworkSettingValue? result
function FrameworkSettings:player_setting(name, player_index, new_value)
    local value = self:player_settings(player_index)[name]
    if new_value ~= nil then
        self:set_setting('player', name, new_value, player_index)
    end
    return value
end

----------------------------------------------------------------------------------------------------

if script then
    local Event = require('stdlib.event.event')

    local function flush()
        Framework.settings:flush()
    end

    local function register_events()
        Event.on_configuration_changed(flush)
        Event.register(defines.events.on_runtime_mod_setting_changed, flush)
    end

    Event.on_init(register_events)
    Event.on_load(register_events)
end

return FrameworkSettings
