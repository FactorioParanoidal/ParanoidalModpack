--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of startup-artillery.lua
	* Artillery targeting remote
	* Artillery cannon toggle
	* MOD: Advanced Artillery Remotes Continued
	* MOD: Artillery Bombardment Remote / Artillery Bombardment Remote (Reloaded) / Artillery Bombardment Remote (DBot's fork)
	* MOD: M.I.R.V. targeting remote
	* MOD: Atomic Artillery Remote
	* MOD: Landmine thrower
]]

data:extend(
{
	{
    	setting_type = "startup",
		name = "artillery-targeting-remote",
    	localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"item-name.artillery-targeting-remote"}},
    	order = "d[artillery]-a[artillery-targeting-remote]",
		type = "bool-setting",
		default_value = true
	},
	{
		setting_type = "startup",
		name = "artillery-toggle",
		localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"Shortcuts-ick.artillery-toggle"}},
		order = "d[artillery]-d[artillery-jammer-tool]",
		type = "string-setting",
		allowed_values = {"disabled", "both", "artillery-wagon", "artillery-turret"},
		default_value = "both"
	}
})

if mods["AdvancedArtilleryRemotesContinued"] then -- only here to allow checks in control.lua
	data:extend({{
		setting_type = "startup",
		name = "advanced-artillery-remote",
		hidden = true,
		type = "bool-setting",
		default_value = true,
		forced_value = true
	}})
end

if mods["artillery-bombardment-remote"] or mods["artillery-bombardment-remote-reloaded"] or mods["dbots-artillery-bombardment-remote"] then -- only here to allow checks in control.lua
	data:extend({{
		setting_type = "startup",
		name = "artillery-bombardment-remote",
		hidden = true,
		type = "bool-setting",
		default_value = true,
		forced_value = true
	}})
end

if mods["MIRV"] then
	data:extend({{
		setting_type = "startup",
		name = "mirv-targeting-remote",
		localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"item-name.mirv-targeting-remote"}},
		order = "d[artillery]-h[mirv-targeting-remote]",
		type = "bool-setting",
		default_value = true
	}})
end

if mods["AtomicArtilleryRemote"] then
	data:extend({{
		setting_type = "startup",
		name = "atomic-artillery-targeting-remote",
		localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"item-name.atomic-artillery-targeting-remote"}},
		order = "d[artillery]-i[atomic-artillery-targeting-remote]",
		type = "bool-setting",
		default_value = true
	}})
end

if mods["landmine-thrower"] then
	data:extend({{
		setting_type = "startup",
		name = "landmine-thrower-remote",
		localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"item-name.landmine-thrower-remote"}},
		order = "d[artillery]-j[landmine-thrower-remote]",
		type = "bool-setting",
		default_value = true
	}})
end
