----------------------------------------------------------------------------------------------------
-- Support for other (optional) mods.
--
-- Must be defined in This.other_mods. If a mod is loaded, finds scripts.other-mods.<mod-name> and calls
-- - settings() in settings phase
-- - data() in first data phase
-- - data_updates() in second data phase
-- - data_final_fixes() in last data phase
-- - runtime() in runtime phase
--
-- An optional mod called 'framework' is always called.
-- runtime() is called if the mod was activated in the current game.
-- all other phases depend on mod[<modname>] being present
----------------------------------------------------------------------------------------------------

---@class framework.OtherModsManager
local OtherMods = {}

local OtherMods_mt = {
    __index = function(_, stage)
        return function()
            if not (This and This.other_mods) then return end
            for mod_name, alias in pairs(This.other_mods) do
                if (script and script.active_mods[mod_name]) or (mods and mods[mod_name]) or mod_name == 'framework' then
                    local mod_support = require('lib.other-mods.' .. alias)
                    if mod_support[stage] then
                        mod_support[stage]()
                    end
                end
            end
        end
    end
}

setmetatable(OtherMods, OtherMods_mt)

return OtherMods
