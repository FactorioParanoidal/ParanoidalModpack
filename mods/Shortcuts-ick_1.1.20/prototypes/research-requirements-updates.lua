--[[ Copyright (c) 2021 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of research-requirements-updates.lua:
	* Compatibility with IR2
	* General compatibility
]]


---------------------------------------------------------------------------------------------------
--Compatibility with IR2
---------------------------------------------------------------------------------------------------
local function change_technology_to_unlock(shortcut, tech)
    if data.raw.shortcut[shortcut] then
        data.raw.shortcut[shortcut].technology_to_unlock = tech
    end
end

if settings.startup["ick-compatibility-mode"].value == false then
	change_technology_to_unlock("toggle-personal-logistic-requests", nil)
	change_technology_to_unlock("environment-killer", nil)
	change_technology_to_unlock("tree-killer", nil)
	change_technology_to_unlock("cliff-fish-item-on-ground", nil)
elseif mods["IndustrialRevolution"] then
	change_technology_to_unlock("toggle-personal-logistic-requests", "ir2-robotower")
	change_technology_to_unlock("environment-killer", "personal-roboport-equipment")
	change_technology_to_unlock("tree-killer", "personal-roboport-equipment")
	change_technology_to_unlock("cliff-fish-item-on-ground", "personal-roboport-equipment")
end


---------------------------------------------------------------------------------------------------
--Remove technology_to_unlock and/or change action for mod shortcuts in order to make them available based in researched in a specific game.
---------------------------------------------------------------------------------------------------
if settings.startup["ick-compatibility-mode"].value == false then
	if mods["circuit-checker"] and data.raw.shortcut["check-circuit"] then
		data.raw.shortcut["check-circuit"].action = "lua"
		data.raw.shortcut["check-circuit"].item_to_spawn = nil
		data.raw.shortcut["check-circuit"].technology_to_unlock = nil
	end
	if mods["Spider_Control"] and data.raw.shortcut["squad-spidertron-follow"] then
		data.raw.shortcut["squad-spidertron-follow"].technology_to_unlock = nil
	end
	if mods["Spider_Control"] and data.raw.shortcut["squad-spidertron-remote"] then
		data.raw.shortcut["squad-spidertron-remote"].technology_to_unlock = nil
	end
	if mods["Spider_Control"] and data.raw.shortcut["squad-spidertron-list"] then
		data.raw.shortcut["squad-spidertron-list"].technology_to_unlock = nil
	end
	if mods["Spider_Control"] and data.raw.shortcut["squad-spidertron-link-tool"] then
		data.raw.shortcut["squad-spidertron-link-tool"].technology_to_unlock = nil
	end
	if mods["pump"] and data.raw.shortcut["pump-shortcut"] then
		data.raw.shortcut["pump-shortcut"].action = "lua"
		data.raw.shortcut["pump-shortcut"].item_to_spawn = nil
		data.raw.shortcut["pump-shortcut"].technology_to_unlock = nil
	end
	if mods["RailSignalPlanner"] and data.raw.shortcut["give-rail-signal-planner"] then
		data.raw.shortcut["give-rail-signal-planner"].action = "lua"
		data.raw.shortcut["give-rail-signal-planner"].item_to_spawn = nil
	end
end