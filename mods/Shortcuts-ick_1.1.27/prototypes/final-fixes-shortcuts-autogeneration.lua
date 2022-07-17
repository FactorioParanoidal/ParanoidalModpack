--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of final-fixes-shortcuts-autogeneration.lua:
	* Autogeneration of modded shortcuts
]]

-- Moved here because of mod "northifytool".

local function hide_the_remote(recipe, technology, item)
	if item then
		if item.flags then
			table.insert(item.flags, "only-in-cursor")
			table.insert(item.flags, "spawnable")
		else
			item.flags = {"only-in-cursor", "spawnable"}
		end
	end
	local recipe_prototype = data.raw.recipe[recipe]
	local tech_prototype = data.raw.technology[technology]
	if recipe_prototype then
		recipe_prototype.hidden = true
		recipe_prototype.ingredients = {{"iron-plate", 1}}
		if technology ~= nil and tech_prototype then
			local effect = tech_prototype.effects
			for i, e in pairs(effect) do
				if effect[i].type == "unlock-recipe" then
					if effect[i].recipe == recipe then
						table.remove(effect, i)
						return
					end
				end
			end
		end
	end
end

local autogen_color = settings.startup["autogen-color"].value
if autogen_color == "default" or autogen_color == "red" or autogen_color == "green" or autogen_color == "blue" then

	--	create a post on the discussion page if you want your shortcut to be added to this ignore_list.
	local shortcut_ignore_list = {
		"artillery-bombardment-remote",
		"smart-artillery-bombardment-remote",
		"smart-artillery-exploration-remote",
		"artillery-jammer-tool",
		"autotrash-network-selection",
		"circuit-checker",
		"fp_beacon_selector",
		"max-rate-calculator",
		"module-inserter",
		"merge-chest-selector",
		"outpost-builder",
		"path-remote-control",
		"pump-selection-tool",
		"rail-signal-planner",
		"rcalc-all-selection-tool",
		"rcalc-electricity-selection-tool",
		"rcalc-heat-selection-tool",
		"rcalc-materials-selection-tool",
		"rcalc-pollution-selection-tool",
		"selection-tool",
		"se-energy-transmitter-targeter",
		"se-delivery-cannon-targeter",
		"squad-spidertron-remote-sel",
		"squad-spidertron-unlink-tool",
		"tms-switcher",
		"trainbuilder-manual",
		"unit-remote-control",
		"well-planner",
		"winch",
		"wire-cutter-copper",
		"wire-cutter-green",
		"wire-cutter-red",
		"wire-cutter-universal"
	}

	for _, tool in pairs(data.raw["selection-tool"]) do
		local name = tool.name
		local continue = true
		for j, ignore_list in pairs(shortcut_ignore_list) do
			if name == ignore_list then
				continue = false
				break
			end
		end

		if continue == true then
			local create = true
			for i, shortcut in pairs(data.raw["shortcut"]) do
				if shortcut.action == "spawn-item" and shortcut.item_to_spawn == name then
					create = false
					break
				end
			end

			if create == true then
				local icon
				local icon_size
				if tool.icon then
					icon = tool.icon
				elseif tool.icons then
					icon = tool.icons[1].icon
				else
					icon = "__core__/graphics/shoot.png"
				end

				if tool.icons and tool.icons[1].icon_size then
					icon_size = tool.icons[1].icon_size
				elseif tool.icon_size then
					icon_size = tool.icon_size
				else
					icon_size = 32
				end

				local shortcut = {
					type = "shortcut",
					name = name,
					order = tool.order,
					action = "spawn-item",
					localised_name = {"item-name." .. name},
					item_to_spawn = name,
					style = settings.startup["autogen-color"].value,
					icon = {
						filename = icon,
						priority = "extra-high-no-scale",
						size = icon_size,
						flags = {"icon"}
					}
				}

				data:extend({shortcut})
				hide_the_remote(name, name, tool) -- only attempts to hide the selection-tool if the recipe/tech name matches the tool name - does not search all recipes for mention of the tool.
			end
		end
	end

end
