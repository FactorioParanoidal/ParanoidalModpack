--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of shortcuts-artillery.lua:
	* Toggle artillery cannon fire
		- configuration
		- shortcut
		- selection tool
]]

-- TAGS
local artillery_turret
if settings.startup["ick-tags"].value == "tags" then
	local tag = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]"}
	artillery_turret = tag
elseif settings.startup["ick-tags"].value == "icons" then
	artillery_turret = "[img=item/artillery-turret] "
else
	artillery_turret = ""
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
			technology_to_unlock = "artillery",
			unavailable_until_unlocked = true,
			style = "red",
			icon = "__Shortcuts-ick__/graphics/artillery-jammer-tool-x32-white.png",
			icon_size = 32,
			small_icon = "__Shortcuts-ick__/graphics/artillery-jammer-tool-x24-white.png",
			small_icon_size = 24
		},
		{
			type = "selection-tool",
			name = "artillery-jammer-tool",
			subgroup = "tool",
			order = "c[automated-construction]-a[artillery-jammer-tool]",
			icon = "__Shortcuts-ick__/graphics/artillery-jammer-tool-red.png",
			icon_size = 32,
			flags = {"only-in-cursor", "not-stackable", "spawnable"},
			hidden = true,
			stack_size = 1,
			select = {
				mode = "blueprint",
				entity_type_filters = disable_turret_list,
				tile_filters = {"tile-unknown"},
				cursor_box_type = "not-allowed",
				border_color = {r = 1, g = 0, b = 0}
			},
			alt_select = {
				mode = "blueprint",
				entity_type_filters = disable_turret_list,
				tile_filters = {"tile-unknown"},
				cursor_box_type = "not-allowed",
				border_color = {r = 1, g = 0, b = 0}
			}
		}
	})
end
