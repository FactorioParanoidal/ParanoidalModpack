--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of updates-shortcuts-artillery.lua:
	* AdvancedArtilleryRemotesContinued artillery-cluster-remote-artillery-shell shortcut.
]]

-- TAGS
local artillery_cluster_remote_artillery_shell = ""

if settings.startup["ick-tags"].value == "tags" then
	local tag = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]"}
	artillery_cluster_remote_artillery_shell = tag
elseif settings.startup["ick-tags"].value == "icons" then
	artillery_cluster_remote_artillery_shell = "[img=item/artillery-cluster-remote-artillery-shell] "
end

-- ADVANCED ARTILLERY REMOTES CONTINUED
-- Mod initialises cluster remotes during data-updates phase, which requires initialising the shortcut during the same phase and use of hidden dependency to ensure load order.
if settings.startup["artillery-targeting-remote"].value and data.raw.capsule["artillery-cluster-remote-artillery-shell"] then
	data:extend({
		{
			type = "shortcut",
			name = "artillery-cluster-remote-artillery-shell",
			localised_name = {"", artillery_cluster_remote_artillery_shell, data.raw.capsule["artillery-cluster-remote-artillery-shell"].localised_name },
			order = "d[artillery]-b[artillery-cluster-remote-artillery-shell]",
			action = "lua",
			style = "red",
			icon = {
				filename = "__Shortcuts-ick__/graphics/artillery-cluster-remote-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 0.5,
				flags = {"gui-icon"}
			}
		}
	})
end
