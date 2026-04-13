---@meta
----------------------------------------------------------------------------------------------------
--- Initialize this mod's globals
----------------------------------------------------------------------------------------------------

---@class MiniLoaderMod
---@field other_mods table<string, string>
---@field MiniLoader miniloader.Controller
---@field Snapping miniloader.Snapping
---@field Console miniloader.Console
This = {
    other_mods = {
        ['PickerDollies'] = 'picker-dollies',
        ['even-pickier-dollies'] = 'picker-dollies',
    },
}

Framework.settings:add_defaults(require('lib.settings'))


if script then
    This.MiniLoader = require('scripts.controller')
    This.Snapping = require('scripts.snapping')
    This.Console = require('scripts.console')
    require('scripts.gui')
end
