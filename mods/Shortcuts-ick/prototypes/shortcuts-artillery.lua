--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of shortcuts-artillery.lua:
	* Artillery targeting remote shortcut.
	* AdvancedArtilleryRemotesContinued shortcuts.
	* Artillery Bombardment Remote shortcuts
	* Toggle artillery cannon fire
		- configuration
		- shortcut
		- selection tool
	* MIRV targeting remote shortcut.
	* AtomicArtilleryRemote shortcut.
	* Landmine thrower shortcut.
]]

-- TAGS
local artillery_targeting_remote = ""
local artillery_cluster_remote = ""
local artillery_discovery_remote = ""
local artillery_bombardment_remote = ""
local smart_artillery_bombardment_remote = ""
local smart_artillery_exploration_remote = ""
local artillery_turret = ""
local mirv_targeting_remote = ""
local atomic_artillery_targeting_remote = ""
local landmine_thrower_remote = ""
if settings.startup["ick-tags"].value == "tags" then
	local tag = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]"}
	artillery_targeting_remote = tag
	artillery_cluster_remote = tag
	artillery_discovery_remote = tag
	artillery_bombardment_remote = tag
	smart_artillery_bombardment_remote = tag
	smart_artillery_exploration_remote = tag
	artillery_turret = tag
	mirv_targeting_remote = tag
	atomic_artillery_targeting_remote = tag
	landmine_thrower_remote = tag
elseif settings.startup["ick-tags"].value == "icons" then
	artillery_targeting_remote = "[img=item/artillery-targeting-remote] "
	artillery_cluster_remote = "[img=item/artillery-cluster-remote] "
	artillery_discovery_remote = "[img=item/artillery-discovery-remote] "
	artillery_bombardment_remote = "[img=item/artillery-bombardment-remote] "
	smart_artillery_bombardment_remote = "[img=item/smart-artillery-bombardment-remote] "
	smart_artillery_exploration_remote = "[img=item/smart-artillery-exploration-remote] "
	artillery_turret = "[img=item/artillery-turret] "
	mirv_targeting_remote = "[img=item/mirv-targeting-remote] "
	atomic_artillery_targeting_remote = "[img=item/artillery-targeting-remote] "
	landmine_thrower_remote = "[img=item/landmine-thrower-remote] "
end

-- ARTILLERY TARGETING REMOTE
if settings.startup["artillery-targeting-remote"].value then
	data:extend({{
		type = "shortcut",
		name = "artillery-targeting-remote",
		localised_name = {"", artillery_targeting_remote, {"item-name.artillery-targeting-remote"}},
		order = "d[artillery]-a[artillery-targeting-remote]",
		action = "lua",
		style = "red",
		icon = {
			filename = "__Shortcuts-ick__/graphics/artillery-targeting-remote-x32-white.png",
			priority = "extra-high-no-scale",
			size = 32,
			scale = 0.5,
			flags = {"gui-icon"}
		},
		small_icon = {
			filename = "__Shortcuts-ick__/graphics/artillery-targeting-remote-x24-white.png",
			priority = "extra-high-no-scale",
			size = 24,
			scale = 0.5,
			flags = {"gui-icon"}
		}
	}})
end

-- ADVANCED ARTILLERY REMOTES CONTINUED
if settings.startup["artillery-targeting-remote"].value and data.raw.capsule["artillery-cluster-remote"] and data.raw.capsule["artillery-discovery-remote"] then
	data:extend({
		{
			type = "shortcut",
			name = "artillery-cluster-remote",
			localised_name = {"", artillery_cluster_remote, {"item-name.artillery-cluster-remote"}},
			order = "d[artillery]-b[artillery-cluster-remote]",
			action = "lua",
			style = "red",
			icon = {
				filename = "__Shortcuts-ick__/graphics/artillery-cluster-remote-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 0.5,
				flags = {"gui-icon"}
			}
		},
		{
			type = "shortcut",
			name = "artillery-discovery-remote",
			localised_name = {"", artillery_discovery_remote, {"item-name.artillery-discovery-remote"}},
			order = "d[artillery]-c[artillery-discovery-remote]",
			action = "lua",
			style = "red",
			icon = {
				filename = "__Shortcuts-ick__/graphics/artillery-discovery-remote-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 0.5,
				flags = {"gui-icon"}
			}
		}
	})
end

-- ARTILLERY BOMBARDMENT REMOTES
if settings.startup["artillery-targeting-remote"].value and data.raw["selection-tool"]["artillery-bombardment-remote"] and data.raw["selection-tool"]["smart-artillery-bombardment-remote"] and data.raw["selection-tool"]["smart-artillery-exploration-remote"] then
	data:extend({
		{
			type = "shortcut",
			name = "artillery-bombardment-remote",
			localised_name = {"", artillery_bombardment_remote, {"item-name.artillery-bombardment-remote"}},
			order = "d[artillery]-e[artillery-bombardment-remote]",
			action = "lua",
			icon = {
				filename = data.raw["selection-tool"]["artillery-bombardment-remote"].icons[1].icon,
				priority = "extra-high-no-scale",
				size = 32,
				scale = 0.5,
				flags = {"gui-icon"}
			}
		},
		{
			type = "shortcut",
			name = "smart-artillery-bombardment-remote",
			localised_name = {"", smart_artillery_bombardment_remote, {"item-name.smart-artillery-bombardment-remote"}},
			order = "d[artillery]-e[smart-artillery-bombardment-remote]",
			action = "lua",
			icon = {
				filename = data.raw["selection-tool"]["smart-artillery-bombardment-remote"].icons[1].icon,
				priority = "extra-high-no-scale",
				size = 32,
				scale = 0.5,
				flags = {"gui-icon"}
			}
		},
		{
			type = "shortcut",
			name = "smart-artillery-exploration-remote",
			localised_name = {"", smart_artillery_exploration_remote, {"item-name.smart-artillery-exploration-remote"}},
			order = "d[artillery]-f[smart-artillery-exploration-remote]",
			action = "lua",
			icon = {
				filename = data.raw["selection-tool"]["smart-artillery-exploration-remote"].icons[1].icon,
				priority = "extra-high-no-scale",
				size = 32,
				scale = 0.5,
				flags = {"gui-icon"}
			}
		}
	})
