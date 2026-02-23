--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of research-requirements-updates.lua:
	* General compatibility
]]

---------------------------------------------------------------------------------------------------
-- General compatibility
---------------------------------------------------------------------------------------------------
local function remove_technology_to_unlock(shortcut)
	if data.raw.shortcut[shortcut] then
		data.raw.shortcut[shortcut].technology_to_unlock = nil
	end
end

if settings.startup["ick-compatibility-mode"].value then
	remove_technology_to_unlock("tree-killer")
	remove_technology_to_unlock("artillery-jammer-tool")
	remove_technology_to_unlock("rail-block-visualization-toggle")
end
