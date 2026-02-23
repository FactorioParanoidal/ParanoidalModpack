------------------------------------------------------------------------
-- Framework initialization code
--
-- provides the global `Framework` object
--
------------------------------------------------------------------------

local Is = require('stdlib.utils.is')

----------------------------------------------------------------------------------------------------

--- Framework central access point
-- The framework singleton, provides access to well known constants and the Framework components
-- other components.

---@class FrameworkRoot
---@field PREFIX string
---@field NAME string
---@field STORAGE string
---@field GAME_ID integer,
---@field RUN_ID integer,
---@field settings FrameworkSettings?
---@field logger FrameworkLogger?
---@field runtime FrameworkRuntime?
---@field gui_manager framework.gui_manager?
---@field ghost_manager framework.ghost_manager?
---@field blueprint framework.blueprint.Manager?
---@field tombstone framework.tombstone_manager?
---@field translation_manager framework.translation.Manager?
---@field other_mods framework.OtherModsManager
---@field remote_api table<string, function>?
---@field render FrameworkRender?
Framework = {
    --- The non-localised prefix (textual ID) of this mod.
    -- Must be set as the earliest possible time, as virtually all other framework parts use this.
    PREFIX = 'unknown-module-',

    --- Human readable, non-localized name
    NAME = '<unknown>',

    --- Root location
    ROOT = '__unknown__',

    --- Name of the field in `global` to store framework persistent runtime data.
    STORAGE = 'framework',

    GAME_ID = -1,

    RUN_ID = -1,

    settings = nil,

    logger = nil,

    runtime = nil,

    gui_manager = nil,

    ghost_manager = nil,

    blueprint = nil,

    translation_manager = nil,

    tombstone = nil,

    remote_api = nil,

    render = nil,
}

--- called in runtime stage
---@param config FrameworkConfig
function Framework:init_runtime(config)
    -- runtime stage
    self.runtime = self.runtime or require('framework.runtime')

    self.logger:init()

    self.logger:log('================================================================================')
    self.logger:log('==')
    self.logger:logf("== Framework logfile for '%s' mod intialized ", Framework.NAME)     --(debug mode: %s)", Framework.NAME, tostring(self.debug_mode))
    self.logger:log('==')
    self.logger:logf('== Run ID: %d', Framework.RUN_ID)
    self.logger:log('================================================================================')
    self.logger:flush()

    self.gui_manager = self.gui_manager or require('framework.gui_manager')
    self.ghost_manager = self.ghost_manager or require('framework.ghost_manager')
    self.blueprint = self.blueprint or require('framework.blueprint_manager')
    self.translation_manager = self.translation_manager or require('framework.translation_manager')
    self.tombstone = self.tombstone or require('framework.tombstone_manager')

    self.render = self.render or require('framework.render')

    if config.remote_name and not self.remote_api then
        self.remote_api = {}
        remote.add_interface(config.remote_name, self.remote_api)
    end
end

--- Initialize the core framework.
--- the code itself references the global Framework table.
---@param config FrameworkConfig|function():FrameworkConfig config provider
function Framework:init(config)
    assert(Is.Function(config) or Is.Table(config), 'configuration must either be a table or a function that provides a table')
    if Is.Function(config) then
        config = config()
    end

    assert(config, 'no configuration provided')
    assert(config.name, 'config.name must contain the mod name')
    assert(config.prefix, 'config.prefix must contain the mod prefix')
    assert(config.root, 'config.root must be contain the module root name!')

    self.NAME = config.name
    self.PREFIX = config.prefix
    self.ROOT = config.root

    -- load only once per stage
    self.settings = self.settings or require('framework.settings') --[[ @as FrameworkSettings ]]
    self.logger = self.logger or require('framework.logger') --[[ @as FrameworkLogger ]]
    self.other_mods = self.other_mods or require('framework.other-mods')

    if data and data.raw['gui-style'] then
        -- data stage
        require('framework.prototype')
    elseif script then
        -- runtime stage
        self:init_runtime(config --[[@as FrameworkConfig]])
    end

    return self
end

---------------------------------------------------------------------------------------------------
-- add meta methods
---------------------------------------------------------------------------------------------------

local game_stages = { 'settings', 'data', 'data_updates', 'data_final_fixes', 'runtime' }

local Framework_mt = {}
setmetatable(Framework, Framework_mt)

local prototype = {}

for _, game_stage in pairs(game_stages) do
    prototype['post_' .. game_stage .. '_stage'] = function()
        -- otherwise, it is an stage method, pass it to the submodules
        Framework.other_mods[game_stage]() -- other-mods subsystem
    end
end

Framework_mt.__index = prototype

return Framework
