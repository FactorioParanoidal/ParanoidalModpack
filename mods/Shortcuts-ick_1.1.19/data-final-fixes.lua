--[[ Copyright (c) 2021 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of data-updates.lua:
	* Generation of disabled artillery
	* Autogeneration of modded shortcuts
]]

---------------------------------------------------------------------------------------------------
-- GENERATION OF DISABLED ARTILLERY
---------------------------------------------------------------------------------------------------
-- Moved here because of mod "heroturrets"

local artillery_toggle = settings.startup["artillery-toggle"].value

if artillery_toggle == "both" or artillery_toggle == "artillery-wagon" or artillery_toggle == "artillery-turret" then

	local disable_turret_types = {}

	if artillery_toggle == "both" then
		disable_turret_types = {"artillery-wagon", "artillery-turret"}
	else
		disable_turret_types = {artillery_toggle}
	end

  for a, type in pairs(disable_turret_types) do
    for b, entity in pairs(data.raw[type]) do
      if string.sub(entity.name,1,9) ~= "disabled-" then

        -- DISABLED TURRET
        local disabled_turret = table.deepcopy(entity)
              disabled_turret.name = "disabled-" .. entity.name
              table.insert(disabled_turret.flags, "hidden")
              if entity.localised_name then
                disabled_turret.localised_name = {"", entity.localised_name, " (", {"gui-constant.off"}, ")"}
              else
                disabled_turret.localised_name = {"", {"entity-name." .. entity.name}, " (", {"gui-constant.off"}, ")"}
              end
							if data.raw.item[entity.name] or data.raw["item-with-entity-data"][entity.name] then
                disabled_turret.placeable_by = {item = entity.name, count = 1}
              end
							if data.raw.recipe[entity.name] then
								if entity.subgroup == nil and data.raw.recipe[entity.name].subgroup then
									disabled_turret.subgroup = data.raw.recipe[entity.name].subgroup
								end
								if entity.order == nil and data.raw.recipe[entity.name].order then
									disabled_turret.order = data.raw.recipe[entity.name].order
								end
							end
              if disabled_turret.icon then
                disabled_turret.icons = {{icon = entity.icon, tint = {0.5, 0.5, 0.5}}}
                disabled_turret.icon = nil
              end

        -- DISABLED GUN
        local disabled_gun = table.deepcopy(data.raw.gun[entity.gun])
              disabled_gun.name = "disabled-" .. entity.gun
              disabled_gun.localised_name = disabled_turret.localised_name
              disabled_gun.flags = {"hidden"}
              disabled_gun.attack_parameters.range = 0
              disabled_gun.attack_parameters.min_range = 0
              if disabled_gun.icon then
                disabled_gun.icons = {{icon = disabled_gun.icon, tint = {0.5, 0.5, 0.5}}}
                disabled_gun.icon = nil
              end

        -- LINKAGE
        disabled_turret.gun = disabled_gun.name

        data:extend({disabled_turret, disabled_gun})
      end
    end
  end

end


---------------------------------------------------------------------------------------------------
-- AUTOGENERATION OF MODDED SHORTCUTS
---------------------------------------------------------------------------------------------------
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
		"squad-spidertron-remote-sel",
		"squad-spidertron-unlink-tool",
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
					icon =
					{
						filename = icon,
						priority = "extra-high-no-scale",
						size = icon_size,
						flags = {"icon"}
					},
				}

				data:extend({shortcut})
				hide_the_remote(name, name, tool) 	--	only attempts to hide the selection-tool if the recipe/tech name matches the tool name - does not search all recipes for mention of the tool.
			end
		end
	end

end