end


-- TOGGLE ARTILLERY CANNON FIRE
local artillery_toggle = settings.startup["artillery-toggle"].value
if artillery_toggle == "both" or artillery_toggle == "artillery-wagon" or artillery_toggle == "artillery-turret" then

	local disable_turret_list = {}
	if artillery_toggle == "both" then
		disable_turret_list = {"artillery-wagon", "artillery-turret"}
	else
		disable_turret_list = {artillery_toggle}
	end

	data:extend({
		{
			type = "shortcut",
			name = "artillery-jammer-tool",
			localised_name = {"", artillery_turret, {"item-name.artillery-jammer-tool"}},
			order = "d[artillery]-g[artillery-jammer-tool]",
			action = "lua",
			style = "red",
			icon = {
				filename = "__Shortcuts-ick__/graphics/artillery-jammer-tool-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 0.5,
				flags = {"gui-icon"}
			},
			small_icon = {
				filename = "__Shortcuts-ick__/graphics/artillery-jammer-tool-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 0.5,
				flags = {"gui-icon"}
			}
		},
		{
			type = "selection-tool",
			name = "artillery-jammer-tool",
			subgroup = "tool",
			order = "c[automated-construction]-a[artillery-jammer-tool]",
			icon = "__Shortcuts-ick__/graphics/artillery-jammer-tool-red.png",
			icon_size = 32,
			flags = {"hidden", "only-in-cursor", "not-stackable"},
			stack_size = 1,
			selection_color = { r = 1, g = 0, b = 0 },
			alt_selection_color = { r = 1, g = 0, b = 0 },
			selection_mode = {"blueprint"},
			alt_selection_mode = {"blueprint"},
			selection_cursor_box_type = "not-allowed",
			alt_selection_cursor_box_type = "not-allowed",
			entity_type_filters = disable_turret_list,
			alt_entity_type_filters = disable_turret_list,
			tile_filters = {"tile-unknown"},
			alt_tile_filters = {"tile-unknown"}
		}
	})
end

-- MIRV
if mods["MIRV"] and data.raw.capsule["mirv-targeting-remote"] and settings.startup["mirv-targeting-remote"].value then
	data:extend({{
		type = "shortcut",
		name = "mirv-targeting-remote",
		localised_name = {"", mirv_targeting_remote, ": [/color]", {"item-name.mirv-targeting-remote"}},
		order = "d[artillery]-h[mirv-targeting-remote]",
		action = "lua",
		style = "red",
		icon = {
			filename = "__Shortcuts-ick__/graphics/mirv-targeting-remote-x32-white.png",
			priority = "extra-high-no-scale",
			size = 32,
			scale = 0.5,
			flags = {"gui-icon"}
		},
		small_icon = {
			filename = "__Shortcuts-ick__/graphics/mirv-targeting-remote-x24-white.png",
			priority = "extra-high-no-scale",
			size = 24,
			scale = 0.5,
			flags = {"gui-icon"}
		}
	}})
end

-- ATOMIC ARTILLERY
if mods["AtomicArtilleryRemote"] and settings.startup["atomic-artillery-targeting-remote"].value then
	data:extend({{	
		type = "shortcut",
		name = "atomic-artillery-targeting-remote",
		localised_name = {"", atomic_artillery_targeting_remote, {"item-name.atomic-artillery-targeting-remote"}},
		order = "d[artillery]-i[atomic-artillery-targeting-remote]",
		action = "lua",
		style = "red",
		icon = {
			filename = "__Shortcuts-ick__/graphics/mirv-targeting-remote-x32-white.png",
			priority = "extra-high-no-scale",
			size = 32,
			scale = 0.5,
			flags = {"gui-icon"}
		},
		small_icon = {
			filename = "__Shortcuts-ick__/graphics/mirv-targeting-remote-x24-white.png",
			priority = "extra-high-no-scale",
			size = 24,
			scale = 0.5,
			flags = {"gui-icon"}
		}
	}})
end

-- LAND MINE THROWER
if mods["landmine-thrower"] and data.raw.capsule["landmine-thrower-remote"] and settings.startup["landmine-thrower-remote"].value then
	data:extend({{
		type = "shortcut",
		name = "landmine-thrower-remote",
		localised_name = {"", landmine_thrower_remote, {"item-name.landmine-thrower-remote"}},
		order = "d[artillery]-j[landmine-thrower-remote]",
		action = "lua",
		style = "red",
		icon =
		{
			filename = "__Shortcuts-ick__/graphics/landmine-thrower-remote-x24-white.png",
			priority = "extra-high-no-scale",
			size = 24,
			scale = 0.5,
			flags = {"gui-icon"}
		}
	}})
end
